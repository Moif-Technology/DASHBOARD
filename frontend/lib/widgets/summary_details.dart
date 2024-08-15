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

  @override
  void initState() {
    super.initState();
    fetchAreaSales(widget.selectedDate);
  }

  Future<void> fetchAreaSales(DateTime date) async {
    ApiServices apiServices = ApiServices();
    List<Map<String, dynamic>> data = await apiServices.fetchAreaSales(date);
    setState(() {
      areaSales = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      color: const Color(0xFF2F353E),
      child: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: areaSales
                  .map((area) => buildDetails(
                      area['areaName'], area['totalSales'].toString()))
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
