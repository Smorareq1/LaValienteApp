import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/auth/app_permissions.dart';
import 'package:la_valiente/features/access/data/access_remote_datasource.dart';
import 'package:la_valiente/features/access/models/access.dart';
import 'package:la_valiente/features/access/ui/users_screen.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';
import 'package:la_valiente/features/auth/state/auth_controller.dart';

/// El `identity` del servidor, de mentira. Esta pantalla va **en línea**, así que
/// lo que hay que fingir es la red.
class _FakeAccess implements AccessRemoteDataSource {
  _FakeAccess({this.userRows = const [], this.roleRows = const []});

  List<SystemUser> userRows;
  List<AccessRole> roleRows;

  bool fails = false;

  final List<(String, bool)> activations = [];
  final List<(String, Set<String>)> roleWrites = [];
  NewAccount? registered;

  @override
  Future<List<SystemUser>> users() async {
    if (fails) throw Exception('sin red');
    return userRows;
  }

  @override
  Future<List<AccessRole>> roles() async => roleRows;

  @override
  Future<SystemUser> register(NewAccount account) async {
    registered = account;
    final created = SystemUser(
      id: 'new',
      username: account.username,
      isActive: true,
      fullName: account.fullName,
    );
    userRows = [...userRows, created];
    return created;
  }

  @override
  Future<SystemUser> setActive(String userId, {required bool isActive}) async {
    activations.add((userId, isActive));
    final current = userRows.firstWhere((user) => user.id == userId);
    return SystemUser(
      id: current.id,
      username: current.username,
      isActive: isActive,
      fullName: current.fullName,
      email: current.email,
      roles: current.roles,
    );
  }

  @override
  Future<void> replaceRoles(String userId, Set<String> roleIds) async {
    roleWrites.add((userId, roleIds));
  }
}

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  Future<AuthUser?> build() async => _user;
}

const _admin = AccessRole(
  id: 'r-admin',
  code: 'admin',
  name: 'Administrador',
  isSystem: true,
  description: 'Todo el sistema',
);
const _collaborator = AccessRole(
  id: 'r-collab',
  code: 'collaborator',
  name: 'Colaborador',
  isSystem: true,
  description: 'El mostrador',
);

SystemUser _user({
  String id = 'u1',
  String username = 'marta',
  String? fullName = 'Marta González',
  bool active = true,
  List<String> roles = const ['collaborator'],
}) {
  return SystemUser(
    id: id,
    username: username,
    isActive: active,
    fullName: fullName,
    roles: roles,
  );
}

