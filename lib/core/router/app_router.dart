import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/state/auth_controller.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/splash_screen.dart';
import '../../features/home/ui/home_screen.dart';

part 'app_router.g.dart';

/// Router de la app con auth guard reactivo:
/// - Mientras se restaura la sesión → splash.
/// - Sin sesión → cualquier ruta protegida redirige a login.
/// - Con sesión → login/splash redirigen a home.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = ValueNotifier(0);
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authControllerProvider, (_, _) => refreshNotifier.value++);

  return GoRouter(
    initialLocation: SplashScreen.path,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (auth.isLoading) {
        return location == SplashScreen.path ? null : SplashScreen.path;
      }

      final loggedIn = auth.valueOrNull != null;
      if (!loggedIn) {
        return location == LoginScreen.path ? null : LoginScreen.path;
      }
      if (location == LoginScreen.path || location == SplashScreen.path) {
        return HomeScreen.path;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: SplashScreen.path,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: LoginScreen.path,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: HomeScreen.path,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
