import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../navigation/app_shell.dart';
import '../providers/carrito_provider.dart';
import '../services/database_services.dart';
import '../utils/colores.dart';
import '../utils/responsive.dart';
import '../widgets/comunes.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  Map<String, String> _datos = const {};

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() => setState(() => _datos = DatabaseService.cargarDatosCliente());

  @override
  Widget build(BuildContext context) {
    final movil = Breakpoints.esMovil(context);
    final carrito = context.watch<CarritoProvider>();
    final nombre = (_datos['nombre'] ?? '').trim();
    final pendientes = carrito.pedidosPendientes.length;

    return Scaffold(
      backgroundColor: AppColors.blanco,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: movil ? 16 : 36),
          child: ContenidoCentrado(
            maxWidth: 760,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppColors.rosaPastel, AppColors.rosa]),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.white,
                        child: nombre.isEmpty
                            ? const Icon(Icons.favorite_rounded, color: AppColors.rosaFuerte, size: 30)
                            : Text(nombre[0].toUpperCase(),
                                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.rosaFuerte)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nombre.isEmpty ? '¡Hola!' : 'Hola, ${nombre.split(' ').first}',
                              style: const TextStyle(
                                  fontFamily: 'DancingScript', fontWeight: FontWeight.w700, fontSize: 36, color: Colors.white),
                            ),
                            Text(
                              nombre.isEmpty
                                  ? 'Guarda tus datos para pedir más rápido.'
                                  : (_datos['telefono'] ?? ''),
                              style: const TextStyle(color: Colors.white, fontSize: 13.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _Dato(valor: '${carrito.totalPedidosRealizados}', etiqueta: 'Pedidos')),
                    const SizedBox(width: 12),
                    Expanded(child: _Dato(valor: '$pendientes', etiqueta: 'Por confirmar')),
                    const SizedBox(width: 12),
                    Expanded(child: _Dato(valor: '${carrito.favoritos.length}', etiqueta: 'Favoritos')),
                  ],
                ),
                const SizedBox(height: 18),
                _Grupo(children: [
                  _Opcion(
                    icono: Icons.receipt_long_outlined,
                    titulo: 'Mis pedidos',
                    subtitulo: 'Historial y estado de tus encargos',
                    onTap: () => navegadorRaiz.currentState?.pushNamed('/historial'),
                  ),
                  _Opcion(
                    icono: Icons.favorite_border_rounded,
                    titulo: 'Mis favoritos',
                    subtitulo: 'Los postres que más te gustan',
                    onTap: () => navegadorRaiz.currentState?.pushNamed('/favoritos'),
                  ),
                  _Opcion(
                    icono: Icons.location_on_outlined,
                    titulo: 'Mis datos de entrega',
                    subtitulo: nombre.isEmpty ? 'Aún no los has guardado' : (_datos['direccion'] ?? ''),
                    onTap: _editarDatos,
                  ),
                ]),
                const SizedBox(height: 14),
                _Grupo(children: [
                  _Opcion(
                    icono: Icons.chat_outlined,
                    titulo: 'Escríbenos por WhatsApp',
                    subtitulo: Contacto.telefonoVisible,
                    onTap: () => Contacto.abrirWhatsApp(context),
                  ),
                  _Opcion(
                    icono: Icons.photo_library_outlined,
                    titulo: 'Créditos de las fotos',
                    subtitulo: 'Imágenes con licencia abierta',
                    onTap: () => navegadorRaiz.currentState?.pushNamed('/creditos'),
                  ),
                  _Opcion(
                    icono: Icons.build_outlined,
                    titulo: 'Herramientas de desarrollo',
                    subtitulo: 'Base de datos local y datos de prueba',
                    onTap: () => navegadorRaiz.currentState?.pushNamed('/debug'),
                  ),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _editarDatos() async {
    final nombre = TextEditingController(text: _datos['nombre']);
    final tel = TextEditingController(text: _datos['telefono']);
    final dir = TextEditingController(text: _datos['direccion']);
    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mis datos de entrega'),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nombre, decoration: const InputDecoration(labelText: 'Nombre', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 12),
              TextField(
                controller: tel,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'WhatsApp', prefixIcon: Icon(Icons.phone_outlined)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: dir,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Dirección', prefixIcon: Icon(Icons.location_on_outlined)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Guardar')),
        ],
      ),
    );
    if (guardar == true) {
      await DatabaseService.guardarDatosCliente(
        nombre: nombre.text.trim(),
        telefono: tel.text.trim(),
        direccion: dir.text.trim(),
      );
      _cargar();
    }
  }
}

class _Dato extends StatelessWidget {
  final String valor;
  final String etiqueta;
  const _Dato({required this.valor, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: AppColors.rosaClaro, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          Text(valor, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.rosaFuerte)),
          Text(etiqueta, style: const TextStyle(fontSize: 12, color: AppColors.gris)),
        ],
      ),
    );
  }
}

class _Grupo extends StatelessWidget {
  final List<Widget> children;
  const _Grupo({required this.children});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(indent: 64, height: 1),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Opcion extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  const _Opcion({required this.icono, required this.titulo, required this.subtitulo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(color: AppColors.rosaClaro, shape: BoxShape.circle),
        child: Icon(icono, color: AppColors.rosaFuerte, size: 21),
      ),
      title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.marron)),
      subtitle: Text(subtitulo, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12.5)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.rosa),
    );
  }
}
