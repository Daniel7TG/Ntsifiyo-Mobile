# Guion hablado — Sección del Modelo (3 diapositivas finales)

Duración estimada: 7–9 minutos a ritmo normal. Marcadores `[…]` son indicaciones de entrega,
no se leen en voz alta.

---

## Transición desde la sección de la aplicación móvil

> Hasta aquí les mostré la aplicación: cómo se ve, cómo la usa un niño, qué pasa cuando graba.
> Ahora quiero abrir la caja y contarles qué hay adentro, porque el modelo es la parte que
> decide si todo esto sirve o no sirve. Voy a hacerlo en tres partes: primero cómo está
> construido, luego qué tan bien identifica las palabras, y al final —y esta es la parte
> honesta de la presentación— qué tan bien evalúa la pronunciación.

---

## Diapositiva 1 — Cómo está construido el modelo

### Apertura (la idea central)

> Lo primero que hay que entender es que esto **no es un reconocedor de voz** de los que
> transcriben lo que dices. No convierte audio en texto. Lo que hace es más simple y más
> adecuado para una lengua sin grandes corpus como el mazahua: es un **comparador**.
>
> Toma la grabación del niño, la convierte en un vector de 128 números, y mide qué tan lejos
> queda ese vector de la referencia de la palabra que se supone que debía decir. Cerca es
> "sí, eso es"; lejos es "eso no fue".

### Los tres bloques

> La arquitectura tiene tres bloques.
>
> **El primero es el backbone**: wav2vec2 XLS-R-300M, un modelo de Meta, de 300 millones de
> parámetros, entrenado con miles de horas de habla en muchísimos idiomas. Nosotros lo
> **congelamos**: no lo reentrenamos, no lo tocamos. Aporta el "oído" general del habla humana.
> De sus 25 capas Transformer usamos la **capa 14** —eso no es arbitrario, lo barrimos
> experimentalmente— y de ahí salen 1024 dimensiones por audio.
>
> [pausa]
>
> **El segundo bloque es la cabeza de proyección**, y esta sí es nuestra: es lo único entrenado
> con audio mazahua. Es una red pequeña: LayerNorm, capa lineal a 256, activación GELU, dropout,
> capa lineal a 128, y normalización L2 al final. Pesa **1.2 megabytes**. Ese contraste vale la
> pena subrayarlo: 300 millones de parámetros prestados, y un megabyte y medio propio. Así es
> como se trabaja con una lengua de pocos recursos: se aprovecha lo que otros entrenaron y se
> aprende encima la parte específica.
>
> **El tercer bloque es la decisión**, y es literalmente una resta.

### AM-Softmax (el ingrediente de entrenamiento)

> Ahora, ¿cómo se entrenó esa cabeza? Con **AM-Softmax**: Additive Margin Softmax.
>
> Un softmax normal clasifica: le das un audio, te dice cuál de las 43 palabras es. El problema
> es que un softmax normal se conforma con acertar. Con que el ejemplo caiga del lado correcto
> de la frontera, ya está contento, aunque haya quedado pegadito a la frontera.
>
> AM-Softmax le mete dos cosas. Una **escala**, s igual a 30, y sobre todo un **margen aditivo**,
> m igual a 0.35. Ese margen significa que al calcular la pérdida le restamos 0.35 a la similitud
> de la clase correcta. Es como decirle al modelo: "no me basta con que aciertes; tienes que
> acertar **con 0.35 de ventaja** sobre la palabra rival más parecida".
>
> El efecto es que el espacio de vectores queda **geométricamente ordenado**: cada palabra forma
> un grupo compacto, y los grupos quedan separados entre sí. Y eso es exactamente lo que permite
> que después, en la aplicación, una medida trivial de distancia funcione.
>
> Además le añadimos un término de calidad, lambda igual a 1: el entrenamiento no solo usa la
> etiqueta de qué palabra es, sino también las calificaciones humanas de qué tan bien se pronunció.

### Distancia de cosenos (el ingrediente de producción)

