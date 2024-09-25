import 'package:fitness_dashboard_ui/const/constant.dart';
import 'package:fitness_dashboard_ui/data/side_menu_data.dart';
import 'package:fitness_dashboard_ui/services/api_services.dart';
import 'package:fitness_dashboard_ui/widgets/group_report.dart';
import 'package:fitness_dashboard_ui/widgets/login_widget.dart';
import 'package:fitness_dashboard_ui/widgets/reports_details.dart';
import 'package:flutter/material.dart';

class SideMenuWidget extends StatefulWidget {
   final String? selectedBranchId; // Accept branchId from MainScreen

  const SideMenuWidget({super.key, this.selectedBranchId});

  @override
  State<SideMenuWidget> createState() => _SideMenuWidgetState();
}

class _SideMenuWidgetState extends State<SideMenuWidget> {
  int selectedIndex = 0;
  final ApiServices _apiServices = ApiServices();

  @override
  Widget build(BuildContext context) {
    final data = SideMenuData();
    final screenSize = MediaQuery.of(context).size;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 20),
          child: Container(
            color: backgroundColor,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  for (int i = 0; i < data.menu.length; i++)
                    buildMenuEntry(data, i),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildMenuEntry(SideMenuData data, int index) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(
          Radius.circular(6.0),
        ),
        color: isSelected ? selectionColor : Colors.transparent,
      ),
      child: InkWell(
        onTap: () async {
          setState(() {
            selectedIndex = index;
          });

          // Handle SignOut
          if (data.menu[index].title == 'SignOut') {
            await _handleLogout();
          }
          // Handle Reports navigation
          else if (data.menu[index].title == 'Items Reports') {
            Navigator.push(
             context,
              MaterialPageRoute(
                builder: (context) => ReportTable(
                  branchId: widget.selectedBranchId, 
                ),
              ),
            );
          }
          // Handle other menu options (if any)
           else if (data.menu[index].title == 'Group Reports') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupReportTable(
                  branchId: widget.selectedBranchId, // Pass branchId to GroupReportTable
                ),
              ),
            );
          }
        },
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
              child: Icon(
                data.menu[index].icon,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
            Text(
              data.menu[index].title,
              style: TextStyle(
                fontSize: 16,
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await _apiServices.logout();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) =>
            false, // Removes all routes until the login screen
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
