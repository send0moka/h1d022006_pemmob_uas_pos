import 'package:get/get.dart';
import 'package:h1d022006_pemmob_uas_pos/models/user.dart';
import 'package:h1d022006_pemmob_uas_pos/utils/api.dart';

class AuthController extends GetxController {
  final ApiService _apiService = ApiService();
  final _isLoggedIn = false.obs;
  final _user = Rxn<User>();

  bool get isLoggedIn => _isLoggedIn.value;
  User? get user => _user.value;

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.login(username, password);
      if (response['status'] == 'success') {
        _user.value = User.fromJson(response['data']);
        _isLoggedIn.value = true;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void logout() {
    _isLoggedIn.value = false;
    _user.value = null;
    Get.offAllNamed('/login');
  }
}
