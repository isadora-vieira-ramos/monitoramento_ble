import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoramento_ble/screens/graphs.dart';
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
    return widget.device.isConnected;
  }

  void connectToDevice(){
     widget.device.connectAndUpdateStream().then(
      (value) => Fluttertoast.showToast(msg: "Conectado!.")
      ).catchError((e) {
        Fluttertoast.showToast(msg: "Não foi possível conectar.");
      }
    );
  }

  Future<void> disconnectToDevice() async {
    try {
      await widget.device.disconnectAndUpdateStream();
      Fluttertoast.showToast(msg: "Desconectado");
    } catch (e) {
      Fluttertoast.showToast(msg: "Não foi possível desconectar");
    }
  }

  Future<int> read() async {
    try{
      List<BluetoothService> services = await widget.device.discoverServices();
      if(services.isNotEmpty){
        for (BluetoothService service in services) {
          if(service.uuid.toString() == "4fafc201-1fb5-459e-8fcc-c5c9c331914b"){
            for (BluetoothCharacteristic characteristic in service.characteristics) {
              if(characteristic.uuid.toString() == "beb5483e-36e1-4688-b7f5-ea07361b26a8"){
                List<int> value = await characteristic.read();
                Fluttertoast.showToast(msg: value.toString());
                return value[0];
              }
            }
          }
        }
      }else{
        Fluttertoast.showToast(msg: "Encontrado");
      }
    }catch(ex){
      Fluttertoast.showToast(msg: "Exceção: ${ex.toString()}");
    }
    return 0;
  }

  void showGraphs(){
    Navigator.push(context, MaterialPageRoute(builder: (context) => Graphs(read: read)));
  }

  void connectFirst(){
    Fluttertoast.showToast(msg: "Conecte primeiro");
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
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  widget.device.advName,
                  style: const TextStyle(
                    fontSize: 18
                  ),
                ),
                if(isConnected)...[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Conectado",
                          style: TextStyle(
                            color: Colors.white
                          ),
                        ),
                      ),
                    ),
                  )
                ]
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if(!isConnected)...[
                  TextButton(onPressed: connectToDevice, child: const Text("Conectar")),
                ],
                if(isConnected)...[
                  TextButton(onPressed: disconnectToDevice, child: const Text("Desconectar")),
                ],   
                TextButton(onPressed: isConnected? read: connectFirst, child: const Text("Ler")),
                TextButton(onPressed: isConnected? showGraphs: connectFirst, child: const Text("Visualizar"))
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