import '../../../core/database/tables/synced_columns.dart';
import '../../../core/money/payment_method.dart';

/// Si el dinero ya salió o el día todavía lo debe.
///
/// Es el «pago atrasado» de la hoja: el proveedor entregó, el gasto cuenta
/// contra el día y el cajón sigue con el dinero adentro. El cierre suma los dos
/// en el total y solo el pagado en el arqueo, y esa diferencia es la advertencia.
enum ExpenseStatus {
  paid('paid', 'Pagado'),
  pending('pending', 'Pendiente');

  const ExpenseStatus(this.wire, this.label);

  final String wire;
  final String label;

  static ExpenseStatus fromWire(String value) =>
      value == 'pending' ? ExpenseStatus.pending : ExpenseStatus.paid;
}

/// Una categoría de gasto, tal como la administra el servidor.
class ExpenseCategory {
  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.isActive,
    required this.sortOrder,
  });

  final String id;
  final String name;
  final bool isActive;
  final int sortOrder;
}

/// Un gasto del día (plan 0005 §6.2).
class Expense {
  const Expense({
    required this.id,
    required this.expenseDate,
    required this.categoryId,
    required this.categoryName,
    required this.concept,
    required this.amount,
    required this.method,
    required this.status,
    required this.syncStatus,
    required this.version,
    this.observations,
    this.employeeId,
    this.attendanceRecordId,
    this.productLotId,
  });

  final String id;

  /// `YYYY-MM-DD`, la fecha de negocio a la que el gasto pertenece.
  final String expenseDate;

  final String categoryId;

  /// Sale de unir con la categoría. Cuando el gasto se captura sin señal contra
  /// una categoría que sí bajó, siempre hay nombre; si la categoría todavía no
  /// llegó, esto queda vacío y la pantalla lo dice en vez de inventarlo.
  final String categoryName;

  final String concept;

  /// En centavos (plan 0001 D14).
  final int amount;

  /// `null` si el servidor mandó un método que esta versión no conoce.
  final PaymentMethod? method;

  final ExpenseStatus status;
  final RowSyncStatus syncStatus;

  /// Versión conocida del servidor; viaja como `base_version` al corregirlo.
  final int version;

  final String? observations;

  /// Los tres vínculos del §6.2 y §6.3. Un gasto que los lleva no se corrige
  /// desde la Caja: se anula y se vuelve a hacer, porque moverlo de jornada o
  /// de lote es otro pago, no una corrección.
  final String? employeeId;
  final String? attendanceRecordId;
  final String? productLotId;

  bool get isPending => status == ExpenseStatus.pending;

  /// Todavía no subió al servidor.
  bool get pendingSync => syncStatus == RowSyncStatus.pending;

  /// Su operación cayó a la cola de revisión.
  bool get needsReview => syncStatus == RowSyncStatus.rejected;

  /// Un gasto atado a una jornada o a un lote no se edita: el servidor tampoco
  /// deja mover esos vínculos, y editar lo demás dejaría un pago de hora extra
  /// diciendo una cosa y la jornada otra.
  bool get isLinked => attendanceRecordId != null || productLotId != null;
}
