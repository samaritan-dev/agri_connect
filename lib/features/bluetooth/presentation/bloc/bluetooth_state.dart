import 'package:equatable/equatable.dart';

import '../../domain/entities/bluetooth_device.dart';

abstract class BluetoothState extends Equatable {
  const BluetoothState();

  @override
  List<Object> get props => [];
}

class BluetoothInitial extends BluetoothState {}

class BluetoothLoading extends BluetoothState {}

class BluetoothLoaded extends BluetoothState {
  final String bluetoothStatus;
  final List<BluetoothDevice> devices;
  final bool isScanning;
  final List<BluetoothDevice> connectedDevices;

  const BluetoothLoaded({
    required this.bluetoothStatus,
    required this.devices,
    required this.isScanning,
    required this.connectedDevices,
  });

  @override
  List<Object> get props => [bluetoothStatus, devices, isScanning, connectedDevices];

  BluetoothLoaded copyWith({
    String? bluetoothStatus,
    List<BluetoothDevice>? devices,
    bool? isScanning,
    List<BluetoothDevice>? connectedDevices,
  }) {
    return BluetoothLoaded(
      bluetoothStatus: bluetoothStatus ?? this.bluetoothStatus,
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      connectedDevices: connectedDevices ?? this.connectedDevices,
    );
  }
}

class BluetoothError extends BluetoothState {
  final String message;

  const BluetoothError({required this.message});

  @override
  List<Object> get props => [message];
} 