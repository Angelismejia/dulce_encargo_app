import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';
import '../models/pedido.dart';
import '../utils/colores.dart';

class HistorialScreen extends StatefulWidget {
  @override
  _HistorialScreenState createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _filtroEstado = 'Todos';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mis Pedidos'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(icon: Icon(Icons.receipt_long), text: 'Pedidos'),
            Tab(icon: Icon(Icons.analytics), text: 'Estadísticas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPedidosTab(),
          _buildEstadisticasTab(),
        ],
      ),
    );
  }

  Widget _buildPedidosTab() {
    return Consumer<CarritoProvider>(
      builder: (context, carrito, child) {
        if (carrito.isLoading) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (carrito.historial.isEmpty) {
          return _buildEstadoVacio();
        }

        final pedidosFiltrados = _filtrarPedidos(carrito.historial);

        return Column(
          children: [
            _buildFiltrosEstado(carrito),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => carrito.recargarDatos(),
                color: AppColors.primary,
                child: ListView.builder(
                  padding: EdgeInsets.all(15),
                  itemCount: pedidosFiltrados.length,
                  itemBuilder: (context, index) {
                    return _buildPedidoCard(pedidosFiltrados[index], carrito);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 30),
          Text(
            'No tienes pedidos aún',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Cuando realices tu primer pedido\naparecerá aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/catalogo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            icon: Icon(Icons.shopping_bag, color: Colors.white),
            label: Text(
              'Hacer mi Primer Pedido',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltrosEstado(CarritoProvider carrito) {
    final estados = ['Todos', 'Pendiente', 'En Proceso', 'Listo', 'Entregado', 'Cancelado'];
    final estadisticas = carrito.obtenerEstadisticasEstados();

    return Container(
      height: 60,
      padding: EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 15),
        itemCount: estados.length,
        itemBuilder: (context, index) {
          final estado = estados[index];
          final cantidad = estado == 'Todos'
              ? carrito.historial.length
              : estadisticas[estado] ?? 0;
          final isSelected = estado == _filtroEstado;

          return Padding(
            padding: EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(estado),
                  if (cantidad > 0) ...[
                    SizedBox(width: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        cantidad.toString(),
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              selectedColor: AppColors.primary,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
              onSelected: (selected) {
                setState(() {
                  _filtroEstado = estado;
                });
              },
            ),
          );
        },
      ),
    );
  }

  List<Pedido> _filtrarPedidos(List<Pedido> pedidos) {
    if (_filtroEstado == 'Todos') return pedidos;
    return pedidos.where((p) => p.estado == _filtroEstado).toList();
  }

  Widget _buildPedidoCard(Pedido pedido, CarritoProvider carrito) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          // Header del pedido
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: _getEstadoColor(pedido.estado).withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pedido #${pedido.id.substring(pedido.id.length - 6)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _formatearFecha(pedido.fechaPedido),
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(pedido.estado),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pedido.estado,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Contenido del pedido
          Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información del cliente
                _buildInfoRow(Icons.person, pedido.nombreCliente),
                _buildInfoRow(Icons.phone, pedido.telefono),
                _buildInfoRow(Icons.location_on, pedido.direccion),

                SizedBox(height: 15),

                // Fecha de entrega
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: Colors.blue[700], size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Entrega: ${_formatearFechaCompleta(pedido.fechaEntrega)}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 15),

                // Lista de productos
                Text(
                  'Productos (${pedido.items.length}):',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),

                ...pedido.items.take(3).map((item) => _buildProductoItem(item)).toList(),

                if (pedido.items.length > 3)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '+ ${pedido.items.length - 3} productos más',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),

                if (pedido.notas != null) ...[
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.note, size: 16, color: Colors.grey[600]),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pedido.notas!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 15),

                // Total y acciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: RD\$ ${pedido.total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) => _handleMenuAction(value, pedido, carrito),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'ver_detalle',
                          child: Row(
                            children: [
                              Icon(Icons.visibility, size: 18),
                              SizedBox(width: 8),
                              Text('Ver Detalle'),
                            ],
                          ),
                        ),
                        if (pedido.estado.toLowerCase() == 'pendiente')
                          PopupMenuItem(
                            value: 'duplicar',
                            child: Row(
                              children: [
                                Icon(Icons.content_copy, size: 18),
                                SizedBox(width: 8),
                                Text('Pedir de Nuevo'),
                              ],
                            ),
                          ),
                        PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      child: Icon(Icons.more_vert, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textSecondary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductoItem(ItemPedido item) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              image: DecorationImage(
                image: NetworkImage(item.producto.imagen),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.cantidad}x ${item.producto.nombre}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (item.personalizacion != null)
                  Text(
                    item.personalizacion!,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            'RD\$ ${item.subtotal.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasTab() {
    return Consumer<CarritoProvider>(
      builder: (context, carrito, child) {
        if (carrito.historial.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.analytics_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 20),
                Text(
                  'Sin estadísticas aún',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                Text(
                  'Realiza algunos pedidos para ver tus estadísticas',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEstadisticasGenerales(carrito),
              SizedBox(height: 20),
              _buildEstadisticasEstados(carrito),
              SizedBox(height: 20),
              _buildProductosMasPedidos(carrito),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEstadisticasGenerales(CarritoProvider carrito) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen General',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaItem(
                    'Total Pedidos',
                    carrito.totalPedidosRealizados.toString(),
                    Icons.receipt_long,
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildEstadisticaItem(
                    'Total Gastado',
                    'RD\$ ${carrito.totalGastado.toStringAsFixed(0)}',
                    Icons.attach_money,
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildEstadisticaItem(
                    'Promedio por Pedido',
                    'RD\$ ${(carrito.totalGastado / carrito.totalPedidosRealizados).toStringAsFixed(0)}',
                    Icons.trending_up,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildEstadisticaItem(
                    'Pendientes',
                    carrito.pedidosPendientes.length.toString(),
                    Icons.pending,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEstadisticaItem(String titulo, String valor, IconData icono, Color color) {
    return Container(
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Icon(icono, color: color, size: 30),
          SizedBox(height: 8),
          Text(
            valor,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadisticasEstados(CarritoProvider carrito) {
    final estadisticas = carrito.obtenerEstadisticasEstados();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estados de Pedidos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 15),
            ...estadisticas.entries.map((entry) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getEstadoColor(entry.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(child: Text(entry.key)),
                  Text(
                    '${entry.value}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductosMasPedidos(CarritoProvider carrito) {
    final productos = carrito.obtenerProductosMasPedidos();
    final top5 = productos.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..take(5);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Productos Más Pedidos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 15),
            ...top5.take(5).toList().asMap().entries.map((entry) {
              final index = entry.key;
              final producto = entry.value;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        producto.key,
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Text(
                      '${producto.value} veces',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action, Pedido pedido, CarritoProvider carrito) {
    switch (action) {
      case 'ver_detalle':
        _mostrarDetallePedido(pedido);
        break;
      case 'duplicar':
        _duplicarPedido(pedido, carrito);
        break;
      case 'eliminar':
        _confirmarEliminarPedido(pedido, carrito);
        break;
    }
  }

  void _mostrarDetallePedido(Pedido pedido) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Detalle del Pedido #${pedido.id.substring(pedido.id.length - 6)}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildInfoRow(Icons.person, 'Cliente: ${pedido.nombreCliente}'),
                    _buildInfoRow(Icons.phone, 'Teléfono: ${pedido.telefono}'),
                    _buildInfoRow(Icons.location_on, 'Dirección: ${pedido.direccion}'),
                    _buildInfoRow(Icons.calendar_today, 'Fecha pedido: ${_formatearFechaCompleta(pedido.fechaPedido)}'),
                    _buildInfoRow(Icons.schedule, 'Fecha entrega: ${_formatearFechaCompleta(pedido.fechaEntrega)}'),

                    SizedBox(height: 20),
                    Text(
                      'Productos:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    ...pedido.items.map((item) => _buildProductoItem(item)).toList(),

                    if (pedido.notas != null) ...[
                      SizedBox(height: 20),
                      Text(
                        'Notas especiales:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(pedido.notas!),
                      ),
                    ],

                    SizedBox(height: 20),
                    Container(
                      padding: EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'RD\$ ${pedido.total.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _duplicarPedido(Pedido pedido, CarritoProvider carrito) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Pedir de Nuevo'),
        content: Text('¿Quieres agregar estos productos a tu carrito?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await carrito.duplicarPedido(pedido.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Productos agregados al carrito'),
                  backgroundColor: AppColors.success,
                  action: SnackBarAction(
                    label: 'Ver Carrito',
                    textColor: Colors.white,
                    onPressed: () => Navigator.pushNamed(context, '/carrito'),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Sí, Agregar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmarEliminarPedido(Pedido pedido, CarritoProvider carrito) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Pedido'),
        content: Text('¿Estás seguro de que quieres eliminar este pedido? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await carrito.eliminarPedido(pedido.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pedido eliminado'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return Colors.amber;
      case 'en proceso':
        return Colors.blue;
      case 'listo':
        return AppColors.success;
      case 'entregado':
        return Colors.green[700]!;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatearFecha(DateTime fecha) {
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fecha).inDays;

    if (diferencia == 0) {
      return 'Hoy';
    } else if (diferencia == 1) {
      return 'Ayer';
    } else if (diferencia < 7) {
      return 'Hace $diferencia días';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  String _formatearFechaCompleta(DateTime fecha) {
    final meses = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return '${fecha.day} de ${meses[fecha.month - 1]} ${fecha.year} a las ${fecha.hour.toString().padLeft(2, '0')}:${fecha.minute.toString().padLeft(2, '0')}';
  }
}