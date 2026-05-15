import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:auto_datetime/auto_datetime.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? _isAutoEnabled;
  String _status = 'Checking...';
  final _autoDatetimePlugin = AutoDatetime();

  @override
  void initState() {
    super.initState();
    _checkAutoDatetime();
  }

  Future<void> _checkAutoDatetime() async {
    bool isEnabled;
    try {
      isEnabled = await _autoDatetimePlugin.isAutomaticDateTimeEnabled();
      setState(() {
        _isAutoEnabled = isEnabled;
        _status = isEnabled ? 'Automatic date & time is ON' : 'Automatic date & time is OFF';
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Auto DateTime Example'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isAutoEnabled == null
                    ? Icons.hourglass_empty
                    : _isAutoEnabled!
                        ? Icons.check_circle
                        : Icons.cancel,
                size: 72,
                color: _isAutoEnabled == null
                    ? Colors.grey
                    : _isAutoEnabled!
                        ? Colors.green
                        : Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _checkAutoDatetime,
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
