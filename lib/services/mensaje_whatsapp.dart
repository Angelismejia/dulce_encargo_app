import '../models/pedido.dart';
import '../utils/formato.dart';

/// Construye el mensaje estructurado que se envía al negocio por WhatsApp.
String mensajePedidoWhatsApp(Pedido p) {
  final b = StringBuffer()
    ..writeln('🍓 *Nuevo encargo — Dulce Encargo*')
    ..writeln('Pedido #${p.id.substring(p.id.length - 6)}')
    ..writeln()
    ..writeln('*Cliente:* ${p.nombreCliente}')
    ..writeln('*WhatsApp:* ${p.telefono}')
    ..writeln('*Modalidad:* ${p.modalidad}');
  if (!p.esRecogida) b.writeln('*Dirección:* ${p.direccion}');
  b
    ..writeln('*Fecha deseada:* ${formatoFechaCompleta(p.fechaEntrega)}')
    ..writeln()
    ..writeln('*Productos:*');
  for (final i in p.items) {
    b.writeln('• ${i.cantidad} × ${i.producto.nombre} — ${formatoPrecio(i.subtotal)}');
    if (i.personalizacion != null) b.writeln('   ✎ ${i.personalizacion}');
  }
  b.writeln();
  if (p.descuento > 0) {
    b
      ..writeln('Subtotal: ${formatoPrecio(p.subtotal)}')
      ..writeln('Cupón ${p.cupon}: −${formatoPrecio(p.descuento)}');
  }
  b.writeln('*Total: ${formatoPrecio(p.total, decimales: true)}*');
  if (p.mensajePastel != null) b..writeln()..writeln('*Mensaje en el pastel:* "${p.mensajePastel}"');
  if (p.notas != null) b..writeln()..writeln('*Indicaciones:* ${p.notas}');
  b
    ..writeln()
    ..write('Quedo atento/a a la confirmación. ¡Gracias! ♡');
  return b.toString();
}
