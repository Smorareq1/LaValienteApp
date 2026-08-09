import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/money/payment_method.dart';
import '../../../core/time/business_date.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../cash/state/cash_day_controller.dart';
import '../../customers/state/customers_controller.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../data/orders_repository.dart';
import '../models/order.dart';
import '../state/orders_controller.dart';
import 'order_deliver_screen.dart';
import 'orders_screen.dart';
import 'widgets/cancel_order_sheet.dart';
import 'widgets/order_progress.dart';
import 'widgets/order_status_badge.dart';
import 'widgets/payment_sheet.dart';

/// Detalle de un pedido (Plan 0006 §5.4).
///
/// Todo el pedido en modo lectura, y abajo lo que se puede hacer con él según
/// su estado y los permisos de quien lo mira. Las acciones no se listan todas
/// apagadas: lo que este estado no permite simplemente no está, porque un botón
/// gris que nunca se enciende es una pregunta sin respuesta.
class OrderDetailScreen extends ConsumerWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detail = ref.watch(orderDetailProvider(orderId));

    return switch (detail) {
      AsyncData(value: final order?) => _Detail(order: order),
      AsyncData() => const _Missing(),
      AsyncError(:final error) => _Failed(message: '$error'),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }
}

class _Missing extends StatelessWidget {
  const _Missing();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: AppEmptyState(
        icon: Icons.help_outline_rounded,
        title: 'Ese pedido ya no está',
        message: 'Puede haberse borrado en otro dispositivo.',
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: AppEmptyState(
        icon: Icons.storage_rounded,
        title: 'No se pudo leer el pedido',
        message: message,
      ),
    );
  }
}

/// Qué está bloqueado por un día ya cerrado.
///
/// Son dos candados y no uno porque el backend usa dos fechas distintas:
/// corregir o anular la boleta toca el día **del pedido** (`ensure_open` sobre
/// `order.order_date`), mientras que entregar y cobrar caen en la hoja de
/// **hoy**, pase lo que pase con la fecha de la boleta — un pedido del lunes que
/// se paga el miércoles es ingreso del miércoles. Un solo candado escondería
/// botones que el servidor sí acepta, o mostraría otros que va a rechazar.
///
/// Avanzar de estado no lleva candado: mover ropa de "recibido" a "en proceso"
/// no mueve dinero de ningún día, y `change_status` no lo comprueba.
class _Locks {
  const _Locks({required this.orderDay, required this.today, required this.sameDay});

  /// El día de la boleta está cerrado: no se corrige ni se anula.
  final bool orderDay;

  /// Hoy está cerrado: no se entrega ni se cobra.
  final bool today;

  final bool sameDay;

  bool get any => orderDay || today;
}

class _Detail extends ConsumerStatefulWidget {
  const _Detail({required this.order});

  final OrderDetail order;

  @override
  ConsumerState<_Detail> createState() => _DetailState();
}

class _DetailState extends ConsumerState<_Detail> {
  bool _busy = false;

  OrderDetail get order => widget.order;

  /// Corre una acción del ciclo y avisa cómo fue.
  ///
  /// El éxito se confirma aunque la pantalla ya se redibuje sola con la BD
  /// local: sin aviso, tocar "Marcar listo" y ver cambiar una píldora pequeña
  /// se parece demasiado a no haber hecho nada.
  Future<void> _run(
    Future<Either<AppFailure, void>> Function() action,
    String done,
  ) async {
    setState(() => _busy = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _busy = false);

    final messenger = ScaffoldMessenger.of(context);
    result.match(
      (failure) => messenger.showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => messenger.showSnackBar(SnackBar(content: Text(done))),
    );
  }

  Future<void> _advance(OrderStatus next) async {
    final repository = ref.read(ordersRepositoryProvider);
    await _run(
      () => repository.changeStatus(order, next),
      'Pedido ${order.reference}: ${next.label.toLowerCase()}',
    );
  }

  Future<void> _pay() async {
    final payment = await PaymentSheet.show(context, balance: order.balance);
    if (payment == null || !mounted) return;

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;
    final repository = ref.read(ordersRepositoryProvider);
    await _run(
      () => repository.addPayment(order, payment: payment, actorId: user.id),
      'Pago de Q${Fixed2.format(payment.amount)} registrado',
    );
  }

