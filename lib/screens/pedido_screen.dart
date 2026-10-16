import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/pedido.dart';
import '../navigation/app_shell.dart';
import '../providers/carrito_provider.dart';
import '../services/database_services.dart';
import '../services/mensaje_whatsapp.dart';
import '../utils/colores.dart';
import '../utils/formato.dart';
import '../utils/responsive.dart';
import '../widgets/comunes.dart';
import '../widgets/producto_imagen.dart';

const _domicilio = 'Entrega a domicilio';
const _recogida = 'Recoger en tienda';

class PedidoScreen extends StatefulWidget {
  const PedidoScreen({super.key});

  @override
  State<PedidoScreen> createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _telefono = TextEditingController();
  final _direccion = TextEditingController();
  final _mensajePastel = TextEditingController();
  final _notas = TextEditingController();

  String _modalidad = _domicilio;
  late DateTime _fecha;
  TimeOfDay _hora = const TimeOfDay(hour: 15, minute: 0);
  bool _recordar = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    final datos = DatabaseService.cargarDatosCliente();
    _nombre.text = datos['nombre'] ?? '';
    _telefono.text = datos['telefono'] ?? '';
    _direccion.text = datos['direccion'] ?? '';
    final manana = DateTime.now().add(const Duration(days: 1));
    _fecha = DateTime(manana.year, manana.month, manana.day);
  }

  @override
  void dispose() {
    for (final c in [_nombre, _telefono, _direccion, _mensajePastel, _notas]) {
      c.dispose();
    }
    super.dispose();
  }

  DateTime get _fechaHora =>
      DateTime(_fecha.year, _fecha.month, _fecha.day, _hora.hour, _hora.minute);

  String? _textoOpcional(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();
    final escritorio = Breakpoints.esDesktop(context);
    final movil = Breakpoints.esMovil(context);

    if (carrito.items.isEmpty && !_enviando) {
      return Scaffold(
        appBar: AppBar(title: const Text('Realizar pedido')),
        body: EstadoVacio(
          icono: Icons.shopping_bag_outlined,
          titulo: 'Tu carrito está vacío',
          mensaje: 'Agrega algunos postres antes de hacer tu encargo.',
          accion: 'Ver el catálogo',
          onAccion: () => AppShell.irA(Seccion.catalogo),
        ),
      );
    }

    final formulario = Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Tarjeta(
            icono: Icons.person_outline_rounded,
            titulo: 'Tus datos',
            children: [
              TextFormField(
                controller: _nombre,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                decoration: const InputDecoration(
                    labelText: 'Nombre completo *',
                    prefixIcon: Icon(Icons.badge_outlined)),
                validator: (v) => (v == null || v.trim().length < 3)
                    ? 'Escribe tu nombre (mínimo 3 letras)'
                    : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _telefono,
                keyboardType: TextInputType.phone,
                autofillHints: const [AutofillHints.telephoneNumber],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))
                ],
                decoration: const InputDecoration(
                  labelText: 'Número de WhatsApp *',
                  hintText: '809-123-4567',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: (v) {
                  final digitos = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  if (digitos.length < 10)
                    return 'Escribe un número válido de 10 dígitos';
                  return null;
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Tarjeta(
            icono: Icons.local_shipping_outlined,
            titulo: 'Entrega',
            children: [
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                        value: _domicilio,
                        icon: Icon(Icons.home_outlined),
                        label: Text('A domicilio')),
                    ButtonSegment(
                        value: _recogida,
                        icon: Icon(Icons.storefront_outlined),
                        label: Text('Recoger')),
                  ],
                  selected: {_modalidad},
                  showSelectedIcon: false,
                  onSelectionChanged: (s) =>
                      setState(() => _modalidad = s.first),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.rosaFuerte,
                    selectedForegroundColor: Colors.white,
                    foregroundColor: AppColors.marron,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                child: _modalidad == _domicilio
                    ? Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: TextFormField(
                          controller: _direccion,
                          maxLines: 2,
                          autofillHints: const [
                            AutofillHints.fullStreetAddress
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Dirección de entrega *',
                            hintText: 'Calle, número, sector y ciudad',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: (v) => _modalidad == _domicilio &&
                                  (v == null || v.trim().length < 10)
                              ? 'Escribe una dirección completa'
                              : null,
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.only(top: 14),
                        child: _Aviso(
                          icono: Icons.storefront_outlined,
                          texto:
                              'Te enviaremos la ubicación para recoger por WhatsApp.',
                        ),
                      ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _Selector(
                      icono: Icons.calendar_month_outlined,
                      etiqueta: 'Fecha deseada',
                      valor: formatoFechaCorta(_fecha),
                      onTap: _elegirFecha,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _Selector(
                      icono: Icons.schedule_rounded,
                      etiqueta: 'Hora',
                      valor: formatoHora(_fechaHora),
                      onTap: _elegirHora,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const _Aviso(
                icono: Icons.info_outline_rounded,
                texto:
                    'Horario: 9:00 AM a 8:00 PM. Los pasteles personalizados necesitan al menos 24 horas.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Tarjeta(
            icono: Icons.cake_outlined,
            titulo: 'Detalles especiales',
            children: [
              TextFormField(
                controller: _mensajePastel,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Mensaje para el pastel (opcional)',
                  hintText: '"Feliz cumpleaños, Ana"',
                  prefixIcon: Icon(Icons.edit_outlined),
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _notas,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Indicaciones especiales (opcional)',
                  hintText: 'Alergias, colores, "llamar al llegar"…',
                  alignLabelWithHint: true,
                ),
              ),
              CheckboxListTile(
                value: _recordar,
                onChanged: (v) => setState(() => _recordar = v ?? true),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: AppColors.rosaFuerte,
                title: const Text('Recordar mis datos en este dispositivo',
                    style: TextStyle(fontSize: 14)),
              ),
            ],
          ),
        ],
      ),
    );

    final resumen = _ResumenLateral(
        carrito: carrito, onRevisar: _revisar, enviando: _enviando);

    return Scaffold(
      backgroundColor: AppColors.rosaClaro,
      appBar: AppBar(
        backgroundColor: AppColors.rosaClaro,
        title: const Text('Realizar pedido'),
        leading: IconButton(
          tooltip: 'Volver al carrito',
          icon:
              const Icon(Icons.arrow_back_rounded, color: AppColors.rosaFuerte),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 8, bottom: movil ? 24 : 40),
        child: ContenidoCentrado(
          maxWidth: 1120,
          child: escritorio
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: formulario),
                    const SizedBox(width: 28),
                    SizedBox(width: 380, child: resumen),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [formulario, const SizedBox(height: 16), resumen],
                ),
        ),
      ),
    );
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final f = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: hoy.add(const Duration(days: 60)),
      helpText: 'Fecha deseada de entrega',
    );
    if (f != null) setState(() => _fecha = f);
  }

  Future<void> _elegirHora() async {
    final h = await showTimePicker(
        context: context, initialTime: _hora, helpText: 'Hora de entrega');
    if (h == null || !mounted) return;
    final minutos = h.hour * 60 + h.minute;
    if (minutos < 9 * 60 || minutos > 20 * 60) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entregamos de 9:00 AM a 8:00 PM')));
      return;
    }
    setState(() => _hora = h);
  }

  void _revisar() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Revisa los campos marcados en rosa')));
      return;
    }
    if (_fechaHora.isBefore(DateTime.now().add(const Duration(hours: 2)))) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Elige una hora con al menos 2 horas de anticipación')));
      return;
    }
    _mostrarRevision();
  }

  Future<void> _mostrarRevision() async {
    final carrito = context.read<CarritoProvider>();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revisa tu encargo'),
        content: SizedBox(
          width: 460,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _FilaRevision('Cliente', _nombre.text.trim()),
                _FilaRevision('WhatsApp', _telefono.text.trim()),
                _FilaRevision('Modalidad', _modalidad),
                if (_modalidad == _domicilio)
                  _FilaRevision('Dirección', _direccion.text.trim()),
                _FilaRevision('Fecha', formatoFechaCompleta(_fechaHora)),
                if (_textoOpcional(_mensajePastel) != null)
                  _FilaRevision(
                      'En el pastel', '"${_mensajePastel.text.trim()}"'),
                if (_textoOpcional(_notas) != null)
                  _FilaRevision('Indicaciones', _notas.text.trim()),
                const Divider(height: 24),
                for (final i in carrito.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                            child:
                                Text('${i.cantidad} × ${i.producto.nombre}')),
                        Text(formatoPrecio(i.subtotal),
                            style:
                                const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                if (carrito.descuento > 0)
                  Row(children: [
                    Expanded(child: Text('Cupón ${carrito.cupon!.codigo}')),
                    Text('− ${formatoPrecio(carrito.descuento)}'),
                  ]),
                const SizedBox(height: 6),
                Row(children: [
                  const Expanded(
                      child: Text('Total',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 16))),
                  Text(formatoPrecio(carrito.totalAPagar, decimales: true),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: AppColors.rosaFuerte)),
                ]),
                const SizedBox(height: 14),
                const _Aviso(
                  icono: Icons.hourglass_top_rounded,
                  texto:
                      'Tu pedido aún NO está confirmado. Se confirma cuando Dulce Encargo te responda por WhatsApp. '
                      'No se realiza ningún pago en la app.',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Editar')),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.whatsapp),
            icon: const Icon(Icons.chat_rounded),
            label: const Text('Enviar por WhatsApp'),
          ),
        ],
      ),
    );
    if (confirmar == true) await _enviar();
  }

  Future<void> _enviar() async {
    final carrito = context.read<CarritoProvider>();
    setState(() => _enviando = true);
    try {
      if (_recordar) {
        await DatabaseService.guardarDatosCliente(
          nombre: _nombre.text.trim(),
          telefono: _telefono.text.trim(),
          direccion: _direccion.text.trim(),
        );
      }
      final pedido = await carrito.realizarPedido(
        nombreCliente: _nombre.text.trim(),
        telefono: _telefono.text.trim(),
        direccion:
            _modalidad == _domicilio ? _direccion.text.trim() : _recogida,
        fechaEntrega: _fechaHora,
        notas: _textoOpcional(_notas),
        modalidad: _modalidad,
        mensajePastel: _textoOpcional(_mensajePastel),
      );
      if (!mounted) return;
      await Contacto.abrirWhatsApp(context,
          mensaje: mensajePedidoWhatsApp(pedido));
      if (!mounted) return;
      await _mostrarEnviado(pedido);
    } catch (_) {
      if (!mounted) return;
      setState(() => _enviando = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No pudimos guardar tu pedido. Intenta de nuevo.')));
    }
  }

  Future<void> _mostrarEnviado(Pedido pedido) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: const BoxDecoration(
                  color: AppColors.rosaClaro, shape: BoxShape.circle),
              child: const Icon(Icons.favorite_rounded,
                  color: AppColors.rosaFuerte, size: 42),
            ),
            const SizedBox(height: 16),
            const Text('¡Encargo enviado!',
                style: TextStyle(
                    fontFamily: 'DancingScript',
                    fontWeight: FontWeight.w700,
                    fontSize: 38,
                    color: AppColors.rosaFuerte)),
            const SizedBox(height: 8),
            Text(
              'Pedido #${pedido.id.substring(pedido.id.length - 6)} guardado como pendiente de confirmación. '
              'Te escribiremos por WhatsApp para confirmarlo.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              AppShell.irA(Seccion.menu);
            },
            child: const Text('Volver al inicio'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              navegadorRaiz.currentState?.pushReplacementNamed('/historial');
            },
            child: const Text('Ver mis pedidos'),
          ),
        ],
      ),
    );
  }
}

