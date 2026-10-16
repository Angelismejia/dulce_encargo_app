import 'package:flutter/material.dart';
import '../data/lista_productos.dart';
import '../models/producto.dart';
import '../navigation/app_shell.dart';
import '../utils/colores.dart';
import '../utils/responsive.dart';
import '../widgets/categorias.dart';
import '../widgets/comunes.dart';
import '../widgets/encabezado.dart';
import '../widgets/producto_card.dart';
import '../widgets/producto_detalle.dart';

class FiltroCatalogo {
  final String? ocasion;
  final String? categoria;
  final String? busqueda;
  const FiltroCatalogo({this.ocasion, this.categoria, this.busqueda});
}

/// Quita acentos y pasa a minúsculas para comparar búsquedas.
String normalizar(String s) {
  const de = 'áéíóúüñàèìòùâêîôûäëïöç';
  const a = 'aeiouunaeiouaeiouaeioc';
  final b = StringBuffer();
  for (final ch in s.toLowerCase().split('')) {
    final i = de.indexOf(ch);
    b.write(i >= 0 ? a[i] : ch);
  }
  return b.toString();
}

class CatalogoScreen extends StatefulWidget {
  const CatalogoScreen({super.key});

  /// Filtro solicitado desde otras pantallas (inicio, búsqueda, etc.).
  static final ValueNotifier<FiltroCatalogo> filtro = ValueNotifier(const FiltroCatalogo());

  @override
  State<CatalogoScreen> createState() => _CatalogoScreenState();
}

class _CatalogoScreenState extends State<CatalogoScreen> {
  final List<Producto> _productos = ListaProductos.obtenerProductos();
  String? _ocasion;
  String _categoria = 'Todos';
  String _busqueda = '';

  @override
  void initState() {
    super.initState();
    _aplicarFiltroExterno();
    CatalogoScreen.filtro.addListener(_aplicarFiltroExterno);
  }

  @override
  void dispose() {
    CatalogoScreen.filtro.removeListener(_aplicarFiltroExterno);
    super.dispose();
  }

  void _aplicarFiltroExterno() {
    final f = CatalogoScreen.filtro.value;
    setState(() {
      _ocasion = f.ocasion;
      _categoria = f.categoria ?? 'Todos';
      _busqueda = f.busqueda ?? '';
    });
  }

  List<Producto> get _filtrados {
    final q = normalizar(_busqueda.trim());
    return _productos.where((p) {
      if (_ocasion != null && !ListaProductos.ocasionesDe(p).contains(_ocasion)) return false;
      if (_categoria != 'Todos' && p.categoria != _categoria) return false;
      if (q.isNotEmpty &&
          !normalizar('${p.nombre} ${p.descripcion} ${p.categoria}').contains(q)) {
        return false;
      }
      return true;
    }).toList();
  }

  void _limpiar() => setState(() {
        _ocasion = null;
        _categoria = 'Todos';
        _busqueda = '';
      });

