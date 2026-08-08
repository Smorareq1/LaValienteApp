// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_day_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$cashOrderPaymentsHash() => r'81edb42607c995e89674defff6e2f3ad6383a3d5';

/// Los cobros de pedidos del día.
///
/// Copied from [cashOrderPayments].
@ProviderFor(cashOrderPayments)
final cashOrderPaymentsProvider =
    AutoDisposeStreamProvider<List<CashEntry>>.internal(
      cashOrderPayments,
      name: r'cashOrderPaymentsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cashOrderPaymentsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CashOrderPaymentsRef = AutoDisposeStreamProviderRef<List<CashEntry>>;
String _$cashSupplySalesHash() => r'0fc5fcad7ea78f3e0870ebf1fa025834861f205b';

/// Las ventas de insumo del día.
///
/// Copied from [cashSupplySales].
@ProviderFor(cashSupplySales)
final cashSupplySalesProvider =
    AutoDisposeStreamProvider<List<SupplySaleSummary>>.internal(
      cashSupplySales,
      name: r'cashSupplySalesProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$cashSupplySalesHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CashSupplySalesRef =
    AutoDisposeStreamProviderRef<List<SupplySaleSummary>>;
String _$cashExpensesHash() => r'5f8c98fcc1f5ea52bb78c8d7b4885bc95782f9ba';

/// Los gastos del día.
///
/// Copied from [cashExpenses].
@ProviderFor(cashExpenses)
final cashExpensesProvider = AutoDisposeStreamProvider<List<Expense>>.internal(
  cashExpenses,
  name: r'cashExpensesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cashExpensesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CashExpensesRef = AutoDisposeStreamProviderRef<List<Expense>>;
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
String _$cashClosureHash() => r'92991c6763f3d12e10b1e3b611c9d916e00abf56';

/// El acta, si la fecha ya se cerró.
///
/// Copied from [cashClosure].
@ProviderFor(cashClosure)
final cashClosureProvider = AutoDisposeStreamProvider<DayClosure?>.internal(
  cashClosure,
  name: r'cashClosureProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cashClosureHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CashClosureRef = AutoDisposeStreamProviderRef<DayClosure?>;
String _$cashDayHash() => r'12d89aba9cc24a78fbded36aa955631c1a77801b';

/// El día entero, armado de sus cuatro fuentes.
///
/// Se compone aquí y no en una consulta porque son cuatro tablas que no se
/// pueden unir con sentido: un cobro, una venta y un gasto no comparten ni
/// columnas ni fecha de corte. Cada una llega en vivo y la suma se rehace sola.
///
/// Copied from [cashDay].
@ProviderFor(cashDay)
final cashDayProvider = AutoDisposeProvider<CashDay>.internal(
  cashDay,
  name: r'cashDayProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cashDayHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CashDayRef = AutoDisposeProviderRef<CashDay>;
String _$cashDayIsLockedHash() => r'929f1dc1a8791b4fb1d50ae7b6c50d61b858fbce';

/// Si la fecha que se está mirando admite escrituras.
///
/// Es el candado del §14: un día cerrado se lee, no se escribe. La comprobación
/// de verdad la hace el servidor —el candado vive en sus services (plan 0005
/// D9)— y esto es para no ofrecer un botón que va a terminar en la cola de
/// revisión con el papel ya firmado.
///
/// Copied from [cashDayIsLocked].
@ProviderFor(cashDayIsLocked)
final cashDayIsLockedProvider = AutoDisposeProvider<bool>.internal(
  cashDayIsLocked,
  name: r'cashDayIsLockedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$cashDayIsLockedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CashDayIsLockedRef = AutoDisposeProviderRef<bool>;
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
