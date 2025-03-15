import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrintInvoice extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PrintInvoice();
}

class _PrintInvoice extends State<PrintInvoice> {
  static const platform = const MethodChannel('samples.flutter.dev/battery');
  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final String result = await platform.invokeMethod('getBatteryLevel',<String, dynamic>{
        'bat2': 'batery2',
        'bat3': 'batery3',
      });
      batteryLevel = 'Battery level at $result % .';
      print('nivel de bateria $batteryLevel');
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
      print('error al obtener el nivel de bateria $batteryLevel');
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            RaisedButton(
              child: Text('Get Battery Level'),
              onPressed: _getBatteryLevel,
            ),
            Text(_batteryLevel),
          ],
        ),
      ),
    );
  }
}