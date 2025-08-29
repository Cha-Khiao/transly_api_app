import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:transly_api_app/services/storage_service.dart';
import 'package:transly_api_app/utils/api.dart';

class ApiService {
  static final String _baseUrl = BASE_URL;

  static Future<Map<String, String>> get headers async {
    try {
      final storageService = Get.find<StorageService>();

      final token = storageService.getToken();

      final headers = <String, String>{'Content-Type': 'application/json'};

      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        if (kDebugMode) {
          print('Authorization header added with token');
        }
      } else {
        if (kDebugMode) {
          print('No token available, skipping Authorization header');
        }
      }

      if (kDebugMode) {
        print('Request headers: $headers');
      }

      return headers;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting headers: $e');
      }
      return {'Content-Type': 'application/json'};
    }
  }

  // GET request
  static Future<dynamic> get(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = await headers;

      if (kDebugMode) {
        print('GET Request: $url');
        print('Headers: $requestHeaders');
      }

      final response = await http.get(url, headers: requestHeaders);

      if (kDebugMode) {
        print('GET Response status: ${response.statusCode}');
        print('GET Response body: ${response.body}');
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('Unauthorized access - token may be invalid or expired');
        }
        throw Exception('Unauthorized - Please login again');
      } else {
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        if (kDebugMode) {
          print('GET request failed: $errorMessage');
        }
        throw Exception(
          'Failed to load data: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('GET request error: $e');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = await headers;
      final requestBody = jsonEncode(data);

      if (kDebugMode) {
        print('POST Request: $url');
        print('Headers: $requestHeaders');
        print('Body: $requestBody');
      }

      final response = await http.post(
        url,
        headers: requestHeaders,
        body: requestBody,
      );

      if (kDebugMode) {
        print('POST Response status: ${response.statusCode}');
        print('POST Response body: ${response.body}');
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseBody;
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('Unauthorized access - token may be invalid or expired');
        }
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 409) {
        final errorMessage = responseBody['message'] ?? 'Conflict occurred';
        if (kDebugMode) {
          print('Conflict error: $errorMessage');
        }
        throw Exception('Conflict - $errorMessage');
      } else {
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        if (kDebugMode) {
          print('POST request failed: $errorMessage');
        }
        throw Exception(
          'Failed to create data: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('POST request error: $e');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // PUT request
  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = await headers;
      final requestBody = jsonEncode(data);

      if (kDebugMode) {
        print('PUT Request: $url');
        print('Headers: $requestHeaders');
        print('Body: $requestBody');
      }

      final response = await http.put(
        url,
        headers: requestHeaders,
        body: requestBody,
      );

      if (kDebugMode) {
        print('PUT Response status: ${response.statusCode}');
        print('PUT Response body: ${response.body}');
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('Unauthorized access - token may be invalid or expired');
        }
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        final errorMessage = responseBody['message'] ?? 'Resource not found';
        if (kDebugMode) {
          print('Not found error: $errorMessage');
        }
        throw Exception('Not Found - $errorMessage');
      } else {
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        if (kDebugMode) {
          print('PUT request failed: $errorMessage');
        }
        throw Exception(
          'Failed to update data: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('PUT request error: $e');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // DELETE request
  static Future<dynamic> delete(String endpoint) async {
    try {
      final url = Uri.parse('$_baseUrl$endpoint');
      final requestHeaders = await headers;

      if (kDebugMode) {
        print('DELETE Request: $url');
        print('Headers: $requestHeaders');
      }

      final response = await http.delete(url, headers: requestHeaders);

      if (kDebugMode) {
        print('DELETE Response status: ${response.statusCode}');
        print('DELETE Response body: ${response.body}');
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else if (response.statusCode == 401) {
        if (kDebugMode) {
          print('Unauthorized access - token may be invalid or expired');
        }
        throw Exception('Unauthorized - Please login again');
      } else if (response.statusCode == 404) {
        final errorMessage = responseBody['message'] ?? 'Resource not found';
        if (kDebugMode) {
          print('Not found error: $errorMessage');
        }
        throw Exception('Not Found - $errorMessage');
      } else {
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        if (kDebugMode) {
          print('DELETE request failed: $errorMessage');
        }
        throw Exception(
          'Failed to delete data: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('DELETE request error: $e');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  // Auth specific methods (no token required)
  static Future<Map<String, dynamic>> login(
    String name,
    String password,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl$LOGIN_ENDPOINT');
      final requestBody = jsonEncode({'name': name, 'password': password});

      if (kDebugMode) {
        print('Login Request: $url');
        print('Body: $requestBody');
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (kDebugMode) {
        print('Login Response status: ${response.statusCode}');
        print('Login Response body: ${response.body}');
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseBody;
      } else {
        final errorMessage = responseBody['message'] ?? 'Login failed';
        if (kDebugMode) {
          print('Login failed: $errorMessage');
        }
        throw Exception('Login failed: ${response.statusCode} - $errorMessage');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Login error: $e');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl$REGISTER_ENDPOINT');
      final requestBody = jsonEncode({
        'name': name,
        'password': password,
        'first_name': firstName,
        'last_name': lastName,
      });

      if (kDebugMode) {
        print('Register Request: $url');
        print('Body: $requestBody');
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: requestBody,
      );

      if (kDebugMode) {
        print('Register Response status: ${response.statusCode}');
        print('Register Response body: ${response.body}');
      }

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return responseBody;
      } else {
        final errorMessage = responseBody['message'] ?? 'Registration failed';
        if (kDebugMode) {
          print('Registration failed: $errorMessage');
        }
        throw Exception(
          'Registration failed: ${response.statusCode} - $errorMessage',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Registration error: $e');
      }
      throw Exception('Network error: ${e.toString()}');
    }
  }
}
