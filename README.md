# La Valiente · App

App de gestión para la lavandería **La Valiente · Cobán**, construida con Flutter.

## Stack

- **UI:** Flutter + GoRouter (auth guard reactivo)
- **Estado:** Riverpod con codegen (`riverpod_generator`)
- **Red:** Dio con interceptor de autenticación (bearer + refresh automático en 401)
- **Persistencia:** Drift (SQLite) y `flutter_secure_storage` para tokens
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

## Desarrollo

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

### Backend

La app apunta al backend en `http://localhost:8000` (`/api/v1`). Para cambiarlo:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000   # emulador Android
```
