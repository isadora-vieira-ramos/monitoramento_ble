import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoramento_ble/utils/extra.dart';

class DeviceTile extends StatefulWidget {
  final BluetoothDevice device;
  const DeviceTile({super.key, required this.device});

  @override
  State<DeviceTile> createState() => _DeviceTileState();
}

class _DeviceTileState extends State<DeviceTile> {
  BluetoothConnectionState _connectionState = BluetoothConnectionState.disconnected;
  late StreamSubscription<BluetoothConnectionState> _connectionStateSubscription;

  @override
  void initState() {
    super.initState();

    _connectionStateSubscription = widget.device.connectionState.listen((state) {
      _connectionState = state;
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _connectionStateSubscription.cancel();
    super.dispose();
  }

  bool get isConnected {
    return _connectionState == BluetoothConnectionState.connected;
  }

  void connectToDevice(){
     widget.device.connectAndUpdateStream().then(
      (value) => Fluttertoast.showToast(msg: "Conectado!.")
      ).catchError((e) {
        Fluttertoast.showToast(msg: "Não foi possível conectar.");
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return  Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.transparent)
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.device.advName,
              style: const TextStyle(
                fontSize: 18
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(onPressed: connectToDevice, child: const Text("Conectar")),
                TextButton(onPressed: isConnected? (){}: (){}, child: const Text("Escrever")),
                TextButton(onPressed: isConnected? (){}: (){}, child: const Text("Ler"))
              ],
            ),
            const Padding(
              padding: EdgeInsets.only(top:5.0, left:5, right: 5),
              child: Divider(color: Colors.black),
            )   
          ],
        ),
      ),
    );
  }
}