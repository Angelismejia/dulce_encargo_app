import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';
import '../screens/carrito_screen.dart';
import '../screens/catalogo_screen.dart';
import '../screens/cupones_screen.dart';
import '../screens/home_screen.dart';
import '../screens/perfil_screen.dart';
import '../utils/colores.dart';
import '../utils/responsive.dart';
import '../widgets/decoraciones.dart';
import '../widgets/encabezado.dart';

/// Navegador raíz de la app (para páginas que se abren encima del shell).
final GlobalKey<NavigatorState> navegadorRaiz = GlobalKey<NavigatorState>();

enum Seccion { menu, catalogo, cupones, carrito, perfil }

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  static final GlobalKey<AppShellState> clave = GlobalKey<AppShellState>();

  /// Navega a una sección desde cualquier parte de la app.
  static void irA(Seccion seccion, {String? ocasion, String? categoria, String? busqueda}) {
    clave.currentState?.ir(seccion, ocasion: ocasion, categoria: categoria, busqueda: busqueda);
  }

  @override
  State<AppShell> createState() => AppShellState();
}

class AppShellState extends State<AppShell> {
  final _menuNav = GlobalKey<NavigatorState>();
  int _indice = 0;
  bool _enCatalogo = false;

  void ir(Seccion seccion, {String? ocasion, String? categoria, String? busqueda}) {
    navegadorRaiz.currentState?.popUntil((r) => r.isFirst);
    switch (seccion) {
      case Seccion.menu:
        _menuNav.currentState?.popUntil((r) => r.isFirst);
        setState(() {
          _indice = 0;
          _enCatalogo = false;
        });
      case Seccion.catalogo:
        CatalogoScreen.filtro.value = FiltroCatalogo(
          ocasion: ocasion,
          categoria: categoria,
          busqueda: busqueda,
        );
        setState(() {
          _indice = 0;
          _enCatalogo = true;
        });
        final nav = _menuNav.currentState;
        if (nav != null) {
          nav.popUntil((r) => r.isFirst);
          nav.pushNamed('/catalogo');
        }
      case Seccion.cupones:
        setState(() => _indice = 1);
      case Seccion.carrito:
        setState(() => _indice = 2);
      case Seccion.perfil:
        setState(() => _indice = 3);
    }
  }

  Seccion get _seccionActual => switch (_indice) {
        0 => _enCatalogo ? Seccion.catalogo : Seccion.menu,
        1 => Seccion.cupones,
        2 => Seccion.carrito,
        _ => Seccion.perfil,
      };

  void _alVolver() {
    final nav = _menuNav.currentState;
    if (_indice == 0 && nav != null && nav.canPop()) {
      nav.pop();
      setState(() => _enCatalogo = false);
    } else if (_indice != 0) {
      setState(() => _indice = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ancho = !Breakpoints.esMovil(context);
    final cantidad = context.select<CarritoProvider, int>((c) => c.itemCount);

    final pestanas = IndexedStack(
      index: _indice,
      children: [
        HeroControllerScope(
          controller: MaterialApp.createMaterialHeroController(),
          child: Navigator(
            key: _menuNav,
            onGenerateRoute: (settings) {
              final pagina = settings.name == '/catalogo' ? const CatalogoScreen() : const HomeScreen();
              return PageRouteBuilder(
                settings: settings,
                transitionDuration: const Duration(milliseconds: 320),
                pageBuilder: (_, __, ___) => pagina,
                transitionsBuilder: (_, anim, __, child) => FadeTransition(
                  opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                  child: SlideTransition(
                    position: Tween(begin: const Offset(0, 0.02), end: Offset.zero).animate(anim),
                    child: child,
                  ),
                ),
              );
            },
          ),
        ),
        const CuponesScreen(),
        const CarritoScreen(),
        const PerfilScreen(),
      ],
    );

    return PopScope(
      canPop: _indice == 0 && !_enCatalogo,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _alVolver();
      },
      child: Scaffold(
        backgroundColor: AppColors.blanco,
        body: ancho
            ? Column(
                children: [
                  BarraSuperior(seccion: _seccionActual, cantidadCarrito: cantidad),
                  Expanded(child: pestanas),
                ],
              )
            : pestanas,
        bottomNavigationBar: ancho
            ? null
            : _NavegacionInferior(
                indice: _indice,
                cantidadCarrito: cantidad,
                onCambio: (i) {
                  if (i == 0 && _indice == 0) {
                    ir(Seccion.menu);
                  } else {
                    setState(() => _indice = i);
                  }
                },
              ),
      ),
    );
  }
}

class _NavegacionInferior extends StatelessWidget {
  final int indice;
  final int cantidadCarrito;
  final ValueChanged<int> onCambio;

