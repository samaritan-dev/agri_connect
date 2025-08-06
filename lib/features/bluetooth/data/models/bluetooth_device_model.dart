import 'package:app_agri_connect/features/bluetooth/domain/entities/bluetooth_device.dart';

class BluetoothDeviceModel extends BluetoothDevice {
  const BluetoothDeviceModel({
    required String id,
    required String name,
    required int rssi,
    required bool isConnectable,
    required Map<String, dynamic> advertisementData,
  }) : super(
          id: id,
          name: name,
          rssi: rssi,
          isConnectable: isConnectable,
          advertisementData: advertisementData,
        );

  factory BluetoothDeviceModel.fromJson(Map<String, dynamic> json) {
    return BluetoothDeviceModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      rssi: json['rssi'] ?? 0,
      isConnectable: json['isConnectable'] ?? false,
      advertisementData: json['advertisementData'] ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'rssi': rssi,
      'isConnectable': isConnectable,
      'advertisementData': advertisementData,
    };
  }
} 