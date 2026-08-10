import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../../core/money/fixed2.dart';
import '../../../core/money/payment_method.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/time/business_date.dart';
import '../../auth/state/auth_controller.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../orders/models/order.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../data/deliveries_repository.dart';
import '../data/expenses_repository.dart';
import '../domain/cash_day.dart';
import '../models/cash_entry.dart';
import '../models/delivery_line.dart';
import '../models/expense.dart';
import '../state/cash_day_controller.dart';
import '../state/deliveries_controller.dart';
import '../state/ticket_lookup_controller.dart';
import 'day_close_screen.dart';
import 'supply_sale_screen.dart';
import 'widgets/delivery_batch_sheet.dart';
import 'widgets/delivery_ticket_sheet.dart';
import 'widgets/expense_sheet.dart';

/// Caja del día (Plan 0006 §7.1): la hoja de Registro Diario en pantalla.
///
/// Ingresos a un lado y gastos al otro, como el papel que reemplaza. Todo sale
/// de la BD local, así que el día se arma igual sin señal; lo que todavía no
/// subió se marca en su fila en vez de esconderse.
class CashScreen extends ConsumerStatefulWidget {
  const CashScreen({super.key});

  static const String path = '/cash';

  @override
  ConsumerState<CashScreen> createState() => _CashScreenState();
}

class _CashScreenState extends ConsumerState<CashScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final day = ref.watch(selectedCashDayProvider);
    // Las entregas se registran contra **hoy**: la ropa del lunes se devuelve el
    // miércoles y el dinero entra el miércoles (plan 0001 §7.2). Mirando un día
    // pasado la Caja es un informe, así que el bloque de captura no aparece.
    final isToday =
        isoDate(ref.watch(cashDateFilterProvider)) == isoDate(businessDate());

    return Stack(
      children: [
        Column(
          children: [
            _CashHeader(day: day),
            Expanded(
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (day.closure != null) ...[
                            _ClosedBanner(closure: day.closure!),
                            const SizedBox(height: 12),
                          ],
                          _DaySummary(day: day),
                          const SizedBox(height: 14),
                          if (!day.isClosed && isToday) ...[
                            PermissionGate(
                              anyOf: const [AppPermissions.ordersDeliver],
                              child: const _DeliveriesCard(),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _TabsHeader(
                      child: ColoredBox(
                        color: AppColors.background,
                        child: AppTabBar(
                          index: _tab,
                          onChanged: (index) => setState(() => _tab = index),
                          tabs: [
                            AppTab(
                              label: 'Ingresos',
                              count: day.incomes.length,
                              icon: Icons.arrow_upward_rounded,
                            ),
                            AppTab(
                              label: 'Gastos',
                              count: day.expenses.length,
                              icon: Icons.arrow_downward_rounded,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_tab == 0)
                    _IncomeList(entries: day.incomes)
                  else
                    _ExpenseList(day: day),
                ],
              ),
            ),
          ],
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: _CashFooter(day: day)),
      ],
    );
  }
}

/// Cabecera: el día, y el efectivo que debería estar en el cajón ahora mismo.
///
/// La cifra grande es el arqueo y no el total cobrado: lo que se compara con el
/// cajón físico es el efectivo que entró menos el que salió, y una transferencia
/// no está en ningún cajón.
class _CashHeader extends ConsumerWidget {
  const _CashHeader({required this.day});

  final CashDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(cashDateFilterProvider);
    final today = businessDate();

    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Caja del día',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ),
              _DayChip(
                date: date,
                today: today,
                onChanged: (value) =>
                    ref.read(cashDateFilterProvider.notifier).update(value),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CashOnHandCard(day: day),
        ],
      ),
    );
  }
}

class _CashOnHandCard extends StatelessWidget {
  const _CashOnHandCard({required this.day});

  final CashDay day;

