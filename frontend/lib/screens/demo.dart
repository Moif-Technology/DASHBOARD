// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:fitness_dashboard_ui/util/responsive.dart';
// import 'package:fitness_dashboard_ui/widgets/dashboard_widget.dart';
// import 'package:fitness_dashboard_ui/widgets/side_menu_widget.dart';
// import 'package:fitness_dashboard_ui/widgets/summary_widget.dart';
// import 'package:fitness_dashboard_ui/services/api_services.dart';
// import 'package:fitness_dashboard_ui/services/token_management.dart';
// import 'package:fitness_dashboard_ui/widgets/login_widget.dart';

// class MainScreen extends StatefulWidget {
//   const MainScreen({super.key});

//   @override
//   _MainScreenState createState() => _MainScreenState();
// }

// class _MainScreenState extends State<MainScreen> {
//   DateTime _selectedDate = DateTime.now();
//   final ApiServices _apiServices = ApiServices();
//   bool _isLoading = true;
//   Map<String, dynamic>? _fetchedData;
//   bool _isSubscriptionExpired = false;
//   String? _selectedBranchId;
//   String? _defaultBranchName;
//   List<Map<String, String>> _branches = [];
//   bool _isFirstLoad = true;
//   DateTime _lastUpdated = DateTime.now();
//   final Stopwatch _stopwatch = Stopwatch();

//   @override
//   void initState() {
//     super.initState();
//     _initializeData();
//     _stopwatch.start();
//   }

//   Future<void> _initializeData() async {
//     final branches = await _apiServices.fetchBranches();
//     final defaultBranchId = await TokenManager.getStationID();

//     Map<String, String>? defaultBranch;
//     if (branches.isNotEmpty) {
//       // Find the default branch using the defaultBranchId
//       defaultBranch = branches.firstWhere(
//           (branch) => branch['BranchID'] == defaultBranchId,
//           orElse: () => branches.first);
//     }

//     setState(() {
//       _branches = branches;
//       // Set the selected branch ID and name for the dropdown
//       _selectedBranchId =
//           defaultBranch != null ? defaultBranch['BranchID'] : null;
//       _defaultBranchName = defaultBranch != null
//           ? defaultBranch['BranchName']
//           : 'No Branch Available';
//     });
//     print("Selected Branch ID: $_selectedBranchId");
//     if (_isFirstLoad) {
//       _isFirstLoad = false;
//       _fetchData();
//     }
//   }

//   Future<void> _fetchData() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final data = await _apiServices.fetchSalesDetails(
//         _selectedDate.toString(),
//         branchId: _selectedBranchId,
//       );
//       setState(() {
//         _fetchedData = data;
//         _isSubscriptionExpired = _fetchedData?['expired'] ?? false;
//         _lastUpdated = DateTime.now();
//         _stopwatch.reset();
//         _stopwatch.start();
//       });
//     } catch (error) {
//       print("Error fetching data: $error");
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   String _getFormattedElapsedTime() {
//     final elapsed = _stopwatch.elapsed;
//     final minutes = elapsed.inMinutes.toString().padLeft(2, "0");
//     return "$minutes min ago";
//   }

//   void _onDateSelected(DateTime date) {
//     setState(() {
//       _selectedDate = date;
//     });
//     _fetchData();
//   }

//   void _onBranchSelected(String? branchId) {
//     if (branchId == null) return;
//     if (_selectedBranchId != branchId) {
//       setState(() {
//         _selectedBranchId = branchId;
//         _defaultBranchName = _branches.firstWhere(
//             (branch) => branch['BranchID'] == branchId)['BranchName'];
//         _fetchData();
//       });
//     }
//   }

//   void _logout() async {
//     await _apiServices.logout();
//     Navigator.of(context).pushReplacement(
//       MaterialPageRoute(
//         builder: (context) => LoginScreen(),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDesktop = Responsive.isDesktop(context);
//     final isMobile = Responsive.isMobile(context);

//     return Scaffold(
//       drawer: !isDesktop
//           ? const SizedBox(
//               width: 250,
//               child: SideMenuWidget(),
//             )
//           : null,
//       endDrawer: isMobile
//           ? SizedBox(
//               width: MediaQuery.of(context).size.width * 0.8,
//               child: SummaryWidget(selectedDate: _selectedDate),
//             )
//           : null,
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(),
//               )
//             : _isSubscriptionExpired
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Subscription expired. Please renew.',
//                           style:
//                               const TextStyle(fontSize: 18, color: Colors.red),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: _logout,
//                           child: const Text('Logout'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue,
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 24, vertical: 12),
//                           ),
//                         ),
//                       ],
//                     ),
//                   )
//                 : RefreshIndicator(
//                     onRefresh: _fetchData,
//                     child: SingleChildScrollView(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 24),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Info and Refresh Section
//                           Container(
//                             padding: const EdgeInsets.all(16),
//                             margin: const EdgeInsets.only(bottom: 24),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.2),
//                                   spreadRadius: 2,
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       _defaultBranchName ?? 'Branch Info',
//                                       style: TextStyle(
//                                         fontSize: 20,
//                                         fontWeight: FontWeight.bold,
//                                         color: Colors.black87,
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       "Last updated ${_getFormattedElapsedTime()}",
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey[600],
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 IconButton(
//                                   icon: Icon(Icons.refresh,
//                                       color: Colors.blue[700]),
//                                   onPressed: _fetchData,
//                                   tooltip: 'Refresh Data',
//                                 ),
//                               ],
//                             ),
//                           ),
//                           // Branch Selector Section
//                           Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 16, vertical: 12),
//                             margin: const EdgeInsets.only(bottom: 24),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(10),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.grey.withOpacity(0.2),
//                                   spreadRadius: 2,
//                                   blurRadius: 10,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   'Select Your Branch',
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     color: Colors.grey[800],
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 _branches.isEmpty
//                                     ? const Center(
//                                         child: CircularProgressIndicator(),
//                                       )
//                                     : DropdownButton<String>(
//                                         value:
//                                             _selectedBranchId, // This ensures the dropdown shows the selected branch
//                                         onChanged: _onBranchSelected,
//                                         items: _branches.map((branch) {
//                                           return DropdownMenuItem<String>(
//                                             value: branch['BranchID'],
//                                             child: Text(
//                                               branch['BranchName'] ??
//                                                   'Unnamed Branch',
//                                               style: const TextStyle(
//                                                 fontSize: 16,
//                                                 fontWeight: FontWeight.w500,
//                                                 color: Colors.black87,
//                                               ),
//                                             ),
//                                           );
//                                         }).toList(),
//                                         isExpanded: true,
//                                         underline: const SizedBox(),
//                                       ),
//                               ],
//                             ),
//                           ),
//                           // Main Dashboard Content
//                           DashboardWidget(
//                             selectedDate: _selectedDate,
//                             onDateSelected: _onDateSelected,
//                             branchId: _selectedBranchId,
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//       ),
//     );
//   }
// }
