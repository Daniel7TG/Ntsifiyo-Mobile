# Presentación — Sección del Modelo (3 diapositivas finales)

Fuentes de los números: `modelo/centroides_y_config.json`, `modelo/umbral.json`,
`experimentos/amsoftmax.json`, `experimentos/am_mas_dtw.json`,
`experimentos/comparacion_referencias.json`, `experimentos/punto_de_operacion.json`,
`experimentos/dtw_pronunciacion.json`, `ENTRADA_DE_AUDIO.md`.

---

## Diapositiva 1 — Cómo está construido el modelo

### Idea en una frase

No es un reconocedor de voz que transcribe. Es un **comparador**: convierte cada grabación en un
vector de 128 números y mide qué tan lejos queda de la referencia de la palabra que el niño debía decir.

### Arquitectura (tres bloques)

```
Audio del micrófono (16 kHz, mono, 0.25 s – 2.0 s)
        │
        ├─ Gate de voz: ¿esto es habla o es ruido de salón?
        ├─ Preprocesado: recorte de silencio, normalización de volumen (RMS 0.1)
        ▼
┌─────────────────────────────────────────────────────────┐
│ 1. BACKBONE — wav2vec2 XLS-R-300M (congelado)           │
│    300 M de parámetros, 25 capas Transformer            │
│    Se extrae la capa 14 → 1024 dimensiones              │
│    No se reentrena: aporta el "oído" general del habla  │
└──────────────────────────┬──────────────────────────────┘
                           ▼
┌─────────────────────────────────────────────────────────┐
│ 2. CABEZA DE PROYECCIÓN (entrenada con audio mazahua)   │
│    LayerNorm(1024) → Linear(256) → GELU → Dropout(0.1)  │
│    → Linear(128) → normalización L2                     │
│    Solo 1.2 MB de pesos entrenados sobre los niños      │
└──────────────────────────┬──────────────────────────────┘
                           ▼
              Vector de 128 dimensiones, unitario
                  (vive sobre una hiperesfera)
                           ▼
┌─────────────────────────────────────────────────────────┐
│ 3. DECISIÓN — distancia coseno contra el prototipo      │
│    similitud = v · prototipo[palabra]                   │
│    distancia = 1 − similitud                            │
│    correcto  = distancia ≤ 0.2406                       │
└─────────────────────────────────────────────────────────┘
```

### Los dos ingredientes clave

**(a) AM-Softmax (Additive Margin Softmax)** — cómo se entrenó la cabeza.

Es un softmax de clasificación sobre las 43 palabras, pero con dos modificaciones:
- **Escala `s = 30`**: agudiza la decisión sobre vectores unitarios.
- **Margen aditivo `m = 0.35`**: al calcular la pérdida se le resta 0.35 a la similitud de la
  clase correcta. El modelo se ve obligado a acercar cada ejemplo a su palabra *con 0.35 de
  ventaja* sobre la palabra rival más cercana.
- Término extra de **calidad (`λ = 1.0`)**: además de "qué palabra es", el entrenamiento usa
  las calificaciones humanas de pronunciación.

Efecto: no basta con clasificar bien; el espacio queda **geométricamente ordenado**, con clases
compactas y separadas. Eso es lo que permite que después una simple distancia funcione.

**(b) Distancia de cosenos** — cómo se decide en producción.

Del entrenamiento AM-Softmax se conserva la matriz de **prototipos**: un vector unitario aprendido
por palabra (mejor que promediar los ejemplos: +0.8 pts en top-1 y −3.8 pts de EER frente al
centroide promediado). En la app no hay softmax ni clasificador: se calcula el vector del niño,
se compara por coseno contra el prototipo y se corta en el umbral 0.2406.

Por qué coseno y no distancia euclídea: los vectores están L2-normalizados, así que solo importa
la **dirección** — el timbre, el volumen y el tamaño de la voz del niño quedan fuera de la medida.

### Lo que se probó y no se quedó (evidencia, no intuición)

