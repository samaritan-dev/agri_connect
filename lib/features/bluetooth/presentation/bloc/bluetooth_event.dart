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