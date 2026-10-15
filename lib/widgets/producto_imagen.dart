import 'package:flutter/material.dart';
import '../utils/colores.dart';

/// Muestra la imagen de un producto, ya sea un asset local o una URL.
class ProductoImagen extends StatelessWidget {
  final String src;
  final BoxFit fit;
  final double? width;
  final double? height;

  /// Ancho aproximado en píxeles lógicos al que se mostrará; se usa para
  /// decodificar la imagen a un tamaño adecuado y ahorrar memoria.
  final double? anchoDecodificado;

  const ProductoImagen({
    super.key,
    required this.src,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.anchoDecodificado,
  });

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final cacheWidth =
        anchoDecodificado == null ? null : (anchoDecodificado! * dpr).round();

    Widget error(BuildContext context, Object e, StackTrace? s) => Container(
          width: width,
          height: height,
          color: AppColors.surfaceMuted,
          alignment: Alignment.center,
          child: const Icon(Icons.cake_outlined, color: AppColors.textSecondary),
        );

    Widget aparecer(BuildContext context, Widget child, int? frame, bool sync) {
      if (sync) return child;
      return AnimatedOpacity(
        opacity: frame == null ? 0 : 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
        child: child,
      );
    }

    final placeholder = Container(color: AppColors.surfaceMuted);

    if (src.startsWith('http')) {
      return Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(child: placeholder),
          Image.network(
            src,
            fit: fit,
            width: width,
            height: height,
            cacheWidth: cacheWidth,
            frameBuilder: aparecer,
            errorBuilder: error,
          ),
        ],
      );
    }
    return Image.asset(
      src,
      fit: fit,
      width: width,
      height: height,
      cacheWidth: cacheWidth,
      frameBuilder: aparecer,
      errorBuilder: error,
    );
  }
}
