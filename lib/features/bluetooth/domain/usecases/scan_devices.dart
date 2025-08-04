import 'dart:async';
import 'package:agri_connect/core/error/failures.dart';
import 'package:agri_connect/core/usecases/either.dart';
import 'package:agri_connect/core/usecases/usecase.dart';
import 'package:agri_connect/features/bluetooth/domain/entities/bluetooth_device.dart';
import 'package:agri_connect/features/bluetooth/domain/repositories/bluetooth_repository.dart';

class ScanDevices implements UseCase<Stream<Either<Failure, List<BluetoothDevice>>>, NoParams> {
  final BluetoothRepository repository;

  ScanDevices(this.repository);

  @override
  Future<Stream<Either<Failure, List<BluetoothDevice>>>> call(NoParams params) async {
    return repository.scanDevices();
  }
} 