import 'package:equatable/equatable.dart';

class BluetoothDevice extends Equatable {
  final String id;
  final String name;
  final int rssi;
  final bool isConnectable;
  final Map<String, dynamic> advertisementData;

  const BluetoothDevice({
    required this.id,
    required this.name,
    required this.rssi,
    required this.isConnectable,
    required this.advertisementData,
  });

  @override
  List<Object?> get props => [id, name, rssi, isConnectable, advertisementData];
} 