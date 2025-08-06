import 'package:flutter_blue_plus/flutter_blue_plus.dart';

import 'package:app_agri_connect/features/bluetooth/data/models/bluetooth_device_model.dart';
import 'package:app_agri_connect/features/bluetooth/data/datasources/bluetooth_remote_datasource.dart';

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
  Future<String> getLocalDeviceName() async {
    try {
      // For now, return a default name since we can't easily get the local device name
      // In a production app, you might want to use platform channels to get the device name
      return 'Agri Connect App';
    } catch (e) {
      return 'Agri Connect App';
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
      
      // Return the scan results stream with farm robot filtering
      return FlutterBluePlus.scanResults.map((results) {
        final devices = results.map((result) {
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
        }).where((device) => _isFarmRobotDevice(device)).toList();
        
        // Remove duplicates based on device ID
        final uniqueDevices = <String, BluetoothDeviceModel>{};
        for (final device in devices) {
          uniqueDevices[device.id] = device;
        }
        
        return uniqueDevices.values.toList();
      });
    } catch (e) {
      // Return empty stream on error
      return Stream.value([]);
    }
  }

  // Filter function to identify farm robot devices
  bool _isFarmRobotDevice(BluetoothDeviceModel device) {
    try {
      print('Checking device: ${device.name} (${device.id})');
      
      // First, check manufacturer data for farm robot identifier (most reliable)
      final manufacturerData = device.advertisementData['manufacturerData'] as Map<String, dynamic>?;
      if (manufacturerData != null) {
        for (final entry in manufacturerData.entries) {
          final manufacturerId = int.tryParse(entry.key);
          if (manufacturerId == 0xFFFF) { // Our custom manufacturer ID
            final data = entry.value;
            if (data is List && data.length >= 4) {
              // Check device type (byte 2) and category (byte 3)
              final deviceType = data[2];
              final deviceCategory = data[3];
              if (deviceType == 1 && deviceCategory == 1) { // Farm Robot + Agriculture
                print('Device identified as farm robot by manufacturer data: ${device.name}');
                return true;
              }
            }
          }
        }
      }

      // Check service UUIDs for farm robot service
      final serviceUuids = device.advertisementData['serviceUuids'] as List<dynamic>?;
      if (serviceUuids != null) {
        for (final uuid in serviceUuids) {
          if (uuid.toString().contains('12345678-1234-1234-1234-123456789abc')) {
            print('Device identified as farm robot by service UUID: ${device.name}');
            return true;
          }
        }
      }

      // Only check device name if it's not empty and contains specific farm robot indicators
      final deviceName = device.name.toLowerCase();
      if (deviceName.isNotEmpty && deviceName != 'unknown device') {
        if (deviceName.contains('farmrobot') || 
            deviceName.contains('farm-robot') ||
            deviceName.contains('farm_robot')) {
          print('Device identified as farm robot by name: ${device.name}');
          return true;
        }
      }

      print('Device NOT identified as farm robot: ${device.name}');
      return false;
    } catch (e) {
      print('Error filtering device ${device.name}: $e');
      return false;
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