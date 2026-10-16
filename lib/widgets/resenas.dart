import 'package:flutter/material.dart';
import '../utils/colores.dart';

class Resena {
  final String nombre;
  final String texto;
  final int estrellas;
  const Resena(this.nombre, this.texto, this.estrellas);
}

/// Reseñas de ejemplo (el negocio es ficticio).
const resenas = [
  Resena(
    'Mandy Rivas',
    'Pedí una torta para la fiesta de graduación de mi papá y quedó preciosa. '
        'Hacer el pedido por WhatsApp fue rapidísimo y me la llevaron a casa a '
        'tiempo. ¡Súper recomendado!',
    5,
  ),
  Resena(
    'Angelis de Jesús',
    'Muy bonito y muy completo. En el catálogo se ve todo con su precio, así '
        'que cuando escribí ya sabía exactamente lo que quería.',
    5,
  ),
  Resena(
    'Arelis López',
    'Excelente atención y mucha variedad. Siempre encuentro el postre perfecto '
        'para cada ocasión. ¡Sigan así!',
    4,
  ),
  Resena(
    'Camila Torres',
    'Los pasteles personalizados son hermosos y deliciosos. ¡Gracias por hacer '
        'especial cada celebración!',
    5,
  ),
];

/// Sección "Lo que dicen nuestros clientes": carrusel horizontal en móvil,
/// dos columnas en tablet y cuatro en escritorio.
class SeccionResenas extends StatelessWidget {
  const SeccionResenas({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final movil = c.maxWidth < 600;
      final titulo = Text(
        'Lo que dicen nuestros clientes',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'DancingScript',
          fontWeight: FontWeight.w700,
          fontSize: movil ? 30 : 40,
          color: AppColors.rosaFuerte,
        ),
      );

      if (movil) {
        return Column(
          children: [
            titulo,
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < resenas.length; i++) ...[
                      if (i > 0) const SizedBox(width: 12),
                      SizedBox(
                        width: (c.maxWidth - 56).clamp(220.0, 300.0),
                        child: _TarjetaResena(resenas[i]),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      }

      // Filas de 2 (tablet) o 4 (escritorio) tarjetas con la misma altura.
      const espacio = 16.0;
      final columnas = c.maxWidth >= 1000 ? 4 : 2;
      return Column(
        children: [
          titulo,
          const SizedBox(height: 20),
          for (var i = 0; i < resenas.length; i += columnas) ...[
            if (i > 0) const SizedBox(height: espacio),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = i; j < i + columnas && j < resenas.length; j++) ...[
                    if (j > i) const SizedBox(width: espacio),
                    Expanded(child: _TarjetaResena(resenas[j])),
                  ],
                ],
              ),
            ),
          ],
        ],
      );
    });
  }
}

class _TarjetaResena extends StatelessWidget {
  final Resena resena;
  const _TarjetaResena(this.resena);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: AppColors.rosa.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [AppColors.rosa, AppColors.rosaFuerte]),
                ),
                child: Text(
                  resena.nombre[0],
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resena.nombre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.marron),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < 5; i++)
                          Icon(
                            i < resena.estrellas ? Icons.star_rounded : Icons.star_outline_rounded,
                            size: 16,
                            color: AppColors.rosaFuerte,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.format_quote_rounded, color: AppColors.rosaPastel, size: 30),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            resena.texto,
            style: const TextStyle(fontSize: 13.5, height: 1.5, color: AppColors.gris),
          ),
        ],
      ),
    );
  }
}
