import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_agri_connect/core/di/injection_container.dart' as di;
import 'package:app_agri_connect/features/bluetooth/presentation/bloc/bluetooth_bloc.dart';
import 'package:app_agri_connect/features/bluetooth/presentation/pages/bluetooth_page.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<BluetoothBloc>(
          create: (context) => di.sl<BluetoothBloc>(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
                  home: BluetoothPage(),
      ),
    );
  }
}


