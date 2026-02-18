import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../providers/carrito_provider.dart';
import '../services/database_services.dart';
import '../models/producto.dart';
import '../models/pedido.dart';
import '../data/lista_productos.dart';

class DebugScreen extends StatefulWidget {
  @override
  _DebugScreenState createState() => _DebugScreenState();
}

class _DebugScreenState extends State<DebugScreen> {
  String _debugInfo = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _actualizarInfo();
  }

  void _actualizarInfo() {
    try {
      final carritoProvider = context.read<CarritoProvider>();
      final dbInfo = DatabaseService.obtenerInfoDebug();

      setState(() {
        _debugInfo = '''
🗃️ ESTADO DE LA BASE DE DATOS:

📦 Carrito Box:
- Está abierto: ${dbInfo['carrito']?['isOpen'] ?? 'N/A'}
- Keys: ${dbInfo['carrito']?['keys'] ?? []}
- Longitud: ${dbInfo['carrito']?['length'] ?? 0}
- Path: ${dbInfo['carrito']?['path'] ?? 'N/A'}

📋 Historial Box:
- Está abierto: ${dbInfo['historial']?['isOpen'] ?? 'N/A'}
- Keys: ${dbInfo['historial']?['keys'] ?? []}
- Longitud: ${dbInfo['historial']?['length'] ?? 0}
- Path: ${dbInfo['historial']?['path'] ?? 'N/A'}

👤 Cliente Box:
- Está abierto: ${dbInfo['cliente']?['isOpen'] ?? 'N/A'}
- Keys: ${dbInfo['cliente']?['keys'] ?? []}
- Longitud: ${dbInfo['cliente']?['length'] ?? 0}
- Path: ${dbInfo['cliente']?['path'] ?? 'N/A'}

🛒 Estado del Provider:
- Inicializado: ${carritoProvider.isInitialized}
- Items en carrito: ${carritoProvider.items.length}
- Pedidos en historial: ${carritoProvider.historial.length}
- Total carrito: RD\$ ${carritoProvider.total.toStringAsFixed(0)}
- Cargando: ${carritoProvider.isLoading}

💰 Estadísticas:
- Total pedidos: ${carritoProvider.totalPedidosRealizados}
- Total gastado: RD\$ ${carritoProvider.totalGastado.toStringAsFixed(0)}
- Pedidos pendientes: ${carritoProvider.pedidosPendientes.length}
      ''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error obteniendo información: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Debug - Base de Datos'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _actualizarInfo,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            SizedBox(height: 20),
            _buildActionsSection(),
            SizedBox(height: 20),
            _buildTestDataSection(),
            SizedBox(height: 20),
            _buildRawDataSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Información del Sistema',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              _debugInfo,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  'Acciones de Debug',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  'Recargar Provider',
                  Icons.refresh,
                  Colors.blue,
                  _recargarProvider,
                ),
                _buildActionButton(
                  'Verificar BD',
                  Icons.check_circle,
                  Colors.green,
                  _verificarBaseDatos,
                ),
                _buildActionButton(
                  'Sincronizar',
                  Icons.sync,
                  Colors.purple,
                  _sincronizar,
                ),
                _buildActionButton(
                  'Limpiar Carrito',
                  Icons.shopping_cart_outlined,
                  Colors.orange,
                  _limpiarCarrito,
                ),
                _buildActionButton(
                  'Limpiar BD',
                  Icons.delete_forever,
                  Colors.red,
                  _limpiarBaseDatos,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestDataSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.science, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Datos de Prueba',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildActionButton(
                  'Agregar Item Test',
                  Icons.add_shopping_cart,
                  Colors.blue,
                  _agregarItemPrueba,
                ),
                _buildActionButton(
                  'Crear Pedido Test',
                  Icons.receipt_long,
                  Colors.green,
                  _crearPedidoPrueba,
                ),
                _buildActionButton(
                  'Llenar con Datos',
                  Icons.dataset,
                  Colors.purple,
                  _llenarConDatosPrueba,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRawDataSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.data_object, color: Colors.grey[700]),
                SizedBox(width: 8),
                Text(
                  'Datos Raw',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            ExpansionTile(
              title: Text('Contenido Carrito Box'),
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getCarritoContent(),
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text('Contenido Historial Box'),
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _getHistorialContent(),
                    style: TextStyle(fontSize: 10, fontFamily: 'monospace'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
      String text,
      IconData icon,
      Color color,
      VoidCallback onPressed,
      ) {
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : onPressed,
      icon: Icon(icon, size: 16),
      label: Text(
        text,
        style: TextStyle(fontSize: 12),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  String _getCarritoContent() {
    try {
      final box = Hive.box('carrito');
      final items = box.get('items');
      return items?.toString() ?? 'Vacío';
    } catch (e) {
      return 'Error: $e';
    }
  }

  String _getHistorialContent() {
    try {
      final box = Hive.box('historial');
      final keys = box.keys.toList();
      if (keys.isEmpty) return 'Vacío';

      String content = '';
      for (var key in keys.take(3)) {
        content += 'Key: $key\n';
        content += 'Value: ${box.get(key)}\n';
        content += '---\n';
      }
      if (keys.length > 3) {
        content += '... y ${keys.length - 3} más';
      }
      return content;
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> _recargarProvider() async {
    setState(() => _isLoading = true);
    try {
      await context.read<CarritoProvider>().recargarDatos();
      _actualizarInfo();
      _showSnackBar('Provider recargado correctamente', Colors.green);
    } catch (e) {
      _showSnackBar('Error recargando: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verificarBaseDatos() async {
    setState(() => _isLoading = true);
    try {
      final isValid = await DatabaseService.verificarIntegridad();
      _actualizarInfo();
      _showSnackBar(
        isValid ? 'Base de datos OK' : 'Problemas en BD',
        isValid ? Colors.green : Colors.orange,
      );
    } catch (e) {
      _showSnackBar('Error verificando: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sincronizar() async {
    setState(() => _isLoading = true);
    try {
      await context.read<CarritoProvider>().sincronizar();
      _actualizarInfo();
      _showSnackBar('Datos sincronizados', Colors.green);
    } catch (e) {
      _showSnackBar('Error sincronizando: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _limpiarCarrito() async {
    setState(() => _isLoading = true);
    try {
      await context.read<CarritoProvider>().limpiarCarrito();
      _actualizarInfo();
      _showSnackBar('Carrito limpiado', Colors.orange);
    } catch (e) {
      _showSnackBar('Error limpiando carrito: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _limpiarBaseDatos() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar'),
        content: Text('¿Seguro que quieres limpiar toda la base de datos?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Sí, limpiar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        await DatabaseService.limpiarTodo();
        await context.read<CarritoProvider>().recargarDatos();
        _actualizarInfo();
        _showSnackBar('Base de datos limpiada', Colors.red);
      } catch (e) {
        _showSnackBar('Error limpiando BD: $e', Colors.red);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _agregarItemPrueba() async {
    setState(() => _isLoading = true);
    try {
      final productos = ListaProductos.obtenerProductos();
      if (productos.isNotEmpty) {
        await context.read<CarritoProvider>().agregarItem(productos.first);
        _actualizarInfo();
        _showSnackBar('Item de prueba agregado', Colors.green);
      }
    } catch (e) {
      _showSnackBar('Error agregando item: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _crearPedidoPrueba() async {
    final carrito = context.read<CarritoProvider>();
    if (carrito.items.isEmpty) {
      _showSnackBar('Agrega items al carrito primero', Colors.orange);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await carrito.realizarPedido(
        nombreCliente: 'Cliente Test',
        telefono: '809-123-4567',
        direccion: 'Dirección de prueba, Santo Domingo',
        fechaEntrega: DateTime.now().add(Duration(days: 1)),
        notas: 'Pedido de prueba generado desde debug',
      );
      _actualizarInfo();
      _showSnackBar('Pedido de prueba creado', Colors.green);
    } catch (e) {
      _showSnackBar('Error creando pedido: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _llenarConDatosPrueba() async {
    setState(() => _isLoading = true);
    try {
      final carrito = context.read<CarritoProvider>();
      final productos = ListaProductos.obtenerProductos();

      // Agregar algunos productos al carrito
      for (int i = 0; i < 3 && i < productos.length; i++) {
        await carrito.agregarItem(productos[i], cantidad: i + 1);
      }

      // Crear un pedido
      if (carrito.items.isNotEmpty) {
        await carrito.realizarPedido(
          nombreCliente: 'Juan Pérez',
          telefono: '809-555-0123',
          direccion: 'Av. Principal #123, Sector Los Prados, Santo Domingo',
          fechaEntrega: DateTime.now().add(Duration(days: 2)),
          notas: 'Favor confirmar por WhatsApp antes de entregar',
        );
      }

      // Agregar más items para otro pedido
      for (int i = 3; i < 5 && i < productos.length; i++) {
        await carrito.agregarItem(productos[i], cantidad: 2);
      }

      _actualizarInfo();
      _showSnackBar('Datos de prueba cargados', Colors.green);
    } catch (e) {
      _showSnackBar('Error cargando datos: $e', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: Duration(seconds: 2),
      ),
    );
  }
}