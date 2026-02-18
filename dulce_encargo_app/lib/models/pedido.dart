import 'producto.dart';

class ItemPedido {
  final Producto producto;
  final int cantidad;
  final String? personalizacion;

  ItemPedido({
    required this.producto,
    required this.cantidad,
    this.personalizacion,
  });

  double get subtotal => producto.precio * cantidad;

  Map<String, dynamic> toMap() {
    return {
      'producto': producto.toMap(),
      'cantidad': cantidad,
      'personalizacion': personalizacion,
    };
  }

  factory ItemPedido.fromMap(Map<String, dynamic> map) {
    return ItemPedido(
      producto: Producto.fromMap(map['producto']),
      cantidad: map['cantidad'],
      personalizacion: map['personalizacion'],
    );
  }
}

class Pedido {
  final String id;
  final List<ItemPedido> items;
  final String nombreCliente;
  final String telefono;
  final String direccion;
  final DateTime fechaPedido;
  final DateTime fechaEntrega;
  final String estado;
  final double total;
  final String? notas;

  Pedido({
    required this.id,
    required this.items,
    required this.nombreCliente,
    required this.telefono,
    required this.direccion,
    required this.fechaPedido,
    required this.fechaEntrega,
    required this.estado,
    required this.total,
    this.notas,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'items': items.map((item) => item.toMap()).toList(),
      'nombreCliente': nombreCliente,
      'telefono': telefono,
      'direccion': direccion,
      'fechaPedido': fechaPedido.toIso8601String(),
      'fechaEntrega': fechaEntrega.toIso8601String(),
      'estado': estado,
      'total': total,
      'notas': notas,
    };
  }

  factory Pedido.fromMap(Map<String, dynamic> map) {
    return Pedido(
      id: map['id'],
      items: (map['items'] as List)
          .map((item) => ItemPedido.fromMap(Map<String, dynamic>.from(item)))
          .toList(),
      nombreCliente: map['nombreCliente'],
      telefono: map['telefono'],
      direccion: map['direccion'],
      fechaPedido: DateTime.parse(map['fechaPedido']),
      fechaEntrega: DateTime.parse(map['fechaEntrega']),
      estado: map['estado'],
      total: map['total'].toDouble(),
      notas: map['notas'],
    );
  }
}