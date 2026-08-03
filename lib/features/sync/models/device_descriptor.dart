import 'dart:io';

import '../../../core/config/env.dart';

/// Cómo se presenta este dispositivo al registrarse (plan 0004 §6.2).
///
/// El nombre es de diagnóstico: sirve para que un admin sepa qué está
/// revocando. La pantalla de Ajustes podrá cambiarlo más adelante.
class DeviceDescriptor {
  const DeviceDescriptor({
    required this.name,
    required this.platform,
    required this.appVersion,
  });

  factory DeviceDescriptor.current() {
    final platform = Platform.operatingSystem;
    return DeviceDescriptor(
      name: 'Dispositivo $platform',
      platform: platform,
      appVersion: Env.appVersion,
    );
  }

  final String name;
  final String platform;
  final String appVersion;
}
