import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/cupones.dart';
import '../navigation/app_shell.dart';
import '../providers/carrito_provider.dart';
import '../utils/colores.dart';
import '../utils/responsive.dart';

class CuponesScreen extends StatelessWidget {
  const CuponesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final movil = Breakpoints.esMovil(context);
    final carrito = context.watch<CarritoProvider>();

    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: movil ? 16 : 36),
          child: ContenidoCentrado(
            maxWidth: 900,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Cupones',
                    style: TextStyle(
                        fontFamily: 'DancingScript',
                        fontWeight: FontWeight.w700,
                        fontSize: movil ? 42 : 54,
                        color: AppColors.rosaFuerte)),
                const Text('Un detalle dulce para tu próximo encargo.',
                    style: TextStyle(color: AppColors.gris, fontSize: 14.5)),
                const SizedBox(height: 22),
                for (final c in cuponesDisponibles)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _TarjetaCupon(
                        cupon: c, aplicado: carrito.cupon?.codigo == c.codigo),
                  ),
                const SizedBox(height: 8),
                const Text(
                  'Los cupones se aplican desde el carrito y no son acumulables.',
                  style: TextStyle(color: AppColors.gris, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LineaPunteada extends CustomPainter {
  const _LineaPunteada();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppColors.rosaPastel
      ..strokeWidth = size.width;
    for (var y = 4.0; y < size.height - 4; y += 10) {
      canvas.drawLine(
          Offset(size.width / 2, y), Offset(size.width / 2, y + 5), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TarjetaCupon extends StatelessWidget {
  final Cupon cupon;
  final bool aplicado;
  const _TarjetaCupon({required this.cupon, required this.aplicado});

  void _usar(BuildContext context) {
    final carrito = context.read<CarritoProvider>();
    final messenger = ScaffoldMessenger.of(context);
    if (carrito.items.isEmpty) {
      messenger.showSnackBar(SnackBar(
        persist: false,
        content: const Text('Agrega postres al carrito para usar este cupón'),
        action: SnackBarAction(
          label: 'Ver catálogo',
          textColor: AppColors.rosaPastel,
          onPressed: () => AppShell.irA(Seccion.catalogo),
        ),
      ));
      return;
    }
    final error = carrito.aplicarCupon(cupon.codigo);
    messenger.showSnackBar(SnackBar(
      persist: false,
      content: Text(error ?? 'Cupón ${cupon.codigo} aplicado ♡'),
      action: error == null
          ? SnackBarAction(
              label: 'Ir al carrito',
              textColor: AppColors.rosaPastel,
              onPressed: () => AppShell.irA(Seccion.carrito),
            )
          : null,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.suave,
        border: Border.all(
            color: aplicado ? AppColors.rosaFuerte : AppColors.border,
            width: aplicado ? 2 : 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 104,
              color: AppColors.rosa,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    child: Text(
                      cupon.etiqueta,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  const Text('OFF',
                      style: TextStyle(
                          color: Colors.white, fontSize: 12, letterSpacing: 2)),
                ],
              ),
            ),
            // Línea punteada de "ticket".
            const SizedBox(
                width: 2, child: CustomPaint(painter: _LineaPunteada())),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cupon.titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.marron)),
                    const SizedBox(height: 2),
                    Text(cupon.descripcion,
                        style: const TextStyle(
                            color: AppColors.gris, fontSize: 13)),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: cupon.codigo));
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text('Código ${cupon.codigo} copiado')));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.rosaClaro,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(cupon.codigo,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.rosaFuerte,
                                          letterSpacing: 1)),
                                ),
                                const SizedBox(width: 6),
                                const Icon(Icons.copy_rounded,
                                    size: 14, color: AppColors.rosaFuerte),
                              ],
                            ),
                          ),
                        ),
                        aplicado
                            ? const Chip(
                                avatar: Icon(Icons.check_rounded,
                                    size: 16, color: Colors.white),
                                label: Text('Aplicado'),
                                labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                                backgroundColor: AppColors.rosaFuerte,
                                side: BorderSide.none,
                              )
                            : FilledButton(
                                onPressed: () => _usar(context),
                                style: FilledButton.styleFrom(
                                  minimumSize: const Size(0, 36),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  shape: const StadiumBorder(),
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13),
                                ),
                                child: const Text('Usar'),
                              ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
