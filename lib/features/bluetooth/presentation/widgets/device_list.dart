import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:agri_connect/features/bluetooth/domain/entities/bluetooth_device.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_bloc.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_event.dart';

class DeviceList extends StatelessWidget {
  final List<BluetoothDevice> devices;
  final bool isScanning;
  final List<BluetoothDevice> connectedDevices;

  const DeviceList({
    Key? key,
    required this.devices,
    required this.isScanning,
    required this.connectedDevices,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Discovered Devices (${devices.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Expanded(
          child: isScanning
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Scanning for BLE devices...'),
                    ],
                  ),
                )
              : devices.isEmpty
                  ? Center(
                      child: Text(
                        'No devices found. Tap "Start Scan" to begin.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final device = devices[index];
                        final isConnected = connectedDevices.any((d) => d.id == device.id);
                        
                        return Card(
                          margin: EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Icon(
                              Icons.bluetooth,
                              color: isConnected ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              device.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ID: ${device.id}'),
                                Text('RSSI: ${device.rssi} dBm'),
                                if (device.isConnectable)
                                  Text('Connectable: Yes', style: TextStyle(color: Colors.green)),
                                if (isConnected)
                                  Text('Connected', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            trailing: ElevatedButton(
                              onPressed: () {
                                if (isConnected) {
                                  context.read<BluetoothBloc>().add(
                                    DisconnectFromDevice(deviceId: device.id),
                                  );
                                } else {
                                  context.read<BluetoothBloc>().add(
                                    ConnectToDevice(deviceId: device.id),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isConnected ? Colors.red : Colors.blue,
                                foregroundColor: Colors.white,
                              ),
                              child: Text(isConnected ? 'Disconnect' : 'Connect'),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
} 