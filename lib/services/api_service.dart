import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../models/order.dart';
import '../models/user.dart';
import 'config.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiService {
  // Use config or platform-specific URL
  static String get baseUrl {
    if (kIsWeb) return AppConfig.apiBaseUrl;
    try {
      if (Platform.isAndroid) {
        return AppConfig.apiBaseUrl.replaceAll('localhost', '10.0.2.2').replaceAll('127.0.0.1', '10.0.2.2');
      }
    } catch (_) {}
    return AppConfig.apiBaseUrl;
  }

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  // ==================== AUTH ====================

  /// Check if username is taken
  Future<bool> isUsernameTaken(String username) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/users/check/$username'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['taken'] ?? false;
      }
      return false;
    } catch (e) {
      debugPrint('Error checking username: $e');
      throw ApiException('Failed to check username: $e');
    }
  }

  /// Register user
  Future<bool> registerUser(User user) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(user.toMap()),
      );
      
      if (response.statusCode == 201) {
        return true;
      }
      
      debugPrint('Registration failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error registering user: $e');
      throw ApiException('Failed to register user: $e');
    }
  }

  /// Login user
  Future<User?> loginUser(String username, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );
      
      if (response.statusCode == 200) {
        return User.fromMap(json.decode(response.body));
      }
      
      debugPrint('Login failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Error logging in: $e');
      throw ApiException('Failed to login: $e');
    }
  }

  // ==================== PRODUCTS ====================

  /// Fetch all products
  Future<List<Product>> getProducts() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/products'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Product.fromMap(e)).toList();
      } else if (response.statusCode == 404) {
        return [];
      }
      throw ApiException('Failed to load products', statusCode: response.statusCode);
    } catch (e) {
      debugPrint('Error fetching products: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Error fetching products: $e');
    }
  }

  /// Fetch product by ID
  Future<Product?> getProduct(String id) async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/products/$id'));
      if (response.statusCode == 200) {
        return Product.fromMap(json.decode(response.body));
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching product: $e');
      throw ApiException('Error fetching product: $e');
    }
  }

  /// Create new product
  Future<bool> createProduct(Product product) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/products'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toMap()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error creating product: $e');
      throw ApiException('Error creating product: $e');
    }
  }

  /// Update product
  Future<bool> updateProduct(Product product) async {
    try {
      final response = await _client.put(
        Uri.parse('$baseUrl/products/${product.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(product.toMap()),
      );
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Error updating product: $e');
      throw ApiException('Error updating product: $e');
    }
  }

  /// Delete product
  Future<bool> deleteProduct(String id) async {
    try {
      final response = await _client.delete(Uri.parse('$baseUrl/products/$id'));
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      throw ApiException('Error deleting product: $e');
    }
  }

  // ==================== ORDERS ====================

  /// Fetch all orders
  Future<List<Order>> getOrders() async {
    try {
      final response = await _client.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Order.fromMap(e)).toList();
      } else if (response.statusCode == 404) {
        return [];
      }
      throw ApiException('Failed to load orders', statusCode: response.statusCode);
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Error fetching orders: $e');
    }
  }

  /// Create new order
  Future<bool> createOrder(Order order) async {
    try {
      final response = await _client.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(order.toMap()),
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      debugPrint('Error creating order: $e');
      throw ApiException('Error creating order: $e');
    }
  }

  /// Close connection
  void dispose() {
    _client.close();
  }
}
