import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/app_permissions.dart';
import '../../auth/ui/widgets/permission_gate.dart';
import '../../shell/ui/widgets/gradient_header.dart';
import '../models/review_item.dart';
import '../models/review_subject.dart';
import '../state/review_queue_controller.dart';
import 'review_queue_screen.dart';

/// Detalle de una entrada de la cola de revisión (Plan 0006 §11.2).
///
/// Muestra las dos versiones —lo que se capturó aquí y lo que hay ahora— y
/// ofrece las acciones concretas del §8 del Plan 0004. Ninguna acción adivina:
/// las que existen son las que el servidor puede aceptar.
class ReviewDetailScreen extends ConsumerWidget {
  const ReviewDetailScreen({super.key, required this.opId});

  static const String path = '/sync/review/:opId';

  final String opId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(reviewEntryProvider(opId));
    final item = entry.valueOrNull;
    final subject = ref.watch(reviewSubjectProvider(opId)).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          _Header(item: item),
          Expanded(
            child: item == null
                // Sin la entrada cargada todavía no se sabe si desapareció o si
                // la consulta va en camino; anunciar "ya está resuelta" sería
                // inventar un final.
                ? (entry.hasValue ? const _Resolved() : const SizedBox.shrink())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      16,
                      AppSpacing.md,
                      28,
                    ),
                    children: [
                      _Explanation(item: item, subject: subject),
                      const SizedBox(height: 18),
                      const AppSectionHeader(title: 'Lo que se capturó aquí'),
                      _FactsCard(facts: item.capturedFacts),
                      const SizedBox(height: 18),
                      AppSectionHeader(
                        title: subject?.holdsTheBooklet == true
                            ? 'La boleta que ya estaba'
                            : 'Lo que hay ahora',
                        accentColor: AppColors.secondary500,
                      ),
                      _ServerCard(item: item, subject: subject),
                      const SizedBox(height: 22),
                      _Actions(item: item, subject: subject),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({this.item});

  final ReviewItem? item;

  @override
  Widget build(BuildContext context) {
    return GradientHeader(
      padding: const EdgeInsets.fromLTRB(8, 0, 18, 20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
            tooltip: 'Volver',
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item == null ? '' : reviewAge(item!.createdAt),
                  style: AppTypography.bodySm.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary100,
                  ),
                ),
                Text(
                  item?.kind.title ?? 'Revisión',
                  style: AppTypography.h3.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
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

/// Lo que se ve cuando la entrada ya se resolvió: puede haber sido en otra
/// pantalla, o en este mismo teléfono hace un segundo.
class _Resolved extends StatelessWidget {
  const _Resolved();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 28, AppSpacing.md, 28),
      children: [
        const AppEmptyState(
          icon: Icons.check_rounded,
          title: 'Ya está resuelta',
          message: 'Esta captura salió de la cola de revisión.',
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Volver a la cola',
          variant: AppButtonVariant.outline,
          fullWidth: true,
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ],
    );
  }
}

/// Qué pasó y qué se puede hacer, en el idioma del mostrador.
///
/// El texto lo escribe la app a partir de **qué operación era**, no del motivo
/// que mandó el servidor: ese llega en inglés y en prosa libre, así que se
/// muestra aparte y literal, como el dato de diagnóstico que es.
class _Explanation extends StatelessWidget {
  const _Explanation({required this.item, required this.subject});

  final ReviewItem item;
  final ReviewSubject? subject;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.errorBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECDCA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(reviewIcon(item.kind), size: 18, color: AppColors.errorText),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.subtitle,
                  style: AppTypography.bodySm.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF912018),
                  ),
                ),
              ),
              AppStatusBadge(
                label: item.outcome.label,
                tone: AppStatusTone.error,
                size: AppStatusBadgeSize.sm,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _headline(item, subject),
            style: AppTypography.bodySm.copyWith(color: const Color(0xFF912018)),
          ),
          if (item.reason case final String reason) ...[
            const SizedBox(height: 12),
            Text(
              'Lo que respondió el servidor',
              style: AppTypography.helper.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.errorText,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              reason,
              style: AppTypography.helper.copyWith(
                fontSize: 12,
                color: AppColors.errorText,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _headline(ReviewItem item, ReviewSubject? subject) {
    return switch (item.kind) {
      ReviewKind.orderCreate =>
        subject == null
            ? 'Esta boleta no quedó registrada en el servidor. Revisá si la serie '
                  'está bien escrita antes de volver a mandarla.'
            : 'Esa serie de boleta ya la tiene el ${subject.headline.toLowerCase()}. '
                  'Casi siempre es la misma boleta capturada dos veces.',
      ReviewKind.orderUpdate when item.outcome == ReviewOutcome.conflict =>
        'Alguien corrigió esta boleta mientras este teléfono estaba sin señal. Tu '
            'corrección no se aplicó: juntar dos versiones de una boleta sería '
            'adivinar cuál es la buena.',
      ReviewKind.orderUpdate =>
        'El servidor no aceptó la corrección. El pedido sigue como estaba.',
      ReviewKind.orderStatus ||
      ReviewKind.orderDeliver ||
      ReviewKind.orderCancel =>
        'Cuando esto llegó al servidor, el pedido ya no estaba como este teléfono '
            'creía. Mirá cómo está ahora antes de decidir.',
      ReviewKind.paymentCreate =>
        'El cobro no quedó registrado. El dinero está en la caja, pero el pedido '
            'todavía lo debe según el servidor.',
      ReviewKind.customerCreate =>
        'El cliente no se registró en el servidor. Solo existe en este teléfono.',
      ReviewKind.customerUpdate when item.outcome == ReviewOutcome.conflict =>
        'Otro dispositivo cambió los datos de este cliente antes que vos. Podés '
            'volver a mandar los tuyos si son los correctos.',
      ReviewKind.customerUpdate || ReviewKind.customerArchive =>
        'El servidor no aceptó el cambio sobre este cliente.',
      ReviewKind.unknown =>
        'Esta operación no se pudo aplicar y necesita una decisión.',
    };
  }
}

class _FactsCard extends StatelessWidget {
  const _FactsCard({required this.facts, this.headline});

  final List<ReviewFact> facts;
  final String? headline;

  @override
  Widget build(BuildContext context) {
    if (facts.isEmpty) {
      return _Card(
        child: Text(
          'Esta operación no lleva datos que comparar.',
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headline != null) ...[
            Text(
              headline!,
              style: AppTypography.h3.copyWith(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
          ],
          for (final fact in facts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 118,
                    child: Text(
                      fact.label,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      fact.value,
                      textAlign: TextAlign.right,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
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

/// El otro lado de la comparación. Cuando no hay nada que enseñar lo dice y
/// explica por qué, en vez de dejar un hueco que se lee como un error.
class _ServerCard extends StatelessWidget {
  const _ServerCard({required this.item, required this.subject});

  final ReviewItem item;
  final ReviewSubject? subject;

  @override
  Widget build(BuildContext context) {
    final current = subject;
    if (current == null) {
      return _Card(
        child: Text(
          switch (item.kind) {
            ReviewKind.orderCreate =>
              'Ningún pedido de este teléfono tiene esa serie de boleta. Puede '
                  'estar en otro dispositivo que todavía no sincroniza.',
            ReviewKind.customerCreate =>
              'Este cliente solo existe aquí: el servidor nunca lo recibió.',
            _ =>
              'Este teléfono todavía no tiene la versión del servidor. Se llena '
                  'con la próxima sincronización.',
          },
          style: AppTypography.bodySm.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return _FactsCard(facts: current.facts, headline: current.headline);
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.card,
      ),
      child: child,
    );
  }
}

/// Las acciones concretas del §8, una por caso.
class _Actions extends ConsumerStatefulWidget {
  const _Actions({required this.item, required this.subject});

  final ReviewItem item;
  final ReviewSubject? subject;

  @override
  ConsumerState<_Actions> createState() => _ActionsState();
}

class _ActionsState extends ConsumerState<_Actions> {
  bool _busy = false;

  ReviewItem get _item => widget.item;

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    final kind = _item.kind;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (subject != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: AppButton(
              label: subject.openLabel,
              variant: AppButtonVariant.outline,
              fullWidth: true,
              icon: const Icon(
                Icons.open_in_new_rounded,
                size: 16,
                color: AppColors.primary600,
              ),
              onPressed: _busy ? null : () => context.push(subject.route),
            ),
          ),

        // Corregir la boleta es la salida de los dos casos de pedido que no se
        // pueden reintentar tal cual: uno porque la serie está repetida, el otro
        // porque la boleta cambió y hay que rehacer el arreglo sobre lo nuevo.
        if (kind == ReviewKind.orderCreate || kind == ReviewKind.orderUpdate)
          PermissionGate(
            anyOf: [
              kind == ReviewKind.orderCreate
                  ? AppPermissions.ordersCreate
                  : AppPermissions.ordersUpdate,
            ],
            child: Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: AppButton(
                label: kind == ReviewKind.orderCreate
                    ? 'Corregir la boleta'
                    : 'Corregir de nuevo',
                fullWidth: true,
                loading: _busy,
                icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.white),
                onPressed: _busy ? null : _correct,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 9),
            child: AppButton(
              label: 'Volver a intentar',
              fullWidth: true,
              loading: _busy,
              icon: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.white),
              onPressed: _busy ? null : _retry,
            ),
          ),

        AppButton(
          label: _discardLabel(kind),
          variant: AppButtonVariant.ghost,
          fullWidth: true,
          onPressed: _busy ? null : _discard,
        ),
      ],
    );
  }

  static String _discardLabel(ReviewKind kind) => switch (kind) {
    ReviewKind.orderCreate => 'Descartar la boleta',
    ReviewKind.orderUpdate => 'Descartar mi corrección',
    ReviewKind.paymentCreate => 'Descartar el cobro',
    ReviewKind.customerCreate => 'Descartar el cliente',
    _ => 'Descartar',
  };

  /// Abre la boleta para arreglarla y, solo si se guardó, cierra la entrada.
  ///
  /// El «solo si» importa: si la persona entra a mirar y se arrepiente, la
  /// captura tiene que seguir esperando decisión. Nada sale de la cola por
  /// haberla visitado.
  Future<void> _correct() async {
    final orderId = _item.orderId;
    if (orderId == null) return;

    final saved = await context.push<bool>('/orders/$orderId/edit');
    if (saved != true || !mounted) return;

    await ref.read(reviewQueueControllerProvider.notifier).resolve(_item);
    if (mounted) Navigator.of(context).maybePop();
  }

  Future<void> _retry() async {
    setState(() => _busy = true);
    await ref.read(reviewQueueControllerProvider.notifier).retry(_item);
    if (!mounted) return;

    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Se mandará en la próxima sincronización')),
    );
    Navigator.of(context).maybePop();
  }

  Future<void> _discard() async {
    final confirmed = await AppConfirmDialog.show(
      context: context,
      title: '¿Descartar esta captura?',
      message: _item.kind.createsLocalRow
          ? 'Se quita de este teléfono y no vuelve a intentarse. El servidor nunca '
                'la tuvo, así que no queda registrada en ningún lado.'
          : 'No se vuelve a intentar. Lo que tiene el servidor se queda como está.',
      confirmLabel: 'Descartar',
      destructive: true,
      icon: Icons.delete_outline_rounded,
    );
    if (!confirmed || !mounted) return;

    setState(() => _busy = true);
    await ref.read(reviewQueueControllerProvider.notifier).discard(_item);
    if (mounted) Navigator.of(context).maybePop();
  }
}
