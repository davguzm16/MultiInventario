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
import 'package:multiinventario/pages/config_page.dart';

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
                      final categoriasSeleccionadas = (extra['categoriasSeleccionadas'] as List)
                          .map((map) => Categoria(
                        idCategoria: map['idCategoria'],
                        nombreCategoria: map['nombreCategoria'],
                      ))
                          .toList();
                      final stockBajo = extra['stockBajo'] as bool?;

                      return FilterProductPage(
                        categoriasSeleccionadas: categoriasSeleccionadas,
                        isStockBajo: stockBajo,
                      );
                    },
                  ),
                  GoRoute(
                    path: 'product/:idProducto',
                    builder: (context, state) {
                      final idProducto = int.parse(state.pathParameters['idProducto']!);
                      return ProductPage(idProducto: idProducto);
                    },
                  ),
                  GoRoute(
                    path: 'rendimiento-test', // Agregamos esta ruta aquí
                    builder: (context, state) => const RendimientoTestPage(),
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
                        path: '/payment-page',
                        builder: (context, state) {
                          final List<dynamic> extraList =
                              state.extra as List<dynamic>;

                          final detallesVenta = extraList
                              .map((map) => DetalleVenta(
                                    idProducto: map['idProducto'],
                                    idLote: map['idLote'],
                                    idVenta: map['idVenta'],
                                    cantidadProducto: map['cantidadProducto'],
                                    precioUnidadProducto:
                                        map['precioUnidadProducto'],
                                    subtotalProducto: map['subtotalProducto'],
                                    gananciaProducto: map['gananciaProducto'],
                                    descuentoProducto: map['descuentoProducto'],
                                  ))
                              .toList();

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
                builder: (context, state) => const ClientsPage(),
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
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/config',
              builder: (context, state) => const ConfigPage(),
            ),
          ])
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
