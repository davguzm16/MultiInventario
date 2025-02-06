import 'package:go_router/go_router.dart';
import 'package:multiinventario/pages/login/all_login_pages.dart';
import 'package:multiinventario/pages/home_page.dart';
import 'package:multiinventario/pages/inventory/all_inventory_pages.dart';
import 'package:multiinventario/pages/sales/all_sales_pages.dart';
import 'package:multiinventario/controllers/barcode_scanner.dart';

class AppRoutes {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    routes: <RouteBase>[
      // Rutas de login
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
              final correctCode = state.extra as String;
              return CodeEmailPage(correctCode: correctCode);
            },
          ),
          GoRoute(
            path: 'create-pin',
            builder: (context, state) => CreatePinPage(),
          ),
        ],
      ),

      // Contenedor "Home" con ShellRoute
      ShellRoute(
        builder: (context, state, child) {
          return HomePage(child: child);
        },
        routes: [
          // Ruta principal de Inventario
          GoRoute(
            path: '/home/inventory',
            builder: (context, state) {
              return const InventoryPage();
            },
            routes: [
              // Ruta para crear un producto en el inventario
              GoRoute(
                path: 'create-product',
                builder: (context, state) => CreateProductPage(),
              ),
              // Ruta para ver un producto específico por su ID
              GoRoute(
                path: 'product/:idProduct',
                builder: (context, state) {
                  final idProducto = state.pathParameters['idProduct']! as int;
                  return ProductPage(idProducto: idProducto);
                },
              ),
            ],
          ),
          // Ruta para Ventas
          GoRoute(
            path: '/home/sales',
            builder: (context, state) {
              return const SalesPage(); // Página de ventas
            },
          ),
          /*GoRoute(
            path: '/home/reports',
            builder: (context, state) {
              return const ReportsPage(); // Página de reportes
            },
          ),*/
        ],
      ),

      // Ruta para el escáner de código de barras
      GoRoute(
        path: '/barcode-scanner',
        builder: (context, state) => BarcodeScanner(),
      ),
    ],
  );
}
