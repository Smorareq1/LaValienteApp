import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/errors/app_failure.dart';
import 'package:la_valiente/features/scan/data/scan_remote_datasource.dart';
import 'package:la_valiente/features/scan/models/cash_sheet.dart';
import 'package:la_valiente/features/scan/models/scan.dart';
import 'package:la_valiente/features/scan/models/ticket_lookup.dart';
import 'package:la_valiente/features/scan/state/scan_controller.dart';
import 'package:la_valiente/features/scan/ui/scan_screen.dart';

/// El servidor de escaneo, de mentira. Este módulo es online-only por diseño
/// (D8), así que lo que hay que fingir es la red y nada más.
class _FakeScans implements ScanRemoteDataSource {
  _FakeScans({this.result});

  ScanResult? result;
  bool fails = false;
  int calls = 0;

  @override
  Future<ScanResult> scan(Uint8List image, {String filename = 'boleta.jpg'}) async {
    calls++;
    if (fails) throw Exception('sin señal');
    return result!;
  }

  @override
  Future<ScanResult> get(String scanId) async => result!;

  /// La búsqueda para entregar vive en Caja y tiene sus propias pruebas; acá
  /// solo hace falta que el doble siga siendo del tipo.
  @override
  Future<TicketLookupResult> lookup(
    Uint8List image, {
    String filename = 'boleta.jpg',
  }) => throw UnimplementedError();

  /// Y la hoja del día vive en su propia pantalla, por lo mismo.
  @override
  Future<CashSheetResult> scanCashSheet(
    Uint8List image, {
    String filename = 'cierre.jpg',
  }) => throw UnimplementedError();

  @override
  Future<CashSheetApplyResult> applyCashSheet(
    String scanId,
    CashSheetApply data,
  ) => throw UnimplementedError();
}

/// Un PNG de un pixel: `Image.memory` necesita bytes que de verdad decodifiquen.
final _png = Uint8List.fromList([
  0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1f, 0x15, 0xc4, 0x89, 0x00, 0x00, 0x00,
  0x0a, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9c, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0d, 0x0a, 0x2d, 0xb4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82,
]);

Map<String, dynamic> _field(Object? value, {bool needsReview = false}) => {
  'value': value,
  'confidence': needsReview ? 0.6 : 0.95,
  'raw_text': null,
  'needs_review': needsReview,
};

ScanResult _result({
  List<String> warnings = const [],
  Map<String, dynamic>? match,
  bool empty = false,
}) {
  return ScanResult.fromJson({
    'id': 's1',
    'status': 'completed',
    'warnings': warnings,
    'draft': {
      'booklet_serial': _field('A-4410'),
      'customer_name': _field(empty ? null : 'María López'),
      'nit': _field('CF'),
      'weight_lbs': _field('12.50'),
      'customer_match': match,
      'garments': empty
          ? <Map<String, dynamic>>[]
          : [
              {
                'garment_type_id': 'g1',
                'name': 'Camisa',
                'quantity': 3,
                'confidence': 0.9,
                'needs_review': false,
              },
            ],
      'charges': empty
          ? <Map<String, dynamic>>[]
          : [
              {
                'service_code': 'wash_by_weight',
                'option_code': null,
                'quantity': '12.5',
                'amount': null,
                'description': 'Lavado por peso',
                'confidence': 0.9,
                'needs_review': false,
              },
            ],
      'estimated_subtotal': '98.75',
      'estimated_total': '98.75',
      'total_read': '108.75',
    },
  });
}

