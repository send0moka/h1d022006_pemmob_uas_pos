import 'dart:async';

import 'package:get/get.dart';
import '../utils/api.dart';

class DashboardController extends GetxController {
  final ApiService _apiService = ApiService();
  final _isLoading = false.obs;
  final _todaySales = 0.0.obs;
  final _totalTransactions = 0.obs;
  final _salesData = <Map<String, dynamic>>[].obs;
  final _error = RxString('');

  bool get isLoading => _isLoading.value;
  double get todaySales => _todaySales.value;
  int get totalTransactions => _totalTransactions.value;
  List<Map<String, dynamic>> get salesData => _salesData;
  String get error => _error.value;

  static const Duration timeoutDuration = Duration(seconds: 10);

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      
      final response = await _apiService.getDashboardData()
          .timeout(timeoutDuration, onTimeout: () {
        throw TimeoutException('Loading timeout');
      });
      
      if (response['status'] == 'success') {
        _todaySales.value = double.tryParse(response['today_sales'].toString()) ?? 0.0;
        _totalTransactions.value = int.tryParse(response['total_transactions'].toString()) ?? 0;
        
        final salesDataList = List<Map<String, dynamic>>.from(response['sales_data'] ?? []);
        _salesData.assignAll(salesDataList.map((data) => {
          'date': data['date'],
          'amount': double.tryParse(data['amount'].toString()) ?? 0.0,
        }));
      } else {
        _error.value = 'Failed to load data';
      }
    } catch (e) {
      _error.value = 'Failed to load dashboard data';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> retryLoading() async {
    await loadDashboardData();
  }

  String formatCurrency(double amount) {
    if (amount == amount.roundToDouble()) {
      final amountInt = amount.toInt();
      return 'Rp ${amountInt.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}.',
      )}';
    }
    return 'Rp ${amount.toStringAsFixed(2)}';
  }
}