  Future<void> _cancel() async {
    final reason = await CancelOrderSheet.show(context, reference: order.reference);
    if (reason == null || !mounted) return;

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;
    final repository = ref.read(ordersRepositoryProvider);
    await _run(
      () => repository.cancel(order, reason: reason, actorId: user.id),
      'Pedido ${order.reference} anulado',
    );
  }

  bool _can(String permission) {
    final user = ref.watch(authControllerProvider).valueOrNull;
    return user != null && user.hasAnyPermission([permission]);
  }

  _Locks _locks() {
    final today = isoDate(businessDate());
    final orderDay = ref.watch(cashClosureProvider(order.orderDate)).valueOrNull != null;
    final sameDay = order.orderDate == today;
    return _Locks(
      orderDay: orderDay,
      today: sameDay
          ? orderDay
          : ref.watch(cashClosureProvider(today)).valueOrNull != null,
      sameDay: sameDay,
    );
  }

  @override
  Widget build(BuildContext context) {
    final locks = _locks();
    final status = order.status;

    final canDeliver =
        (status?.canBeDelivered ?? false) && !locks.today && _can(AppPermissions.ordersDeliver);
    final canCollect = (status?.acceptsPayments ?? false) &&
        order.hasBalance &&
        !locks.today &&
        _can(AppPermissions.ordersCollectPayment);

    // Entregar es la acción principal desde cualquier estado vivo (plan 0001
    // D13). Marcar «en proceso» o «listo» sigue estando, pero abajo con las
    // demás: es contabilidad opcional, y ponerla acá arriba volvería a sugerir
    // que hay que darla antes de poder entregar.
    final (String, VoidCallback)? primary = canDeliver
        ? ('Entregar pedido', () => context.push(OrderDeliverScreen.pathFor(order.id)))
        : null;

    return Stack(
      children: [
        Column(
          children: [
            _Header(order: order),
            Expanded(child: _body(locks)),
          ],
        ),
        if (primary != null || canCollect)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _ActionBar(
              order: order,
              busy: _busy,
              primaryLabel: primary?.$1,
              onPrimary: primary?.$2,
              onCollect: canCollect ? _pay : null,
            ),
          ),
      ],
    );
  }

  Widget _body(_Locks locks) {
    return ListView(
      // El hueco de abajo deja pasar la barra fija: sin él, el último botón de
      // la lista queda debajo de ella y no hay scroll que lo rescate.
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 180),
      children: [
        if (locks.any) _LockNotice(locks: locks),
        if (order.status == OrderStatus.cancelled) _CancelledBanner(reason: order.cancelReason),
        if (order.isPending)
          const _Notice(
            icon: Icons.schedule_rounded,
            message: 'Todavía no sube al servidor. El No. diario definitivo '
                'llega al sincronizar.',
          ),
        if (order.needsReview)
          const _Notice(
            icon: Icons.error_outline_rounded,
            isError: true,
            message: 'El servidor rechazó este pedido. Está en la cola de revisión.',
          ),
        if (OrderProgress.appliesTo(order.status)) OrderProgress(status: order.status),
        _CustomerCard(order: order),
        _FactsRow(order: order),
        _GarmentsCard(order: order),
        _MoneyCard(order: order),
        _PaymentsCard(order: order),
        _AuditCard(order: order),
        _SecondaryActions(
          order: order,
          locks: locks,
          busy: _busy,
          onAdvance: _advance,
          onCancel: _cancel,
        ),
      ],
    );
  }
}

/// Cabecera: volver, fecha, folio y estado.
///
/// El folio y el estado viven aquí y no en una tarjeta porque son las dos cosas
/// que se dicen en voz alta ("el 42, ya está listo") y no deberían irse con el
/// scroll cuando alguien baja a mirar los cargos.
class _Header extends StatelessWidget {
  const _Header({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final day = parseIsoDate(order.orderDate);
    final created = order.createdAt?.toLocal();
    final when = [
      if (day != null) formatBusinessDate(day, today: businessDate()) else order.orderDate,
      if (created != null) _hhmm(created),
    ].join(' · ');

    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(8, 0, 14, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(OrdersScreen.path);
              }
            },
            tooltip: 'Volver',
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  when,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  // "No. 42" cuando el servidor ya numeró la boleta; el folio
                  // provisional se deja tal cual, porque "No. P-1" haría pasar
                  // por número diario algo que todavía no lo es.
                  order.dailyNumber < 0 ? order.reference : 'No. ${order.dailyNumber}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.h3.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OrderStatusBadge(status: order.status, compact: true),
        ],
      ),
    );
  }
}