  @override
  Widget build(BuildContext context) {
    final movil = Breakpoints.esMovil(context);
    final escritorio = Breakpoints.esDesktop(context);
    final productos = _filtrados;
    final claveFiltro = '$_ocasion|$_categoria|$_busqueda';

    final circulos = SizedBox(
      height: movil ? 96 : 118,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: movil ? 8 : 0),
        children: [
          for (final o in [null, ...ListaProductos.ocasiones])
            Padding(
              padding: EdgeInsets.symmetric(horizontal: movil ? 2 : 10),
              child: CirculoCategoria(
                etiqueta: o ?? 'Todos',
                diametro: movil ? 58 : 76,
                seleccionado: _ocasion == o,
                onTap: () => setState(() => _ocasion = o),
              ),
            ),
        ],
      ),
    );

    final chips = SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: movil ? 16 : 0),
        itemCount: ListaProductos.obtenerCategorias().length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _ChipCategoria(
          categoria: ListaProductos.obtenerCategorias()[i],
          seleccionada: _categoria == ListaProductos.obtenerCategorias()[i],
          onTap: () => setState(() => _categoria = ListaProductos.obtenerCategorias()[i]),
        ),
      ),
    );

    final resultados = AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOut,
      child: KeyedSubtree(
        key: ValueKey(claveFiltro),
        child: productos.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: EstadoVacio(
                  icono: Icons.search_off_rounded,
                  titulo: 'No encontramos ese antojo',
                  mensaje: 'Prueba con otra palabra o quita algunos filtros.',
                  accion: 'Ver todo el catálogo',
                  onAccion: _limpiar,
                ),
              )
            : CuadriculaProductos(
                productos: productos,
                onAgregar: (p) => agregarAlCarrito(context, p),
                onVer: (p) => mostrarDetalleProducto(context, p),
              ),
      ),
    );

    final contador = Text(
      '${productos.length} ${productos.length == 1 ? 'postre' : 'postres'}'
      '${_ocasion != null ? ' para $_ocasion' : ''}',
      style: const TextStyle(color: AppColors.gris, fontSize: 13),
    );

    if (escritorio) {
      return Scaffold(
        backgroundColor: AppColors.blanco,
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: ContenidoCentrado(
            maxWidth: 1320,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nuestro catálogo',
                    style: TextStyle(fontFamily: 'DancingScript', fontWeight: FontWeight.w700, fontSize: 48, color: AppColors.rosaFuerte)),
                const SizedBox(height: 12),
                circulos,
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 240,
                      child: _PanelFiltros(
                        busqueda: _busqueda,
                        onBusqueda: (v) => setState(() => _busqueda = v),
                        categoria: _categoria,
                        onCategoria: (c) => setState(() => _categoria = c),
                        onLimpiar: _limpiar,
                      ),
                    ),
                    const SizedBox(width: 36),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [contador, const SizedBox(height: 16), resultados],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.blanco,
      appBar: movil
          ? AppBar(
              backgroundColor: AppColors.blanco,
              leading: IconButton(
                tooltip: 'Volver al inicio',
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.rosaFuerte),
                onPressed: () => AppShell.irA(Seccion.menu),
              ),
              title: const Text('Catálogo'),
            )
          : null,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(movil ? 16 : 28, movil ? 4 : 24, movil ? 16 : 28, 8),
              child: BarraBusqueda(
                valorInicial: _busqueda,
                onBuscar: (v) => setState(() => _busqueda = v),
                onCambio: (v) => setState(() => _busqueda = v),
              ),
            ),
          ),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.only(top: 8), child: circulos)),
          SliverToBoxAdapter(child: Padding(padding: EdgeInsets.symmetric(horizontal: movil ? 0 : 28), child: chips)),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(movil ? 16 : 28, 16, movil ? 16 : 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [contador, const SizedBox(height: 14), resultados],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipCategoria extends StatelessWidget {
  final String categoria;
  final bool seleccionada;
  final VoidCallback onTap;
  const _ChipCategoria({required this.categoria, required this.seleccionada, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(categoria),
      selected: seleccionada,
      onSelected: (_) => onTap(),
      labelStyle: TextStyle(
        color: seleccionada ? Colors.white : AppColors.marron,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      backgroundColor: AppColors.rosaClaro,
      selectedColor: AppColors.rosaFuerte,
      side: BorderSide.none,
    );
  }
}

class _PanelFiltros extends StatelessWidget {
  final String busqueda;
  final ValueChanged<String> onBusqueda;
  final String categoria;
  final ValueChanged<String> onCategoria;
  final VoidCallback onLimpiar;

  const _PanelFiltros({
    required this.busqueda,
    required this.onBusqueda,
    required this.categoria,
    required this.onCategoria,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: AppColors.rosaClaro, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarraBusqueda(valorInicial: busqueda, onBuscar: onBusqueda, onCambio: onBusqueda),
          const SizedBox(height: 18),
          const Padding(
            padding: EdgeInsets.only(left: 6, bottom: 6),
            child: Text('Categorías', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.marron)),
          ),
          for (final c in ListaProductos.obtenerCategorias())
            _ItemFiltro(texto: c, activo: c == categoria, onTap: () => onCategoria(c)),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: onLimpiar,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Limpiar filtros'),
          ),
        ],
      ),
    );
  }
}

class _ItemFiltro extends StatelessWidget {
  final String texto;
  final bool activo;
  final VoidCallback onTap;
  const _ItemFiltro({required this.texto, required this.activo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: activo ? AppColors.rosaFuerte : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Text(
              texto,
              style: TextStyle(
                color: activo ? Colors.white : AppColors.marron,
                fontWeight: activo ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
