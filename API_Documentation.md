# Documentación de API - NtsiFiyo

## Tabla de Contenidos

- [Enumeraciones](#enumeraciones)
- [Roles y Niveles de Acceso](#roles-y-niveles-de-acceso)
- [Códigos de Respuesta HTTP](#códigos-de-respuesta-http)
- [Códigos de Error](#códigos-de-error)
- [Estructura de Errores](#estructura-de-errores)
- [Auth Controller](#auth-controller)
- [Activity Controller](#activity-controller)
- [Dictionary Controller](#dictionary-controller)
- [Group Controller](#group-controller)
- [User Controller](#user-controller)
- [Leaderboard Controller](#leaderboard-controller)
- [Admin User Controller](#admin-user-controller)
- [Admin Dashboard Controller](#admin-dashboard-controller)
- [Teacher Dashboard Controller](#teacher-dashboard-controller)
- [Student Dashboard Controller](#student-dashboard-controller)
- [Visitor Dashboard Controller](#visitor-dashboard-controller)
- [Game Controller](#game-controller)
- [Media Controller](#media-controller)
- [Pronunciation Controller](#pronunciation-controller)
- [Catalog Controller](#catalog-controller)

---

## Enumeraciones

### GameType
| Valor | Descripción |
|-------|-------------|
| `QUESTIONNAIRE` | Tipo cuestionario |
| `PAIR` | Tipo emparejar |
| `MEDIA` | Tipo multimedia |

### GameTopic
| Valor | Descripción |
|-------|-------------|
| `VOWELS` | Vocales |
| `COLORS` | Colores |
| `ANIMALS` | Animales |
| `NUMBERS` | Números |
| `FAMILY` | Familia |
| `BODY_PARTS` | Partes del cuerpo |
| `FOOD` | Comida |
| `WEATHER` | Clima |
| `SCHOOL` | Escuela |
| `PROFESSIONS` | Profesiones |
| `NATURE` | Naturaleza |
| `FEELINGS` | Sentimientos |
| `TIME` | Tiempo |
| `OBJECTS` | Objetos |
| `PLACES` | Lugares |

### Difficult
| Valor | Descripción |
|-------|-------------|
| `EASY` | Fácil |
| `MEDIUM` | Medio |
| `HARD` | Difícil |

### UserType
| Valor | Descripción |
|-------|-------------|
| `STUDENT` | Estudiante |
| `TEACHER` | Maestro/Docente |
| `ADMIN` | Administrador |
| `VISITOR` | Visitante |

### MediaType
| Valor | Descripción |
|-------|-------------|
| `SONG` | Canción |
| `ANECDOTE` | Anecdota |
| `LEGEND` | Leyenda |
| `POEM` | Poema |

### PronunciationStatus
| Valor | Descripción |
|-------|-------------|
| `CORRECT` | La pronunciación coincide con la palabra objetivo |
| `INCORRECT` | La pronunciación no coincide con ninguna palabra reconocible |
| `INCORRECT_DIFFERENT_WORD` | Se reconoció una palabra del catálogo, pero distinta a la objetivo |
| `SILENCE` | El audio está vacío, es demasiado corto o solo contiene silencio |

### CatalogChangeType
| Valor | Descripción |
|-------|-------------|
| `CREATED` | El objeto se creó. El cliente debe descargarlo |
| `UPDATED` | El objeto se modificó. El cliente debe volver a descargarlo |
| `DELETED` | El objeto se eliminó. El cliente debe borrarlo de su caché local, no intentar descargarlo |

---

## Roles y Niveles de Acceso

| Rol | Descripción |
|-----|-------------|
| **PUBLIC** | Sin autenticación requerida |
| **STUDENT** | Estudiante registrado |
| **TEACHER** | Maestro/docente |
| **ADMIN** | Administrador del sistema |
| **VISITOR** | Visitante registrado |

### Reglas de Acceso por Path

| Path Pattern | Roles Permitidos |
|--------------|------------------|
| `/api/auth/**` | PUBLIC (todos los endpoints de login/registro) |
| `/api/admin/**` | ADMIN |
| `/api/dashboard/admin/**` | ADMIN |
| `/api/dashboard/teacher/**` | ADMIN, TEACHER |
| `/api/dashboard/student/**` | STUDENT, ADMIN, TEACHER |
| `/api/dictionary/words/daily` | PUBLIC |
| `/api/dictionary/**` | Autenticado |
| `/api/games/{gameId}/preview` | Autenticado |
| `/api/groups/**` | ADMIN (excepto `/groups/students` que también permite TEACHER) |
| `/api/user/available` | ADMIN |
| `/api/user/**` | Autenticado |
| `/api/media` | ADMIN, TEACHER (POST) |
| `/api/media/**` | Autenticado |
| `/api/pronunciation/**` | Autenticado |
| `/api/catalog/updates` | Autenticado |
| `/api/games/**` | TEACHER (para crear/editar/eliminar), Autenticado (para obtener) |
| `/api/activities/**` | Mixto (ver detalles por endpoint) |

---

## Códigos de Respuesta HTTP

| Código | Descripción |
|--------|-------------|
| `200` | OK - Solicitud exitosa |
| `201` | Created - Recurso creado exitosamente |
| `204` | No Content - Respuesta exitosa sin contenido |
| `400` | Bad Request - Datos inválidos o mal formados |
| `401` | Unauthorized - Credenciales incorrectas |
| `403` | Forbidden - No tiene permisos |
| `404` | Not Found - Recurso no encontrado |
| `409` | Conflict - Conflicto de estado (ej. duplicado) |
| `429` | Too Many Requests - Rate limit excedido |
| `500` | Internal Server Error - Error interno del servidor |

---

## Códigos de Error

| Código | Descripción |
|--------|-------------|
| `STUDENT_NOT_FOUND` | Estudiante no encontrado |
| `RATE_LIMIT_EXCEEDED` | Rate limit excedido |
| `VALIDATION_ERROR` | Error de validación |
| `CONSTRAINT_VIOLATION` | Violación de restricción |
| `BAD_CREDENTIALS` | Credenciales incorrectas |
| `USER_NOT_FOUND` | Usuario no encontrado |
| `ILLEGAL_ARGUMENT` | Argumento ilegal |
| `HTTP_MESSAGE_NOT_READABLE` | Mensaje no legible |
| `ENTITY_NOT_FOUND` | Entidad no encontrada |
| `ACCESS_DENIED` | Acceso denegado |
| `RESOURCE_IN_USE` | Recurso en uso (conflicto) |
| `INTERNAL_SERVER_ERROR` | Error interno del servidor |

---

## Estructura de Errores

### Error Response
```json
{
  "message": "string",
  "errorCode": "string",
  "timestamp": "LocalDateTime",
  "path": "string",
  "details": "object | null"
}
```

### Ejemplo de Error de Validación
```json
{
  "message": "Errores de validación en la petición",
  "errorCode": "VALIDATION_ERROR",
  "timestamp": "2026-05-02T10:30:00",
  "path": "/api/auth/login/student",
  "details": {
    "listNumber": "must not be null",
    "grade": "must not be null"
  }
}
```

### Ejemplo de Error de Credenciales
```json
{
  "message": "Credenciales incorrectas",
  "errorCode": "BAD_CREDENTIALS",
  "timestamp": "2026-05-02T10:30:00",
  "path": "/api/auth/login/student",
  "details": null
}
```

---

# Auth Controller

**Base URL:** `/api/auth`

### Endpoints

---

## POST /api/auth/login/student

- **Descripción:** Autentica un estudiante con número de lista y grado
- **Nivel de acceso:** PUBLIC
- **Rate Limit:** Sí (prevención de fuerza bruta)

**Códigos de respuesta:**
- `200` - Login exitoso
- `400` - Datos de login inválidos
- `401` - Credenciales incorrectas
- `429` - Rate limit excedido

### Request Body
```json
{
  "listNumber": 15,
  "grade": 3,
  "password": "password123"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `listNumber` | Integer | Sí | Número de lista del estudiante (1-99) |
| `grade` | Short | Sí | Grado del estudiante (1-6) |
| `password` | String | Sí | Contraseña del estudiante |

### Response Body (200 OK)
```json
{
  "level": 3,
  "totalExperience": 150,
  "grade": 3,
  "firstname": "Juan",
  "lastname": "Pérez",
  "userType": "STUDENT",
  "jwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `level` | Integer | Nivel actual del estudiante |
| `totalExperience` | Integer | Experiencia total acumulada |
| `grade` | Short | Grado del estudiante |
| `firstname` | String | Nombre del estudiante |
| `lastname` | String | Apellido del estudiante |
| `userType` | UserType | Tipo de usuario |
| `jwtToken` | String | Token JWT para autenticación |

---

## POST /api/auth/login/admin

- **Descripción:** Autentica un administrador con username y password
- **Nivel de acceso:** PUBLIC

**Códigos de respuesta:**
- `200` - Login exitoso
- `400` - Datos de login inválidos
- `401` - Credenciales incorrectas
- `429` - Rate limit excedido

### Request Body
```json
{
  "username": "admin001",
  "password": "adminPass123"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `username` | String | Sí | Nombre de usuario del admin |
| `password` | String | Sí | Contraseña del admin |

### Response Body (200 OK)
```json
{
  "firstname": "Admin",
  "lastname": "Sistema",
  "userType": "ADMIN",
  "jwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## POST /api/auth/login/teacher

- **Descripción:** Autentica un maestro con username y password
- **Nivel de acceso:** PUBLIC

**Códigos de respuesta:**
- `200` - Login exitoso
- `400` - Datos de login inválidos
- `401` - Credenciales incorrectas
- `429` - Rate limit excedido

### Request Body
```json
{
  "username": "prof_maria",
  "password": "teacherPass123"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `username` | String | Sí | Nombre de usuario del maestro |
| `password` | String | Sí | Contraseña del maestro |

### Response Body (200 OK)
```json
{
  "firstname": "María",
  "lastname": "García",
  "userType": "TEACHER",
  "jwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## POST /api/auth/login/visitor

- **Descripción:** Autentica un visitante con username y password
- **Nivel de acceso:** PUBLIC

**Códigos de respuesta:**
- `200` - Login exitoso
- `400` - Datos de login inválidos
- `401` - Credenciales incorrectas
- `429` - Rate limit excedido

### Request Body
```json
{
  "username": "visitor_juan",
  "password": "visitorPass123"
}
```

### Response Body (200 OK)
```json
{
  "level": 1,
  "totalExperience": 0,
  "firstname": "Juan",
  "lastname": "Visitante",
  "userType": "VISITOR",
  "jwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

## POST /api/auth/visitor

- **Descripción:** Registra un nuevo visitante
- **Nivel de acceso:** PUBLIC

**Códigos de respuesta:**
- `201` - Visitante registrado exitosamente
- `400` - Datos de registro inválidos
- `409` - Username ya existe

### Request Body
```json
{
  "username": "new_visitor",
  "email": "visitor@example.com",
  "password": "securePassword123",
  "firstname": "Nuevo",
  "lastname": "Visitante"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `username` | String | Sí | Nombre de usuario único (3-50 caracteres) |
| `email` | String | Sí | Correo electrónico válido |
| `password` | String | Sí | Contraseña (mínimo 6 caracteres) |
| `firstname` | String | Sí | Nombre (2-100 caracteres) |
| `lastname` | String | Sí | Apellido (2-100 caracteres) |

### Response Body (201 Created)
```
(empty - solo código de estado)
```

---

# Activity Controller

**Base URL:** `/api/activities`

### Endpoints

---

## GET /api/activities/teacher

- **Descripción:** Obtiene todos los juegos creados por el maestro autenticado
- **Nivel de acceso:** TEACHER

**Códigos de respuesta:**
- `200` - Juegos obtenidos exitosamente
- `403` - No tiene permisos de maestro

### Query Parameters
No aplica

### Response Body (200 OK)
```json
[
  {
    "id": 5,
    "title": "Colores Básicos",
    "difficult": "EASY",
    "gameType": "QUESTIONNAIRE",
    "gameTopic": "COLORS",
    "description": "Aprende los colores básicos en Mazahua",
    "experience": 50,
    "totalQuestions": 10
  },
  {
    "id": 8,
    "title": "Emparejar Animales",
    "difficult": "MEDIUM",
    "gameType": "PAIR",
    "gameTopic": "ANIMALS",
    "description": "Empareja las imágenes con las palabras",
    "experience": 75,
    "totalQuestions": 8
  }
]
```

---

## POST /api/activities/complete

- **Descripción:** Completa una actividad, guarda registros de respuesta y recompensa experiencia proporcional a los aciertos
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Actividad completada exitosamente
- `400` - Datos inválidos o juego sin experiencia configurada
- `404` - Actividad no encontrada

### Request Body
```json
{
  "activityId": 1,
  "startDate": "2026-05-02T10:00:00",
  "correctAnswers": 8,
  "responseLogs": [
    {
      "questionId": 1,
      "responseAnswerId": 5,
      "isCorrect": true
    },
    {
      "questionId": 2,
      "responseAnswerId": 8,
      "isCorrect": true
    },
    {
      "questionId": 3,
      "responseAnswerId": 12,
      "isCorrect": false
    }
  ],
  "gameId": 5
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `activityId` | Integer | Sí | ID de la actividad |
| `startDate` | LocalDateTime | Sí | Fecha de inicio de la actividad |
| `correctAnswers` | Integer | Sí | Ignorado por el servidor: el número de aciertos se **recuenta a partir de `responseLogs`** (`isCorrect=true`) para evitar manipulación desde el cliente. Se mantiene por compatibilidad del contrato. |
| `responseLogs` | List | Sí | Lista de respuestas del estudiante. Fuente autoritativa de aciertos. |
| `gameId` | Integer | Sí | ID del juego |

### Response Body (200 OK)
```json
{
  "xpGained": 33,
  "actualXp": 233,
  "currentLevel": 3,
  "isLevelUp": false
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `xpGained` | Integer | XP otorgada por esta actividad: `round(game.experience * aciertos / game.totalQuestions)`. `game.experience` es el premio máximo (juego perfecto = premio completo); 0 aciertos = 0 XP. |
| `actualXp` | Integer | XP total acumulada del usuario tras sumar `xpGained` |
| `currentLevel` | Integer | Nivel del usuario tras la actualización. Cada nivel requiere más XP que el anterior (curva cuadrática: costo `L → L+1` = `50 * L`) |
| `isLevelUp` | Boolean | `true` si el usuario subió de nivel con esta actividad |

---

## POST /api/activities/start/{activity}

- **Descripción:** Inicia una actividad existente
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Actividad iniciada exitosamente
- `404` - Actividad no encontrada

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `activity` | Long | ID de la actividad |

### Response Body (200 OK)
```json
{
  "activityId": 1,
  "gameId": 5,
  "title": "Colores Básicos",
  "gameType": "QUESTIONNAIRE",
  "gameTopic": "COLORS",
  "difficult": "EASY",
  "experience": 50,
  "totalQuestions": 10,
  "questions": [
    {
      "id": 1,
      "question": "¿Cómo se dice 'rojo' en Mazahua?",
      "wordId": 10,
      "answers": [
        {"id": 1, "answerText": "Chí", "isCorrect": true},
        {"id": 2, "answerText": "Tzui", "isCorrect": false},
        {"id": 3, "answerText": "Xí", "isCorrect": false},
        {"id": 4, "answerText": "Ní", "isCorrect": false}
      ]
    }
  ]
}
```

---

## POST /api/activities/start/game/{gameId}

- **Descripción:** Crea una nueva instancia de actividad desde un juego
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Actividad creada e iniciada exitosamente
- `404` - Juego o usuario no encontrado

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `gameId` | Long | ID del juego |

### Response Body
Mismo formato que `/api/activities/start/{activity}`

---

## GET /api/activities/{type}

- **Descripción:** Obtiene actividades filtradas por tipo (paginado, 10 por página)
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Actividades obtenidas exitosamente
- `400` - Tipo de juego inválido

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `type` | String | Tipo de juego (QUESTIONNAIRE, PAIR, MEDIA) |

### Query Parameters
| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `page` | Integer | 0 | Número de página (0-indexed) |

### Response Body (200 OK)
```json
{
  "content": [
    {
      "gameId": 5,
      "title": "Colores",
      "gameType": "QUESTIONNAIRE",
      "gameTopic": "COLORS",
      "isActive": true,
      "completedCount": 10,
      "totalCount": 25
    }
  ],
  "totalPages": 3,
  "totalElements": 25,
  "size": 10,
  "number": 0
}
```

---

## POST /api/activities/assign

- **Descripción:** Asigna un juego a un grupo
- **Nivel de acceso:** TEACHER

**Códigos de respuesta:**
- `201` - Actividad asignada exitosamente
- `404` - Juego o grupo no encontrado
- `409` - Grupo no pertenece al maestro o instancia duplicada

### Request Body
```json
{
  "gameId": 5
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `gameId` | Integer | Sí | ID del juego a asignar |

### Query Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `groupId` | Long | ID del grupo (enviar como query param) |

### Response Body (201 Created)
```
(empty - solo código de estado)
```

---

## PATCH /api/activities/instance/{groupId}/{gameId}

- **Descripción:** Cambia el estado de una instancia de actividad
- **Nivel de acceso:** TEACHER

**Códigos de respuesta:**
- `200` - Estado actualizado exitosamente
- `404` - Grupo o instancia no encontrada
- `409` - Grupo no pertenece al maestro

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `groupId` | Long | ID del grupo |
| `gameId` | Long | ID del juego |

### Query Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `state` | Boolean | true = activa, false = desactiva |

### Response Body (200 OK)
```
(empty - solo código de estado)
```

---

## GET /api/activities/group/{groupId}

- **Descripción:** Obtiene las actividades asignadas a un grupo
- **Nivel de acceso:** TEACHER

**Códigos de respuesta:**
- `200` - Actividades obtenidas exitosamente
- `404` - Grupo no encontrado

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `groupId` | Long | ID del grupo |

### Query Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `active` | Boolean | true = solo activas, false = solo inactivas, null = todas |

### Response Body (200 OK)
```json
{
  "activities": [
    {
      "gameId": 5,
      "title": "Colores Básicos",
      "difficult": "EASY",
      "gameType": "QUESTIONNAIRE",
      "gameTopic": "COLORS",
      "isActive": true,
      "assignedDate": "2026-05-01",
      "studentActivityIds": [1, 2, 3, 4, 5],
      "completedCount": 3,
      "totalCount": 5
    }
  ]
}
```

---

## GET /api/activities/student

- **Descripción:** Obtiene juegos asignados al estudiante
- **Nivel de acceso:** STUDENT

**Códigos de respuesta:**
- `200` - Juegos obtenidos exitosamente
- `404` - Estudiante no encontrado

### Response Body (200 OK)
```json
[
  {
    "id": 5,
    "title": "Colores Básicos",
    "difficult": "EASY",
    "gameType": "QUESTIONNAIRE",
    "gameTopic": "COLORS",
    "description": "Aprende los colores básicos en Mazahua",
    "experience": 50,
    "totalQuestions": 10
  }
]
```

---

# Dictionary Controller

**Base URL:** `/api/dictionary`

### Endpoints

---

## GET /api/dictionary/words/daily

- **Descripción:** Obtiene una palabra aleatoria del día
- **Nivel de acceso:** PUBLIC

**Códigos de respuesta:**
- `200` - Palabra del día obtenida exitosamente

### Response Body (200 OK)
```json
{
  "id": 15,
  "spanishText": "Rojo",
  "mazahuaText": "Chí",
  "topic": "COLORS"
}
```

---

## GET /api/dictionary/words/categories

- **Descripción:** Obtiene las categorías de palabras disponibles
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Categorías obtenidas exitosamente

### Response Body (200 OK)
```json
{
  "topics": ["VOWELS", "COLORS", "ANIMALS", "NUMBERS", "FAMILY", "BODY_PARTS"]
}
```

---

## GET /api/dictionary/words/{topic}

- **Descripción:** Obtiene palabras por categoría con paginación
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Lista de palabras obtenida exitosamente
- `400` - Categoría o página inválida
- `404` - Categoría no encontrada

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `topic` | GameTopic | Categoría de palabras |

### Query Parameters
| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `page` | Integer | 0 | Número de página |

### Response Body (200 OK)
```json
{
  "words": [
    {
      "id": 1,
      "spanishText": "Rojo",
      "mazahuaText": "Chí"
    },
    {
      "id": 2,
      "spanishText": "Azul",
      "mazahuaText": "Xí"
    }
  ],
  "currentPage": 0,
  "totalPages": 2,
  "totalElements": 15
}
```

---

## DELETE /api/dictionary/words/{id}

- **Descripción:** Elimina una palabra por ID
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `204` - Palabra eliminada exitosamente
- `400` - ID inválido
- `404` - Palabra no encontrada
- `409` - Palabra en uso

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `id` | Long | ID de la palabra |

### Response Body (204 No Content)
```
(empty - solo código de estado)
```

---

## POST /api/dictionary/word

- **Descripción:** Crea una nueva palabra
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `201` - Palabra creada exitosamente
- `400` - Datos de palabra inválidos

### Request Body
```json
{
  "spanishText": "Casa",
  "mazahuaText": "Nda",
  "topic": "OBJECTS",
  "urlSpanishAudio": "https://example.com/audio/casa.mp3",
  "urlMazahuaAudio": "https://example.com/audio/nda.mp3",
  "urlImage": "https://example.com/images/casa.jpg"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `spanishText` | String | Sí | Texto en español |
| `mazahuaText` | String | Sí | Texto en Mazahua |
| `topic` | GameTopic | Sí | Categoría de la palabra |
| `urlSpanishAudio` | String | No | URL del audio en español |
| `urlMazahuaAudio` | String | Sí | URL del audio en Mazahua |
| `urlImage` | String | Sí | URL de la imagen |

### Response Body (201 Created)
```json
{
  "id": 25,
  "spanishText": "Casa",
  "mazahuaText": "Nda",
  "topic": "OBJECTS",
  "urlSpanishAudio": "https://example.com/audio/casa.mp3",
  "urlMazahuaAudio": "https://example.com/audio/nda.mp3",
  "urlImage": "https://example.com/images/casa.jpg"
}
```

---

## POST /api/dictionary/word/media

- **Descripción:** Crea una nueva palabra con archivos multimedia
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `201` - Palabra creada exitosamente
- `400` - Datos o archivos inválidos

### Request Body (Multipart/Form-Data)
| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `spanishText` | String | Sí | Texto en español |
| `mazahuaText` | String | Sí | Texto en Mazahua |
| `topic` | GameTopic | Sí | Categoría de la palabra |
| `image` | MultipartFile | Sí | Archivo de imagen |
| `audio` | MultipartFile | Sí | Archivo de audio |

### Response Body (201 Created)
```json
{
  "id": 26,
  "spanishText": "Perro",
  "mazahuaText": "Ndu",
  "topic": "ANIMALS",
  "urlImage": "https://oci.example.com/.../perro.jpg",
  "urlMazahuaAudio": "https://oci.example.com/.../ndu.mp3"
}
```

---

## GET /api/dictionary/words/details/{id}

- **Descripción:** Obtiene detalles de una palabra por ID
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Detalles obtenidos exitosamente
- `404` - Palabra no encontrada

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `id` | Long | ID de la palabra |

### Response Body (200 OK)
```json
[
  {
    "wordId": 1,
    "spanishText": "Rojo",
    "mazahuaText": "Chí",
    "topic": "COLORS",
    "imageUrl": "https://oci.example.com/.../rojo.jpg",
    "mazahuaAudioUrl": "https://oci.example.com/.../chi.mp3"
  }
]
```

---

## POST /api/dictionary/media

- **Descripción:** Obtiene URLs de medios para una lista de palabras
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - URLs de media obtenidas exitosamente
- `400` - Datos inválidos o palabra no encontrada

### Request Body
```json
{
  "includeImage": true,
  "includeAudio": true,
  "wordIds": [1, 2, 3, 4, 5]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `includeImage` | Boolean | Sí | Incluir URLs de imagen |
| `includeAudio` | Boolean | Sí | Incluir URLs de audio |
| `wordIds` | List<Long> | Sí | Lista de IDs de palabras |

### Response Body (200 OK)
```json
[
  {
    "wordId": 1,
    "spanishText": "Rojo",
    "mazahuaText": "Chí",
    "topic": "COLORS",
    "imageUrl": "https://oci.example.com/.../rojo.jpg",
    "mazahuaAudioUrl": "https://oci.example.com/.../chi.mp3"
  },
  {
    "wordId": 2,
    "spanishText": "Azul",
    "mazahuaText": "Xí",
    "topic": "COLORS",
    "imageUrl": "https://oci.example.com/.../azul.jpg",
    "mazahuaAudioUrl": "https://oci.example.com/.../xi.mp3"
  }
]
```

---

## GET /api/dictionary/game/{gameId}

- **Descripción:** Obtiene medios para palabras de un juego
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Media del juego obtenida exitosamente
- `400` - ID de juego inválido o tipo de juego no soportado
- `404` - Juego no encontrado

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `gameId` | Long | ID del juego |

### Response Body (200 OK)
```json
{
  "gameId": 5,
  "gameType": "QUESTIONNAIRE",
  "questions": [
    {
      "questionId": 1,
      "question": "¿Cómo se dice 'rojo' en Mazahua?",
      "answers": [
        {
          "answerId": 1,
          "answerText": "Chí",
          "isCorrect": true,
          "word": {
            "wordId": 1,
            "spanishText": "Rojo",
            "mazahuaText": "Chí",
            "imageUrl": "https://oci.example.com/.../rojo.jpg",
            "mazahuaAudioUrl": "https://oci.example.com/.../chi.mp3"
          }
        }
      ]
    }
  ]
}
```

---

# Group Controller

**Base URL:** `/api/groups`

### Endpoints

---

## GET /api/groups

- **Descripción:** Obtiene todos los grupos
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `200` - Lista de grupos obtenida exitosamente
- `403` - No tiene permisos de administrador

### Response Body (200 OK)
```json
{
  "groups": [
    {
      "grade": 1,
      "teacherUsername": "prof_juan",
      "teacherName": "Juan Pérez",
      "studentCount": 25,
      "isComplete": true
    },
    {
      "grade": 2,
      "teacherUsername": "prof_maria",
      "teacherName": "María García",
      "studentCount": 22,
      "isComplete": true
    }
  ]
}
```

---

## GET /api/groups/{grade}/students

- **Descripción:** Obtiene todos los estudiantes de un grupo por grado
- **Nivel de acceso:** ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Lista de alumnos obtenida exitosamente
- `400` - El grupo no existe o no tiene alumnos

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `grade` | Integer | Grado del grupo (1-6) |

### Response Body (200 OK)
```json
{
  "students": [
    {
      "username": "est_001",
      "firstname": "Ana",
      "lastname": "López",
      "listNumber": 1,
      "level": 3,
      "totalExperience": 150,
      "inrow": 5
    },
    {
      "username": "est_002",
      "firstname": "Carlos",
      "lastname": "Martínez",
      "listNumber": 2,
      "level": 2,
      "totalExperience": 80,
      "inrow": 3
    }
  ]
}
```

---

## POST /api/groups/{grade}

- **Descripción:** Crea un nuevo grupo para un grado específico
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `201` - Grupo creado exitosamente
- `400` - Error en la creación del grupo

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `grade` | Integer | Grado del grupo (1-6) |

### Request Body
```json
{
  "studentsUsername": ["est_001", "est_002", "est_003"],
  "teacherUsername": "prof_juan"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `studentsUsername` | List<String> | Sí | Lista de usernames de estudiantes |
| `teacherUsername` | String | Sí | Username del maestro |

### Response Body (201 Created)
```
(empty - solo código de estado)
```

---

## POST /api/groups/{grade}/students/{student}

- **Descripción:** Agrega un estudiante a un grupo
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `200` - Alumno agregado al grupo exitosamente
- `400` - Error al agregar estudiante

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `grade` | Integer | Grado del grupo (1-6) |
| `student` | String | Username del estudiante |

### Response Body (200 OK)
```
(empty - solo código de estado)
```

---

## DELETE /api/groups/{grade}/students/{student}

- **Descripción:** Elimina un estudiante de un grupo
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `200` - Alumno eliminado del grupo exitosamente
- `400` - Error al eliminar estudiante

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `grade` | Integer | Grado del grupo (1-6) |
| `student` | String | Username del estudiante |

### Response Body (200 OK)
```
(empty - solo código de estado)
```

---

## PUT /api/groups/{grade}/students/{student}

- **Descripción:** Reasigna un estudiante a un grupo diferente
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `200` - Alumno reasignado exitosamente
- `400` - Error al reasignar estudiante

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `grade` | Integer | Grado destino (1-6) |
| `student` | String | Username del estudiante |

### Response Body (200 OK)
```
(empty - solo código de estado)
```

---

## POST /api/groups/advance-year

- **Descripción:** Avanza el año escolar de todos los alumnos. Cada alumno sube un grado (1→2, 2→3, ..., 5→6) y es reasignado al grupo correspondiente al nuevo grado. Los alumnos del último grado (6°) se gradúan: se desasignan del grupo (`group=null`, `grade=0`, `listNumber=0`) conservando su cuenta. Se recalculan automáticamente los números de lista de todos los grupos afectados.
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `200` - Año avanzado exitosamente
- `403` - No tiene permisos de administrador

### Response Body (200 OK)
```json
{
  "promoted": 42,
  "graduated": 8,
  "processed": 50
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `promoted` | Integer | Alumnos que subieron de grado (1-5 → 2-6) |
| `graduated` | Integer | Alumnos de 6° que se graduaron (desasignados del grupo) |
| `processed` | Integer | Total de alumnos procesados (incluye los ignorados por no tener grado válido) |

---

# User Controller

**Base URL:** `/api/user`

### Endpoints

---

## POST /api/user/session/start

- **Descripción:** Inicia una sesión de usuario
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `201` - Sesión iniciada exitosamente
- `404` - Usuario no encontrado

### Response Body (201 Created)
```
(empty - solo código de estado)
```

---

## PUT /api/user/session/end

- **Descripción:** Finaliza la sesión de usuario actual
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Sesión finalizada exitosamente
- `404` - No hay sesión activa

### Response Body (200 OK)
```
(empty - solo código de estado)
```

---

## GET /api/user/available

- **Descripción:** Obtiene estudiantes disponibles para asignación a grupos
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `200` - Estudiantes disponibles obtenidos exitosamente

### Response Body (200 OK)
```json
{
  "students": [
    {
      "username": "est_099",
      "firstname": "Nuevo",
      "lastname": "Estudiante",
      "listNumber": 99,
      "grade": null
    }
  ]
}
```

---

## GET /api/user/avatar

- **Descripción:** Obtiene el id del avatar del usuario autenticado
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Avatar obtenido exitosamente
- `404` - Usuario no encontrado

### Response Body (200 OK)
```json
7
```

---

## PUT /api/user/avatar

- **Descripción:** Configura el avatar del usuario autenticado. Recibe únicamente el id del avatar.
- **Nivel de acceso:** STUDENT, VISITOR

### Request Body
```json
{
  "avatarId": 7
}
```

| Campo | Tipo | Requerido | Validación |
|-------|------|-----------|------------|
| avatarId | Integer | Sí | Entre 0 y 19 |

**Códigos de respuesta:**
- `200` - Avatar actualizado exitosamente
- `400` - avatarId fuera del rango 0-19
- `403` - El usuario no es estudiante ni visitante
- `404` - Usuario no encontrado

### Response Body (200 OK)
```json
7
```

---

# Leaderboard Controller

**Base URL:** `/api/leaderboard`

### Endpoints

## GET /api/leaderboard

- **Descripción:** Tabla de puntuaciones paginada. El tipo de usuario se filtra automáticamente según quién consulta: los estudiantes solo ven estudiantes y los visitantes solo visitantes. Profesores y admins, que no compiten, pueden elegir la tabla con `userType` (por defecto `STUDENT`).
- **Nivel de acceso:** Autenticado

**Query params:**

| Param | Tipo | Default | Notas |
|-------|------|---------|-------|
| page | int | 0 | Índice de página (base 0) |
| size | int | 20 | Máximo 50 |
| userType | UserType | - | Solo lo respetan TEACHER y ADMIN (`STUDENT` o `VISITOR`); se ignora para estudiantes y visitantes |

Orden: experiencia DESC, nivel DESC, username ASC.
`currentUser` es la fila del usuario autenticado con su rank global, aunque no caiga en la página pedida (`null` para profesores y admins).

**Códigos de respuesta:**
- `200` - Tabla obtenida exitosamente
- `404` - Usuario no encontrado

### Response Body (200 OK)
```json
{
  "userType": "STUDENT",
  "content": [
    {
      "username": "est_001",
      "name": "Ana López",
      "avatarId": 7,
      "level": 5,
      "experience": 520,
      "finishedActivities": 18,
      "rank": 1
    }
  ],
  "currentUser": {
    "username": "est_045",
    "name": "Luis Pérez",
    "avatarId": 3,
    "level": 2,
    "experience": 90,
    "finishedActivities": 4,
    "rank": 34
  },
  "page": 0,
  "size": 20,
  "totalElements": 120,
  "totalPages": 6,
  "first": true,
  "last": false
}
```

---

# Admin User Controller

**Base URL:** `/api/admin`

### Endpoints

---

## POST /api/admin/users

- **Descripción:** Registra un nuevo usuario (estudiante o maestro)
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `201` - Usuario registrado exitosamente
- `400` - Datos de registro inválidos
- `403` - No tiene permisos de administrador

### Request Body
```json
{
  "firstname": "Juan",
  "lastname": "Pérez",
  "userType": "STUDENT",
  "grade": 3
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `firstname` | String | Sí | Nombre (2-100 caracteres, sin números) |
| `lastname` | String | Sí | Apellido (2-100 caracteres, sin números) |
| `userType` | UserType | Sí | STUDENT o TEACHER |
| `grade` | Short | Solo para STUDENT | Grado del estudiante (1-6) |

### Response Body (201 Created)
```json
{
  "username": "est_100",
  "password": "Abc123456",
  "userType": "STUDENT"
}
```

---

## DELETE /api/admin/users/{username}

- **Descripción:** Elimina un usuario por username
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `204` - Usuario eliminado exitosamente
- `400` - Username inválido
- `403` - No tiene permisos de administrador
- `404` - Usuario no encontrado

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del usuario |

### Response Body (204 No Content)
```
(empty - solo código de estado)
```

---

## GET /api/admin/students

- **Descripción:** Obtiene todos los estudiantes
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `200` - Lista de alumnos obtenida exitosamente
- `403` - No tiene permisos de administrador

### Response Body (200 OK)
```json
{
  "students": [
    {
      "username": "est_001",
      "firstname": "Ana",
      "lastname": "López",
      "listNumber": 1,
      "grade": 3,
      "level": 3,
      "totalExperience": 150
    }
  ]
}
```

---

## GET /api/admin/teacher

- **Descripción:** Obtiene todos los maestros
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `200` - Lista de docentes obtenida exitosamente
- `403` - No tiene permisos de administrador

### Response Body (200 OK)
```json
[
  {
    "username": "prof_juan",
    "firstname": "Juan",
    "lastname": "Pérez",
    "groupGrade": 1,
    "groupId": 1,
    "studentCount": 25
  }
]
```

---

## PUT /api/admin/students/{username}

- **Descripción:** Edita un estudiante existente
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `204` - Estudiante actualizado exitosamente
- `400` - Datos inválidos
- `403` - No tiene permisos de administrador
- `404` - Estudiante no encontrado

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del estudiante |

### Request Body
```json
{
  "firstName": "Juan",
  "lastName": "Pérez",
  "grade": 3,
  "listNumber": 5,
  "password": "nueva_contraseña"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `firstName` | String | Sí | Nombre (2-100 caracteres, sin números) |
| `lastName` | String | Sí | Apellido (2-100 caracteres, sin números) |
| `grade` | Short | Sí | Grado (1-6) |
| `listNumber` | Integer | Sí | Número de lista |
| `password` | String | No | Nueva contraseña (3-100 caracteres). Si se omite, no se cambia. |

### Response Body (204 No Content)
```
(empty)
```

---

## PUT /api/admin/teachers/{username}

- **Descripción:** Edita un maestro existente
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `204` - Docente actualizado exitosamente
- `400` - Datos inválidos
- `403` - No tiene permisos de administrador
- `404` - Docente no encontrado

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del maestro |

### Request Body
```json
{
  "firstName": "Juan",
  "lastName": "Pérez",
  "password": "nueva_contraseña"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `firstName` | String | Sí | Nombre (2-100 caracteres, sin números) |
| `lastName` | String | Sí | Apellido (2-100 caracteres, sin números) |
| `password` | String | No | Nueva contraseña (6-100 caracteres). Si se omite, no se cambia. |

### Response Body (204 No Content)
```
(empty)
```

---

## POST /api/admin/register/admin

- **Descripción:** Registra un nuevo administrador
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `201` - Admin registrado exitosamente
- `400` - Datos de registro inválidos
- `403` - No tiene permisos de administrador
- `409` - Username o email ya existe

### Request Body
```json
{
  "username": "new_admin",
  "email": "admin@example.com",
  "password": "AdminPass123",
  "firstName": "Nuevo",
  "lastName": "Administrador"
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `username` | String | Sí | Username único (3-50 caracteres) |
| `email` | String | Sí | Email válido y único |
| `password` | String | Sí | Contraseña (mínimo 6 caracteres) |
| `firstName` | String | Sí | Nombre |
| `lastName` | String | Sí | Apellido |

### Response Body (201 Created)
```
(empty - solo código de estado)
```

---

# Admin Dashboard Controller

**Base URL:** `/api/dashboard/admin`

### Endpoints

---

## GET /api/dashboard/admin

- **Descripción:** Obtiene el dashboard completo del admin
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `200` - Datos obtenidos exitosamente

### Response Body (200 OK)
```json
{
  "groupStudentCounts": [
    {
      "grade": 1,
      "studentCount": 25
    },
    {
      "grade": 2,
      "studentCount": 22
    }
  ],
  "wordCategoryCounts": [
    {
      "topic": "COLORS",
      "count": 10
    },
    {
      "topic": "ANIMALS",
      "count": 15
    }
  ],
  "totalGames": 45,
  "totalActivities": 150,
  "groupTeachers": [
    {
      "grade": 1,
      "teacherName": "Juan Pérez"
    }
  ],
  "averageInrow": 3.5,
  "groupsCompleteStudents": [
    {
      "grade": 1,
      "completeStudents": ["est_001", "est_002"]
    }
  ]
}
```

---

## GET /api/dashboard/admin/groups/students

- **Descripción:** Obtiene el conteo de estudiantes por grupo
- **Nivel de acceso:** ADMIN

### Response Body (200 OK)
```json
[
  {
    "grade": 1,
    "studentCount": 25
  },
  {
    "grade": 2,
    "studentCount": 22
  },
  {
    "grade": 3,
    "studentCount": 28
  }
]
```

---

## GET /api/dashboard/admin/words

- **Descripción:** Obtiene el conteo de palabras por categoría
- **Nivel de acceso:** ADMIN

### Response Body (200 OK)
```json
[
  {
    "topic": "VOWELS",
    "count": 5
  },
  {
    "topic": "COLORS",
    "count": 10
  },
  {
    "topic": "ANIMALS",
    "count": 15
  }
]
```

---

## GET /api/dashboard/admin/games

- **Descripción:** Obtiene el conteo total de juegos
- **Nivel de acceso:** ADMIN

### Response Body (200 OK)
```json
45
```

---

## GET /api/dashboard/admin/activities

- **Descripción:** Obtiene el conteo total de actividades
- **Nivel de acceso:** ADMIN

### Response Body (200 OK)
```json
150
```

---

## GET /api/dashboard/admin/students/inrow

- **Descripción:** Obtiene el promedio de inrow de los estudiantes
- **Nivel de acceso:** ADMIN

### Response Body (200 OK)
```json
3.5
```

---

# Teacher Dashboard Controller

**Base URL:** `/api/dashboard/teacher`

### Endpoints

---

## GET /api/dashboard/teacher/{group}

- **Descripción:** Obtiene el dashboard completo del maestro
- **Nivel de acceso:** ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Datos obtenidos exitosamente

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `group` | Long | ID del grupo |

### Response Body (200 OK)
```json
{
  "totalStudents": 25,
  "assignedActivities": [
    {
      "gameId": 5,
      "title": "Colores",
      "activeCount": 20,
      "completedCount": 15
    }
  ],
  "alertStudents": [
    {
      "username": "est_010",
      "firstname": "Pedro",
      "lastname": "Gómez",
      "level": 2
    }
  ],
  "completeStudents": [
    {
      "username": "est_001",
      "firstname": "Ana",
      "lastname": "López",
      "level": 4
    }
  ]
}
```

---

## GET /api/dashboard/teacher/{group}/students/total

- **Descripción:** Obtiene el total de estudiantes de un grupo
- **Nivel de acceso:** ADMIN, TEACHER

### Response Body (200 OK)
```json
25
```

---

## GET /api/dashboard/teacher/{group}/activities/assigned

- **Descripción:** Obtiene las actividades asignadas del grupo con estadísticas
- **Nivel de acceso:** ADMIN, TEACHER

### Response Body (200 OK)
```json
[
  {
    "gameId": 5,
    "title": "Colores Básicos",
    "activeCount": 20,
    "completedCount": 15
  },
  {
    "gameId": 8,
    "title": "Animales",
    "activeCount": 18,
    "completedCount": 10
  }
]
```

---

## GET /api/dashboard/teacher/{group}/students/alert

- **Descripción:** Obtiene estudiantes en alerta
- **Nivel de acceso:** ADMIN, TEACHER

### Response Body (200 OK)
```json
[
  {
    "username": "est_010",
    "firstname": "Pedro",
    "lastname": "Gómez",
    "level": 2,
    "totalExperience": 80
  }
]
```

---

# Student Dashboard Controller

**Base URL:** `/api/dashboard/student`

### Endpoints

---

## GET /api/dashboard/student

- **Descripción:** Obtiene el dashboard completo del estudiante autenticado
- **Nivel de acceso:** STUDENT, ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Datos obtenidos exitosamente

### Response Body (200 OK)
```json
{
  "level": 3,
  "totalExperience": 150,
  "inrow": 5,
  "pendingGames": [
    {
      "gameId": 5,
      "title": "Colores Básicos",
      "experience": 50
    }
  ],
  "finishedActivities": 10,
  "classmates": [
    {
      "name": "Carlos Martínez",
      "avatarId": 12,
      "level": 4,
      "experience": 200
    }
  ]
}
```

---

## GET /api/dashboard/student/{username}

- **Descripción:** Obtiene el dashboard de un estudiante específico
- **Nivel de acceso:** STUDENT (propio), ADMIN, TEACHER

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del estudiante |

### Response Body (200 OK)
Mismo formato que `/api/dashboard/student`

---

## GET /api/dashboard/student/{username}/level

- **Descripción:** Obtiene el nivel de un estudiante
- **Nivel de acceso:** STUDENT (propio), ADMIN, TEACHER

### Response Body (200 OK)
```json
3
```

---

## GET /api/dashboard/student/{username}/experience

- **Descripción:** Obtiene la experiencia de un estudiante
- **Nivel de acceso:** STUDENT (propio), ADMIN, TEACHER

### Response Body (200 OK)
```json
150
```

---

## GET /api/dashboard/student/{username}/inrow

- **Descripción:** Obtiene los días seguidos que el estudiante ha entrado
- **Nivel de acceso:** STUDENT (propio), ADMIN, TEACHER

### Response Body (200 OK)
```json
5
```

---

## GET /api/dashboard/student/{username}/pending

- **Descripción:** Obtiene las actividades pendientes de un estudiante
- **Nivel de acceso:** STUDENT (propio), ADMIN, TEACHER

### Response Body (200 OK)
```json
[
  {
    "gameId": 5,
    "title": "Colores Básicos",
    "experience": 50
  }
]
```

---

## GET /api/dashboard/student/{username}/finished

- **Descripción:** Obtiene el conteo de actividades terminadas
- **Nivel de acceso:** STUDENT (propio), ADMIN, TEACHER

### Response Body (200 OK)
```json
10
```

---

## GET /api/dashboard/student/{username}/classmates

- **Descripción:** Obtiene el ranking de compañeros de grupo
- **Nivel de acceso:** STUDENT (propio), ADMIN, TEACHER

### Response Body (200 OK)
```json
[
  {
    "name": "Carlos Martínez",
    "avatarId": 12,
    "level": 4,
    "experience": 200
  },
  {
    "name": "Ana López",
    "avatarId": 3,
    "level": 3,
    "experience": 150
  }
]
```

---

# Game Controller

**Base URL:** `/api/games`

### Endpoints

---

## POST /api/games

- **Descripción:** Crea una nueva actividad/juego
- **Nivel de acceso:** TEACHER

**Códigos de respuesta:**
- `201` - Actividad creada exitosamente
- `400` - Datos inválidos
- `403` - No tiene permisos de maestro

### Request Body
```json
{
  "gameType": "QUESTIONNAIRE",
  "gameTopic": "COLORS",
  "title": "Colores Básicos",
  "description": "Aprende los colores básicos en Mazahua",
  "totalQuestions": 10,
  "experience": 50,
  "difficult": "EASY",
  "wordIds": [1, 2, 3, 4, 5],
  "questions": [
    {
      "question": "¿Cómo se dice 'rojo' en Mazahua?",
      "wordId": 1,
      "answers": [
        {"answerText": "Chí", "isCorrect": true, "wordId": 1},
        {"answerText": "Tzui", "isCorrect": false, "wordId": null},
        {"answerText": "Xí", "isCorrect": false, "wordId": null},
        {"answerText": "Ní", "isCorrect": false, "wordId": null}
      ]
    }
  ],
  "gameConfigs": [
    {
      "configKey": "showImages",
      "configValue": "true"
    },
    {
      "configKey": "playAudio",
      "configValue": "true"
    }
  ]
}
```

| Campo | Tipo | Requerido | Descripción |
|-------|------|------------|-------------|
| `gameType` | GameType | Sí | Tipo de juego |
| `gameTopic` | GameTopic | Sí | Tema del juego |
| `title` | String | Sí | Título del juego |
| `description` | String | Sí | Descripción (10-300 caracteres) |
| `totalQuestions` | Integer | Sí | Número total de preguntas |
| `experience` | Integer | Sí | Experiencia por completar |
| `difficult` | Difficult | Sí | Dificultad del juego |
| `wordIds` | List<Long> | No | IDs de palabras asociadas |
| `questions` | List | No | Preguntas del juego |
| `gameConfigs` | List | Sí | Configuración (mínimo 2) |

### Response Body (201 Created)
```
(empty - solo código de estado)
```

---

## GET /api/games

- **Descripción:** Obtiene los juegos paginados (vista previa para el panel de asignar actividades), con filtros opcionales. Sin filtros devuelve el catálogo completo paginado.
- **Nivel de acceso:** TEACHER, ADMIN

**Códigos de respuesta:**
- `200` - Juegos obtenidos exitosamente
- `400` - Filtros inválidos (p. ej. `assignmentStatus` sin `groupId`)
- `403` - No tiene permisos

### Query Params

Todos opcionales. Los filtros se combinan con **AND**; los no enviados no restringen.

| Param | Tipo | Descripción |
|-------|------|-------------|
| `gameType` | GameType | Tipo de juego. **Repetible**: `?gameType=QUESTIONNAIRE&gameType=MEMORY_GAME` filtra por cualquiera de ellos (OR entre sí) |
| `difficult` | Difficult | Dificultad exacta (`EASY` \| `MEDIUM` \| `HARD`) |
| `creator` | String | Username exacto del docente creador |
| `assignmentStatus` | AssignmentStatus | Estado de asignación **respecto a un grupo**. Requiere `groupId` (si falta → `400`) |
| `groupId` | Long | Grupo contra el que se evalúa `assignmentStatus` |
| `page`, `size`, `sort` | Pageable | Paginación y orden estándar de Spring (`?page=0&size=20&sort=title,asc`) |

**Valores de `assignmentStatus`** (la PK de `GameInstance` es `(groupId, gameId)`, así que hay a lo sumo una instancia por par grupo-juego; los tres estados particionan el catálogo respecto a ese grupo):

| Valor | Significado |
|-------|-------------|
| `ASSIGNED` | El juego tiene instancia **activa** en el grupo |
| `UNASSIGNED` | El juego tiene instancia en el grupo, pero **desactivada** |
| `NEVER_ASSIGNED` | El juego **nunca** se asignó al grupo (no existe instancia) |

**Ejemplo:**
```
GET /api/games?gameType=QUESTIONNAIRE&gameType=MEMORY_GAME&difficult=EASY&creator=prof1&assignmentStatus=NEVER_ASSIGNED&groupId=5&page=0&size=20
```

### Response Body (200 OK)

Página de Spring (`Page<GetGamesGameDTO>`). Los objetos de `content` mantienen exactamente la misma forma que antes.

```json
{
  "content": [
    {
      "id": 1,
      "title": "Memorama de Vocales",
      "difficult": "EASY",
      "gameType": "FAST_MEMORY",
      "gameTopic": "VOWELS",
      "description": "Ejercicio para identificar vocales en mazahua",
      "teacher": {
        "firstName": "Juan",
        "lastName": "Pérez"
      },
      "experience": 50,
      "totalQuestions": 10,
      "assignActivityGameConfigDTO": [
        {
          "showImage": true,
          "showText": true,
          "playAudio": false,
          "isMazahua": true
        },
        {
          "showImage": true,
          "showText": false,
          "playAudio": false,
          "isMazahua": false
        }
      ]
    }
  ],
  "totalElements": 42,
  "totalPages": 3,
  "number": 0,
  "size": 20,
  "first": true,
  "last": false
}
```

> **Breaking change:** este endpoint devolvía un array plano (`List`) sin paginar. Ahora devuelve una `Page`; los juegos están en `content`.

---

## GET /api/games/{id}

- **Descripción:** Obtiene los detalles completos de un juego
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Juego obtenido exitosamente
- `404` - Juego no encontrado

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `id` | Long | ID del juego |

### Response Body (200 OK)
```json
{
  "id": 5,
  "gameType": "QUESTIONNAIRE",
  "gameTopic": "COLORS",
  "title": "Colores Básicos",
  "description": "Aprende los colores básicos en Mazahua",
  "totalQuestions": 10,
  "experience": 50,
  "difficult": "EASY",
  "wordIds": [1, 2, 3, 4, 5],
  "gameConfigs": [
    {"configKey": "showImages", "configValue": "true"},
    {"configValue": "true", "configKey": "playAudio"}
  ],
  "questions": [
    {
      "id": 1,
      "question": "¿Cómo se dice 'rojo' en Mazahua?",
      "wordId": 1,
      "answers": [
        {"id": 1, "answerText": "Chí", "isCorrect": true, "wordId": 1},
        {"id": 2, "answerText": "Tzui", "isCorrect": false, "wordId": null}
      ]
    }
  ]
}
```

---

## GET /api/games/{gameId}/preview

- **Descripción:** Devuelve los detalles jugables de un juego (palabras, preguntas, respuestas, media y configuración) **sin crear ni iniciar una actividad**. Entrega exactamente el mismo contenido que `POST /api/activities/start/game/{gameId}`, pero sin `activityId` y sin escribir nada en base de datos, por lo que la partida no queda registrada ni otorga experiencia.
- **Nivel de acceso:** Autenticado (cualquier rol, incluido STUDENT)

**Códigos de respuesta:**
- `200` - Detalles del juego obtenidos exitosamente
- `401` - No autenticado (token ausente, inválido o expirado)
- `404` - Juego no encontrado
- `500` - Error interno del servidor

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `gameId` | Long | ID del juego. Solo dígitos |

### Request

Sin body y sin parámetros de query.

```http
GET /api/games/5/preview
Authorization: Bearer <token>
```

### Response Body (200 OK)
```json
{
  "words": [
    {
      "id": 10,
      "mazahuaWord": "Chí",
      "spanishWord": "rojo",
      "imageUrl": "https://oci.example.com/.../rojo.png?token=...",
      "audioUrl": "https://oci.example.com/.../chi.mp3?token=..."
    }
  ],
  "questions": [
    {
      "id": 1,
      "question": "¿Cómo se dice 'rojo' en Mazahua?",
      "word": {
        "id": 10,
        "mazahuaWord": null,
        "spanishWord": "rojo",
        "imageUrl": "https://oci.example.com/.../rojo.png?token=...",
        "audioUrl": null
      },
      "responseList": [
        {
          "id": 1,
          "answerText": "Chí",
          "isCorrect": true,
          "word": {
            "id": 10,
            "mazahuaWord": "Chí",
            "spanishWord": null,
            "imageUrl": null,
            "audioUrl": "https://oci.example.com/.../chi.mp3?token=..."
          }
        },
        {
          "id": 2,
          "answerText": "Tzui",
          "isCorrect": false,
          "word": null
        }
      ]
    }
  ],
  "mediaId": null,
  "gameConfigs": [
    {"showImage": true, "showText": false, "playAudio": false, "isMazahua": false, "order": 1},
    {"showImage": false, "showText": true, "playAudio": true, "isMazahua": true, "order": 2}
  ]
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `words` | List\<Word\> | Palabras del juego. Lista vacía si el juego no usa palabras directamente |
| `questions` | List\<Question\> | Preguntas del juego. `null` si el juego no tiene preguntas |
| `mediaId` | Integer | ID del media asociado al juego. `null` si no tiene |
| `gameConfigs` | List\<GameConfig\> | Siempre 2 elementos: configuración del lado 1 (`order` 1) y del lado 2 (`order` 2) |

**Objeto Word:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | Long | ID de la palabra |
| `mazahuaWord` | String | Texto en Mazahua. `null` si la configuración no muestra texto o no es Mazahua |
| `spanishWord` | String | Texto en español. `null` si la configuración no muestra texto |
| `imageUrl` | String | URL firmada de la imagen. `null` si la configuración no muestra imagen |
| `audioUrl` | String | URL firmada del audio en Mazahua. `null` si la configuración no reproduce audio |

**Objeto Question:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | Long | ID de la pregunta |
| `question` | String | Texto de la pregunta |
| `word` | Word | Palabra asociada al enunciado, filtrada con la configuración del lado 1. `null` si no tiene |
| `responseList` | List\<Answer\> | Respuestas posibles |

**Objeto Answer:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `id` | Long | ID de la respuesta |
| `answerText` | String | Texto de la respuesta. `null` si la respuesta es solo una palabra |
| `isCorrect` | Boolean | Indica si es la respuesta correcta |
| `word` | Word | Palabra asociada a la respuesta, filtrada con la configuración del lado 2. `null` si no tiene |

**Objeto GameConfig:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `showImage` | Boolean | Mostrar la imagen de la palabra |
| `showText` | Boolean | Mostrar el texto de la palabra |
| `playAudio` | Boolean | Reproducir el audio de la palabra |
| `isMazahua` | Boolean | El texto mostrado es Mazahua en lugar de español |
| `order` | Integer | Lado del juego al que aplica la configuración (1 o 2) |

**Notas:**
- Las URLs de imagen y audio son URLs firmadas del bucket privado y caducan; hay que pedirlas de nuevo si expiran.
- Los campos de `words` se filtran con la combinación (OR) de ambas configuraciones, mientras que la palabra de una pregunta usa la configuración del lado 1 y la de una respuesta la del lado 2. Por eso un mismo campo puede venir en un objeto y llegar `null` en otro.
- El juego debe tener sus 2 configuraciones registradas; de lo contrario la petición falla con `500`.
- Diferencia con `GET /api/games/{id}`: ese endpoint devuelve la definición administrativa del juego (título, dificultad, experiencia, `wordIds`), mientras que este devuelve el contenido listo para jugar, ya filtrado por configuración y con URLs firmadas.

---

## GET /api/games/{type}

- **Descripción:** Obtiene juegos por categoría (paginado)
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Juegos obtenidos exitosamente

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `type` | GameType | Tipo de juego |

### Query Parameters
| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `page` | Integer | 0 | Número de página |
| `size` | Integer | 10 | Tamaño de página |
| `sort` | String | | Ordenamiento |

### Response Body (200 OK)
```json
{
  "content": [
    {
      "id": 5,
      "title": "Colores Básicos",
      "difficult": "EASY",
      "gameType": "QUESTIONNAIRE",
      "gameTopic": "COLORS",
      "description": "Aprende los colores básicos",
      "experience": 50,
      "totalQuestions": 10
    }
  ],
  "totalPages": 3,
  "totalElements": 25,
  "size": 10,
  "number": 0
}
```

---

## GET /api/games/topic/{topic}

- **Descripción:** Obtiene juegos por tema (paginado)
- **Nivel de acceso:** Autenticado

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `topic` | GameTopic | Tema del juego |

### Query Parameters
| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `page` | Integer | 0 | Número de página |
| `size` | Integer | 10 | Tamaño de página |

### Response Body (200 OK)
```json
{
  "content": [
    {
      "id": 5,
      "title": "Colores Básicos",
      "difficult": "EASY",
      "experience": 50,
      "totalQuestions": 10
    }
  ],
  "totalPages": 1,
  "totalElements": 5,
  "size": 10,
  "number": 0
}
```

---

## PUT /api/games/{id}

- **Descripción:** Edita un juego (solo el creador o admin)
- **Nivel de acceso:** TEACHER (creador), ADMIN

**Códigos de respuesta:**
- `200` - Juego actualizado exitosamente
- `400` - Datos inválidos
- `403` - No tiene permisos
- `404` - Juego no encontrado

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `id` | Long | ID del juego |

### Request Body
Mismo formato que GET /api/games/{id}

### Response Body (200 OK)
```
(empty - solo código de estado)
```

---

## DELETE /api/games/{id}

- **Descripción:** Elimina un juego
- **Nivel de acceso:** TEACHER (creador), ADMIN

**Códigos de respuesta:**
- `204` - Juego eliminado exitosamente
- `403` - No tiene permisos
- `404` - Juego no encontrado

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `id` | Long | ID del juego |

### Response Body (204 No Content)
```
(empty - solo código de estado)
```

---

## GET /api/games/activities/{gameId}/students/{studentUsername}/responses

- **Descripción:** Obtiene las respuestas de un estudiante
- **Nivel de acceso:** TEACHER, ADMIN

**Códigos de respuesta:**
- `200` - Respuestas obtenidas exitosamente
- `403` - No tiene permisos
- `404` - Actividad no encontrada

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `gameId` | Long | ID del juego |
| `studentUsername` | String | Username del estudiante |

### Response Body (200 OK)
```json
[
  {
    "questionId": 1,
    "questionText": "¿Cómo se dice 'rojo' en Mazahua?",
    "studentAnswerId": 1,
    "studentAnswerText": "Chí",
    "isCorrect": true,
    "responseTimestamp": "2026-05-02T10:30:00"
  }
]
```

---

# Media Controller

**Base URL:** `/api/media`

### Endpoints

---

## POST /api/media

- **Descripción:** Sube un nuevo media (video o audio) con subtítulos en español y mazahua
- **Nivel de acceso:** ADMIN, TEACHER

**Códigos de respuesta:**
- `201` - Media creado exitosamente
- `400` - Datos o archivos inválidos
- `403` - No tiene permisos
- `500` - Error interno al procesar el archivo

### Request Body (Multipart/Form-Data)

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `title` | String | Sí | Título del media |
| `description` | String | Sí | Descripción del media |
| `mediaType` | String | Sí | Tipo de media (SONG, ANECDOTE, LEGEND, POEM) |
| `seasonMonth` | Integer | Sí | Mes de temporada (1-12) |
| `difficult` | String | Sí | Dificultad (EASY, MEDIUM, HARD) |
| `mediaFile` | MultipartFile | Sí | Archivo de video o audio (solo uno) |
| `previewImage` | MultipartFile | No | Imagen de preview (requerida para audio) |
| `espSubtitles` | MultipartFile | Sí | Subtítulos en español (VTT) |
| `mazSubtitles` | MultipartFile | Sí | Subtítulos en mazahua (VTT) |

### Notas
- Si el archivo es **video**, se convierte a **WebM** con resolución máxima **720p** y se extrae el primer fotograma como preview si no se envía una imagen.
- Si el archivo es **audio**, se convierte a **MP3** y se requiere enviar una imagen de preview.
- Los archivos se almacenan en OCI con el formato: `media_{tipo}_{id}.{ext}`

### Response Body (201 Created)
```
(empty - solo código de estado)
```

---

## GET /api/media

- **Descripción:** Obtiene elementos de media con paginación y filtros
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Media obtenida exitosamente
- `400` - Filtros inválidos

### Query Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `page` | Integer | Número de página (requerido) |
| `type` | String | Filtro opcional (SONG, ANECDOTE, LEGEND) |
| `seasonMonth` | Integer | Filtro opcional (1-12) |
| `difficult` | String | Filtro opcional (EASY, MEDIUM, HARD) |

### Response Body (200 OK)
```json
{
  "media": [
    {
      "id": 1,
      "title": "Canción de los Colores",
      "description": "Una canción divertida para aprender colores",
      "mediaType": "SONG",
      "difficulty": "EASY",
      "seasonMonth": 5,
      "previewImageUrl": "https://oci.example.com/.../preview.jpg"
    }
  ],
  "currentPage": 0,
  "totalPages": 5,
  "totalElements": 50
}
```

---

## GET /api/media/{id}/stream

- **Descripción:** Obtiene recursos de streaming para un media
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Recursos obtenidos exitosamente
- `404` - Media no encontrada

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `id` | Long | ID del media |

### Response Body (200 OK)
```json
{
  "videoUrl": "https://oci.example.com/.../video.mp4",
  "subtitles": [
    {
      "language": "es",
      "url": "https://oci.example.com/.../subtitles_es.vtt"
    }
  ]
}
```

---

## DELETE /api/media/{id}

- **Descripción:** Elimina un media y sus archivos asociados de OCI
- **Nivel de acceso:** ADMIN

**Códigos de respuesta:**
- `204` - Media eliminado exitosamente
- `403` - No tiene permisos
- `404` - Media no encontrado
- `500` - Error eliminando archivos de OCI

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `id` | Long | ID del media |

### Response Body (204 No Content)
```
(empty)
```

---

## GET /api/media/recommendations

- **Descripción:** Obtiene recomendaciones de media basadas en nivel y temporada
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Recomendaciones obtenidas exitosamente
- `404` - Usuario no encontrado

### Response Body (200 OK)
```json
{
  "recommendations": [
    {
      "id": 1,
      "title": "Canción de los Colores",
      "mediaType": "SONG",
      "difficulty": "EASY"
    },
    {
      "id": 2,
      "title": "Leyenda del Sol",
      "mediaType": "LEGEND",
      "difficulty": "MEDIUM"
    }
  ]
}
```

---

# Pronunciation Controller

**Base URL:** `/api/pronunciation`

Valida la pronunciación en Mazahua de un audio grabado por el usuario. La validación se hace localmente en el servidor con un modelo ONNX (`validador_int8.onnx`): se extrae un *embedding* del audio y se compara por **distancia coseno** contra los centroides precalculados de cada palabra (`centroides_y_config.json`).

### Endpoints

---

## POST /api/pronunciation/validate/{wordId}

- **Descripción:** Recibe un archivo de audio y el ID de la palabra que el usuario intentó pronunciar, y devuelve si la pronunciación fue correcta junto con una puntuación y las distancias calculadas.
- **Nivel de acceso:** Autenticado
- **Content-Type:** `multipart/form-data`

**Códigos de respuesta:**
- `200` - Validación realizada exitosamente (incluye los casos `INCORRECT` y `SILENCE`: son resultados válidos, no errores)
- `400` - El archivo de audio no se pudo procesar o está mal formado
- `401` - No autenticado (token ausente, inválido o expirado)
- `404` - No existe una palabra con el `wordId` indicado
- `500` - Error interno del servidor o fallo en la inferencia del modelo

### Path Parameters

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `wordId` | Long | ID de la palabra que se espera que el usuario pronuncie |

### Request (multipart/form-data)

| Campo | Tipo | Requerido | Descripción |
|-------|------|-----------|-------------|
| `audio` | MultipartFile | Sí | Grabación del usuario. Se convierte internamente a PCM mono de 16 kHz con FFmpeg, por lo que se acepta cualquier formato que FFmpeg pueda leer (`m4a`, `mp3`, `wav`, `ogg`, `webm`, ...) |

```http
POST /api/pronunciation/validate/12
Authorization: Bearer <token>
Content-Type: multipart/form-data

audio: <archivo de audio>
```

### Response Body (200 OK)
```json
{
  "status": "CORRECT",
  "score": 87.4,
  "targetWord": "agua",
  "detectedWord": "agua",
  "targetDistance": 0.1832,
  "minDistance": 0.1832,
  "threshold": 0.3500
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `status` | PronunciationStatus | Resultado de la validación: `CORRECT`, `INCORRECT`, `INCORRECT_DIFFERENT_WORD` o `SILENCE` |
| `score` | double | Puntuación de 0 a 100, redondeada a 1 decimal. `>= 50` cuando la pronunciación es correcta; `<= 49.9` en cualquier otro caso; `0` si hubo silencio |
| `targetWord` | String | Texto en español de la palabra que se pidió pronunciar |
| `detectedWord` | String | Palabra del catálogo más parecida al audio. Igual a `targetWord` si fue correcta; `null` si hubo silencio |
| `targetDistance` | double | Distancia coseno entre el audio y el centroide de la palabra objetivo (4 decimales). `2.0` si no hay centroide para esa palabra o si hubo silencio |
| `minDistance` | double | Menor distancia coseno encontrada contra cualquier centroide del catálogo (4 decimales) |
| `threshold` | double | Umbral global de decisión del modelo. Se considera correcta la pronunciación si `targetDistance <= threshold` |

### Ejemplo: palabra distinta reconocida
```json
{
  "status": "INCORRECT_DIFFERENT_WORD",
  "score": 21.3,
  "targetWord": "agua",
  "detectedWord": "casa",
  "targetDistance": 0.5734,
  "minDistance": 0.2101,
  "threshold": 0.3500
}
```

### Ejemplo: silencio
```json
{
  "status": "SILENCE",
  "score": 0.0,
  "targetWord": "agua",
  "detectedWord": null,
  "targetDistance": 2.0,
  "minDistance": 2.0,
  "threshold": 0.3500
}
```

**Notas:**
- Un audio de menos de 0.1 s (1600 muestras a 16 kHz) o con RMS por debajo de `0.005` se clasifica como `SILENCE` sin ejecutar el modelo.
- No todas las palabras del diccionario tienen centroide en el modelo. Si la palabra objetivo no está cubierta, `targetDistance` vale `2.0` y el resultado será `INCORRECT` o `INCORRECT_DIFFERENT_WORD`; conviene no ofrecer el ejercicio de pronunciación para esas palabras.
- Menores distancias significan mayor parecido: `0` es idéntico y `2` es lo más distinto posible.
- El endpoint no guarda el audio ni modifica la palabra; no afecta a `GET /api/catalog/updates`.

---

# Visitor Dashboard Controller

**Base URL:** `/api/dashboard/visitor`

### Endpoints

---

## GET /api/dashboard/visitor

- **Descripción:** Obtiene el dashboard completo del visitante autenticado
- **Nivel de acceso:** VISITOR, ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Datos obtenidos exitosamente

### Response Body (200 OK)
```json
{
  "level": 2,
  "totalExperience": 75,
  "inrow": 3,
  "recentActivities": [
    {
      "activityId": 15,
      "gameTitle": "Vocales en Mazahua",
      "gameType": "QUESTIONNAIRE",
      "gameTopic": "VOWELS",
      "correctAnswers": 8,
      "totalQuestions": 10,
      "experienceEarned": 25,
      "passed": true,
      "completedAt": "2026-05-02T10:30:00"
    },
    {
      "activityId": 14,
      "gameTitle": "Emparejar Colores",
      "gameType": "PAIR",
      "gameTopic": "COLORS",
      "correctAnswers": 6,
      "totalQuestions": 8,
      "experienceEarned": 20,
      "passed": true,
      "completedAt": "2026-05-01T15:45:00"
    },
    {
      "activityId": 13,
      "gameTitle": "Números del 1 al 5",
      "gameType": "QUESTIONNAIRE",
      "gameTopic": "NUMBERS",
      "correctAnswers": 3,
      "totalQuestions": 5,
      "experienceEarned": 15,
      "passed": false,
      "completedAt": "2026-04-30T09:20:00"
    }
  ],
  "topUsers": [
    {
      "username": "visitor_carlos",
      "firstName": "Carlos",
      "lastName": "Martínez",
      "userType": "VISITOR",
      "avatarId": 12,
      "level": 4,
      "experience": 280,
      "finishedActivities": 22,
      "rank": 1
    },
    {
      "username": "visitor_ana",
      "firstName": "Ana",
      "lastName": "López",
      "userType": "VISITOR",
      "avatarId": 3,
      "level": 3,
      "experience": 250,
      "finishedActivities": 17,
      "rank": 2
    }
  ],
  "totalActivitiesCompleted": 12
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `level` | Integer | Nivel actual del visitante |
| `totalExperience` | Integer | Experiencia total acumulada |
| `inrow` | Integer | Días seguidos de conexión |
| `recentActivities` | List | Últimas 5 actividades completadas |
| `topUsers` | List | Top 5 visitantes (mismo tipo de usuario, incluye al actual si está en el top) |
| `totalActivitiesCompleted` | Integer | Total de actividades terminadas |

---

## GET /api/dashboard/visitor/{username}/level

- **Descripción:** Obtiene el nivel de un visitante
- **Nivel de acceso:** VISITOR (propio), ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Nivel obtenido exitosamente

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del visitante |

### Response Body (200 OK)
```json
2
```

---

## GET /api/dashboard/visitor/{username}/experience

- **Descripción:** Obtiene la experiencia de un visitante
- **Nivel de acceso:** VISITOR (propio), ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Experiencia obtenida exitosamente

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del visitante |

### Response Body (200 OK)
```json
75
```

---

## GET /api/dashboard/visitor/{username}/inrow

- **Descripción:** Obtiene los días seguidos que el visitante ha entrado
- **Nivel de acceso:** VISITOR (propio), ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Inrow obtenido exitosamente

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del visitante |

### Response Body (200 OK)
```json
3
```

---

## GET /api/dashboard/visitor/{username}/recent-activities

- **Descripción:** Obtiene las últimas 5 actividades completadas por el visitante con sus resultados
- **Nivel de acceso:** VISITOR (propio), ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Actividades recientes obtenidas exitosamente

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del visitante |

### Response Body (200 OK)
```json
[
  {
    "activityId": 15,
    "gameTitle": "Vocales en Mazahua",
    "gameType": "QUESTIONNAIRE",
    "gameTopic": "VOWELS",
    "correctAnswers": 8,
    "totalQuestions": 10,
    "experienceEarned": 25,
    "passed": true,
    "completedAt": "2026-05-02T10:30:00"
  },
  {
    "activityId": 14,
    "gameTitle": "Emparejar Colores",
    "gameType": "PAIR",
    "gameTopic": "COLORS",
    "correctAnswers": 6,
    "totalQuestions": 8,
    "experienceEarned": 20,
    "passed": true,
    "completedAt": "2026-05-01T15:45:00"
  },
  {
    "activityId": 13,
    "gameTitle": "Números del 1 al 5",
    "gameType": "QUESTIONNAIRE",
    "gameTopic": "NUMBERS",
    "correctAnswers": 3,
    "totalQuestions": 5,
    "experienceEarned": 15,
    "passed": false,
    "completedAt": "2026-04-30T09:20:00"
  },
  {
    "activityId": 12,
    "gameTitle": "Aprende los Animales",
    "gameType": "MEDIA",
    "gameTopic": "ANIMALS",
    "correctAnswers": 10,
    "totalQuestions": 10,
    "experienceEarned": 30,
    "passed": true,
    "completedAt": "2026-04-29T14:00:00"
  },
  {
    "activityId": 11,
    "gameTitle": "Colores Básicos",
    "gameType": "QUESTIONNAIRE",
    "gameTopic": "COLORS",
    "correctAnswers": 0,
    "totalQuestions": 10,
    "experienceEarned": 0,
    "passed": false,
    "completedAt": "2026-04-28T11:30:00"
  }
]
```

### RecentActivityDto

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `activityId` | Long | ID de la actividad |
| `gameTitle` | String | Título del juego |
| `gameType` | String | Tipo de juego (QUESTIONNAIRE, PAIR, MEDIA) |
| `gameTopic` | String | Tema del juego |
| `correctAnswers` | Integer | Respuestas correctas |
| `totalQuestions` | Integer | Total de preguntas |
| `experienceEarned` | Integer | Experiencia ganada |
| `passed` | Boolean | Si pasó (>= 60% de correctas) |
| `completedAt` | LocalDateTime | Fecha de finalización |

---

## GET /api/dashboard/visitor/{username}/top-users

- **Descripción:** Obtiene los usuarios con mayor nivel y experiencia (excluyendo al usuario actual)
- **Nivel de acceso:** VISITOR (propio), ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Top de usuarios obtenido exitosamente

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del visitante |

### Response Body (200 OK)
```json
[
  {
    "username": "est_001",
    "firstName": "Ana",
    "lastName": "López",
    "userType": "STUDENT",
    "level": 5,
    "experience": 350,
    "rank": 1
  },
  {
    "username": "visitor_carlos",
    "firstName": "Carlos",
    "lastName": "Martínez",
    "userType": "VISITOR",
    "level": 4,
    "experience": 280,
    "rank": 2
  },
  {
    "username": "est_015",
    "firstName": "Pedro",
    "lastName": "Gómez",
    "userType": "STUDENT",
    "level": 4,
    "experience": 250,
    "rank": 3
  },
  {
    "username": "est_008",
    "firstName": "María",
    "lastName": "Rodríguez",
    "userType": "STUDENT",
    "level": 3,
    "experience": 180,
    "rank": 4
  },
  {
    "username": "visitor_lucia",
    "firstName": "Lucía",
    "lastName": "Fernández",
    "userType": "VISITOR",
    "level": 3,
    "experience": 150,
    "rank": 5
  }
]
```

### TopUserDto

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `username` | String | Username del usuario |
| `firstName` | String | Nombre del usuario |
| `lastName` | String | Apellido del usuario |
| `userType` | UserType | Tipo de usuario (STUDENT, VISITOR) |
| `level` | Integer | Nivel del usuario |
| `experience` | Integer | Experiencia total |
| `rank` | Integer | Posición en el ranking |

---

## GET /api/dashboard/visitor/{username}/finished

- **Descripción:** Obtiene el conteo total de actividades terminadas del visitante
- **Nivel de acceso:** VISITOR (propio), ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Conteo obtenido exitosamente

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del visitante |

### Response Body (200 OK)
```json
12
```

---

## GET /api/dashboard/visitor/{username}

- **Descripción:** Obtiene el dashboard completo de un visitante específico
- **Nivel de acceso:** ADMIN, TEACHER

**Códigos de respuesta:**
- `200` - Dashboard obtenido exitosamente

### Path Parameters
| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `username` | String | Username del visitante |

### Response Body (200 OK)
```json
{
  "level": 2,
  "totalExperience": 75,
  "inrow": 3,
  "recentActivities": [
    {
      "activityId": 15,
      "gameTitle": "Vocales en Mazahua",
      "gameType": "QUESTIONNAIRE",
      "gameTopic": "VOWELS",
      "correctAnswers": 8,
      "totalQuestions": 10,
      "experienceEarned": 25,
      "passed": true,
      "completedAt": "2026-05-02T10:30:00"
    }
  ],
  "topUsers": [
    {
      "username": "est_001",
      "firstName": "Ana",
      "lastName": "López",
      "userType": "STUDENT",
      "level": 5,
      "experience": 350,
      "rank": 1
    }
  ],
  "totalActivitiesCompleted": 12
}
```

---

## VisitorDashboardDto

```java
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class VisitorDashboardDto {
    private Integer level;
    private Integer experience;
    private Integer inrow;
    private List<RecentActivityDto> recentActivities;
    private List<TopUserDto> topUsers;
    private Integer totalActivitiesCompleted;
}
```

---

## RecentActivityDto

```java
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class RecentActivityDto {
    private Long activityId;
    private String gameTitle;
    private String gameType;
    private String gameTopic;
    private Integer correctAnswers;
    private Integer totalQuestions;
    private Integer experienceEarned;
    private Boolean passed;
    private LocalDateTime completedAt;
}
```

---

## TopUserDto

```java
@Data
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class TopUserDto {
    private String username;
    private String firstName;
    private String lastName;
    private UserType userType;
    private Integer level;
    private Integer experience;
    private Integer rank;
}
```

---

## Arreglo: Top de Estudiantes

### Problema Anterior
El endpoint `GET /api/dashboard/student/{username}/classmates` excluía al usuario actual del ranking de compañeros, por lo que si el estudiante estaba entre los mejores de su grupo, no aparecía en la lista.

### Solución Implementada
Se agregaron dos nuevos métodos en StudentRepository:

1. `findClassmatesExcludingUser` - Obtiene compañeros excluyendo al usuario actual
2. `findClassmateByUsername` - Obtiene los datos del usuario actual

El servicio ahora:
1. Obtiene la lista de compañeros (excluyendo al actual)
2. Si la lista tiene menos de 10 elementos, agrega al usuario actual para completar el top

### Cambios en archivos:
- **StudentRepository.java** - Nuevos métodos de consulta
- **StudentDashboardService.java** - Lógica para incluir al usuario actual en el ranking

### Response Body (Ejemplo Actualizado)
```json
[
  {
    "fullName": "Carlos Martínez",
    "level": 4,
    "experience": 250
  },
  {
    "fullName": "Ana López",
    "level": 3,
    "experience": 180
  },
  {
    "fullName": "Pedro Gómez",
    "level": 3,
    "experience": 150
  },
  {
    "fullName": "María Rodríguez",
    "level": 2,
    "experience": 100
  },
  {
    "fullName": "Juan Pérez",
    "level": 2,
    "experience": 80
  }
]
```

---

# Catalog Controller

**Base URL:** `/api/catalog`

Sincronización incremental de los catálogos de juegos y palabras. Reemplaza a los antiguos
`GET /api/games/updatedGames` y `GET /api/dictionary/updatedWords`, que solo devolvían la fecha del
último cambio y obligaban a volver a descargar el catálogo completo.

### Endpoints

---

## GET /api/catalog/updates

- **Descripción:** Devuelve los **ids** de todos los juegos y palabras que cambiaron después de la fecha enviada en `since`, junto con el tipo de cambio. No devuelve el contenido de los objetos: con esos ids el cliente descarga después, en otra llamada, solo lo que le falta.
- **Nivel de acceso:** Autenticado

**Códigos de respuesta:**
- `200` - Cambios obtenidos exitosamente
- `400` - El parámetro `since` no tiene formato ISO-8601
- `401` - No autenticado (token ausente, inválido o expirado)
- `500` - Error interno del servidor

### Request

Sin body. Un único parámetro de query.

| Parámetro | Tipo | Requerido | Descripción |
|-----------|------|-----------|-------------|
| `since` | ISO-8601 date-time | No | Fecha de corte, **exclusiva**: se devuelve todo lo que cambió estrictamente después de ella. Se acepta hora local (`2026-08-01T00:00:00`) y hora con offset (`2026-08-01T00:00:00Z`, `2026-08-01T00:00:00-06:00`), que se traslada a la zona del servidor. Si se omite, se devuelve el catálogo completo |

```http
GET /api/catalog/updates?since=2026-08-01T00:00:00
Authorization: Bearer <token>
```

Primera sincronización del cliente (sin caché previa), se omite `since` y llega todo el catálogo:

```http
GET /api/catalog/updates
Authorization: Bearer <token>
```

### Response Body (200 OK)
```json
{
  "since": "2026-08-01T00:00:00",
  "serverTime": "2026-08-19T10:15:30.482",
  "games": [
    {
      "gameId": 42,
      "changeType": "UPDATED",
      "updatedAt": "2026-08-09T14:23:11.482"
    },
    {
      "gameId": 51,
      "changeType": "DELETED",
      "updatedAt": "2026-08-14T18:02:45.117"
    }
  ],
  "words": [
    {
      "wordId": 87,
      "changeType": "CREATED",
      "updatedAt": "2026-08-12T09:00:00.000"
    }
  ]
}
```

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `since` | LocalDateTime | La fecha que se envió en la petición. `null` si no se envió ninguna |
| `serverTime` | LocalDateTime | Hora del servidor al atender la petición. **Es el valor que el cliente debe guardar y reenviar como `since` la próxima vez** |
| `games` | Array | Juegos modificados, del cambio más antiguo al más reciente. Array vacío si no hubo ninguno |
| `words` | Array | Palabras modificadas, del cambio más antiguo al más reciente. Array vacío si no hubo ninguna |

**Objeto de `games`:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `gameId` | Long | ID del juego, para descargarlo después con `GET /api/games/{gameId}/preview` |
| `changeType` | CatalogChangeType | `CREATED`, `UPDATED` o `DELETED` |
| `updatedAt` | LocalDateTime | Momento exacto del cambio |

**Objeto de `words`:**

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `wordId` | Long | ID de la palabra, para descargarla después desde el diccionario |
| `changeType` | CatalogChangeType | `CREATED`, `UPDATED` o `DELETED` |
| `updatedAt` | LocalDateTime | Momento exacto del cambio |

### Respuesta cuando no hubo cambios (200 OK)
```json
{
  "since": "2026-08-19T10:00:00",
  "serverTime": "2026-08-19T10:15:30.482",
  "games": [],
  "words": []
}
```

**Flujo de uso recomendado:**

1. La primera vez, llamar sin `since`: llega el catálogo completo en forma de ids.
2. Descargar el detalle de cada `gameId` / `wordId` recibido.
3. Guardar el `serverTime` de la respuesta.
4. En la siguiente sincronización, llamar con `since = <serverTime guardado>`.
5. Por cada elemento recibido:
   - `CREATED` o `UPDATED` → descargar (o volver a descargar) ese id y guardarlo en la caché local.
   - `DELETED` → borrar ese id de la caché local. **No intentar descargarlo**: ya no existe en el servidor y devolvería 404.
6. Volver a guardar el nuevo `serverTime` y repetir.

**Notas:**
- Se devuelve un solo cambio por objeto: el más reciente. Si un juego se creó y luego se editó tres veces desde `since`, aparece una sola vez con `UPDATED`.
- Si un objeto se creó y se eliminó entre dos sincronizaciones, el cliente lo verá directamente como `DELETED` y simplemente no lo descargará.
- Los cambios se registran dentro de la misma transacción que la operación que los provoca: si la petición que crea o edita falla, el cambio no aparece aquí.
- Operaciones que registran un cambio de juego: `POST /api/games`, `PUT /api/games/{id}` (incluye preguntas, respuestas, palabras asociadas y `gameConfig`) y `DELETE /api/games/{id}`.
- Operaciones que registran un cambio de palabra: `POST /api/dictionary/word`, `POST /api/dictionary/word/media`, `PUT /api/dictionary/word/{id}`, `PUT /api/dictionary/word/{id}/media` y `DELETE /api/dictionary/words/{id}`.
- `since` se compara contra la hora del servidor. Por eso conviene reenviar el `serverTime` recibido en lugar de la hora del dispositivo: evita perder cambios por desfase de reloj.
- La respuesta no está paginada. Solo lleva ids, así que incluso el catálogo completo es una respuesta pequeña.

---

*Documentación generada automáticamente del proyecto NtsiFiyo*