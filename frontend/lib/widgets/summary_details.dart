import 'package:fitness_dashboard_ui/widgets/custom_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/services/api_services.dart';
import 'package:fitness_dashboard_ui/data/pie_chart_data.dart'; // Ensure ChartData is imported

class SummaryDetails extends StatelessWidget {
  final DateTime selectedDate;
  final String? branchId; // Add branchId parameter
  final ChartData chartData; // Pass ChartData to access colors

  const SummaryDetails({
    super.key,
    required this.selectedDate,
    this.branchId, // Include branchId
    required this.chartData, // Include chartData
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: const Color(0xFF2F353E),
      child: chartData.areaSales.isEmpty
          ? const Center(
              child: Text(
                'No data available for the selected date.',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            )
          : Column(
              children: chartData.areaSales.asMap().entries.map((entry) {
                int index = entry.key;
                Map<String, dynamic> area = entry.value;

                // Handle out-of-bounds index issue
                if (index >= chartData.chartColors.length) {
                  return Container(); // Return empty widget if index is out of bounds
                }

                Color color = chartData.chartColors[index]; // Get the corresponding color
                return buildDetails(
                    area['areaName'] ?? 'Unknown Area',
                    area['totalSales']?.toString() ?? '0',
                    color); // Pass the color to the buildDetails method
              }).toList(),
            ),
    );
  }

  Widget buildDetails(String areaName, String totalSales, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color, // Display the color here
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                areaName,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(width: 2),
          Text(
            totalSales,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
