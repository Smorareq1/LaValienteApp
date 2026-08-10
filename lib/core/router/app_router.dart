import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/access/ui/users_screen.dart';
import '../../features/auth/models/auth_user.dart';
import '../../features/auth/state/auth_controller.dart';
import '../../features/auth/ui/forgot_password_screen.dart';
import '../../features/auth/ui/login_screen.dart';
import '../../features/auth/ui/reset_password_screen.dart';
import '../../features/auth/ui/splash_screen.dart';
import '../../features/cash/ui/cash_screen.dart';
import '../../features/cash/ui/close_history_screen.dart';
import '../../features/cash/ui/day_close_screen.dart';
import '../../features/cash/ui/supply_sale_screen.dart';
import '../../features/customers/ui/customer_detail_screen.dart';
import '../../features/customers/ui/customers_screen.dart';
import '../../features/catalog/ui/catalog_screen.dart';
import '../../features/catalog/ui/service_detail_screen.dart';
import '../../features/catalog/ui/service_wizard_screen.dart';
import '../../features/inventory/ui/inventory_screen.dart';
import '../../features/inventory/ui/product_detail_screen.dart';
import '../../features/home/ui/home_screen.dart';
import '../../features/more/ui/more_screen.dart';
import '../../features/orders/models/order.dart';
import '../../features/orders/ui/order_capture_screen.dart';
import '../../features/orders/ui/order_detail_screen.dart';
import '../../features/orders/ui/order_deliver_screen.dart';
import '../../features/orders/ui/order_services_screen.dart';
import '../../features/orders/ui/orders_screen.dart';
import '../../features/promotions/ui/promotions_screen.dart';
import '../../features/scan/models/scan.dart';
import '../../features/scan/ui/scan_screen.dart';
import '../../features/shell/ui/app_shell.dart';
import '../../features/staff/ui/attendance_screen.dart';
import '../../features/staff/ui/employees_screen.dart';
import '../../features/staff/ui/staff_settings_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
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
  // Escanear también: el borrador solo sirve para acabar en una boleta, y el
  // servidor exige además `scans.create` al leer la foto.
  ScanScreen.path: [AppPermissions.ordersCreate],
  '/customers': [AppPermissions.customersRead],
  '/cash': [AppPermissions.expensesRead],
  // Se evalúa además del de `/cash`: vender un insumo supone poder ver la caja.
  SupplySaleScreen.path: [AppPermissions.supplySalesCreate],
  // Leer el acta, no firmarla: cerrar y reabrir piden su permiso en el botón,
  // porque el colaborador sí necesita las cifras del día para cuadrar el cajón
  // (§13, y por eso `daily_close.read` es suyo por omisión en el catálogo).
  DayCloseScreen.path: [AppPermissions.dailyCloseRead],
  CloseHistoryScreen.path: [AppPermissions.dailyCloseRead],
  '/inventory': [AppPermissions.inventoryRead],
  '/staff': [AppPermissions.attendanceRecord, AppPermissions.staffRead],
  '/staff/employees': [AppPermissions.staffRead],
  '/staff/settings': [AppPermissions.staffManage],
  CatalogScreen.path: [AppPermissions.catalogManage],
  ServiceDetailScreen.path: [AppPermissions.catalogManage],
  ServiceWizardScreen.path: [AppPermissions.catalogManage],
  '/promotions': [AppPermissions.promotionsManage],
  // `/settings` a secas solo pide sesión —el perfil es de todos—, así que la
  // administración de cuentas pone su propia puerta.
  UsersScreen.path: [AppPermissions.usersManage],
};

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
      // El escaneo va **antes** que `/orders/new` y que la rama de Pedidos por
      // lo mismo que la toma: `/orders/:id` también casaría con "scan".
      GoRoute(
        path: ScanScreen.path,
        builder: (context, state) => const ScanScreen(),
      ),
      GoRoute(
        path: OrderCaptureScreen.path,
        // El borrador viaja como `extra` y no en la ruta: es un prellenado, no
        // una dirección. `/orders/new` guardado en un enlace tiene que seguir
        // significando "boleta en blanco".
        builder: (context, state) =>
            OrderCaptureScreen(scan: _scanFromExtra(state.extra)),
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
      // Las dos de administración van **antes** que `/staff`: son rutas hijas
      // suyas por el camino y GoRouter se queda con la primera que coincide.
      // El detalle del servicio va antes que `/catalog` por lo mismo que las de
      // personal: es una ruta hija suya y la primera coincidencia gana.
      // El asistente va **antes** que el detalle por lo mismo que `/orders/new`:
      // `/catalog/services/:id` también casaría con "new" y gana la primera.
      GoRoute(
        path: ServiceWizardScreen.path,
        builder: (context, state) => const ServiceWizardScreen(),
      ),
      GoRoute(
        path: ServiceDetailScreen.path,
        builder: (context, state) =>
            ServiceDetailScreen(serviceId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: CatalogScreen.path,
        builder: (context, state) => const CatalogScreen(),
      ),
      // Antes que `/settings` por lo mismo que las dos de personal: es una ruta
      // hija suya por el camino y gana la primera que coincide.
      GoRoute(
        path: UsersScreen.path,
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: SettingsScreen.path,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: EmployeesScreen.path,
        builder: (context, state) => const EmployeesScreen(),
      ),
      GoRoute(
        path: StaffSettingsScreen.path,
        builder: (context, state) => const StaffSettingsScreen(),
      ),
      GoRoute(
        path: AttendanceScreen.path,
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: SupplySaleScreen.path,
        builder: (context, state) => const SupplySaleScreen(),
      ),
      // El cierre y su histórico también se apilan sobre el shell, y **antes**
      // que él por lo mismo que la venta: son rutas bajo `/cash` y la rama de
      // Caja gana la coincidencia si se declaran después.
      //
      // La fecha viaja como query y no en la ruta porque la pantalla tiene un
      // día por omisión —hoy— y `/cash/close` a secas tiene que seguir
      // significando "cerrar el día de hoy".
      GoRoute(
        path: DayCloseScreen.path,
        builder: (context, state) =>
            DayCloseScreen(date: state.uri.queryParameters['date']),
      ),
      GoRoute(
        path: CloseHistoryScreen.path,
        builder: (context, state) => const CloseHistoryScreen(),
      ),
      // Administrar promociones también se apila sobre el shell: se llega desde
      // "Más", es cosa de admin y no uno de los cinco destinos del mostrador.
      GoRoute(
        path: PromotionsScreen.path,
        builder: (context, state) => const PromotionsScreen(),
      ),
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
                      // Sumar servicios a una boleta viva. El permiso lo aplica
                      // el botón del detalle —que distingue un pedido listo de
                      // uno en proceso— y el RBAC del servidor al aplicar la
                      // operación, igual que con «Editar».
                      GoRoute(
                        path: 'services',
                        builder: (context, state) =>
                            OrderServicesScreen(orderId: state.pathParameters['id']!),
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

/// El borrador con el que el escaneo abre la boleta, si vino uno.
ScanResult? _scanFromExtra(Object? extra) {
  if (extra is! Map) return null;
  final scan = extra['scan'];
  return scan is ScanResult ? scan : null;
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
