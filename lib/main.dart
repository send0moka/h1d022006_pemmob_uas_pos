import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/auth/login_view.dart';
import 'views/dashboard/dashboard_view.dart';
import 'views/cashier/cashier_view.dart';
import 'controllers/auth_controller.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'POS System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginView(),
          middlewares: [
            RouteGuard(),
          ],
        ),
        GetPage(
          name: '/dashboard',
          page: () => DashboardView(),
          middlewares: [
            AuthMiddleware(),
          ],
        ),
        GetPage(
          name: '/cashier',
          page: () => CashierView(),
          middlewares: [
            AuthMiddleware(),
          ],
        ),
      ],
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    );
  }
}

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return !Get.find<AuthController>().isLoggedIn
        ? const RouteSettings(name: '/login')
        : null;
  }
}

class RouteGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    return Get.find<AuthController>().isLoggedIn
        ? const RouteSettings(name: '/dashboard')
        : null;
  }
}
