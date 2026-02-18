import 'package:hive_flutter/hive_flutter.dart';
import '../models/producto.dart';
import '../models/pedido.dart';

class DatabaseService {
  static const String _carritoBoxName = 'carrito';
  static const String _historialBoxName = 'historial';
  static const String _clienteBoxName = 'cliente';

  // Referencias a las cajas
  static Box? _carritoBoxRef;
  static Box? _historialBoxRef;
  static Box? _clienteBoxRef;

  static Future<void> initHive() async {
    try {
      await Hive.initFlutter();
      print('✅ Hive inicializado');

      // Abrir las cajas y mantener referencias
      _carritoBoxRef = await Hive.openBox(_carritoBoxName);
      _historialBoxRef = await Hive.openBox(_historialBoxName);
      _clienteBoxRef = await Hive.openBox(_clienteBoxName);

      print('✅ Cajas de Hive abiertas correctamente');
      print('- Carrito: ${_carritoBoxRef?.isOpen}');
      print('- Historial: ${_historialBoxRef?.isOpen}');
      print('- Cliente: ${_clienteBoxRef?.isOpen}');
    } catch (e) {
      print('❌ Error inicializando Hive: $e');
      rethrow;
    }
  }

  // Getters para las cajas con verificación
  static Box get carritoBox {
    if (_carritoBoxRef == null || !_carritoBoxRef!.isOpen) {
      throw Exception('Carrito box no está disponible');
    }
    return _carritoBoxRef!;
  }

  static Box get historialBox {
    if (_historialBoxRef == null || !_historialBoxRef!.isOpen) {
      throw Exception('Historial box no está disponible');
    }
    return _historialBoxRef!;
  }

  static Box get clienteBox {
    if (_clienteBoxRef == null || !_clienteBoxRef!.isOpen) {
      throw Exception('Cliente box no está disponible');
    }
    return _clienteBoxRef!;
  }

  // =================== MÉTODOS PARA EL CARRITO ===================

  static Future<void> guardarCarrito(List<ItemPedido> items) async {
    try {
      final box = carritoBox;

      // Convertir items a mapas serializables
      final itemsMap = items.map((item) => {
        'producto': {
          'id': item.producto.id,
          'nombre': item.producto.nombre,
          'descripcion': item.producto.descripcion,
          'precio': item.producto.precio,
          'imagen': item.producto.imagen,
          'categoria': item.producto.categoria,
          'disponible': item.producto.disponible,
        },
        'cantidad': item.cantidad,
        'personalizacion': item.personalizacion,
      }).toList();

      await box.put('items', itemsMap);
      await box.flush(); // Forzar escritura inmediata
      print('✅ Carrito guardado: ${items.length} items');
    } catch (e) {
      print('❌ Error guardando carrito: $e');
      rethrow;
    }
  }

  static List<ItemPedido> cargarCarrito() {
    try {
      final box = carritoBox;
      final data = box.get('items');

      if (data == null) {
        print('📝 Carrito vacío');
        return [];
      }

      final items = (data as List).map((itemData) {
        final productoData = itemData['producto'];
        final producto = Producto(
          id: productoData['id'],
          nombre: productoData['nombre'],
          descripcion: productoData['descripcion'],
          precio: (productoData['precio'] as num).toDouble(),
          imagen: productoData['imagen'],
          categoria: productoData['categoria'],
          disponible: productoData['disponible'] ?? true,
        );

        return ItemPedido(
          producto: producto,
          cantidad: itemData['cantidad'] as int,
          personalizacion: itemData['personalizacion'] as String?,
        );
      }).toList();

      print('✅ Carrito cargado: ${items.length} items');
      return items;
    } catch (e) {
      print('❌ Error cargando carrito: $e');
      return [];
    }
  }

  static Future<void> limpiarCarrito() async {
    try {
      final box = carritoBox;
      await box.delete('items');
      await box.flush();
      print('✅ Carrito limpiado');
    } catch (e) {
      print('❌ Error limpiando carrito: $e');
      rethrow;
    }
  }

  // =================== MÉTODOS PARA EL HISTORIAL ===================

