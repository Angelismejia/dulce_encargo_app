import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../providers/carrito_provider.dart';
import '../utils/colores.dart';
import '../utils/formato.dart';
import 'producto_imagen.dart';

/// Tarjeta horizontal blanca del carrito.
class CarritoItem extends StatelessWidget {
  final ItemPedido item;
  final VoidCallback onRemove;
  final ValueChanged<int> onUpdateQuantity;

  const CarritoItem({
    super.key,
    required this.item,
    required this.onRemove,
    required this.onUpdateQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final p = item.producto;
    final favorito = context.select<CarritoProvider, bool>((c) => c.esFavorito(p.id));

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(color: AppColors.rosaFuerte.withValues(alpha: 0.18), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen sobre fondo rosa claro.
            Container(
              width: 92,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.rosaClaro,
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ProductoImagen(src: p.imagen, anchoDecodificado: 100),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Nombre, descripción y acciones.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.marron, height: 1.25),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.personalizacion != null ? '“${item.personalizacion}”' : p.descripcion,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.gris,
                          height: 1.3,
                          fontStyle: item.personalizacion != null ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatoPrecio(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5, color: AppColors.rosaFuerte),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _IconoAccion(
                        icono: favorito ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        tooltip: favorito ? 'Quitar de favoritos' : 'Agregar a favoritos',
                        onTap: () => context.read<CarritoProvider>().alternarFavorito(p.id),
                      ),
                      const SizedBox(width: 6),
                      _IconoAccion(
                        icono: Icons.delete_outline_rounded,
                        tooltip: 'Eliminar ${p.nombre}',
                        onTap: onRemove,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Control vertical de cantidad.
            Container(
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.rosaClaro,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _BotonCantidad(
                    icono: Icons.add_rounded,
                    tooltip: 'Agregar uno',
                    onTap: () => onUpdateQuantity(item.cantidad + 1),
                  ),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, anim) => ScaleTransition(
                      scale: Tween(begin: 0.6, end: 1.0).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Text(
                      '${item.cantidad}',
                      key: ValueKey(item.cantidad),
                      semanticsLabel: 'Cantidad ${item.cantidad}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.rosaFuerte),
                    ),
                  ),
                  _BotonCantidad(
                    icono: Icons.remove_rounded,
                    tooltip: 'Quitar uno',
                    onTap: item.cantidad > 1 ? () => onUpdateQuantity(item.cantidad - 1) : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IconoAccion extends StatelessWidget {
  final IconData icono;
  final String tooltip;
  final VoidCallback onTap;
  const _IconoAccion({required this.icono, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.zero,
        onPressed: onTap,
        style: IconButton.styleFrom(backgroundColor: AppColors.rosaClaro),
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Icon(icono, key: ValueKey(icono), color: AppColors.rosaFuerte, size: 19),
        ),
      ),
    );
  }
}

class _BotonCantidad extends StatelessWidget {
  final IconData icono;
  final String tooltip;
  final VoidCallback? onTap;
  const _BotonCantidad({required this.icono, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 40,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onTap,
        padding: EdgeInsets.zero,
        icon: Icon(icono, size: 22),
        color: AppColors.rosaFuerte,
        disabledColor: AppColors.rosaPastel,
      ),
    );
  }
}
