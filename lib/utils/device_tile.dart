import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceTile extends StatelessWidget {
  final BluetoothDevice device;
  const DeviceTile({super.key, required this.device});

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
              device.advName,
              style: const TextStyle(
                fontSize: 18
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton(onPressed: (){}, child: const Text("Conectar")),
                TextButton(onPressed: (){}, child: const Text("Escrever")),
                TextButton(onPressed: (){}, child: const Text("Ler"))
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