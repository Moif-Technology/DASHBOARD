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
    print('PieChartSample2 initState: Date is ${widget.selectedDate}');
    fetchData(widget.selectedDate);
  }

  Future<void> fetchData(DateTime date) async {
    print('PieChartSample2 fetchData: Date is $date');
    await chartData.fetchAndSetData(date);
    setState(() {
      isLoading = false;
    });
  }

  @override
  void didUpdateWidget(covariant PieChartSample2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate) {
      print(
          'PieChartSample2 didUpdateWidget: Old Date: ${oldWidget.selectedDate}, New Date: ${widget.selectedDate}');
      setState(() {
        isLoading = true;
      });
      fetchData(widget.selectedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    print('PieChartSample2 build: Date is ${widget.selectedDate}');
    return Column(
      children: <Widget>[
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (chartData.paiChartSelectionDatas.isEmpty)
          const Center(
            child: Text(
              'No data available for the selected date.',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 243, 117, 33),
              ),
            ),
          )
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
                borderData: FlBorderData(show: false),
                sectionsSpace: 0,
                centerSpaceRadius: 40,
                sections: showingSections(),
              ),
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
