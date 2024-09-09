import 'dart:math';
import 'package:fitness_dashboard_ui/services/api_services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChartData {
  List<PieChartSectionData> paiChartSelectionDatas = [];
  List<Map<String, dynamic>> areaSales = [];
  List<Color> chartColors = []; // List to store colors for each section

  // Update fetchAndSetData to accept branchId as a named parameter
  Future<void> fetchAndSetData(DateTime date, {String? branchId}) async {
    ApiServices apiServices = ApiServices();
    String formattedDate = DateFormat('yyyy-MM-dd').format(date);
    print('Fetching data for date: $formattedDate and branchId: $branchId');

    // Pass branchId to the fetchAreaSales method
    List<Map<String, dynamic>> data =
        await apiServices.fetchAreaSales(date, branchId: branchId);

    // Handle null or empty response
    if (data == null || data.isEmpty) {
      paiChartSelectionDatas = [];
      chartColors = []; // Ensure colors are cleared
      return;
    }

    areaSales = data;

    double totalSales =
        data.fold(0, (sum, item) => sum + (item['totalSales'] ?? 0));

    // Handle zero total sales to avoid divide by zero errors
    if (totalSales == 0) {
      paiChartSelectionDatas = [];
      chartColors = [];
      return;
    }

    // Helper function to generate random colors
    Color getRandomColor() {
      Random random = Random();
      return Color.fromRGBO(
        random.nextInt(256),
        random.nextInt(256),
        random.nextInt(256),
        1,
      );
    }

    paiChartSelectionDatas = data
        .asMap()
        .map((index, item) {
          double percentage = ((item['totalSales'] ?? 0) / totalSales) * 100;
          Color sectionColor = getRandomColor(); // Generate a random color
          chartColors.add(sectionColor); // Store the color
          return MapEntry(
            index,
            PieChartSectionData(
              color: sectionColor,
              value: percentage,
              showTitle: percentage > 0,
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
