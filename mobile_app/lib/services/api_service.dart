import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://172.31.99.152:5002/api';

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> _handleAuthFailure(int statusCode) async {
    if (statusCode == 401) {
      await logout();
    }
  }

  // ---------- Auth ----------

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 201) return data;
    throw ApiException(data['error'] ?? 'Registration failed');
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) {
      await _saveToken(data['token']);
      return data;
    }
    throw ApiException(data['error'] ?? 'Login failed');
  }

  // ---------- Diagnose ----------

  static Future<Map<String, dynamic>> diagnose(File imageFile) async {
    final token = await _getToken();
    if (token == null) throw ApiException('Please login first');

    final request =
        http.MultipartRequest('POST', Uri.parse('$baseUrl/diagnose'));
    request.headers['Authorization'] = 'Bearer $token';
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    await _handleAuthFailure(res.statusCode);
    final data = jsonDecode(res.body) as Map<String, dynamic>;

    if (res.statusCode == 201) return data;
    throw ApiException(data['error'] ?? 'Diagnosis failed');
  }

  // ---------- History ----------

  static Future<List<dynamic>> getHistory({DateTime? from, DateTime? to}) async {
    final token = await _getToken();
    if (token == null) throw ApiException('Please login first');

    final params = <String, String>{};
    if (from != null) params['from'] = _formatDate(from);
    if (to != null) params['to'] = _formatDate(to);

    final uri = Uri.parse('$baseUrl/history')
        .replace(queryParameters: params.isEmpty ? null : params);
    final res =
        await http.get(uri, headers: {'Authorization': 'Bearer $token'});
    await _handleAuthFailure(res.statusCode);

    if (res.statusCode == 200) return jsonDecode(res.body) as List<dynamic>;
    if (res.statusCode == 401) {
      throw ApiException('Your session has expired. Please login again.');
    }
    throw ApiException('Failed to load history');
  }

  static String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ---------- Treatment ----------

  static Future<Map<String, dynamic>> getTreatment(
      String diseaseType, String stage) async {
    final token = await _getToken();
    if (token == null) throw ApiException('Please login first');

    final res = await http.get(
      Uri.parse('$baseUrl/treatment/$diseaseType/$stage'),
      headers: {'Authorization': 'Bearer $token'},
    );
    await _handleAuthFailure(res.statusCode);
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    if (res.statusCode == 200) return data;
    throw ApiException(data['error'] ?? 'No treatment guideline found');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}