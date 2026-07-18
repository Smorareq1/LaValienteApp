# Reglas de Arquitectura y Desarrollo para Flutter Apps

Este documento define el estándar arquitectónico, las responsabilidades por capa y las reglas de diseño que deben seguirse durante el desarrollo de aplicaciones Flutter.

## 1. Stack Tecnológico Base

Las herramientas y dependencias principales están predefinidas y no deben alterarse sin justificación técnica:

* **Framework y UI:** Flutter (SDK ^3.9.2) con navegación declarativa usando GoRouter.
* **Gestión de Estado:** Riverpod (usando anotaciones reactivas con `riverpod_generator`).
* **Persistencia Local:** Drift (ORM sobre SQLite) y `flutter_secure_storage` para datos sensibles.
* **Red y API:** Dio como cliente HTTP configurado con interceptores dinámicos.
* **Operaciones Funcionales:** Uso del paquete `fpdart` para el manejo robusto de errores mediante `Either<Failure, T>`.

## 2. Topología del Código Base

El proyecto mantiene una separación estricta organizada por funcionalidades (Feature-First):

* **`lib/core/`**: Contiene la infraestructura técnica compartida (base de datos, red, enrutador, almacenamiento, utilidades).
* **`lib/features/`**: Cada módulo de negocio es un microcosmos autónomo.
    * Las reglas de dependencia dentro de un *feature* son estrictas: siempre apuntan hacia adentro (UI → State → Data → Entities).
* **`packages/design_system/`**: Paquete de UI 100% independiente estructurado en Tokens (base), Átomos y Moléculas para garantizar la reutilización.

## 3. Flujo Arquitectónico Unidireccional

El flujo del sistema es estrictamente unidireccional: las peticiones fluyen hacia abajo y el estado fluye hacia arriba.

* **Regla de Oro:** Una capa jamás salta a otra capa no adyacente.
* **Restricción Crítica:** La UI nunca debe tocar ni importar directamente un `Datasource` o un `Repository`.

## 4. Responsabilidades y Contratos por Capa

### Capa UI (Vistas / Widgets)

* **Responsabilidad:** Es un observador pasivo. Su único trabajo es observar el estado y disparar acciones puntuales.
* **Reglas:**
    * Debe consumir el estado mediante `ref.watch` y ejecutar acciones mediante `ref.read`.
    * Puede interactuar con el usuario y con el Provider, pero no maneja lógica de negocio ni I/O.

### Capa Provider (`@riverpod`)

* **Responsabilidad:** Funciona como el traductor de estado. Mantiene el estado de la UI y traduce respuestas crudas en estados consumibles (ej. `AsyncLoading`, `AsyncData`).
* **Reglas:**
    * Maneja exclusivamente el estado visual.
    * Cero I/O: no debe saber nada sobre la implementación de redes o bases de datos.

### Capa Repository

* **Responsabilidad:** Es el orquestador de datos. Coordina el flujo entre múltiples fuentes de datos (local y remoto).
* **Reglas:**
    * Transforma las excepciones crudas en objetos tipados `AppFailure`.
    * Restricción absoluta: no emite estados de pantalla ni tiene conocimiento de widgets.

### Capa DataSources (Local & Remote)

* **Responsabilidad:** Entrada y salida pura (I/O).
* **Reglas:**
    * No deben contener contexto ni lógica de negocio, exclusivamente operaciones de lectura y escritura.
    * **RemoteDataSource:** Usa Dio, conoce URLs, headers y transforma JSON a modelos.
    * **LocalDataSource:** Usa Drift, conoce DAOs y mapea modelos a Companions de Drift.

## 5. La Capa de Servicios y la "Regla de los 3 Puntos"

La arquitectura es pragmática; no se crean capas por convención ciega. Una capa intermedia de `Service` entre el `Provider` y el `Repository` solo debe existir si cumple las siguientes tres condiciones:

