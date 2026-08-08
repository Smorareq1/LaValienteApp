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
import '../../features/cash/ui/cash_screen.dart';
import '../../features/cash/ui/supply_sale_screen.dart';
import '../../features/customers/ui/customer_detail_screen.dart';
import '../../features/customers/ui/customers_screen.dart';
import '../../features/inventory/ui/inventory_screen.dart';
import '../../features/inventory/ui/product_detail_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/more/ui/more_screen.dart';
import '../../features/orders/models/order.dart';
import '../../features/orders/ui/order_capture_screen.dart';
import '../../features/orders/ui/order_detail_screen.dart';
import '../../features/orders/ui/order_deliver_screen.dart';
import '../../features/orders/ui/orders_screen.dart';
import '../../features/promotions/ui/promotions_screen.dart';
import '../../features/shell/ui/app_shell.dart';
import '../../features/staff/ui/attendance_screen.dart';
import '../../features/shell/ui/module_placeholder_screen.dart';
import '../../features/sync/ui/review_detail_screen.dart';
import '../../features/sync/ui/review_queue_screen.dart';
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
  // Se evalúa además del de `/orders`: tomar un pedido supone poder verlos.
  OrderCaptureScreen.path: [AppPermissions.ordersCreate],
  '/customers': [AppPermissions.customersRead],
  '/cash': [AppPermissions.expensesRead],
  // Se evalúa además del de `/cash`: vender un insumo supone poder ver la caja.
  SupplySaleScreen.path: [AppPermissions.supplySalesCreate],
  '/cash/history': [AppPermissions.dailyCloseRead],
  '/inventory': [AppPermissions.inventoryRead],
  '/staff': [AppPermissions.attendanceRecord, AppPermissions.staffRead],
  '/staff/employees': [AppPermissions.staffRead],
  '/staff/settings': [AppPermissions.staffManage],
  '/catalog': [AppPermissions.catalogManage],
  '/promotions': [AppPermissions.promotionsManage],
};

/// Rutas de los módulos que "Más" ya ofrece pero que su fase de UI aún no
/// construye (Plan 0006 §16). El permiso lo sigue aplicando [_routePermissions],
/// así que el marcador solo lo ve quien tendría acceso a la pantalla real.
final List<RouteBase> _pendingModules = [
  for (final module in const [
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
      // La cola de revisión se alcanza desde el banner de Inicio, desde el
      // indicador del AppBar y desde la propia pantalla de sincronización. Van
      // planas y no anidadas bajo `/sync` porque se llega a ellas desde
      // cualquier parte de la app, no bajando por un módulo.
      //
      // Solo piden sesión (§3.2): un colaborador tiene que poder resolver sus
      // propias capturas, y el RBAC del servidor sigue decidiendo qué se aplica.
      GoRoute(
        path: ReviewQueueScreen.path,
        builder: (context, state) => const ReviewQueueScreen(),
      ),
      GoRoute(
        path: ReviewDetailScreen.path,
        builder: (context, state) =>
            ReviewDetailScreen(opId: state.pathParameters['opId']!),
      ),
      // La toma de pedido también vive fuera del shell: ocupa la pantalla
      // completa y su footer de total va pegado abajo, donde estaría la barra
      // de navegación. Se llega desde Inicio y desde la lista de Pedidos, y se
      // sale con la flecha o al guardar.
      //
      // Va **antes** del shell a propósito: dentro de la rama de Pedidos vive
      // `/orders/:id`, que también casaría con "new". Gana la primera que
      // coincide, y esta se declara primero.
      GoRoute(
        path: OrderCaptureScreen.path,
        builder: (context, state) => const OrderCaptureScreen(),
      ),
      // Corregir una boleta es la misma pantalla precargada (plan 0001 §7.3),
      // así que vive donde ella: fuera del shell, porque el footer del total
      // ocupa el sitio de la barra de navegación. El permiso lo aplica el botón
      // del detalle —que distingue un pedido listo de uno en proceso— y el RBAC
      // del servidor al aplicar la operación, que es donde el plan 0004 §10
      // dice que se evalúa.
      GoRoute(
        path: '/orders/:id/edit',
        builder: (context, state) =>
            OrderCaptureScreen(orderId: state.pathParameters['id']),
      ),
      // La venta de insumo va fuera del shell por lo mismo que la toma de
      // pedido: su footer con el TOTAL ocupa el sitio de la barra de cinco
      // destinos. Y **antes** del shell, porque dentro de la rama de Caja
      // podrían vivir rutas hijas que también casarían con "supply-sale".
      GoRoute(
        path: InventoryScreen.path,
        builder: (context, state) => const InventoryScreen(),
        routes: [
          // Hija: el detalle se apila sobre la cuadrícula, así que volver
          // regresa a ella con la búsqueda intacta.
          GoRoute(
            path: ':id',
            builder: (context, state) =>
                ProductDetailScreen(productId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: AttendanceScreen.path,
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: SupplySaleScreen.path,
        builder: (context, state) => const SupplySaleScreen(),
      ),
      // Administrar promociones también se apila sobre el shell: se llega desde
      // "Más", es cosa de admin y no uno de los cinco destinos del mostrador.
      GoRoute(
        path: PromotionsScreen.path,
        builder: (context, state) => const PromotionsScreen(),
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
                path: OrdersScreen.path,
                builder: (context, state) => OrdersScreen(
                  // Los contadores de Inicio abren la lista ya filtrada.
                  initialStatus: _statusFromExtra(state.extra),
                ),
                routes: [
                  // Hijas de la rama: la barra inferior sigue ahí y volver
                  // regresa a la lista con el día y los filtros intactos.
                  GoRoute(
                    path: ':id',
                    builder: (context, state) =>
                        OrderDetailScreen(orderId: state.pathParameters['id']!),
                    routes: [
                      GoRoute(
                        path: 'deliver',
                        builder: (context, state) =>
                            OrderDeliverScreen(orderId: state.pathParameters['id']!),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: CashScreen.path,
                builder: (context, state) => const CashScreen(),
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

/// El estado con el que Inicio pide abrir la lista, si mandó alguno.
///
/// Viaja como `extra` y no en la ruta porque es una preferencia de apertura, no
/// una dirección: `/orders` filtrado por "listos" y `/orders` son la misma
/// pantalla, y un enlace guardado no debería congelar un filtro.
OrderStatus? _statusFromExtra(Object? extra) {
  if (extra is! Map) return null;
  final status = extra['status'];
  return status is String ? OrderStatus.fromWire(status) : null;
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
