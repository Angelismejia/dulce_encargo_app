import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/lista_productos.dart';
import '../models/producto.dart';
import '../navigation/app_shell.dart';
import '../providers/carrito_provider.dart';
import '../utils/responsive.dart';
import '../widgets/comunes.dart';
import '../widgets/producto_card.dart';
import '../widgets/producto_detalle.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ids = context.watch<CarritoProvider>().favoritos;
    final productos = ids.map(ListaProductos.buscarPorId).whereType<Producto>().toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Mis favoritos')),
      body: productos.isEmpty
          ? EstadoVacio(
              icono: Icons.favorite_border_rounded,
              titulo: 'Aún no tienes favoritos',
              mensaje: 'Toca el corazón de cualquier postre para guardarlo aquí.',
              accion: 'Explorar el catálogo',
              onAccion: () => AppShell.irA(Seccion.catalogo),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ContenidoCentrado(
                child: CuadriculaProductos(
                  productos: productos,
                  onAgregar: (p) => agregarAlCarrito(context, p),
                  onVer: (p) => mostrarDetalleProducto(context, p),
                ),
              ),
            ),
    );
  }
}
