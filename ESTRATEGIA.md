# Estrategia de Automatización

**Proyecto:** Suite de pruebas API de Usuarios - ServeRest
**Framework:** Karate DSL 1.4.1 · JUnit5 · Maven · Java 17

---

## 1. Objetivo y alcance

Automatizar la verificación funcional del recurso `/usuarios` de la API de ServeRest,
cubriendo las cinco operaciones CRUD exigidas por la historia de usuario del reto:

| Operación | Endpoint |
|-----------|----------|
| Listar    | `GET /usuarios` |
| Registrar | `POST /usuarios` |
| Buscar    | `GET /usuarios/{_id}` |
| Actualizar| `PUT /usuarios/{_id}` |
| Eliminar  | `DELETE /usuarios/{_id}` |

El alcance incluye casos **positivos**, **negativos**, **validación de esquemas JSON**
y un **flujo end-to-end** que representa el ciclo de vida completo de un usuario.

---

## 2. Estrategia de pruebas

### 2.1 Pirámide y tipo de pruebas
El foco es la **capa de API (servicio)**: pruebas de integración de caja negra contra
el contrato REST. No se prueban detalles de UI ni de base de datos directamente.

### 2.2 Diseño de casos
Se aplicaron técnicas de diseño de pruebas:
- **Partición de equivalencia:** datos válidos vs. inválidos.
- **Análisis de valores límite / formato:** ID de 16 caracteres alfanuméricos, formato de email.
- **Cobertura de errores de negocio:** email duplicado, campos obligatorios ausentes.
- **Data-driven testing:** un `Scenario Outline` valida los cuatro campos obligatorios
  del POST con una sola definición, mejorando la mantenibilidad.

### 2.3 Casos positivos y negativos
Cada endpoint tiene al menos un caso feliz y uno de error, verificando tanto el
**status code** como el **cuerpo de la respuesta** (mensajes de negocio de ServeRest en portugués).

---

## 3. Organización del proyecto

```
src/test/java/
├── karate-config.js          → configuración global y por ambiente
├── features/usuarios/        → un feature por endpoint + E2E + runner
├── schemas/                  → esquemas JSON reutilizables
└── helpers/                  → utilidades de generación de datos
```

Un **feature por endpoint** mantiene la suite legible y facilita la ejecución selectiva
por operación. El flujo E2E se aísla en su propio feature.

---

## 4. Patrones y buenas prácticas aplicadas

| Patrón | Aplicación |
|--------|------------|
| **Configuración centralizada** | `karate-config.js` define `baseUrl`, timeouts, headers y expone el helper de datos. Permite cambiar de ambiente con `-Dkarate.env`. |
| **Background reutilizable** | Cada feature comparte `url baseUrl` y la carga de esquemas; el feature de PUT crea el usuario base en el Background. |
| **Schema validation reutilizable** | `usuario-schema.js` centraliza los marcadores fuzzy de Karate (`#string`, `#number`, `#regex`), evitando duplicación entre features. |
| **Data-driven** | `Scenario Outline` + `Examples` para los campos obligatorios; `DataGenerator` para datos dinámicos. |
| **Generación de datos con Faker** | Emails únicos por timestamp evitan colisiones (400 por duplicado) en una API pública compartida por muchos usuarios. |
| **Teardown / limpieza** | Cada escenario elimina los usuarios que crea, dejando el sistema sin residuos. |
| **Tags para segmentación** | `@smoke`, `@positivo`, `@negativo`, por operación — habilitan estrategias de ejecución (CI rápido vs. regresión completa). |
| **Aserciones robustas** | Se valida status, contrato y mensajes de negocio, no solo el código HTTP. |

---

## 5. Gestión de datos de prueba

- **Independencia:** ningún test depende de datos preexistentes; cada uno crea lo que necesita.
- **Unicidad:** `DataGenerator.emailUnico()` combina timestamp + aleatorio para no colisionar.
- **Aislamiento:** los IDs inexistentes usan formato válido de 16 caracteres para probar
  la lógica de negocio (usuario no encontrado) y no la validación de formato.
- **Limpieza:** los datos creados se eliminan al final de cada escenario.

---

## 6. Consideraciones sobre la API bajo prueba

ServeRest es una API pública y compartida con particularidades detectadas y contempladas:
- El campo `administrador` se maneja como **string** (`"true"`/`"false"`).
- El `_id` debe tener **exactamente 16 caracteres alfanuméricos**.
- **PUT con ID inexistente hace upsert** (crea el registro, 201) — comportamiento verificado explícitamente.
- Las contraseñas se devuelven en texto plano en las respuestas (por diseño de ServeRest).
- Mensajes de negocio en **portugués**.

---

## 7. Ejecución en CI (recomendación)

La suite es apta para integración continua:

```bash
# Validación rápida en cada push
mvn test -Dtest=SmokeRunner

# Regresión completa en el pipeline principal
mvn test
```

El reporte HTML de Karate (`target/karate-reports/`) puede publicarse como artefacto del build.

---

## 8. Resultados

- **5** feature files · **19** escenarios · **100% en verde** contra el entorno real.
- Cobertura de las **5 operaciones CRUD** con casos positivos y negativos.
- Validación de esquema JSON en todas las respuestas relevantes.

