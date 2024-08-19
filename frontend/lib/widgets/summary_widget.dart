import 'package:fitness_dashboard_ui/const/constant.dart';
import 'package:fitness_dashboard_ui/widgets/pie_chart_widget.dart';
import 'package:fitness_dashboard_ui/widgets/summary_details.dart';
import 'package:flutter/material.dart';

class SummaryWidget extends StatelessWidget {
  final DateTime selectedDate;

  const SummaryWidget({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    print(
        'SummaryWidget: Selected Date received is ${selectedDate.toString()}');
    return Container(
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(10)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                            child: PieChartSample2(selectedDate: selectedDate)),
                        const SizedBox(height: defaultPadding),
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SummaryDetails(selectedDate: selectedDate),
                      ],
                    ),
                  ),
                  const SizedBox(width: defaultPadding),
                ],
              );
            } else {
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: defaultPadding),
                    Center(child: PieChartSample2(selectedDate: selectedDate)),
                    const SizedBox(height: defaultPadding),
                    const Text(
                      'Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SummaryDetails(selectedDate: selectedDate),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
