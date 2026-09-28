# QA-Backend-test - Suite de pruebas API Usuarios (ServeRest)

Suite de pruebas automatizadas para la **API de Usuarios de ServeRest**
(https://serverest.dev/) implementada con **Karate DSL**.

Cubre el CRUD completo del recurso `/usuarios` con casos **positivos y negativos**,
**validación de esquemas JSON**, **generación dinámica de datos** y un **flujo E2E** encadenado.

---

## Requisitos previos

| Herramienta | Versión mínima |
|-------------|----------------|
| JDK         | 17             |
| Maven       | 3.8+           |
| Conexión a internet | La API es pública (`https://serverest.dev`) |

Verifica tu entorno:

```bash
java -version
mvn -version
```

---

## Estructura del proyecto

```
QA-Backend-test/
├── pom.xml                                  # Maven + Karate 1.4.1 + JUnit5 + DataFaker
├── README.md                                # Este archivo
├── ESTRATEGIA.md                            # Informe de estrategia y patrones
└── src/test/java/
    ├── karate-config.js                     # Config global (baseUrl, timeouts, helpers)
    ├── logback-test.xml                      # Configuración de logging
    ├── features/usuarios/
    │   ├── usuarios-get.feature             # GET lista + GET por ID (+/-)
    │   ├── usuarios-post.feature            # POST registrar usuario (+/-)
    │   ├── usuarios-put.feature             # PUT actualizar usuario (+/-)
    │   ├── usuarios-delete.feature          # DELETE eliminar usuario (+/-)
    │   ├── usuarios-e2e.feature             # Flujo CRUD end-to-end
    │   ├── UsuariosRunner.java              # Runner JUnit5 - suite completa
    │   └── SmokeRunner.java                 # Runner JUnit5 - solo @smoke
    ├── schemas/
    │   └── usuario-schema.js                # Esquemas JSON reutilizables
    └── helpers/
        └── DataGenerator.java               # Generación de datos de prueba (Faker)
```

---

## Ejecución de los tests

### Ejecutar toda la suite

```bash
mvn test
```

> `mvn test` ejecuta la suite completa (19 escenarios) a través de `UsuariosRunner`.
> Es equivalente a `mvn test -Dtest=UsuariosRunner`.

### Ejecutar solo smoke tests

```bash
mvn test -Dtest=SmokeRunner
```

> Los smoke (tag `@smoke`) viven en un runner separado (`SmokeRunner`) para que
> `mvn test` no los ejecute por duplicado. Solo corren cuando se piden explícitamente.

### Filtrar por tags (Karate options)

Encierra **todo** el argumento `-D` entre comillas. Esta forma funciona en
**bash, CMD y PowerShell** (evita que la coma o el `@` rompan el comando en Windows):

```bash
# Solo casos positivos
mvn test "-Dkarate.options=--tags @positivo"

# Solo casos negativos
mvn test "-Dkarate.options=--tags @negativo"

# Un endpoint o combinación (coma = OR: POST o PUT)
mvn test "-Dkarate.options=--tags @post,@put"

# Solo el flujo end-to-end
mvn test "-Dkarate.options=--tags @e2e"
```

> **Nota (Windows):** la forma `mvn test -Dkarate.options="--tags @post,@put"`
> (con las comillas solo alrededor del valor) suele fallar en PowerShell/CMD
> porque la coma se interpreta como separador y Maven recibe `@put` como una
> fase inválida (`Unknown lifecycle phase '@put'`). Usa la sintaxis de arriba,
> con las comillas envolviendo todo el `-D...`.
>
> La coma entre tags significa **OR** (`@post,@put` = post **o** put).
> Para **AND** usa `--tags @post --tags @smoke`.

### Seleccionar ambiente

```bash
mvn test -Dkarate.env=qa
```

---

## Tags disponibles

| Tag         | Descripción                                  |
|-------------|----------------------------------------------|
| `@usuarios` | Todos los tests del recurso usuarios         |
| `@get` `@post` `@put` `@delete` | Por operación HTTP       |
| `@positivo` | Casos de éxito (happy path)                  |
| `@negativo` | Casos de error / validaciones                |
| `@smoke`    | Subconjunto crítico para validación rápida   |
| `@e2e`      | Flujo CRUD encadenado                        |

---

## Reportes

Tras cada ejecución, Karate genera un reporte HTML en:

```
target/karate-reports/karate-summary.html
```

Ábrelo en el navegador para ver el detalle de cada escenario, request/response y tiempos.

---

## Cobertura de casos

### GET /usuarios y /usuarios/{_id}
- Listar todos los usuarios (schema + `#array`)
- `quantidade` coincide con el tamaño del arreglo
- Buscar usuario por ID existente
- Buscar usuario por ID inexistente (400 · `Usuário não encontrado`)

### POST /usuarios
- Registrar usuario válido (201 · `Cadastro realizado com sucesso`)
- Registrar administrador y verificar persistencia
- Email duplicado (400 · `Este email já está sendo usado`)
- Campos obligatorios ausentes — data-driven (`nome`, `email`, `password`, `administrador`)
- Formato de email inválido

### PUT /usuarios/{_id}
- Actualizar usuario existente y verificar persistencia
- Upsert: PUT con ID inexistente crea usuario (201)
- Actualizar con email ya usado por otro usuario
- Actualizar con campo obligatorio ausente

### DELETE /usuarios/{_id}
- Eliminar usuario existente + verificar 404 posterior
- Eliminar ID inexistente (200 · `Nenhum registro excluído`)

### E2E
- Ciclo completo: crear → buscar → listar → actualizar → verificar → eliminar → confirmar eliminación

---

## Detalles técnicos

- **Generación de datos:** `helpers.DataGenerator` (Java DataFaker) crea usuarios con
  email único por timestamp para evitar colisiones en una API pública compartida.
- **Validación de esquemas:** `schemas/usuario-schema.js` centraliza los marcadores
  de Karate (`#string`, `#number`, `#regex`) reutilizables entre features.
- **Limpieza (teardown):** cada escenario elimina los datos que crea para no dejar residuos.

Consulta [`ESTRATEGIA.md`](./ESTRATEGIA.md) para el detalle de la estrategia y los patrones aplicados.