  const _NavegacionInferior({required this.indice, required this.cantidadCarrito, required this.onCambio});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: AppColors.rosaFuerte.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, -4)),
        ],
      ),
      child: NavigationBar(
        selectedIndex: indice,
        onDestinationSelected: onCambio,
        animationDuration: const Duration(milliseconds: 400),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront_rounded),
            label: 'Menú',
          ),
          const NavigationDestination(
            icon: Icon(Icons.local_offer_outlined),
            selectedIcon: Icon(Icons.local_offer_rounded),
            label: 'Cupones',
          ),
          NavigationDestination(
            icon: _IconoCarrito(cantidad: cantidadCarrito, activo: false),
            selectedIcon: _IconoCarrito(cantidad: cantidadCarrito, activo: true),
            label: 'Carrito',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

class _IconoCarrito extends StatelessWidget {
  final int cantidad;
  final bool activo;
  const _IconoCarrito({required this.cantidad, required this.activo});

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: cantidad > 0,
      backgroundColor: AppColors.rosaFuerte,
      label: Text(cantidad > 99 ? '99+' : '$cantidad'),
      child: Icon(activo ? Icons.shopping_bag_rounded : Icons.shopping_bag_outlined),
    );
  }
}

/// Barra superior para tablet y escritorio.
class BarraSuperior extends StatelessWidget {
  final Seccion seccion;
  final int cantidadCarrito;

  const BarraSuperior({super.key, required this.seccion, required this.cantidadCarrito});

  @override
  Widget build(BuildContext context) {
    final escritorio = Breakpoints.esDesktop(context);

    Widget enlace(String texto, Seccion destino) {
      final activo = seccion == destino;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TextButton(
          onPressed: () => AppShell.irA(destino),
          style: TextButton.styleFrom(
            foregroundColor: activo ? AppColors.rosaFuerte : AppColors.marron,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(texto, style: TextStyle(fontWeight: activo ? FontWeight.w700 : FontWeight.w500)),
              const SizedBox(height: 4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                height: 3,
                width: activo ? 22 : 0,
                decoration: BoxDecoration(color: AppColors.rosa, borderRadius: BorderRadius.circular(2)),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      color: AppColors.rosaClaro,
      child: SafeArea(
        bottom: false,
        child: ContenidoCentrado(
          maxWidth: 1320,
          child: SizedBox(
            height: 76,
            child: Row(
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => AppShell.irA(Seccion.menu),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    child: LogoDulceEncargo(tamano: 32),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: BarraBusqueda(
                      onBuscar: (q) => AppShell.irA(Seccion.catalogo, busqueda: q),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                if (escritorio) ...[
                  enlace('Inicio', Seccion.menu),
                  enlace('Catálogo', Seccion.catalogo),
                  enlace('Cupones', Seccion.cupones),
                  enlace('Perfil', Seccion.perfil),
                ] else ...[
                  IconButton(
                    tooltip: 'Catálogo',
                    onPressed: () => AppShell.irA(Seccion.catalogo),
                    icon: const Icon(Icons.storefront_outlined, color: AppColors.rosaFuerte),
                  ),
                  IconButton(
                    tooltip: 'Cupones',
                    onPressed: () => AppShell.irA(Seccion.cupones),
                    icon: const Icon(Icons.local_offer_outlined, color: AppColors.rosaFuerte),
                  ),
                  IconButton(
                    tooltip: 'Perfil',
                    onPressed: () => AppShell.irA(Seccion.perfil),
                    icon: const Icon(Icons.person_outline_rounded, color: AppColors.rosaFuerte),
                  ),
                ],
                const SizedBox(width: 8),
                BotonCarrito(cantidad: cantidadCarrito, activo: seccion == Seccion.carrito),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
