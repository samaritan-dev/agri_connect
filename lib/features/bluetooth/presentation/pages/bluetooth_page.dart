import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_bloc.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_event.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_state.dart';
import 'package:agri_connect/features/bluetooth/presentation/widgets/bluetooth_status_card.dart';
import 'package:agri_connect/features/bluetooth/presentation/widgets/scan_controls.dart';
import 'package:agri_connect/features/bluetooth/presentation/widgets/device_list.dart';

class BluetoothPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri Connect - BLE'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: BlocProvider(
        create: (context) => context.read<BluetoothBloc>()..add(InitializeBluetooth()),
        child: BlocBuilder<BluetoothBloc, BluetoothState>(
          builder: (context, state) {
            if (state is BluetoothInitial) {
              return Center(child: CircularProgressIndicator());
            } else if (state is BluetoothLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is BluetoothLoaded) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BluetoothStatusCard(status: state.bluetoothStatus),
                    SizedBox(height: 16),
                    ScanControls(isScanning: state.isScanning),
                    SizedBox(height: 16),
                    Expanded(
                      child: DeviceList(),
                    ),
                  ],
                ),
              );
            } else if (state is BluetoothError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Error',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<BluetoothBloc>().add(InitializeBluetooth());
                      },
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }
            return Center(child: Text('Unknown state'));
          },
        ),
      ),
    );
  }
} 