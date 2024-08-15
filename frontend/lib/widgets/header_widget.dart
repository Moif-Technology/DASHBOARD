import 'package:fitness_dashboard_ui/const/constant.dart';
import 'package:fitness_dashboard_ui/util/responsive.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HeaderWidget extends StatefulWidget {
  final Function(DateTime) onDateSelected;

  const HeaderWidget({super.key, required this.onDateSelected});

  @override
  _HeaderWidgetState createState() => _HeaderWidgetState();
}

class _HeaderWidgetState extends State<HeaderWidget> {
  DateTime? _selectedDate;

  void _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
      widget.onDateSelected(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (!Responsive.isDesktop(context))
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.menu,
                      color: primaryColor, // Updated color
                      size: 25,
                    ),
                  ),
                ),
              ),
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
                  _selectedDate != null
                      ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
                      : 'Select Date',
                  style: TextStyle(color: Colors.white, fontSize: 16),
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
      ],
    );
  }
}
