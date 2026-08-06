import '../../../core/money/fixed2.dart';
import 'order.dart';

/// El pedido recién guardado, para la pantalla de confirmación (§3.8).
class SavedOrder {
  const SavedOrder({
    required this.id,
    required this.dailyNumber,
    required this.total,
    required this.paid,
    this.warnings = const [],
  });

  final String id;

  /// Correlativo del día, o el provisional en negativo mientras el pedido no
  /// haya subido.
  final int dailyNumber;

  /// Centavos.
  final int total;
  final int paid;

  final List<String> warnings;

  int get balance => total - paid;

  /// Todavía no tiene número del servidor, así que todavía no subió.
  bool get pendingSync => dailyNumber < 0;

  String get reference => orderReference(dailyNumber);

  double get totalAsDouble => Fixed2.toDouble(total);

  double get balanceAsDouble => Fixed2.toDouble(balance);
}
