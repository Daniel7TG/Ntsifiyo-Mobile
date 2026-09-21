import 'coyote_controller.dart';

/// Mensaje del coyote por sección (mirror de ROUTE_MESSAGES en MainLayout.jsx).
const coyoteSectionMessages = <String, (String, CoyoteEmotion)>{
  '/inicio': (
    '¡Hola! Este es tu camino de aprendizaje. Sigue avanzando de tema en tema.',
    CoyoteEmotion.saludo
  ),
  '/explorar': (
    '¡Explora el mapa de aventuras o descubre canciones, leyendas y poemas!',
    CoyoteEmotion.esperando
  ),
  '/palabras': (
    '¡El diccionario mágico! Busca palabras en mazahua para expandir tu vocabulario.',
    CoyoteEmotion.pensando
  ),
  '/perfil': (
    'Aquí puedes ver tus progresos, asignaciones y la tabla de líderes.',
    CoyoteEmotion.saludo
  ),
  '/perfil/asignaciones': (
    'Revisa las tareas que te asignaron tus profesores. ¡Vamos a completarlas!',
    CoyoteEmotion.pensando
  ),
};

/// Instrucción al entrar a un juego, por id corto de activityConfig
/// (mirror del switch de gameType en MainLayout.jsx).
const _gameInstructions = <String, String>{
  'memoria_rapida':
      '¡Rápido! Toca el visto bueno si la carta coincide con la palabra de arriba, o la cruz si es diferente.',
  'memorama':
      'Voltea las cartas de dos en dos para encontrar los pares ocultos. ¡Pon a prueba tu memoria!',
  'quiz':
      'Lee con atención y elige la respuesta correcta entre las opciones disponibles.',
  'intruso':
      'Observa bien el grupo de cartas y selecciona la única que NO pertenece a la familia o es diferente.',
  'pares':
      'Selecciona una carta de la izquierda y luego su pareja en la derecha para unirlas.',
  'loteria':
      'Presta atención a las cartas que van saliendo y márcalas en tu tablero si las tienes. ¡Llena el tablero!',
  'laberinto':
      '¡Guía a tu personaje por el laberinto hasta encontrar la respuesta correcta sin chocar!',
  'tripas':
      'Une con una línea las parejas correctas. ¡Pero mucho cuidado, las líneas no pueden cruzarse!',
  'encuentra_palabra':
      'Busca las palabras escondidas en la sopa de letras. ¡Pueden estar en cualquier dirección!',
  'fill_blank':
      'Observa la oración incompleta y selecciona la palabra correcta para llenarla.',
};

String coyoteGameInstruction(String gameId) =>
    _gameInstructions[gameId] ??
    '¡Demuestra todo lo que has aprendido! Completa la actividad para ganar puntos.';
