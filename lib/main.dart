import 'package:flutter/material.dart';
import 'core/database/hive_setup.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  await HiveSetup.init();

  runApp(const CarbonLauncherApp());
}

class CarbonLauncherApp extends StatelessWidget {
  const CarbonLauncherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Carbon Launcher',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Light grey/white Notion style
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'Backend Initialized.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}