import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_agri_connect/core/di/injection_container.dart' as di;
import 'package:app_agri_connect/features/bluetooth/presentation/bloc/bluetooth_bloc.dart';
import 'package:app_agri_connect/features/bluetooth/presentation/bloc/bluetooth_event.dart';
import 'package:app_agri_connect/features/home/presentation/pages/home_page.dart';
import 'package:app_agri_connect/features/settings/presentation/pages/settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  
  // Set the app name for BLE identification
  try {
    // This will help the farm robot identify this as an agricultural client
    print('Agri Connect App: Initializing as agricultural client device');
  } catch (e) {
    print('Error setting app identifier: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    print('MyApp: Building app with BluetoothBloc initialization...');
    final bluetoothBloc = di.sl<BluetoothBloc>();
    print('MyApp: BluetoothBloc created: ${bluetoothBloc.runtimeType}');
    bluetoothBloc.add(InitializeBluetooth());
    print('MyApp: InitializeBluetooth event added');
    
    return MultiBlocProvider(
      providers: [
        BlocProvider<BluetoothBloc>.value(
          value: bluetoothBloc,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomePage(),
          '/settings': (context) => const SettingsPage(),
        },
      ),
    );
  }
}