Future<void> _pump(
  WidgetTester tester,
  _FakeScans scans, {
  ScanState? initial,
}) async {
  tester.view.physicalSize = const Size(400, 1800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: [scanRemoteDataSourceProvider.overrideWithValue(scans)],
  );
  addTearDown(container.dispose);

  // La foto no se puede tomar en una prueba de widget —no hay cámara—, así que
  // el estado se pone directamente y lo que se ejercita es la revisión, que es
  // donde vive la decisión.
  if (initial != null) {
    container.read(scanControllerProvider.notifier).state = initial;
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: ScanScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin foto explica que nada se guarda solo', (tester) async {
    // Es el principio inviolable del plan 0003 y hay que decirlo donde se usa.
    await _pump(tester, _FakeScans());

    expect(find.textContaining('nada se guarda solo'), findsOneWidget);
    expect(find.text('Tomar la foto'), findsOneWidget);
    expect(find.text('Elegir de la galería'), findsOneWidget);
  });

  testWidgets('la revisión dice que el total lo pone el catálogo', (tester) async {
    // D4: los montos escritos en la boleta jamás se cobran.
    await _pump(
      tester,
      _FakeScans(),
      initial: ScanDone(_png, _result()),
    );

    expect(find.text('Q98.75'), findsOneWidget);
    expect(find.textContaining('Lo calcula el catálogo, no la foto'), findsOneWidget);
  });

  testWidgets('la discrepancia de total se muestra en español', (tester) async {
    await _pump(
      tester,
      _FakeScans(),
      initial: ScanDone(_png, _result(warnings: ['total_mismatch:108.75:98.75'])),
    );

    expect(find.textContaining('La boleta dice Q108.75'), findsOneWidget);
  });

  testWidgets('el cliente sugerido se enseña como pregunta', (tester) async {
    // §7.5: una sugerencia, nunca una decisión. Aceptarla sola archivaría la
    // ropa de alguien bajo el nombre de otro.
    await _pump(
      tester,
      _FakeScans(),
      initial: ScanDone(
        _png,
        _result(
          match: {
            'customer_id': 'c1',
            'full_name': 'María López',
            'phone': '55123456',
            'score': 1.0,
            'matched_on': 'phone',
          },
        ),
      ),
    );

    expect(find.textContaining('¿Es María López'), findsOneWidget);
  });

  testWidgets('una foto de la que no salió nada ofrece volver a intentar', (
    tester,
  ) async {
    await _pump(
      tester,
      _FakeScans(),
      initial: ScanDone(_png, _result(empty: true)),
    );

    expect(find.textContaining('no se sacó nada aprovechable'), findsOneWidget);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('un fallo de red ofrece reintentar y capturar a mano', (
    tester,
  ) async {
    // La salida que D8 promete: la captura a mano no depende de este módulo, y
    // ofrecerla aquí es lo que impide que un fallo del proveedor pare el
    // mostrador.
    await _pump(
      tester,
      _FakeScans(),
      initial: ScanFailed(_png, const NetworkFailure()),
    );

    expect(find.text('Reintentar'), findsOneWidget);
    expect(find.text('Capturar a mano'), findsOneWidget);
  });

  group('el controlador', () {
    test('un fallo conserva la foto para no volver a encuadrar', () async {
      // Quien acaba de sostener una boleta con las manos ocupadas no debería
      // tener que repetir la foto porque se cayó la red.
      final scans = _FakeScans()..fails = true;
      final container = ProviderContainer(
        overrides: [scanRemoteDataSourceProvider.overrideWithValue(scans)],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(scanControllerProvider.notifier)
          .send(_png);

      expect(result.isLeft(), isTrue);
      final state = container.read(scanControllerProvider);
      expect(state, isA<ScanFailed>());
      expect((state as ScanFailed).image, _png);
    });

    test('reintentar manda la misma foto y no pide otra', () async {
      final scans = _FakeScans(result: _result())..fails = true;
      final container = ProviderContainer(
        overrides: [scanRemoteDataSourceProvider.overrideWithValue(scans)],
      );
      addTearDown(container.dispose);

      final controller = container.read(scanControllerProvider.notifier);
      await controller.send(_png);
      scans.fails = false;
      await controller.retry();

      expect(scans.calls, 2);
      expect(container.read(scanControllerProvider), isA<ScanDone>());
    });

    test('sin ninguna foto no hay nada que reintentar', () async {
      final container = ProviderContainer(
        overrides: [
          scanRemoteDataSourceProvider.overrideWithValue(_FakeScans()),
        ],
      );
      addTearDown(container.dispose);

      final result = await container
          .read(scanControllerProvider.notifier)
          .retry();

      expect(result.isLeft(), isTrue);
    });
  });
}
