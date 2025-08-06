import 'package:equatable/equatable.dart';

import 'package:app_agri_connect/core/error/failures.dart';
import 'package:app_agri_connect/core/usecases/either.dart';
import 'package:app_agri_connect/core/usecases/usecase.dart';
import 'package:app_agri_connect/features/bluetooth/domain/entities/bluetooth_device.dart';
import 'package:app_agri_connect/features/bluetooth/domain/repositories/bluetooth_repository.dart';

class GetConnectedDevicesParams extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetConnectedDevicesUseCase implements UseCase<Either<Failure, List<BluetoothDevice>>, GetConnectedDevicesParams> {
  final BluetoothRepository repository;

  GetConnectedDevicesUseCase(this.repository);

  @override
  Future<Either<Failure, List<BluetoothDevice>>> call(GetConnectedDevicesParams params) async {
    return await repository.getConnectedDevices();
  }
} 