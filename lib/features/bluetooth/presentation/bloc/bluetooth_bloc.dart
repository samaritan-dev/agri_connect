import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;
import 'package:permission_handler/permission_handler.dart';

import 'package:app_agri_connect/core/error/failures.dart';
import 'package:app_agri_connect/core/usecases/either.dart';
import 'package:app_agri_connect/core/usecases/usecase.dart';
import 'package:app_agri_connect/features/bluetooth/domain/usecases/scan_devices.dart';
import 'package:app_agri_connect/features/bluetooth/domain/usecases/connect_device.dart';
import 'package:app_agri_connect/features/bluetooth/domain/usecases/disconnect_device.dart';
import 'package:app_agri_connect/features/bluetooth/domain/usecases/get_connected_devices.dart';
import 'package:app_agri_connect/features/bluetooth/domain/usecases/send_command.dart' as send_command_use_case;
import 'package:app_agri_connect/features/bluetooth/domain/entities/bluetooth_device.dart';
import 'package:app_agri_connect/features/bluetooth/presentation/bloc/bluetooth_event.dart';
import 'package:app_agri_connect/features/bluetooth/presentation/bloc/bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final ScanDevices scanDevices;
  final ConnectDevice connectDevice;
  final DisconnectDevice disconnectDevice;
  final GetConnectedDevicesUseCase getConnectedDevices;
  final send_command_use_case.SendCommand sendCommand;
  
  StreamSubscription<Either<Failure, List<BluetoothDevice>>>? _scanSubscription;

  BluetoothBloc({
    required this.scanDevices,
    required this.connectDevice,
    required this.disconnectDevice,
    required this.getConnectedDevices,
    required this.sendCommand,
  }) : super(BluetoothInitial()) {
    on<InitializeBluetooth>(_onInitializeBluetooth);
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<GetConnectedDevices>(_onGetConnectedDevices);
    on<SendCommand>(_onSendCommand);
    on<UpdateDevices>(_onUpdateDevices);
    on<ScanFailed>(_onScanFailed);
  }

  Future<void> _onInitializeBluetooth(
    InitializeBluetooth event,
    Emitter<BluetoothState> emit,
  ) async {
    print('BluetoothBloc: Initializing Bluetooth...');
    emit(BluetoothLoading());
    
    try {
      // Check and request permissions first
      final locationStatus = await Permission.location.status;
      final bluetoothStatus = await Permission.bluetooth.status;
      final bluetoothScanStatus = await Permission.bluetoothScan.status;
      
      // Request permissions if needed
      if (locationStatus.isDenied) {
        await Permission.location.request();
      }
      
      if (bluetoothStatus.isDenied) {
        await Permission.bluetooth.request();
      }
      
      if (bluetoothScanStatus.isDenied) {
        await Permission.bluetoothScan.request();
      }
      
      // Check if Bluetooth is supported using FlutterBluePlus directly
      bool isSupported = false;
      try {
        final adapterState = await fbp.FlutterBluePlus.adapterState.first;
        isSupported = adapterState != fbp.BluetoothAdapterState.unavailable;
      } catch (e) {
        isSupported = false;
      }

      if (!isSupported) {
        emit(BluetoothLoaded(
          bluetoothStatus: 'Bluetooth not supported on this device',
          devices: [],
          isScanning: false,
          connectedDevices: [],
        ));
        return;
      }

      // Get current Bluetooth state using FlutterBluePlus directly
      String bluetoothState = 'Unknown';
      try {
        final adapterState = await fbp.FlutterBluePlus.adapterState.first;
        switch (adapterState) {
          case fbp.BluetoothAdapterState.on:
            bluetoothState = 'Bluetooth is ON';
            break;
          case fbp.BluetoothAdapterState.off:
            bluetoothState = 'Bluetooth is OFF - Please enable Bluetooth';
            break;
          case fbp.BluetoothAdapterState.turningOn:
            bluetoothState = 'Bluetooth is turning ON';
            break;
          case fbp.BluetoothAdapterState.turningOff:
            bluetoothState = 'Bluetooth is turning OFF';
            break;
          case fbp.BluetoothAdapterState.unavailable:
            bluetoothState = 'Bluetooth is unavailable';
            break;
          default:
            bluetoothState = 'Bluetooth state: $adapterState';
        }
      } catch (e) {
        bluetoothState = 'Error getting Bluetooth state: $e';
      }

      print('BluetoothBloc: Bluetooth initialized successfully. Status: $bluetoothState');
      emit(BluetoothLoaded(
        bluetoothStatus: bluetoothState,
        devices: [],
        isScanning: false,
        connectedDevices: [],
      ));
    } catch (e) {
      print('BluetoothBloc: Error initializing Bluetooth: $e');
      emit(BluetoothError(message: 'Failed to initialize Bluetooth: $e'));
    }
  }

  Future<void> _onStartScan(
    StartScan event,
    Emitter<BluetoothState> emit,
  ) async {
    print('BluetoothBloc: Starting scan...');
    try {
      if (state is BluetoothLoaded) {
        final currentState = state as BluetoothLoaded;
        
        print('BluetoothBloc: Current state is BluetoothLoaded, starting scan...');
        emit(currentState.copyWith(isScanning: true, devices: []));
        
        // Ensure Bluetooth is on before scanning
        final adapterState = await fbp.FlutterBluePlus.adapterState.first;
        if (adapterState != fbp.BluetoothAdapterState.on) {
          await fbp.FlutterBluePlus.turnOn();
          await Future.delayed(Duration(seconds: 2));
        }
        
        // Start scanning
        final scanStream = await scanDevices(NoParams());
        
        _scanSubscription?.cancel();
        _scanSubscription = scanStream.listen(
          (either) {
            // Process scan results
            if (either is Right) {
              final devices = either.getRight();
              add(UpdateDevices(devices: devices));
            } else if (either is Left) {
              final failure = either.getLeft();
              add(ScanFailed(message: failure.message));
            }
          },
          onError: (error) {
            if (!emit.isDone && state is BluetoothLoaded) {
              final currentState = state as BluetoothLoaded;
              emit(currentState.copyWith(
                isScanning: false,
                bluetoothStatus: 'Scan error: $error',
              ));
            }
          },
        );
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(BluetoothError(message: 'Failed to start scan: $e'));
      }
    }
  }

  Future<void> _onStopScan(
    StopScan event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      _scanSubscription?.cancel();
      
      // Stop the actual scanning
      await fbp.FlutterBluePlus.stopScan();
      
      if (state is BluetoothLoaded) {
        final currentState = state as BluetoothLoaded;
        emit(currentState.copyWith(isScanning: false));
      }
    } catch (e) {
      emit(BluetoothError(message: 'Failed to stop scan: $e'));
    }
  }

  Future<void> _onConnectToDevice(
    ConnectToDevice event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      final result = await connectDevice(ConnectDeviceParams(deviceId: event.deviceId));
      
      result.fold(
        (failure) {
          emit(BluetoothError(message: failure.message));
        },
        (success) {
          if (success) {
            // Refresh connected devices
            add(GetConnectedDevices());
          } else {
            emit(BluetoothError(message: 'Failed to connect to device'));
          }
        },
      );
    } catch (e) {
      emit(BluetoothError(message: 'Failed to connect to device: $e'));
    }
  }

  Future<void> _onDisconnectFromDevice(
    DisconnectFromDevice event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      final result = await disconnectDevice(DisconnectDeviceParams(deviceId: event.deviceId));
      
      result.fold(
        (failure) {
          emit(BluetoothError(message: failure.message));
        },
        (success) {
          if (success) {
            // Refresh connected devices
            add(GetConnectedDevices());
          } else {
            emit(BluetoothError(message: 'Failed to disconnect from device'));
          }
        },
      );
    } catch (e) {
      emit(BluetoothError(message: 'Failed to disconnect from device: $e'));
    }
  }

  Future<void> _onGetConnectedDevices(
    GetConnectedDevices event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      final result = await getConnectedDevices(GetConnectedDevicesParams());
      
      result.fold(
        (failure) {
          if (state is BluetoothLoaded) {
            final currentState = state as BluetoothLoaded;
            emit(currentState.copyWith(
              bluetoothStatus: 'Failed to get connected devices: ${failure.message}',
            ));
          }
        },
        (connectedDevices) {
          if (state is BluetoothLoaded) {
            final currentState = state as BluetoothLoaded;
            emit(currentState.copyWith(connectedDevices: connectedDevices));
          }
        },
      );
    } catch (e) {
      if (state is BluetoothLoaded) {
        final currentState = state as BluetoothLoaded;
        emit(currentState.copyWith(
          bluetoothStatus: 'Error getting connected devices: $e',
        ));
      }
    }
  }

  Future<void> _onSendCommand(
    SendCommand event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      final result = await sendCommand(send_command_use_case.SendCommandParams(
        deviceId: event.deviceId, 
        command: event.command,
        parameters: event.parameters,
      ));
      
      result.fold(
        (failure) {
          emit(BluetoothError(message: failure.message));
        },
        (success) {
          if (success) {
            // Command sent successfully
            if (state is BluetoothLoaded) {
              final currentState = state as BluetoothLoaded;
              emit(currentState.copyWith(
                bluetoothStatus: 'Command sent successfully: ${event.command}',
              ));
            }
          } else {
            emit(BluetoothError(message: 'Failed to send command to device'));
          }
        },
      );
    } catch (e) {
      emit(BluetoothError(message: 'Failed to send command to device: $e'));
    }
  }

  Future<void> _onUpdateDevices(
    UpdateDevices event,
    Emitter<BluetoothState> emit,
  ) async {
    if (state is BluetoothLoaded) {
      final currentState = state as BluetoothLoaded;
      final devices = event.devices.cast<BluetoothDevice>();
      emit(currentState.copyWith(devices: devices));
    }
  }

  Future<void> _onScanFailed(
    ScanFailed event,
    Emitter<BluetoothState> emit,
  ) async {
    if (state is BluetoothLoaded) {
      final currentState = state as BluetoothLoaded;
      emit(currentState.copyWith(
        isScanning: false,
        bluetoothStatus: 'Scan failed: ${event.message}',
      ));
    }
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
} 