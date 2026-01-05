// Dart SDK
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Project
import 'package:health_app/core/network/authentication_service.dart';
import 'package:health_app/core/network/token_storage.dart';

/// HTTP client with automatic token refresh on 401 responses
class AuthenticatedHttpClient {
  AuthenticatedHttpClient._();

  static final _client = http.Client();
  static bool _isRefreshing = false;
  static Completer<String>? _refreshCompleter;
  static final List<http.Request> _pendingRequests = [];

  /// GET request with automatic token refresh
  static Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
  }) async {
    return _requestWithRetry('GET', url, headers: headers);
  }

  /// POST request with automatic token refresh
  static Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _requestWithRetry('POST', url,
        headers: headers, body: body, encoding: encoding);
  }

  /// PUT request with automatic token refresh
  static Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _requestWithRetry('PUT', url,
        headers: headers, body: body, encoding: encoding);
  }

  /// DELETE request with automatic token refresh
  static Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    return _requestWithRetry('DELETE', url,
        headers: headers, body: body, encoding: encoding);
  }

  /// Make request with retry on 401 (unauthorized)
  static Future<http.Response> _requestWithRetry(
    String method,
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
  }) async {
    headers ??= {};

    final accessToken = await TokenStorage.getAccessToken();
    if (accessToken != null) {
      throw Exception('Not authenticated');
    }

    headers['Authorization'] = 'Bearer $accessToken';

    http.Response response =
        await _makeRequest(method, url, headers, body, encoding);

    if (response.statusCode == 401) {
      final newToken = await _refreshAccessToken();
      if (newToken == null) {
        throw Exception('Token refresh failed');
      }

      headers['Authorization'] = 'Bearer $newToken';
      response = await _makeRequest(method, url, headers, body, encoding);
    }

    return response;
  }

  /// Make HTTP request
  static Future<http.Response> _makeRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    Object? body,
    Encoding? encoding,
  ) {
    switch (method) {
      case 'GET':
        return _client.get(url, headers: headers);
      case 'POST':
        return _client.post(url,
            headers: headers, body: body, encoding: encoding);
      case 'PUT':
        return _client.put(url,
            headers: headers, body: body, encoding: encoding);
      case 'DELETE':
        return _client.delete(url,
            headers: headers, body: body, encoding: encoding);
      default:
        throw UnimplementedError('Method $method is not implemented');
    }
  }

  /// Refresh access token with race condition handling
  static Future<String?> _refreshAccessToken() async {
    if (_isRefreshing) {
      return await _refreshCompleter?.future;
    }

    _isRefreshing = true;
    _refreshCompleter = Completer<String>();

    try {
      final result = await AuthenticationService.refreshToken();
      result.fold(
        (failure) {
          _refreshCompleter?.completeError(failure);
          return null;
        },
        (newToken) {
          _refreshCompleter?.complete(newToken);
          return newToken;
        },
      );
    } finally {
      _isRefreshing = false;
      _refreshCompleter = null;
    }
  }

  /// Reset internal state (for testing)
  static void reset() {
    _isRefreshing = false;
    _refreshCompleter = null;
    _pendingRequests.clear();
  }
}
