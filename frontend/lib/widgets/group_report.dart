import 'package:fitness_dashboard_ui/services/api_services.dart'; // Import the API services
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class GroupReportTable extends StatefulWidget {
  final String? branchId;

  GroupReportTable({required this.branchId});

  @override
  _GroupReportTableState createState() => _GroupReportTableState();
}

class _GroupReportTableState extends State<GroupReportTable> {
  DateTime? fromDate = DateTime.now(); // Set default as today's date
  DateTime? toDate =
      DateTime.now().add(Duration(days: 1)); // Set default as tomorrow's date
  List<Map<String, dynamic>> groupReports = []; // Store fetched group reports
  bool isLoading = false; // Loading state
  double total = 0.0; // Total amount

  final ApiServices _apiServices = ApiServices(); // Instantiate ApiServices

  @override
  void initState() {
    super.initState();
    fetchGroupReport(); // Fetch group report when page renders
  }

  // Fetch the group report from the API
  Future<void> fetchGroupReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Call the API service to fetch group report for the selected dates
      final result = await _apiServices.fetchGroupReport(
        fromDate: DateFormat('yyyy-MM-dd').format(fromDate!), // Today's date
        toDate: DateFormat('yyyy-MM-dd').format(toDate!), // Tomorrow's date
        branchId: widget.branchId,
      );

      // Calculate the total from the fetched group reports
      double fetchedTotal = 0.0;
      for (var item in result) {
        if (item.containsKey('TotalAmount')) {
          fetchedTotal += item['TotalAmount']; // Summing the total amount
        }
      }

      setState(() {
        groupReports = result; // Set the fetched group reports
        total = fetchedTotal; // Set the total value
      });
    } catch (e) {
      print('Error fetching group report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to select the date
  Future<void> selectDate(BuildContext context, bool isFromDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Default to current date
      firstDate: DateTime(2000), // Start date range
      lastDate: DateTime(2101), // End date range
    );

    if (picked != null && picked != (isFromDate ? fromDate : toDate)) {
      setState(() {
        if (isFromDate) {
          fromDate = picked;
        } else {
          toDate = picked;
        }
      });

      // Fetch the report when both dates are selected
      if (fromDate != null && toDate != null) {
        fetchGroupReport();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    String formatDate(DateTime? date) {
      return date != null ? DateFormat.yMMMd().format(date) : 'Select Date';
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(width: 8),
            Icon(Icons.stacked_bar_chart, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Group Sales Report',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blueGrey[900],
        elevation: 3,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0), // Keep padding as is
        child: Column(
          children: [
            // Date selection row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // From Date
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => selectDate(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding:
                          EdgeInsets.symmetric(vertical: 12), // Reduced padding
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.date_range, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'From: ${formatDate(fromDate)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14, // Keep font size
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 6), // Spacing before the hyphen

                // Hyphen Separator
                Text(
                  '-',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),

                SizedBox(width: 6), // Spacing after the hyphen

                // To Date
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => selectDate(context, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueGrey[800],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.date_range, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'To: ${formatDate(toDate)}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16), // Add spacing before table

            // Data table with scrollable rows + Scrollbar
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(
                    child: Scrollbar(
                      thumbVisibility: true, // Ensure scrollbar is visible
                      thickness: 6.0, // Thickness of the scrollbar
                      radius:
                          Radius.circular(8.0), // Rounded corners for scrollbar
                      child: Column(
                        children: [
                          // Sticky Header
                          Container(
                            color: Colors.blueGrey[800],
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                Expanded(
                                    flex: 4, // More space for Group Name
                                    child: Text('Group Name',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))),
                                Expanded(
                                    flex: 2, // Less space for Total Amount
                                    child: Text('Total Amount',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))),
                              ],
                            ),
                          ),
                          // Scrollable rows
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: groupReports.map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal:
                                            12.0), // Adjusted row height
                                    color: Colors.blueGrey[700],
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex:
                                                4, // More space for Group Name
                                            child: Text(item['GroupName'] ?? '',
                                                style: TextStyle(
                                                    color: Colors.white))),
                                        Expanded(
                                            flex: 2, // Less space for Amount
                                            child: Text(
                                                item['TotalAmount']
                                                    .toStringAsFixed(2),
                                                style: TextStyle(
                                                    color: Colors.white))),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12.0), // Compact padding
        decoration: BoxDecoration(
          color: Colors.blueGrey[900],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Total: \$${total.toStringAsFixed(2)}', // Show total in USD
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'Roboto',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blueGrey[900],
    );
  }
}