  @override
  Widget build(BuildContext context) {
    final income = day.income;
    final paid = day.paidExpenses;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 14,
                color: AppColors.primary100,
              ),
              const SizedBox(width: 6),
              Text(
                'Efectivo en caja ahora',
                style: AppTypography.helper.copyWith(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          AppMoneyText(
            Fixed2.toDouble(day.cashOnHand),
            size: AppMoneySize.hero,
            color: AppColors.white,
            decimalColor: AppColors.primary100,
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0x3DFFFFFF)),
          const SizedBox(height: 10),
          Row(
            children: [
              _HeaderFigure(label: 'Entró en efectivo', amount: income.cash),
              _HeaderFigure(label: 'Salió en efectivo', amount: -paid.cash),
              _HeaderFigure(label: 'Por transferencia', amount: income.transfer),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderFigure extends StatelessWidget {
  const _HeaderFigure({required this.label, required this.amount});

  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.helper.copyWith(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary100,
            ),
          ),
          AppMoneyText(
            Fixed2.toDouble(amount),
            size: AppMoneySize.sm,
            color: AppColors.white,
            decimalColor: AppColors.primary100,
            showDecimals: false,
          ),
        ],
      ),
    );
  }
}

/// El candado del §14: la fecha ya se cerró y no admite escrituras.
class _ClosedBanner extends StatelessWidget {
  const _ClosedBanner({required this.closure});

  final DayClosure closure;

  @override
  Widget build(BuildContext context) {
    final at = closure.closedAt.toLocal();
    final time =
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.gray600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Día cerrado a las $time',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Solo lectura: para cambiar algo hay que reabrir el día',
                  style: AppTypography.helper.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Las tres cifras del §7.1 y el reparto efectivo/transferencia.
class _DaySummary extends StatelessWidget {
  const _DaySummary({required this.day});

  final CashDay day;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: AppStatTile(
                    label: 'Ingresos',
                    amount: Fixed2.toDouble(day.incomeTotal),
                    tone: AppStatTone.positive,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: AppStatTile(
                    label: 'Gastos',
                    amount: Fixed2.toDouble(day.expensesTotal),
                    tone: AppStatTone.negative,
                    compact: true,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: AppStatTile(
                    label: 'Neto',
                    amount: Fixed2.toDouble(day.netTotal),
                    tone: AppStatTone.brand,
                    compact: true,
                  ),
                ),
              ],
            ),
          ),
          if (day.pendingExpensesTotal > 0) ...[
            const SizedBox(height: 10),
            _PendingNote(amount: day.pendingExpensesTotal),
          ],
        ],
      ),
    );
  }
}

/// La diferencia entre lo que el día debe y lo que salió del cajón. Es la
/// advertencia del cierre, dicha antes de llegar a él.
class _PendingNote extends StatelessWidget {
  const _PendingNote({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.schedule_rounded, size: 14, color: AppColors.warningText),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            'Q${Fixed2.format(amount)} en gastos pendientes: cuentan en el día, '
            'pero todavía no salieron del cajón.',
            style: AppTypography.helper.copyWith(
              fontSize: 11.5,
              color: AppColors.warningText,
            ),
          ),
        ),
      ],
    );
  }
}

/// Entregas y cobros: donde se registra el ingreso (plan 0006 §7.1.1).
///
/// El mostrador no marca «en proceso» ni «listo» ni entra pedido por pedido: al
/// cierre dice "de las que tenía, entregué estas" y anota boleta, cliente y
/// cuánto pagó. Eso es a la vez la entrega y el ingreso, y por eso vive acá y no
/// en Pedidos — el lado de ingresos de la hoja es lo que la persona escribe.
class _DeliveriesCard extends ConsumerStatefulWidget {
  const _DeliveriesCard();

  @override
  ConsumerState<_DeliveriesCard> createState() => _DeliveriesCardState();
}

class _DeliveriesCardState extends ConsumerState<_DeliveriesCard> {
  /// Cuántas boletas se ven antes de "ver todas". Cuatro caben sin empujar el
  /// resto de la Caja fuera de la pantalla.
  static const int _preview = 4;

  /// Propio y no del campo, para que el escáner pueda dejar escrito lo que leyó
  /// cuando no encontró la boleta.
  final TextEditingController _search = TextEditingController();

