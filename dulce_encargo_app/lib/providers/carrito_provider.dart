import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/pedido.dart';
import '../services/database_services.dart';

class CarritoProvider with ChangeNotifier {
  List<ItemPedido> _items = [];
  List<Pedido> _historial = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<ItemPedido> get items => _items;
  List<Pedido> get historial => _historial..sort((a, b) => b.fechaPedido.compareTo(a.fechaPedido));
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  double get total => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  // Estadísticas generales
  int get totalPedidosRealizados => _historial.length;

  double get totalGastado => _historial.fold(0.0, (sum, pedido) => sum + pedido.total);

  List<Pedido> get pedidosPendientes => _historial.where((pedido) =>
  pedido.estado.toLowerCase() == 'pendiente').toList();

  // Inicializar datos desde la base de datos
  Future<void> inicializar() async {
    if (_isLoading) return; // Evitar múltiples inicializaciones simultáneas

    _isLoading = true;
    notifyListeners();

    try {
      // Verificar que Hive esté inicializado
      if (!await DatabaseService.verificarIntegridad()) {
        throw Exception('Base de datos no inicializada correctamente');
      }

      _items = DatabaseService.cargarCarrito();
      _historial = DatabaseService.cargarHistorial();
      _isInitialized = true;

      print('✅ Provider inicializado: ${_items.length} items, ${_historial.length} pedidos');
    } catch (e) {
      print('❌ Error inicializando provider: $e');
      _items = [];
      _historial = [];
      _isInitialized = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Recargar datos (útil para RefreshIndicator)
  Future<void> recargarDatos() async {
    _isInitialized = false;
    await inicializar();
  }

  Future<void> agregarItem(Producto producto, {int cantidad = 1, String? personalizacion}) async {
    if (!_isInitialized) {
      await inicializar();
    }

    try {
      final existingIndex = _items.indexWhere((item) =>
      item.producto.id == producto.id &&
          item.personalizacion == personalizacion);

      if (existingIndex >= 0) {
        _items[existingIndex] = ItemPedido(
          producto: producto,
          cantidad: _items[existingIndex].cantidad + cantidad,
          personalizacion: personalizacion,
        );
      } else {
        _items.add(ItemPedido(
          producto: producto,
          cantidad: cantidad,
          personalizacion: personalizacion,
        ));
      }

      await DatabaseService.guardarCarrito(_items);
      print('✅ Item agregado y guardado: ${producto.nombre} (${cantidad}x)');
      notifyListeners();
    } catch (e) {
      print('❌ Error agregando item: $e');
      rethrow;
    }
  }

  Future<void> removerItem(int index) async {
    try {
      if (index < 0 || index >= _items.length) return;

      final producto = _items[index].producto.nombre;
      _items.removeAt(index);
      await DatabaseService.guardarCarrito(_items);
      print('✅ Item removido: $producto');
      notifyListeners();
    } catch (e) {
      print('❌ Error removiendo item: $e');
      rethrow;
    }
  }

  Future<void> actualizarCantidad(int index, int nuevaCantidad) async {
    try {
      if (index < 0 || index >= _items.length) return;

      if (nuevaCantidad <= 0) {
        await removerItem(index);
      } else {
        _items[index] = ItemPedido(
          producto: _items[index].producto,
          cantidad: nuevaCantidad,
          personalizacion: _items[index].personalizacion,
        );
        await DatabaseService.guardarCarrito(_items);
        print('✅ Cantidad actualizada: ${_items[index].producto.nombre} -> ${nuevaCantidad}');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error actualizando cantidad: $e');
      rethrow;
    }
  }

  Future<void> limpiarCarrito() async {
    try {
      _items.clear();
      await DatabaseService.limpiarCarrito();
      print('✅ Carrito limpiado');
      notifyListeners();
    } catch (e) {
      print('❌ Error limpiando carrito: $e');
      rethrow;
    }
  }

  Future<void> realizarPedido({
    required String nombreCliente,
    required String telefono,
    required String direccion,
    required DateTime fechaEntrega,
    String? notas,
  }) async {
    if (_items.isEmpty) {
      throw Exception('El carrito está vacío');
    }

    try {
      final pedido = Pedido(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        items: List.from(_items),
        nombreCliente: nombreCliente,
        telefono: telefono,
        direccion: direccion,
        fechaPedido: DateTime.now(),
        fechaEntrega: fechaEntrega,
        estado: 'Pendiente',
        total: total,
        notas: notas,
      );

      // Guardar pedido primero
      await DatabaseService.guardarPedido(pedido);

      // Agregar al historial local
      _historial.add(pedido);

      // Limpiar carrito después
      await limpiarCarrito();

      // Forzar sincronización
      await DatabaseService.sincronizar();

      print('✅ Pedido realizado exitosamente: ${pedido.id}');
      notifyListeners();
    } catch (e) {
      print('❌ Error realizando pedido: $e');
      rethrow;
    }
  }

  Future<void> eliminarPedido(String id) async {
    try {
      await DatabaseService.eliminarPedido(id);
      _historial.removeWhere((pedido) => pedido.id == id);
      await DatabaseService.sincronizar();
      print('✅ Pedido eliminado: $id');
      notifyListeners();
    } catch (e) {
      print('❌ Error eliminando pedido: $e');
      rethrow;
    }
  }

  Future<void> duplicarPedido(String pedidoId) async {
    try {
      final pedido = _historial.firstWhere((p) => p.id == pedidoId);

      // Agregar todos los items del pedido al carrito actual
      for (final item in pedido.items) {
        await agregarItem(
          item.producto,
          cantidad: item.cantidad,
          personalizacion: item.personalizacion,
        );
      }

      print('✅ Pedido duplicado: $pedidoId');
    } catch (e) {
      print('❌ Error duplicando pedido: $e');
      rethrow;
    }
  }

  // Método para actualizar estado de pedido (útil para admin)
  Future<void> actualizarEstadoPedido(String pedidoId, String nuevoEstado) async {
    try {
      final index = _historial.indexWhere((p) => p.id == pedidoId);
      if (index != -1) {
        final pedidoActualizado = Pedido(
          id: _historial[index].id,
          items: _historial[index].items,
          nombreCliente: _historial[index].nombreCliente,
          telefono: _historial[index].telefono,
          direccion: _historial[index].direccion,
          fechaPedido: _historial[index].fechaPedido,
          fechaEntrega: _historial[index].fechaEntrega,
          estado: nuevoEstado,
          total: _historial[index].total,
          notas: _historial[index].notas,
        );

        _historial[index] = pedidoActualizado;
        await DatabaseService.guardarPedido(pedidoActualizado);
        await DatabaseService.sincronizar();
        print('✅ Estado actualizado: $pedidoId -> $nuevoEstado');
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error actualizando estado: $e');
      rethrow;
    }
  }

  // Estadísticas por estado
  Map<String, int> obtenerEstadisticasEstados() {
    final Map<String, int> estadisticas = {};

    for (final pedido in _historial) {
      final estado = pedido.estado;
      estadisticas[estado] = (estadisticas[estado] ?? 0) + 1;
    }

    return estadisticas;
  }

  // Productos más pedidos
  Map<String, int> obtenerProductosMasPedidos() {
    final Map<String, int> productos = {};

    for (final pedido in _historial) {
      for (final item in pedido.items) {
        final nombre = item.producto.nombre;
        productos[nombre] = (productos[nombre] ?? 0) + item.cantidad;
      }
    }

    return productos;
  }

  // Método para buscar pedidos
  List<Pedido> buscarPedidos(String query) {
    if (query.isEmpty) return historial;

    final queryLower = query.toLowerCase();
    return _historial.where((pedido) {
      return pedido.nombreCliente.toLowerCase().contains(queryLower) ||
          pedido.telefono.contains(query) ||
          pedido.id.contains(query) ||
          pedido.items.any((item) =>
              item.producto.nombre.toLowerCase().contains(queryLower));
    }).toList();
  }

  // Obtener pedidos por rango de fechas
  List<Pedido> obtenerPedidosPorFecha(DateTime desde, DateTime hasta) {
    return _historial.where((pedido) {
      return pedido.fechaPedido.isAfter(desde.subtract(Duration(days: 1))) &&
          pedido.fechaPedido.isBefore(hasta.add(Duration(days: 1)));
    }).toList();
  }

  // Obtener total de ventas por mes
  Map<String, double> obtenerVentasPorMes() {
    final Map<String, double> ventasPorMes = {};

    for (final pedido in _historial) {
      final key = '${pedido.fechaPedido.year}-${pedido.fechaPedido.month.toString().padLeft(2, '0')}';
      ventasPorMes[key] = (ventasPorMes[key] ?? 0) + pedido.total;
    }

    return ventasPorMes;
  }

  // Verificar si hay stock disponible
  bool verificarStock(Producto producto, int cantidadDeseada) {
    // Por ahora siempre retorna true, pero se puede implementar lógica de stock
    return producto.disponible;
  }

  // Obtener resumen de carrito
  Map<String, dynamic> obtenerResumenCarrito() {
    return {
      'cantidadItems': itemCount,
      'cantidadProductos': _items.length,
      'total': total,
      'productos': _items.map((item) => {
        'nombre': item.producto.nombre,
        'cantidad': item.cantidad,
        'subtotal': item.subtotal,
        'personalizacion': item.personalizacion,
      }).toList(),
    };
  }

  // Debug: Información del estado actual
  Map<String, dynamic> obtenerInfoDebug() {
    return {
      'items_carrito': _items.length,
      'total_carrito': total,
      'pedidos_historial': _historial.length,
      'total_gastado': totalGastado,
      'pedidos_pendientes': pedidosPendientes.length,
      'is_loading': _isLoading,
      'is_initialized': _isInitialized,
      'database_info': DatabaseService.obtenerInfoDebug(),
    };
  }

  // Método para forzar sincronización
  Future<void> sincronizar() async {
    try {
      await DatabaseService.sincronizar();
      print('✅ Provider sincronizado');
    } catch (e) {
      print('❌ Error sincronizando provider: $e');
      rethrow;
    }
  }
}