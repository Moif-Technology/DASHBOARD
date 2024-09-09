import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/services/api_services.dart';

class CountersDialog extends StatefulWidget {
  final String? branchId; // Add branchId parameter

  const CountersDialog({Key? key, this.branchId})
      : super(key: key); // Pass branchId to constructor

  @override
  _CountersDialogState createState() => _CountersDialogState();
}

class _CountersDialogState extends State<CountersDialog> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _counters = [];
  final ApiServices _apiServices = ApiServices();

  @override
  void initState() {
    super.initState();
    print("${widget.branchId} from dialog");
    _fetchCounters();
  }

  Future<void> _fetchCounters() async {
    try {
      // Fetch data from the API service
      final fetchedCounters = await _apiServices.fetchCounterCloseDetails(
        branchId: widget.branchId, // Pass the branchId to API call
      );

      // Convert fetchedCounters to List<Map<String, dynamic>>
      final List<Map<String, dynamic>> convertedCounters =
          fetchedCounters.map((counter) {
        return Map<String, dynamic>.from(counter as Map<dynamic, dynamic>);
      }).toList();

      setState(() {
        _counters = convertedCounters;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching counters: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show bottom sheet with counter details
  void _showCounterDetails(Map<String, dynamic> counter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _buildFullWidthBottomSheet(counter);
      },
    );
  }

  // Widget for the full-width bottom sheet
  Widget _buildFullWidthBottomSheet(Map<String, dynamic> counter) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildHeaderSection(counter),
                const Divider(),
                _buildFinancialSection(counter),
                const Divider(),
                _buildSalesSection(counter),
              ],
            ),
          ),
        );
      },
    );
  }

  // Header Section (Counter Close Number, Bill Count, Cashier Name, etc.)
  Widget _buildHeaderSection(Map<String, dynamic> counter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Counter Close No: ${counter['CounterCloseNo']?.toString() ?? '0'}   Bill Count: ${counter['BillCount']?.toString() ?? '0'}   Counter No: ${counter['CounterNo']?.toString() ?? '0'}',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text('Cashier Name: ${counter['CashierName']?.toString() ?? 'N/A'}',
            style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text(
          'Close Date: ${counter['CloseTime']?.toString() ?? 'N/A'}',
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  // Financial Information Section
  Widget _buildFinancialSection(Map<String, dynamic> counter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Total Cash', counter['TotalCash']?.toString() ?? '0',
            'Credit Received', counter['CreditReceived']?.toString() ?? '0'),
        _buildInfoRow('Total Cash Disc', counter['DiscCash']?.toString() ?? '0',
            'Refund', counter['TotalRefund']?.toString() ?? '0'),
        const Divider(),
        _buildInfoRow(
            'Cash to be Collected',
            counter['CashToBeCollected']?.toString() ?? '0',
            'Collected Cash',
            counter['CollectedCash']?.toString() ?? '0'),
        _buildInfoRow('Cash Difference',
            counter['CashDifference']?.toString() ?? '0', ''),
      ],
    );
  }

  // Sales and Tax Information Section
  Widget _buildSalesSection(Map<String, dynamic> counter) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Total Credit', counter['TotalCredit']?.toString() ?? '0',
            'Total Credit Card', counter['TotalCreditCard']?.toString() ?? '0'),
        _buildInfoRow(
            'Voucher Amount', counter['VoucherAmount']?.toString() ?? '0', ''),
        const Divider(),
        _buildInfoRow('Total Sales', counter['BillCount']?.toString() ?? '0',
            'Total TAX Amount', counter['ComplimentAmount']?.toString() ?? '0'),
      ],
    );
  }

  // Helper method to build rows with two columns
  Widget _buildInfoRow(String label1, String value1, String label2,
      [String value2 = '']) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label1,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value1,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          if (label2.isNotEmpty)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label2,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value2,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Counters'),
      content: _isLoading
          ? const SizedBox(
              height: 100,
              child: Center(child: CircularProgressIndicator()),
            )
          : _counters.isEmpty
              ? const Text('No counter closes for this branch')
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _buildCountersTable(),
                ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }

  // Widget to build the counters table
  Widget _buildCountersTable() {
    return DataTable(
      columnSpacing: 16,
      headingRowHeight: 32,
      dataRowHeight: 48,
      columns: const [
        DataColumn(
          label: Text(
            'C.No',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Cashier',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Close No',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
        DataColumn(
          label: Text(
            'Date/Time',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
      rows: _counters.map((counter) {
        return DataRow(cells: [
          DataCell(
            GestureDetector(
              onTap: () => _showCounterDetails(counter),
              child: Text(
                counter['CounterNo']?.toString() ?? '0',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          DataCell(
            GestureDetector(
              onTap: () => _showCounterDetails(counter),
              child: Text(
                counter['CashierName']?.toString() ?? 'N/A',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          DataCell(
            GestureDetector(
              onTap: () => _showCounterDetails(counter),
              child: Text(
                counter['CounterCloseNo']?.toString() ?? '0',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          DataCell(
            GestureDetector(
              onTap: () => _showCounterDetails(counter),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    counter['CloseTime']?.split(' ')[0] ?? 'N/A', // Date
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    counter['CloseTime'] != null
                        ? counter['CloseTime'].split(' ')[1] +
                            ' ' +
                            counter['CloseTime'].split(' ')[2] // Time
                        : 'N/A',
                    style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ]);
      }).toList(),
    );
  }
}