  bool _showAll = false;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Qué se dice después de escanear. Cada final tiene su frase porque cada uno
  /// pide algo distinto de quien está en el mostrador.
  void _sayOutcome(TicketLookupOutcome outcome) {
    final message = switch (outcome) {
      TicketLookupCancelled() => null,
      TicketMarked(:final order, wasAlreadyMarked: true) =>
        'La ${order.reference} ya estaba marcada.',
      TicketMarked(:final order) =>
        'Marcada la ${order.reference} · ${order.customerName}',
      TicketAlreadyClosed(:final match) =>
        'La boleta ${orderReference(match.dailyNumber)} ya no está abierta: '
            'se entregó o se anuló.',
      TicketNotMirrored(:final match) =>
        'La boleta ${orderReference(match.dailyNumber)} existe pero este '
            'teléfono aún no la tiene. Sincroniza y volvé a intentar.',
      TicketAmbiguous(:final matches) =>
        'El serial y el número apuntan a boletas distintas '
            '(${matches.map((m) => orderReference(m.dailyNumber)).join(' y ')}). '
            'Buscala a mano.',
      TicketNotFound(wasUnreadable: true) =>
        'No se pudo leer el número de la boleta. Escribilo en el buscador.',
      TicketNotFound(:final read) =>
        'Leyó «$read» y no hay ninguna boleta abierta con ese número. '
            'Corregilo en el buscador.',
      TicketLookupFailed(:final failure) => failure.message,
    };
    if (message == null || !mounted) return;
    _say(context, message);
  }

  Future<void> _register() async {
    final outcome = await DeliveryBatchSheet.show(context);
    if (outcome == null || !mounted) return;

    final entregadas = outcome.delivered == 1
        ? '1 boleta entregada'
        : '${outcome.delivered} boletas entregadas';
    _say(
      context,
      outcome.isClean
          ? '$entregadas · +Q${Fixed2.format(outcome.collected)} en caja'
          : '$entregadas. No se pudo con ${outcome.failures.length}: '
                '${outcome.failures.first}',
    );
  }

  /// Entrega **una** boleta, que es lo que pasa cuando el cliente está enfrente:
  /// se abre su hoja, se dice cuánto y cómo pagó, y sale del listado.
  ///
  /// El lote sigue existiendo para el repaso del cierre; esto es el camino
  /// ordinario, y por eso es lo que hace tocar la fila.
  Future<void> _deliverOne(OrderListItem order) async {
    final line = await DeliveryTicketSheet.show(context, order);
    if (line == null || !mounted) return;

    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null) return;

    final outcome = await ref
        .read(deliveriesRepositoryProvider)
        .deliverAll([line], actorId: user.id);
    if (!mounted) return;

    // Lo que salió se desmarca: pudo estar marcada de antes —la escaneó alguien
    // barriendo la pila— y una boleta ya entregada no puede seguir contando en
    // el lote.
    ref.read(deliverySelectionProvider.notifier).forget(outcome.deliveredIds);

