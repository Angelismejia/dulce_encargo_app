/// Formatea un monto en pesos dominicanos: `RD$ 1,250` o `RD$ 1,250.00`.
String formatoPrecio(double monto, {bool decimales = false}) {
  final centavos = (monto * 100).round();
  final entero = (decimales ? centavos ~/ 100 : monto.round()).toString();
  final buffer = StringBuffer();
  for (var i = 0; i < entero.length; i++) {
    if (i > 0 && (entero.length - i) % 3 == 0) buffer.write(',');
    buffer.write(entero[i]);
  }
  if (decimales) buffer.write('.${(centavos % 100).toString().padLeft(2, '0')}');
  return 'RD\$ $buffer';
}

const _meses = [
  'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
  'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
];

const _dias = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];

String formatoHora(DateTime fecha) {
  final h = fecha.hour % 12 == 0 ? 12 : fecha.hour % 12;
  final m = fecha.minute.toString().padLeft(2, '0');
  return '$h:$m ${fecha.hour < 12 ? 'AM' : 'PM'}';
}

/// `mar 14 oct`
String formatoFechaCorta(DateTime fecha) =>
    '${_dias[fecha.weekday - 1].substring(0, 3)} ${fecha.day} ${_meses[fecha.month - 1].substring(0, 3)}';

/// `martes 14 de octubre`
String formatoFechaLarga(DateTime fecha) =>
    '${_dias[fecha.weekday - 1]} ${fecha.day} de ${_meses[fecha.month - 1]}';

/// `14 de octubre 2025, 2:00 PM`
String formatoFechaCompleta(DateTime fecha) =>
    '${fecha.day} de ${_meses[fecha.month - 1]} ${fecha.year}, ${formatoHora(fecha)}';

/// `Hoy`, `Ayer`, `Hace 3 días` o `14/10/2025`.
String formatoFechaRelativa(DateTime fecha) {
  final hoy = DateTime.now();
  final dias = DateTime(hoy.year, hoy.month, hoy.day)
      .difference(DateTime(fecha.year, fecha.month, fecha.day))
      .inDays;
  if (dias == 0) return 'Hoy';
  if (dias == 1) return 'Ayer';
  if (dias < 7) return 'Hace $dias días';
  return '${fecha.day}/${fecha.month}/${fecha.year}';
}
