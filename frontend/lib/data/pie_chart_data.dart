import 'package:fitness_dashboard_ui/services/api_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartData {
  List<PieChartSectionData> paiChartSelectionDatas = [];
  List<Map<String, dynamic>> areaSales = [];

  Future<void> fetchAndSetData(DateTime date) async {
    ApiServices apiServices = ApiServices();
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    List<Map<String, dynamic>> data =
        await apiServices.fetchAreaSales(date);
    areaSales = data;

    double totalSales = data.fold(0, (sum, item) => sum + item['totalSales']);

    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange
    ]; // Add more colors if needed

    paiChartSelectionDatas = data
        .asMap()
        .map((index, item) {
          double percentage = (item['totalSales'] / totalSales) * 100;
          return MapEntry(
            index,
            PieChartSectionData(
              color: colors[index % colors.length], // Rotate through colors
              value: percentage,
              showTitle: false,
              radius: 50,
              title: '${percentage.toStringAsFixed(1)}%',
              titleStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          );
        })
        .values
        .toList();
  }
}