class _ResumenLateral extends StatelessWidget {
  final CarritoProvider carrito;
  final VoidCallback onRevisar;
  final bool enviando;
  const _ResumenLateral(
      {required this.carrito, required this.onRevisar, required this.enviando});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppColors.rosa, borderRadius: BorderRadius.circular(26)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Tu encargo',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 18)),
          const SizedBox(height: 12),
          for (final i in carrito.items)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                        width: 44,
                        height: 44,
                        child: ProductoImagen(
                            src: i.producto.imagen, anchoDecodificado: 50)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('${i.cantidad} × ${i.producto.nombre}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: AppColors.marron)),
                  ),
                  Text(formatoPrecio(i.subtotal),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppColors.rosaFuerte)),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppColors.rosaFuerte,
                borderRadius: BorderRadius.circular(18)),
            child: Column(
              children: [
                if (carrito.descuento > 0)
                  Row(children: [
                    Expanded(
                        child: Text('Cupón ${carrito.cupon!.codigo}',
                            style: const TextStyle(color: Colors.white))),
                    Text('− ${formatoPrecio(carrito.descuento)}',
                        style: const TextStyle(color: Colors.white)),
                  ]),
                Row(children: [
                  const Expanded(
                      child: Text('Total:',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700))),
                  Text(formatoPrecio(carrito.totalAPagar, decimales: true),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: enviando ? null : onRevisar,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.rosaFuerte,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              icon: enviando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.fact_check_outlined),
              label: const Text('Revisar y confirmar'),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Sin pagos en línea: confirmamos y coordinamos el pago por WhatsApp.',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final List<Widget> children;
  const _Tarjeta(
      {required this.icono, required this.titulo, required this.children});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26), boxShadow: AppShadows.suave),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                        color: AppColors.rosaClaro, shape: BoxShape.circle),
                    child: Icon(icono, color: AppColors.rosaFuerte, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(titulo,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: AppColors.marron)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _Selector extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;
  final VoidCallback onTap;
  const _Selector(
      {required this.icono,
      required this.etiqueta,
      required this.valor,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.rosaClaro,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(icono, color: AppColors.rosaFuerte, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(etiqueta,
                        style: const TextStyle(
                            fontSize: 11.5, color: AppColors.gris)),
                    Text(valor,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.marron,
                            fontSize: 13.5)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Aviso extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _Aviso({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: AppColors.rosaClaro, borderRadius: BorderRadius.circular(14)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 18, color: AppColors.rosaFuerte),
          const SizedBox(width: 8),
          Expanded(
              child: Text(texto,
                  style: const TextStyle(
                      fontSize: 12.5, color: AppColors.marron, height: 1.4))),
        ],
      ),
    );
  }
}

class _FilaRevision extends StatelessWidget {
  final String a;
  final String b;
  const _FilaRevision(this.a, this.b);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 96,
              child: Text(a,
                  style: const TextStyle(color: AppColors.gris, fontSize: 13))),
          Expanded(
              child: Text(b,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13.5))),
        ],
      ),
    );
  }
}
