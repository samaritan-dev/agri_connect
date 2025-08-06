import 'package:equatable/equatable.dart';

import 'package:app_agri_connect/core/error/failures.dart';
import 'package:app_agri_connect/core/usecases/either.dart';
import 'package:app_agri_connect/core/usecases/usecase.dart';
import 'package:app_agri_connect/features/bluetooth/domain/repositories/bluetooth_repository.dart';

class ConnectDeviceParams extends Equatable {
  final String deviceId;

  const ConnectDeviceParams({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}

class ConnectDevice implements UseCase<Either<Failure, bool>, ConnectDeviceParams> {
  final BluetoothRepository repository;

  ConnectDevice(this.repository);

  @override
  Future<Either<Failure, bool>> call(ConnectDeviceParams params) async {
    return repository.connectToDevice(params.deviceId);
  }
} 