    if (!outcome.isClean) {
      _say(context, outcome.failures.first);
      return;
    }
    // Lo que entró y lo que quedó a deber se dicen los dos: el saldo que queda
    // abierto es lo que alguien va a tener que cobrar otro día.
    _say(
      context,
      [
        'Entregada la ${line.label}',
        if (outcome.collected > 0) '+Q${Fixed2.format(outcome.collected)} en caja',
        if (line.isPartial) 'queda debiendo Q${Fixed2.format(line.pending)}',
      ].join(' · '),
    );
  }

  @override
  Widget build(BuildContext context) {
    final open = ref.watch(openOrdersProvider).valueOrNull ?? const <OrderListItem>[];
    final matches = ref.watch(deliverableOrdersProvider);
    final selection = ref.watch(deliverySelectionProvider);
    final batch = ref.watch(deliveryBatchProvider);
    final searching = ref.watch(deliverySearchQueryProvider).trim().isNotEmpty;

    // El campo es un espejo del filtro y no su dueño: así lo que el escáner
    // dejó escrito se ve, en vez de filtrar la lista por algo que la caja de
    // texto no muestra.
    ref.listen(deliverySearchQueryProvider, (_, next) {
      if (_search.text != next) _search.text = next;
    });

    final visible = _showAll || matches.length <= _preview
        ? matches
        : matches.take(_preview).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppSectionHeader(
          title: 'ENTREGAS Y COBROS',
          trailing: open.isEmpty
              ? null
              : Text(
                  open.length == 1 ? '1 sin entregar' : '${open.length} sin entregar',
                  style: AppTypography.helper.copyWith(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                  ),
                ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(13, 13, 13, 13),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.card,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: AppSearchField(
                      key: const ValueKey('delivery-search'),
                      controller: _search,
                      hintText: 'No. de boleta o cliente',
                      backgroundColor: AppColors.gray50,
                      onChanged: (value) =>
                          ref.read(deliverySearchQueryProvider.notifier).update(value),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _ScanTicketButton(onDone: _sayOutcome),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Tocá la boleta para entregarla y cobrarla. La casilla es para el '
                'repaso del cierre: marcá varias y registralas juntas.',
                style: AppTypography.helper.copyWith(fontSize: 11.5),
              ),
              if (open.isEmpty)
                const _DeliveriesNote(
                  icon: Icons.check_circle_outline_rounded,
                  message: 'No queda ropa pendiente de entregar.',
                )
              else if (visible.isEmpty)
                const _DeliveriesNote(
                  icon: Icons.search_off_rounded,
                  message: 'Ninguna boleta abierta con ese número ni ese nombre.',
                )
              else ...[
                const Divider(height: 18),
                for (final order in visible)
                  _OpenOrderRow(
                    order: order,
                    marked: selection.containsKey(order.id),
                    onTap: () => _deliverOne(order),
                    onMark: () =>
                        ref.read(deliverySelectionProvider.notifier).toggle(order),
                  ),
                if (!_showAll && matches.length > _preview)
                  GestureDetector(
                    onTap: () => setState(() => _showAll = true),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        searching
                            ? 'Ver las ${matches.length} que coinciden'
                            : 'Ver las ${matches.length} pendientes',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodySm.copyWith(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
              ],
              if (!batch.isEmpty) ...[
                const SizedBox(height: 11),
                _SelectionBar(batch: batch, onRegister: _register),
              ] else if (open.isNotEmpty) ...[
                const SizedBox(height: 11),
                const _DeliveriesNote(
                  icon: Icons.info_outline_rounded,
                  message: 'Las que no marques siguen abiertas mañana, con su saldo.',
                  inset: false,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Escanear la boleta para marcarla, al lado del buscador (§7.1.1).
///
/// El acelerador y no el camino: teclear el número funciona siempre y contra la
/// BD local, esto necesita señal porque la foto la lee un modelo que vive del
/// otro lado (plan 0003 D8). Sin conexión se muestra apagado y lo dice al
/// tocarlo, como el chip de la toma de pedido — esconderlo dejaría a quien lo
/// busca creyendo que la app lo perdió.
class _ScanTicketButton extends ConsumerWidget {
  const _ScanTicketButton({required this.onDone});

  final ValueChanged<TicketLookupOutcome> onDone;

  Future<void> _scan(BuildContext context, WidgetRef ref) async {
    // Cámara y no galería: acá la boleta está en la mano. La galería es del
    // otro escaneo, donde llegan fotos por WhatsApp.
    final outcome = await ref
        .read(ticketLookupControllerProvider.notifier)
        .scan(AppImageSource.camera);
    onDone(outcome);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final online = ref.watch(connectivityChangesProvider).valueOrNull ?? true;
    final busy = ref.watch(ticketLookupControllerProvider);
    final radius = BorderRadius.circular(14);

    return Material(
      color: online ? AppColors.secondary50 : AppColors.gray100,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: busy
            ? null
            : () {
                if (!online) {
                  _say(
                    context,
                    'Escanear necesita señal. Buscá la boleta por su número.',
                  );
                  return;
                }
                _scan(context, ref);
              },
        child: SizedBox(
          width: 46,
          height: 44,
          child: Center(
            child: busy
                ? const SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Icon(
                    Icons.document_scanner_outlined,
                    size: 19,
                    color: online ? AppColors.secondary700 : AppColors.gray400,
                  ),
          ),
        ),
      ),
    );
  }
}

/// Una boleta abierta, con dos toques distintos a propósito.
///
/// La fila entera **entrega**: es el gesto de todos los días, con el cliente
/// enfrente pidiendo su ropa. La casilla solo **marca** para el repaso en lote
/// del cierre. Son dos cosas y por eso son dos blancos: tocar una boleta y que
/// se marque en silencio es cómo alguien se va creyendo que ya la entregó.
class _OpenOrderRow extends StatelessWidget {
  const _OpenOrderRow({
    required this.order,
    required this.marked,
    required this.onTap,
    required this.onMark,
  });

  final OrderListItem order;
  final bool marked;

  /// Abre la hoja de la boleta: entregar y cobrar.
  final VoidCallback onTap;

  /// Marca o desmarca para el lote.
  final VoidCallback onMark;

  @override
  Widget build(BuildContext context) {
    // La serie de imprenta es como la llama el mostrador; el correlativo es el
    // último recurso, para una boleta sin serie o que todavía no subió.
    final label = order.bookletSerial ?? order.reference;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            // El blanco de la casilla es más grande que la casilla: 24 px de
            // borde a borde son la mitad de lo que necesita un pulgar, y fallarlo
            // acabaría abriendo la hoja de entrega.
            InkWell(
              key: ValueKey('mark-${order.id}'),
              onTap: onMark,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: marked ? AppColors.primary : AppColors.white,
                    border: Border.all(
                      color: marked ? AppColors.primary : AppColors.gray300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: marked
                      ? const Icon(Icons.check_rounded, size: 15, color: AppColors.white)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 5),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gray100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          label,
                          style: AppTypography.helper.copyWith(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          order.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySm.copyWith(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      '${order.totalPieces} ${order.totalPieces == 1 ? 'pieza' : 'piezas'}',
                      if (order.paid > 0) 'anticipo Q${Fixed2.format(order.paid)}',
                    ].join(' · '),
                    style: AppTypography.helper.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                AppMoneyText(order.balanceAsDouble, size: AppMoneySize.md),
                Text(
                  'saldo',
                  style: AppTypography.helper.copyWith(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Lo marcado, con el botón que abre el repaso.
class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.batch, required this.onRegister});

  final DeliveryBatch batch;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.primary50,
        border: Border.all(color: AppColors.primary100),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.count == 1
                      ? '1 boleta marcada · Q${Fixed2.format(batch.balance)}'
                      : '${batch.count} boletas marcadas · Q${Fixed2.format(batch.balance)}',
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary700,
                  ),
                ),
                Text(
                  'por cobrar al entregarlas',
                  style: AppTypography.helper.copyWith(
                    fontSize: 10.5,
                    color: AppColors.primary700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 9),
          AppButton(
            label: 'Registrar',
            elevated: true,
            size: AppButtonSize.sm,
            onPressed: onRegister,
          ),
        ],
      ),
    );
  }
}

class _DeliveriesNote extends StatelessWidget {
  const _DeliveriesNote({
    required this.icon,
    required this.message,
    this.inset = true,
  });

  final IconData icon;
  final String message;

  /// Con separación propia cuando reemplaza a la lista; sin ella cuando ya va
  /// dentro de una fila con su espacio.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: inset ? 12 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.helper.copyWith(fontSize: 11.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Mantiene las pestañas pegadas arriba mientras la lista se desplaza: la
/// pregunta "¿estoy viendo ingresos o gastos?" no se puede perder de vista.
class _TabsHeader extends SliverPersistentHeaderDelegate {
  const _TabsHeader({required this.child});

  final Widget child;

  static const double _height = 46;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: _height, child: child);
  }

  @override
  bool shouldRebuild(_TabsHeader oldDelegate) => oldDelegate.child != child;
}

class _IncomeList extends StatelessWidget {
  const _IncomeList({required this.entries});

  final List<CashEntry> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 200),
          child: AppEmptyState(
            icon: Icons.savings_outlined,
            title: 'Todavía no entra nada',
            message: 'Los cobros de pedidos y las ventas de insumo aparecen acá.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
      sliver: SliverList.separated(
        itemCount: entries.length,
        separatorBuilder: (context, index) => const SizedBox(height: 9),
        itemBuilder: (context, index) => _IncomeCard(entry: entries[index]),
      ),
    );
  }
}

class _IncomeCard extends StatelessWidget {
  const _IncomeCard({required this.entry});

  final CashEntry entry;

  @override
  Widget build(BuildContext context) {
    final isSale = entry.kind == CashEntryKind.supplySale;
    final at = entry.at?.toLocal();
    final subtitle = [
      if (at != null)
        '${at.hour.toString().padLeft(2, '0')}:${at.minute.toString().padLeft(2, '0')}',
      entry.method?.label.toLowerCase() ?? 'método desconocido',
      if (entry.subtitle != null) entry.subtitle!,
    ].join(' · ');

    return AppListCard(
      title: entry.title,
      subtitle: subtitle,
      onTap: entry.route == null ? null : () => context.push(entry.route!),
      leading: AppListCardTile(
        icon: isSale ? Icons.local_mall_outlined : Icons.arrow_upward_rounded,
        background: isSale ? AppColors.secondary100 : AppColors.successBg,
        foreground: isSale ? AppColors.secondary700 : AppColors.successText,
      ),
      titleSuffix: entry.needsReview
          ? const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.errorText)
          : entry.pendingSync
          ? const Icon(Icons.schedule_rounded, size: 13, color: AppColors.warningText)
          : null,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppMoneyText(
            Fixed2.toDouble(entry.amount),
            size: AppMoneySize.md,
            color: AppColors.successText,
          ),
          if (isSale) ...[
            const SizedBox(height: 4),
            const AppStatusBadge(
              label: 'Insumo',
              tone: AppStatusTone.info,
              size: AppStatusBadgeSize.sm,
            ),
          ] else if (entry.method == PaymentMethod.transfer) ...[
            const SizedBox(height: 4),
            const AppStatusBadge(
              label: 'Transferencia',
              tone: AppStatusTone.brand,
              size: AppStatusBadgeSize.sm,
            ),
          ],
        ],
      ),
    );
  }
}

