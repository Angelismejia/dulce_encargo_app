import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/colores.dart';

/// Ola de crema blanca con goteos, usada en la parte inferior del banner rosa.
class OndaCremaPainter extends CustomPainter {
  final Color color;
  final Color sombra;

  const OndaCremaPainter({this.color = Colors.white, this.sombra = AppColors.rosaPastel});

  Path _onda(Size size, double base, double amplitud, int crestas, double fase) {
    final w = size.width;
    final path = Path()..moveTo(0, size.height)..lineTo(0, base);
    final paso = w / crestas;
    for (var i = 0; i < crestas; i++) {
      final x0 = i * paso;
      final alto = amplitud * (0.75 + 0.25 * math.sin(i * 1.7 + fase));
      path.cubicTo(
        x0 + paso * 0.25, base - alto,
        x0 + paso * 0.75, base - alto,
        x0 + paso, base,
      );
    }
    path..lineTo(w, size.height)..close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final crestas = math.max(4, (size.width / 120).round());

    // Capa trasera en rosa pastel para dar volumen.
    canvas.drawPath(
      _onda(size, size.height * 0.42, size.height * 0.22, crestas, 1.3),
      Paint()..color = sombra.withValues(alpha: 0.7),
    );

    // Crema principal.
    final crema = Paint()..color = color;
    final base = size.height * 0.55;
    canvas.drawPath(_onda(size, base, size.height * 0.26, crestas, 0), crema);

    // Goteos que caen desde la crema.
    final paso = size.width / crestas;
    for (var i = 0; i < crestas; i++) {
      final x = i * paso + paso * (0.15 + 0.7 * ((i * 37) % 10) / 10);
      final largo = size.height * (0.12 + 0.1 * ((i * 53) % 7) / 7);
      final ancho = 9.0 + (i % 3) * 4;
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - ancho / 2, base - 4, ancho, largo + 4),
        Radius.circular(ancho / 2),
      );
      canvas.drawRRect(rect, crema);
    }

    // Brillos suaves sobre la crema.
    final brillo = Paint()
      ..color = sombra.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < crestas; i += 2) {
      final cx = i * paso + paso / 2;
      canvas.drawArc(
        Rect.fromCenter(center: Offset(cx, base - size.height * 0.08), width: paso * 0.4, height: size.height * 0.12),
        math.pi * 1.15,
        math.pi * 0.5,
        false,
        brillo,
      );
    }
  }

  @override
  bool shouldRepaint(covariant OndaCremaPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.sombra != sombra;
}

/// Florecita de cinco pétalos.
class FlorPainter extends CustomPainter {
  final Color color;
  final Color centro;
  const FlorPainter({this.color = Colors.white, this.centro = AppColors.rosaPastel});

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;
    final petalo = Paint()..color = color;
    for (var i = 0; i < 5; i++) {
      final a = i * 2 * math.pi / 5 - math.pi / 2;
      canvas.drawCircle(c + Offset(math.cos(a), math.sin(a)) * r * 0.5, r * 0.42, petalo);
    }
    canvas.drawCircle(c, r * 0.3, Paint()..color = centro);
  }

  @override
  bool shouldRepaint(covariant FlorPainter oldDelegate) => oldDelegate.color != color;
}

/// Corazones, flores y destellos distribuidos sin saturar el banner.
class DecoracionesHero extends StatelessWidget {
  final bool amplio;
  const DecoracionesHero({super.key, this.amplio = false});

  @override
  Widget build(BuildContext context) {
    // (x, y, tipo, tamaño, opacidad) en coordenadas relativas.
    final items = <(double, double, int, double, double)>[
      (0.06, 0.12, 0, 22, 0.9),
      (0.18, 0.40, 1, 20, 0.85),
      (0.88, 0.10, 1, 26, 0.9),
      (0.80, 0.38, 0, 16, 0.75),
      (0.94, 0.30, 2, 14, 0.9),
      (0.30, 0.08, 2, 12, 0.8),
      (0.66, 0.06, 0, 14, 0.7),
      if (amplio) ...[
        (0.42, 0.30, 1, 16, 0.6),
        (0.58, 0.42, 2, 12, 0.7),
        (0.12, 0.62, 0, 14, 0.6),
      ],
    ];

    return LayoutBuilder(builder: (context, c) {
      return Stack(
        children: [
          for (final (x, y, tipo, t, o) in items)
            Positioned(
              left: c.maxWidth * x - t / 2,
              top: c.maxHeight * y,
              child: Opacity(
                opacity: o,
                child: switch (tipo) {
                  0 => Icon(Icons.favorite_rounded, size: t, color: Colors.white),
                  1 => CustomPaint(size: Size.square(t), painter: const FlorPainter()),
                  _ => Icon(Icons.auto_awesome, size: t, color: Colors.white),
                },
              ),
            ),
        ],
      );
    });
  }
}

