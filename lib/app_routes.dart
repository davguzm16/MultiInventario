import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Models
import 'package:multiinventario/models/detalle_venta.dart';
import 'package:multiinventario/models/categoria.dart';

// Vistas del login
import 'package:multiinventario/pages/login/all_login_pages.dart';

// Vistas del HomePage
import 'package:multiinventario/pages/home_page.dart';
import 'package:multiinventario/pages/inventory/all_inventory_pages.dart';
import 'package:multiinventario/pages/sales/all_sales_pages.dart';
import 'package:multiinventario/pages/clients/all_clients_pages.dart';
import 'package:multiinventario/pages/reports/reports_page.dart';

// Modulos auxiales
import 'package:multiinventario/controllers/barcode_scanner.dart';
import 'package:multiinventario/controllers/image_picker.dart';

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
                builder: (context, state) {
                  return const InventoryPage();
                },
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
                builder: (context, state) {
                  return const SalesPage();
                },
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
                    path: 'details-sale/:idVenta',
                    builder: (context, state) {
                      final idVenta =
                          int.parse(state.pathParameters['idVenta']!);
                      return DetailsSalePage(idVenta: idVenta);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/clients',
                builder: (context, state) {
                  return const ClientsPage();
                },
                routes: [
                  GoRoute(
                    path: 'details-client/:idCliente',
                    builder: (context, state) {
                      final idCliente =
                          int.parse(state.pathParameters['idCliente']!);
                      return DetailsClientPage(idCliente: idCliente);
                    },
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
