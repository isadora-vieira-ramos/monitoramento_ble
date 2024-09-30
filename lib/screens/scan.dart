import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:monitoramento_ble/utils/device_tile.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
 List<BluetoothDevice> _systemDevices = [];
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;
  late StreamSubscription<List<ScanResult>> _scanResultsSubscription;
  late StreamSubscription<bool> _isScanningSubscription;
  
  @override
  void initState() {
    super.initState();

    _scanResultsSubscription = FlutterBluePlus.scanResults.listen((results) {
      _scanResults = results;
      if (mounted) {
        setState(() {});
      }
    }, onError: (e) {
     
    });

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((state) {
      _isScanning = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _scanResultsSubscription.cancel();
    _isScanningSubscription.cancel();
    super.dispose();
  }

  Future onRefresh() {
    if (_isScanning == false) {
      FlutterBluePlus.startScan(timeout: const Duration(seconds: 15));
    }
    if (mounted) {
      setState(() {});
    }
    return Future.delayed(const Duration(milliseconds: 500));
  }

  List<Widget> scanResultList(BuildContext context) {
    return _scanResults.where((element) => element.device.advName.isNotEmpty)
        .map(
          (r) => DeviceTile(
            device: r.device
          ),
        )
        .toList();
  }

  Future onScanPressed() async {
    try {
      _systemDevices = await FlutterBluePlus.systemDevices;
    } catch (e) {
      Fluttertoast.showToast(msg: "Erro ao tentar encontrar os dispositivos já conectados.");   
    }
    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 15),
        withNames: []
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Erro ao tentar escanear dipositivos.");
    }
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
  
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "Dispositivos disponíveis",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20
                  )
                ),
              ),
              ...scanResultList(context),
            ],
          ),
        )
      ),
      floatingActionButton: FlutterBluePlus.isScanningNow? 
        FloatingActionButton(
          child: const Icon(Icons.stop),
          onPressed: (){
            FlutterBluePlus.stopScan();
          },
        ): 
        FloatingActionButton(
          onPressed: onScanPressed,
          child: const Icon(Icons.bluetooth_searching),
        ),
    );
  }
}