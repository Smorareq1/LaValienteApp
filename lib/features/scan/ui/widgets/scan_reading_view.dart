import 'dart:math' as math;
import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// La espera mientras el servidor lee la foto (plan 0003 §4).
///
/// Es una pantalla de carga y hace lo que hace cualquier pantalla de carga, pero
/// tiene un trabajo más: **decir qué está pasando**. Escanear tarda entre cinco y
/// treinta segundos —una llamada a un modelo del otro lado, sobre una foto de un
/// megabyte, desde un teléfono en Cobán— y un giro indefinido durante treinta
/// segundos se lee como algo trabado. Los pasos de abajo van avanzando con el
/// tiempo esperado de cada uno, así que quien mira sabe que sigue vivo.
///
/// Los pasos son **honestos en el orden y estimados en el tiempo**: la app no
/// puede saber en qué va el servidor —es una sola petición— pero sí sabe qué
/// hace y en qué orden, y ese es el sentido de enseñarlo. Ninguno se marca como
/// terminado por su cuenta: el último se queda latiendo hasta que la respuesta
/// llega, que es la verdad.
class ScanReadingView extends StatefulWidget {
  const ScanReadingView({
    required this.image,
    required this.steps,
    super.key,
    this.title = 'Leyendo la boleta',
  });

  /// La foto que se está leyendo. Se enseña debajo de la animación porque es lo
  /// que ancla la espera: se ve que es la boleta correcta antes de que termine.
  final Uint8List image;

  final String title;

  /// Los pasos, en orden, con cuánto suele tardar cada uno.
  final List<ScanStep> steps;

  /// Los de una boleta de talonario.
  static const List<ScanStep> ticketSteps = [
    ScanStep('Subiendo la foto', Icons.cloud_upload_outlined, Duration(seconds: 3)),
    ScanStep('Leyendo la letra', Icons.auto_awesome_outlined, Duration(seconds: 9)),
    ScanStep('Buscando al cliente', Icons.person_search_outlined, Duration(seconds: 3)),
    ScanStep('Calculando con el catálogo', Icons.calculate_outlined, Duration(seconds: 4)),
  ];

  /// Los de la hoja de registro diario, que es más papel y más filas.
  static const List<ScanStep> cashSteps = [
    ScanStep('Subiendo la foto', Icons.cloud_upload_outlined, Duration(seconds: 3)),
    ScanStep('Leyendo la hoja', Icons.auto_awesome_outlined, Duration(seconds: 12)),
    ScanStep('Buscando las boletas', Icons.receipt_long_outlined, Duration(seconds: 5)),
    ScanStep('Cuadrando los totales', Icons.calculate_outlined, Duration(seconds: 4)),
  ];

  @override
  State<ScanReadingView> createState() => _ScanReadingViewState();
}

/// Un paso de la lectura: qué dice, con qué icono, y cuánto suele durar.
class ScanStep {
  const ScanStep(this.label, this.icon, this.duration);

  final String label;
  final IconData icon;
  final Duration duration;
}

