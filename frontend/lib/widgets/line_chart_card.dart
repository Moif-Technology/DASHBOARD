import 'package:fitness_dashboard_ui/const/constant.dart';
import 'package:fitness_dashboard_ui/data/line_chart_data.dart';
import 'package:fitness_dashboard_ui/widgets/custom_card_widget.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartCard extends StatefulWidget {
  const LineChartCard({super.key});

  @override
  _LineChartCardState createState() => _LineChartCardState();
}

class _LineChartCardState extends State<LineChartCard> {
  LineData lineData = LineData();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    await lineData.fetchData();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Sales Overview",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          AspectRatio(
            aspectRatio: 16 / 6,
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : LineChart(
                    LineChartData(
                      lineTouchData: LineTouchData(
                        handleBuiltInTouches: true,
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: true,
                        drawHorizontalLine: true,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                        getDrawingVerticalLine: (value) {
                          return FlLine(
                            color: Colors.grey.withOpacity(0.2),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      titlesData: FlTitlesData(
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              int index = value.toInt();
                              String? month = lineData.bottomTitle[index];
                              return month != null
                                  ? SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        month,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[400],
                                        ),
                                      ),
                                    )
                                  : const SizedBox();
                            },
                            interval: 1, // Ensure one label per month
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value % 20000 == 0) {
                                return Text(
                                  '${(value / 1000).toStringAsFixed(0)}K',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[400],
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                            showTitles: true,
                            interval: 20000,
                            reservedSize: 40,
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          color: primaryColor,
                          barWidth: 2.5,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.2),
                                Colors.transparent,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                          dotData: FlDotData(show: false),
                          spots: lineData.spots,
                        ),
                      ],
                      minX: 0,
                      maxX: 11, // Ensure x-axis covers 12 months (0-11)
                      maxY: 120000, // Adjust according to your data range
                      minY: 0,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
