import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class GraphsScreen extends StatefulWidget {
  final Future<int> Function() read;
  const GraphsScreen({super.key, required this.read});

  final Color sinColor = Colors.blue;
  final Color cosColor = Colors.pink;

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen> {
  final limitCount = 100;
  final valuesRead = <FlSpot>[];

  double xValue = 0;
  double step = 0.05;

  late Timer timer;

  @override
  void initState() {
    super.initState();
    valuesRead.add(FlSpot.zero);
    valuesRead.add(FlSpot(xValue, 5));
    timer = Timer.periodic(const Duration(milliseconds: 10000), (timer) async {
      while (valuesRead.length > limitCount) {
        valuesRead.removeAt(0);
      }
      int value = await widget.read();
      double dValue = value.toDouble();
      setState(() {
        valuesRead.add(FlSpot(xValue, dValue));
      });
      xValue += step;
    });
  }

  @override
  Widget build(BuildContext context) {
    return valuesRead.isNotEmpty
        ? Scaffold(
          backgroundColor: Colors.grey.shade200,
          body: Column(
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
                  'Último valor lido: ${valuesRead.last.y.toStringAsFixed(1)}',
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: LineChart(
                      LineChartData(
                        minY: -1,
                        maxY: 256,
                        minX: valuesRead.first.x,
                        maxX: valuesRead.last.x,
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
                        titlesData: const FlTitlesData(
                          show: false,
                        ),
                      ),
                    ),
                  ),
                )
              ],
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