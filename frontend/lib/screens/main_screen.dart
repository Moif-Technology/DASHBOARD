import 'dart:async';
import 'package:fitness_dashboard_ui/util/responsive.dart';
import 'package:fitness_dashboard_ui/widgets/dashboard_widget.dart';
import 'package:fitness_dashboard_ui/widgets/side_menu_widget.dart';
import 'package:fitness_dashboard_ui/widgets/summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/services/api_services.dart';
import 'package:fitness_dashboard_ui/widgets/login_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();
  final ApiServices _apiServices = ApiServices();
  DateTime _lastUpdated = DateTime.now();
  bool _isLoading = true; // Initially true to show the spinner
  Map<String, dynamic>? _fetchedData; // Store fetched data
  bool _isSubscriptionExpired = false; // Track if subscription is expired
  late Timer _timer;
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch
        .start(); // Start the stopwatch to track the time since last update
    _startTimer(); // Start the timer to update UI every second
    _fetchData(); // Initial data fetch
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {}); // Update the UI every 500 milliseconds
    });
  }

  String _getFormattedElapsedTime() {
    final elapsed = _stopwatch.elapsed;
    final minutes = elapsed.inMinutes.toString().padLeft(2, "0");

    return "$minutes - Min";
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true; // Start showing the initial loading spinner
    });

    // Fetch data from the API
    try {
      final data =
          await _apiServices.fetchSalesDetails(_selectedDate.toString());
      setState(() {
        _fetchedData = data;
        _isSubscriptionExpired = _fetchedData?['expired'] ?? false;
        _lastUpdated = DateTime.now();
        _stopwatch.reset();
        _stopwatch.start(); // Reset and start the stopwatch on data fetch
      });
    } catch (error) {
      // Handle errors appropriately in production
      print("Error fetching data: $error");
    } finally {
      setState(() {
        _isLoading = false; // Stop showing spinner
      });
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
    _fetchData(); // Fetch data whenever the date is changed
  }

  Future<void> _refreshData() async {
    await _fetchData(); // Fetch data when pull-to-refresh or refresh button is clicked
  }

  void _logout() async {
    await _apiServices.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context);

    return Scaffold(
      drawer: !isDesktop
          ? const SizedBox(
              width: 250,
              child: SideMenuWidget(),
            )
          : null,
      endDrawer: Responsive.isMobile(context)
          ? SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: SummaryWidget(selectedDate: _selectedDate),
            )
          : null,
      body: SafeArea(
        child: _isLoading // Show loading spinner if data is still being fetched
            ? const Center(
                child:
                    CircularProgressIndicator()) // Initial spinner while data is loading
            : _isSubscriptionExpired // Check if subscription is expired
                ? Stack(
                    children: [
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            _fetchedData?['message'] ??
                                'Company subscription has expired.',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: ElevatedButton(
                          onPressed: _logout,
                          child: const Text('Logout'),
                        ),
                      ),
                    ],
                  )
                : RefreshIndicator(
                    onRefresh: _refreshData, // Trigger refresh on pull down
                    child: SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(), // Make sure it's scrollable even when content is small
                      child: Column(
                        children: [
                          // Last updated text with refresh icon at the top
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Last updated ${_getFormattedElapsedTime()} ago",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(
                                    width: 8), // Spacing between text and icon
                                GestureDetector(
                                  onTap: _refreshData,
                                  child: const Icon(
                                    Icons.refresh,
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Header Widget
                          Row(
                            children: [
                              if (isDesktop)
                                Expanded(
                                  flex: 2,
                                  child: const SideMenuWidget(),
                                ),
                              Expanded(
                                flex: 7,
                                child: DashboardWidget(
                                  selectedDate: _selectedDate,
                                  onDateSelected: _onDateSelected,
                                ),
                              ),
                              if (isDesktop)
                                Expanded(
                                  flex: 3,
                                  child: SummaryWidget(
                                      selectedDate: _selectedDate),
                                ),
                            ],
                          ),
                          // Expanded content below
                          Column(
                            children: [
                              // Your existing content below this, like charts, cards, etc.
                              if (_fetchedData != null)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                      "Fetched Data: ${_fetchedData.toString()}"),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
      ),
    );
  }
}