/// Textura muy sutil de puntitos, usada en el botón blanco del carrito.
class TexturaPuntosPainter extends CustomPainter {
  final Color color;
  const TexturaPuntosPainter({this.color = AppColors.rosaPastel});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color.withValues(alpha: 0.35);
    const paso = 14.0;
    for (var y = 4.0; y < size.height; y += paso) {
      final desfase = ((y / paso).round().isEven) ? 0.0 : paso / 2;
      for (var x = 4.0 + desfase; x < size.width; x += paso) {
        canvas.drawCircle(Offset(x, y), 1.2, p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant TexturaPuntosPainter oldDelegate) => false;
}

/// Iconos lineales que Material no incluye.
enum IconoLinea { pastelBodas, porcion }

class IconoLineaPainter extends CustomPainter {
  final IconoLinea icono;
  final Color color;
  const IconoLineaPainter(this.icono, {this.color = Colors.white});

  @override
  void paint(Canvas canvas, Size s) {
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = s.width * 0.075
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final w = s.width, h = s.height;

    switch (icono) {
      case IconoLinea.pastelBodas:
        RRect piso(double cx, double bottom, double ancho, double alto) => RRect.fromRectAndRadius(
              Rect.fromLTWH(cx - ancho / 2, bottom - alto, ancho, alto),
              Radius.circular(w * 0.06),
            );
        canvas.drawRRect(piso(w / 2, h * 0.92, w * 0.84, h * 0.24), p);
        canvas.drawRRect(piso(w / 2, h * 0.68, w * 0.6, h * 0.2), p);
        canvas.drawRRect(piso(w / 2, h * 0.48, w * 0.36, h * 0.17), p);
        // Corazón en la cima.
        final c = Offset(w / 2, h * 0.2);
        final r = w * 0.07;
        final corazon = Path()
          ..moveTo(c.dx, c.dy + r * 1.3)
          ..cubicTo(c.dx - r * 2.2, c.dy - r * 0.2, c.dx - r * 0.8, c.dy - r * 1.8, c.dx, c.dy - r * 0.5)
          ..cubicTo(c.dx + r * 0.8, c.dy - r * 1.8, c.dx + r * 2.2, c.dy - r * 0.2, c.dx, c.dy + r * 1.3);
        canvas.drawPath(corazon, p);
      case IconoLinea.porcion:
        final cuerpo = Path()
          ..moveTo(w * 0.1, h * 0.5)
          ..lineTo(w * 0.9, h * 0.32)
          ..lineTo(w * 0.9, h * 0.78)
          ..lineTo(w * 0.1, h * 0.88)
          ..close();
        canvas.drawPath(cuerpo, p);
        canvas.drawLine(Offset(w * 0.1, h * 0.68), Offset(w * 0.9, h * 0.56), p);
        canvas.drawCircle(Offset(w * 0.72, h * 0.2), w * 0.08, p);
    }
  }

  @override
  bool shouldRepaint(covariant IconoLineaPainter oldDelegate) =>
      oldDelegate.icono != icono || oldDelegate.color != color;
}

/// Logotipo "Dulce Encargo" en letra manuscrita.
class LogoDulceEncargo extends StatelessWidget {
  final double tamano;
  final Color color;
  const LogoDulceEncargo({super.key, this.tamano = 28, this.color = AppColors.rosaFuerte});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Dulce Encargo',
      header: true,
      child: ExcludeSemantics(
        child: Text(
          'Dulce Encargo',
          maxLines: 1,
          style: TextStyle(
            fontFamily: 'DancingScript',
            fontWeight: FontWeight.w700,
            fontSize: tamano,
            color: color,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