class _ExpenseList extends ConsumerWidget {
  const _ExpenseList({required this.day});

  final CashDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (day.expenses.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 200),
          child: AppEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'Ningún gasto este día',
            message: 'Lo que salga de la caja se anota con el botón de abajo.',
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 200),
      sliver: SliverList.separated(
        itemCount: day.expenses.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 9),
        itemBuilder: (context, index) => index == day.expenses.length
            ? _ExpensesTotal(amount: day.expensesTotal)
            : _ExpenseCard(expense: day.expenses[index], locked: day.isClosed),
      ),
    );
  }
}

class _ExpenseCard extends ConsumerWidget {
  const _ExpenseCard({required this.expense, required this.locked});

  final Expense expense;
  final bool locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canEdit = !locked && !expense.isLinked;

    return AppListCard(
      title: expense.concept,
      subtitle: [
        expense.categoryName,
        expense.method?.label.toLowerCase() ?? 'método desconocido',
      ].join(' · '),
      onTap: canEdit ? () => _edit(context, ref) : null,
      leading: AppListCardTile(
        icon: Icons.arrow_downward_rounded,
        background: AppColors.errorBg,
        foreground: AppColors.errorText,
      ),
      titleSuffix: expense.needsReview
          ? const Icon(Icons.error_outline_rounded, size: 14, color: AppColors.errorText)
          : expense.pendingSync
          ? const Icon(Icons.schedule_rounded, size: 13, color: AppColors.warningText)
          : null,
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          AppMoneyText(
            Fixed2.toDouble(expense.amount),
            size: AppMoneySize.md,
            color: AppColors.errorText,
          ),
          if (expense.isPending) ...[
            const SizedBox(height: 4),
            const AppStatusBadge(
              label: 'Pendiente',
              tone: AppStatusTone.warning,
              size: AppStatusBadgeSize.sm,
            ),
          ],
        ],
      ),
    );
  }

  /// Corregir exige `expenses.update`, que el colaborador no tiene (§13). Se
  /// comprueba aquí y no escondiendo la tarjeta: el gasto se tiene que ver
  /// igual, lo que cambia es si se puede tocar.
  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authControllerProvider).valueOrNull;
    if (user == null || !user.hasPermission(AppPermissions.expensesUpdate)) {
      _say(context, 'Corregir un gasto es cosa de un administrador');
      return;
    }

    final categories =
        ref.read(cashExpensesCategoriesProvider).valueOrNull ?? const <ExpenseCategory>[];
    final draft = await ExpenseSheet.show(
      context,
      categories: categories,
      date: ref.read(cashDateFilterProvider),
      initial: expense,
    );
    if (draft == null || !context.mounted) return;

    final result = await ref.read(expensesRepositoryProvider).update(expense, draft);
    if (!context.mounted) return;
    result.match(
      (failure) => _say(context, failure.message),
      (_) => _say(context, 'Gasto corregido'),
    );
  }
}

