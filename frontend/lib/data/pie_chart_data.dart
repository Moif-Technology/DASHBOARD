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
    print(formattedDate);
    List<Map<String, dynamic>> data = await apiServices.fetchAreaSales(date);

    if (data == null || data.isEmpty) {
      // Handle the case where data is null or empty
      paiChartSelectionDatas = []; // Ensure the pie chart data is empty
      return;
    }

    areaSales = data;

    double totalSales =
        data.fold(0, (sum, item) => sum + (item['totalSales'] ?? 0));

    if (totalSales == 0) {
      // Handle the case where all sales are 0, avoid dividing by 0
      paiChartSelectionDatas = []; // No valid chart sections to show
      return;
    }

    List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.orange,
      Colors.black,
      Colors.pink
    ]; // Add more colors if needed

    paiChartSelectionDatas = data
        .asMap()
        .map((index, item) {
          double percentage = ((item['totalSales'] ?? 0) / totalSales) * 100;
          return MapEntry(
            index,
            PieChartSectionData(
              color: colors[index % colors.length], // Rotate through colors
              value: percentage,
              showTitle: percentage >
                  0, // Show title only if there is a valid percentage
              radius: 50,
              title: percentage > 0 ? '${percentage.toStringAsFixed(1)}%' : '',
              titleStyle: const TextStyle(
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
