import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/producto.dart';
import '../data/lista_productos.dart';
import '../widgets/producto_card.dart';
import '../providers/carrito_provider.dart';
import '../utils/colores.dart';

class CatalogoScreen extends StatefulWidget {
  @override
  _CatalogoScreenState createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  String categoriaSeleccionada = 'Todos';
  List<Producto> productos = [];
  List<Producto> productosFiltrados = [];

  @override
  void initState() {
    super.initState();
    productos = ListaProductos.obtenerProductos();
    productosFiltrados = productos;
  }

  void filtrarProductos(String categoria) {
    setState(() {
      categoriaSeleccionada = categoria;
      if (categoria == 'Todos') {
        productosFiltrados = productos;
      } else {
        productosFiltrados = productos.where((p) => p.categoria == categoria).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Catálogo de Productos'),
        actions: [
          Consumer<CarritoProvider>(
            builder: (context, carrito, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.pushNamed(context, '/carrito'),
                  ),
                  if (carrito.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${carrito.itemCount}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtros por categoría
          Container(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 10),
              children: ListaProductos.obtenerCategorias().map((categoria) {
                final isSelected = categoria == categoriaSeleccionada;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(categoria),
                    selected: isSelected,
                    onSelected: (selected) => filtrarProductos(categoria),
                    selectedColor: AppColors.accent,
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
          ),

          // Grid de productos
          Expanded(
            child: productosFiltrados.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cake,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay productos en esta categoría',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
                : GridView.builder(
              padding: EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: productosFiltrados.length,
              itemBuilder: (context, index) {
                return ProductoCard(
                  producto: productosFiltrados[index],
                  onAddToCart: () async {
                    await context.read<CarritoProvider>().agregarItem(
                      productosFiltrados[index],
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${productosFiltrados[index].nombre} agregado al carrito'),
                        duration: Duration(seconds: 2),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}