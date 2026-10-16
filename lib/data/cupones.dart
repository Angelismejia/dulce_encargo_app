import '../utils/formato.dart';

class Cupon {
  final String codigo;
  final String titulo;
  final String descripcion;

  /// Si es porcentaje, [valor] va de 0 a 100; si no, es un monto fijo en RD$.
  final bool esPorcentaje;
  final double valor;
  final double minimo;

  const Cupon({
    required this.codigo,
    required this.titulo,
    required this.descripcion,
    required this.esPorcentaje,
    required this.valor,
    this.minimo = 0,
  });

  String get etiqueta => esPorcentaje ? '${valor.round()}%' : formatoPrecio(valor);

  bool aplicaA(double subtotal) => subtotal >= minimo;

  double descuentoPara(double subtotal) {
    if (!aplicaA(subtotal)) return 0;
    final d = esPorcentaje ? subtotal * valor / 100 : valor;
    return d > subtotal ? subtotal : d;
  }
}

const List<Cupon> cuponesDisponibles = [
  Cupon(
    codigo: 'BIENVENIDA',
    titulo: 'Tu primer antojo',
    descripcion: 'RD\$ 150 de descuento en pedidos desde RD\$ 800.',
    esPorcentaje: false,
    valor: 150,
    minimo: 800,
  ),
  Cupon(
    codigo: 'DULCE10',
    titulo: 'Dulce martes',
    descripcion: '10% de descuento en todo tu pedido.',
    esPorcentaje: true,
    valor: 10,
  ),
  Cupon(
    codigo: 'FIESTA15',
    titulo: 'Para celebrar en grande',
    descripcion: '15% de descuento en pedidos desde RD\$ 2,500.',
    esPorcentaje: true,
    valor: 15,
    minimo: 2500,
  ),
];

Cupon? buscarCupon(String codigo) {
  final c = codigo.trim().toUpperCase();
  for (final cupon in cuponesDisponibles) {
    if (cupon.codigo == c) return cupon;
  }
  return null;
}
