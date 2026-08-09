import 'dart:typed_data';

import 'package:design_system/design_system.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/tables/synced_columns.dart';
import 'package:la_valiente/features/cash/state/deliveries_controller.dart';
import 'package:la_valiente/features/cash/state/ticket_lookup_controller.dart';
import 'package:la_valiente/features/orders/models/order.dart';
import 'package:la_valiente/features/scan/data/scan_remote_datasource.dart';
import 'package:la_valiente/features/scan/models/scan.dart';
import 'package:la_valiente/features/scan/models/ticket_lookup.dart';
import 'package:la_valiente/features/scan/state/ticket_photo_picker.dart';

/// Escanear una boleta para entregarla (plan 0006 §7.1.1).
///
/// Lo que se prueba es la **resolución**: qué hace la app con lo que el
/// servidor contestó. Es donde esto se puede equivocar de una forma que importa
/// —marcar la boleta de otro— y donde tiene que degradar bien: sin coincidencia,
/// lo leído termina en el buscador, que es el camino que nunca necesitó la red.

class _FakeScans implements ScanRemoteDataSource {
  _FakeScans(this.result);

  TicketLookupResult? result;
  Object? throws;
  int calls = 0;

  @override
  Future<TicketLookupResult> lookup(
    Uint8List image, {
    String filename = 'boleta.jpg',
  }) async {
    calls++;
    if (throws != null) throw throws!;
    return result!;
  }

  @override
  Future<ScanResult> scan(Uint8List image, {String filename = 'boleta.jpg'}) =>
      throw UnimplementedError();

  @override
  Future<ScanResult> get(String scanId) => throw UnimplementedError();
}

class _FakePicker implements TicketPhotoPicker {
  _FakePicker({this.cancels = false});

  /// Salir de la cámara sin tomar la foto.
  final bool cancels;

  @override
  Future<Uint8List?> pick(AppImageSource source) async =>
      cancels ? null : Uint8List.fromList([1, 2, 3]);
}

OrderListItem order({
  String id = 'order-1',
  int dailyNumber = 41,
  String customerName = 'María López',
  int total = 12000,
  int paid = 0,
  String? bookletSerial,
}) => OrderListItem(
  id: id,
  dailyNumber: dailyNumber,
  orderDate: '2026-08-08',
  customerName: customerName,
  status: OrderStatus.received,
  total: total,
  paid: paid,
  totalPieces: 3,
  syncStatus: RowSyncStatus.synced,
  bookletSerial: bookletSerial,
);

Map<String, dynamic> match({
  String orderId = 'order-1',
  int dailyNumber = 41,
  String status = 'received',
  String matchedOn = 'daily_number',
}) => {
  'order_id': orderId,
  'order_date': '2026-08-08',
  'daily_number': dailyNumber,
  'customer_id': 'customer-1',
  'status': status,
  'total_pieces': 3,
  'total': '120.00',
  'paid_total': '0.00',
  'balance': '120.00',
  'matched_on': matchedOn,
};

TicketLookupResult answer({
  List<Map<String, dynamic>> matches = const [],
  List<String> warnings = const [],
  int? dailyNumber = 41,
  String? bookletSerial,
}) => TicketLookupResult.fromJson({
  'id': 'scan-1',
  'status': 'completed',
  'daily_number': {'value': dailyNumber, 'confidence': 0.95},
  'booklet_serial': {'value': bookletSerial, 'confidence': bookletSerial == null ? 0.0 : 0.95},
  'matches': matches,
  'warnings': warnings,
});

