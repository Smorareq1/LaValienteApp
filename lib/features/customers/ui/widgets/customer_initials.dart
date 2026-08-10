import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Avatar de un cliente a partir de su nombre.
///
/// El color no es decorativo: se deriva del nombre, así que el mismo cliente
/// sale siempre del mismo tono y el ojo lo reencuentra en una lista larga sin
/// leerla.
class CustomerInitials extends StatelessWidget {
  const CustomerInitials({super.key, required this.name, this.size = 42});

  final String name;
  final double size;

  static const List<AppAvatarStyle> _palette = [
    AppAvatarStyle.primary,
    AppAvatarStyle.secondary,
    AppAvatarStyle.neutral,
  ];

  @override
  Widget build(BuildContext context) {
    return AppAvatar(
      initials: initialsOf(name),
      style: _palette[name.hashCode.abs() % _palette.length],
      size: size,
    );
  }

  /// Iniciales de un nombre: dos letras cuando hay nombre y apellido.
  static String initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'))
      ..removeWhere((part) => part.isEmpty);
    if (parts.isEmpty) return '··';
    if (parts.length == 1) {
      final first = parts.first;
      return first.substring(0, first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
  }
}
