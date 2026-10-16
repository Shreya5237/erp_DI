import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/lead.dart';
import '../models/department.dart';
import '../models/task.dart';

/// Structured exceptions for Digital Inertia API interactions
class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.message, {this.statusCode = 500});

  @override
  String toString() => 'ApiException (HTTP $statusCode): $message';
}

class NetworkException extends ApiException {
  const NetworkException(super.message) : super(statusCode: 0);
}

class AuthenticationException extends ApiException {
  const AuthenticationException(super.message) : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException(super.message) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message) : super(statusCode: 404);
}

/// DTO representing authenticated user profile from Spring Boot
class AuthUserData {
  final String id;
  final String email;
  final String fullName;
  final String role; // e.g. 'ROLE_CEO', 'ROLE_POC', 'ROLE_SALES'
  final String? employeeId;

  const AuthUserData({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.employeeId,
  });

  factory AuthUserData.fromJson(Map<String, dynamic> json) {
    return AuthUserData(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      role: json['role'] as String? ?? 'ROLE_EMPLOYEE',
      employeeId: json['employeeId'] as String?,
    );
  }
}

/// DTO representing login response from POST /api/v1/auth/login
class LoginResult {
  final String token;
  final String tokenType;
  final int expiresInMs;
  final AuthUserData user;

  const LoginResult({
    required this.token,
    this.tokenType = 'Bearer',
    required this.expiresInMs,
    required this.user,
  });

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'] as Map<String, dynamic>? ?? {};
    return LoginResult(
      token: json['token'] as String? ?? '',
      tokenType: json['tokenType'] as String? ?? 'Bearer',
      expiresInMs: (json['expiresInMs'] as num?)?.toInt() ?? 86400000,
      user: AuthUserData.fromJson(userJson),
    );
  }
}

/// Client service managing REST API communication with Spring Boot backend
class ApiService {
  // Custom server host configured by user (e.g. for testing from physical phone via LAN IP)
  static String? customBaseUrlOverride;

