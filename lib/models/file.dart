import 'dart:io';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

class Files{

  Future<String> get _localPath async {
    try{
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    }catch(e){
      Fluttertoast.showToast(msg: 'Erro: ${e.toString()}');
      return '';
    }
    
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/pontos.txt');
  }

  Future<File> writeSpotToFile(FlSpot spot) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('[${spot.x},${spot.y}],', mode: FileMode.append);
  }

  Future<String?> readSpotFromFile() async {
    try {
      final file = await _localFile;

      // Read the file
      final contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return null;
    }
  }
}