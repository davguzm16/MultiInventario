import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/pages/inventory/create_product_page.dart';
import 'package:multiinventario/pages/login/all_login_pages.dart';
import 'package:multiinventario/pages/home_page.dart';
import 'package:multiinventario/pages/inventory/inventory_page.dart';
import 'package:multiinventario/pages/reports/reports_page.dart';
import 'package:multiinventario/pages/sales/sales_page.dart';
import 'package:multiinventario/controllers/barcode_scanner.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    navigatorKey: _rootNavigatorKey,
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginPage(),
        routes: [
          GoRoute(
            path: 'input-email',
            builder: (context, state) => InputEmailPage(),
          ),
          GoRoute(
            path: 'code-email',
            builder: (context, state) =>
                CodeEmailPage(correctCode: state.extra as String),
          ),
          GoRoute(
            path: 'create-pin',
            builder: (context, state) => CreatePinPage(),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return HomePage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inventory',
                builder: (context, state) => const InventoryPage(),
                routes: [
                  GoRoute(
                    path: 'create-product',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) => const CreateProductPage(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/sales',
                builder: (context, state) => const SalesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) => const ReportsPage(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/barcode-scanner',
        builder: (context, state) => BarcodeScanner(),
      ),
    ],
  );
}
