import 'package:shared_preferences/shared_preferences.dart';
import 'package:agri_connect/features/bluetooth/data/models/bluetooth_device_model.dart';

abstract class BluetoothLocalDataSource {
  Future<void> cacheDevices(List<BluetoothDeviceModel> devices);
  Future<List<BluetoothDeviceModel>> getCachedDevices();
  Future<void> cacheConnectedDevice(BluetoothDeviceModel device);
  Future<List<BluetoothDeviceModel>> getCachedConnectedDevices();
  Future<void> clearCache();
} 