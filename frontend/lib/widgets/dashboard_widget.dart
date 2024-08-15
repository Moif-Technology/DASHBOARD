import 'package:fitness_dashboard_ui/util/responsive.dart';
import 'package:fitness_dashboard_ui/widgets/activity_details_card.dart';
import 'package:fitness_dashboard_ui/widgets/header_widget.dart';
import 'package:fitness_dashboard_ui/widgets/line_chart_card.dart';
import 'package:fitness_dashboard_ui/widgets/summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/const/constant.dart';

class DashboardWidget extends StatefulWidget {
  const DashboardWidget({super.key});

  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  DateTime _selectedDate = DateTime.now();

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
        child: Column(
          children: [
            const SizedBox(height: defaultPadding),
            HeaderWidget(onDateSelected: _onDateSelected),
            const SizedBox(height: defaultPadding),
            ActivityDetailsCard(selectedDate: _selectedDate),
            const SizedBox(height: defaultPadding),
            const LineChartCard(),
            if (Responsive.isTablet(context)) SummaryWidget(selectedDate: _selectedDate),
          ],
        ),
      ),
    );
  }
}