class _ScanReadingViewState extends State<ScanReadingView>
    with TickerProviderStateMixin {
  /// El barrido sobre la foto. Va y viene sin parar: es lo que dice «sigue».
  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat();

  /// El reloj de los pasos. Uno solo para los cuatro, porque el paso en curso se
  /// deduce del tiempo transcurrido y no de cuatro animaciones que sincronizar.
  late final AnimationController _elapsed = AnimationController(
    vsync: this,
    duration: _total,
  )..forward();

  Duration get _total => widget.steps.fold(
    Duration.zero,
    (sum, step) => sum + step.duration,
  );

  /// En qué paso va, por el tiempo transcurrido. El último se queda latiendo:
  /// mientras no llegue la respuesta, sigue leyendo.
  int get _currentStep {
    final elapsed = _total * _elapsed.value;
    var accumulated = Duration.zero;
    for (var index = 0; index < widget.steps.length; index++) {
      accumulated += widget.steps[index].duration;
      if (elapsed < accumulated) return index;
    }
    return widget.steps.length - 1;
  }

  @override
  void dispose() {
    _sweep.dispose();
    _elapsed.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
      children: [
        Center(
          child: _Halo(
            sweep: _sweep,
            child: Text(
              widget.title,
              style: AppTypography.h3.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 20),
        AnimatedBuilder(
          animation: _elapsed,
          builder: (context, _) => _Steps(
            steps: widget.steps,
            current: _currentStep,
          ),
        ),
        const SizedBox(height: 18),
        _ScannedPhoto(image: widget.image, sweep: _sweep),
        const SizedBox(height: 14),
        Text(
          'Tarda unos segundos. Si no sale, siempre podés capturarla a mano.',
          style: AppTypography.helper.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// El anillo que late detrás del título.
class _Halo extends StatelessWidget {
  const _Halo({required this.sweep, required this.child});

  final Animation<double> sweep;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sweep,
      builder: (context, _) {
        // Dos senos desfasados: el anillo respira sin llegar nunca a un tamaño
        // fijo, que es lo que haría que se leyera como una imagen congelada.
        final pulse = (math.sin(sweep.value * 2 * math.pi) + 1) / 2;
        return Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppGradients.brand,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary500.withValues(alpha: 0.18 + pulse * 0.22),
                    blurRadius: 18 + pulse * 22,
                    spreadRadius: pulse * 6,
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: sweep.value * 2 * math.pi,
                child: const Icon(
                  Icons.document_scanner_outlined,
                  size: 36,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        );
      },
    );
  }
}

/// Los pasos, con el que va en curso resaltado.
class _Steps extends StatelessWidget {
  const _Steps({required this.steps, required this.current});

  final List<ScanStep> steps;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0; index < steps.length; index++)
            _StepRow(
              step: steps[index],
              done: index < current,
              active: index == current,
            ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.step, required this.done, required this.active});

  final ScanStep step;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = done
        ? AppColors.successText
        : active
        ? AppColors.primary600
        : AppColors.textMuted;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: done
                ? const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: AppColors.successText,
                  )
                : active
                ? const CircularProgressIndicator(
                    strokeWidth: 2.2,
                    color: AppColors.primary500,
                  )
                : Icon(step.icon, size: 19, color: AppColors.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              style: AppTypography.bodySm.copyWith(
                fontSize: 14,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
              child: Text(step.label),
            ),
          ),
        ],
      ),
    );
  }
}

/// La foto con la línea de barrido encima.
class _ScannedPhoto extends StatelessWidget {
  const _ScannedPhoto({required this.image, required this.sweep});

  final Uint8List image;
  final Animation<double> sweep;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: Stack(
        children: [
          // Atenuada: lo que se mira mientras se espera es la animación, y una
          // foto a pleno contraste debajo de una línea que se mueve es ruido.
          ColorFiltered(
            colorFilter: const ColorFilter.mode(
              AppColors.gray300,
              BlendMode.saturation,
            ),
            child: Image.memory(image, fit: BoxFit.contain, width: double.infinity),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: sweep,
              builder: (context, _) => CustomPaint(
                painter: _SweepPainter(progress: sweep.value),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// La banda de luz que recorre la foto de arriba abajo y vuelve.
class _SweepPainter extends CustomPainter {
  const _SweepPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Triangular en vez de lineal: el barrido baja y sube, y un salto del final
    // al principio se vería como un tirón.
    final travel = progress <= 0.5 ? progress * 2 : (1 - progress) * 2;
    final y = travel * size.height;
    final band = size.height * 0.16;

    final rect = Rect.fromLTWH(0, y - band, size.width, band * 2);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.secondary500.withValues(alpha: 0),
          AppColors.secondary500.withValues(alpha: 0.32),
          AppColors.primary500.withValues(alpha: 0.10),
          AppColors.secondary500.withValues(alpha: 0),
        ],
        stops: const [0, 0.5, 0.62, 1],
      ).createShader(rect);
    canvas.drawRect(rect, paint);

    final line = Paint()
      ..color = AppColors.secondary500.withValues(alpha: 0.85)
      ..strokeWidth = 2;
    canvas.drawLine(Offset(0, y), Offset(size.width, y), line);
  }

  @override
  bool shouldRepaint(_SweepPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
