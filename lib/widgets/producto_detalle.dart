import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../navigation/app_shell.dart';
import '../providers/carrito_provider.dart';
import '../utils/colores.dart';
import '../utils/formato.dart';
import '../utils/responsive.dart';
import 'comunes.dart';
import 'producto_imagen.dart';

/// Agrega un producto al carrito y muestra la confirmación.
Future<void> agregarAlCarrito(
  BuildContext context,
  Producto producto, {
  int cantidad = 1,
  String? personalizacion,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  await context.read<CarritoProvider>().agregarItem(
        producto,
        cantidad: cantidad,
        personalizacion: personalizacion,
      );
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        persist: false,
        content: Text('${cantidad > 1 ? '$cantidad× ' : ''}${producto.nombre} agregado al carrito'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Ver carrito',
          textColor: AppColors.rosaPastel,
          onPressed: () => AppShell.irA(Seccion.carrito),
        ),
      ),
    );
}

/// Abre el detalle del producto: hoja inferior en móvil y diálogo en pantallas anchas.
Future<void> mostrarDetalleProducto(BuildContext context, Producto producto) {
  if (Breakpoints.esMovil(context)) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (_) => _DetalleProducto(producto: producto, ancho: false),
    );
  }
  return showDialog(
    context: context,
    builder: (_) => Dialog(
      clipBehavior: Clip.antiAlias,
      insetPadding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 880, maxHeight: 560),
        child: _DetalleProducto(producto: producto, ancho: true),
      ),
    ),
  );
}

class _DetalleProducto extends StatefulWidget {
  final Producto producto;
  final bool ancho;

  const _DetalleProducto({required this.producto, required this.ancho});

  @override
  State<_DetalleProducto> createState() => _DetalleProductoState();
}

class _DetalleProductoState extends State<_DetalleProducto> {
  final _personalizacion = TextEditingController();
  int _cantidad = 1;

  @override
  void dispose() {
    _personalizacion.dispose();
    super.dispose();
  }

  Future<void> _agregar() async {
    final texto = _personalizacion.text.trim();
    final navigator = Navigator.of(context);
    await agregarAlCarrito(
      context,
      widget.producto,
      cantidad: _cantidad,
      personalizacion: texto.isEmpty ? null : texto,
    );
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.producto;
    final theme = Theme.of(context);

    final imagen = Stack(
      fit: StackFit.expand,
      children: [
        Hero(
          tag: 'producto-${p.id}',
          child: ProductoImagen(src: p.imagen, anchoDecodificado: 600),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Material(
            color: Colors.white.withValues(alpha: 0.92),
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Cerrar',
              icon: const Icon(Icons.close_rounded),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
      ],
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          p.categoria.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.gris,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(p.nombre, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              formatoPrecio(p.precio),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.rosaFuerte),
            ),
            const SizedBox(width: 12),
            _Disponibilidad(disponible: p.disponible),
          ],
        ),
        const SizedBox(height: 14),
        Text(p.descripcion, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 18),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Rasgo(icono: Icons.eco_outlined, texto: 'Ingredientes frescos'),
            _Rasgo(icono: Icons.schedule_rounded, texto: 'Listo en 24 h'),
            _Rasgo(icono: Icons.local_shipping_outlined, texto: 'Entrega a domicilio'),
          ],
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _personalizacion,
          maxLength: 80,
          decoration: const InputDecoration(
            labelText: 'Personalización (opcional)',
            hintText: 'Ej.: "Feliz cumpleaños, Ana", colores, sin nueces…',
            prefixIcon: Icon(Icons.edit_note_rounded),
          ),
        ),
      ],
    );

    final acciones = Row(
      children: [
        SelectorCantidad(cantidad: _cantidad, onCambio: (v) => setState(() => _cantidad = v)),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton(
            onPressed: p.disponible ? _agregar : null,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(p.disponible ? 'Agregar · ${formatoPrecio(p.precio * _cantidad)}' : 'No disponible por ahora'),
            ),
          ),
        ),
      ],
    );

    if (widget.ancho) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(flex: 5, child: imagen),
          Expanded(
            flex: 6,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
              child: Column(
                children: [
                  Expanded(child: SingleChildScrollView(child: info)),
                  const SizedBox(height: 12),
                  acciones,
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AspectRatio(aspectRatio: 4 / 3, child: imagen),
                    Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: info),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 16), child: acciones),
            ),
          ],
        ),
      ),
    );
  }
}

class _Disponibilidad extends StatelessWidget {
  final bool disponible;
  const _Disponibilidad({required this.disponible});

  @override
  Widget build(BuildContext context) {
    final color = disponible ? AppColors.success : AppColors.gris;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(disponible ? Icons.check_circle_rounded : Icons.do_not_disturb_on_outlined, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            disponible ? 'Disponible' : 'Agotado',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _Rasgo extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Rasgo({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(texto, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
