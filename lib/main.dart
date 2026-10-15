import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'navigation/app_shell.dart';
import 'providers/carrito_provider.dart';
import 'screens/creditos_screen.dart';
import 'screens/debug_screen.dart';
import 'screens/favoritos_screen.dart';
import 'screens/historial_screen.dart';
import 'screens/pedido_screen.dart';
import 'services/database_services.dart';
import 'utils/tema.dart';
import 'widgets/comunes.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await DatabaseService.initHive();
  } catch (e) {
    // La app sigue funcionando; el carrito simplemente no se guardará.
    debugPrint('❌ Error inicializando la base de datos: $e');
  }
  runApp(const DulceEncargoApp());
}

class DulceEncargoApp extends StatelessWidget {
  const DulceEncargoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CarritoProvider()..inicializar(),
      child: MaterialApp(
        title: 'Dulce Encargo · Repostería artesanal',
        debugShowCheckedModeBanner: false,
        navigatorKey: navegadorRaiz,
        theme: AppTema.claro,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es', 'DO'), Locale('es', 'ES'), Locale('en', 'US')],
        locale: const Locale('es', 'DO'),
        initialRoute: '/',
        routes: {
          '/': (_) => AppShell(key: AppShell.clave),
          '/pedido': (_) => const PedidoScreen(),
          '/historial': (_) => HistorialScreen(),
          '/favoritos': (_) => const FavoritosScreen(),
          '/creditos': (_) => const CreditosScreen(),
          '/debug': (_) => DebugScreen(),
        },
        onUnknownRoute: (_) => MaterialPageRoute(
          builder: (context) => Scaffold(
            body: EstadoVacio(
              icono: Icons.cake_outlined,
              titulo: 'Página no encontrada',
              mensaje: 'Este postre no está en el menú.',
              accion: 'Ir al inicio',
              onAccion: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false),
            ),
          ),
        ),
      ),
    );
  }
}
