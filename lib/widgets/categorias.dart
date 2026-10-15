import 'package:flutter/material.dart';
import '../utils/colores.dart';
import 'decoraciones.dart';

/// Icono blanco lineal para cada ocasión.
Widget iconoOcasion(String ocasion, double size) {
  switch (ocasion) {
    case 'Cumpleaños':
      return Icon(Icons.cake_outlined, size: size, color: Colors.white);
    case 'Eventos':
      return Icon(Icons.celebration_outlined, size: size, color: Colors.white);
    case 'Bodas':
      return CustomPaint(size: Size.square(size), painter: const IconoLineaPainter(IconoLinea.pastelBodas));
    case 'Para ti':
      return CustomPaint(size: Size.square(size), painter: const IconoLineaPainter(IconoLinea.porcion));
    default:
      return Icon(Icons.storefront_outlined, size: size, color: Colors.white);
  }
}

/// Categoría circular rosa intenso con icono blanco y texto debajo.
class CirculoCategoria extends StatefulWidget {
  final String etiqueta;
  final bool seleccionado;
  final VoidCallback onTap;
  final double diametro;

  /// Ancho total del elemento (círculo + texto). Por defecto, `diametro + 30`.
  final double? ancho;

  const CirculoCategoria({
    super.key,
    required this.etiqueta,
    required this.onTap,
    this.seleccionado = false,
    this.diametro = 64,
    this.ancho,
  });

  @override
  State<CirculoCategoria> createState() => _CirculoCategoriaState();
}

class _CirculoCategoriaState extends State<CirculoCategoria> {
  bool _hover = false;
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final d = widget.diametro;
    final escala = _presionado ? 0.92 : (_hover ? 1.06 : 1.0);

    return Semantics(
      button: true,
      selected: widget.seleccionado,
      label: widget.etiqueta,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _presionado = true),
          onTapCancel: () => setState(() => _presionado = false),
          onTapUp: (_) => setState(() => _presionado = false),
          onTap: widget.onTap,
          child: FocusableActionDetector(
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
                widget.onTap();
                return null;
              }),
            },
            onShowFocusHighlight: (v) => setState(() => _hover = v),
            child: SizedBox(
              width: widget.ancho ?? d + 30,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedScale(
                    scale: escala,
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: d,
                      height: d,
                      padding: EdgeInsets.all(widget.seleccionado ? 3 : 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.seleccionado ? AppColors.rosaFuerte : Colors.transparent,
                          width: 2.5,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.rosaFuerte,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.rosaFuerte.withValues(alpha: _hover ? 0.45 : 0.25),
                              blurRadius: _hover ? 16 : 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: iconoOcasion(widget.etiqueta, d * 0.46),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.etiqueta,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: widget.seleccionado ? FontWeight.w700 : FontWeight.w500,
                      color: widget.seleccionado ? AppColors.rosaFuerte : AppColors.marron,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
