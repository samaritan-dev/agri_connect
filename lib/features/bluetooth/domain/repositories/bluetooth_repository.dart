import 'package:app_agri_connect/features/bluetooth/domain/entities/bluetooth_device.dart';
import 'package:app_agri_connect/core/error/failures.dart';
import 'package:app_agri_connect/core/usecases/either.dart';

abstract class BluetoothRepository {
  Future<Either<Failure, bool>> isBluetoothSupported();
  Future<Either<Failure, String>> getBluetoothState();
  Stream<Either<Failure, List<BluetoothDevice>>> scanDevices();
  Future<Either<Failure, bool>> connectToDevice(String deviceId);
  Future<Either<Failure, bool>> disconnectFromDevice(String deviceId);
  Future<Either<Failure, List<BluetoothDevice>>> getConnectedDevices();
  Future<Either<Failure, String>> getLocalDeviceName();
  Future<Either<Failure, bool>> sendCommand(String deviceId, String command, Map<String, dynamic>? parameters);
} 