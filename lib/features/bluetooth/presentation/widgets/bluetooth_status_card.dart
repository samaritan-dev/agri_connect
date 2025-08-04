import 'package:flutter/material.dart';

class BluetoothStatusCard extends StatelessWidget {
  final String status;

  const BluetoothStatusCard({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bluetooth,
                  color: _getStatusColor(),
                ),
                SizedBox(width: 8),
                Text(
                  'Bluetooth Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                color: _getStatusColor(),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (status.toLowerCase()) {
      case 'bluetooth is on':
      case 'on':
        return Colors.green;
      case 'bluetooth is off':
      case 'off':
        return Colors.red;
      case 'bluetooth is turning on':
      case 'turning_on':
        return Colors.orange;
      case 'bluetooth is turning off':
      case 'turning_off':
        return Colors.orange;
      case 'initializing...':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
} 