import 'package:flutter/material.dart';

class Graphs extends StatelessWidget {
  const Graphs({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Visualizar os dados",
              style: TextStyle(
                fontSize: 20,
                color: Colors.blue.shade500,
              ),
            )
          ],
        ),
      ),
    );
  }
}
