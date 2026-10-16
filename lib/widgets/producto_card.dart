import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../providers/carrito_provider.dart';
import '../utils/colores.dart';
import '../utils/formato.dart';
import 'producto_imagen.dart';

/// Altura del bloque de texto bajo la foto; la cuadrícula la usa para calcular proporciones.
const double alturaInfoTarjeta = 86;

class ProductoCard extends StatefulWidget {
  final Producto producto;
  final VoidCallback onAddToCart;
  final VoidCallback? onTap;

  /// Posición en la cuadrícula; escalona la animación de entrada.
  final int indice;

  const ProductoCard({
    super.key,
    required this.producto,
    required this.onAddToCart,
    this.onTap,
    this.indice = 0,
  });

  @override
  State<ProductoCard> createState() => _ProductoCardState();
}

class _ProductoCardState extends State<ProductoCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    final favorito =
        context.select<CarritoProvider, bool>((c) => c.esFavorito(p.id));
    final retraso = (widget.indice % 8) * 60;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + retraso),
      curve: Interval(retraso / (420 + retraso), 1, curve: Curves.easeOutCubic),
      builder: (context, t, child) => Opacity(
        opacity: t,
        child:
            Transform.translate(offset: Offset(0, 18 * (1 - t)), child: child),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -5 : 0, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: 'Ver detalles de ${p.nombre}',
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: _hover ? AppShadows.elevada : AppShadows.suave,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: Material(
                        color: AppColors.rosaClaro,
                        child: InkWell(
                          onTap: widget.onTap,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              AnimatedScale(
                                scale: _hover ? 1.06 : 1,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                                child: Hero(
                                  tag: 'producto-${p.id}',
                                  child: ProductoImagen(
                                      src: p.imagen, anchoDecodificado: 340),
                                ),
                              ),
                              if (!p.disponible)
                                Container(
                                  color: Colors.white.withValues(alpha: 0.55),
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.marron,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: const Text('Agotado',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12)),
                                  ),
                                ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: _BotonFavorito(
                                    productoId: p.id, activo: favorito),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: alturaInfoTarjeta,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 10, 0, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: widget.onTap,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Text(
                                  p.nombre,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    height: 1.2,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.marron,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatoPrecio(p.precio),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.rosaFuerte,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: BotonAgregar(
                          onPressed: p.disponible ? widget.onAddToCart : null,
                          etiqueta: 'Agregar ${p.nombre} al carrito',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BotonFavorito extends StatelessWidget {
  final String productoId;
  final bool activo;
  const _BotonFavorito({required this.productoId, required this.activo});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.92),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: activo ? 'Quitar de favoritos' : 'Agregar a favoritos',
        visualDensity: VisualDensity.compact,
        iconSize: 18,
        onPressed: () =>
            context.read<CarritoProvider>().alternarFavorito(productoId),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Icon(
            activo ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            key: ValueKey(activo),
            color: AppColors.rosaFuerte,
          ),
        ),
      ),
    );
  }
}

/// Botón circular rosa que confirma visualmente que se agregó el producto.
class BotonAgregar extends StatefulWidget {
  final VoidCallback? onPressed;
  final String etiqueta;
  final double tamano;
  const BotonAgregar(
      {super.key,
      required this.onPressed,
      required this.etiqueta,
      this.tamano = 40});

  @override
  State<BotonAgregar> createState() => _BotonAgregarState();
}

class _BotonAgregarState extends State<BotonAgregar> {
  bool _agregado = false;

  void _tap() {
    widget.onPressed?.call();
    setState(() => _agregado = true);
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _agregado = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final activo = widget.onPressed != null;
    return Tooltip(
      message: widget.etiqueta,
      child: AnimatedScale(
        scale: _agregado ? 1.15 : 1,
        duration: const Duration(milliseconds: 180),
        child: Material(
          color: !activo
              ? AppColors.rosaPastel
              : (_agregado ? AppColors.rosaFuerte : AppColors.rosa),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: activo ? _tap : null,
            child: SizedBox(
              width: widget.tamano,
              height: widget.tamano,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  _agregado
                      ? Icons.check_rounded
                      : Icons.add_shopping_cart_rounded,
                  key: ValueKey(_agregado),
                  color: Colors.white,
                  size: widget.tamano * 0.48,
                  semanticLabel: widget.etiqueta,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cuadrícula adaptable: 2 columnas en móvil, 3 en tablet y 4 en escritorio.
class CuadriculaProductos extends StatelessWidget {
  final List<Producto> productos;
  final void Function(Producto) onAgregar;
  final void Function(Producto) onVer;
  final int? maxColumnas;

  const CuadriculaProductos({
    super.key,
    required this.productos,
    required this.onAgregar,
    required this.onVer,
    this.maxColumnas,
  });

  static int columnasPara(double ancho) {
    if (ancho < 560) return 2;
    if (ancho < 900) return 3;
    return 4;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      var cols = columnasPara(c.maxWidth);
      if (maxColumnas != null && cols > maxColumnas!) cols = maxColumnas!;
      final espacio = c.maxWidth < 560 ? 14.0 : 22.0;
      final anchoItem = (c.maxWidth - espacio * (cols - 1)) / cols;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: productos.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: espacio,
          mainAxisSpacing: espacio + 4,
          mainAxisExtent: anchoItem + alturaInfoTarjeta,
        ),
        itemBuilder: (context, i) {
          final p = productos[i];
          return ProductoCard(
            key: ValueKey(p.id),
            producto: p,
            indice: i,
            onTap: () => onVer(p),
            onAddToCart: () => onAgregar(p),
          );
        },
      );
    });
  }
}