| Alternativa | Resultado | Decisión |
|---|---|---|
| Triplet Loss (línea base) | top-1 = 0.579 | Reemplazado por AM-Softmax |
| Mezcla aprendida de las 25 capas | top-1 = 0.917 | No supera a la capa 14 sola |
| Cabeza ordinal CORAL (4 niveles) | top-1 baja a 0.854 | Descartado |
| DTW (alineamiento temporal) fusionado | ver diapositiva 3 | Solo como refuerzo |

### Despliegue

Exportado a **ONNX cuantizado a int8** (`validador_int8.onnx`, 191 MB frente a 759 MB en fp32).
Entrada: forma de onda cruda `[1, N]`. Salida: `embedding_128`. Sin espectrogramas, sin MFCC:
wav2vec2 lleva su propio front-end convolucional dentro del grafo. Corre local, sin servidor.

---

## Diapositiva 2 — Resultados: identificación de palabra

**La pregunta:** *"¿qué palabra dijo el niño?"* — clasificación sobre vocabulario cerrado.

### Protocolo de evaluación

- **Leave-One-Child-Out con 14 particiones**: se entrena con 13 niños y se evalúa con el niño que
  el modelo nunca oyó. Nada de mezclar al mismo niño en entrenamiento y prueba.
- 2 semillas (42, 43); desviación entre semillas ≈ 0.001 → los resultados no son suerte.
- 43 palabras activas (de 47 originales; se excluyeron `burro`, `delantal` y `lasOrejas` por
  etiquetado inconsistente).
- 2674 emisiones bien pronunciadas + 3172 mal pronunciadas.

### Resultado principal (modelo desplegado)

| Métrica | Valor |
|---|---|
| **Top-1** (acierta la palabra exacta) | **98.5 %** |
| **Top-3** (está entre las 3 primeras) | **99.8 %** |
| **EER de palabra equivocada** | **0.44 %** |
| Vocabulario | 43 palabras |

Leído en claro: de cada 1000 grabaciones, el modelo identifica correctamente unas 985 y
prácticamente nunca confunde una palabra con otra.

### Cómo se llegó ahí — el salto que dio AM-Softmax

| Configuración | Top-1 | Top-3 | EER palabra |
|---|---|---|---|
| Triplet Loss (línea base) | 57.9 % | 76.4 % | 14.1 % |
| AM-Softmax + centroides | 97.6 % | 99.7 % | 0.82 % |
| **AM-Softmax + prototipos (desplegado)** | **98.5 %** | **99.8 %** | **0.44 %** |

Cambiar la función de pérdida —de tripletes a AM-Softmax con margen— pasó la identificación de
palabra de "más o menos la mitad" a "prácticamente resuelta": **+40 puntos de top-1** y el error
de confusión dividido por 32. Además entrena más rápido: 40 s frente a 257 s.

### Fusión con DTW (experimento sobre 943 clips)

| Método | Top-1 | Top-3 |
|---|---|---|
| Solo AM-Softmax | 92.5 % | 96.0 % |
| Solo DTW | 88.7 % | 95.5 % |
| Fusión con peso w = 0.3 | **94.7 %** | 96.7 % |

DTW aporta unos 2 puntos en ese experimento, a costa de guardar 9.7 MB de tramas de referencia
y de calcular alineamientos en cada consulta. Con el modelo final ya en 98.5 % de top-1, el
reranker DTW deja de ser necesario para identificar.

### Mensaje para el público

**Identificar la palabra es el problema resuelto.** La app puede confiar en lo que oyó.
La dificultad real está en la siguiente diapositiva.

---

## Diapositiva 3 — Resultados: pronunciación

**La pregunta:** *"¿la pronunció bien?"* — dijo la palabra correcta, pero ¿suena como la
referencia del hablante nativo?

### Resultado principal

| Métrica | Valor |
|---|---|
| **EER de pronunciación** | **34.6 %** |
| Umbral desplegado (distancia coseno) | 0.2406 |
| Tasa de falsos positivos en operación | 35.1 % |
| Tasa de falsos negativos en operación | 34.3 % |
| Muestras | 2674 bien / 3172 mal |

