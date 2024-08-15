import 'package:fitness_dashboard_ui/util/responsive.dart';
import 'package:fitness_dashboard_ui/widgets/dashboard_widget.dart';
import 'package:fitness_dashboard_ui/widgets/side_menu_widget.dart';
import 'package:fitness_dashboard_ui/widgets/summary_widget.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/services/api_services.dart';
import 'package:fitness_dashboard_ui/widgets/login_widget.dart'; // Import your login screen

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  DateTime _selectedDate = DateTime.now();
  final ApiServices _apiServices = ApiServices();

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _logout() async {
    await _apiServices.logout();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (context) =>
              LoginScreen()), // Navigate back to the login screen
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
        child: FutureBuilder<Map<String, dynamic>>(
          future: _apiServices.fetchSalesDetails(_selectedDate.toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              print('Response Data: ${snapshot.data}');

              if (snapshot.data?['expired'] == true) {
                return Stack(
                  children: [
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Text(
                          snapshot.data?['message'] ??
                              'Company subscription has expired.',
                          style: TextStyle(
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
                        child: Text('Logout'),
                      ),
                    ),
                  ],
                );
              } else {
                return Row(
                  children: [
                    if (isDesktop)
                      Expanded(
                        flex: 2,
                        child: SizedBox(
                          child: SideMenuWidget(),
                        ),
                      ),
                    Expanded(
                      flex: 7,
                      child: DashboardWidget(),
                    ),
                    if (isDesktop)
                      Expanded(
                        flex: 3,
                        child: SummaryWidget(selectedDate: _selectedDate),
                      ),
                  ],
                );
              }
            } else {
              return Center(child: Text('No data available.'));
            }
          },
        ),
      ),
    );
  }
}
