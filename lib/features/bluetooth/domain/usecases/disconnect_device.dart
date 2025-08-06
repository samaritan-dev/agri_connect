import 'package:equatable/equatable.dart';

import 'package:app_agri_connect/core/error/failures.dart';
import 'package:app_agri_connect/core/usecases/either.dart';
import 'package:app_agri_connect/core/usecases/usecase.dart';
import 'package:app_agri_connect/features/bluetooth/domain/repositories/bluetooth_repository.dart';

class DisconnectDeviceParams extends Equatable {
  final String deviceId;

  const DisconnectDeviceParams({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}

class DisconnectDevice implements UseCase<Either<Failure, bool>, DisconnectDeviceParams> {
  final BluetoothRepository repository;

  DisconnectDevice(this.repository);

  @override
  Future<Either<Failure, bool>> call(DisconnectDeviceParams params) async {
    return repository.disconnectFromDevice(params.deviceId);
  }
} 