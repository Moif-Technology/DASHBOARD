import 'package:fitness_dashboard_ui/data/pie_chart_data.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class PieChartSample2 extends StatefulWidget {
  final DateTime selectedDate;

  const PieChartSample2({super.key, required this.selectedDate});

  @override
  State<StatefulWidget> createState() => PieChart2State();
}

class PieChart2State extends State<PieChartSample2> {
  int touchedIndex = -1;
  final ChartData chartData = ChartData();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData(widget.selectedDate);
  }

  Future<void> fetchData(DateTime date) async {
  await chartData.fetchAndSetData(date);
  setState(() {
    isLoading = false;
  });
}

  @override
  void didUpdateWidget(covariant PieChartSample2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      setState(() {
        isLoading = true;
      });
      fetchData(widget.selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else
          AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        touchedIndex = -1;
                        return;
                      }
                      touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(
                  show: false,
                ),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: showingSections(),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: chartData.areaSales.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> area = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Indicator(
                  color: chartData.paiChartSelectionDatas[index].color!,
                  text:
                      '${area['areaName']} (${chartData.paiChartSelectionDatas[index].value.toStringAsFixed(1)}%)',
                  isSquare: true,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> showingSections() {
    return chartData.paiChartSelectionDatas.asMap().entries.map((entry) {
      int index = entry.key;
      PieChartSectionData section = entry.value;
      final isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 25.0 : 16.0;
      final double radius = isTouched ? 60.0 : 50.0;
      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      return section.copyWith(
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
      );
    }).toList();
  }
}

class Indicator extends StatelessWidget {
  final Color color;
  final String text;
  final bool isSquare;
  final double size;
  final Color textColor;

  const Indicator({
    required this.color,
    required this.text,
    required this.isSquare,
    this.size = 16,
    this.textColor = const Color(0xff505050),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
