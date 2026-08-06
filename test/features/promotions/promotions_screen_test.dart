import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/features/promotions/data/promotions_remote_datasource.dart';
import 'package:la_valiente/features/promotions/models/promotion.dart';
import 'package:la_valiente/features/promotions/ui/promotions_screen.dart';

/// El servidor de promociones, de mentira. La pantalla es de las pocas que va
/// en línea, así que lo que hay que fingir aquí es la red y no la BD local.
class _FakeRemote implements PromotionsRemoteDataSource {
  _FakeRemote(this.promotions);

  List<Promotion> promotions;

  /// Lo que se pidió apagar o encender, para comprobarlo sin espiar la UI.
  final List<(String, bool)> toggles = [];

  bool fails = false;

  @override
  Future<List<Promotion>> list() async {
    if (fails) throw Exception('sin red');
    return promotions;
  }

  @override
  Future<Promotion> create(PromotionInput input) async => throw UnimplementedError();

  @override
  Future<Promotion> update(String id, PromotionInput input) async =>
      throw UnimplementedError();

  @override
  Future<Promotion> setActive(String id, {required bool isActive}) async {
    toggles.add((id, isActive));
    final updated = [
      for (final promotion in promotions)
        if (promotion.id == id)
          Promotion(
            id: promotion.id,
            code: promotion.code,
            name: promotion.name,
            discountType: promotion.discountType,
            value: promotion.value,
            appliesToServiceCodes: promotion.appliesToServiceCodes,
            validFrom: promotion.validFrom,
            validTo: promotion.validTo,
            isActive: isActive,
          )
        else
          promotion,
    ];
    promotions = updated;
    return updated.firstWhere((promotion) => promotion.id == id);
  }
}

Promotion _promotion({
  required String id,
  required String name,
  DiscountType type = DiscountType.percentage,
  int value = 5000,
  List<String>? services,
  String from = '2020-01-01',
  String? to,
  bool active = true,
}) {
  return Promotion(
    id: id,
    code: id,
    name: name,
    discountType: type,
    value: value,
    appliesToServiceCodes: services,
    validFrom: from,
    validTo: to,
    isActive: active,
  );
}

Future<void> _pump(WidgetTester tester, _FakeRemote remote) async {
  tester.view.physicalSize = const Size(400, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [promotionsRemoteDataSourceProvider.overrideWithValue(remote)],
      child: const MaterialApp(home: PromotionsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('cada promoción dice qué rebaja, sobre qué y hasta cuándo', (tester) async {
    await _pump(
      tester,
      _FakeRemote([
        _promotion(id: 'domicilio_50', name: '50% en domicilio', services: ['delivery']),
        _promotion(
          id: 'edredon_q5',
          name: 'Q5 en edredones',
          type: DiscountType.fixedAmount,
          value: 500,
        ),
      ]),
    );

    expect(find.text('50% en domicilio'), findsOneWidget);
    expect(find.text('50% · 1 servicio · desde 01/01/2020'), findsOneWidget);
    expect(
      find.text('Q5.00 de menos · todo el pedido · desde 01/01/2020'),
      findsOneWidget,
    );
  });

  testWidgets('el badge distingue vigente, programada, vencida y apagada', (tester) async {
    await _pump(
      tester,
      _FakeRemote([
        // Los nombres no repiten los del badge a propósito: si coincidieran, el
        // test pasaría encontrando el nombre y no la etiqueta de vigencia.
        _promotion(id: 'ahora', name: 'La que corre hoy'),
        _promotion(id: 'luego', name: 'La que empieza en 2099', from: '2099-01-01'),
        _promotion(
          id: 'antes',
          name: 'La de febrero de 2020',
          from: '2020-01-01',
          to: '2020-02-01',
        ),
        _promotion(id: 'off', name: 'La que alguien apagó', active: false),
      ]),
    );

    for (final label in const ['Activa', 'Programada', 'Vencida', 'Apagada']) {
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });

  testWidgets('apagar una promoción se manda al servidor y se ve en la lista', (
    tester,
  ) async {
    final remote = _FakeRemote([_promotion(id: 'domicilio_50', name: '50% en domicilio')]);
    await _pump(tester, remote);

    expect(find.text('Activa'), findsOneWidget);

    await tester.tap(find.byTooltip('Apagar'));
    await tester.pumpAndSettle();

    expect(remote.toggles, [('domicilio_50', false)]);
    expect(find.text('Apagada'), findsOneWidget);
  });

  testWidgets('sin red lo dice y ofrece reintentar en vez de quedarse vacía', (
    tester,
  ) async {
    final remote = _FakeRemote([])..fails = true;
    await _pump(tester, remote);

    expect(find.textContaining('necesita conexión'), findsOneWidget);
    expect(find.widgetWithText(AppButton, 'Reintentar'), findsOneWidget);
  });

  testWidgets('sin promociones invita a crear la primera', (tester) async {
    await _pump(tester, _FakeRemote([]));

    expect(find.text('Todavía no hay promociones'), findsOneWidget);
  });
}