/// El candado del día cerrado (Plan 0005 D9).
class _LockNotice extends StatelessWidget {
  const _LockNotice({required this.locks});

  final _Locks locks;

  @override
  Widget build(BuildContext context) {
    final message = locks.sameDay
        ? 'Día cerrado · este pedido ya no se puede editar'
        : locks.orderDay && locks.today
            ? 'El día del pedido y el de hoy están cerrados · no se puede '
                'corregir, anular, entregar ni cobrar'
            : locks.orderDay
                ? 'El día del pedido ya está cerrado · no se puede corregir ni anular'
                : 'Hoy ya está cerrado · no se pueden registrar entregas ni pagos';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 17, color: AppColors.gray600),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.gray800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// El aviso de anulado, con su motivo.
///
/// Sube arriba del todo en vez de quedarse en la bitácora: es lo primero que hay
/// que saber de esta boleta, porque cambia el sentido de todas las cifras que
/// vienen debajo.
class _CancelledBanner extends StatelessWidget {
  const _CancelledBanner({required this.reason});

  final String? reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.cancel_outlined, size: 17, color: AppColors.errorText),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido anulado',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF912018),
                  ),
                ),
                if (reason != null)
                  Text(
                    'Motivo: $reason',
                    style: AppTypography.bodySm.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.errorText,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// El cliente, con lo que hace falta para llamarlo o facturarle.
class _CustomerCard extends ConsumerWidget {
  const _CustomerCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = ref.watch(customerByIdProvider(order.customerId)).valueOrNull;
    // El NIT de la boleta manda sobre el del cliente: se factura al que se pidió
    // ese día, y puede no ser el suyo de siempre.
    final subtitle = [
      if (customer?.phone != null) customer!.phone!,
      if (order.nit != null) 'NIT ${order.nit}' else if (customer?.nit != null) 'NIT ${customer!.nit}',
    ].join(' · ');

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          onTap: () => context.push('/customers/${order.customerId}'),
          child: Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                AppAvatar(initials: _initials(order.customerName)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        subtitle.isEmpty ? 'Sin teléfono ni NIT' : subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.helper.copyWith(
                          fontSize: 11.5,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.gray300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Iniciales para el avatar: la primera de las dos primeras palabras.
  static String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    if (words.length == 1) return words.first.characters.first.toUpperCase();
    return (words[0].characters.first + words[1].characters.first).toUpperCase();
  }
}

/// Boleta, peso y piezas: los tres datos que se cotejan contra el papel.
class _FactsRow extends StatelessWidget {
  const _FactsRow({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final facts = <(IconData, Color, String, String)>[
      if (order.bookletSerial != null)
        (Icons.receipt_long_rounded, AppColors.gray400, order.bookletSerial!, 'Boleta'),
      if (order.weightLbs != null)
        (
          Icons.scale_rounded,
          AppColors.secondary600,
          '${Fixed2.format(order.weightLbs!)} lbs',
          'Peso',
        ),
      (Icons.layers_rounded, AppColors.primary500, '${order.totalPieces}', 'Piezas'),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          for (var index = 0; index < facts.length; index++)
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == facts.length - 1 ? 0 : 8),
                child: _FactTile(
                  icon: facts[index].$1,
                  color: facts[index].$2,
                  value: facts[index].$3,
                  label: facts[index].$4,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.money(fontSize: 15),
          ),
          Text(
            label,
            style: AppTypography.helper.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GarmentsCard extends StatelessWidget {
  const _GarmentsCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    if (order.garments.isEmpty) return const SizedBox.shrink();

    final reconciled = order.garments.any((line) => line.quantityDelivered != null);
    final missing = order.garments
        .where((line) => line.isShort)
        .fold(0, (sum, line) => sum + (line.quantity - line.quantityDelivered!));

    return _Card(
      title: 'Prendas',
      trailing: reconciled
          ? Text(
              'recib. / entreg.',
              style: AppTypography.helper.copyWith(
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                color: AppColors.gray500,
              ),
            )
          : AppStatusBadge(
              label: '${order.totalPieces} pzas',
              tone: AppStatusTone.brand,
              size: AppStatusBadgeSize.sm,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Dos columnas y no una lista: son cuatro o cinco tipos de prenda con
          // una cifra corta cada uno, y en una sola columna la mitad del ancho
          // queda vacía y hay que hacer scroll para contarlas.
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.6,
            children: [
              for (final line in order.garments) _GarmentTile(line: line),
            ],
          ),
          if (missing > 0) ...[
            const SizedBox(height: 9),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 15, color: AppColors.errorText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Faltaron $missing ${missing == 1 ? 'pieza' : 'piezas'} al entregar',
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF912018),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GarmentTile extends StatelessWidget {
  const _GarmentTile({required this.line});

  final OrderGarmentLine line;

  @override
  Widget build(BuildContext context) {
    // La diferencia entre lo recibido y lo entregado se pinta en rojo: es la
    // única cifra de esta pantalla que alguien va a tener que explicar.
    final short = line.isShort;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: short ? AppColors.errorBg : AppColors.gray50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: short ? const Color(0xFFFECDCA) : AppColors.gray100),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: short ? const Color(0xFFFECDCA) : AppColors.primary100,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              _garmentIcon(line.name),
              size: 17,
              color: short ? AppColors.errorText : AppColors.primary600,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  line.quantityDelivered == null
                      ? '${line.quantity}'
                      : '${line.quantity}/${line.quantityDelivered}',
                  style: AppTypography.money(
                    fontSize: 16,
                    color: short ? AppColors.errorText : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  line.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.helper.copyWith(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyCard extends StatelessWidget {
  const _MoneyCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'Cargos y descuentos',
      accent: AppColors.secondary500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final charge in order.charges)
            _ChargeRow(
              icon: _serviceIcon(charge.description),
              label: charge.description,
              detail: charge.quantity == 100
                  ? null
                  : '${Fixed2.format(charge.quantity)} × Q${Fixed2.format(charge.unitPrice)}',
              amount: charge.amount,
            ),
          const _DashedDivider(),
          _TotalRow(label: 'Subtotal', amount: order.subtotal),
          for (final discount in order.discounts)
            _TotalRow(
              label: discount.description,
              amount: -discount.amount,
              highlight: true,
            ),
          const SizedBox(height: 3),
          _TotalRow(label: 'TOTAL', amount: order.total, strong: true),
        ],
      ),
    );
  }
}

class _ChargeRow extends StatelessWidget {
  const _ChargeRow({
    required this.icon,
    required this.label,
    required this.amount,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.secondary100,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, size: 17, color: AppColors.secondary700),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray800,
                  ),
                ),
                if (detail != null)
                  Text(
                    detail!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.helper.copyWith(fontSize: 10.5),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          AppMoneyText(Fixed2.toDouble(amount), size: AppMoneySize.md),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3, bottom: 11),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dash = 4.0;
          const gap = 4.0;
          final count = (constraints.maxWidth / (dash + gap)).floor();
          return Row(
            children: [
              for (var index = 0; index < count; index++)
                Container(
                  width: dash,
                  height: 1,
                  margin: const EdgeInsets.only(right: gap),
                  color: AppColors.border,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
    required this.label,
    required this.amount,
    this.strong = false,
    this.highlight = false,
  });

  final String label;
  final int amount;
  final bool strong;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? AppColors.primary700 : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: strong
                  ? AppTypography.money(fontSize: 12, color: AppColors.gray500)
                      .copyWith(letterSpacing: 0.5)
                  : AppTypography.bodySm.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color ?? AppColors.gray500,
                    ),
            ),
          ),
          const SizedBox(width: 10),
          AppMoneyText(
            Fixed2.toDouble(amount),
            size: strong ? AppMoneySize.hero : AppMoneySize.sm,
            color: color,
          ),
        ],
      ),
    );
  }
}

