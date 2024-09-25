import 'dart:convert';

import 'package:fitness_dashboard_ui/services/token_management.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ApiServices {
  // final String _baseUrl = 'http://10.39.1.64:5000';
  final String _baseUrl = 'https://dashboard-two-sigma-80.vercel.app';
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
        final errorData = jsonDecode(response.body);
        print('Error: ${errorData['message']}');
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
      return data;
    } else if (response.statusCode == 403) {
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

  Future<List<Map<String, String>>> fetchBranches({String? branchId}) async {
    try {
      branchId ??= await TokenManager.getStationID();
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
    branchId ??= await TokenManager.getStationID();

    final endpoint = branchId != null
        ? '/salesDetails?date=$date&branchId=$branchId'
        : '/salesDetails?date=$date';

    final response = await get(endpoint);
    return await _handleApiResponse(response);
  }

  Future<int> fetchCustomerCount(String date, {String? branchId}) async {
    branchId ??= await TokenManager.getStationID();

    final endpoint = branchId != null
        ? '/customerCount?date=$date&branchId=$branchId'
        : '/customerCount?date=$date';

    final response = await get(endpoint);
    final data = await _handleApiResponse(response);
    if (data is Map<String, dynamic> && data.containsKey('totalCustomers')) {
      return data['totalCustomers'];
    } else {
      throw Exception(
          'Unexpected data format: Expected a Map<String, dynamic> with totalCustomers key');
    }
  }

  Future<List<FlSpot>> fetchMonthlySales({String? branchId}) async {
    branchId ??= await TokenManager.getStationID();

    final endpoint =
        branchId != null ? '/monthlySales?branchId=$branchId' : '/monthlySales';

    final response = await get(endpoint);
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

  Future<List<Map<String, dynamic>>> fetchAreaSales(DateTime date,
      {String? branchId}) async {
    try {
      branchId ??= await TokenManager.getStationID();

      final endpoint = branchId != null
          ? '/areaSales?date=$date&branchId=$branchId'
          : '/areaSales?date=$date';

      final response = await get(endpoint);
      lastResponseStatusCode = response.statusCode;
      if (response.statusCode == 404) {
        print('Area sales data is not available for this company.');
        return [];
      }

      if (response.statusCode == 403) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message']);
      }

      final data = await _handleApiResponse(response);
      if (data is List<dynamic>) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else if (data is Map<String, dynamic>) {
        return [data];
      } else {
        throw Exception(
            'Unexpected data format: Expected a List<Map<String, dynamic>> or Map<String, dynamic>');
      }
    } catch (e) {
      print('Error fetching area sales data: $e');
      return [];
    }
  }

  Future<List> fetchCounterCloseDetails({String? branchId}) async {
    branchId ??= await TokenManager
        .getStationID(); // Get branchId from token if not passed explicitly

    final response = await get(
        '/CounterClose?branchId=$branchId'); // Pass branchId as query parameter
    final data = await _handleApiResponse(response);

    if (data is List) {
      return data.map((counter) {
        return counter.map((key, value) {
          if (value is int || value is double || value is DateTime) {
            return MapEntry(key,
                value.toString()); // Convert int, double, DateTime to String
          }
          return MapEntry(key, value); // Leave strings as they are
        });
      }).toList();
    } else {
      throw Exception(
          'Unexpected data format: Expected a List<Map<String, dynamic>>');
    }
  }

  Future<Map<String, dynamic>> fetchItemSaleReport({
    required String fromDate,
    required String toDate,
    String? branchId,
    String? groupName, // Include groupName as a parameter
  }) async {
    try {
      // Fetch branchId from token if not provided
      branchId ??= await TokenManager.getStationID();

      // Construct API endpoint with query parameters, including groupName if provided
      String endpoint =
          '/getItemReport?fromDate=$fromDate&toDate=$toDate&branchId=$branchId';

      if (groupName != null && groupName.isNotEmpty) {
        // Use Uri.encodeComponent to encode the groupName before adding it to the query string
        endpoint += '&groupName=${Uri.encodeComponent(groupName)}';
      }
      // Print the constructed API endpoint to debug the query parameters
      print('Constructed API endpoint: $endpoint');

      // Make the GET request
      final response = await get(endpoint);

      // Print raw response to debug the issue
      print('API Raw Response: ${response.body}');

      // Handle the response using the utility function
      final data = await _handleApiResponse(response);

      // If the response is a map, return groupNames and data
      if (data is Map<String, dynamic>) {
        final groupNames = data['groupNames'] != null
            ? List<String>.from(data['groupNames'])
            : [];
        final dataList = data['data'] != null
            ? List<Map<String, dynamic>>.from(data['data'])
            : [];

        return {
          'groupNames': groupNames,
          'data': dataList,
        };
      } else {
        throw Exception(
            'Unexpected data format: Expected a Map<String, dynamic>');
      }
    } catch (e) {
      print('Error fetching item sale report: $e');
      return {
        'groupNames': [],
        'data': [],
      };
    }
  }

  Future<List<Map<String, dynamic>>> fetchGroupReport({
    required String fromDate,
    required String toDate,
    String? branchId,
  }) async {
    try {
      // Ensure token is loaded before making the request
      await _loadToken();

      // Construct the API endpoint
      final endpoint = branchId != null
          ? '/getGroupReport?fromDate=$fromDate&toDate=$toDate&branchId=$branchId'
          : '/getGroupReport?fromDate=$fromDate&toDate=$toDate';

      // Make the GET request with the token
      final response = await http.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      // Handle the API response
      final data = await _handleApiResponse(response);

      // Ensure that the data is in the expected format (List of Maps)
      if (data is List<dynamic>) {
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else if (data is Map<String, dynamic> && data.containsKey('data')) {
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        throw Exception('Unexpected data format: Expected a List of Maps');
      }
    } catch (e) {
      print('Error fetching group report: $e');
      return [];
    }
  }
}
