import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' as fbp;

import 'package:agri_connect/core/error/failures.dart';
import 'package:agri_connect/core/usecases/either.dart';
import 'package:agri_connect/core/usecases/usecase.dart';
import 'package:agri_connect/features/bluetooth/domain/usecases/scan_devices.dart';
import 'package:agri_connect/features/bluetooth/domain/usecases/connect_device.dart';
import 'package:agri_connect/features/bluetooth/domain/usecases/disconnect_device.dart';
import 'package:agri_connect/features/bluetooth/domain/entities/bluetooth_device.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_event.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_state.dart';

class BluetoothBloc extends Bloc<BluetoothEvent, BluetoothState> {
  final ScanDevices scanDevices;
  final ConnectDevice connectDevice;
  final DisconnectDevice disconnectDevice;
  
  StreamSubscription<Either<Failure, List<BluetoothDevice>>>? _scanSubscription;

  BluetoothBloc({
    required this.scanDevices,
    required this.connectDevice,
    required this.disconnectDevice,
  }) : super(BluetoothInitial()) {
    on<InitializeBluetooth>(_onInitializeBluetooth);
    on<StartScan>(_onStartScan);
    on<StopScan>(_onStopScan);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectFromDevice>(_onDisconnectFromDevice);
    on<GetConnectedDevices>(_onGetConnectedDevices);
  }

  Future<void> _onInitializeBluetooth(
    InitializeBluetooth event,
    Emitter<BluetoothState> emit,
  ) async {
    emit(BluetoothLoading());
    
    try {
      // Check if Bluetooth is supported
      final isSupportedResult = await scanDevices.repository.isBluetoothSupported();
      final isSupported = isSupportedResult.fold(
        (failure) => false,
        (supported) => supported,
      );

      if (!isSupported) {
        emit(BluetoothLoaded(
          bluetoothStatus: 'Bluetooth not supported on this device',
          devices: [],
          isScanning: false,
          connectedDevices: [],
        ));
        return;
      }

      // Get current Bluetooth state
      final stateResult = await scanDevices.repository.getBluetoothState();
      final bluetoothState = stateResult.fold(
        (failure) => 'Error getting Bluetooth state',
        (state) => state,
      );

      emit(BluetoothLoaded(
        bluetoothStatus: bluetoothState,
        devices: [],
        isScanning: false,
        connectedDevices: [],
      ));
    } catch (e) {
      emit(BluetoothError(message: 'Failed to initialize Bluetooth: $e'));
    }
  }

  Future<void> _onStartScan(
    StartScan event,
    Emitter<BluetoothState> emit,
  ) async {
    try {
      if (state is BluetoothLoaded) {
        final currentState = state as BluetoothLoaded;
        
        emit(currentState.copyWith(isScanning: true, devices: []));
        
        // Start scanning
        final scanStream = await scanDevices(NoParams());
        
        _scanSubscription?.cancel();
        _scanSubscription = scanStream.listen(
          (either) {
            if (!emit.isDone) {
              either.fold(
                (failure) {
                  if (state is BluetoothLoaded) {
                    final currentState = state as BluetoothLoaded;
                    emit(currentState.copyWith(
                      isScanning: false,
                      bluetoothStatus: 'Scan failed: ${failure.message}',
                    ));
                  }
                },
                (devices) {
                  if (state is BluetoothLoaded) {
                    final currentState = state as BluetoothLoaded;
                    emit(currentState.copyWith(devices: devices));
                  }
                },
              );
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
    // This would typically call a use case to get connected devices
    // For now, we'll just update the state without changing connected devices
    if (state is BluetoothLoaded) {
      final currentState = state as BluetoothLoaded;
      // In a real implementation, you would fetch connected devices here
      emit(currentState.copyWith(connectedDevices: []));
    }
  }

  @override
  Future<void> close() {
    _scanSubscription?.cancel();
    return super.close();
  }
} 