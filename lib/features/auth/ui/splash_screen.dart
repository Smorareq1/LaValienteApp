import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Pantalla mostrada mientras se restaura la sesión al arrancar.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const String path = '/splash';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppGradients.authHeader),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Image.asset('assets/images/logo_la_valiente.png', width: 180),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SizedBox.square(
                dimension: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
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
