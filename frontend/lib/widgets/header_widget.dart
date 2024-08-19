import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fitness_dashboard_ui/widgets/side_menu_widget.dart';
import 'package:fitness_dashboard_ui/util/responsive.dart';

class HeaderWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final DateTime selectedDate;

  const HeaderWidget({
    super.key,
    required this.onDateSelected,
    required this.selectedDate,
  });

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      widget.onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // For mobile screens, show the hamburger menu instead of the full sidebar
        if (!Responsive.isDesktop(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer(); // Open the side menu
            },
          ),

        // SideMenu is integrated and visible directly for larger screens
        if (Responsive.isDesktop(context)) const SideMenuWidget(),

        // Date picker and selected date display
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.calendar_month_sharp,
                      color: Colors.grey,
                      size: 25,
                    ),
                    onPressed: _pickDate,
                  ),
                  Text(
                    'Selected Date: ${DateFormat('yyyy-MM-dd').format(widget.selectedDate)}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              InkWell(
                onTap: () => Scaffold.of(context).openEndDrawer(),
                child: CircleAvatar(
                  backgroundColor: Colors.transparent,
                  child: Image.asset(
                    "assets/images/avatar.png",
                    width: 32,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
