import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:agri_connect/features/bluetooth/data/models/bluetooth_device_model.dart';
import 'package:agri_connect/features/bluetooth/data/datasources/bluetooth_remote_datasource.dart';

class BluetoothRemoteDataSourceImpl implements BluetoothRemoteDataSource {
  @override
  Future<bool> isBluetoothSupported() async {
    try {
      return await FlutterBluePlus.isSupported;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String> getBluetoothState() async {
    try {
      // Request Bluetooth permissions first
      await FlutterBluePlus.turnOn();
      
      final state = await FlutterBluePlus.adapterState.first;
      switch (state) {
        case BluetoothAdapterState.on:
          return 'Bluetooth is ON';
        case BluetoothAdapterState.off:
          return 'Bluetooth is OFF - Please enable Bluetooth';
        case BluetoothAdapterState.turningOn:
          return 'Bluetooth is turning ON';
        case BluetoothAdapterState.turningOff:
          return 'Bluetooth is turning OFF';
        default:
          return 'Bluetooth state: $state';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  @override
  Stream<List<BluetoothDeviceModel>> scanDevices() {
    try {
      // Start scanning
      FlutterBluePlus.startScan(timeout: Duration(seconds: 10));
      
      // Return the scan results stream
      return FlutterBluePlus.scanResults.map((results) {
        print('DEBUG: Found ${results.length} devices in scan results');
        return results.map((result) {
          return BluetoothDeviceModel(
            id: result.device.remoteId.toString(),
            name: result.device.platformName.isNotEmpty 
                ? result.device.platformName 
                : 'Unknown Device',
            rssi: result.rssi,
            isConnectable: result.advertisementData.connectable,
            advertisementData: {
              'txPowerLevel': result.advertisementData.txPowerLevel,
              'connectable': result.advertisementData.connectable,
              'manufacturerData': result.advertisementData.manufacturerData.map((key, value) => 
                MapEntry(key.toString(), value is List ? value.map((e) => e.toString()).toList() : value.toString())),
              'serviceData': result.advertisementData.serviceData.map((key, value) => 
                MapEntry(key.toString(), value is List ? value.map((e) => e.toString()).toList() : value.toString())),
              'serviceUuids': result.advertisementData.serviceUuids.map((uuid) => uuid.toString()).toList(),
            },
          );
        }).toList();
      });
    } catch (e) {
      // Return empty stream on error
      return Stream.value([]);
    }
  }

  @override
  Future<bool> connectToDevice(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.connect(timeout: Duration(seconds: 10));
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> disconnectFromDevice(String deviceId) async {
    try {
      final device = BluetoothDevice.fromId(deviceId);
      await device.disconnect();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<BluetoothDeviceModel>> getConnectedDevices() async {
    try {
      final devices = await FlutterBluePlus.connectedDevices;
      return devices.map((device) {
        return BluetoothDeviceModel(
          id: device.remoteId.toString(),
          name: device.platformName.isNotEmpty 
              ? device.platformName 
              : 'Unknown Device',
          rssi: 0, // Connected devices don't have RSSI
          isConnectable: true,
          advertisementData: {},
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
} 