class _PaymentsCard extends StatelessWidget {
  const _PaymentsCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final settled = order.balance <= 0;

    return _Card(
      title: 'Pagos',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (order.payments.isEmpty)
            Text(
              'Todavía no se ha cobrado nada.',
              style: AppTypography.helper.copyWith(fontSize: 12),
            ),
          for (final payment in order.payments) _PaymentRow(payment: payment),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: settled ? AppColors.successBg : AppColors.errorBg,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Text(
                  settled ? 'Pagado por completo' : 'Saldo pendiente',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: settled ? AppColors.successText : const Color(0xFF912018),
                  ),
                ),
                const Spacer(),
                AppMoneyText(
                  Fixed2.toDouble(order.balance < 0 ? 0 : order.balance),
                  size: AppMoneySize.lg,
                  color: settled ? AppColors.successText : const Color(0xFF912018),
                  decimalColor: settled ? AppColors.success : AppColors.error,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment});

  final OrderPaymentLine payment;

  @override
  Widget build(BuildContext context) {
    final transfer = payment.method == PaymentMethod.transfer;
    final label = payment.isAdvance
        ? 'Anticipo · ${(payment.method?.label ?? 'otro método').toLowerCase()}'
        : payment.method?.label ?? 'Pago';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.gray50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: transfer ? AppColors.primary100 : AppColors.successBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                transfer ? Icons.swap_horiz_rounded : Icons.payments_rounded,
                size: 17,
                color: transfer ? AppColors.primary700 : AppColors.successText,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray800,
                          ),
                        ),
                      ),
                      if (payment.isPending) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.schedule_rounded,
                          size: 12,
                          color: AppColors.warningText,
                        ),
                      ],
                    ],
                  ),
                  Text(
                    _paidAtLabel(payment),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.helper.copyWith(fontSize: 10.5),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            AppMoneyText(
              Fixed2.toDouble(payment.amount),
              size: AppMoneySize.md,
              color: AppColors.successText,
              decimalColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  static String _paidAtLabel(OrderPaymentLine payment) {
    final at = payment.paidAt.toLocal();
    final day = '${at.day.toString().padLeft(2, '0')}/${at.month.toString().padLeft(2, '0')}';
    final reference = payment.reference;
    final stamp = '$day · ${_hhmm(at)}';
    return reference == null ? stamp : '$stamp · $reference';
  }
}

/// Observaciones y bitácora.
class _AuditCard extends StatelessWidget {
  const _AuditCard({required this.order});

  final OrderDetail order;

  @override
  Widget build(BuildContext context) {
    final entries = <(IconData, Color, Color, String, DateTime)>[
      if (order.createdAt != null)
        (
          Icons.inbox_rounded,
          AppColors.secondary700,
          AppColors.secondary100,
          'Recibido',
          order.createdAt!,
        ),
      if (order.deliveredAt != null)
        (
          Icons.shopping_bag_rounded,
          AppColors.primary700,
          AppColors.primary100,
          'Entregado',
          order.deliveredAt!,
        ),
      if (order.cancelledAt != null)
        (
          Icons.cancel_outlined,
          AppColors.errorText,
          AppColors.errorBg,
          'Anulado',
          order.cancelledAt!,
        ),
    ];

    if (entries.isEmpty && order.observations == null) return const SizedBox.shrink();

    return _Card(
      title: 'Observaciones y bitácora',
      accent: AppColors.secondary500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (order.observations != null)
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.secondary50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.observations!,
                style: AppTypography.bodySm.copyWith(
                  fontSize: 12.5,
                  height: 1.5,
                  color: AppColors.gray800,
                ),
              ),
            ),
          for (final (icon, color, background, label, moment) in entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(color: background, shape: BoxShape.circle),
                    child: Icon(icon, size: 15, color: color),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray800,
                          ),
                        ),
                        Text(
                          _moment(moment),
                          style: AppTypography.helper.copyWith(fontSize: 10.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          // Quién hizo cada cosa se guarda, pero no se puede mostrar: los
          // usuarios no viajan por el feed, así que el dispositivo solo tiene
          // ids. Aparecerá cuando `identity` entre al feed. Tampoco hay marca de
          // cuándo pasó a proceso o a listo: el servidor guarda el estado, no su
          // historia, así que la bitácora tiene los tres hechos que sí existen.
        ],
      ),
    );
  }

  static String _moment(DateTime value) {
    final at = value.toLocal();
    final day = '${at.day.toString().padLeft(2, '0')}/${at.month.toString().padLeft(2, '0')}';
    return '$day a las ${_hhmm(at)}';
  }
}

