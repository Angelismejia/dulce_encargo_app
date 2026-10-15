import 'package:dulce_encargo_app/data/cupones.dart';
import 'package:dulce_encargo_app/data/lista_productos.dart';
import 'package:dulce_encargo_app/models/pedido.dart';
import 'package:dulce_encargo_app/screens/catalogo_screen.dart';
import 'package:dulce_encargo_app/services/mensaje_whatsapp.dart';
import 'package:dulce_encargo_app/utils/formato.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatoPrecio', () {
    test('agrega separador de miles', () {
      expect(formatoPrecio(85), r'RD$ 85');
      expect(formatoPrecio(1200), r'RD$ 1,200');
      expect(formatoPrecio(1234567), r'RD$ 1,234,567');
    });

    test('muestra centavos cuando se piden', () {
      expect(formatoPrecio(0, decimales: true), r'RD$ 0.00');
      expect(formatoPrecio(1350.5, decimales: true), r'RD$ 1,350.50');
    });
  });

  group('cupones', () {
    test('porcentaje y monto fijo', () {
      expect(buscarCupon('dulce10')!.descuentoPara(1000), 100);
      expect(buscarCupon('BIENVENIDA')!.descuentoPara(1000), 150);
    });

    test('respeta el mínimo de compra', () {
      expect(buscarCupon('BIENVENIDA')!.descuentoPara(500), 0);
      expect(buscarCupon('FIESTA15')!.aplicaA(2499), isFalse);
    });

    test('código inexistente', () => expect(buscarCupon('NOEXISTE'), isNull));
  });

  group('catálogo', () {
    test('todas las imágenes son assets locales', () {
      for (final p in ListaProductos.obtenerProductos()) {
        expect(p.imagen, startsWith('assets/images/productos/'), reason: p.nombre);
      }
    });

    test('ids únicos y cada producto tiene ocasión', () {
      final productos = ListaProductos.obtenerProductos();
      expect(productos.map((p) => p.id).toSet().length, productos.length);
      for (final p in productos) {
        expect(ListaProductos.ocasionesDe(p), isNotEmpty);
      }
    });

    test('la búsqueda ignora acentos', () {
      expect(normalizar('Crème Brûlée'), contains('creme'));
      expect(normalizar('Limón'), 'limon');
    });
  });

  test('mensaje de WhatsApp incluye todos los datos del pedido', () {
    final p = ListaProductos.buscarPorId('5')!;
    final pedido = Pedido(
      id: '1700000123456',
      items: [ItemPedido(producto: p, cantidad: 2, personalizacion: 'Sin canela')],
      nombreCliente: 'Ana Pérez',
      telefono: '8095551234',
      direccion: 'Calle El Conde 25',
      fechaPedido: DateTime(2026, 10, 15),
      fechaEntrega: DateTime(2026, 10, 17, 15),
      estado: 'Pendiente',
      total: 2700,
      descuento: 300,
      cupon: 'DULCE10',
      mensajePastel: 'Feliz cumple, Ana',
      notas: 'Llamar al llegar',
    );

    final m = mensajePedidoWhatsApp(pedido);
    expect(m, contains('Pedido #123456'));
    expect(m, contains('Ana Pérez'));
    expect(m, contains('Calle El Conde 25'));
    expect(m, contains('2 × Torta Tres Leches'));
    expect(m, contains('Sin canela'));
    expect(m, contains('Cupón DULCE10'));
    expect(m, contains(r'Total: RD$ 2,700.00'));
    expect(m, contains('Feliz cumple, Ana'));
    expect(m, contains('Llamar al llegar'));
  });

  test('pedido para recoger no incluye dirección', () {
    final pedido = Pedido(
      id: '1700000999999',
      items: [ItemPedido(producto: ListaProductos.buscarPorId('1')!, cantidad: 1)],
      nombreCliente: 'Luis',
      telefono: '8090000000',
      direccion: 'Recoger en tienda',
      fechaPedido: DateTime(2026, 10, 15),
      fechaEntrega: DateTime(2026, 10, 16, 10),
      estado: 'Pendiente',
      total: 85,
      modalidad: 'Recoger en tienda',
    );
    expect(mensajePedidoWhatsApp(pedido), isNot(contains('Dirección')));
  });
}
