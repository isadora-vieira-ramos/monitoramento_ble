import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoramento_ble/models/file.dart';
import 'package:monitoramento_ble/utils/loading.dart';

class FileRecord extends StatefulWidget {
  const FileRecord({super.key});

  @override
  State<FileRecord> createState() => _FileRecordState();
}

class _FileRecordState extends State<FileRecord> {
  List<String> spotList = [];
  BLEFile file = BLEFile();
  String? fileContent = null;

  Future<void> readFileWithSpots() async {
    fileContent = await file.readSpotFromFile();
    if(fileContent != null){
      spotList = fileContent!.split("],");
    }
  }

  Future<void> deleteDataFromFile() async {
    var emptyFile = await file.deleteDataFromFile();
    setState(() {
      spotList = [];
    });
    // var fileContent = await emptyFile!.readAsString();
    // if(emptyFile != null && fileContent.isEmpty){
    //   setState(() {
    //     spotList = ['Arquivo vazio.'];
    //   });
    // }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
          future: readFileWithSpots(), 
          builder: (context, snapshot) {
            if(snapshot.connectionState != ConnectionState.done){
              return const LoadingComponent();
            }
            else{
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(spotList.length > 1)...[
                    Expanded(
                      child: ListView.builder(
                        itemCount: spotList.length < 20? spotList.length : 20,
                        itemBuilder: (context, index) {
                          return Text(spotList[index]);
                        },
                      )
                    ),
                    TextButton(
                      onPressed: deleteDataFromFile, 
                      child: const Text("Apagar tudo")
                    )
                  ]else...[
                    const Center(child: Text("Arquivo vazio.", style: TextStyle(fontSize: 20),))
                  ]
                ],
              );
            }     
          }
        ),
      ),
    );
  }
}