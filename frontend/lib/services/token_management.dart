import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenManager {
  static final _storage = FlutterSecureStorage();

  // Save all login-related data
  static Future<void> saveAllData({
    required String token,
    required String companyId,
    required String companyName,
    required String dbSchemaName,
    required String stationId,
    required String systemRoleId,
    required String branchName,
    required int expiryStatus,
    required String expiryDate,
  }) async {
    await Future.wait([
      _storage.write(key: 'token', value: token),
      _storage.write(key: 'companyId', value: companyId),
      _storage.write(key: 'companyName', value: companyName),
      _storage.write(key: 'dbSchemaName', value: dbSchemaName),
      _storage.write(key: 'stationId', value: stationId),
      _storage.write(key: 'systemRoleId', value: systemRoleId),
      _storage.write(key: 'branchName', value: branchName),
      _storage.write(key: 'expiryStatus', value: expiryStatus.toString()),
      _storage.write(key: 'expiryDate', value: expiryDate),
    ]);

    // Print all stored values to verify
    print('Token: ${await getToken()}');
    print('CompanyID: ${await getCompanyID()}');
    print('CompanyName: ${await getCompanyName()}');
    print('DbSchemaName: ${await getDbSchemaName()}');
    print('StationID: ${await getStationID()}');
    print('SystemRoleID: ${await getSystemRoleID()}');
    print('BranchName: ${await getBranchName()}');
    print('ExpiryStatus: ${await getExpiryStatus()}');
    print('ExpiryDate: ${await getExpiryDate()}');

    print('All login-related data saved successfully.');
  }

  // Removed branch-saving methods

  // Retrieve individual values as before
  static Future<String?> getToken() async => await _storage.read(key: 'token');
  static Future<String?> getCompanyID() async =>
      await _storage.read(key: 'companyId');
  static Future<String?> getCompanyName() async =>
      await _storage.read(key: 'companyName');
  static Future<String?> getDbSchemaName() async =>
      await _storage.read(key: 'dbSchemaName');
  static Future<String?> getStationID() async =>
      await _storage.read(key: 'stationId');
  static Future<String?> getSystemRoleID() async =>
      await _storage.read(key: 'systemRoleId');
  static Future<String?> getBranchName() async =>
      await _storage.read(key: 'branchName');
  static Future<int?> getExpiryStatus() async {
    final expiryStatus = await _storage.read(key: 'expiryStatus');
    return expiryStatus != null ? int.tryParse(expiryStatus) : null;
  }

  static Future<String?> getExpiryDate() async =>
      await _storage.read(key: 'expiryDate');

  // Removed branch retrieval methods

  // Clear all saved data
  static Future<void> clearAll() async {
    await _storage.deleteAll();
    print('All tokens and data cleared');
  }
}
