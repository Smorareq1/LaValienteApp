import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/env.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Un release compilado sin `--dart-define-from-file` apunta a localhost y no
  // lo dice: se instala, abre, y recién falla al primer login, ya en el
  // mostrador. Esta línea es lo único que separa ese descuido de una tarde
  // buscando un problema de red que no existe. Va con `debugPrint` y no con
  // `appLog` a propósito: `appLog` se poda en release, que es justo donde el
  // aviso hace falta.
  if (kReleaseMode && Env.isMisconfiguredRelease) {
    debugPrint(
      '[LV] ADVERTENCIA: release compilado contra ${Env.apiBaseUrl}. '
      'Falta --dart-define-from-file=prod.json.',
    );
  }

  runApp(const ProviderScope(child: LaValienteApp()));
}
