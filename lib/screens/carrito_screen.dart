import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/app_shell.dart';
import '../providers/carrito_provider.dart';
import '../utils/colores.dart';
import '../utils/formato.dart';
import '../utils/responsive.dart';
import '../widgets/carrito_item.dart';
import '../widgets/decoraciones.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final escritorio = Breakpoints.esDesktop(context);
    final movil = Breakpoints.esMovil(context);

    final titulo = Row(
      children: [
        if (movil) ...[
          Material(
            color: Colors.white,
            shape: const CircleBorder(),
            elevation: 0,
            child: IconButton(
              tooltip: 'Volver al menú',
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.rosaFuerte),
              onPressed: () => AppShell.irA(Seccion.menu),
            ),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Text(
            'Mi carrito',
            style: TextStyle(
              fontFamily: 'DancingScript',
              fontWeight: FontWeight.w700,
              fontSize: movil ? 44 : 56,
              color: Colors.white,
              height: 1.1,
            ),
          ),
        ),
        if (carrito.items.isNotEmpty)
          TextButton(
            onPressed: () => _confirmarVaciar(context, carrito),
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            child: const Text('Vaciar'),
          ),
      ],
    );

    final lista = carrito.items.isEmpty
        ? const _CarritoVacio()
        : Column(
            children: [
              for (var i = 0; i < carrito.items.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: CarritoItem(
                    key: ValueKey('${carrito.items[i].producto.id}-${carrito.items[i].personalizacion}'),
                    item: carrito.items[i],
                    onRemove: () => _eliminar(context, carrito, i),
                    onUpdateQuantity: (n) => carrito.actualizarCantidad(i, n),
                  ),
                ),
            ],
          );

    return Scaffold(
      backgroundColor: AppColors.rosa,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: movil ? 16 : 36),
          child: ContenidoCentrado(
            maxWidth: 1180,
            child: escritorio
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 7,
                        child: Column(children: [titulo, const SizedBox(height: 24), lista]),
                      ),
                      const SizedBox(width: 36),
                      SizedBox(
                        width: 380,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 86),
                          child: ResumenCarrito(carrito: carrito, detallado: true),
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      titulo,
                      const SizedBox(height: 18),
                      lista,
                      if (carrito.items.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        ResumenCarrito(carrito: carrito, detallado: !movil),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _eliminar(BuildContext context, CarritoProvider carrito, int index) {
    final item = carrito.items[index];
    carrito.removerItem(index);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        persist: false,
        content: Text('${item.producto.nombre} eliminado'),
        action: SnackBarAction(
          label: 'Deshacer',
          textColor: AppColors.rosaPastel,
          onPressed: () => carrito.agregarItem(
            item.producto,
            cantidad: item.cantidad,
            personalizacion: item.personalizacion,
          ),
        ),
      ));
  }

  void _confirmarVaciar(BuildContext context, CarritoProvider carrito) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Vaciar el carrito?'),
        content: const Text('Se quitarán todos los postres que agregaste.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              carrito.limpiarCarrito();
              Navigator.pop(ctx);
            },
            child: const Text('Vaciar'),
          ),
        ],
      ),
    );
  }
}

/// Barra de total rosa oscuro + botón blanco "Realizar pedido".
class ResumenCarrito extends StatelessWidget {
  final CarritoProvider carrito;
  final bool detallado;

  const ResumenCarrito({super.key, required this.carrito, this.detallado = false});

