import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:agri_connect/features/bluetooth/data/datasources/bluetooth_local_datasource.dart';
import 'package:agri_connect/features/bluetooth/data/datasources/bluetooth_local_datasource_impl.dart';
import 'package:agri_connect/features/bluetooth/data/datasources/bluetooth_remote_datasource.dart';
import 'package:agri_connect/features/bluetooth/data/datasources/bluetooth_remote_datasource_impl.dart';
import 'package:agri_connect/features/bluetooth/data/repositories/bluetooth_repository_impl.dart';
import 'package:agri_connect/features/bluetooth/domain/repositories/bluetooth_repository.dart';
import 'package:agri_connect/features/bluetooth/domain/usecases/scan_devices.dart';
import 'package:agri_connect/features/bluetooth/domain/usecases/connect_device.dart';
import 'package:agri_connect/features/bluetooth/domain/usecases/disconnect_device.dart';
import 'package:agri_connect/features/bluetooth/presentation/bloc/bluetooth_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(
    () => BluetoothBloc(
      scanDevices: sl(),
      connectDevice: sl(),
      disconnectDevice: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => ScanDevices(sl()));
  sl.registerLazySingleton(() => ConnectDevice(sl()));
  sl.registerLazySingleton(() => DisconnectDevice(sl()));

  // Repository
  sl.registerLazySingleton<BluetoothRepository>(
    () => BluetoothRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<BluetoothRemoteDataSource>(
    () => BluetoothRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<BluetoothLocalDataSource>(
    () => BluetoothLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => Dio());
} 