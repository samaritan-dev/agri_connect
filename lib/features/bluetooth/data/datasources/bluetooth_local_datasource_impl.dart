import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:app_agri_connect/features/bluetooth/data/models/bluetooth_device_model.dart';
import 'package:app_agri_connect/features/bluetooth/data/datasources/bluetooth_local_datasource.dart';

class BluetoothLocalDataSourceImpl implements BluetoothLocalDataSource {
  final SharedPreferences sharedPreferences;

  BluetoothLocalDataSourceImpl({required this.sharedPreferences});

  static const String CACHED_DEVICES_KEY = 'CACHED_DEVICES';
  static const String CACHED_CONNECTED_DEVICES_KEY = 'CACHED_CONNECTED_DEVICES';

  @override
  Future<void> cacheDevices(List<BluetoothDeviceModel> devices) async {
    final devicesJson = devices.map((device) => device.toJson()).toList();
    await sharedPreferences.setString(CACHED_DEVICES_KEY, json.encode(devicesJson));
  }

  @override
  Future<List<BluetoothDeviceModel>> getCachedDevices() async {
    final devicesString = sharedPreferences.getString(CACHED_DEVICES_KEY);
    if (devicesString != null) {
      final devicesJson = json.decode(devicesString) as List;
      return devicesJson.map((json) => BluetoothDeviceModel.fromJson(json)).toList();
    }
    return [];
  }

  @override
  Future<void> cacheConnectedDevice(BluetoothDeviceModel device) async {
    final connectedDevices = await getCachedConnectedDevices();
    final existingIndex = connectedDevices.indexWhere((d) => d.id == device.id);
    
    if (existingIndex >= 0) {
      connectedDevices[existingIndex] = device;
    } else {
      connectedDevices.add(device);
    }
    
    await cacheConnectedDevices(connectedDevices);
  }

  @override
  Future<List<BluetoothDeviceModel>> getCachedConnectedDevices() async {
    final devicesString = sharedPreferences.getString(CACHED_CONNECTED_DEVICES_KEY);
    if (devicesString != null) {
      final devicesJson = json.decode(devicesString) as List;
      return devicesJson.map((json) => BluetoothDeviceModel.fromJson(json)).toList();
    }
    return [];
  }

  Future<void> cacheConnectedDevices(List<BluetoothDeviceModel> devices) async {
    final devicesJson = devices.map((device) => device.toJson()).toList();
    await sharedPreferences.setString(CACHED_CONNECTED_DEVICES_KEY, json.encode(devicesJson));
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(CACHED_DEVICES_KEY);
    await sharedPreferences.remove(CACHED_CONNECTED_DEVICES_KEY);
  }
} 