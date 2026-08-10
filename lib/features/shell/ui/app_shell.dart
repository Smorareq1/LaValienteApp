import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../auth/state/auth_controller.dart';
import '../../sync/state/sync_engine.dart';
import '../shell_destinations.dart';
import 'widgets/app_bottom_nav.dart';

/// Shell autenticado: mantiene el estado de cada rama y dibuja la barra
/// inferior con los destinos que el rol actual puede usar (Plan 0006 §3.1).
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).valueOrNull;

    // El motor de sincronización vive mientras haya un shell montado: aquí es
    // donde empieza a existir la sesión de trabajo del día.
    ref.watch(syncEngineProvider);

    // Se conserva el índice de rama de cada destino visible: la barra muestra
    // menos ítems que ramas tiene el router, pero navega a la rama correcta.
    final visible = <({ShellDestination destination, int branchIndex})>[
      for (var i = 0; i < shellDestinations.length; i++)
        if (shellDestinations[i].isVisibleFor(user))
          (destination: shellDestinations[i], branchIndex: i),
    ];

    final currentIndex =
        visible.indexWhere((entry) => entry.branchIndex == navigationShell.currentIndex);

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: navigationShell,
      bottomNavigationBar: AppBottomNav(
        destinations: [for (final entry in visible) entry.destination],
        currentIndex: currentIndex,
        onSelected: (index) => navigationShell.goBranch(
          visible[index].branchIndex,
          // Volver a tocar el tab activo regresa a la raíz de esa rama.
          initialLocation: visible[index].branchIndex == navigationShell.currentIndex,
        ),
      ),
    );
  }
}