class _ExpensesTotal extends StatelessWidget {
  const _ExpensesTotal({required this.amount});

  final int amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Text(
            'Total de gastos',
            style: AppTypography.bodySm.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          AppMoneyText(Fixed2.toDouble(amount), size: AppMoneySize.lg),
        ],
      ),
    );
  }
}

/// Las acciones del mostrador, fijas sobre la barra inferior.
///
/// «Cerrar día» va arriba y en una fila propia, no como tercer botón: las dos de
/// abajo se tocan decenas de veces al día y esta una sola vez, al final, y
/// ponerlas del mismo tamaño invitaría a cerrar el día con un pulgar distraído.
class _CashFooter extends ConsumerWidget {
  const _CashFooter({required this.day});

  final CashDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = ref.watch(cashDateFilterProvider);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PermissionGate(
            anyOf: const [AppPermissions.dailyCloseRead],
            child: Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: _CloseDayRow(
                closed: day.isClosed,
                onTap: () => context.push('${DayCloseScreen.path}?date=${isoDate(date)}'),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: PermissionGate(
                  anyOf: const [AppPermissions.expensesCreate],
                  child: AppButton(
                    label: 'Gasto',
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    variant: AppButtonVariant.outline,
                    fullWidth: true,
                    onPressed: day.isClosed ? null : () => _addExpense(context, ref),
                  ),
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: PermissionGate(
                  anyOf: const [AppPermissions.supplySalesCreate],
                  child: AppButton(
                    label: 'Venta',
                    icon: const Icon(Icons.local_mall_outlined),
                    fullWidth: true,
                    elevated: true,
                    onPressed: day.isClosed
                        ? null
                        : () => context.push(SupplySaleScreen.path),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _addExpense(BuildContext context, WidgetRef ref) async {
    final user = ref.read(authControllerProvider).valueOrNull;
    final categories =
        ref.read(cashExpensesCategoriesProvider).valueOrNull ?? const <ExpenseCategory>[];

    final draft = await ExpenseSheet.show(
      context,
      categories: categories,
      date: ref.read(cashDateFilterProvider),
    );
    if (draft == null || user == null || !context.mounted) return;

    final result = await ref
        .read(expensesRepositoryProvider)
        .create(draft, createdById: user.id);
    if (!context.mounted) return;
    result.match(
      (failure) => _say(context, failure.message),
      (expense) => _say(context, 'Gasto de Q${Fixed2.format(expense.amount)} registrado'),
    );
  }
}

/// La entrada al acta del día (§7.4). Dice qué va a encontrar quien la toque:
/// un día abierto lleva al cierre, uno cerrado al acta que ya se firmó.
class _CloseDayRow extends StatelessWidget {
  const _CloseDayRow({required this.closed, required this.onTap});

  final bool closed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: closed ? AppColors.gray100 : AppColors.primary50,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          child: Row(
            children: [
              Icon(
                closed ? Icons.lock_outline_rounded : Icons.event_available_outlined,
                size: 17,
                color: closed ? AppColors.gray600 : AppColors.primary700,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  closed ? 'Ver el acta del día' : 'Cerrar día',
                  style: AppTypography.button(
                    fontSize: 13.5,
                    color: closed ? AppColors.gray600 : AppColors.primary700,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: closed ? AppColors.gray600 : AppColors.primary700,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip de fecha con calendario, igual que en la lista de pedidos: la pregunta
/// "¿de qué día?" precede a todas las demás.
class _DayChip extends StatelessWidget {
  const _DayChip({required this.date, required this.today, required this.onChanged});

  final DateTime date;
  final DateTime today;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.18),
      borderRadius: AppRadius.fullAll,
      child: InkWell(
        borderRadius: AppRadius.fullAll,
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(today.year - 1),
            lastDate: today,
            helpText: 'Día de la caja',
            cancelText: 'Cancelar',
            confirmText: 'Ver',
          );
          if (picked != null) onChanged(picked);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.white),
              const SizedBox(width: 7),
              Text(
                formatBusinessDate(date, today: today),
                style: AppTypography.bodySm.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void _say(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
