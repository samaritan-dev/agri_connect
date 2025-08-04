import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_bloc.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_event.dart';

class ScanControls extends StatelessWidget {
  final bool isScanning;

  const ScanControls({Key? key, required this.isScanning}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: isScanning ? null : () {
              context.read<BluetoothBloc>().add(StartScan());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text('Start Scan'),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: isScanning ? () {
              context.read<BluetoothBloc>().add(StopScan());
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Stop Scan'),
          ),
        ),
      ],
    );
  }
} 