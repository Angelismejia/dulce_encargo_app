import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/lista_productos.dart';
import '../navigation/app_shell.dart';
import '../providers/carrito_provider.dart';
import '../utils/colores.dart';
import '../utils/responsive.dart';
import '../widgets/categorias.dart';
import '../widgets/decoraciones.dart';
import '../widgets/encabezado.dart';
import '../widgets/pie_pagina.dart';
import '../widgets/producto_card.dart';
import '../widgets/producto_detalle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movil = Breakpoints.esMovil(context);
    final destacados = ListaProductos.destacados();

    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        builder: (_, t, child) => Opacity(opacity: t, child: child),
        child: CustomScrollView(
          slivers: [
            if (movil) const SliverToBoxAdapter(child: _EncabezadoMovil()),
            SliverToBoxAdapter(child: _Hero(movil: movil)),
            SliverToBoxAdapter(
              child: ContenidoCentrado(
                child: Padding(
                  padding: EdgeInsets.only(top: movil ? 4 : 12, bottom: movil ? 24 : 40),
                  child: const _Ocasiones(),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: ContenidoCentrado(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TituloSeccion(
                      titulo: 'Nuestros favoritos',
                      onVerTodo: () => AppShell.irA(Seccion.catalogo),
                    ),
                    const SizedBox(height: 16),
                    CuadriculaProductos(
                      productos: destacados,
                      onAgregar: (p) => agregarAlCarrito(context, p),
                      onVer: (p) => mostrarDetalleProducto(context, p),
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: OutlinedButton.icon(
                        onPressed: () => AppShell.irA(Seccion.catalogo),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.rosaFuerte,
                          side: const BorderSide(color: AppColors.rosa, width: 1.5),
                          shape: const StadiumBorder(),
                        ),
                        icon: const Icon(Icons.storefront_outlined),
                        label: Text('Ver los ${ListaProductos.obtenerProductos().length} postres'),
                      ),
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
            const SliverToBoxAdapter(child: PiePagina()),
          ],
        ),
      ),
    );
  }
}

class _EncabezadoMovil extends StatelessWidget {
  const _EncabezadoMovil();

  @override
  Widget build(BuildContext context) {
    final cantidad = context.select<CarritoProvider, int>((c) => c.itemCount);
    return Container(
      color: AppColors.rosaPastel,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: BarraBusqueda(
                  onBuscar: (q) => AppShell.irA(Seccion.catalogo, busqueda: q),
                ),
              ),
              const SizedBox(width: 10),
              BotonCarrito(cantidad: cantidad),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final bool movil;
  const _Hero({required this.movil});

  @override
  Widget build(BuildContext context) {
    final alto = movil ? 250.0 : 380.0;
    final altoOnda = movil ? 92.0 : 130.0;

    return SizedBox(
      height: alto,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.rosaPastel, AppColors.rosa],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned.fill(bottom: altoOnda * 0.6, child: DecoracionesHero(amplio: !movil)),
          Positioned(
            left: 0,
            right: 0,
            bottom: -1,
            height: altoOnda,
            child: const CustomPaint(painter: OndaCremaPainter()),
          ),
          Positioned.fill(
            bottom: altoOnda * 0.55,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, t, child) => Opacity(
                    opacity: t,
                    child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Dulce Encargo',
                          style: TextStyle(
                            fontFamily: 'DancingScript',
                            fontWeight: FontWeight.w700,
                            fontSize: movil ? 52 : 84,
                            color: Colors.white,
                            height: 1.05,
                            shadows: [
                              Shadow(
                                color: AppColors.rosaFuerte.withValues(alpha: 0.45),
                                offset: const Offset(0, 3),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Hecho con amor, especialmente para ti ♡',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: movil ? 14.5 : 19,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      if (!movil) ...[
                        const SizedBox(height: 22),
                        FilledButton(
                          onPressed: () => AppShell.irA(Seccion.catalogo),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.rosaFuerte,
                            shape: const StadiumBorder(),
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                          ),
                          child: const Text('Haz tu encargo'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ocasiones extends StatelessWidget {
  const _Ocasiones();

  @override
  Widget build(BuildContext context) {
    if (Breakpoints.esMovil(context)) {
      // Cuatro círculos repartidos en el ancho disponible (también en pantallas de 320 px).
      return LayoutBuilder(builder: (context, c) {
        final ancho = c.maxWidth / ListaProductos.ocasiones.length;
        return Row(
          children: [
            for (final o in ListaProductos.ocasiones)
              CirculoCategoria(
                etiqueta: o,
                ancho: ancho,
                diametro: (ancho - 18).clamp(44.0, 64.0),
                onTap: () => AppShell.irA(Seccion.catalogo, ocasion: o),
              ),
          ],
        );
      });
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 48,
      runSpacing: 16,
      children: [
        for (final o in ListaProductos.ocasiones)
          CirculoCategoria(
            etiqueta: o,
            diametro: 84,
            onTap: () => AppShell.irA(Seccion.catalogo, ocasion: o),
          ),
      ],
    );
  }
}

class _TituloSeccion extends StatelessWidget {
  final String titulo;
  final VoidCallback onVerTodo;
  const _TituloSeccion({required this.titulo, required this.onVerTodo});

  @override
  Widget build(BuildContext context) {
    final movil = Breakpoints.esMovil(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            titulo,
            style: TextStyle(
              fontFamily: 'DancingScript',
              fontWeight: FontWeight.w700,
              fontSize: movil ? 30 : 40,
              color: AppColors.rosaFuerte,
            ),
          ),
        ),
        TextButton(
          onPressed: onVerTodo,
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [Text('Ver todo'), SizedBox(width: 4), Icon(Icons.arrow_forward_rounded, size: 18)],
          ),
        ),
      ],
    );
  }
}
