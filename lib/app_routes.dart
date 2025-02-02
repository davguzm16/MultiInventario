import 'package:flutter/material.dart';
import 'package:multiinventario/pages/login/all_login_pages.dart';
import 'package:multiinventario/pages/home_page.dart';
import 'package:multiinventario/pages/inventory/all_inventory_pages.dart';
import 'package:multiinventario/pages/sales/all_sales_pages.dart';

class AppRoutes {
  static const String login = '/login';
  static const String loginInputEmail = '/login/input-email';
  static const String loginCodeEmail = '/login/code-email';
  static const String loginCreatePin = '/login/create-pin';
  static const String home = '/home';
  static const String inventory = '/inventory';
  static const String inventoryProduct = '/inventory/product';
  static const String inventoryCreateProduct = "/inventory/create-product";
  static const String inventoryFilterProduct = "/inventory/filter-product";
  static const String sales = '/sales';
  static const String reports = '/reports';

  static Map<String, WidgetBuilder> routes = {
    login: (context) => LoginPage(),
    loginInputEmail: (context) => InputEmailPage(),
    loginCodeEmail: (context) => CodeEmailPage(),
    loginCreatePin: (context) => CreatePinPage(),
    home: (context) => HomePage(),
    inventory: (context) => InventoryPage(),
    inventoryProduct: (context) => ProductPage(),
    inventoryCreateProduct: (context) => CreateProductPage(),
    inventoryFilterProduct: (context) => FilterProductPage(),
    sales: (context) => SalesPage(),
    //reports: (context) => ReportsPage(),
  };
}
