import 'package:flutter/material.dart';
import '../data/creditos_imagenes.dart';
import '../utils/colores.dart';
import '../utils/responsive.dart';
import '../widgets/comunes.dart';
import '../widgets/producto_imagen.dart';

class CreditosScreen extends StatelessWidget {
  const CreditosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créditos de las fotos')),
      body: ContenidoCentrado(
        maxWidth: 820,
        padding: EdgeInsets.zero,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          itemCount: creditosImagenes.length + 1,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, i) {
            if (i == 0) {
              return const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  'Las fotografías provienen de Openverse y tienen licencias abiertas que permiten su uso. '
                  'Gracias a sus autores ♡',
                  style: TextStyle(color: AppColors.gris),
                ),
              );
            }
            final c = creditosImagenes[i - 1];
            return Material(
              color: AppColors.rosaClaro,
              borderRadius: BorderRadius.circular(18),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                onTap: () => Contacto.abrirUrl(context, c.fuente),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(width: 52, height: 52, child: ProductoImagen(src: c.asset, anchoDecodificado: 56)),
                ),
                title: Text(c.titulo.isEmpty ? 'Sin título' : c.titulo, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text('${c.autor} · ${c.licencia}', maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.rosaFuerte),
              ),
            );
          },
        ),
      ),
    );
  }
}