> Y aquí viene lo que me parece más elegante del diseño: **en la aplicación no hay softmax.**
>
> El softmax solo existió durante el entrenamiento. Lo que nos llevamos de ahí es la matriz de
> **prototipos**: un vector unitario aprendido por cada palabra. En el teléfono, el proceso es:
> se calcula el vector del niño, se hace el producto punto contra el prototipo —eso es la
> similitud coseno—, se resta de uno, y se compara contra un umbral: **0.2406**. Si la distancia
> es menor o igual, es correcto.
>
> ¿Por qué coseno y no distancia euclidiana? Porque todos los vectores están normalizados a
> longitud uno. Solo importa la **dirección**, no la magnitud. Y eso significa que el volumen de
> la voz, el timbre, si el niño habla fuerte o bajito, quedan **fuera de la medida por
> construcción**. No hay que corregirlo después: la geometría ya lo resuelve.
>
> Un detalle que aprendimos con dolor: probamos usar **centroides** —el promedio de los ejemplos
> de cada palabra— en lugar de los prototipos aprendidos. Los prototipos ganan: casi un punto más
> de top-1 y casi cuatro puntos menos de error en pronunciación. El modelo aprende una referencia
> mejor de la que nosotros podemos calcular promediando.

### Lo descartado

> Y para que no parezca que llegamos aquí por intuición: probamos alternativas y las medimos.
> Triplet Loss, que era nuestra línea base, se quedó en 58 % de acierto. Una mezcla aprendida de
> las 25 capas en lugar de solo la capa 14: no mejoró. Una cabeza ordinal CORAL, para predecir
> niveles de 0 a 3 en vez de sí/no: bajó la identificación de palabra a 85 %. Todas están
> documentadas en la carpeta de experimentos.

### Cierre de la diapositiva

> Para desplegarlo lo exportamos a **ONNX cuantizado a int8**: 191 megabytes en lugar de 759.
> Recibe la forma de onda cruda, sin espectrogramas ni MFCC —wav2vec2 lleva su propio front-end
> adentro del grafo— y corre **local, sin servidor**. El audio del niño no sale del dispositivo.

---

## Diapositiva 2 — Resultados: identificación de palabra

### Encuadre del protocolo (decirlo antes que los números)

> Antes de darles cifras, quiero decir **cómo** las medimos, porque si no, un número bonito no
> significa nada.
>
> Usamos **leave-one-child-out** con 14 particiones. Entrenamos con 13 niños y evaluamos con el
> niño que el modelo **nunca escuchó**. Nada de mezclar al mismo niño en entrenamiento y prueba,
> que es la forma más común de inflar resultados en tareas de voz. Repetimos con dos semillas
> aleatorias, y la diferencia entre ellas es de una milésima: los números no son suerte.
>
> El vocabulario son **43 palabras** activas, de 47 originales. Excluimos tres —burro, delantal y
> lasOrejas— porque el etiquetado humano era inconsistente; sobre eso vuelvo en la tercera parte.

### El número

> Con eso dicho: el modelo desplegado identifica correctamente la palabra el **98.5 % de las
> veces**. En top-3, 99.8 %. Y el EER de palabra equivocada —confundir una palabra con otra— es
> del **0.44 %**.
>
> [pausa]
>
> Dicho en claro: de cada mil grabaciones, acierta unas 985, y prácticamente nunca confunde una
> palabra con otra.

### El salto

> Lo interesante es de dónde venimos. Con Triplet Loss estábamos en **57.9 %** de top-1 y 14 % de
> error de confusión. Cambiar la función de pérdida a AM-Softmax con margen nos dio **más de 40
> puntos** de top-1 y dividió el error de confusión **entre 32**.
>
> No cambiamos el backbone. No conseguimos más datos. Cambiamos **cómo se organiza el espacio**
> durante el entrenamiento. Y de propina entrena más rápido: 40 segundos en lugar de 257.

### DTW

