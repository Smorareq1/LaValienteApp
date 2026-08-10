import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/auth/app_permissions.dart';
import 'package:la_valiente/features/auth/models/auth_user.dart';
import 'package:la_valiente/features/auth/state/auth_controller.dart';
import 'package:la_valiente/features/settings/ui/settings_screen.dart';
import 'package:la_valiente/features/sync/data/devices_remote_datasource.dart';

class _FakeAuthController extends AuthController {
  _FakeAuthController(this._user);

  final AuthUser? _user;

  @override
  Future<AuthUser?> build() async => _user;
}

class _FakeDevices implements DevicesRemoteDataSource {
  _FakeDevices({this.devices = const []});

  List<SyncDevice> devices;

  final List<String> revoked = [];

  @override
  Future<List<SyncDevice>> list() async => devices;

  @override
  Future<SyncDevice> revoke(String id) async {
    revoked.add(id);
    final updated = [
      for (final device in devices)
        if (device.id == id)
          SyncDevice(
            id: device.id,
            userId: device.userId,
            name: device.name,
            platform: device.platform,
            revokedAt: DateTime.utc(2026, 8, 8),
          )
        else
          device,
    ];
    devices = updated;
    return updated.firstWhere((device) => device.id == id);
  }
}

Future<void> _pump(
  WidgetTester tester,
  _FakeDevices devices, {
  List<String> permissions = const [AppPermissions.all],
}) async {
  tester.view.physicalSize = const Size(400, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        devicesRemoteDataSourceProvider.overrideWithValue(devices),
        authControllerProvider.overrideWith(
          () => _FakeAuthController(
            AuthUser(
              id: 'u1',
              username: 'mostrador',
              fullName: 'Marta González',
              roles: const ['admin'],
              permissions: permissions,
            ),
          ),
        ),
      ],
      child: const MaterialApp(home: SettingsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el perfil muestra el nombre, el usuario y los roles', (tester) async {
    await _pump(tester, _FakeDevices());

    expect(find.text('Marta González'), findsOneWidget);
    expect(find.text('mostrador'), findsOneWidget);
    expect(find.text('admin'), findsOneWidget);
  });

  testWidgets('sin el permiso, los dispositivos ni se mencionan', (tester) async {
    // `sync.devices.manage` no lo tiene ningún rol sembrado: llega por el
    // comodín del administrador.
    await _pump(
      tester,
      _FakeDevices(
        devices: [
          const SyncDevice(id: 'd1', userId: 'u1', name: 'Teléfono mostrador'),
        ],
      ),
      permissions: const [AppPermissions.ordersRead],
    );

    expect(find.text('Dispositivos'), findsNothing);
    expect(find.text('Teléfono mostrador'), findsNothing);
  });

  testWidgets('revocar pide confirmación y avisa de lo que se pierde', (
    tester,
  ) async {
    // No es apagar un interruptor: el aparato borra su base local en el
    // siguiente contacto (plan 0004 D11).
    final devices = _FakeDevices(
      devices: [
        const SyncDevice(
          id: 'd1',
          userId: 'u1',
          name: 'Teléfono mostrador',
          platform: 'android',
        ),
      ],
    );
    await _pump(tester, devices);

    await tester.tap(find.byTooltip('Revocar'));
    await tester.pumpAndSettle();

    expect(find.text('¿Revocar Teléfono mostrador?'), findsOneWidget);
    expect(find.textContaining('se pierde'), findsOneWidget);
    expect(devices.revoked, isEmpty);
  });

  testWidgets('confirmar revoca y la fila lo dice', (tester) async {
    final devices = _FakeDevices(
      devices: [
        const SyncDevice(id: 'd1', userId: 'u1', name: 'Teléfono mostrador'),
      ],
    );
    await _pump(tester, devices);

    await tester.tap(find.byTooltip('Revocar'));
    await tester.pumpAndSettle();
    // El botón del diálogo, no el de la fila: el `Revocar` de la fila es un
    // `IconButton` con tooltip y este es texto dentro del diálogo.
    await tester.tap(find.text('Revocar').last);
    await tester.pumpAndSettle();

    expect(devices.revoked, ['d1']);
    expect(find.text('Revocado'), findsOneWidget);
  });

  testWidgets('un dispositivo que nunca sincronizó lo dice', (tester) async {
    await _pump(
      tester,
      _FakeDevices(
        devices: [
          const SyncDevice(id: 'd1', userId: 'u1', name: 'Tablet vieja'),
        ],
      ),
    );

    expect(find.text('Nunca ha sincronizado'), findsOneWidget);
  });
}
