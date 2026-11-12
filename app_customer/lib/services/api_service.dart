import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'api_exception.dart';
import 'auth_service.dart';

class ApiService {
  final AuthService _authService = AuthService();
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> getProducts({
    String search = '',
    String kategori = '',
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}/products').replace(
      queryParameters: {
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (kategori.trim().isNotEmpty) 'kategori': kategori.trim(),
      },
    );
    final response = await _client.get(uri);
    final data = decodeApiResponse(response)['data'] as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(Product.fromJson)
        .toList(growable: false);
  }

  Future<Product> getProduct(String id) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/products/$id'),
    );
    return Product.fromJson(
      decodeApiResponse(response)['data'] as Map<String, dynamic>,
    );
  }

  Future<Order> createOrder({
    required List<Map<String, dynamic>> items,
    required String address,
    required String phone,
    String notes = '',
  }) async {
    final response = await _authorizedRequest(
      'POST',
      '/orders',
      body: {
        'items': items,
        'address': address,
        'phone': phone,
        'notes': notes,
      },
    );
    return Order.fromJson(
      decodeApiResponse(response)['data'] as Map<String, dynamic>,
    );
  }

  Future<List<Order>> getOrders() async {
    final response = await _authorizedRequest('GET', '/orders');
    final data = decodeApiResponse(response)['data'] as List<dynamic>;
    return data
        .whereType<Map<String, dynamic>>()
        .map(Order.fromJson)
        .toList(growable: false);
  }

  Future<Order> confirmOrderReceived(String orderId) async {
    final response = await _authorizedRequest(
      'PATCH',
      '/orders/$orderId/received',
    );
    return Order.fromJson(
      decodeApiResponse(response)['data'] as Map<String, dynamic>,
    );
  }

  Future<Map<String, dynamic>> getMe({required String token}) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/me'),
      headers: {'Authorization': 'Bearer $token'},
    );
    return decodeApiResponse(response)['data'] as Map<String, dynamic>;
  }

  Future<http.Response> _authorizedRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Sesi login tidak ditemukan. Silakan login kembali.');
    }
    final uri = Uri.parse('${ApiConfig.baseUrl}$path');
    final headers = {'Authorization': 'Bearer $token'};
    if (body != null) headers['Content-Type'] = 'application/json';
    if (method == 'POST') {
      return _client.post(uri, headers: headers, body: jsonEncode(body));
    }
    if (method == 'PATCH') {
      return _client.patch(uri, headers: headers, body: jsonEncode(body ?? {}));
    }
    return _client.get(uri, headers: headers);
  }
}
