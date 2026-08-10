# La Valiente · App

App de gestión para la lavandería **La Valiente · Cobán**, construida con Flutter.

## Stack

- **UI:** Flutter + GoRouter (auth guard reactivo)
- **Estado:** Riverpod con codegen (`riverpod_generator`)
- **Red:** Dio con interceptor de autenticación (bearer + refresh automático en 401)
- **Persistencia:** Drift sobre **SQLite cifrado con SQLCipher** (llave por dispositivo en `flutter_secure_storage`, plan 0004 D12)
- **Errores:** `fpdart` con `Either<AppFailure, T>`
- **Design system:** paquete interno [`packages/design_system`](packages/design_system) bajo diseño atómico (tokens → átomos → moléculas)

La arquitectura completa está documentada en [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md).

## Estructura

```
lib/
  core/        # config, errores, red, router, storage, database, theme
  features/    # módulos de negocio (auth, home, ...) — feature-first
packages/
  design_system/  # tokens, átomos y moléculas — 100% independiente
```

## Datos: todo sale de la base local

La UI **nunca** espera a la red (plan 0004 D1). Lee y escribe SQLite, y el motor de
sincronización reconcilia por detrás:

- `features/catalog` y `features/customers` leen sus tablas espejo, que llena el feed.
- Las pantallas de Clientes (lista, detalle y formulario) operan enteras contra esas
  tablas: buscar, dar de alta, editar y archivar funcionan sin señal.
- Capturar un cliente escribe la fila y encola su operación en una sola transacción; la
  fila queda `pending` hasta que el servidor responde.
- Sumar una entidad al espejo es registrar un `SyncEntityMirror` en `syncMirrorsProvider`;
  lo que llegó antes de que existiera está en `deferred_changes` y entra solo.

## Permisos: se oculta, no se deshabilita

Las secciones que un rol no puede usar **no se dibujan** (plan 0006 §13): la barra
inferior, el hub "Más" y las cards de Inicio consultan `AuthUser.hasPermission`, y el
router repite el chequeo por si alguien entra por deep link. Los roles `admin` y
`system_admin` llevan el comodín `*.*` y ven todo; un `deny` por usuario le gana al
comodín, con la misma regla que aplica el backend.

## Desarrollo

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Backend

**El backend se elige al compilar, no al ejecutar.** No hay pantalla de ajustes
donde cambiar de servidor: un APK sabe contra qué API habla desde que se arma, y
eso es lo que hace imposible que un dispositivo del mostrador termine
escribiendo en la base de desarrollo.

Dos archivos, ninguno versionado (este repositorio es público). Copia las
plantillas la primera vez:

```bash
cp dev.json.example dev.json      # tu backend local
cp prod.json.example prod.json    # el de Railway; pega ahí la URL
```

| Entorno | Archivo | Comando |
| --- | --- | --- |
| Desarrollo | `dev.json` | `flutter run --dart-define-from-file=dev.json` |
| Producción | `prod.json` | `flutter run --dart-define-from-file=prod.json` |

O sin archivo, para una prueba suelta:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # emulador Android
```

### Compilar un APK

```bash
# Desarrollo — contra el backend local
flutter build apk --release --dart-define-from-file=dev.json

# Producción — contra Railway
flutter build apk --release --dart-define-from-file=prod.json
```

El APK queda en `build/app/outputs/flutter-apk/app-release.apk`. Como el nombre
es el mismo en los dos casos, conviene renombrarlo al sacarlo:

```bash
mv build/app/outputs/flutter-apk/app-release.apk lavaliente-prod.apk
```

> **Nunca compiles un release sin `--dart-define-from-file`.** Sin él,
> `API_BASE_URL` cae en su valor por omisión (`http://localhost:8000`), que en un
> teléfono es el teléfono mismo: el APK se instala, abre, y solo falla al primer
> login, ya en el mostrador. `Env.isMisconfiguredRelease` detecta ese caso y deja
> una advertencia en el log al arrancar, pero el aviso llega tarde — el hábito de
> pasar siempre el archivo es la verdadera protección.

Para confirmar contra qué backend quedó un APK ya armado:

```bash
adb logcat -s flutter:V | Select-String '\[LV\]'
```

> La app es **native-only**: el opener de la BD usa `dart:io`, `path_provider` y
> SQLCipher, así que no compila para web. No vuelvas a agregar `drift_flutter`:
> su `sqlite3_flutter_libs` declara la misma clase de plugin Android que
> `sqlcipher_flutter_libs` y rompe el dex merge.

## Pruebas

```bash
flutter test          # unitarias y de widget — no necesitan dispositivo
```

Las de `integration_test/` corren la app real sobre un dispositivo o emulador,
que es la única forma de comprobar lo que depende de la plataforma:

```bash
# 1. Emulador headless
"$LOCALAPPDATA/Android/Sdk/emulator/emulator" -avd Medium_Phone_API_35 -no-window -no-audio

# 2. Que la BD abra con SQLCipher y quede ilegible en disco
flutter test integration_test/encrypted_database_test.dart -d emulator-5554
```

El ciclo de sincronización necesita además el backend levantado y un usuario de
pruebas (ver `BACKEND/README.md`):

```bash
flutter test integration_test/sync_cycle_test.dart -d emulator-5554 \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000 \
  --dart-define=E2E_USER=e2e_tester --dart-define=E2E_PASSWORD=...
```

En el emulador de Android, `10.0.2.2` es el `localhost` de la máquina anfitriona.
