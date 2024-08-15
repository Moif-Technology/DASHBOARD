import 'package:fitness_dashboard_ui/const/constant.dart';
import 'package:fitness_dashboard_ui/screens/main_screen.dart';
import 'package:fitness_dashboard_ui/services/auth_middleware.dart';
import 'package:flutter/material.dart';
import 'package:fitness_dashboard_ui/widgets/login_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if token exists
  bool isAuthenticated = await AuthMiddleware.isAuthenticated();
  runApp(MyApp(isAuthenticated: isAuthenticated));
}

class MyApp extends StatelessWidget {
  final bool isAuthenticated;

  const MyApp({super.key, required this.isAuthenticated});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dashboard UI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: backgroundColor,
        brightness: Brightness.light,
        textTheme: TextTheme(
          displayLarge: TextStyle(color: primaryColor),
          bodyLarge: TextStyle(color: Colors.black),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: primaryColor,
          textTheme: ButtonTextTheme.primary,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: primaryColor),
          ),
        ),
      ),
      home: isAuthenticated ? const MainScreen() : LoginScreen(),
      routes: {
        '/main': (context) => const MainScreen(),
      },
    );
  }
}
