import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:agri_connect/features/bluetooth/domain/entities/bluetooth_device.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_bloc.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_event.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_state.dart';

class DeviceList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BluetoothBloc, BluetoothState>(
      builder: (context, state) {
        if (state is! BluetoothLoaded) {
          return Center(child: CircularProgressIndicator());
        }

        final devices = state.devices;
        final isScanning = state.isScanning;
        final connectedDevices = state.connectedDevices;


        
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
            // Scanning status indicator
            if (isScanning)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Scanning for BLE devices...',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            
            // Device list
            Expanded(
              child: devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.bluetooth_disabled,
                            size: 64,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            isScanning 
                                ? 'Searching for devices...'
                                : 'No devices found. Tap "Start Scan" to begin.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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
      },
    );
  }
} 