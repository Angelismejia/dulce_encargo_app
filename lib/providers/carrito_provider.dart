import 'package:flutter/material.dart';
import '../models/producto.dart';
import '../models/pedido.dart';
import '../services/database_services.dart';
import '../data/cupones.dart';
import '../utils/formato.dart';

class CarritoProvider with ChangeNotifier {
  List<ItemPedido> _items = [];
  List<Pedido> _historial = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  Set<String> _favoritos = {};
  Cupon? _cupon;

  List<ItemPedido> get items => _items;
  List<Pedido> get historial =>
      List.of(_historial)..sort((a, b) => b.fechaPedido.compareTo(a.fechaPedido));
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  int get itemCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  /// Subtotal del carrito (antes de descuentos).
  double get total => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  Cupon? get cupon => _cupon;
  double get descuento => _cupon?.descuentoPara(total) ?? 0;
  double get totalAPagar => total - descuento;

  Set<String> get favoritos => _favoritos;
  bool esFavorito(String productoId) => _favoritos.contains(productoId);

  Future<void> alternarFavorito(String productoId) async {
    if (!_favoritos.remove(productoId)) _favoritos.add(productoId);
    notifyListeners();
    await DatabaseService.guardarFavoritos(_favoritos);
  }

  /// Aplica un cupón. Devuelve un mensaje de error o `null` si se aplicó.
  String? aplicarCupon(String codigo) {
    final cupon = buscarCupon(codigo);
    if (cupon == null) return 'Ese cupón no existe';
    if (!cupon.aplicaA(total)) {
      return 'Este cupón aplica en pedidos desde ${formatoPrecio(cupon.minimo)}';
    }
    _cupon = cupon;
    notifyListeners();
    return null;
  }

  void quitarCupon() {
    _cupon = null;
    notifyListeners();
  }

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
      _favoritos = DatabaseService.cargarFavoritos();
      _isInitialized = true;

      debugPrint('✅ Provider inicializado: ${_items.length} items, ${_historial.length} pedidos');
    } catch (e) {
      debugPrint('❌ Error inicializando provider: $e');
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
      debugPrint('✅ Item agregado y guardado: ${producto.nombre} (${cantidad}x)');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error agregando item: $e');
      rethrow;
    }
  }

  Future<void> removerItem(int index) async {
    try {
      if (index < 0 || index >= _items.length) return;

      final producto = _items[index].producto.nombre;
      _items.removeAt(index);
      await DatabaseService.guardarCarrito(_items);
      debugPrint('✅ Item removido: $producto');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error removiendo item: $e');
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
        debugPrint('✅ Cantidad actualizada: ${_items[index].producto.nombre} -> $nuevaCantidad');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error actualizando cantidad: $e');
      rethrow;
    }
  }

  Future<void> limpiarCarrito() async {
    try {
      _items.clear();
      await DatabaseService.limpiarCarrito();
      debugPrint('✅ Carrito limpiado');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error limpiando carrito: $e');
      rethrow;
    }
  }

  /// Crea y guarda el pedido; devuelve el pedido creado.
  Future<Pedido> realizarPedido({
    required String nombreCliente,
    required String telefono,
    required String direccion,
    required DateTime fechaEntrega,
    String? notas,
    String modalidad = 'Entrega a domicilio',
    String? mensajePastel,
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
        total: totalAPagar,
        notas: notas,
        modalidad: modalidad,
        mensajePastel: mensajePastel,
        cupon: descuento > 0 ? _cupon?.codigo : null,
        descuento: descuento,
      );

      // Guardar pedido primero
      await DatabaseService.guardarPedido(pedido);

      // Agregar al historial local
      _historial.add(pedido);

      // Limpiar carrito después
      _cupon = null;
      await limpiarCarrito();

      // Forzar sincronización
      await DatabaseService.sincronizar();

      debugPrint('✅ Pedido realizado exitosamente: ${pedido.id}');
      notifyListeners();
      return pedido;
    } catch (e) {
      debugPrint('❌ Error realizando pedido: $e');
      rethrow;
    }
  }

  Future<void> eliminarPedido(String id) async {
    try {
      await DatabaseService.eliminarPedido(id);
      _historial.removeWhere((pedido) => pedido.id == id);
      await DatabaseService.sincronizar();
      debugPrint('✅ Pedido eliminado: $id');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Error eliminando pedido: $e');
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

      debugPrint('✅ Pedido duplicado: $pedidoId');
    } catch (e) {
      debugPrint('❌ Error duplicando pedido: $e');
      rethrow;
    }
  }

  // Método para actualizar estado de pedido (útil para admin)
  Future<void> actualizarEstadoPedido(String pedidoId, String nuevoEstado) async {
    try {
      final index = _historial.indexWhere((p) => p.id == pedidoId);
      if (index != -1) {
        final pedidoActualizado = _historial[index].copyWith(estado: nuevoEstado);

        _historial[index] = pedidoActualizado;
        await DatabaseService.guardarPedido(pedidoActualizado);
        await DatabaseService.sincronizar();
        debugPrint('✅ Estado actualizado: $pedidoId -> $nuevoEstado');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('❌ Error actualizando estado: $e');
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
      debugPrint('✅ Provider sincronizado');
    } catch (e) {
      debugPrint('❌ Error sincronizando provider: $e');
      rethrow;
    }
  }
}