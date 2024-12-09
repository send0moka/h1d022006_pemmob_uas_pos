import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost/h1d022006_pemmob_uas_pos/api';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2/h1d022006_pemmob_uas_pos/api';
    }
    return 'http://localhost/h1d022006_pemmob_uas_pos/api';
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login.php'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'username': username, 'password': password}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/products/read.php'));
    final data = jsonDecode(response.body);
    return data['data'];
  }

  Future<Map<String, dynamic>> createProduct(String name, double price) async {
    final response = await http.post(
      Uri.parse('$baseUrl/products/create.php'),
      body: jsonEncode({'name': name, 'price': price}),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateProduct(
    int id,
    String name,
    double price,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/products/update.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'name': name, 'price': price}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> deleteProduct(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/products/delete.php'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> createTransaction(
    int userId,
    double totalAmount,
    List<Map<String, dynamic>> items,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/transactions/create.php'),
      body: jsonEncode({
        'user_id': userId,
        'total_amount': totalAmount,
        'items': items,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getTransactions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/transactions/read.php'),
    );
    final data = jsonDecode(response.body);
    return data['data'];
  }

  Future<Map<String, dynamic>> getDashboardData() async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/summary.php'),
    );
    return jsonDecode(response.body);
  }
}