ProviderContainer harness({
  required TicketLookupResult? result,
  List<OrderListItem> open = const [],
  Object? throws,
}) {
  final fake = _FakeScans(result)..throws = throws;
  final container = ProviderContainer(
    overrides: [
      scanRemoteDataSourceProvider.overrideWithValue(fake),
      ticketPhotoPickerProvider.overrideWithValue(_FakePicker()),
      openOrdersProvider.overrideWith((ref) => Stream.value(open)),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('la boleta encontrada y abierta queda marcada', () async {
    final open = order();
    final container = harness(
      result: answer(matches: [match()]),
      open: [open],
    );
    // El espejo se lee con `ref.read`, así que el stream tiene que haber
    // emitido antes de escanear.
    await container.read(openOrdersProvider.future);

    final outcome = await container
        .read(ticketLookupControllerProvider.notifier)
        .scan(AppImageSource.camera);

    expect(outcome, isA<TicketMarked>());
    expect((outcome as TicketMarked).order.id, 'order-1');
    expect(container.read(deliverySelectionProvider).containsKey('order-1'), isTrue);
  });

  test('escanear dos veces la misma boleta no la desmarca', () async {
    final open = order();
    final container = harness(result: answer(matches: [match()]), open: [open]);
    await container.read(openOrdersProvider.future);
    final controller = container.read(ticketLookupControllerProvider.notifier);

    await controller.scan(AppImageSource.camera);
    final second = await controller.scan(AppImageSource.camera);

    expect(second, isA<TicketMarked>());
    expect((second as TicketMarked).wasAlreadyMarked, isTrue);
    // Sigue marcada: barrer una pila y repetir un papel no puede perderlo.
    expect(container.read(deliverySelectionProvider).containsKey('order-1'), isTrue);
  });

  test('una boleta ya entregada se dice, no se marca', () async {
    final container = harness(
      result: answer(matches: [match(status: 'delivered')]),
      open: const [],
    );
    await container.read(openOrdersProvider.future);

    final outcome = await container
        .read(ticketLookupControllerProvider.notifier)
        .scan(AppImageSource.camera);

    expect(outcome, isA<TicketAlreadyClosed>());
    expect(container.read(deliverySelectionProvider), isEmpty);
  });

  test('una boleta que el servidor tiene y este teléfono no se distingue', () async {
    final container = harness(
      result: answer(matches: [match(orderId: 'de-otro-telefono')]),
      open: const [],
    );
    await container.read(openOrdersProvider.future);

    final outcome = await container
        .read(ticketLookupControllerProvider.notifier)
        .scan(AppImageSource.camera);

    // Abierta para el servidor pero ausente del espejo: el pull no la ha
    // bajado. Es otra frase y otra salida que «ya se entregó».
    expect(outcome, isA<TicketNotMirrored>());
  });

  test('sin coincidencia deja lo leído en el buscador', () async {
    final container = harness(
      result: answer(warnings: ['no_match:9'], dailyNumber: 9),
      open: [order()],
    );
    await container.read(openOrdersProvider.future);

    final outcome = await container
        .read(ticketLookupControllerProvider.notifier)
        .scan(AppImageSource.camera);

    expect(outcome, isA<TicketNotFound>());
    expect((outcome as TicketNotFound).read, '9');
    // Casi siempre es un dígito mal leído: corregirlo tecleando es más rápido
    // que volver a encuadrar la foto.
    expect(container.read(deliverySearchQueryProvider), '9');
  });

  test('una boleta ilegible no inventa búsqueda', () async {
    final container = harness(
      result: answer(warnings: ['ticket_unreadable'], dailyNumber: null),
      open: [order()],
    );
    await container.read(openOrdersProvider.future);

    final outcome = await container
        .read(ticketLookupControllerProvider.notifier)
        .scan(AppImageSource.camera);

    expect(outcome, isA<TicketNotFound>());
    expect((outcome as TicketNotFound).wasUnreadable, isTrue);
    expect(container.read(deliverySearchQueryProvider), '');
  });

  test('el serial impreso y el número escrito que no coinciden se preguntan', () async {
    final container = harness(
      result: answer(
        matches: [
          match(orderId: 'por-serial', dailyNumber: 7, matchedOn: 'booklet_serial'),
          match(orderId: 'por-numero', dailyNumber: 41),
        ],
        warnings: ['serial_and_number_disagree'],
      ),
      open: [order(id: 'por-serial', dailyNumber: 7), order(id: 'por-numero')],
    );
    await container.read(openOrdersProvider.future);

    final outcome = await container
        .read(ticketLookupControllerProvider.notifier)
        .scan(AppImageSource.camera);

    expect(outcome, isA<TicketAmbiguous>());
    // Nada se marca solo: la decisión es de quien tiene el papel en la mano.
    expect(container.read(deliverySelectionProvider), isEmpty);
  });

  test('sin señal el fallo se devuelve y no se marca nada', () async {
    final container = harness(
      result: null,
      open: [order()],
      throws: Exception('sin señal'),
    );
    await container.read(openOrdersProvider.future);

    final outcome = await container
        .read(ticketLookupControllerProvider.notifier)
        .scan(AppImageSource.camera);

    expect(outcome, isA<TicketLookupFailed>());
    expect(container.read(deliverySelectionProvider), isEmpty);
  });

  test('cancelar la cámara no llama al servidor', () async {
    final scans = _FakeScans(answer(matches: [match()]));
    final container = ProviderContainer(
      overrides: [
        scanRemoteDataSourceProvider.overrideWithValue(scans),
        ticketPhotoPickerProvider.overrideWithValue(_FakePicker(cancels: true)),
        openOrdersProvider.overrideWith((ref) => Stream.value([order()])),
      ],
    );
    addTearDown(container.dispose);

    final outcome = await container
        .read(ticketLookupControllerProvider.notifier)
        .scan(AppImageSource.camera);

    expect(outcome, isA<TicketLookupCancelled>());
    // Cada llamada al proveedor se cobra: no salir de la cámara no cuesta nada.
    expect(scans.calls, 0);
  });
}
