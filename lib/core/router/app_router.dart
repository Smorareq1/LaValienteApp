import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/models/auth_user.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/auth/ui/forgot_password_screen.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/reset_password_screen.dart';
import '../../features/auth/ui/splash_screen.dart';
import '../../features/customers/ui/customer_detail_screen.dart';
import '../../features/customers/ui/customers_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/more/ui/more_screen.dart';
import '../../features/shell/ui/app_shell.dart';
import '../../features/shell/ui/module_placeholder_screen.dart';
import '../../features/sync/ui/sync_screen.dart';
import '../auth/app_permissions.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Permiso mínimo por ruta (Plan 0006 §3.2). Una ruta ausente de este mapa
/// solo exige sesión.
///
/// Es la segunda mitad de ocultar una sección: el destino desaparece de la barra
/// y del hub, pero un `push` a mano, un deep link o una ruta guardada tienen que
/// toparse con la misma puerta.
const Map<String, List<String>> _routePermissions = {
  '/orders': [AppPermissions.ordersRead],
  '/customers': [AppPermissions.customersRead],
  '/cash': [AppPermissions.expensesRead],
  '/cash/history': [AppPermissions.dailyCloseRead],
  '/inventory': [AppPermissions.inventoryRead],
  '/staff': [AppPermissions.attendanceRecord, AppPermissions.staffRead],
  '/catalog': [AppPermissions.catalogManage],
  '/promotions': [AppPermissions.promotionsManage],
};

/// Rutas de los módulos que "Más" ya ofrece pero que su fase de UI aún no
/// construye (Plan 0006 §16). El permiso lo sigue aplicando [_routePermissions],
/// así que el marcador solo lo ve quien tendría acceso a la pantalla real.
final List<RouteBase> _pendingModules = [
  for (final module in const [
    (path: '/inventory', title: 'Insumos', icon: Icons.inventory_2_outlined, phase: 'UI 7'),
    (path: '/staff', title: 'Personal', icon: Icons.badge_outlined, phase: 'UI 7'),
    (path: '/promotions', title: 'Promociones', icon: Icons.local_offer_outlined, phase: 'UI 5'),
    (path: '/catalog', title: 'Catálogo', icon: Icons.sell_outlined, phase: 'UI 10'),
    (
      path: '/cash/history',
      title: 'Cierres de días pasados',
      icon: Icons.calendar_month_outlined,
      phase: 'UI 8',
    ),
    (path: '/settings', title: 'Ajustes', icon: Icons.settings_outlined, phase: 'UI 10'),
  ])
    GoRoute(
      path: module.path,
      builder: (context, state) => ModulePlaceholderScreen(
        title: module.title,
        icon: module.icon,
        phase: module.phase,
      ),
    ),
];

/// Router de la app con auth guard reactivo:
/// - Mientras se restaura la sesión → splash.
/// - Sin sesión → cualquier ruta protegida redirige a login.
/// - Con sesión → login/splash redirigen a Inicio.
/// - Con sesión pero sin el permiso de la ruta → vuelve a Inicio.
@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refreshNotifier = ValueNotifier(0);
  ref.onDispose(refreshNotifier.dispose);
  ref.listen(authControllerProvider, (_, _) => refreshNotifier.value++);

  // Rutas accesibles sin sesión (login y recuperación de contraseña).
  const publicPaths = {
    LoginScreen.path,
    ForgotPasswordScreen.path,
    ResetPasswordScreen.path,
  };

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: SplashScreen.path,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final location = state.matchedLocation;

      if (auth.isLoading) {
        return location == SplashScreen.path ? null : SplashScreen.path;
      }

      final user = auth.valueOrNull;
      if (user == null) {
        return publicPaths.contains(location) ? null : LoginScreen.path;
      }
      if (publicPaths.contains(location) || location == SplashScreen.path) {
        return HomeScreen.path;
      }
      if (!_isAllowed(user, location)) return HomeScreen.path;
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
        path: ForgotPasswordScreen.path,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: ResetPasswordScreen.path,
        builder: (context, state) =>
            ResetPasswordScreen(initialIdentifier: state.extra as String?),
      ),
      // Fuera del shell: se apila sobre la pantalla desde la que se abrió, sin
      // pertenecer a ningún tab.
      GoRoute(
        path: SyncScreen.path,
        builder: (context, state) => const SyncScreen(),
      ),
      // Los módulos del hub "Más". Existen desde ya, aunque sea como marcador,
      // porque el hub los ofrece: una entrada visible que cae en la pantalla de
      // ruta desconocida se lee como una app rota, no como una fase pendiente.
      ..._pendingModules,
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        // El orden de las ramas debe coincidir con `shellDestinations`.
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: HomeScreen.path,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/orders',
                builder: (context, state) => const ModulePlaceholderScreen(
                  title: 'Pedidos',
                  icon: Icons.local_mall_outlined,
                  phase: 'UI 4',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/cash',
                builder: (context, state) => const ModulePlaceholderScreen(
                  title: 'Caja',
                  icon: Icons.account_balance_wallet_outlined,
                  phase: 'UI 6',
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CustomersScreen.path,
                builder: (context, state) => const CustomersScreen(),
                routes: [
                  // Ruta hija: el detalle se apila dentro de la rama, así que
                  // la barra inferior sigue ahí y volver regresa a la lista
                  // con la búsqueda intacta.
                  GoRoute(
                    path: ':id',
                    builder: (context, state) => CustomerDetailScreen(
                      customerId: state.pathParameters['id']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: MoreScreen.path,
                builder: (context, state) => const MoreScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Comprueba el permiso mínimo de [location] contra los permisos de [user].
///
/// Se evalúa por prefijo para que las rutas apiladas hereden el permiso de su
/// módulo (`/orders/42` exige lo mismo que `/orders`).
bool _isAllowed(AuthUser user, String location) {
  for (final entry in _routePermissions.entries) {
    final isMatch = location == entry.key || location.startsWith('${entry.key}/');
    if (isMatch && !user.hasAnyPermission(entry.value)) return false;
  }
  return true;
}
