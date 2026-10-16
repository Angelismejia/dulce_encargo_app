import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/lista_productos.dart';
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

  /// [path] permite usar un directorio propio (por ejemplo en pruebas).
  static Future<void> initHive({String? path}) async {
    try {
      if (path != null) {
        Hive.init(path);
      } else {
        await Hive.initFlutter();
      }
      debugPrint('✅ Hive inicializado');

      // Abrir las cajas y mantener referencias
      _carritoBoxRef = await Hive.openBox(_carritoBoxName);
      _historialBoxRef = await Hive.openBox(_historialBoxName);
      _clienteBoxRef = await Hive.openBox(_clienteBoxName);

      debugPrint('✅ Cajas de Hive abiertas correctamente');
      debugPrint('- Carrito: ${_carritoBoxRef?.isOpen}');
      debugPrint('- Historial: ${_historialBoxRef?.isOpen}');
      debugPrint('- Cliente: ${_clienteBoxRef?.isOpen}');
    } catch (e) {
      debugPrint('❌ Error inicializando Hive: $e');
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
      debugPrint('✅ Carrito guardado: ${items.length} items');
    } catch (e) {
      debugPrint('❌ Error guardando carrito: $e');
      rethrow;
    }
  }

  static List<ItemPedido> cargarCarrito() {
    try {
      final box = carritoBox;
      final data = box.get('items');

      if (data == null) {
        debugPrint('📝 Carrito vacío');
        return [];
      }

      final items = (data as List).map((itemData) {
        final productoData = itemData['producto'];
        final producto = Producto(
          id: productoData['id'],
          nombre: productoData['nombre'],
          descripcion: productoData['descripcion'],
          precio: (productoData['precio'] as num).toDouble(),
          // Las imágenes viven ahora en assets; se toma la del catálogo actual.
                imagen: ListaProductos.buscarPorId(productoData['id'])?.imagen ?? productoData['imagen'],
          categoria: productoData['categoria'],
          disponible: productoData['disponible'] ?? true,
        );

        return ItemPedido(
          producto: producto,
          cantidad: itemData['cantidad'] as int,
          personalizacion: itemData['personalizacion'] as String?,
        );
      }).toList();

      debugPrint('✅ Carrito cargado: ${items.length} items');
      return items;
    } catch (e) {
      debugPrint('❌ Error cargando carrito: $e');
      return [];
    }
  }

  static Future<void> limpiarCarrito() async {
    try {
      final box = carritoBox;
      await box.delete('items');
      await box.flush();
      debugPrint('✅ Carrito limpiado');
    } catch (e) {
      debugPrint('❌ Error limpiando carrito: $e');
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
        'modalidad': pedido.modalidad,
        'mensajePastel': pedido.mensajePastel,
        'cupon': pedido.cupon,
        'descuento': pedido.descuento,
      };

      await box.put(pedido.id, pedidoMap);
      await box.flush(); // Forzar escritura inmediata
      debugPrint('✅ Pedido guardado: ${pedido.id}');
    } catch (e) {
      debugPrint('❌ Error guardando pedido: $e');
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
                // Las imágenes viven ahora en assets; se toma la del catálogo actual.
                imagen: ListaProductos.buscarPorId(productoData['id'])?.imagen ?? productoData['imagen'],
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
              modalidad: data['modalidad'] as String? ?? 'Entrega a domicilio',
              mensajePastel: data['mensajePastel'] as String?,
              cupon: data['cupon'] as String?,
              descuento: (data['descuento'] as num? ?? 0).toDouble(),
            );

            pedidos.add(pedido);
          }
        } catch (e) {
          debugPrint('❌ Error cargando pedido con key $key: $e');
          // Eliminar entrada corrupta
          try {
            historialBox.delete(key);
            debugPrint('🗑️ Entrada corrupta eliminada: $key');
          } catch (deleteError) {
            debugPrint('❌ Error eliminando entrada corrupta: $deleteError');
          }
        }
      }

      debugPrint('✅ Historial cargado: ${pedidos.length} pedidos');
      return pedidos;
    } catch (e) {
      debugPrint('❌ Error cargando historial: $e');
      return [];
    }
  }

  static Future<void> eliminarPedido(String id) async {
    try {
      final box = historialBox;
      await box.delete(id);
      await box.flush();
      debugPrint('✅ Pedido eliminado: $id');
    } catch (e) {
      debugPrint('❌ Error eliminando pedido: $e');
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
      debugPrint('✅ Datos del cliente guardados');
    } catch (e) {
      debugPrint('❌ Error guardando datos del cliente: $e');
      rethrow;
    }
  }

  static Map<String, String> cargarDatosCliente() {
    try {
      final box = clienteBox;
      final data = box.get('datos_cliente');

      if (data == null) {
        debugPrint('📝 No hay datos del cliente guardados');
        return {
          'nombre': '',
          'telefono': '',
          'direccion': '',
        };
      }

      debugPrint('✅ Datos del cliente cargados');
      return {
        'nombre': data['nombre'] ?? '',
        'telefono': data['telefono'] ?? '',
        'direccion': data['direccion'] ?? '',
      };
    } catch (e) {
      debugPrint('❌ Error cargando datos del cliente: $e');
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
      debugPrint('✅ Datos del cliente eliminados');
    } catch (e) {
      debugPrint('❌ Error eliminando datos del cliente: $e');
      rethrow;
    }
  }

  // =================== FAVORITOS ===================

  static Set<String> cargarFavoritos() {
    try {
      final data = clienteBox.get('favoritos');
      if (data is List) return data.cast<String>().toSet();
    } catch (e) {
      debugPrint('❌ Error cargando favoritos: $e');
    }
    return {};
  }

  static Future<void> guardarFavoritos(Set<String> ids) async {
    try {
      await clienteBox.put('favoritos', ids.toList());
      await clienteBox.flush();
    } catch (e) {
      debugPrint('❌ Error guardando favoritos: $e');
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

      debugPrint('✅ Toda la base de datos ha sido limpiada');
    } catch (e) {
      debugPrint('❌ Error limpiando la base de datos: $e');
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
      debugPrint('❌ Error obteniendo info de debug: $e');
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
      debugPrint('❌ Error haciendo backup: $e');
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

      debugPrint('✅ Backup restaurado exitosamente');
    } catch (e) {
      debugPrint('❌ Error restaurando backup: $e');
      rethrow;
    }
  }

  // Verificar integridad de las cajas
  static Future<bool> verificarIntegridad() async {
    try {
      bool carritoOk = _carritoBoxRef != null && _carritoBoxRef!.isOpen;
      bool historialOk = _historialBoxRef != null && _historialBoxRef!.isOpen;
      bool clienteOk = _clienteBoxRef != null && _clienteBoxRef!.isOpen;

      debugPrint('🔍 Verificación de integridad:');
      debugPrint('- Carrito: ${carritoOk ? "✅" : "❌"}');
      debugPrint('- Historial: ${historialOk ? "✅" : "❌"}');
      debugPrint('- Cliente: ${clienteOk ? "✅" : "❌"}');

      return carritoOk && historialOk && clienteOk;
    } catch (e) {
      debugPrint('❌ Error verificando integridad: $e');
      return false;
    }
  }

  // Sincronizar datos (forzar escritura)
  static Future<void> sincronizar() async {
    try {
      await carritoBox.flush();
      await historialBox.flush();
      await clienteBox.flush();
      debugPrint('✅ Datos sincronizados');
    } catch (e) {
      debugPrint('❌ Error sincronizando datos: $e');
      rethrow;
    }
  }
}