  static Future<void> guardarPedido(Pedido pedido) async {
    try {
      final box = historialBox;

      final pedidoMap = {
        'id': pedido.id,
        'items': pedido.items.map((item) => {
          'producto': {
            'id': item.producto.id,
            'nombre': item.producto.nombre,
            'descripcion': item.producto.descripcion,
            'precio': item.producto.precio,
            'imagen': item.producto.imagen,
            'categoria': item.producto.categoria,
            'disponible': item.producto.disponible,
          },
          'cantidad': item.cantidad,
          'personalizacion': item.personalizacion,
        }).toList(),
        'nombreCliente': pedido.nombreCliente,
        'telefono': pedido.telefono,
        'direccion': pedido.direccion,
        'fechaPedido': pedido.fechaPedido.millisecondsSinceEpoch,
        'fechaEntrega': pedido.fechaEntrega.millisecondsSinceEpoch,
        'estado': pedido.estado,
        'total': pedido.total,
        'notas': pedido.notas,
      };

      await box.put(pedido.id, pedidoMap);
      await box.flush(); // Forzar escritura inmediata
      print('✅ Pedido guardado: ${pedido.id}');
    } catch (e) {
      print('❌ Error guardando pedido: $e');
      rethrow;
    }
  }

  static List<Pedido> cargarHistorial() {
    try {
      final box = historialBox;
      final List<Pedido> pedidos = [];

      for (var key in box.keys) {
        try {
          final data = box.get(key);
          if (data != null && data is Map) {
            final items = (data['items'] as List).map((itemData) {
              final productoData = itemData['producto'];
              final producto = Producto(
                id: productoData['id'],
                nombre: productoData['nombre'],
                descripcion: productoData['descripcion'],
                precio: (productoData['precio'] as num).toDouble(),
                imagen: productoData['imagen'],
                categoria: productoData['categoria'],
                disponible: productoData['disponible'] ?? true,
              );

              return ItemPedido(
                producto: producto,
                cantidad: itemData['cantidad'] as int,
                personalizacion: itemData['personalizacion'] as String?,
              );
            }).toList();

            final pedido = Pedido(
              id: data['id'],
              items: items,
              nombreCliente: data['nombreCliente'],
              telefono: data['telefono'],
              direccion: data['direccion'],
              fechaPedido: DateTime.fromMillisecondsSinceEpoch(data['fechaPedido']),
              fechaEntrega: DateTime.fromMillisecondsSinceEpoch(data['fechaEntrega']),
              estado: data['estado'],
              total: (data['total'] as num).toDouble(),
              notas: data['notas'] as String?,
            );

            pedidos.add(pedido);
          }
        } catch (e) {
          print('❌ Error cargando pedido con key $key: $e');
          // Eliminar entrada corrupta
          try {
            historialBox.delete(key);
            print('🗑️ Entrada corrupta eliminada: $key');
          } catch (deleteError) {
            print('❌ Error eliminando entrada corrupta: $deleteError');
          }
        }
      }

      print('✅ Historial cargado: ${pedidos.length} pedidos');
      return pedidos;
    } catch (e) {
      print('❌ Error cargando historial: $e');
      return [];
    }
  }

  static Future<void> eliminarPedido(String id) async {
    try {
      final box = historialBox;
      await box.delete(id);
      await box.flush();
      print('✅ Pedido eliminado: $id');
    } catch (e) {
      print('❌ Error eliminando pedido: $e');
      rethrow;
    }
  }

  // =================== MÉTODOS PARA DATOS DEL CLIENTE ===================

  static Future<void> guardarDatosCliente({
    required String nombre,
    required String telefono,
    required String direccion,
  }) async {
    try {
      final box = clienteBox;

      final datosCliente = {
        'nombre': nombre,
        'telefono': telefono,
        'direccion': direccion,
        'fechaActualizacion': DateTime.now().millisecondsSinceEpoch,
      };

      await box.put('datos_cliente', datosCliente);
      await box.flush();
      print('✅ Datos del cliente guardados');
    } catch (e) {
      print('❌ Error guardando datos del cliente: $e');
      rethrow;
    }
  }

  static Map<String, String> cargarDatosCliente() {
    try {
      final box = clienteBox;
      final data = box.get('datos_cliente');

      if (data == null) {
        print('📝 No hay datos del cliente guardados');
        return {
          'nombre': '',
          'telefono': '',
          'direccion': '',
        };
      }

      print('✅ Datos del cliente cargados');
      return {
        'nombre': data['nombre'] ?? '',
        'telefono': data['telefono'] ?? '',
        'direccion': data['direccion'] ?? '',
      };
    } catch (e) {
      print('❌ Error cargando datos del cliente: $e');
      return {
        'nombre': '',
        'telefono': '',
        'direccion': '',
      };
    }
  }

