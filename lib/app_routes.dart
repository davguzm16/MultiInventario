import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:multiinventario/controllers/image_picker.dart';
import 'package:multiinventario/models/categoria.dart';
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/pages/inventory/all_inventory_pages.dart';
import 'package:multiinventario/pages/login/all_login_pages.dart';
import 'package:multiinventario/pages/home_page.dart';
import 'package:multiinventario/pages/reports/reports_page.dart';
import 'package:multiinventario/pages/sales/create_sale_page.dart';
import 'package:multiinventario/pages/sales/debtors_page.dart';
import 'package:multiinventario/pages/sales/details_sale_page.dart';
import 'package:multiinventario/pages/sales/payment_page.dart';
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
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              return CodeEmailPage(
                correctCode: extra['codigo'] as String,
                emailUser: extra['email'] as String,
              );
            },
          ),
          GoRoute(
            path: 'create-pin',
            builder: (context, state) {
              final extra = state.extra as bool;
              return CreatePinPage(isRecovery: extra);
            },
          ),
          GoRoute(
              path: 'recover-pin',
              builder: (context, state) => RecoverPinPage())
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
                  GoRoute(
                    path: 'filter-products',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (context, state) {
                      final extra = state.extra as Map<String, dynamic>;
                      final categoriasSeleccionadas =
                          extra['categoriasSeleccionadas'] as List<Categoria>;
                      final isStockBajo = extra['isStockBajo'] as bool;

                      return FilterProductPage(
                        categoriasSeleccionadas: categoriasSeleccionadas,
                        isStockBajo: isStockBajo,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'product/:idProducto',
                    builder: (context, state) {
                      final idProducto =
                          int.parse(state.pathParameters['idProducto']!);
                      return ProductPage(idProducto: idProducto);
                    },
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
                routes: [
                  GoRoute(
                    path: 'create-sale',
                    builder: (context, state) => const CreateSalePage(),
                    routes: [
                      GoRoute(
                        path: 'payment-page',
                        builder: (context, state) {
                          final detallesVenta =
                              state.extra as List<DetalleVenta>;
                          return PaymentPage(detallesVenta: detallesVenta);
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'debtors',
                    builder: (context, state) => const DebtorsPage(),
                  ),
                  GoRoute(
                    path: 'details-sale',
                    builder: (context, state) => const DetailsSalePage(),
                  ),
                ],
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
      GoRoute(
        path: '/image-picker',
        builder: (context, state) => ImagePickerHelper(),
      ),
    ],
  );
}
