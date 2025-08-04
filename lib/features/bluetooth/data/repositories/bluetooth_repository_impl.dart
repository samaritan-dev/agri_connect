import 'dart:async';
import 'package:agri_connect/core/error/failures.dart';
import 'package:agri_connect/core/usecases/either.dart';
import 'package:agri_connect/features/bluetooth/domain/entities/bluetooth_device.dart';
import 'package:agri_connect/features/bluetooth/domain/repositories/bluetooth_repository.dart';
import 'package:agri_connect/features/bluetooth/data/datasources/bluetooth_local_datasource.dart';
import 'package:agri_connect/features/bluetooth/data/datasources/bluetooth_remote_datasource.dart';
import 'package:agri_connect/features/bluetooth/data/models/bluetooth_device_model.dart';

class BluetoothRepositoryImpl implements BluetoothRepository {
  final BluetoothRemoteDataSource remoteDataSource;
  final BluetoothLocalDataSource localDataSource;

  BluetoothRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, bool>> isBluetoothSupported() async {
    try {
      final isSupported = await remoteDataSource.isBluetoothSupported();
      return Right(isSupported);
    } catch (e) {
      return Left(BluetoothFailure('Failed to check Bluetooth support: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getBluetoothState() async {
    try {
      final state = await remoteDataSource.getBluetoothState();
      return Right(state);
    } catch (e) {
      return Left(BluetoothFailure('Failed to get Bluetooth state: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<BluetoothDevice>>> scanDevices() {
    print('DEBUG Repository: Starting scan devices stream');
    return remoteDataSource.scanDevices().map<Either<Failure, List<BluetoothDevice>>>((deviceModels) {
      print('DEBUG Repository: Received ${deviceModels.length} device models');
      // Convert BluetoothDeviceModel to BluetoothDevice
      final devices = deviceModels.map((model) => model as BluetoothDevice).toList();
      print('DEBUG Repository: Converted to ${devices.length} devices');
      // Cache the devices locally
      localDataSource.cacheDevices(deviceModels);
      return Right(devices);
    });
  }

  @override
  Future<Either<Failure, bool>> connectToDevice(String deviceId) async {
    try {
      final success = await remoteDataSource.connectToDevice(deviceId);
      if (success) {
        // Get connected devices and cache the newly connected one
        final connectedDevices = await remoteDataSource.getConnectedDevices();
        final connectedDevice = connectedDevices.firstWhere(
          (device) => device.id == deviceId,
          orElse: () => BluetoothDeviceModel(
            id: deviceId,
            name: 'Connected Device',
            rssi: 0,
            isConnectable: true,
            advertisementData: {},
          ),
        );
        await localDataSource.cacheConnectedDevice(connectedDevice);
      }
      return Right(success);
    } catch (e) {
      return Left(BluetoothFailure('Failed to connect to device: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> disconnectFromDevice(String deviceId) async {
    try {
      final success = await remoteDataSource.disconnectFromDevice(deviceId);
      return Right(success);
    } catch (e) {
      return Left(BluetoothFailure('Failed to disconnect from device: $e'));
    }
  }

  @override
  Future<Either<Failure, List<BluetoothDevice>>> getConnectedDevices() async {
    try {
      final deviceModels = await remoteDataSource.getConnectedDevices();
      // Convert BluetoothDeviceModel to BluetoothDevice
      final devices = deviceModels.map((model) => model as BluetoothDevice).toList();
      return Right(devices);
    } catch (e) {
      return Left(BluetoothFailure('Failed to get connected devices: $e'));
    }
  }
} 