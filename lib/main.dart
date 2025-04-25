import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Battery level: unknown.';
  String _hasLockScreen = 'Lock screen: unknown.';

   Future<void> _getBatteryLevel() async {
    String batteryLevel;
    
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result%.';


    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  Future<void> _getHasLockScreen() async {
    String hasLockScreen;
    
    try {
      final bool result = await platform.invokeMethod('hasLockScreen');
      hasLockScreen = 'Has Lock Screen is $result%.';

    } on PlatformException catch (e) {
      hasLockScreen = "Failed to has locked screen: '${e.message}'.";
    }

    setState(() {
      _hasLockScreen = hasLockScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Text(_batteryLevel),
          Text(_hasLockScreen),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getHasLockScreen,
        tooltip: 'Get Battery Level',
        child: const Icon(Icons.battery_full),
      ),
    );
  }
}
