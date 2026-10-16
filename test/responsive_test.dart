import 'dart:io';

import 'package:dulce_encargo_app/data/lista_productos.dart';
import 'package:dulce_encargo_app/main.dart';
import 'package:dulce_encargo_app/navigation/app_shell.dart';
import 'package:dulce_encargo_app/providers/carrito_provider.dart';
import 'package:dulce_encargo_app/screens/home_screen.dart';
import 'package:dulce_encargo_app/services/database_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Falla mostrando el detalle completo del error (widget que lo causó).
void sinErrores(WidgetTester tester, String donde) {
  final e = tester.takeException();
  if (e != null) fail('$donde: ${e is FlutterError ? e.toStringDeep() : e}');
}

/// Renderiza cada sección en varios anchos de pantalla. Cualquier desbordamiento
/// (las franjas amarillas y negras) hace fallar la prueba.
void main() {
  late Directory dir;

  setUpAll(() async {
    // Fuentes reales para que las medidas del texto sean como en el dispositivo.
    final fuentes = {
      'Poppins': ['Regular', 'Medium', 'SemiBold', 'Bold'].map((w) => 'assets/fonts/Poppins-$w.ttf'),
      'DancingScript': ['SemiBold', 'Bold'].map((w) => 'assets/fonts/DancingScript-$w.ttf'),
    };
    for (final f in fuentes.entries) {
      final loader = FontLoader(f.key);
      for (final archivo in f.value) {
        loader.addFont(File(archivo).readAsBytes().then((b) => ByteData.view(b.buffer)));
      }
      await loader.load();
    }
    dir = await Directory.systemTemp.createTemp('dulce_test');
    await DatabaseService.initHive(path: dir.path);
  });

  tearDownAll(() async {
    try {
      await dir.delete(recursive: true);
    } catch (_) {}
  });

  const tamanos = {
    'celular pequeño': Size(320, 640),
    'celular': Size(390, 844),
    'tablet': Size(820, 1180),
    'escritorio': Size(1440, 900),
  };

  for (final entry in tamanos.entries) {
    testWidgets('todas las secciones sin desbordes — ${entry.key}', (tester) async {
      tester.view.physicalSize = entry.value;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const DulceEncargoApp());
      final scrollInicio = find.descendant(of: find.byType(HomeScreen), matching: find.byType(Scrollable)).first;
      await tester.pump(const Duration(seconds: 1));

      // Carrito con productos para ver las tarjetas reales.
      final context = tester.element(find.byType(AppShell));
      final carrito = context.read<CarritoProvider>();
      await tester.runAsync(() async {
        await carrito.limpiarCarrito();
        await carrito.agregarItem(ListaProductos.buscarPorId('5')!, cantidad: 2);
        await carrito.agregarItem(ListaProductos.buscarPorId('26')!, personalizacion: 'Con galletitas extra, por favor');
      });
      await tester.pump(const Duration(seconds: 1));
      await tester.scrollUntilVisible(
        find.text('Mandy Rivas'),
        400,
        scrollable: scrollInicio,
      );
      await tester.pump(const Duration(milliseconds: 500));
      sinErrores(tester, 'inicio');

      for (final seccion in [Seccion.catalogo, Seccion.cupones, Seccion.carrito, Seccion.perfil, Seccion.menu]) {
        AppShell.irA(seccion);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        sinErrores(tester, seccion.name);
      }

      // Formulario de pedido.
      navegadorRaiz.currentState!.pushNamed('/pedido');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Realizar pedido'), findsWidgets);
      sinErrores(tester, 'pedido');

      // Detalle de producto.
      navegadorRaiz.currentState!.pop();
      AppShell.irA(Seccion.menu);
      await tester.pump(const Duration(seconds: 1));
      final tarjeta = find.descendant(of: find.byType(HomeScreen), matching: find.text('Torta Tres Leches'));
      await tester.scrollUntilVisible(tarjeta, -400, scrollable: scrollInicio);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(tarjeta);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining('Agregar ·'), findsOneWidget);
      sinErrores(tester, 'detalle');

      await tester.runAsync(() => carrito.limpiarCarrito());
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 3));
    });
  }
}