/// Corregir, anular y deshacer un paso: lo que no mueve el pedido hacia
/// adelante vive aquí y no en la barra de abajo, para que la acción principal
/// no compita con la de arreglar un error.
String _forwardLabel(OrderStatus next) => switch (next) {
  OrderStatus.inProgress => 'Pasar a proceso',
  OrderStatus.ready => 'Marcar listo',
  // Entregar y anular no llegan por aquí: tienen su propia pantalla.
  _ => 'Marcar ${next.label.toLowerCase()}',
};

class _SecondaryActions extends StatelessWidget {
  const _SecondaryActions({
    required this.order,
    required this.locks,
    required this.busy,
    required this.onAdvance,
    required this.onCancel,
  });

  final OrderDetail order;
  final _Locks locks;
  final bool busy;
  final void Function(OrderStatus) onAdvance;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    if (status == null) return const SizedBox.shrink();

    final back = status.backStep;
    // El paso hacia adelante de la cadena (§7.1). Vive acá abajo y no en la
    // barra de acciones porque es opcional: sirve para saber qué hay en lavado,
    // y entregar no lo exige. Va sin candado de fecha, igual que el de volver
    // atrás: mover la ropa por el taller no mueve el dinero de ningún día.
    final forward = status.forwardStep;
    // Corregir la boleta (§7.3). Un pedido `listo` pide además el permiso de
    // admin, y por eso son dos puertas y no una: el colaborador ve el botón
    // mientras el pedido está en el local, y deja de verlo cuando ya se lavó.
    final canEdit = status.canBeEdited && !locks.orderDay;
    final canCancel = status.canBeCancelled && !locks.orderDay;