  @override
  Widget build(BuildContext context) {
    final vacio = carrito.items.isEmpty;

    Widget linea(String a, String b, {bool fuerte = false}) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: Text(a, style: TextStyle(color: Colors.white.withValues(alpha: fuerte ? 1 : 0.9), fontSize: 14)),
              ),
              Text(b, style: TextStyle(color: Colors.white, fontWeight: fuerte ? FontWeight.w700 : FontWeight.w600)),
            ],
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(20, detallado ? 20 : 14, 20, detallado ? 20 : 14),
          decoration: BoxDecoration(
            color: AppColors.rosaFuerte,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (detallado) ...[
                const Text('Resumen del pedido',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 17)),
                const SizedBox(height: 10),
                linea('Artículos', '${carrito.itemCount}'),
                linea('Subtotal', formatoPrecio(carrito.total)),
              ],
              if (carrito.descuento > 0)
                linea('Cupón ${carrito.cupon!.codigo}', '− ${formatoPrecio(carrito.descuento)}'),
              if (detallado || carrito.descuento > 0)
                Divider(color: Colors.white.withValues(alpha: 0.35), height: 18),
              Row(
                children: [
                  const Expanded(
                    child: Text('Total:', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: carrito.totalAPagar),
                    duration: const Duration(milliseconds: 350),
                    builder: (_, v, __) => Text(
                      formatoPrecio(v, decimales: true),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: vacio ? null : () => _dialogoCupon(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.local_offer_outlined, size: 16),
                  label: Text(carrito.cupon == null ? '¿Tienes un cupón?' : 'Cambiar cupón'),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        BotonBlancoTexturizado(
          texto: 'Realizar pedido',
          onPressed: vacio ? null : () => navegadorRaiz.currentState?.pushNamed('/pedido'),
        ),
      ],
    );
  }

  void _dialogoCupon(BuildContext context) {
    final c = TextEditingController(text: carrito.cupon?.codigo);
    String? error;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) {
          void aplicar() {
            final e = carrito.aplicarCupon(c.text);
            if (e == null) {
              Navigator.pop(ctx);
            } else {
              setState(() => error = e);
            }
          }

          return AlertDialog(
            title: const Text('Aplicar cupón'),
            content: TextField(
              controller: c,
              autofocus: true,
              textCapitalization: TextCapitalization.characters,
              onSubmitted: (_) => aplicar(),
              decoration: InputDecoration(labelText: 'Código', hintText: 'Ej.: DULCE10', errorText: error),
            ),
            actions: [
              if (carrito.cupon != null)
                TextButton(
                  onPressed: () {
                    carrito.quitarCupon();
                    Navigator.pop(ctx);
                  },
                  child: const Text('Quitar'),
                ),
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
              FilledButton(onPressed: aplicar, child: const Text('Aplicar')),
            ],
          );
        },
      ),
    );
  }
}

/// Botón blanco ancho, texto rosa, sombra delicada y textura sutil de puntitos.
class BotonBlancoTexturizado extends StatefulWidget {
  final String texto;
  final VoidCallback? onPressed;
  final IconData? icono;

  const BotonBlancoTexturizado({super.key, required this.texto, required this.onPressed, this.icono});

  @override
  State<BotonBlancoTexturizado> createState() => _BotonBlancoTexturizadoState();
}

class _BotonBlancoTexturizadoState extends State<BotonBlancoTexturizado> {
  bool _presionado = false;

  @override
  Widget build(BuildContext context) {
    final activo = widget.onPressed != null;
    return AnimatedScale(
      scale: _presionado ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      child: Container(
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: AppColors.marron.withValues(alpha: 0.12), blurRadius: 18, offset: const Offset(0, 8)),
          ],
        ),
        child: Material(
          color: activo ? Colors.white : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onPressed,
            onHighlightChanged: (v) => setState(() => _presionado = v),
            splashColor: AppColors.rosaPastel.withValues(alpha: 0.5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const CustomPaint(painter: TexturaPuntosPainter()),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.icono != null) ...[
                        Icon(widget.icono, color: AppColors.rosaFuerte),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.texto,
                        style: TextStyle(
                          color: activo ? AppColors.rosaFuerte : AppColors.rosaPastel,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CarritoVacio extends StatelessWidget {
  const _CarritoVacio();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(color: AppColors.rosaClaro, shape: BoxShape.circle),
            child: const Icon(Icons.shopping_bag_outlined, size: 44, color: AppColors.rosaFuerte),
          ),
          const SizedBox(height: 18),
          const Text('Tu carrito está vacío',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.marron)),
          const SizedBox(height: 6),
          const Text(
            'Agrega algo dulce y aparecerá aquí ♡',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.gris),
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: () => AppShell.irA(Seccion.catalogo),
            style: FilledButton.styleFrom(shape: const StadiumBorder()),
            child: const Text('Ver el catálogo'),
          ),
        ],
      ),
    );
  }
}