  // Dynamic default host: custom override, 10.0.2.2 on Android emulator, localhost on Desktop/Web
  static String get defaultBaseUrl {
    if (customBaseUrlOverride != null && customBaseUrlOverride!.isNotEmpty) {
      return customBaseUrlOverride!;
    }
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8080/api/v1';
    }
    return 'http://localhost:8080/api/v1';
  }

  String _baseUrl;
  final http.Client _client;
  final Duration timeout;

  // In-memory token storage (never logged)
  String? _token;

  ApiService({
    String? baseUrl,
    http.Client? client,
    this.timeout = const Duration(seconds: 10),
  })  : _baseUrl = (baseUrl ?? defaultBaseUrl).endsWith('/')
            ? (baseUrl ?? defaultBaseUrl).substring(0, (baseUrl ?? defaultBaseUrl).length - 1)
            : (baseUrl ?? defaultBaseUrl),
        _client = client ?? http.Client();

  String get baseUrl => _baseUrl;
  String? get token => _token;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  void updateBaseUrl(String newUrl) {
    String clean = newUrl.trim();
    if (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    _baseUrl = clean;
    customBaseUrlOverride = clean;
  }

  void setToken(String? token) {
    _token = token;
  }

  void clearSession() {
    _token = null;
  }

  Map<String, String> _buildHeaders({bool requireAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (requireAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  /// Authenticate against POST /api/v1/auth/login
  Future<LoginResult> login(String email, String password) async {
    final uri = Uri.parse('$_baseUrl/auth/login');
    final body = jsonEncode({
      'email': email.trim(),
      'password': password,
    });

    try {
      final response = await _client
          .post(uri, headers: _buildHeaders(requireAuth: false), body: body)
          .timeout(timeout);

      final Map<String, dynamic> jsonBody = _decodeResponseBody(response);

      if (response.statusCode == 200) {
        final data = jsonBody['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw const ApiException('Invalid login response: missing data object');
        }
        final result = LoginResult.fromJson(data);
        _token = result.token;
        return result;
      } else if (response.statusCode == 401) {
        final msg = jsonBody['message'] as String? ?? 'Invalid credentials';
        throw AuthenticationException(msg);
      } else if (response.statusCode == 400) {
        final msg = jsonBody['message'] as String? ?? 'Validation error';
        throw ApiException(msg, statusCode: 400);
      } else {
        final msg = jsonBody['message'] as String? ?? 'Authentication failed';
        throw ApiException(msg, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException(
        'Unable to connect to backend at $_baseUrl. Ensure Spring Boot is running.\nDetails: ${e.message}',
      );
    } on TimeoutException {
      throw const NetworkException('Connection to backend timed out after 10s.');
    } on http.ClientException catch (e) {
      throw NetworkException('Network client error: ${e.message}');
    }
  }

  /// Fetch currently authenticated user profile from GET /api/v1/auth/me
  Future<AuthUserData> getCurrentUser() async {
    final uri = Uri.parse('$_baseUrl/auth/me');
    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(requireAuth: true))
          .timeout(timeout);

      final Map<String, dynamic> jsonBody = _decodeResponseBody(response);

      if (response.statusCode == 200) {
        final data = jsonBody['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw const ApiException('Invalid user profile response');
        }
        return AuthUserData.fromJson(data);
      } else if (response.statusCode == 401) {
        throw const AuthenticationException('Session expired. Please log in again.');
      } else {
        final msg = jsonBody['message'] as String? ?? 'Failed to retrieve user profile';
        throw ApiException(msg, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException('Network error connecting to $_baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException('Connection timed out.');
    }
  }

  /// Fetch all active leads from GET /api/v1/leads
  Future<List<Lead>> getLeads({String? stage, String? ownerId}) async {
    final queryParams = <String, String>{};
    if (stage != null) queryParams['stage'] = stage;
    if (ownerId != null) queryParams['ownerId'] = ownerId;

    final baseUri = Uri.parse('$_baseUrl/leads');
    final uri = queryParams.isEmpty ? baseUri : baseUri.replace(queryParameters: queryParams);

    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(requireAuth: true))
          .timeout(timeout);

      final Map<String, dynamic> jsonBody = _decodeResponseBody(response);

      if (response.statusCode == 200) {
        final data = jsonBody['data'] as List<dynamic>? ?? [];
        return data.map((item) => Lead.fromBackendJson(item as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw const AuthenticationException('Session expired. Please log in again.');
      } else if (response.statusCode == 403) {
        throw const ForbiddenException('You do not have permission to view leads.');
      } else {
        final msg = jsonBody['message'] as String? ?? 'Failed to retrieve leads';
        throw ApiException(msg, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException('Network error connecting to $_baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException('Connection timed out while fetching leads.');
    }
  }

  /// Update lead stage via PATCH /api/v1/leads/{id}/stage?stage={stage}
  Future<Lead> updateLeadStage(String id, String newStage) async {
    final uri = Uri.parse('$_baseUrl/leads/$id/stage').replace(
      queryParameters: {'stage': newStage},
    );

    try {
      final response = await _client
          .patch(uri, headers: _buildHeaders(requireAuth: true))
          .timeout(timeout);

      final Map<String, dynamic> jsonBody = _decodeResponseBody(response);

      if (response.statusCode == 200) {
        final data = jsonBody['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw const ApiException('Invalid lead update response');
        }
        return Lead.fromBackendJson(data);
      } else if (response.statusCode == 401) {
        throw const AuthenticationException('Session expired. Please log in again.');
      } else if (response.statusCode == 403) {
        throw const ForbiddenException(
          'Permission denied: Only CEO or POC roles can update lead stages on the server.',
        );
      } else if (response.statusCode == 404) {
        throw NotFoundException('Lead with ID $id not found.');
      } else {
        final msg = jsonBody['message'] as String? ?? 'Failed to update lead stage';
        throw ApiException(msg, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException('Network error connecting to $_baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException('Connection timed out while updating lead stage.');
    }
  }

  /// Fetch full department hierarchy (roots with nested subcategories) from GET /api/v1/departments
  Future<List<DepartmentItem>> getDepartments() async {
    final uri = Uri.parse('$_baseUrl/departments');
    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(requireAuth: false))
          .timeout(timeout);

      final Map<String, dynamic> jsonBody = _decodeResponseBody(response);

      if (response.statusCode == 200) {
        final data = jsonBody['data'] as List<dynamic>? ?? [];
        return data.map((item) => DepartmentItem.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        final msg = jsonBody['message'] as String? ?? 'Failed to retrieve departments';
        throw ApiException(msg, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException('Network error connecting to $_baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException('Connection timed out while fetching departments.');
    }
  }

  /// Fetch only top-level root departments from GET /api/v1/departments/roots
  Future<List<DepartmentItem>> getRootDepartments() async {
    final uri = Uri.parse('$_baseUrl/departments/roots');
    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(requireAuth: false))
          .timeout(timeout);

      final Map<String, dynamic> jsonBody = _decodeResponseBody(response);

      if (response.statusCode == 200) {
        final data = jsonBody['data'] as List<dynamic>? ?? [];
        return data.map((item) => DepartmentItem.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        final msg = jsonBody['message'] as String? ?? 'Failed to retrieve root departments';
        throw ApiException(msg, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException('Network error connecting to $_baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException('Connection timed out while fetching root departments.');
    }
  }

  /// Fetch subcategories for a given root department from GET /api/v1/departments/{id}/subcategories
  Future<List<DepartmentItem>> getDepartmentSubcategories(String departmentId) async {
    final uri = Uri.parse('$_baseUrl/departments/$departmentId/subcategories');
    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(requireAuth: false))
          .timeout(timeout);

      final Map<String, dynamic> jsonBody = _decodeResponseBody(response);

      if (response.statusCode == 200) {
        final data = jsonBody['data'] as List<dynamic>? ?? [];
        return data.map((item) => DepartmentItem.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        final msg = jsonBody['message'] as String? ?? 'Failed to retrieve subcategories';
        throw ApiException(msg, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException('Network error connecting to $_baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException('Connection timed out while fetching subcategories.');
    }
  }

  /// Fetch tasks from Spring Boot GET /api/v1/tasks
  Future<List<CompanyTask>> getTasks({String? assignedToId, String? status}) async {
    final queryParams = <String, String>{};
    if (assignedToId != null && assignedToId.isNotEmpty) {
      queryParams['assignedToId'] = assignedToId;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final baseUri = Uri.parse('$_baseUrl/tasks');
    final uri = queryParams.isEmpty ? baseUri : baseUri.replace(queryParameters: queryParams);

    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(requireAuth: false))
          .timeout(timeout);

      final Map<String, dynamic> jsonBody = _decodeResponseBody(response);

      if (response.statusCode == 200) {
        final data = jsonBody['data'] as List<dynamic>? ?? [];
        return data.map((item) => CompanyTask.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        final msg = jsonBody['message'] as String? ?? 'Failed to retrieve tasks';
        throw ApiException(msg, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException('Network error connecting to $_baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException('Connection timed out while fetching tasks.');
    }
  }

  /// Update task status via Spring Boot PATCH /api/v1/tasks/{id}/status?status={status}
  Future<CompanyTask> updateTaskStatus(String id, String newStatus) async {
    final uri = Uri.parse('$_baseUrl/tasks/$id/status').replace(
      queryParameters: {'status': newStatus},
    );

    try {
      final response = await _client
          .patch(uri, headers: _buildHeaders(requireAuth: true))
          .timeout(timeout);

      final Map<String, dynamic> jsonBody = _decodeResponseBody(response);

      if (response.statusCode == 200) {
        final data = jsonBody['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw const ApiException('Invalid task update response');
        }
        return CompanyTask.fromJson(data);
      } else {
        final msg = jsonBody['message'] as String? ?? 'Failed to update task status';
        throw ApiException(msg, statusCode: response.statusCode);
      }
    } on SocketException catch (e) {
      throw NetworkException('Network error connecting to $_baseUrl: ${e.message}');
    } on TimeoutException {
      throw const NetworkException('Connection timed out while updating task status.');
    }
  }

  /// Fetch active alerts from GET /api/v1/dashboard/alerts
  Future<List<Map<String, dynamic>>> getDashboardAlerts() async {
    final uri = Uri.parse('$_baseUrl/dashboard/alerts');
    try {
      final response = await _client
          .get(uri, headers: _buildHeaders(requireAuth: false))
          .timeout(timeout);

      final Map<String, dynamic> jsonBody = _decodeResponseBody(response);

      if (response.statusCode == 200) {
        final data = jsonBody['data'] as List<dynamic>? ?? [];
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  Map<String, dynamic> _decodeResponseBody(http.Response response) {
    if (response.body.isEmpty) {
      return {'success': response.statusCode >= 200 && response.statusCode < 300};
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Malformed response from server (HTTP ${response.statusCode}): ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}
