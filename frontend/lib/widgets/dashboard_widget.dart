import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/widgets/header_widget.dart';
import 'package:fitness_dashboard_ui/widgets/activity_details_card.dart';
import 'package:fitness_dashboard_ui/widgets/line_chart_card.dart';
import 'package:fitness_dashboard_ui/widgets/summary_widget.dart';

class DashboardWidget extends StatelessWidget {
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;

  const DashboardWidget({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            HeaderWidget(
              onDateSelected: onDateSelected,
              selectedDate: selectedDate,
            ),
            const SizedBox(height: 16.0),
            ActivityDetailsCard(selectedDate: selectedDate),
            const SizedBox(height: 16.0),
            const LineChartCard(),
            // Remove the SummaryWidget here to avoid duplicate UI
          ],
        ),
      ),
    );
  }
}
