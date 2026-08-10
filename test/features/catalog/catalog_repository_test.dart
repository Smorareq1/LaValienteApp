import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:la_valiente/core/database/app_database.dart';
import 'package:la_valiente/features/catalog/data/catalog_mirrors.dart';
import 'package:la_valiente/features/catalog/data/catalog_repository.dart';
import 'package:la_valiente/features/catalog/models/catalog.dart';
import 'package:la_valiente/features/sync/models/sync_change.dart';

SyncChange _change(String entity, String id, Map<String, dynamic> data, {bool deleted = false}) {
  return SyncChange(
    entity: entity,
    id: id,
    version: 1,
    syncSeq: 1,
    deleted: deleted,
    data: data,
  );
}

void main() {
  late AppDatabase database;
  late CatalogRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = CatalogRepository(database);
  });

  tearDown(() => database.close());

  Future<void> applyService(
    String id, {
    required String name,
    String mode = 'per_unit',
    int sortOrder = 0,
    bool active = true,
    bool deleted = false,
  }) {
    return ServiceTypeMirror(database).apply(
      _change('service_type', id, {
        'code': id,
        'name': name,
        'pricing_mode': mode,
        'unit_label': 'lb',
        'is_active': active,
        'sort_order': sortOrder,
      }, deleted: deleted),
    );
  }

  Future<void> applyOption(
    String id, {
    required String serviceId,
    required String name,
    int? min,
    int? max,
    int sortOrder = 0,
  }) {
    return ServiceOptionMirror(database).apply(
      _change('service_option', id, {
        'service_type_id': serviceId,
        'code': id,
        'name': name,
        'min_quantity': min,
        'max_quantity': max,
        'is_active': true,
        'sort_order': sortOrder,
      }),
    );
  }

  Future<void> applyPrice(
    String id, {
    required String serviceId,
    String? optionId,
    required String amount,
    required String from,
    String? to,
  }) {
    return ServicePriceMirror(database).apply(
      _change('service_price', id, {
        'service_type_id': serviceId,
        'service_option_id': optionId,
        'price': amount,
        'valid_from': from,
        'valid_to': to,
      }),
    );
  }

  group('servicios', () {
    test('salen en el orden configurado, con sus opciones', () async {
      await applyService('lavado', name: 'Lavado por libra', sortOrder: 1);
      await applyService('tinas', name: 'Tinas', mode: 'tiered', sortOrder: 0);
      await applyOption('t1', serviceId: 'tinas', name: 'Tina chica', sortOrder: 0);
      await applyOption('t2', serviceId: 'tinas', name: 'Tina grande', sortOrder: 1);

      final services = await repository.watchServices().first;

      expect(services.map((service) => service.name), ['Tinas', 'Lavado por libra']);
      expect(services.first.options.map((option) => option.name), [
        'Tina chica',
        'Tina grande',
      ]);
      expect(services.last.options, isEmpty);
    });

    test('un servicio inactivo o borrado desaparece del mostrador', () async {
      await applyService('viejo', name: 'Servicio retirado', active: false);
      await applyService('otro', name: 'Servicio borrado', deleted: true);
      await applyService('vivo', name: 'Servicio vigente');

      final services = await repository.watchServices().first;

      expect(services.map((service) => service.name), ['Servicio vigente']);
    });

    test('una modalidad de precio desconocida no se adivina', () async {
      // El servidor puede estrenar una modalidad antes de que esta versión de
      // la app sepa qué hacer con ella; interpretarla a medias sería peor.
      await applyService('raro', name: 'Servicio futuro', mode: 'por_kilometro');

      expect((await repository.watchServices().first).single.pricingMode, isNull);
    });

    test('las opciones saben a qué cantidad de piezas corresponden', () async {
      await applyService('mano', name: 'Lavado a mano', mode: 'tiered');
      await applyOption('n2', serviceId: 'mano', name: 'N2', min: 1, max: 4);

      final option = (await repository.watchServices().first).single.options.single;

      expect(option.covers(1), isTrue);
      expect(option.covers(4), isTrue);
      expect(option.covers(5), isFalse);
    });
  });

  group('precios', () {
    test('devuelve el vigente en la fecha del pedido', () async {
      await applyPrice('p1', serviceId: 's1', amount: '5.00', from: '2026-01-01', to: '2026-06-30');
      await applyPrice('p2', serviceId: 's1', amount: '6.00', from: '2026-07-01');

      final antiguo = await repository.priceFor(serviceTypeId: 's1', onDate: '2026-03-15');
      final vigente = await repository.priceFor(serviceTypeId: 's1', onDate: '2026-08-02');

      // Un pedido de marzo se sigue cotizando con el precio de marzo: los
      // precios no se editan, se sustituyen (plan 0001 D1).
      expect(antiguo!.amount, '5.00');
      expect(vigente!.amount, '6.00');
    });

    test('sin precio vigente devuelve null en vez de inventar uno', () async {
      await applyPrice('p1', serviceId: 's1', amount: '5.00', from: '2026-01-01', to: '2026-06-30');

      expect(await repository.priceFor(serviceTypeId: 's1', onDate: '2026-08-02'), isNull);
    });

    test('el precio de una opción no se confunde con el del servicio', () async {
      await applyPrice('base', serviceId: 's1', amount: '5.00', from: '2026-01-01');
      await applyPrice(
        'opcion',
        serviceId: 's1',
        optionId: 'o1',
        amount: '30.00',
        from: '2026-01-01',
      );

      final sinOpcion = await repository.priceFor(serviceTypeId: 's1', onDate: '2026-08-02');
      final conOpcion = await repository.priceFor(
        serviceTypeId: 's1',
        serviceOptionId: 'o1',
        onDate: '2026-08-02',
      );

      expect(sinOpcion!.amount, '5.00');
      expect(conOpcion!.amount, '30.00');
    });

    test('el monto conserva los centavos exactos del servidor', () async {
      await applyPrice('p1', serviceId: 's1', amount: '12.35', from: '2026-01-01');

      final price = await repository.priceFor(serviceTypeId: 's1', onDate: '2026-08-02');

      expect(price!.amount, '12.35');
      expect(price, isA<ServicePrice>());
    });
  });

  group('prendas', () {
    test('solo las activas y en su orden', () async {
      final mirror = GarmentTypeMirror(database);
      await mirror.apply(
        _change('garment_type', 'g1', {
          'name': 'Camisa',
          'notes': null,
          'is_active': true,
          'sort_order': 1,
        }),
      );
      await mirror.apply(
        _change('garment_type', 'g2', {
          'name': 'Pantalón',
          'notes': null,
          'is_active': true,
          'sort_order': 0,
        }),
      );
      await mirror.apply(
        _change('garment_type', 'g3', {
          'name': 'Retirada',
          'notes': null,
          'is_active': false,
          'sort_order': 2,
        }),
      );

      final garments = await repository.watchGarmentTypes().first;

      expect(garments.map((garment) => garment.name), ['Pantalón', 'Camisa']);
    });
  });
}
