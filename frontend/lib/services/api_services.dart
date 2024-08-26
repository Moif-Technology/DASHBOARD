import 'dart:convert';
import 'package:fitness_dashboard_ui/services/token_management.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiServices {
  final String _baseUrl = 'http://10.39.1.171:5000';
  // final String _baseUrl = 'https://155f-5-195-73-11.ngrok-free.app';
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _token;
  int? lastResponseStatusCode;

  ApiServices();

  void attachToken(String token) {
    _token = token;
  }

  Future<String?> login(String username, String password) async {
    try {
      print('Attempting to login with username: $username');
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        print('Login response body: $responseBody');

        final token = responseBody['token'] as String;
        final companyId = responseBody['CompanyID']?.toString() ?? "";
        final companyName = responseBody['CompanyName']?.toString() ?? "";
        final dbSchemaName = responseBody['DbSchemaName']?.toString() ?? "";
        final stationId = responseBody['StationID']?.toString() ?? "";
        final systemRoleId = responseBody['SystemRoleID']?.toString() ?? "";
        final branchName = responseBody['BranchName']?.toString() ?? "";
        final expiryStatus =
            int.tryParse(responseBody['ExpiryStatus'].toString()) ?? 0;
        final expiryDate = responseBody['ExpiryDate']?.toString() ?? "";

        // Removed branch fetching logic here

        await TokenManager.saveAllData(
          token: token,
          companyId: companyId,
          companyName: companyName,
          dbSchemaName: dbSchemaName,
          stationId: stationId,
          systemRoleId: systemRoleId,
          branchName: branchName,
          expiryStatus: expiryStatus,
          expiryDate: expiryDate,
        );

        _token = token;

        print('Login successful. Token and company details saved.');
        return null;
      } else if (response.statusCode == 401) {
        return 'Invalid username or password';
      } else if (response.statusCode == 403) {
        return 'Company subscription has expired.';
      } else if (response.statusCode == 404) {
        // Handle specific status code scenarios
        final errorData = jsonDecode(response.body);
        print('Error: ${errorData['message']}'); // Print the error message
      } else {
        print('Error: ${response.body}');
        return 'Error: ${response.statusCode}';
      }
    } catch (e) {
      print('Error in login request: $e');
      return 'Error: $e';
    }
  }

  Future<void> logout() async {
    try {
      final String? token = await _storage.read(key: 'token');
      if (token != null) {
        final response = await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.statusCode == 200) {
          await _storage.deleteAll(); // Clear all secure storage data
          _token = null; // Clear in-memory token
          print('Logout successful.');
        } else {
          throw Exception('Failed to logout: ${response.body}');
        }
      } else {
        throw Exception('No token found');
      }
    } catch (e) {
      print('Logout error: $e');
      throw Exception('Logout error: $e');
    }
  }

  Future<dynamic> _handleApiResponse(http.Response response) async {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('API Response: $data');
      return data; // Returning raw data to handle in specific methods
    } else if (response.statusCode == 403) {
      // Handle expired status
      return {'expired': true, 'message': 'Company subscription has expired.'};
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<http.Response> get(String endpoint) async {
    await _loadToken(); // Ensure token is loaded
    final response = await http.get(
      Uri.parse('$_baseUrl$endpoint'),
      headers: _buildHeaders(),
    );
    return response;
  }

  Future<List<Map<String, String>>> fetchBranches() async {
    try {
      final response = await get('/fetchBranches');
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print(jsonData);
        if (jsonData is Map<String, dynamic> &&
            jsonData.containsKey('branches')) {
          final branchList = jsonData['branches'];
          if (branchList is List<dynamic>) {
            return branchList
                .map((branch) => Map<String, String>.from(branch))
                .toList();
          } else {
            throw Exception('Invalid JSON response');
          }
        } else {
          throw Exception('Invalid JSON response');
        }
      } else {
        print('Error fetching branches: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching branches: $e');
      return [];
    }
  }

  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<void> _loadToken() async {
    if (_token == null) {
      _token = await _storage.read(key: 'token');
    }
  }

  Future<Map<String, dynamic>> fetchSalesDetails(String date,
      {String? branchId}) async {
    // Prioritize the manually selected branch ID over the token-stored branch ID
    branchId ??= await TokenManager.getStationID();

    final endpoint = branchId != null
        ? '/salesDetails?date=$date&branchId=$branchId'
        : '/salesDetails?date=$date';

    final response = await get(endpoint);
    return await _handleApiResponse(response);
  }

  Future<int> fetchCustomerCount(String date) async {
    final response = await get('/customerCount?date=$date');
    final data = await _handleApiResponse(response);
    if (data is Map<String, dynamic> && data.containsKey('totalCustomers')) {
      return data['totalCustomers'];
    } else {
      throw Exception(
          'Unexpected data format: Expected a Map<String, dynamic> with totalCustomers key');
    }
  }

  Future<List<FlSpot>> fetchMonthlySales() async {
    final response = await get('/monthlySales');
    final data = await _handleApiResponse(response);
    if (data is List<dynamic>) {
      List<FlSpot> spots = [];
      for (var entry in data) {
        if (entry is Map<String, dynamic>) {
          double x = (entry['Month'] - 1).toDouble();
          double y = entry['TotalAmount'].toDouble();
          spots.add(FlSpot(x, y));
        }
      }
      return spots;
    } else {
      throw Exception(
          'Unexpected data format: Expected a List<Map<String, dynamic>>');
    }
  }

  Future<List<Map<String, dynamic>>> fetchAreaSales(DateTime date) async {
    try {
      final response = await get('/areaSales?date=$date');
      lastResponseStatusCode = response.statusCode;
      if (response.statusCode == 404) {
        // Handle the scenario where area sales data is not available
        print('Area sales data is not available for this company.');
        return []; // Return an empty list if data is not available
      }

      if (response.statusCode == 403) {
        // Handle token expiry or subscription expiry
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message']);
      }

      final data = await _handleApiResponse(response);
      if (data is List<dynamic>) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else if (data is Map<String, dynamic>) {
        return [data]; // Wrap the single map in a list
      } else {
        throw Exception(
            'Unexpected data format: Expected a List<Map<String, dynamic>> or Map<String, dynamic>');
      }
    } catch (e) {
      print('Error fetching area sales data: $e');
      return [];
    }
  }
}
