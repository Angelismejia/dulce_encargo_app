import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/colores.dart';

/// Datos de contacto del negocio.
class Contacto {
  static const String telefonoVisible = '809-977-7238';
  static const String whatsapp = '18099777238';
  static const String instagram = 'https://instagram.com/dulceencargo.rd';
  static const String facebook = 'https://facebook.com/dulceencargord';
  static const String tiktok = 'https://tiktok.com/@dulceencargo.rd';

  static Future<void> abrirWhatsApp(BuildContext context, {String? mensaje}) {
    final texto = mensaje ?? 'Hola! Me comunico desde la app DulceEncargo. ';
    return abrirUrl(
      context,
      'https://wa.me/$whatsapp?text=${Uri.encodeComponent(texto)}',
    );
  }

  static Future<void> abrirUrl(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!ok) throw Exception('No se pudo abrir $url');
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text('No pudimos abrir el enlace. Visítanos en $url')),
      );
    }
  }
}

/// Encabezado de sección con una etiqueta pequeña, un título y una acción opcional.
class SeccionTitulo extends StatelessWidget {
  final String etiqueta;
  final String titulo;
  final String? descripcion;
  final String? accion;
  final VoidCallback? onAccion;
  final bool centrado;

  const SeccionTitulo({
    super.key,
    required this.etiqueta,
    required this.titulo,
    this.descripcion,
    this.accion,
    this.onAccion,
    this.centrado = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textos = Column(
      crossAxisAlignment: centrado ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta.toUpperCase(),
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.6,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          titulo,
          textAlign: centrado ? TextAlign.center : TextAlign.start,
          style: theme.textTheme.headlineMedium,
        ),
        if (descripcion != null) ...[
          const SizedBox(height: 8),
          Text(
            descripcion!,
            textAlign: centrado ? TextAlign.center : TextAlign.start,
            style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );

    if (accion == null) return textos;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: textos),
        const SizedBox(width: 12),
        TextButton.icon(
          onPressed: onAccion,
          iconAlignment: IconAlignment.end,
          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
          label: Text(accion!),
        ),
      ],
    );
  }
}

/// Estado vacío ilustrado con una acción principal.
class EstadoVacio extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String mensaje;
  final String? accion;
  final VoidCallback? onAccion;

  const EstadoVacio({
    super.key,
    required this.icono,
    required this.titulo,
    required this.mensaje,
    this.accion,
    this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                ),
                child: Icon(icono, size: 52, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              Text(titulo, textAlign: TextAlign.center, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(mensaje, textAlign: TextAlign.center, style: theme.textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
              if (accion != null) ...[
                const SizedBox(height: 28),
                FilledButton(onPressed: onAccion, child: Text(accion!)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Selector de cantidad compacto (– 1 +).
class SelectorCantidad extends StatelessWidget {
  final int cantidad;
  final ValueChanged<int> onCambio;
  final int minimo;
  final bool compacto;

  const SelectorCantidad({
    super.key,
    required this.cantidad,
    required this.onCambio,
    this.minimo = 1,
    this.compacto = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = compacto ? 32.0 : 44.0;
    Widget boton(IconData icon, VoidCallback? onTap, String tooltip) => SizedBox(
          width: size,
          height: size,
          child: IconButton(
            tooltip: tooltip,
            padding: EdgeInsets.zero,
            iconSize: compacto ? 16 : 20,
            onPressed: onTap,
            icon: Icon(icon),
            color: AppColors.textPrimary,
            disabledColor: AppColors.textSecondary.withValues(alpha: 0.35),
          ),
        );

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          boton(Icons.remove_rounded, cantidad > minimo ? () => onCambio(cantidad - 1) : null, 'Quitar uno'),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: compacto ? 22 : 30),
            child: Text(
              '$cantidad',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: compacto ? 14 : 16),
            ),
          ),
          boton(Icons.add_rounded, () => onCambio(cantidad + 1), 'Agregar uno'),
        ],
      ),
    );
  }
}

/// Insignia numérica sobre un icono.
class IconoConInsignia extends StatelessWidget {
  final IconData icono;
  final int cantidad;
  final Color? color;

  const IconoConInsignia({super.key, required this.icono, required this.cantidad, this.color});

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: cantidad > 0,
      backgroundColor: AppColors.primary,
      label: Text(cantidad > 99 ? '99+' : '$cantidad'),
      child: Icon(icono, color: color),
    );
  }
}
