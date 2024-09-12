import 'package:fitness_dashboard_ui/model/menu_model.dart';
import 'package:flutter/material.dart';

class SideMenuData {
  final menu = const <MenuModel>[
    MenuModel(icon: Icons.home, title: 'Dashboard'),
    MenuModel(icon: Icons.assessment_rounded, title: 'Items Reports'),
    MenuModel(
        icon: Icons.stacked_bar_chart,
        title: 'Group Reports'), // Added Group Reports
    MenuModel(icon: Icons.logout, title: 'SignOut'),
  ];
}