1. **Reusabilidad:** La lógica de negocio es requerida por más de un `Repository` o se usa en múltiples flujos distintos.
2. **Complejidad:** Contiene ramas condicionales pesadas y no triviales (ej. cálculos compuestos o validaciones con múltiples reglas).
3. **Testabilidad:** Contiene lógica de negocio independiente del I/O que exige pruebas unitarias aisladas.

Módulos simples pueden omitir esta capa. Los módulos con lógica de negocio compleja y reutilizable deben usarla.

## 6. Taxonomía de Excepciones y Errores

Todo fallo debe ser tipado y capturado bajo el modelo de `AppFailure` usando la librería `fpdart` (`Either<Failure, T>`). Las clasificaciones son:

* **NetworkFailure:** Timeout o pérdida de conexión de red.
* **ServerFailure:** Un error explícito devuelto por el backend.
* **AuthFailure:** Problemas de sesión, credenciales inválidas o acceso denegado.
* **CacheFailure:** Fallo al leer o escribir en la base de datos local (SQLite).
* **ValidationFailure:** Datos capturados a nivel local que no son válidos.
* **UnexpectedFailure:** Excepciones genéricas o no controladas.

## 7. Developer Experience (DX)

Para la ejecución y generación de código, se debe utilizar el siguiente flujo estandarizado:

1. `flutter pub get` — instalar dependencias.
2. `dart run build_runner build --delete-conflicting-outputs` — generar código de Riverpod, Drift y serialización.
3. `flutter run` — compilar y lanzar.

## 8. Estructura Estricta de las Entidades (Entities)

Dentro del patrón estructural por módulo, la capa más profunda son las **Entidades** (`models/`).

* **Reglas:**
    * Representan estructuras de datos puras.
    * Son la capa más profunda y no deben tener dependencias de Flutter, UI u otros paquetes pesados.
    * Solo las capas superiores (Repository, Provider) pueden depender de ellas, nunca al revés.

## 9. Reglas del Design System (UI Escalable)

Para garantizar la reutilización cruzada y mantener la UI independiente, se debe usar un paquete interno `design_system` bajo el modelo de Diseño Atómico:

* **Tokens (Base):** Variables de diseño fundamentales (tipografía, colores, dimensiones, iconografía).
* **Átomos:** Componentes indivisibles del sistema (ej. botones, inputs, badges).
* **Moléculas:** Composiciones que unen varios átomos (ej. formularios, tarjetas compuestas).
* **Restricción:** El `AppTheme` de la aplicación principal debe consumir estrictamente los tokens provistos por este paquete independiente.

## 10. Reglas de Enrutamiento y Seguridad (Auth Guard)

El manejo de acceso a las pantallas no se hace con validaciones sueltas en la UI, sino a nivel del enrutador.

* **GoRouter Auth Guard:** Se utiliza un guard reactivo conectado al estado de autenticación.
* **Flujo:** Si el usuario no está autenticado, cualquier intento de acceso a rutas protegidas redirige a la ruta pública de login. Si está autenticado e intenta acceder a rutas públicas de login, redirige a la pantalla principal.
* **Protección de Datos:** La persistencia de tokens de sesión y credenciales sensibles debe manejarse exclusivamente a través de un servicio de almacenamiento seguro (`SecureStorageService`).

## 11. Patrones de Flujo para Procesos Largos

Para operaciones que tardan (sincronización, importación, procesamiento por lotes):

* El **Repository** emite progreso mediante un `Stream` (ej. `yield step(...)`).
* El **Provider** traduce esos eventos en estados consumibles por la UI (ej. `InProgress(currentStep, progress)`).
* La **UI** observa esos estados para mostrar feedback (barra de progreso, paso actual) sin bloquearse.

Para operaciones con variantes (completa vs incremental), el Repository expone el modo como parámetro y la UI delega la elección al usuario o al contexto de la app.
