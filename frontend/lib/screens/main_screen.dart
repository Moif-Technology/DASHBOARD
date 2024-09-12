import 'dart:async';
import 'package:fitness_dashboard_ui/widgets/countersDialog.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/util/responsive.dart';
import 'package:fitness_dashboard_ui/widgets/dashboard_widget.dart';
import 'package:fitness_dashboard_ui/widgets/side_menu_widget.dart';
import 'package:fitness_dashboard_ui/widgets/summary_widget.dart';
import 'package:fitness_dashboard_ui/services/api_services.dart';
import 'package:fitness_dashboard_ui/services/token_management.dart';
import 'package:fitness_dashboard_ui/widgets/login_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();
  final ApiServices _apiServices = ApiServices();
  bool _isLoading = true;
  Map<String, dynamic>? _fetchedData;
  bool _isSubscriptionExpired = false;
  String? _selectedBranchId;
  String? _defaultBranchName;
  List<Map<String, String>> _branches = [];
  bool _isFirstLoad = true;
  DateTime _lastUpdated = DateTime.now();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _startAutoUpdateTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startAutoUpdateTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Just triggering a rebuild every second
        });
      }
    });
  }

  Future<void> _initializeData() async {
    final branches = await _apiServices.fetchBranches();
    final defaultBranchId = await TokenManager.getStationID();

    Map<String, String>? defaultBranch;
    if (branches.isNotEmpty) {
      // Find the default branch using the defaultBranchId
      defaultBranch = branches.firstWhere(
          (branch) => branch['BranchID'] == defaultBranchId,
          orElse: () => branches.first);
    }

    setState(() {
      _branches = branches;
      // Set the selected branch ID and name for the dropdown
      _selectedBranchId =
          defaultBranch != null ? defaultBranch['BranchID'] : null;
      _defaultBranchName = defaultBranch != null
          ? defaultBranch['BranchName']
          : 'No Branch Available';
    });
    print("Selected Branch ID: $_selectedBranchId");
    if (_isFirstLoad) {
      _isFirstLoad = false;
      _fetchData();
    }
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await _apiServices.fetchSalesDetails(
        _selectedDate.toString(),
        branchId: _selectedBranchId,
      );
      setState(() {
        _fetchedData = data;
        _isSubscriptionExpired = _fetchedData?['expired'] ?? false;
        _lastUpdated = DateTime.now();
      });
    } catch (error) {
      print("Error fetching data: $error");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getFormattedElapsedTime() {
    final elapsed = DateTime.now().difference(_lastUpdated);
    final minutes = elapsed.inMinutes.toString().padLeft(2, "0");
    final seconds = (elapsed.inSeconds % 60).toString().padLeft(2, "0");
    return "$minutes min $seconds sec ago";
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchData();
  }

  void _onBranchSelected(String? branchId) {
    if (branchId == null) return;
    if (_selectedBranchId != branchId) {
      setState(() {
        _selectedBranchId = branchId;
        _defaultBranchName = _branches.firstWhere(
            (branch) => branch['BranchID'] == branchId)['BranchName'];
        _fetchData();
      });
    }
  }

  void _logout() async {
    await _apiServices.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  // Function to show the counters dialog
// Function to show the counters dialog with branchId
void _showCountersDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CountersDialog(branchId: _selectedBranchId); // Pass branchId
    },
  );
}


  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);
    final isMobile = Responsive.isMobile(context);

    return Scaffold(
      drawer: !isDesktop
          ? SizedBox(
              width: 250,
              child: SideMenuWidget(
                selectedBranchId: _selectedBranchId, // Pass branchId to SideMenu
              ),
            )
          : null,
      endDrawer: isMobile
          ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SummaryWidget(
                selectedDate: _selectedDate,
                branchId: _selectedBranchId,
              ),
            )
          : null,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : _isSubscriptionExpired
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Subscription expired. Please renew.',
                          style:
                              const TextStyle(fontSize: 18, color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _logout,
                          child: const Text('Logout'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section with Branch Dropdown and Last Updated
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Branch Info Heading
                                Text(
                                  'Branch Info',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: DropdownButton<String>(
                                          value: _selectedBranchId,
                                          onChanged: _onBranchSelected,
                                          items: _branches.map((branch) {
                                            return DropdownMenuItem<String>(
                                              value: branch['BranchID'],
                                              child: Text(
                                                branch['BranchName'] ??
                                                    'Unnamed Branch',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black87,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          icon: const Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.black54,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.refresh, size: 20),
                                      onPressed: _fetchData,
                                      tooltip: 'Refresh Data',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Last updated ${_getFormattedElapsedTime()}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Main Dashboard Content with Selected Date and Stylish Button
                          Row(
                            children: [
                              InkWell(
                                onTap:
                                    _showCountersDialog, // Opens the dialog with counters
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 12),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF4A90E2),
                                        Color(0xFF50E3C2)
                                      ], // Blue and teal gradient
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        spreadRadius: 2,
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Text(
                                    'Show Counters',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DashboardWidget(
                            selectedDate: _selectedDate,
                            onDateSelected: _onDateSelected,
                            branchId: _selectedBranchId,
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
