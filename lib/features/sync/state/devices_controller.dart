import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_failure.dart';
import '../data/devices_remote_datasource.dart';

part 'devices_controller.g.dart';

/// Los dispositivos registrados (Plan 0006 §12).
@riverpod
class DevicesController extends _$DevicesController {
  @override
  Future<List<SyncDevice>> build() =>
      ref.watch(devicesRemoteDataSourceProvider).list();

  Future<Either<AppFailure, SyncDevice>> revoke(String id) async {
    try {
      final revoked = await ref.read(devicesRemoteDataSourceProvider).revoke(id);
      final current = state.valueOrNull;
      if (current != null) {
        state = AsyncData([
          for (final device in current)
            if (device.id == revoked.id) revoked else device,
        ]);
      }
      return Right(revoked);
    } catch (error) {
      return Left(AppFailure.fromException(error));
    }
  }
}