> También probamos fusionar con **DTW**, alineamiento temporal dinámico, que compara las
> trayectorias de sonido en el tiempo en lugar de un solo vector resumen. En un experimento sobre
> 943 clips, la fusión con peso 0.3 dio 94.7 % contra 92.5 % de AM-Softmax solo. Aporta unos dos
> puntos.
>
> Pero cuesta 9.7 megabytes de tramas de referencia guardadas y un alineamiento por consulta. Con
> el modelo final ya en 98.5 %, ese refuerzo dejó de ser necesario. Lo dejamos documentado, no
> desplegado.

### Cierre

> Conclusión de esta parte: **identificar la palabra es el problema resuelto.** La aplicación
> puede confiar en lo que oyó. La dificultad real está en la siguiente diapositiva.

---

## Diapositiva 3 — Resultados: pronunciación

### Encuadre honesto (marcar el cambio de tono)

> Esta es la diapositiva donde les cuento lo que **no** funcionó tan bien, porque creo que es más
> útil que otra ronda de números buenos.
>
> La segunda pregunta es: el niño dijo la palabra correcta, pero **¿la pronunció bien?** ¿Suena
> como la referencia del hablante nativo?

### El número

> El EER de pronunciación es del **34.6 %**. En operación, con el umbral desplegado, eso son
> 35 % de falsos positivos y 34 % de falsos negativos, sobre 2674 emisiones bien pronunciadas y
> 3172 mal pronunciadas.
>
> Las distribuciones **se solapan mucho**. La distancia media de las bien pronunciadas es 0.224;
> la de las mal pronunciadas, 0.334. Hay señal —el orden es el correcto, no es azar— pero no hay
> un corte limpio. Barrimos todos los umbrales posibles y **ninguno** baja el error total de
> alrededor del 34 %.

### El contraste

> Pónganlo al lado del número anterior:
>
> **Qué palabra dijo: 0.44 % de error. Qué tan bien la dijo: 34.6 %.**
>
> Un factor de casi **ochenta** entre las dos tareas. Ese es, para mí, el hallazgo central del
> proyecto, y prefiero decirlo tal cual.

### Por qué

> ¿Por qué es tan difícil? Cuatro razones.
>
> **Primera, y la más importante: la etiqueta humana no es unánime.** "Bien pronunciado" es un
> juicio graduado de 0 a 3 que los propios evaluadores no reproducen igual entre sí, ni consigo
> mismos en días distintos. El modelo está persiguiendo un blanco borroso. No puedes ser más
> consistente que tus etiquetas.
>
> **Segunda: la variabilidad infantil domina la señal.** Entre 6 y 12 años cambian el tracto
> vocal, el ritmo, la fluidez. Esa variación entre niños es **mayor** que la diferencia entre
> bien y mal pronunciado.
>
> **Tercera: el backbone está entrenado para lo contrario.** wav2vec2 fue diseñado para ser
> invariante a cómo suena la voz y quedarse con qué palabra es. Nosotros queremos medir
> precisamente lo que él aprendió a ignorar.
>
> **Cuarta: la referencia es única.** Comparamos contra un prototipo, no contra el abanico de
> realizaciones válidas que tendría un hablante nativo.

### Qué intentamos

> Y no nos quedamos de brazos cruzados. Probamos DTW crudo: peor, 0.371. DTW sobre la cabeza:
> peor, 0.365. La fusión de prototipo con DTW: **0.339**, el mejor absoluto, siete décimas de
> punto de mejora. La cabeza ordinal CORAL bajó el EER a 0.330 pero se llevó por delante la
> identificación de palabra, que cayó a 85 %.
>
> Ninguna variante rompe la barrera. Y esa es la conclusión técnica importante: **el problema no
> es de arquitectura, es de datos y de definición de la etiqueta.** Siete décimas de punto no
> justifican meter DTW en un teléfono.
>
> El ruido entre semillas es de tres diezmilésimas, así que estas diferencias son reales; solo
> que son pequeñas.

### Dónde está el error

> Y el error no está repartido parejo. Palabras como *arroz*, con 57 % de EER, o *laBoca*, con
> 56 %, concentran una parte desproporcionada. Son términos con pocos ejemplos y con el etiquetado
> más disputado. Eso nos dice **exactamente dónde** invertir el próximo esfuerzo de etiquetado, y
> es la vía de mejora más barata que tenemos.

