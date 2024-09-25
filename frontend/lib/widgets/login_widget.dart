import 'package:another_flushbar/flushbar.dart'; // Import the another_flushbar package
import 'package:fitness_dashboard_ui/services/api_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSecurePassword = true;
  bool _isLoading = false; // To track loading state
  final ApiServices _apiServices = ApiServices(); // Centralized API service
  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // For secure storage of JWT

  void _login() async {
    // Disable the button during the login process
    setState(() {
      _isLoading = true;
    });

    try {
      String? loginError = await _apiServices.login(
        _usernameController.text.trim(),
        _passwordController.text.trim(),
      );

      // Handle login error
      if (loginError != null) {
        _showErrorFlushbar(loginError);
      } else {
        await Future.delayed(Duration(milliseconds: 500));

        // Fetch token and company details from secure storage
        final String? token = await _storage.read(key: 'token');
        final String? companyId = await _storage.read(key: 'companyId');
        final String? companyName = await _storage.read(key: 'companyName');
        final String? dbSchemaName = await _storage.read(key: 'dbSchemaName');

        // Only proceed if all values are valid
        if (token != null &&
            token.isNotEmpty &&
            companyId != null &&
            companyId.isNotEmpty &&
            companyName != null &&
            companyName.isNotEmpty &&
            dbSchemaName != null &&
            dbSchemaName.isNotEmpty) {
          Navigator.pushReplacementNamed(
            context,
            '/main',
            arguments: 'Login successful!',
          );
        } else {
          _showErrorFlushbar('Some values are null or empty.');
        }
      }
    } catch (e) {
      _showErrorFlushbar('Login failed: $e');
    } finally {
      // Enable the button again after the login attempt
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorFlushbar(String message) {
    Flushbar(
      message: message,
      backgroundColor: Colors.redAccent,
      duration: Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP, // Position it at the top
      margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      padding: EdgeInsets.all(15.0),
      borderRadius: BorderRadius.circular(12.0),
      icon: Icon(
        Icons.error_outline,
        color: Colors.white,
        size: 28.0,
      ),
      shouldIconPulse: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          spreadRadius: 2,
          blurRadius: 10,
          offset: Offset(0, 3),
        ),
      ],
      mainButton: TextButton(
        onPressed: () {
          Flushbar().dismiss(context); // Dismiss on click
        },
        child: Text(
          'DISMISS',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      isDismissible: true,
    ).show(context);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background Color with Subtle Gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF5F5F5), // Light Grey (Top)
                    Color(0xFFE0E0E0), // Soft Grey (Bottom)
                  ],
                ),
              ),
            ),
            // Centered Login Form
            Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 500, // Max width for the form
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLogo(screenWidth),
                      SizedBox(height: screenHeight * 0.05),
                      _buildUsernameField(),
                      SizedBox(height: screenHeight * 0.02),
                      _buildPasswordField(),
                      SizedBox(height: screenHeight * 0.04),
                      _buildLoginButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(double screenWidth) {
    return Column(
      children: [
        Image.asset(
          'assets/images/logo.png', // Your logo image
          width: screenWidth * 0.4, // Adjust the width based on screen size
        ),
        const SizedBox(height: 16),
        Text(
          'Welcome Back',
          style: TextStyle(
            fontSize: screenWidth * 0.07, // Large title size
            fontWeight: FontWeight.bold,
            color: Color(0xFF3A1C71), // Deep violet for contrast
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUsernameField() {
    return TextField(
      controller: _usernameController,
      decoration: InputDecoration(
        labelText: 'Username',
        prefixIcon: Icon(Icons.person_outline,
            color: Color(0xFF3A1C71)), // Deep violet icon color
        filled: true,
        fillColor: Colors.white, // Solid white background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Subtle rounded corners
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(
            color: Color(0xFF3A1C71)), // Deep violet text color for labels
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF3A1C71)),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      ),
      style: TextStyle(
          color: Color(0xFF3A1C71)), // Deep violet text color for input
    );
  }

  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: _isSecurePassword,
      decoration: InputDecoration(
        labelText: 'Password',
        prefixIcon: Icon(Icons.lock_outline,
            color: Color(0xFF3A1C71)), // Deep violet icon color
        suffixIcon: IconButton(
          icon: Icon(
            _isSecurePassword ? Icons.visibility : Icons.visibility_off,
            color: Color(0xFF3A1C71),
          ),
          onPressed: () {
            setState(() {
              _isSecurePassword = !_isSecurePassword;
            });
          },
        ),
        filled: true,
        fillColor: Colors.white, // Solid white background
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), // Subtle rounded corners
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(
            color: Color(0xFF3A1C71)), // Deep violet text color for labels
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF3A1C71)),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      ),
      style: TextStyle(
          color: Color(0xFF3A1C71)), // Deep violet text color for input
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFAA00), // Orange-Yellow
              Color(0xFFFF3D3D), // Red
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: Offset(0, 4), // Subtle shadow below the button
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _login, // Disable button if loading
          child: _isLoading
              ? CircularProgressIndicator(
                  color: Colors.white,
                )
              : Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