Future<void> _pump(
  WidgetTester tester,
  _FakeAccess access, {
  String meId = 'me',
}) async {
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        accessRemoteDataSourceProvider.overrideWithValue(access),
        authControllerProvider.overrideWith(
          () => _FakeAuthController(
            AuthUser(
              id: meId,
              username: 'duena',
              roles: const ['admin'],
              permissions: const [AppPermissions.all],
            ),
          ),
        ),
      ],
      child: const MaterialApp(home: UsersScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('la lista', () {
    testWidgets('una cuenta enseña su usuario y sus roles', (tester) async {
      await _pump(tester, _FakeAccess(userRows: [_user()]));

      expect(find.text('Marta González'), findsOneWidget);
      expect(find.text('marta · collaborator'), findsOneWidget);
    });

    testWidgets('una cuenta sin rol lo dice, que no es lo mismo que vacía', (
      tester,
    ) async {
      // Sin rol la cuenta entra pero no ve nada: hay que poder distinguirlo de
      // un renglón al que simplemente no le cupo el texto.
      await _pump(tester, _FakeAccess(userRows: [_user(roles: const [])]));

      expect(find.text('marta · sin rol'), findsOneWidget);
    });

    testWidgets('una cuenta apagada se marca', (tester) async {
      await _pump(tester, _FakeAccess(userRows: [_user(active: false)]));

      expect(find.text('Sin acceso'), findsOneWidget);
    });

    testWidgets('la propia cuenta se marca como tuya', (tester) async {
      await _pump(tester, _FakeAccess(userRows: [_user(id: 'me')]), meId: 'me');

      expect(find.text('Tú'), findsOneWidget);
    });

    testWidgets('sin red se dice y se ofrece reintentar', (tester) async {
      await _pump(tester, _FakeAccess()..fails = true);

      expect(find.text('No se pudieron leer las cuentas'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });
  });

  group('el acceso de una cuenta', () {
    testWidgets('quitarlo pide confirmación y avisa de la sesión', (
      tester,
    ) async {
      final access = _FakeAccess(
        userRows: [_user()],
        roleRows: const [_admin, _collaborator],
      );
      await _pump(tester, access);

      await tester.tap(find.text('Marta González'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();

      expect(find.text('¿Quitarle el acceso a marta?'), findsOneWidget);
      expect(find.textContaining('se le cerrará la sesión'), findsOneWidget);
      // Nada se escribió mientras el diálogo sigue abierto.
      expect(access.activations, isEmpty);
    });

    testWidgets('confirmar apaga la cuenta', (tester) async {
      final access = _FakeAccess(
        userRows: [_user()],
        roleRows: const [_admin, _collaborator],
      );
      await _pump(tester, access);

      await tester.tap(find.text('Marta González'));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quitar acceso').last);
      await tester.pumpAndSettle();

      expect(access.activations, [('u1', false)]);
      expect(find.text('Sin acceso'), findsWidgets);
    });

    testWidgets('la propia cuenta no ofrece el interruptor', (tester) async {
      // El servidor lo rechaza con un conflicto; ofrecerlo sería invitar al
      // error y explicarlo después.
      final access = _FakeAccess(
        userRows: [_user(id: 'me')],
        roleRows: const [_admin, _collaborator],
      );
      await _pump(tester, access, meId: 'me');

      await tester.tap(find.text('Marta González'));
      await tester.pumpAndSettle();

      expect(find.byType(Switch), findsNothing);
      expect(find.textContaining('Es tu propia cuenta'), findsOneWidget);
    });
  });

  group('los roles', () {
    testWidgets('los que ya tiene llegan marcados', (tester) async {
      final access = _FakeAccess(
        userRows: [_user()],
        roleRows: const [_admin, _collaborator],
      );
      await _pump(tester, access);

      await tester.tap(find.text('Marta González'));
      await tester.pumpAndSettle();

      final checkboxes = tester.widgetList<Checkbox>(find.byType(Checkbox));
      expect(checkboxes.map((box) => box.value), [false, true]);
    });

    testWidgets('guardar manda la lista final, no un incremento', (
      tester,
    ) async {
      // El endpoint sustituye: no hay «agregar» ni «quitar».
      final access = _FakeAccess(
        userRows: [_user()],
        roleRows: const [_admin, _collaborator],
      );
      await _pump(tester, access);

      await tester.tap(find.text('Marta González'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Administrador'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Guardar roles'));
      await tester.pumpAndSettle();

      expect(access.roleWrites, hasLength(1));
      expect(access.roleWrites.single.$1, 'u1');
      // Por contenido: un `Set` no promete orden y la lista final es lo que
      // importa, no en qué secuencia se marcaron las casillas.
      expect(access.roleWrites.single.$2, {'r-admin', 'r-collab'});
      expect(find.text('marta · admin, collaborator'), findsOneWidget);
    });

    testWidgets('sin permiso para listarlos se explica por qué', (tester) async {
      // `authorization.roles.manage` no viene incluido en el de usuarios: el
      // datasource devuelve vacío y la sheet lo dice en vez de enseñar una lista
      // vacía que parecería que no hay roles.
      final access = _FakeAccess(userRows: [_user()]);
      await _pump(tester, access);

      await tester.tap(find.text('Marta González'));
      await tester.pumpAndSettle();

      expect(
        find.textContaining('authorization.roles.manage'),
        findsOneWidget,
      );
    });
  });
}
