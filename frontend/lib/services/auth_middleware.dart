import 'package:flutter/material.dart';
import 'token_management.dart';
import 'api_services.dart';

class AuthMiddleware {
  final ApiServices _apiService = ApiServices(); // No need to pass the base URL

  static Future<bool> isAuthenticated() async {
    String? token = await TokenManager.getToken();
    return token != null;
  }

  Future<void> attachTokenIfNeeded() async {
    bool isAuthenticated = await AuthMiddleware.isAuthenticated();
    if (isAuthenticated) {
      String? token = await TokenManager.getToken();
      _apiService.attachToken(token!); // Attach token to API requests
    }
  }

  static void redirectToLogin(BuildContext context) {
    Navigator.pushReplacementNamed(context, '/login');
  }
}