Las distribuciones **se solapan mucho**:

| | Media | Mediana | p10 | p90 |
|---|---|---|---|---|
| Bien pronunciadas | 0.224 | 0.197 | 0.111 | 0.382 |
| Mal pronunciadas | 0.334 | 0.295 | 0.156 | 0.579 |

Hay señal real (las medias se separan y el orden es el correcto), pero no hay un corte limpio:
ninguna elección de umbral baja el error total por debajo de ~34 %.

### Contraste honesto entre las dos tareas

| Tarea | EER |
|---|---|
| ¿Qué palabra dijo? | **0.44 %** |
| ¿La pronunció bien? | **34.6 %** |

Un factor de casi 80 entre ambas. Es el hallazgo central del proyecto y conviene decirlo tal cual.

### Por qué es tan difícil

1. **La etiqueta humana no es unánime.** "Bien pronunciado" es un juicio graduado (0–3) que los
   propios evaluadores no reproducen igual. El modelo está persiguiendo un blanco borroso.
2. **La variabilidad infantil domina la señal.** Entre 6 y 12 años cambian el tracto vocal, el
   ritmo y la fluidez. Esa variación es mayor que la diferencia entre bien y mal pronunciado.
3. **El backbone fue entrenado para identidad léxica, no para calidad fonética.** Está diseñado
   para ser invariante justo a lo que aquí queremos medir.
4. **Referencia única.** Se compara contra un prototipo, no contra el abanico de realizaciones
   válidas de un hablante nativo.

### Qué se intentó para mejorarlo

| Enfoque | EER pronunciación | Resultado |
|---|---|---|
| Prototipo AM-Softmax (desplegado) | 0.346 | Línea base |
| DTW crudo (sin cabeza) | 0.371 | Peor |
| DTW sobre la cabeza | 0.365 | Peor |
| **Fusión prototipo + DTW crudo (w = 0.5)** | **0.339** | Mejor absoluto: −0.7 pts |
| Cabeza ordinal CORAL λ=2 | 0.330 | Mejor EER, pero top-1 cae a 85.4 % |
| Triplet + centroide | 0.362 | Peor |

Ninguna variante rompe la barrera. La mejora de la fusión DTW (0.7 puntos) no justifica su coste
en cómputo y memoria en un dispositivo móvil. **El problema no es de arquitectura, es de datos y
de definición de la etiqueta.**

Comprobación de sanidad: el ruido entre semillas es 0.0003, o sea que las diferencias medidas
son reales, solo que pequeñas.

### Dónde se concentra el error

No está repartido de forma pareja. Palabras como `arroz` (EER 57 %) o `laBoca` (56 %) concentran
una fracción desproporcionada: son términos con pocos ejemplos y con etiquetado más disputado.
Concentrar el esfuerzo de etiquetado ahí es la vía más barata de mejora.

### Cómo lo afronta la aplicación

El veredicto de pronunciación **no se presenta como una calificación**, sino como estímulo:
"✔ Correcto" / "✘ Intenta de nuevo". Con un EER del 35 %, la app funciona como compañero de
práctica que anima a repetir, nunca como evaluador que califica al niño. El componente en el que
sí se puede confiar —saber qué palabra se dijo, 98.5 %— es el que sostiene la experiencia de uso.

### Prueba integrada de extremo a extremo (200 clips reales)

| Métrica | Valor |
|---|---|
| Acierto binario | 77 % |
| Recall en bien pronunciadas | 83 % |
| Recall en mal pronunciadas | 71 % |
| Falsos disparos con 24 buffers de ruido puro | 0 |

El gate de voz elimina por completo los falsos positivos por ruido de salón: antes de existir,
23 de 24 buffers de ruido recibían un veredicto de palabra.

### Cierre de la sección

- Identificación de palabra: **resuelta** (98.5 % top-1).
- Evaluación de pronunciación: **señal útil pero no calificadora** (EER 34.6 %).
- Ambas conclusiones están medidas con leave-one-child-out, la evaluación más exigente
  disponible con 14 niños, y son estables entre semillas.
