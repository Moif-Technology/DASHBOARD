import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final _storage = FlutterSecureStorage();

  // Save the token
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
    print('Token saved: $token');
  }

  // Retrieve the token
  static Future<String?> getToken() async {
    String? token = await _storage.read(key: 'token');
    print('Retrieved token: $token');
    return token;
  }

  // Delete the token
  static Future<void> deleteToken() async {
    await _storage.delete(key: 'token');
    print('Token deleted');
  }

  // Save the company ID
  static Future<void> saveCompanyID(String companyId) async {
    await _storage.write(key: 'companyId', value: companyId);
    print('Company ID saved: $companyId');
  }

  // Retrieve the company ID
  static Future<String?> getCompanyID() async {
    String? companyId = await _storage.read(key: 'companyId');
    print('Retrieved Company ID: $companyId');
    return companyId;
  }

  // Save the company name
  static Future<void> saveCompanyName(String companyName) async {
    await _storage.write(key: 'companyName', value: companyName);
    print('Company name saved: $companyName');
  }

  // Retrieve the company name
  static Future<String?> getCompanyName() async {
    String? companyName = await _storage.read(key: 'companyName');
    print('Retrieved company name: $companyName');
    return companyName;
  }

  // Save the database schema name
  static Future<void> saveDbSchemaName(String dbSchemaName) async {
    await _storage.write(key: 'dbSchemaName', value: dbSchemaName);
    print('DB Schema name saved: $dbSchemaName');
  }

  // Retrieve the database schema name
  static Future<String?> getDbSchemaName() async {
    String? dbSchemaName = await _storage.read(key: 'dbSchemaName');
    print('Retrieved DB Schema name: $dbSchemaName');
    return dbSchemaName;
  }

  // Save the expiry status
  static Future<void> saveExpiryStatus(int expiryStatus) async {
    await _storage.write(key: 'expiryStatus', value: expiryStatus.toString());
    print('Expiry status saved: $expiryStatus');
  }

  // Retrieve the expiry status
  static Future<int?> getExpiryStatus() async {
    String? expiryStatus = await _storage.read(key: 'expiryStatus');
    print('Retrieved expiry status: $expiryStatus');
    return expiryStatus != null ? int.tryParse(expiryStatus) : null;
  }

  // Save the expiry date
  static Future<void> saveExpiryDate(String expiryDate) async {
    await _storage.write(key: 'expiryDate', value: expiryDate);
    print('Expiry date saved: $expiryDate');
  }

  // Retrieve the expiry date
  static Future<String?> getExpiryDate() async {
    String? expiryDate = await _storage.read(key: 'expiryDate');
    print('Retrieved expiry date: $expiryDate');
    return expiryDate;
  }

  // Clear all saved data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
    print('All tokens and data cleared');
  }
}