    if (!canEdit && !canCancel && back == null && forward == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canEdit || canCancel)
          Row(
            children: [
              if (canEdit)
                Expanded(
                  child: PermissionGate(
                    anyOf: status.needsAdminToEdit
                        ? const [AppPermissions.ordersUpdateReady]
                        : const [AppPermissions.ordersUpdate],
                    child: _QuietButton(
                      label: 'Editar',
                      icon: Icons.edit_outlined,
                      iconColor: AppColors.secondary700,
                      onPressed: busy
                          ? null
                          : () => context.push('${OrdersScreen.path}/${order.id}/edit'),
                    ),
                  ),
                ),
              if (canEdit && canCancel) const SizedBox(width: 8),
              if (canCancel)
                Expanded(
                  child: PermissionGate(
                    anyOf: const [AppPermissions.ordersCancel],
                    child: _QuietButton(
                      label: 'Anular',
                      icon: Icons.cancel_outlined,
                      iconColor: AppColors.errorText,
                      foreground: AppColors.errorText,
                      border: const Color(0xFFFECDCA),
                      onPressed: busy ? null : onCancel,
                    ),
                  ),
                ),
            ],
          ),
        if (forward != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: PermissionGate(
              anyOf: const [AppPermissions.ordersUpdate],
              child: _QuietButton(
                label: _forwardLabel(forward),
                icon: Icons.local_laundry_service_outlined,
                iconColor: AppColors.secondary700,
                onPressed: busy ? null : () => onAdvance(forward),
              ),
            ),
          ),
        if (back != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: PermissionGate(
              anyOf: const [AppPermissions.ordersUpdate],
              child: AppButton(
                label: 'Regresar a ${back.label.toLowerCase()}',
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.sm,
                icon: const Icon(Icons.undo_rounded),
                fullWidth: true,
                onPressed: busy ? null : () => onAdvance(back),
              ),
            ),
          ),
      ],
    );
  }
}

