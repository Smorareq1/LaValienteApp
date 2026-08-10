import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/scan/data/scan_remote_datasource.dart';
import 'package:la_valiente/features/scan/models/cash_sheet.dart';
import 'package:la_valiente/features/scan/models/scan.dart';
import 'package:la_valiente/features/scan/models/ticket_lookup.dart';
import 'package:la_valiente/features/scan/state/cash_sheet_controller.dart';

/// Importar la hoja del día (plan 0005 §1).
///
/// Lo que se prueba es **qué llega marcado y qué se manda**, que es donde esto
/// se puede equivocar de la forma que importa: una fila marcada de más cobra
/// dinero que nadie pidió cobrar.

class _FakeScans implements ScanRemoteDataSource {
  CashSheetResult? result;
  Object? throws;
  CashSheetApply? sent;

  @override
  Future<CashSheetResult> scanCashSheet(
    Uint8List image, {
    String filename = 'cierre.jpg',
  }) async {
    if (throws != null) throw throws!;
    return result!;
  }

  @override
  Future<CashSheetApplyResult> applyCashSheet(
    String scanId,
    CashSheetApply data,
  ) async {
    sent = data;
    if (throws != null) throw throws!;
    return CashSheetApplyResult(closeDate: data.closeDate);
  }

  @override
  Future<ScanResult> scan(Uint8List image, {String filename = 'boleta.jpg'}) =>
      throw UnimplementedError();

  @override
  Future<ScanResult> get(String scanId) => throw UnimplementedError();

  @override
  Future<TicketLookupResult> lookup(
    Uint8List image, {
    String filename = 'boleta.jpg',
  }) => throw UnimplementedError();
}

Map<String, dynamic> leaf(Object? value) => {
  'value': value,
  'confidence': 0.95,
  'raw_text': null,
};

Map<String, dynamic> income({
  required int index,
  required String status,
  String serial = '939',
  String amountRead = '115.00',
  String? amountSuggested = '115.00',
  String? orderId = 'order-1',
  String balance = '115.00',
  String method = 'cash',
  bool canDeliver = true,
}) => {
  'index': index,
  'status': status,
  'booklet_serial': leaf(serial),
  'customer_text': leaf('Elmer González'),
  'amount_read': leaf(amountRead),
  'method': method,
  'invoice_requested': false,
  'order_id': orderId,
  'balance': balance,
  'amount_suggested': amountSuggested,
  'can_deliver': canDeliver,
};

Map<String, dynamic> expense({
  required int index,
  required String status,
  String? categoryId = 'cat-1',
  String concept = 'gas',
  String amount = '160.00',
}) => {
  'index': index,
  'status': status,
  'concept': leaf(concept),
  'amount': leaf(amount),
  'observations': leaf(null),
  'category_id': categoryId,
  'category_name': 'Gas',
  'expense_status': 'paid',
  'method': 'cash',
};

CashSheetResult sheet({
  List<Map<String, dynamic>> incomes = const [],
  List<Map<String, dynamic>> expenses = const [],
  List<String> warnings = const [],
}) => CashSheetResult.fromJson({
  'id': 'scan-1',
  'status': 'completed',
  'warnings': warnings,
  'draft': {
    'days': [
      {
        'close_date': leaf('2026-08-09'),
        'incomes': incomes,
        'expenses': expenses,
        'attendance': <Map<String, dynamic>>[],
        'warnings': <String>[],
      },
    ],
  },
});

Future<CashSheetReview> reviewOf(
  ProviderContainer container,
  CashSheetResult result,
) async {
  await container
      .read(cashSheetControllerProvider.notifier)
      .send(Uint8List.fromList([1, 2, 3]));
  return container.read(cashSheetControllerProvider) as CashSheetReview;
}

