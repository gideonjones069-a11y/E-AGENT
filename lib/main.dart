import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/add_client_screen.dart';
import 'screens/client_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/policy_form_screen.dart';
import 'screens/policies_info_screen.dart';
import 'screens/all_reports_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const EAgentApp());
}

class EAgentApp extends StatelessWidget {
  const EAgentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'E-AGENT',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primarySwatch: Colors.blue,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightBlueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      initialRoute: '/',

      routes: {

        '/': (context) => const LoginScreen(),

        '/home': (context) => const HomeScreen(),

        '/add_client': (context) => const AddClientScreen(),

        '/clients': (context) => const ClientListScreen(),

        '/policy_form': (context) => const PolicyFormScreen(),

    
        '/policies_info': (context) => const PoliciesInfoScreen(),
        
        '/all_reports': (context) => const AllReportsScreen(),

        '/settings': (context) => const SettingsScreen(),

      },
    );
  }
}