/// Botón de contorno gris: el de las acciones que no son la principal.
///
/// No es `AppButtonVariant.outline` porque ese lleva el contorno magenta de la
/// marca, y puesto junto al botón primario de abajo compite con él.
class _QuietButton extends StatelessWidget {
  const _QuietButton({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onPressed,
    this.foreground = AppColors.gray800,
    this.border = AppColors.border,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final Color foreground;
  final Color border;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Material(
      color: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: enabled ? border : AppColors.border, width: 1.5),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: enabled ? iconColor : AppColors.gray300),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.button(
                    fontSize: 13,
                    color: enabled ? foreground : AppColors.gray400,
                  ).copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Saldo y acción principal, fijos abajo.
///
/// El saldo se repite aquí a propósito: es la cifra que se dice en el mostrador
/// justo antes de tocar el botón, y tenerla que buscar con el scroll es cómo se
/// entrega un pedido sin cobrarlo.
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.order,
    required this.busy,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onCollect,
  });

  final OrderDetail order;
  final bool busy;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onCollect;

  @override
  Widget build(BuildContext context) {
    final settled = order.balance <= 0;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 11, 14, 14),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: Color(0x14000000), blurRadius: 18, offset: Offset(0, -6)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                settled ? 'Pagado por completo' : 'Saldo pendiente',
                style: AppTypography.helper.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray500,
                ),
              ),
              const Spacer(),
              AppMoneyText(
                Fixed2.toDouble(order.balance < 0 ? 0 : order.balance),
                size: AppMoneySize.lg,
                color: settled ? AppColors.successText : const Color(0xFF912018),
                decimalColor: settled ? AppColors.success : AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              if (onCollect != null) ...[
                AppButton(
                  label: 'Cobrar',
                  variant: AppButtonVariant.outline,
                  icon: const Icon(Icons.credit_card_rounded),
                  onPressed: busy ? null : onCollect,
                ),
                const SizedBox(width: 8),
              ],
              if (primaryLabel != null)
                Expanded(
                  child: AppButton(
                    label: primaryLabel!,
                    size: AppButtonSize.lg,
                    trailingIcon: const Icon(Icons.arrow_forward_rounded),
                    fullWidth: true,
                    elevated: true,
                    loading: busy,
                    onPressed: busy ? null : onPrimary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({
    required this.child,
    this.title,
    this.trailing,
    this.accent = AppColors.primary500,
  });

  final String? title;
  final Widget? trailing;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            AppSectionHeader(title: title!, accentColor: accent, trailing: trailing),
          child,
        ],
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.message, this.isError = false});

  final IconData icon;
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final foreground = isError ? AppColors.errorText : AppColors.warningText;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isError ? AppColors.errorBg : AppColors.warningBg,
        borderRadius: AppRadius.mdAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySm.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _hhmm(DateTime at) =>
    '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

/// Icono de una prenda, leído de su nombre.
///
/// El catálogo no guarda iconos —los tipos de prenda los da de alta un admin y
/// solo tienen nombre—, así que esto es una lectura del texto con una prenda
/// genérica de respaldo. Es decoración: si acierta ayuda a distinguir las filas
/// de un vistazo, y si no acierta no cambia ninguna cifra.
IconData _garmentIcon(String name) {
  final text = name.toLowerCase();
  if (text.contains('pantal') || text.contains('jean') || text.contains('short')) {
    return Icons.dry_cleaning_rounded;
  }
  if (text.contains('toalla') ||
      text.contains('sabana') ||
      text.contains('sábana') ||
      text.contains('cobij') ||
      text.contains('edred')) {
    return Icons.bed_rounded;
  }
  if (text.contains('zapat') || text.contains('tenis')) return Icons.ice_skating_rounded;
  return Icons.checkroom_rounded;
}

/// Icono de un cargo, leído de su descripción congelada. Mismo trato que
/// [_garmentIcon]: ayuda a leer, no decide nada.
IconData _serviceIcon(String description) {
  final text = description.toLowerCase();
  if (text.contains('peso') || text.contains('libra')) return Icons.scale_rounded;
  if (text.contains('tina')) return Icons.water_drop_rounded;
  if (text.contains('secado') || text.contains('secadora')) return Icons.wb_sunny_rounded;
  if (text.contains('mano') || text.contains('nivel')) return Icons.back_hand_rounded;
  if (text.contains('domicilio') || text.contains('motorista') || text.contains('entrega')) {
    return Icons.local_shipping_rounded;
  }
  if (text.contains('suavizante') || text.contains('rins') || text.contains('cloro')) {
    return Icons.opacity_rounded;
  }
  if (text.contains('planch')) return Icons.iron_rounded;
  return Icons.local_laundry_service_rounded;
}
