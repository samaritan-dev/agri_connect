import 'package:equatable/equatable.dart';

abstract class BluetoothEvent extends Equatable {
  const BluetoothEvent();

  @override
  List<Object> get props => [];
}

class InitializeBluetooth extends BluetoothEvent {}

class StartScan extends BluetoothEvent {}

class StopScan extends BluetoothEvent {}

class ConnectToDevice extends BluetoothEvent {
  final String deviceId;

  const ConnectToDevice({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}

class DisconnectFromDevice extends BluetoothEvent {
  final String deviceId;

  const DisconnectFromDevice({required this.deviceId});

  @override
  List<Object> get props => [deviceId];
}

class GetConnectedDevices extends BluetoothEvent {}

class UpdateDevices extends BluetoothEvent {
  final List<dynamic> devices;

  const UpdateDevices({required this.devices});

  @override
  List<Object> get props => [devices];
}

class ScanFailed extends BluetoothEvent {
  final String message;

  const ScanFailed({required this.message});

  @override
  List<Object> get props => [message];
} 