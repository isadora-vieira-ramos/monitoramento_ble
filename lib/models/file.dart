import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:path_provider/path_provider.dart';

class Files{
  List<FlSpot> spots = [];
  Files({required this.spots});

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/pontos.txt');
  }

  Future<File> writeSpotToFile(FlSpot spot) async {
    final file = await _localFile;

    // Write the file
    return file.writeAsString('[${spot.x}, ${spot.y}]');
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