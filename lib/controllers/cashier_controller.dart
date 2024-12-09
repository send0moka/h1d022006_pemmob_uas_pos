import 'package:get/get.dart';
import 'package:h1d022006_pemmob_uas_pos/controllers/auth_controller.dart';
import 'package:h1d022006_pemmob_uas_pos/models/product.dart';
import 'package:h1d022006_pemmob_uas_pos/utils/api.dart';
import 'package:h1d022006_pemmob_uas_pos/widgets/payment_dialog.dart';

class CashierController extends GetxController {
  final ApiService _apiService = ApiService();
  final _products = <Product>[].obs;
  final _cartItems = <Product, int>{}.obs;
  final _isLoading = RxBool(false);
  final _error = RxString('');

  bool get isLoading => _isLoading.value;
  String get error => _error.value;
  List<Product> get products => _products;
  Map<Product, int> get cartItems => _cartItems;
  bool get isCartEmpty => _cartItems.isEmpty;

  double get total => _cartItems.entries.fold(
    0,
    (sum, item) => sum + (item.key.price * item.value),
  );

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    try {
      _isLoading.value = true;
      _error.value = '';
      final productsData = await _apiService.getProducts();
      _products.value = productsData.map((p) => Product.fromJson(p)).toList();
    } catch (e) {
      _error.value = 'Failed to load products: $e';
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> createProduct(String name, double price) async {
    try {
      _isLoading.value = true;
      await _apiService.createProduct(name, price);
      await loadProducts();
      Get.back();
      Get.snackbar('Success', 'Product added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> addProduct(String name, double price) async {
    try {
      _isLoading.value = true;
      final response = await _apiService.createProduct(name, price);
      if (response['status'] == 'success') {
        await loadProducts();
        Get.snackbar('Success', 'Product added successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to add product: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> updateProduct(int id, String name, double price) async {
    try {
      _isLoading.value = true;
      final response = await _apiService.updateProduct(id, name, price);
      if (response['status'] == 'success') {
        final updatedProduct = Product(id: id, name: name, price: price);
        final cartEntries = _cartItems.entries.toList();

        for (var entry in cartEntries) {
          if (entry.key.id == id) {
            _cartItems.remove(entry.key);
            _cartItems[updatedProduct] = entry.value;
          }
        }

        await loadProducts();
        Get.snackbar(
          'Success',
          'Product updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      _isLoading.value = true;
      _cartItems.removeWhere((product, quantity) => product.id == id);
      final response = await _apiService.deleteProduct(id);
      if (response['status'] == 'success') {
        await loadProducts();
        Get.snackbar(
          'Success',
          'Product deleted successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete product: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      _isLoading.value = false;
    }
  }

  void addToCart(Product product) {
    if (_cartItems.containsKey(product)) {
      _cartItems[product] = _cartItems[product]! + 1;
    } else {
      _cartItems[product] = 1;
    }
    Get.snackbar(
      'Added to Cart',
      '${product.name} (${_cartItems[product]})',
      duration: const Duration(seconds: 1),
    );
  }

  void removeFromCart(Product product) {
    if (_cartItems.containsKey(product)) {
      if (_cartItems[product] == 1) {
        _cartItems.remove(product);
      } else {
        _cartItems[product] = _cartItems[product]! - 1;
      }
    }
  }

  Future<void> checkout() async {
    if (_cartItems.isEmpty) {
      Get.snackbar('Error', 'Cart is empty');
      return;
    }

    try {
      await Get.dialog<bool>(
        PaymentDialog(
          totalAmount: total,
          controller: this,
          onConfirm: (paymentAmount) => _processPayment(paymentAmount),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Payment process cancelled');
    }
  }

  Future<void> _processPayment(double paymentAmount) async {
    try {
      _isLoading.value = true;
      final items = _cartItems.entries.map((e) => {
        'product_id': e.key.id,
        'quantity': e.value,
        'price': e.key.price,
      }).toList();

      final response = await _apiService.createTransaction(
        Get.find<AuthController>().user!.id,
        total,
        items,
      );

      if (response['status'] == 'success') {
        double change = paymentAmount - total;
        _cartItems.clear();
        
        Get.snackbar(
          'Success',
          'Transaction completed successfully\n${change > 0 ? 'Change: ${formatPrice(change)}' : 'Exact amount paid'}',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to complete transaction: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  String formatPrice(double price) {
    if (price == price.roundToDouble()) {
      final priceInt = price.toInt();
      return 'Rp ${priceInt.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    } else {
      return 'Rp ${price.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
    }
  }
}
