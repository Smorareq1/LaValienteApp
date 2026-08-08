// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_day_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cashOrderPaymentsHash() => r'9604cfca51b5182fa2ef9b4c0dd05821ba50492c';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Los cobros de pedidos de una fecha.
///
/// Copied from [cashOrderPayments].
@ProviderFor(cashOrderPayments)
const cashOrderPaymentsProvider = CashOrderPaymentsFamily();

/// Los cobros de pedidos de una fecha.
///
/// Copied from [cashOrderPayments].
class CashOrderPaymentsFamily extends Family<AsyncValue<List<CashEntry>>> {
  /// Los cobros de pedidos de una fecha.
  ///
  /// Copied from [cashOrderPayments].
  const CashOrderPaymentsFamily();

  /// Los cobros de pedidos de una fecha.
  ///
  /// Copied from [cashOrderPayments].
  CashOrderPaymentsProvider call(String date) {
    return CashOrderPaymentsProvider(date);
  }

  @override
  CashOrderPaymentsProvider getProviderOverride(
    covariant CashOrderPaymentsProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cashOrderPaymentsProvider';
}

/// Los cobros de pedidos de una fecha.
///
/// Copied from [cashOrderPayments].
class CashOrderPaymentsProvider
    extends AutoDisposeStreamProvider<List<CashEntry>> {
  /// Los cobros de pedidos de una fecha.
  ///
  /// Copied from [cashOrderPayments].
  CashOrderPaymentsProvider(String date)
    : this._internal(
        (ref) => cashOrderPayments(ref as CashOrderPaymentsRef, date),
        from: cashOrderPaymentsProvider,
        name: r'cashOrderPaymentsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cashOrderPaymentsHash,
        dependencies: CashOrderPaymentsFamily._dependencies,
        allTransitiveDependencies:
            CashOrderPaymentsFamily._allTransitiveDependencies,
        date: date,
      );

  CashOrderPaymentsProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  Override overrideWith(
    Stream<List<CashEntry>> Function(CashOrderPaymentsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CashOrderPaymentsProvider._internal(
        (ref) => create(ref as CashOrderPaymentsRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<CashEntry>> createElement() {
    return _CashOrderPaymentsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CashOrderPaymentsProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CashOrderPaymentsRef on AutoDisposeStreamProviderRef<List<CashEntry>> {
  /// The parameter `date` of this provider.
  String get date;
}

class _CashOrderPaymentsProviderElement
    extends AutoDisposeStreamProviderElement<List<CashEntry>>
    with CashOrderPaymentsRef {
  _CashOrderPaymentsProviderElement(super.provider);

  @override
  String get date => (origin as CashOrderPaymentsProvider).date;
}

String _$cashSupplySalesHash() => r'40f86543dc53e5c0779dd3b2742fe7265d0d8ace';

/// Las ventas de insumo de una fecha.
///
/// Copied from [cashSupplySales].
@ProviderFor(cashSupplySales)
const cashSupplySalesProvider = CashSupplySalesFamily();

/// Las ventas de insumo de una fecha.
///
/// Copied from [cashSupplySales].
class CashSupplySalesFamily
    extends Family<AsyncValue<List<SupplySaleSummary>>> {
  /// Las ventas de insumo de una fecha.
  ///
  /// Copied from [cashSupplySales].
  const CashSupplySalesFamily();

  /// Las ventas de insumo de una fecha.
  ///
  /// Copied from [cashSupplySales].
  CashSupplySalesProvider call(String date) {
    return CashSupplySalesProvider(date);
  }

  @override
  CashSupplySalesProvider getProviderOverride(
    covariant CashSupplySalesProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cashSupplySalesProvider';
}

/// Las ventas de insumo de una fecha.
///
/// Copied from [cashSupplySales].
class CashSupplySalesProvider
    extends AutoDisposeStreamProvider<List<SupplySaleSummary>> {
  /// Las ventas de insumo de una fecha.
  ///
  /// Copied from [cashSupplySales].
  CashSupplySalesProvider(String date)
    : this._internal(
        (ref) => cashSupplySales(ref as CashSupplySalesRef, date),
        from: cashSupplySalesProvider,
        name: r'cashSupplySalesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cashSupplySalesHash,
        dependencies: CashSupplySalesFamily._dependencies,
        allTransitiveDependencies:
            CashSupplySalesFamily._allTransitiveDependencies,
        date: date,
      );

  CashSupplySalesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  Override overrideWith(
    Stream<List<SupplySaleSummary>> Function(CashSupplySalesRef provider)
    create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CashSupplySalesProvider._internal(
        (ref) => create(ref as CashSupplySalesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<SupplySaleSummary>> createElement() {
    return _CashSupplySalesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CashSupplySalesProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CashSupplySalesRef
    on AutoDisposeStreamProviderRef<List<SupplySaleSummary>> {
  /// The parameter `date` of this provider.
  String get date;
}

class _CashSupplySalesProviderElement
    extends AutoDisposeStreamProviderElement<List<SupplySaleSummary>>
    with CashSupplySalesRef {
  _CashSupplySalesProviderElement(super.provider);

  @override
  String get date => (origin as CashSupplySalesProvider).date;
}

String _$cashExpensesHash() => r'14edbd17b8e9652ab7dd95cd171fb28eee631283';

/// Los gastos de una fecha.
///
/// Copied from [cashExpenses].
@ProviderFor(cashExpenses)
const cashExpensesProvider = CashExpensesFamily();

/// Los gastos de una fecha.
///
/// Copied from [cashExpenses].
class CashExpensesFamily extends Family<AsyncValue<List<Expense>>> {
  /// Los gastos de una fecha.
  ///
  /// Copied from [cashExpenses].
  const CashExpensesFamily();

  /// Los gastos de una fecha.
  ///
  /// Copied from [cashExpenses].
  CashExpensesProvider call(String date) {
    return CashExpensesProvider(date);
  }

  @override
  CashExpensesProvider getProviderOverride(
    covariant CashExpensesProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cashExpensesProvider';
}

/// Los gastos de una fecha.
///
/// Copied from [cashExpenses].
class CashExpensesProvider extends AutoDisposeStreamProvider<List<Expense>> {
  /// Los gastos de una fecha.
  ///
  /// Copied from [cashExpenses].
  CashExpensesProvider(String date)
    : this._internal(
        (ref) => cashExpenses(ref as CashExpensesRef, date),
        from: cashExpensesProvider,
        name: r'cashExpensesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cashExpensesHash,
        dependencies: CashExpensesFamily._dependencies,
        allTransitiveDependencies:
            CashExpensesFamily._allTransitiveDependencies,
        date: date,
      );

  CashExpensesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  Override overrideWith(
    Stream<List<Expense>> Function(CashExpensesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CashExpensesProvider._internal(
        (ref) => create(ref as CashExpensesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<Expense>> createElement() {
    return _CashExpensesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CashExpensesProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CashExpensesRef on AutoDisposeStreamProviderRef<List<Expense>> {
  /// The parameter `date` of this provider.
  String get date;
}

class _CashExpensesProviderElement
    extends AutoDisposeStreamProviderElement<List<Expense>>
    with CashExpensesRef {
  _CashExpensesProviderElement(super.provider);

  @override
  String get date => (origin as CashExpensesProvider).date;
}

String _$cashExpensesCategoriesHash() =>
    r'2af98f46814c733fc756e5711530a0752a745a02';

/// Las categorías que el formulario de gasto puede ofrecer.
///
/// Bajan del feed y se administran en línea (D11), así que un teléfono que nunca
/// sincronizó no tiene ninguna — y el formulario lo dice en vez de mostrar una
/// lista vacía sin explicación.
///
/// Copied from [cashExpensesCategories].
@ProviderFor(cashExpensesCategories)
final cashExpensesCategoriesProvider =
    AutoDisposeStreamProvider<List<ExpenseCategory>>.internal(
      cashExpensesCategories,
      name: r'cashExpensesCategoriesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cashExpensesCategoriesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CashExpensesCategoriesRef =
    AutoDisposeStreamProviderRef<List<ExpenseCategory>>;
String _$cashClosureHash() => r'3f1d89c9722988dd97e61b4bc5e045ee578b3118';

/// El acta, si la fecha ya se cerró.
///
/// Copied from [cashClosure].
@ProviderFor(cashClosure)
const cashClosureProvider = CashClosureFamily();

/// El acta, si la fecha ya se cerró.
///
/// Copied from [cashClosure].
class CashClosureFamily extends Family<AsyncValue<DayClosure?>> {
  /// El acta, si la fecha ya se cerró.
  ///
  /// Copied from [cashClosure].
  const CashClosureFamily();

  /// El acta, si la fecha ya se cerró.
  ///
  /// Copied from [cashClosure].
  CashClosureProvider call(String date) {
    return CashClosureProvider(date);
  }

  @override
  CashClosureProvider getProviderOverride(
    covariant CashClosureProvider provider,
  ) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cashClosureProvider';
}

/// El acta, si la fecha ya se cerró.
///
/// Copied from [cashClosure].
class CashClosureProvider extends AutoDisposeStreamProvider<DayClosure?> {
  /// El acta, si la fecha ya se cerró.
  ///
  /// Copied from [cashClosure].
  CashClosureProvider(String date)
    : this._internal(
        (ref) => cashClosure(ref as CashClosureRef, date),
        from: cashClosureProvider,
        name: r'cashClosureProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cashClosureHash,
        dependencies: CashClosureFamily._dependencies,
        allTransitiveDependencies: CashClosureFamily._allTransitiveDependencies,
        date: date,
      );

  CashClosureProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  Override overrideWith(
    Stream<DayClosure?> Function(CashClosureRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: CashClosureProvider._internal(
        (ref) => create(ref as CashClosureRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<DayClosure?> createElement() {
    return _CashClosureProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CashClosureProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CashClosureRef on AutoDisposeStreamProviderRef<DayClosure?> {
  /// The parameter `date` of this provider.
  String get date;
}

class _CashClosureProviderElement
    extends AutoDisposeStreamProviderElement<DayClosure?>
    with CashClosureRef {
  _CashClosureProviderElement(super.provider);

  @override
  String get date => (origin as CashClosureProvider).date;
}

String _$cashDayHash() => r'c4d386554aa231df35881329eabd3a1c1df31fda';

/// El día entero, armado de sus cuatro fuentes.
///
/// Se compone aquí y no en una consulta porque son cuatro tablas que no se
/// pueden unir con sentido: un cobro, una venta y un gasto no comparten ni
/// columnas ni fecha de corte. Cada una llega en vivo y la suma se rehace sola.
///
/// Recibe la fecha en vez de leer el filtro de la pantalla: la Caja mira el día
/// que alguien eligió con el calendario e Inicio mira siempre hoy. Atarlo al
/// filtro haría que abrir el calendario en Caja cambiara las cifras de Inicio.
///
/// Copied from [cashDay].
@ProviderFor(cashDay)
const cashDayProvider = CashDayFamily();

/// El día entero, armado de sus cuatro fuentes.
///
/// Se compone aquí y no en una consulta porque son cuatro tablas que no se
/// pueden unir con sentido: un cobro, una venta y un gasto no comparten ni
/// columnas ni fecha de corte. Cada una llega en vivo y la suma se rehace sola.
///
/// Recibe la fecha en vez de leer el filtro de la pantalla: la Caja mira el día
/// que alguien eligió con el calendario e Inicio mira siempre hoy. Atarlo al
/// filtro haría que abrir el calendario en Caja cambiara las cifras de Inicio.
///
/// Copied from [cashDay].
class CashDayFamily extends Family<CashDay> {
  /// El día entero, armado de sus cuatro fuentes.
  ///
  /// Se compone aquí y no en una consulta porque son cuatro tablas que no se
  /// pueden unir con sentido: un cobro, una venta y un gasto no comparten ni
  /// columnas ni fecha de corte. Cada una llega en vivo y la suma se rehace sola.
  ///
  /// Recibe la fecha en vez de leer el filtro de la pantalla: la Caja mira el día
  /// que alguien eligió con el calendario e Inicio mira siempre hoy. Atarlo al
  /// filtro haría que abrir el calendario en Caja cambiara las cifras de Inicio.
  ///
  /// Copied from [cashDay].
  const CashDayFamily();

  /// El día entero, armado de sus cuatro fuentes.
  ///
  /// Se compone aquí y no en una consulta porque son cuatro tablas que no se
  /// pueden unir con sentido: un cobro, una venta y un gasto no comparten ni
  /// columnas ni fecha de corte. Cada una llega en vivo y la suma se rehace sola.
  ///
  /// Recibe la fecha en vez de leer el filtro de la pantalla: la Caja mira el día
  /// que alguien eligió con el calendario e Inicio mira siempre hoy. Atarlo al
  /// filtro haría que abrir el calendario en Caja cambiara las cifras de Inicio.
  ///
  /// Copied from [cashDay].
  CashDayProvider call(String date) {
    return CashDayProvider(date);
  }

  @override
  CashDayProvider getProviderOverride(covariant CashDayProvider provider) {
    return call(provider.date);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'cashDayProvider';
}

/// El día entero, armado de sus cuatro fuentes.
///
/// Se compone aquí y no en una consulta porque son cuatro tablas que no se
/// pueden unir con sentido: un cobro, una venta y un gasto no comparten ni
/// columnas ni fecha de corte. Cada una llega en vivo y la suma se rehace sola.
///
/// Recibe la fecha en vez de leer el filtro de la pantalla: la Caja mira el día
/// que alguien eligió con el calendario e Inicio mira siempre hoy. Atarlo al
/// filtro haría que abrir el calendario en Caja cambiara las cifras de Inicio.
///
/// Copied from [cashDay].
class CashDayProvider extends AutoDisposeProvider<CashDay> {
  /// El día entero, armado de sus cuatro fuentes.
  ///
  /// Se compone aquí y no en una consulta porque son cuatro tablas que no se
  /// pueden unir con sentido: un cobro, una venta y un gasto no comparten ni
  /// columnas ni fecha de corte. Cada una llega en vivo y la suma se rehace sola.
  ///
  /// Recibe la fecha en vez de leer el filtro de la pantalla: la Caja mira el día
  /// que alguien eligió con el calendario e Inicio mira siempre hoy. Atarlo al
  /// filtro haría que abrir el calendario en Caja cambiara las cifras de Inicio.
  ///
  /// Copied from [cashDay].
  CashDayProvider(String date)
    : this._internal(
        (ref) => cashDay(ref as CashDayRef, date),
        from: cashDayProvider,
        name: r'cashDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$cashDayHash,
        dependencies: CashDayFamily._dependencies,
        allTransitiveDependencies: CashDayFamily._allTransitiveDependencies,
        date: date,
      );

  CashDayProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.date,
  }) : super.internal();

  final String date;

  @override
  Override overrideWith(CashDay Function(CashDayRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: CashDayProvider._internal(
        (ref) => create(ref as CashDayRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        date: date,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<CashDay> createElement() {
    return _CashDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CashDayProvider && other.date == date;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, date.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin CashDayRef on AutoDisposeProviderRef<CashDay> {
  /// The parameter `date` of this provider.
  String get date;
}

class _CashDayProviderElement extends AutoDisposeProviderElement<CashDay>
    with CashDayRef {
  _CashDayProviderElement(super.provider);

  @override
  String get date => (origin as CashDayProvider).date;
}

String _$selectedCashDayHash() => r'f411e798e57c39e56736b0385f516c70dc2f5acc';

/// El día que la pantalla de Caja está mirando: [cashDay] con la fecha del chip.
///
/// De aquí sale el candado del §14 —un día cerrado se lee, no se escribe—. La
/// comprobación de verdad la hace el servidor, porque el candado vive en sus
/// services (plan 0005 D9); esto es para no ofrecer un botón que va a terminar
/// en la cola de revisión con el papel ya firmado.
///
/// Copied from [selectedCashDay].
@ProviderFor(selectedCashDay)
final selectedCashDayProvider = AutoDisposeProvider<CashDay>.internal(
  selectedCashDay,
  name: r'selectedCashDayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$selectedCashDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SelectedCashDayRef = AutoDisposeProviderRef<CashDay>;
String _$cashDateFilterHash() => r'1f9f62fc335fd8fddbc2da686673fda323861152';

/// El día que la Caja está mirando. Por omisión el de negocio (plan 0001 D8): a
/// las 19:00 en Cobán la caja del día sigue siendo la de hoy, aunque en UTC ya
/// sea mañana.
///
/// Copied from [CashDateFilter].
@ProviderFor(CashDateFilter)
final cashDateFilterProvider =
    AutoDisposeNotifierProvider<CashDateFilter, DateTime>.internal(
      CashDateFilter.new,
      name: r'cashDateFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cashDateFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CashDateFilter = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
