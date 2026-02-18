import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/catalogo_screen.dart';
import 'screens/carrito_screen.dart';
import 'screens/pedido_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/debug_screen.dart';
import 'providers/carrito_provider.dart';
import 'services/database_services.dart';
import 'utils/colores.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Inicializar Hive de forma más robusta
    await DatabaseService.initHive();

    print('✅ Aplicación inicializada correctamente');
  } catch (e) {
    print('❌ Error crítico inicializaflutter --versionndo la aplicación: $e');
    // En caso de error, mostrar un mensaje de error pero no detener la app
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) {
        final provider = CarritoProvider();
        // Inicializar después de crear el provider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          provider.inicializar();
        });
        return provider;
      },
      child: MaterialApp(
        title: 'DulceEncargoApp',
        debugShowCheckedModeBanner: false,

        // ← CONFIGURACIÓN DE LOCALIZACIÓN (SOLUCIONA EL ERROR)
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'DO'), // Español Dominicano
          Locale('es', 'ES'), // Español España
          Locale('en', 'US'), // Inglés (fallback)
        ],
        locale: const Locale('es', 'DO'), // Configurar español dominicano por defecto

        theme: ThemeData(
          primarySwatch: Colors.pink,
          primaryColor: AppColors.primary,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          // Configuración adicional para mejor compatibilidad
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => HomeScreen(),
          '/catalogo': (context) => CatalogoScreen(),
          '/carrito': (context) => CarritoScreen(),
          '/pedido': (context) => PedidoScreen(),
          '/historial': (context) => HistorialScreen(),
          '/debug': (context) => DebugScreen(),
        },
        // Manejar errores de rutas
        onUnknownRoute: (settings) {
          return MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: Text('Error')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text('Página no encontrada'),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                      child: Text('Ir al Inicio'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}