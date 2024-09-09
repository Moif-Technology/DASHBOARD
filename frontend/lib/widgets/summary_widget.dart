import 'package:fitness_dashboard_ui/const/constant.dart';
import 'package:fitness_dashboard_ui/widgets/pie_chart_widget.dart';
import 'package:fitness_dashboard_ui/widgets/summary_details.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/data/pie_chart_data.dart';

class SummaryWidget extends StatefulWidget {
  final DateTime selectedDate;
  final String? branchId;

  const SummaryWidget({
    super.key,
    required this.selectedDate,
    this.branchId,
  });

  @override
  State<SummaryWidget> createState() => _SummaryWidgetState();
}

class _SummaryWidgetState extends State<SummaryWidget> {
  final ChartData chartData = ChartData();
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void didUpdateWidget(covariant SummaryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.branchId != widget.branchId) {
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    await chartData.fetchAndSetData(widget.selectedDate,
        branchId: widget.branchId);

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            width: double.infinity,
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
                                child: SizedBox(
                                  height:
                                      350, // Increased the height for better spacing
                                  child: PieChartSample2(
                                    selectedDate: widget.selectedDate,
                                    branchId: widget.branchId,
                                    chartData: chartData,
                                  ),
                                ),
                              ),
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
                              SummaryDetails(
                                selectedDate: widget.selectedDate,
                                branchId: widget.branchId,
                                chartData: chartData,
                              ),
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
                          Center(
                            child: SizedBox(
                              height: 350, // Adjusted height for mobile layout
                              child: PieChartSample2(
                                selectedDate: widget.selectedDate,
                                branchId: widget.branchId,
                                chartData: chartData,
                              ),
                            ),
                          ),
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
                          SummaryDetails(
                            selectedDate: widget.selectedDate,
                            branchId: widget.branchId,
                            chartData: chartData,
                          ),
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
