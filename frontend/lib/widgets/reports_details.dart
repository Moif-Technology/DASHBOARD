import 'package:fitness_dashboard_ui/services/api_services.dart'; // Import the API services
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting dates

class ReportTable extends StatefulWidget {
  final String? branchId;

  ReportTable({required this.branchId});

  @override
  _ReportTableState createState() => _ReportTableState();
}

class _ReportTableState extends State<ReportTable> {
  DateTime? fromDate = DateTime.now(); // Set default as today's date
  DateTime? toDate =
      DateTime.now().add(Duration(days: 1)); // Set default as tomorrow's date
  String? selectedGroup; // For storing selected group
  List<Map<String, dynamic>> items = []; // Store fetched items
  List<String> groups = []; // Store fetched group names
  bool isLoading = false; // Loading state
  double total = 0.0; // Total amount

  final ApiServices _apiServices = ApiServices(); // Instantiate ApiServices

  @override
  void initState() {
    super.initState();
    fetchGroupNamesAndReport(); // Fetch group names and report when page renders
  }

  // Fetch both group names and report from the same API
  Future<void> fetchGroupNamesAndReport() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Call the API service to fetch group names and report data for today's and tomorrow's dates
      final result = await _apiServices.fetchItemSaleReport(
        fromDate: DateFormat('yyyy-MM-dd').format(fromDate!), // Today's date
        toDate: DateFormat('yyyy-MM-dd').format(toDate!), // Tomorrow's date
        branchId: widget.branchId,
        groupName: null, // Initially fetch all data without group filtering
      );

      // Extract group names and report items from the result
      final fetchedGroups = result['groupNames'] ?? [];
      final fetchedItems = result['data'] ?? [];

      // Calculate the total from the fetched items
      double fetchedTotal = 0.0;
      for (var item in fetchedItems) {
        if (item.containsKey('TotalAmount')) {
          fetchedTotal += item['TotalAmount']; // Summing the total amount
        }
      }

      setState(() {
        groups = fetchedGroups; // Set the fetched group names
        items = fetchedItems; // Set the fetched report data
        total = fetchedTotal; // Set the total value
      });
    } catch (e) {
      print('Error fetching report and group names: $e');
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
        fetchItemSaleReport();
      }
    }
  }

  // Function to fetch the item sale report
  Future<void> fetchItemSaleReport() async {
    if (fromDate == null || toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select both From and To dates')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await _apiServices.fetchItemSaleReport(
        fromDate: DateFormat('yyyy-MM-dd').format(fromDate!),
        toDate: DateFormat('yyyy-MM-dd').format(toDate!),
        branchId: widget.branchId,
        groupName: selectedGroup, // Pass the selected group to the API
      );

      final fetchedItems = result['data'] ?? [];
      double fetchedTotal = 0.0;

      // Calculate the total from the fetched items
      for (var item in fetchedItems) {
        if (item.containsKey('TotalAmount')) {
          fetchedTotal += item['TotalAmount']; // Summing the total amount
        }
      }

      setState(() {
        items = fetchedItems;
        total = fetchedTotal; // Set the total value
      });
    } catch (e) {
      print('Error fetching report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching report')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to clear the selected group
  void clearSelectedGroup() {
    setState(() {
      selectedGroup = null;
    });

    // Fetch report without group filtering
    if (fromDate != null && toDate != null) {
      fetchItemSaleReport();
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
            Icon(Icons.bar_chart_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Items Report',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20, // Keep the font size as is
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
                        borderRadius: BorderRadius.circular(8), // Keep as is
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

            SizedBox(height: 16), // Add spacing before the dropdown

            // Group selection dropdown with clear button
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedGroup,
                    hint: Text(
                      'Select Group',
                      style: TextStyle(color: Colors.white),
                    ),
                    icon: Icon(Icons.arrow_downward, color: Colors.white),
                    dropdownColor: Colors.blueGrey[900],
                    isExpanded: true,
                    style: TextStyle(
                        color: Colors.white, fontSize: 14), // Keep font size
                    underline:
                        Container(height: 1, color: Colors.white), // Underline
                    // Adjust the dropdown button padding and icon size for minimal design
                    items: groups.map((String group) {
                      return DropdownMenuItem<String>(
                        value: group,
                        child: Container(
                          height: 35, // Set the height for each item
                          padding: EdgeInsets.symmetric(vertical: 5),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            group,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize:
                                  12, // Smaller font size for dropdown items
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedGroup = newValue;
                        print("Selected Group: $selectedGroup");
                        // Fetch the report immediately after group selection
                        if (fromDate != null && toDate != null) {
                          fetchItemSaleReport();
                        }
                      });
                    },
                  ),
                ),
                IconButton(
                  onPressed: clearSelectedGroup,
                  icon: Icon(Icons.close, color: Colors.white),
                  tooltip: 'Clear selection', // Tooltip for accessibility
                ),
              ],
            ),

            SizedBox(height: 16), // Add spacing before table

            // Data table with sticky header and scrollable rows + Scrollbar
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
                                    flex: 4, // More space for Item Name
                                    child: Text('Item Name',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))),
                                Expanded(
                                    flex: 2, // Less space for Quantity
                                    child: Text('Quantity',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold))),
                                Expanded(
                                    flex: 2, // Less space for Price
                                    child: Text('Price',
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
                                children: items.map((item) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                        horizontal:
                                            12.0), // Adjusted row height
                                    color: Colors.blueGrey[700],
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 4, // More space for Item Name
                                            child: Text(
                                                item['ShortDescription'] ?? '',
                                                style: TextStyle(
                                                    color: Colors.white))),
                                        Expanded(
                                            flex: 2, // Less space for Quantity
                                            child: Text(item['Qty'].toString(),
                                                style: TextStyle(
                                                    color: Colors.white))),
                                        Expanded(
                                            flex: 2, // Less space for Price
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
              'Total: ${total.toStringAsFixed(2)}', // Show total in AED
              style: TextStyle(
                fontSize: 18, // Keep font size as is
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
