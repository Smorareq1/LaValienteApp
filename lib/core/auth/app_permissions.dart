/// Códigos de permiso `resource.action` del backend (módulo `identity`).
///
/// Se centralizan aquí para que las pantallas y el guard del router hablen del
/// mismo string y un cambio de nombre en el backend se corrija en un solo sitio.
abstract final class AppPermissions {
  /// Comodín: quien lo tiene pasa cualquier chequeo salvo un `deny` explícito.
  /// Lo llevan los roles `admin` y `system_admin`, para que un módulo nuevo
  /// aparezca para ellos el día que se publica sin tener que otorgar nada.
  static const String all = '*.*';

  // Pedidos — Plan 0001 §9.
  static const String ordersRead = 'orders.read';
  static const String ordersCreate = 'orders.create';

  /// Mover el pedido por la cadena `recibido → en proceso → listo`. Lo tiene
  /// todo colaborador; entregar y anular piden lo suyo aparte.
  static const String ordersUpdate = 'orders.update';

  /// Corregir un pedido que ya está listo (plan 0001 §7.3). Los estados
  /// `recibido` y `en proceso` los edita cualquiera con `ordersUpdate`; uno ya
  /// contado, lavado y doblado es decisión de un admin.
  static const String ordersUpdateReady = 'orders.update_ready';

  static const String ordersDeliver = 'orders.deliver';
  static const String ordersDeliverUnpaid = 'orders.deliver_unpaid';
  static const String ordersCollectPayment = 'orders.collect_payment';
  static const String ordersCancel = 'orders.cancel';

  /// Rebajar un pedido sin una promoción detrás. El chequeo del backend vive en
  /// el service porque la condición es el cuerpo del pedido, no la ruta.
  static const String ordersManualDiscount = 'orders.manual_discount';

  // Clientes.
  static const String customersRead = 'customers.read';
  static const String customersCreate = 'customers.create';
  static const String customersUpdate = 'customers.update';
  static const String customersArchive = 'customers.archive';

  // Caja — Plan 0005 §7.
  static const String expensesRead = 'expenses.read';
  static const String expensesCreate = 'expenses.create';
  static const String supplySalesCreate = 'supply_sales.create';
  static const String dailyCloseRead = 'daily_close.read';
  static const String dailyCloseClose = 'daily_close.close';
  static const String dailyCloseReopen = 'daily_close.reopen';

  // Inventario.
  static const String inventoryRead = 'inventory.read';
  static const String inventoryManage = 'inventory.manage';
  static const String inventoryAdjust = 'inventory.adjust';

  // Personal.
  static const String attendanceRecord = 'attendance.record';
  static const String staffRead = 'staff.read';
  static const String staffManage = 'staff.manage';

  // Catálogo y promociones.
  static const String catalogManage = 'catalog.manage';
  static const String promotionsManage = 'promotions.manage';

  // Administración de accesos.
  static const String usersManage = 'authorization.users.manage';
  static const String rolesManage = 'authorization.roles.manage';
}
