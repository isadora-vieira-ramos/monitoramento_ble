import 'dart:async';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:monitoramento_ble/models/file.dart';

class GraphsScreen extends StatefulWidget {
  final Future<int> Function() read;
  const GraphsScreen({super.key, required this.read});

  final Color sinColor = Colors.blue;
  final Color cosColor = Colors.pink;

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  final valuesRead = <FlSpot>[];
  double currentMinX = 0;
  double currentMaxX = 100;
  double xValue = 0;
  double step = 1;

  Files files = Files(spots: []);
  late Timer timer;

  @override
  void initState() {
    super.initState();
    valuesRead.add(FlSpot.zero);
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      int value = await widget.read();
      double dValue = value.toDouble();
      FlSpot spot = FlSpot(xValue, dValue);
      String? spotsread = await files.readSpotFromFile();
      
      if(spotsread != null) {
        Fluttertoast.showToast(msg: spotsread);
      }

      files.writeSpotToFile(spot);
      setState(() {
        valuesRead.add(spot);
      });
      xValue += step;
      if(xValue >= 100 && xValue < 1000){
        var remainder = xValue % 100;
        if(remainder == 0){
          var divideByHundred = (xValue / 100).floor();
          setState(() {
            currentMinX = divideByHundred * 100;
            currentMaxX = currentMinX + 100;
          });
        }
      }else if(xValue >= 1000){
        dispose();
      }
    });
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;

    if(value == 0){
      text = const Text('0', style: style);
    }else if(value%25 == 0){
      text = Text(value.toInt().toString(), style: style);
    }else{
      text = const Text('', style: style);
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    switch (value.toInt()) {
      case 50:
        text = '50';
        break;
      case 100:
        text = '100';
        break;
      case 150:
        text = '150';
        break;
      case 200:
        text = '200';
        break;
      case 250:
        text = '250';
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  @override
  Widget build(BuildContext context) {
    return valuesRead.isNotEmpty
        ? Scaffold(
          backgroundColor: Colors.grey.shade200,
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'Valor de x: ${xValue.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: widget.sinColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Valor de y: ${valuesRead.last.y.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: widget.sinColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  AspectRatio(
                    aspectRatio: 1.5,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        width: currentMaxX * 3.5,
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: LineChart(
                            LineChartData(
                              minY: -1,
                              maxY: 256,
                              minX: 0,
                              maxX: currentMaxX,
                              lineTouchData: const LineTouchData(enabled: false),
                              clipData: const FlClipData.all(),
                              gridData: const FlGridData(
                                show: true,
                                drawVerticalLine: false,
                              ),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                sinLine(valuesRead),
                              ],
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 30,
                                    getTitlesWidget: bottomTitleWidgets,
                                    interval: 1,
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: leftTitleWidgets,
                                    reservedSize: 42,
                                    interval: 1,
                                  ),
                                ),
                                topTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: const AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Text("Role para o lado para visualizar o gráfico inteiro."),
                  TextButton(
                    onPressed: (){
                      currentMaxX = 100;
                      xValue = 0;
                    }, 
                    child: const Text("Reiniciar")
                  )
                ],
              ),
          ),
        )
        : Container();
  }

  LineChartBarData sinLine(List<FlSpot> points) {
    return LineChartBarData(
      spots: points,
      dotData: const FlDotData(
        show: false,
      ),
      gradient: LinearGradient(
        colors: [widget.sinColor.withOpacity(0), widget.sinColor],
        stops: const [0.1, 1.0],
      ),
      barWidth: 4,
      isCurved: false,
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}