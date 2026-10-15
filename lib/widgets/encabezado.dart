import 'package:flutter/material.dart';
import '../navigation/app_shell.dart';
import '../utils/colores.dart';

/// Barra de búsqueda blanca y redondeada: "¿Qué se te antoja hoy?".
class BarraBusqueda extends StatefulWidget {
  final ValueChanged<String> onBuscar;
  final ValueChanged<String>? onCambio;
  final String? valorInicial;
  final bool autofocus;

  const BarraBusqueda({
    super.key,
    required this.onBuscar,
    this.onCambio,
    this.valorInicial,
    this.autofocus = false,
  });

  @override
  State<BarraBusqueda> createState() => _BarraBusquedaState();
}

class _BarraBusquedaState extends State<BarraBusqueda> {
  late final TextEditingController _c = TextEditingController(text: widget.valorInicial);

  @override
  void didUpdateWidget(covariant BarraBusqueda oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.valorInicial != oldWidget.valorInicial && widget.valorInicial != _c.text) {
      _c.text = widget.valorInicial ?? '';
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(color: AppColors.rosaFuerte.withValues(alpha: 0.10), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _c,
        autofocus: widget.autofocus,
        textInputAction: TextInputAction.search,
        onSubmitted: (v) => widget.onBuscar(v.trim()),
        onChanged: (v) {
          widget.onCambio?.call(v);
          setState(() {});
        },
        style: const TextStyle(fontSize: 14.5, color: AppColors.marron),
        decoration: InputDecoration(
          hintText: '¿Qué se te antoja hoy?',
          hintStyle: const TextStyle(color: AppColors.gris, fontSize: 14.5),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.rosa),
          suffixIcon: _c.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Borrar búsqueda',
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.gris),
                  onPressed: () {
                    _c.clear();
                    widget.onCambio?.call('');
                    setState(() {});
                  },
                ),
          filled: false,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(999),
            borderSide: const BorderSide(color: AppColors.rosa, width: 1.5),
          ),
        ),
      ),
    );
  }
}

/// Icono de carrito con contador, usado en los encabezados.
class BotonCarrito extends StatelessWidget {
  final int cantidad;
  final bool activo;
  final Color color;

  const BotonCarrito({super.key, required this.cantidad, this.activo = false, this.color = AppColors.rosaFuerte});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: activo ? AppColors.rosa : Colors.white,
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: 'Mi carrito ($cantidad artículos)',
        onPressed: () => AppShell.irA(Seccion.carrito),
        icon: Badge(
          isLabelVisible: cantidad > 0,
          backgroundColor: activo ? Colors.white : AppColors.rosaFuerte,
          textColor: activo ? AppColors.rosaFuerte : Colors.white,
          label: TweenAnimationBuilder<double>(
            key: ValueKey(cantidad),
            tween: Tween(begin: 1.6, end: 1),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            builder: (_, s, child) => Transform.scale(scale: s, child: child),
            child: Text(cantidad > 99 ? '99+' : '$cantidad'),
          ),
          child: Icon(Icons.shopping_bag_outlined, color: activo ? Colors.white : color),
        ),
      ),
    );
  }
}
