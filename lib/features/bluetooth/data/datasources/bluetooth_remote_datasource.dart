import 'package:app_agri_connect/features/bluetooth/data/models/bluetooth_device_model.dart';

abstract class BluetoothRemoteDataSource {
  Future<bool> isBluetoothSupported();
  Future<String> getBluetoothState();
  Stream<List<BluetoothDeviceModel>> scanDevices();
  Future<bool> connectToDevice(String deviceId);
  Future<bool> disconnectFromDevice(String deviceId);
  Future<List<BluetoothDeviceModel>> getConnectedDevices();
  Future<String> getLocalDeviceName();
} 