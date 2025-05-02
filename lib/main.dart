import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

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
  String _wifi = 'Wifi is safe: unknown.';
  String _localAuth = 'Lock screen: unknown.';
  
  @override
  void initState() {
    super.initState();
    _getHasLockScreen();
    _getBatteryLevel();
    _wifiIsSafe();
    _getLocalAuth();
  }

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



  Future<void> _getLocalAuth() async {
    final LocalAuthentication auth = LocalAuthentication();
    final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
    final bool canAuthenticate =
        canAuthenticateWithBiometrics || await auth.isDeviceSupported();
  
    setState(() {
      _localAuth = 'Has Lock Screen (local_auth): $canAuthenticate.' ;
    });
  }

   Future<void> _wifiIsSafe() async {
    String wifi;
    
    try {
      final String result = await platform.invokeMethod('wifiIsSafe');
      wifi = '$result';

    } on PlatformException catch (e) {
      wifi = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _wifi = wifi;
    });
  }

  Future<void> _getHasLockScreen() async {
    String hasLockScreen;
    
    try {
      final bool result = await platform.invokeMethod('hasLockScreen');
      hasLockScreen = 'Has Lock Screen: $result.';

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
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              Text(_batteryLevel),
            ],
          ),
          Row(
            children: [
              Text(_hasLockScreen),
            ],
          ),
          Row(
            children: [
              Text(_localAuth),
            ],
          ),
          Row(
            children: [
              Text(_wifi),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:  () {
          _getHasLockScreen();
          _getBatteryLevel(); 
          _wifiIsSafe();
          _getLocalAuth();
        },
        tooltip: 'Reload',
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
