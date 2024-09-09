import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/data/pie_chart_data.dart';

class PieChartSample2 extends StatefulWidget {
  final DateTime selectedDate;
  final String? branchId;
  final ChartData chartData;

  const PieChartSample2({
    super.key,
    required this.selectedDate,
    this.branchId,
    required this.chartData,
  });

  @override
  State<PieChartSample2> createState() => PieChartSample2State();
}

class PieChartSample2State extends State<PieChartSample2> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.3,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF2A2D3E),
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
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
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius:
                  50, // Reduced center space to give more area to sections
              sections: showingSections(),
            ),
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> showingSections() {
    return widget.chartData.paiChartSelectionDatas.asMap().entries.map((entry) {
      int index = entry.key;
      PieChartSectionData section = entry.value;
      final bool isTouched = index == touchedIndex;
      final double fontSize = isTouched ? 18.0 : 14.0;
      final double radius =
          isTouched ? 80.0 : 70.0; // Increased radius to make sections thicker
      final shadows = [
        Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 6),
      ];

      // Ensure very small sections have a minimum value for visibility
      double value = section.value < 1.0 ? 1.0 : section.value;

      return section.copyWith(
        radius: radius,
        value: value, // Set a minimum value for small sections
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: shadows,
        ),
        color: section.color.withOpacity(isTouched ? 0.9 : 0.75),
      );
    }).toList();
  }
}
