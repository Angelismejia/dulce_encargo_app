import 'package:flutter/material.dart';
import '../utils/colores.dart';
import '../utils/responsive.dart';
import 'comunes.dart';
import 'decoraciones.dart';

class PiePagina extends StatelessWidget {
  const PiePagina({super.key});

  @override
  Widget build(BuildContext context) {
    final movil = Breakpoints.esMovil(context);

    Widget red(IconData icono, String nombre, String url) => IconButton(
          tooltip: nombre,
          onPressed: () => Contacto.abrirUrl(context, url),
          style: IconButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppColors.rosaFuerte),
          icon: Icon(icono),
        );

    final marca = Column(
      crossAxisAlignment: movil ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        const LogoDulceEncargo(tamano: 34),
        const SizedBox(height: 6),
        Text(
          'Repostería artesanal en República Dominicana.\nPasteles, cupcakes y postres para cada celebración.',
          textAlign: movil ? TextAlign.center : TextAlign.start,
          style: const TextStyle(color: AppColors.gris, fontSize: 13.5, height: 1.5),
        ),
      ],
    );

    final contacto = Column(
      crossAxisAlignment: movil ? CrossAxisAlignment.center : CrossAxisAlignment.end,
      children: [
        FilledButton.icon(
          onPressed: () => Contacto.abrirWhatsApp(context),
          style: FilledButton.styleFrom(backgroundColor: AppColors.whatsapp, shape: const StadiumBorder()),
          icon: const Icon(Icons.chat_rounded),
          label: const Text('Escríbenos por WhatsApp'),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            red(Icons.camera_alt_outlined, 'Instagram', Contacto.instagram),
            const SizedBox(width: 8),
            red(Icons.facebook_rounded, 'Facebook', Contacto.facebook),
            const SizedBox(width: 8),
            red(Icons.music_note_rounded, 'TikTok', Contacto.tiktok),
          ],
        ),
      ],
    );

    return Container(
      color: AppColors.rosaClaro,
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: ContenidoCentrado(
        child: Column(
          children: [
            if (movil) ...[marca, const SizedBox(height: 20), contacto]
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [Expanded(child: marca), contacto],
              ),
            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 14),
            Text(
              '© ${DateTime.now().year} Dulce Encargo · Hecho con ♡ en RD',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.gris, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
