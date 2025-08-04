import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class BluetoothDebugPage extends StatefulWidget {
  @override
  _BluetoothDebugPageState createState() => _BluetoothDebugPageState();
}

class _BluetoothDebugPageState extends State<BluetoothDebugPage> {
  bool isScanning = false;
  List<String> debugLogs = [];
  List<ScanResult> scanResults = [];
  String bluetoothStatus = 'Unknown';

  @override
  void initState() {
    super.initState();
    _checkBluetoothStatus();
  }

  Future<void> _checkBluetoothStatus() async {
    try {
      debugLogs.add('Checking Bluetooth support...');
      
      final isSupported = await FlutterBluePlus.isSupported;
      debugLogs.add('Bluetooth supported: $isSupported');
      
      if (!isSupported) {
        setState(() {
          bluetoothStatus = 'Not Supported';
        });
        return;
      }

      // Check permissions
      debugLogs.add('Checking permissions...');
      final locationStatus = await Permission.location.status;
      final bluetoothPermissionStatus = await Permission.bluetooth.status;
      final bluetoothScanStatus = await Permission.bluetoothScan.status;
      
      debugLogs.add('Location permission: $locationStatus');
      debugLogs.add('Bluetooth permission: $bluetoothPermissionStatus');
      debugLogs.add('Bluetooth scan permission: $bluetoothScanStatus');

      // Request permissions if needed
      if (locationStatus.isDenied) {
        debugLogs.add('Requesting location permission...');
        final result = await Permission.location.request();
        debugLogs.add('Location permission result: $result');
      }
      
      if (bluetoothPermissionStatus.isDenied) {
        debugLogs.add('Requesting bluetooth permission...');
        final result = await Permission.bluetooth.request();
        debugLogs.add('Bluetooth permission result: $result');
      }
      
      if (bluetoothScanStatus.isDenied) {
        debugLogs.add('Requesting bluetooth scan permission...');
        final result = await Permission.bluetoothScan.request();
        debugLogs.add('Bluetooth scan permission result: $result');
      }

      debugLogs.add('Getting adapter state...');
      final state = await FlutterBluePlus.adapterState.first;
      debugLogs.add('Adapter state: $state');
      
      setState(() {
        this.bluetoothStatus = state.toString();
      });

      // Listen to state changes
      FlutterBluePlus.adapterState.listen((state) {
        debugLogs.add('State changed to: $state');
        setState(() {
          this.bluetoothStatus = state.toString();
        });
      });

    } catch (e) {
      debugLogs.add('Error checking Bluetooth: $e');
    }
  }

  Future<void> _startScan() async {
    try {
      setState(() {
        isScanning = true;
        scanResults.clear();
        debugLogs.add('Starting scan...');
      });

      // Check if Bluetooth is on
      final state = await FlutterBluePlus.adapterState.first;
      if (state != BluetoothAdapterState.on) {
        debugLogs.add('Bluetooth is not ON. Current state: $state');
        debugLogs.add('Turning on Bluetooth...');
        await FlutterBluePlus.turnOn();
        await Future.delayed(Duration(seconds: 2));
      }

      debugLogs.add('Starting FlutterBluePlus scan...');
      debugLogs.add('Scan timeout: 15 seconds');
      debugLogs.add('Scan settings: No filters applied');
      
      // Start scanning
      await FlutterBluePlus.startScan(timeout: Duration(seconds: 15));
      debugLogs.add('Scan started successfully');

      // Check for existing scan results first
      final existingResults = FlutterBluePlus.scanResults;
      debugLogs.add('Existing scan results: ${existingResults.length}');
      
      // Listen to scan results with better error handling
      FlutterBluePlus.scanResults.listen(
        (results) {
          debugLogs.add('Received ${results.length} scan results');
          setState(() {
            scanResults = results;
          });
          
          for (final result in results) {
            debugLogs.add('Device: ${result.device.platformName} (${result.device.remoteId}) - RSSI: ${result.rssi}');
          }
        },
        onError: (error) {
          debugLogs.add('Error in scan results: $error');
        },
      );

      // Listen to scan state
      FlutterBluePlus.isScanning.listen(
        (scanning) {
          debugLogs.add('Scan state changed: $scanning');
          setState(() {
            isScanning = scanning;
          });
        },
        onError: (error) {
          debugLogs.add('Error in scan state: $error');
        },
      );

      // Add a periodic check for scan results
      Timer.periodic(Duration(seconds: 2), (timer) {
        if (!isScanning) {
          timer.cancel();
          return;
        }
        debugLogs.add('Scan check - Current results: ${scanResults.length}');
      });

    } catch (e) {
      debugLogs.add('Error starting scan: $e');
      setState(() {
        isScanning = false;
      });
    }
  }

  Future<void> _stopScan() async {
    try {
      debugLogs.add('Stopping scan...');
      await FlutterBluePlus.stopScan();
      debugLogs.add('Scan stopped');
      setState(() {
        isScanning = false;
      });
    } catch (e) {
      debugLogs.add('Error stopping scan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BLE Debug'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bluetooth Status',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text('Status: $bluetoothStatus'),
                    Text('Scanning: $isScanning'),
                    Text('Devices Found: ${scanResults.length}'),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isScanning ? null : _startScan,
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
                    onPressed: isScanning ? _stopScan : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Stop Scan'),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Scan Results
            if (scanResults.isNotEmpty) ...[
              Text(
                'Found Devices (${scanResults.length})',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: scanResults.length,
                  itemBuilder: (context, index) {
                    final result = scanResults[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          result.device.platformName.isNotEmpty 
                              ? result.device.platformName 
                              : 'Unknown Device',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ID: ${result.device.remoteId}'),
                            Text('RSSI: ${result.rssi} dBm'),
                            Text('Connectable: ${result.advertisementData.connectable}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            
            // Debug Logs
            if (debugLogs.isNotEmpty) ...[
              SizedBox(height: 16),
              Text(
                'Debug Logs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Container(
                height: 200,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: debugLogs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 1),
                      child: Text(
                        debugLogs[debugLogs.length - 1 - index],
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 