void main() {
  late _FakeScans scans;
  late ProviderContainer container;

  setUp(() {
    scans = _FakeScans();
    container = ProviderContainer(
      overrides: [scanRemoteDataSourceProvider.overrideWithValue(scans)],
    );
    addTearDown(container.dispose);
  });

  group('qué llega marcado', () {
    test('solo se marca la fila que cuadra con el saldo', () async {
      scans.result = sheet(
        incomes: [
          income(index: 0, status: 'matched'),
          income(index: 1, status: 'amount_mismatch', amountRead: '150.00'),
          income(index: 2, status: 'not_found', orderId: null, amountSuggested: null),
          income(index: 3, status: 'settled', amountSuggested: null),
        ],
      );

      final review = await reviewOf(container, scans.result!);

      expect(review.incomes[0]!.selected, isTrue);
      // Las tres de abajo son justo las que hay que mirar: marcarlas las
      // escondería en la lista.
      expect(review.incomes[1]!.selected, isFalse);
      expect(review.incomes[2]!.selected, isFalse);
      expect(review.incomes[3]!.selected, isFalse);
      expect(review.selectedIncomes, 1);
    });

    test('la fila desajustada llega con el monto ya recortado al saldo', () async {
      scans.result = sheet(
        incomes: [
          income(
            index: 0,
            status: 'amount_mismatch',
            amountRead: '150.00',
            amountSuggested: '115.00',
          ),
        ],
      );

      final review = await reviewOf(container, scans.result!);

      expect(review.incomes[0]!.amount, 11500);
    });

    test('un gasto sin categoría no se puede marcar', () async {
      scans.result = sheet(
        expenses: [expense(index: 0, status: 'no_category', categoryId: null)],
      );

      final review = await reviewOf(container, scans.result!);

      expect(review.expenses[0]!.selected, isFalse);
      expect(review.expenses[0]!.isComplete, isFalse);
    });

    test('el total a cobrar es la suma de lo marcado y nada más', () async {
      scans.result = sheet(
        incomes: [
          income(index: 0, status: 'matched'),
          income(index: 1, status: 'amount_mismatch', amountSuggested: '80.00'),
        ],
      );

      final review = await reviewOf(container, scans.result!);

      expect(review.collectedTotal, 11500);
    });
  });

  group('qué se manda', () {
    test('lo desmarcado no viaja', () async {
      scans.result = sheet(
        incomes: [
          income(index: 0, status: 'matched'),
          income(index: 1, status: 'matched', orderId: 'order-2'),
        ],
      );
      final review = await reviewOf(container, scans.result!);
      final notifier = container.read(cashSheetControllerProvider.notifier);
      notifier.updateIncome(1, review.incomes[1]!.copyWith(selected: false));

      await notifier.apply();

      expect(scans.sent!.incomes, hasLength(1));
      expect(scans.sent!.incomes.first.orderId, 'order-1');
    });

    test('el monto corregido a mano es el que se cobra', () async {
      scans.result = sheet(incomes: [income(index: 0, status: 'matched')]);
      final review = await reviewOf(container, scans.result!);
      final notifier = container.read(cashSheetControllerProvider.notifier);
      notifier.updateIncome(0, review.incomes[0]!.copyWith(amount: 9000));

      await notifier.apply();

      expect(scans.sent!.incomes.first.amount, 9000);
    });

    test('una fila sin boleta emparejada nunca viaja, aunque se marque', () async {
      scans.result = sheet(
        incomes: [
          income(index: 0, status: 'not_found', orderId: null, amountSuggested: null),
        ],
      );
      final review = await reviewOf(container, scans.result!);
      final notifier = container.read(cashSheetControllerProvider.notifier);
      notifier.updateIncome(
        0,
        review.incomes[0]!.copyWith(selected: true, amount: 5000),
      );

      final result = await notifier.apply();

      expect(result.isLeft(), isTrue);
      expect(scans.sent, isNull);
    });

    test('sin nada marcado no se llama al servidor', () async {
      scans.result = sheet(
        incomes: [income(index: 0, status: 'settled', amountSuggested: null)],
      );
      await reviewOf(container, scans.result!);

      final result = await container
          .read(cashSheetControllerProvider.notifier)
          .apply();

      expect(result.isLeft(), isTrue);
      expect(scans.sent, isNull);
    });
  });

  group('cuando algo sale mal', () {
    test('un fallo al aplicar conserva lo marcado para reintentar', () async {
      scans.result = sheet(incomes: [income(index: 0, status: 'matched')]);
      await reviewOf(container, scans.result!);
      scans.throws = Exception('sin señal');

      await container.read(cashSheetControllerProvider.notifier).apply();

      final state = container.read(cashSheetControllerProvider);
      expect(state, isA<CashSheetReview>());
      expect((state as CashSheetReview).selectedIncomes, 1);
      expect(state.applying, isFalse);
      expect(state.failure, isNotNull);
    });

    test('una hoja sin un solo bloque legible no deja la pantalla en blanco', () async {
      // El servidor contesta 200 y con cero días cuando la foto no deja leer la
      // rejilla: es una respuesta válida, y construir la revisión sobre ella
      // reventaría al pedir el primer bloque.
      scans.result = CashSheetResult.fromJson({
        'id': 'scan-1',
        'status': 'completed',
        'warnings': ['no_blocks_read'],
        'draft': {'days': <Map<String, dynamic>>[]},
      });

      final result = await container
          .read(cashSheetControllerProvider.notifier)
          .send(Uint8List.fromList([1, 2, 3]));

      expect(result.isLeft(), isTrue);
      final state = container.read(cashSheetControllerProvider);
      expect(state, isA<CashSheetFailed>());
      // La foto se conserva para reintentar sin volver a encuadrar.
      expect((state as CashSheetFailed).image, isNotEmpty);
    });

    test('una hoja ya importada se reconoce por su aviso', () async {
      scans.result = sheet(
        incomes: [income(index: 0, status: 'matched')],
        warnings: ['already_applied:2026-08-09T20:15'],
      );

      final review = await reviewOf(container, scans.result!);

      expect(review.result.isAlreadyApplied, isTrue);
    });
  });
}
