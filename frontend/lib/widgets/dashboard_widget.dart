import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/widgets/header_widget.dart';
import 'package:fitness_dashboard_ui/widgets/activity_details_card.dart';
import 'package:fitness_dashboard_ui/widgets/line_chart_card.dart';

class DashboardWidget extends StatelessWidget {
  final DateTime selectedDate;
  final String? branchId;
  final Function(DateTime) onDateSelected;

  const DashboardWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    required this.branchId,
  });

  @override
  Widget build(BuildContext context) {

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            HeaderWidget(
              onDateSelected: onDateSelected,
              selectedDate: selectedDate,
            ),
            ActivityDetailsCard(
              selectedDate: selectedDate,
              branchId: branchId, // Pass branch ID
            ),
            const SizedBox(height: 16.0),
            const LineChartCard(),
          ],
        ),
      ),
    );
  }
}
