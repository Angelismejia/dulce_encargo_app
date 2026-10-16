import 'package:flutter/material.dart';

/// Puntos de quiebre de la app.
class Breakpoints {
  static const double tablet = 640;
  static const double desktop = 1024;
  static const double contenidoMax = 1200;

  static double ancho(BuildContext context) => MediaQuery.sizeOf(context).width;
  static bool esMovil(BuildContext context) => ancho(context) < tablet;
  static bool esTablet(BuildContext context) =>
      ancho(context) >= tablet && ancho(context) < desktop;
  static bool esDesktop(BuildContext context) => ancho(context) >= desktop;

  /// Margen horizontal recomendado para el ancho actual.
  static double margen(BuildContext context) {
    final w = ancho(context);
    if (w < tablet) return 16;
    if (w < desktop) return 28;
    return 40;
  }
}

/// Centra el contenido y limita su ancho en pantallas grandes.
class ContenidoCentrado extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ContenidoCentrado({
    super.key,
    required this.child,
    this.maxWidth = Breakpoints.contenidoMax,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: Breakpoints.margen(context)),
          child: child,
        ),
      ),
    );
  }
}