### Cómo lo resuelve el producto

> Entonces, ¿qué hace uno con un 35 % de error en producción? La respuesta está en el diseño de
> la aplicación, no en el modelo.
>
> El veredicto de pronunciación **no se le presenta al niño como una calificación**. Se presenta
> como estímulo: "Correcto" o "Intenta de nuevo". Con este EER, la app funciona como **compañero
> de práctica** que anima a repetir, **nunca** como evaluador que califica.
>
> Y el componente en el que **sí** se puede confiar —saber qué palabra se dijo, 98.5 %— es el que
> sostiene toda la experiencia de uso: el juego sabe siempre si el niño está intentando la palabra
> que le tocaba.

### La prueba de extremo a extremo

> Probamos el sistema completo sobre 200 clips reales: 77 % de acierto binario, 83 % de recall en
> las bien pronunciadas, 71 % en las mal pronunciadas.
>
> Y un dato que me gusta: con 24 buffers de **ruido puro**, cero falsos disparos. Antes de meter
> el gate de voz, 23 de esos 24 recibían un veredicto de palabra. La aplicación afirmaba oír
> mazahua en el ruido del salón. Ese gate no está puesto a ojo: sus seis constantes salen de un
> script de calibración.

### Cierre de toda la sección

> Y con eso cierro. Tres frases:
>
> **Uno:** identificar la palabra está resuelto, 98.5 % de acierto con un niño que el modelo
> nunca escuchó.
>
> **Dos:** evaluar la pronunciación da señal útil pero no es una calificadora, y el producto está
> diseñado en consecuencia.
>
> **Tres:** ambas conclusiones están medidas con la evaluación más exigente que permiten 14 niños,
> y son estables entre semillas. No estoy reportando el mejor número que encontramos; estoy
> reportando el que sobrevivió a la validación.
>
> Gracias.

---

## Anexo — Respuestas a preguntas probables

**"¿Por qué no usaron Whisper / un ASR comercial?"**
> Porque no existe para mazahua. Whisper no lo cubre, y afinarlo requeriría horas de audio
> transcrito que no hay. Nuestro enfoque necesita solo unos pocos ejemplos por palabra, porque no
> aprende la lengua: aprende a comparar.

**"¿34 % de error no es demasiado para usarlo con niños?"**
> Lo sería si calificara. Por eso no califica. El veredicto es "intenta de nuevo", que en el peor
> caso pide una repetición extra, y la repetición es justamente el ejercicio pedagógico. El riesgo
> real sería que el niño reciba una nota injusta, y ese caso no existe en el diseño.

**"¿Cómo mejorarían el número de pronunciación?"**
> En este orden: primero, doble etiquetado con medida de acuerdo entre evaluadores en las palabras
> problemáticas —arroz, laBoca— para saber cuál es el techo real; segundo, más de una referencia
> nativa por palabra; tercero, más niños. Otra arquitectura es lo último de la lista: ya probamos
> cinco y ninguna movió la aguja.

**"¿Funciona sin internet?"**
> Sí. El modelo va en el dispositivo, 191 MB en ONNX int8. El audio del niño nunca sale del
> teléfono, lo cual además es lo correcto tratándose de menores en una comunidad.

**"¿Cuántos datos usaron?"**
> 14 niños de 6 a 12 años, 43 palabras activas, y del orden de 5800 emisiones evaluadas entre
> bien y mal pronunciadas, más audio aumentado con ruido, reverberación y cambio de tono.

**"¿Por qué la capa 14 y no la última?"**
> Porque lo medimos. Las últimas capas de wav2vec2 se especializan en la tarea con la que fue
> preentrenado y pierden detalle fonético. La zona media conserva mejor la información de cómo
> suena, que es la que necesitamos. También probamos dejar que el modelo aprendiera solo la mezcla
> de las 25 capas, y no superó a la capa 14 sola.
