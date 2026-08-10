import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../models/order.dart';

/// Un paso de la cadena, con el color que le toca cuando ya se cumplió.
typedef _Step = ({OrderStatus status, IconData icon, Color color, Color dark});

const List<_Step> _steps = [
  (
    status: OrderStatus.received,
    icon: Icons.inbox_rounded,
    color: AppColors.secondary500,
    dark: AppColors.secondary700,
  ),
  (
    status: OrderStatus.inProgress,
    icon: Icons.autorenew_rounded,
    color: AppColors.warning,
    dark: AppColors.warningText,
  ),
  (
    status: OrderStatus.ready,
    icon: Icons.check_rounded,
    color: AppColors.success,
    dark: AppColors.successText,
  ),
  (
    status: OrderStatus.delivered,
    icon: Icons.shopping_bag_rounded,
    color: AppColors.primary500,
    dark: AppColors.primary700,
  ),
];

/// Dónde va el pedido en la cadena `recibido → en proceso → listo → entregado`.
///
/// Es lo primero que alguien pregunta en el mostrador, y una píldora de estado
/// sola no lo contesta: dice dónde está pero no cuánto falta. Los cuatro pasos
/// puestos en fila sí, y de paso enseñan el ciclo a quien recién entra.
///
/// Un pedido anulado no tiene avance que mostrar — se salió de la cadena, no
/// avanzó por ella — y uno con estado desconocido tampoco se puede ubicar. En
/// los dos casos esto no se dibuja.
class OrderProgress extends StatelessWidget {
  const OrderProgress({super.key, required this.status});

  final OrderStatus? status;

  static bool appliesTo(OrderStatus? status) =>
      status != null && status != OrderStatus.cancelled;

  @override
  Widget build(BuildContext context) {
    if (!appliesTo(status)) return const SizedBox.shrink();
    final current = _steps.indexWhere((step) => step.status == status);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Semantics(
        label: 'Avance: ${_steps[current].status.label}',
        child: Stack(
          children: [
            // Las líneas van en su propia capa y por debajo: cada celda aporta
            // media línea a cada lado, así el trazo pasa por detrás del círculo
            // en vez de chocar con él.
            Positioned(
              top: 16.5,
              left: 0,
              right: 0,
              height: 3,
              child: Row(
                children: [
                  for (var index = 0; index < _steps.length; index++)
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: _Line(
                              color: index == 0
                                  ? Colors.transparent
                                  : index <= current
                                      ? _steps[index - 1].color
                                      : AppColors.gray100,
                            ),
                          ),
                          Expanded(
                            child: _Line(
                              color: index == _steps.length - 1
                                  ? Colors.transparent
                                  : index < current
                                      ? _steps[index].color
                                      : AppColors.gray100,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < _steps.length; index++)
                  Expanded(
                    child: _StepTile(
                      step: _steps[index],
                      done: index <= current,
                      current: index == current,
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

class _Line extends StatelessWidget {
  const _Line({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    // Alto explícito y no un `DecoratedBox` a secas: sin hijo ni altura propia
    // se encoge a cero dentro de la fila y el trazo no se pinta.
    return Container(
      height: 3,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.done, required this.current});

  final _Step step;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? step.color : AppColors.gray100,
            // El halo del paso actual: sitúa "aquí está" sin recurrir a otro
            // color, que en una fila de cuatro colores ya no distinguiría nada.
            boxShadow: current
                ? [
                    BoxShadow(
                      color: step.color.withValues(alpha: 0.18),
                      spreadRadius: 4,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            step.icon,
            size: 18,
            color: done ? AppColors.white : AppColors.gray300,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          step.status.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: AppTypography.bodySm.copyWith(
            fontSize: 9.5,
            height: 1.2,
            fontWeight: FontWeight.w800,
            color: current
                ? step.dark
                : done
                    ? AppColors.gray600
                    : AppColors.gray300,
          ),
        ),
      ],
    );
  }
}