  static Future<void> limpiarDatosCliente() async {
    try {
      final box = clienteBox;
      await box.delete('datos_cliente');
      await box.flush();
      print('✅ Datos del cliente eliminados');
    } catch (e) {
      print('❌ Error eliminando datos del cliente: $e');
      rethrow;
    }
  }

  // =================== MÉTODOS DE UTILIDAD ===================

  static Future<void> limpiarTodo() async {
    try {
      await carritoBox.clear();
      await historialBox.clear();
      await clienteBox.clear();

      await carritoBox.flush();
      await historialBox.flush();
      await clienteBox.flush();

      print('✅ Toda la base de datos ha sido limpiada');
    } catch (e) {
      print('❌ Error limpiando la base de datos: $e');
      rethrow;
    }
  }

  // Obtener información de debug
  static Map<String, dynamic> obtenerInfoDebug() {
    try {
      return {
        'carrito': {
          'isOpen': _carritoBoxRef?.isOpen ?? false,
          'keys': _carritoBoxRef?.keys.toList() ?? [],
          'length': _carritoBoxRef?.length ?? 0,
          'path': _carritoBoxRef?.path,
        },
        'historial': {
          'isOpen': _historialBoxRef?.isOpen ?? false,
          'keys': _historialBoxRef?.keys.toList() ?? [],
          'length': _historialBoxRef?.length ?? 0,
          'path': _historialBoxRef?.path,
        },
        'cliente': {
          'isOpen': _clienteBoxRef?.isOpen ?? false,
          'keys': _clienteBoxRef?.keys.toList() ?? [],
          'length': _clienteBoxRef?.length ?? 0,
          'path': _clienteBoxRef?.path,
        },
      };
    } catch (e) {
      print('❌ Error obteniendo info de debug: $e');
      return {};
    }
  }

  // Hacer backup de los datos
  static Map<String, dynamic> hacerBackup() {
    try {
      return {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'carrito': carritoBox.toMap(),
        'historial': historialBox.toMap(),
        'cliente': clienteBox.toMap(),
      };
    } catch (e) {
      print('❌ Error haciendo backup: $e');
      return {};
    }
  }

  // Restaurar desde backup
  static Future<void> restaurarBackup(Map<String, dynamic> backup) async {
    try {
      await limpiarTodo();

      // Restaurar datos
      if (backup['carrito'] != null) {
        for (var entry in (backup['carrito'] as Map).entries) {
          await carritoBox.put(entry.key, entry.value);
        }
      }

      if (backup['historial'] != null) {
        for (var entry in (backup['historial'] as Map).entries) {
          await historialBox.put(entry.key, entry.value);
        }
      }

      if (backup['cliente'] != null) {
        for (var entry in (backup['cliente'] as Map).entries) {
          await clienteBox.put(entry.key, entry.value);
        }
      }

      await carritoBox.flush();
      await historialBox.flush();
      await clienteBox.flush();

      print('✅ Backup restaurado exitosamente');
    } catch (e) {
      print('❌ Error restaurando backup: $e');
      rethrow;
    }
  }

  // Verificar integridad de las cajas
  static Future<bool> verificarIntegridad() async {
    try {
      bool carritoOk = _carritoBoxRef != null && _carritoBoxRef!.isOpen;
      bool historialOk = _historialBoxRef != null && _historialBoxRef!.isOpen;
      bool clienteOk = _clienteBoxRef != null && _clienteBoxRef!.isOpen;

      print('🔍 Verificación de integridad:');
      print('- Carrito: ${carritoOk ? "✅" : "❌"}');
      print('- Historial: ${historialOk ? "✅" : "❌"}');
      print('- Cliente: ${clienteOk ? "✅" : "❌"}');

      return carritoOk && historialOk && clienteOk;
    } catch (e) {
      print('❌ Error verificando integridad: $e');
      return false;
    }
  }

  // Sincronizar datos (forzar escritura)
  static Future<void> sincronizar() async {
    try {
      await carritoBox.flush();
      await historialBox.flush();
      await clienteBox.flush();
      print('✅ Datos sincronizados');
    } catch (e) {
      print('❌ Error sincronizando datos: $e');
      rethrow;
    }
  }
}