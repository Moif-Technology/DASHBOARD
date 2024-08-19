import 'package:fitness_dashboard_ui/widgets/custom_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/services/api_services.dart';

class SummaryDetails extends StatefulWidget {
  final DateTime selectedDate;

  const SummaryDetails({super.key, required this.selectedDate});

  @override
  _SummaryDetailsState createState() => _SummaryDetailsState();
}

class _SummaryDetailsState extends State<SummaryDetails> {
  List<Map<String, dynamic>> areaSales = [];
  bool isLoading = true;
  bool isError = false;
  bool isAreaSalesUnavailable = false; // New flag for handling unavailable area sales

  @override
  void initState() {
    super.initState();
    print('SummaryDetails initState: Date is ${widget.selectedDate}');
    fetchAreaSales(widget.selectedDate);
  }

  Future<void> fetchAreaSales(DateTime date) async {
    print('SummaryDetails fetchAreaSales: Date is $date');
    try {
      ApiServices apiServices = ApiServices();
      List<Map<String, dynamic>> data = await apiServices.fetchAreaSales(date);
      setState(() {
        if (data.isEmpty && apiServices.lastResponseStatusCode == 404) {
          // Check if the API returned a 404 indicating area sales is not available
          isAreaSalesUnavailable = true;
        } else {
          areaSales = data ?? [];
        }
        isLoading = false;
        isError = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print('SummaryDetails build: Date is ${widget.selectedDate}');
    return CustomCard(
      color: const Color(0xFF2F353E),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
              ? const Center(
                  child: Text(
                    'Error loading data. Please try again later.',
                    style: TextStyle(fontSize: 16, color: Colors.red),
                  ),
                )
              : isAreaSalesUnavailable // Handle when area sales is unavailable
                  ? const Center(
                      child: Text(
                        'Area sales data is not available for this company.',
                        style: TextStyle(fontSize: 16, color: Colors.orange),
                      ),
                    )
                  : areaSales.isEmpty
                      ? const Center(
                          child: Text(
                            'No data available for the selected date.',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        )
                      : Column(
                          children: areaSales
                              .map((area) => buildDetails(
                                  area['areaName'],
                                  area['totalSales'].toString()))
                              .toList(),
                        ),
    );
  }

  Widget buildDetails(String key, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(width: 2),
          Text(
            value,
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
