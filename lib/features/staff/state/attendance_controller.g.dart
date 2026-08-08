// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$attendanceDayHash() => r'9de11eb87fad998fd6ed7ae9e7a6f6c664a51c31';

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

/// El personal activo con su día resuelto (§9.1).
///
/// Copied from [attendanceDay].
@ProviderFor(attendanceDay)
const attendanceDayProvider = AttendanceDayFamily();

/// El personal activo con su día resuelto (§9.1).
///
/// Copied from [attendanceDay].
class AttendanceDayFamily extends Family<AsyncValue<List<EmployeeDay>>> {
  /// El personal activo con su día resuelto (§9.1).
  ///
  /// Copied from [attendanceDay].
  const AttendanceDayFamily();

  /// El personal activo con su día resuelto (§9.1).
  ///
  /// Copied from [attendanceDay].
  AttendanceDayProvider call(String date) {
    return AttendanceDayProvider(date);
  }

  @override
  AttendanceDayProvider getProviderOverride(
    covariant AttendanceDayProvider provider,
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
  String? get name => r'attendanceDayProvider';
}

/// El personal activo con su día resuelto (§9.1).
///
/// Copied from [attendanceDay].
class AttendanceDayProvider
    extends AutoDisposeStreamProvider<List<EmployeeDay>> {
  /// El personal activo con su día resuelto (§9.1).
  ///
  /// Copied from [attendanceDay].
  AttendanceDayProvider(String date)
    : this._internal(
        (ref) => attendanceDay(ref as AttendanceDayRef, date),
        from: attendanceDayProvider,
        name: r'attendanceDayProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$attendanceDayHash,
        dependencies: AttendanceDayFamily._dependencies,
        allTransitiveDependencies:
            AttendanceDayFamily._allTransitiveDependencies,
        date: date,
      );

  AttendanceDayProvider._internal(
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
    Stream<List<EmployeeDay>> Function(AttendanceDayRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AttendanceDayProvider._internal(
        (ref) => create(ref as AttendanceDayRef),
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
  AutoDisposeStreamProviderElement<List<EmployeeDay>> createElement() {
    return _AttendanceDayProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AttendanceDayProvider && other.date == date;
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
mixin AttendanceDayRef on AutoDisposeStreamProviderRef<List<EmployeeDay>> {
  /// The parameter `date` of this provider.
  String get date;
}

class _AttendanceDayProviderElement
    extends AutoDisposeStreamProviderElement<List<EmployeeDay>>
    with AttendanceDayRef {
  _AttendanceDayProviderElement(super.provider);

  @override
  String get date => (origin as AttendanceDayProvider).date;
}

String _$workShiftsHash() => r'eddc995fa6c8ae2a0afb286d4924c26bc7c14a0b';

/// Los turnos que se pueden elegir al marcar.
///
/// Copied from [workShifts].
@ProviderFor(workShifts)
final workShiftsProvider = AutoDisposeStreamProvider<List<WorkShift>>.internal(
  workShifts,
  name: r'workShiftsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workShiftsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkShiftsRef = AutoDisposeStreamProviderRef<List<WorkShift>>;
String _$attendanceDateFilterHash() =>
    r'65f593ab1a1cf981cfc646864f9679629d7c484e';

/// El día que la asistencia está mirando. Por omisión el de negocio, igual que
/// la Caja: a las 19:00 en Cobán la jornada de hoy sigue siendo la de hoy.
///
/// Copied from [AttendanceDateFilter].
@ProviderFor(AttendanceDateFilter)
final attendanceDateFilterProvider =
    AutoDisposeNotifierProvider<AttendanceDateFilter, DateTime>.internal(
      AttendanceDateFilter.new,
      name: r'attendanceDateFilterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$attendanceDateFilterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AttendanceDateFilter = AutoDisposeNotifier<DateTime>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
