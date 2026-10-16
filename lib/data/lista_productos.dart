import '../models/producto.dart';

class ListaProductos {
  static List<Producto> obtenerProductos() {
    return [
      // Cupcakes
      Producto(
        id: '1',
        nombre: 'Cupcake de Vainilla',
        descripcion: 'Delicioso cupcake de vainilla con frosting de mantequilla',
        precio: 85.0,
        imagen: 'assets/images/productos/cupcake_vainilla.jpg',
        categoria: 'Cupcakes',
      ),
      Producto(
        id: '2',
        nombre: 'Cupcake de Chocolate',
        descripcion: 'Rico cupcake de chocolate con crema de chocolate',
        precio: 90.0,
        imagen: 'assets/images/productos/cupcake_chocolate.jpg',
        categoria: 'Cupcakes',
      ),
      Producto(
        id: '3',
        nombre: 'Cupcake Red Velvet',
        descripcion: 'Clásico red velvet con cream cheese frosting',
        precio: 100.0,
        imagen: 'assets/images/productos/cupcake_red_velvet.jpg',
        categoria: 'Cupcakes',
      ),
      Producto(
        id: '16',
        nombre: 'Cupcake de Limón',
        descripcion: 'Fresco cupcake de limón con frosting cítrico',
        precio: 95.0,
        imagen: 'assets/images/productos/cupcake_limon.jpg',
        categoria: 'Cupcakes',
      ),
      Producto(
        id: '17',
        nombre: 'Cupcake de Fresa',
        descripcion: 'Cupcake de fresa con crema rosada y decoración',
        precio: 105.0,
        imagen: 'assets/images/productos/cupcake_fresa.jpg',
        categoria: 'Cupcakes',
      ),
      Producto(
        id: '18',
        nombre: 'Cupcake de Nutella',
        descripcion: 'Cupcake relleno de Nutella con frosting de avellana',
        precio: 110.0,
        imagen: 'assets/images/productos/cupcake_nutella.jpg',
        categoria: 'Cupcakes',
      ),
      Producto(
        id: '19',
        nombre: 'Cupcake de Café',
        descripcion: 'Cupcake con sabor a café y frosting de moca',
        precio: 100.0,
        imagen: 'assets/images/productos/cupcake_cafe.jpg',
        categoria: 'Cupcakes',
      ),

      // Bizcochos/Tortas
      Producto(
        id: '4',
        nombre: 'Bizcocho de Cumpleaños',
        descripcion: 'Bizcocho personalizado de vainilla con decoración especial',
        precio: 1200.0,
        imagen: 'assets/images/productos/bizcocho_cumpleanos.jpg',
        categoria: 'Bizcochos',
      ),
      Producto(
        id: '5',
        nombre: 'Torta Tres Leches',
        descripcion: 'Tradicional tres leches dominicana con canela',
        precio: 1500.0,
        imagen: 'assets/images/productos/torta_tres_leches.jpg',
        categoria: 'Bizcochos',
      ),
      Producto(
        id: '6',
        nombre: 'Bizcocho de Chocolate',
        descripcion: 'Húmedo bizcocho de chocolate con ganache',
        precio: 1350.0,
        imagen: 'assets/images/productos/bizcocho_chocolate.jpg',
        categoria: 'Bizcochos',
      ),
      Producto(
        id: '20',
        nombre: 'Torta de Zanahoria',
        descripcion: 'Esponjosa torta de zanahoria con frosting de queso crema',
        precio: 1400.0,
        imagen: 'assets/images/productos/torta_zanahoria.jpg',
        categoria: 'Bizcochos',
      ),
      Producto(
        id: '21',
        nombre: 'Torta de Piña',
        descripcion: 'Torta tropical de piña con crema de coco',
        precio: 1300.0,
        imagen: 'assets/images/productos/torta_pina.jpg',
        categoria: 'Bizcochos',
      ),
      Producto(
        id: '22',
        nombre: 'Torta de Boda',
        descripcion: 'Elegante torta de varios pisos para bodas',
        precio: 3500.0,
        imagen: 'assets/images/productos/torta_boda.jpg',
        categoria: 'Bizcochos',
      ),
      Producto(
        id: '23',
        nombre: 'Torta Selva Negra',
        descripcion: 'Clásica torta alemana con cerezas y crema',
        precio: 1600.0,
        imagen: 'assets/images/productos/torta_selva_negra.jpg',
        categoria: 'Bizcochos',
      ),

      // Postres Dominicanos
      Producto(
        id: '7',
        nombre: 'Flan de Coco',
        descripcion: 'Cremoso flan de coco con caramelo casero',
        precio: 150.0,
        imagen: 'assets/images/productos/flan_coco.jpg',
        categoria: 'Postres Tradicionales',
      ),
      Producto(
        id: '8',
        nombre: 'Flan de Vainilla',
        descripcion: 'Clásico flan de vainilla con textura perfecta',
        precio: 120.0,
        imagen: 'assets/images/productos/flan_vainilla.jpg',
        categoria: 'Postres Tradicionales',
      ),
      Producto(
        id: '9',
        nombre: 'Majarete',
        descripcion: 'Tradicional majarete dominicano con canela',
        precio: 100.0,
        imagen: 'assets/images/productos/majarete.jpg',
        categoria: 'Postres Tradicionales',
      ),
      Producto(
        id: '10',
        nombre: 'Tembleque',
        descripcion: 'Postre de coco cremoso estilo caribeño',
        precio: 130.0,
        imagen: 'assets/images/productos/tembleque.jpg',
        categoria: 'Postres Tradicionales',
      ),
      Producto(
        id: '24',
        nombre: 'Dulce de Leche Cortada',
        descripcion: 'Tradicional dulce dominicano de leche cuajada',
        precio: 140.0,
        imagen: 'assets/images/productos/dulce_leche_cortada.jpg',
        categoria: 'Postres Tradicionales',
      ),
      Producto(
        id: '25',
        nombre: 'Arroz con Leche',
        descripcion: 'Cremoso arroz con leche y canela',
        precio: 90.0,
        imagen: 'assets/images/productos/arroz_con_leche.jpg',
        categoria: 'Postres Tradicionales',
      ),
      Producto(
        id: '26',
        nombre: 'Habichuelas con Dulce',
        descripcion: 'Postre tradicional dominicano de Semana Santa',
        precio: 160.0,
        imagen: 'assets/images/productos/habichuelas_con_dulce.jpg',
        categoria: 'Postres Tradicionales',
      ),

      // Galletas
      Producto(
        id: '11',
        nombre: 'Galletas de Avena',
        descripcion: 'Galletas caseras de avena con pasas (docena)',
        precio: 200.0,
        imagen: 'assets/images/productos/galletas_avena.jpg',
        categoria: 'Galletas',
      ),
      Producto(
        id: '12',
        nombre: 'Galletas de Chocolate Chip',
        descripcion: 'Clásicas galletas con chispas de chocolate (docena)',
        precio: 220.0,
        imagen: 'assets/images/productos/galletas_chocolate_chip.jpg',
        categoria: 'Galletas',
      ),
      Producto(
        id: '27',
        nombre: 'Galletas de Mantequilla',
        descripcion: 'Delicadas galletas de mantequilla tipo danesas (docena)',
        precio: 180.0,
        imagen: 'assets/images/productos/galletas_mantequilla.jpg',
        categoria: 'Galletas',
      ),
      Producto(
        id: '28',
        nombre: 'Galletas de Jengibre',
        descripcion: 'Especiadas galletas de jengibre con glaseado (docena)',
        precio: 210.0,
        imagen: 'assets/images/productos/galletas_jengibre.jpg',
        categoria: 'Galletas',
      ),
      Producto(
        id: '29',
        nombre: 'Galletas Decoradas',
        descripcion: 'Galletas personalizadas con royal icing (docena)',
        precio: 350.0,
        imagen: 'assets/images/productos/galletas_decoradas.jpg',
        categoria: 'Galletas',
      ),
      Producto(
        id: '30',
        nombre: 'Macarons Franceses',
        descripcion: 'Delicados macarons en varios sabores (6 unidades)',
        precio: 400.0,
        imagen: 'assets/images/productos/macarons.jpg',
        categoria: 'Galletas',
      ),

      // Cheesecakes
      Producto(
        id: '13',
        nombre: 'Cheesecake de Fresa',
        descripcion: 'Cremoso cheesecake con coulis de fresa',
        precio: 300.0,
        imagen: 'assets/images/productos/cheesecake_fresa.jpg',
        categoria: 'Cheesecakes',
      ),
      Producto(
        id: '31',
        nombre: 'Cheesecake Clásico',
        descripcion: 'Tradicional cheesecake de Nueva York',
        precio: 280.0,
        imagen: 'assets/images/productos/cheesecake_clasico.jpg',
        categoria: 'Cheesecakes',
      ),
      Producto(
        id: '32',
        nombre: 'Cheesecake de Chocolate',
        descripcion: 'Rico cheesecake de chocolate con base de oreo',
        precio: 320.0,
        imagen: 'assets/images/productos/cheesecake_chocolate.jpg',
        categoria: 'Cheesecakes',
      ),
      Producto(
        id: '33',
        nombre: 'Cheesecake de Limón',
        descripcion: 'Refrescante cheesecake cítrico con merengue',
        precio: 290.0,
        imagen: 'assets/images/productos/cheesecake_limon.jpg',
        categoria: 'Cheesecakes',
      ),
      Producto(
        id: '34',
        nombre: 'Cheesecake de Mango',
        descripcion: 'Tropical cheesecake con pulpa de mango fresco',
        precio: 310.0,
        imagen: 'assets/images/productos/cheesecake_mango.jpg',
        categoria: 'Cheesecakes',
      ),

      // Postres Especiales
      Producto(
        id: '14',
        nombre: 'Tiramisu',
        descripcion: 'Tradicional tiramisu italiano con café',
        precio: 280.0,
        imagen: 'assets/images/productos/tiramisu.jpg',
        categoria: 'Postres Especiales',
      ),
      Producto(
        id: '35',
        nombre: 'Crème Brûlée',
        descripcion: 'Elegante crema francesa con azúcar caramelizada',
        precio: 200.0,
        imagen: 'assets/images/productos/creme_brulee.jpg',
        categoria: 'Postres Especiales',
      ),
      Producto(
        id: '36',
        nombre: 'Panna Cotta',
        descripcion: 'Sedosa panna cotta italiana con frutos rojos',
        precio: 180.0,
        imagen: 'assets/images/productos/panna_cotta.jpg',
        categoria: 'Postres Especiales',
      ),
      Producto(
        id: '37',
        nombre: 'Profiteroles',
        descripcion: 'Deliciosos profiteroles rellenos de crema pastelera',
        precio: 250.0,
        imagen: 'assets/images/productos/profiteroles.jpg',
        categoria: 'Postres Especiales',
      ),
      Producto(
        id: '38',
        nombre: 'Éclair de Chocolate',
        descripcion: 'Clásicos éclairs franceses con crema y chocolate',
        precio: 120.0,
        imagen: 'assets/images/productos/eclair_chocolate.jpg',
        categoria: 'Postres Especiales',
      ),

      // Mousses
      Producto(
        id: '15',
        nombre: 'Mousse de Chocolate',
        descripcion: 'Ligero y cremoso mousse de chocolate belga',
        precio: 180.0,
        imagen: 'assets/images/productos/mousse_chocolate.jpg',
        categoria: 'Mousses',
      ),
      Producto(
        id: '39',
        nombre: 'Mousse de Fresa',
        descripcion: 'Suave mousse de fresa con trozos de fruta',
        precio: 170.0,
        imagen: 'assets/images/productos/mousse_fresa.jpg',
        categoria: 'Mousses',
      ),
      Producto(
        id: '40',
        nombre: 'Mousse de Limón',
        descripcion: 'Refrescante mousse cítrico con ralladura de limón',
        precio: 175.0,
        imagen: 'assets/images/productos/mousse_limon.jpg',
        categoria: 'Mousses',
      ),
      Producto(
        id: '41',
        nombre: 'Mousse de Maracuyá',
        descripcion: 'Exótico mousse tropical de maracuyá',
        precio: 185.0,
        imagen: 'assets/images/productos/mousse_maracuya.jpg',
        categoria: 'Mousses',
      ),

      // Tartas y Pies
      Producto(
        id: '42',
        nombre: 'Tarta de Manzana',
        descripcion: 'Clásica tarta de manzana con canela y masa crujiente',
        precio: 450.0,
        imagen: 'assets/images/productos/tarta_manzana.jpg',
        categoria: 'Tartas',
      ),
      Producto(
        id: '43',
        nombre: 'Tarta de Chocolate',
        descripcion: 'Rica tarta de chocolate con ganache y nueces',
        precio: 480.0,
        imagen: 'assets/images/productos/tarta_chocolate.jpg',
        categoria: 'Tartas',
      ),
      Producto(
        id: '44',
        nombre: 'Tarta de Frutas',
        descripcion: 'Colorida tarta con crema pastelera y frutas frescas',
        precio: 520.0,
        imagen: 'assets/images/productos/tarta_frutas.jpg',
        categoria: 'Tartas',
      ),
      Producto(
        id: '45',
        nombre: 'Key Lime Pie',
        descripcion: 'Auténtico pie de lima con base de galleta graham',
        precio: 350.0,
        imagen: 'assets/images/productos/key_lime_pie.jpg',
        categoria: 'Tartas',
      ),
      Producto(
        id: '46',
        nombre: 'Tarta de Queso y Arándanos',
        descripcion: 'Tarta cremosa con queso mascarpone y arándanos',
        precio: 420.0,
        imagen: 'assets/images/productos/tarta_queso_arandanos.jpg',
        categoria: 'Tartas',
      ),

      // Postres Fríos
      Producto(
        id: '47',
        nombre: 'Helado Artesanal de Vainilla',
        descripcion: 'Cremoso helado casero de vainilla (1 litro)',
        precio: 300.0,
        imagen: 'assets/images/productos/helado_vainilla.jpg',
        categoria: 'Postres Fríos',
      ),
      Producto(
        id: '48',
        nombre: 'Helado de Chocolate',
        descripcion: 'Intenso helado de chocolate belga (1 litro)',
        precio: 320.0,
        imagen: 'assets/images/productos/helado_chocolate.jpg',
        categoria: 'Postres Fríos',
      ),
      Producto(
        id: '49',
        nombre: 'Sorbete de Limón',
        descripcion: 'Refrescante sorbete natural de limón (1 litro)',
        precio: 250.0,
        imagen: 'assets/images/productos/sorbete_limon.jpg',
        categoria: 'Postres Fríos',
      ),
      Producto(
        id: '50',
        nombre: 'Copa Helada de Frutas',
        descripcion: 'Deliciosa copa con helado, frutas y crema',
        precio: 180.0,
        imagen: 'assets/images/productos/copa_helada_frutas.jpg',
        categoria: 'Postres Fríos',
      ),

      // Brownies y Bars
      Producto(
        id: '51',
        nombre: 'Brownies Clásicos',
        descripcion: 'Fudgy brownies con nueces (bandeja de 12)',
        precio: 400.0,
        imagen: 'assets/images/productos/brownies.jpg',
        categoria: 'Brownies',
      ),
      Producto(
        id: '52',
        nombre: 'Blondies',
        descripcion: 'Brownies de chocolate blanco con almendras (bandeja de 12)',
        precio: 380.0,
        imagen: 'assets/images/productos/blondies.jpg',
        categoria: 'Brownies',
      ),
      Producto(
        id: '53',
        nombre: 'Lemon Bars',
        descripcion: 'Barras de limón con base de masa mantecosa (bandeja de 12)',
        precio: 350.0,
        imagen: 'assets/images/productos/lemon_bars.jpg',
        categoria: 'Brownies',
      ),

      // Muffins
      Producto(
        id: '54',
        nombre: 'Muffins de Arándanos',
        descripcion: 'Esponjosos muffins con arándanos frescos (6 unidades)',
        precio: 240.0,
        imagen: 'assets/images/productos/muffins_arandanos.jpg',
        categoria: 'Muffins',
      ),
      Producto(
        id: '55',
        nombre: 'Muffins de Chocolate',
        descripcion: 'Muffins doble chocolate con chispas (6 unidades)',
        precio: 260.0,
        imagen: 'assets/images/productos/muffins_chocolate.jpg',
        categoria: 'Muffins',
      ),
      Producto(
        id: '56',
        nombre: 'Muffins de Banana',
        descripcion: 'Húmedos muffins de plátano con nueces (6 unidades)',
        precio: 230.0,
        imagen: 'assets/images/productos/muffins_banana.jpg',
        categoria: 'Muffins',
      ),

      // Panes Dulces
      Producto(
        id: '57',
        nombre: 'Pan de Banana',
        descripcion: 'Aromático pan dulce de plátano maduro',
        precio: 200.0,
        imagen: 'assets/images/productos/pan_banana.jpg',
        categoria: 'Panes Dulces',
      ),
      Producto(
        id: '58',
        nombre: 'Pan de Calabaza',
        descripcion: 'Especiado pan de calabaza con canela y nuez moscada',
        precio: 220.0,
        imagen: 'assets/images/productos/pan_calabaza.jpg',
        categoria: 'Panes Dulces',
      ),
      Producto(
        id: '59',
        nombre: 'Stollen Navideño',
        descripcion: 'Tradicional pan alemán con frutas confitadas',
        precio: 450.0,
        imagen: 'assets/images/productos/stollen.jpg',
        categoria: 'Panes Dulces',
        disponible: false,
      ),

      // Postres Sin Azúcar
      Producto(
        id: '60',
        nombre: 'Brownie Sin Azúcar',
        descripcion: 'Delicioso brownie endulzado con stevia (4 unidades)',
        precio: 280.0,
        imagen: 'assets/images/productos/brownie_sin_azucar.jpg',
        categoria: 'Sin Azúcar',
      ),
      Producto(
        id: '61',
        nombre: 'Cheesecake Sin Azúcar',
        descripcion: 'Cremoso cheesecake con edulcorante natural',
        precio: 350.0,
        imagen: 'assets/images/productos/cheesecake_sin_azucar.jpg',
        categoria: 'Sin Azúcar',
      ),
      Producto(
        id: '62',
        nombre: 'Galletas de Avena Sin Azúcar',
        descripcion: 'Saludables galletas endulzadas con dátiles (docena)',
        precio: 250.0,
        imagen: 'assets/images/productos/galletas_avena_sin_azucar.jpg',
        categoria: 'Sin Azúcar',
      ),
    ];
  }

  static final List<Producto> _cache = obtenerProductos();

  static Producto? buscarPorId(String id) {
    for (final p in _cache) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Productos destacados en la pantalla de inicio.
  static List<Producto> destacados() => ['5', '3', '7', '30', '14', '44', '13', '26']
      .map(buscarPorId)
      .whereType<Producto>()
      .toList();

  /// Ocasiones que se muestran como círculos en inicio y catálogo.
  static const List<String> ocasiones = ['Cumpleaños', 'Eventos', 'Bodas', 'Para ti'];

  static const Map<String, List<String>> _ocasionesPorCategoria = {
    'Cupcakes': ['Cumpleaños', 'Eventos', 'Bodas', 'Para ti'],
    'Bizcochos': ['Cumpleaños', 'Eventos'],
    'Postres Tradicionales': ['Para ti', 'Eventos'],
    'Galletas': ['Eventos', 'Para ti'],
    'Cheesecakes': ['Cumpleaños', 'Eventos', 'Para ti'],
    'Postres Especiales': ['Bodas', 'Eventos', 'Para ti'],
    'Mousses': ['Para ti', 'Eventos'],
    'Tartas': ['Cumpleaños', 'Eventos', 'Para ti'],
    'Postres Fríos': ['Para ti', 'Cumpleaños'],
    'Brownies': ['Eventos', 'Para ti'],
    'Muffins': ['Para ti', 'Eventos'],
    'Panes Dulces': ['Para ti'],
    'Sin Azúcar': ['Para ti'],
  };

  static const Map<String, List<String>> _ocasionesPorProducto = {
    '22': ['Bodas', 'Eventos'], // Torta de Boda
    '29': ['Cumpleaños', 'Bodas', 'Eventos'], // Galletas Decoradas
    '30': ['Bodas', 'Eventos', 'Para ti'], // Macarons
  };

  static List<String> ocasionesDe(Producto p) =>
      _ocasionesPorProducto[p.id] ?? _ocasionesPorCategoria[p.categoria] ?? const ['Para ti'];

  /// Imagen representativa de cada categoría.
  static const Map<String, String> imagenCategoria = {
    'Cupcakes': 'assets/images/productos/cupcake_fresa.jpg',
    'Bizcochos': 'assets/images/productos/torta_selva_negra.jpg',
    'Postres Tradicionales': 'assets/images/productos/flan_coco.jpg',
    'Galletas': 'assets/images/productos/galletas_chocolate_chip.jpg',
    'Cheesecakes': 'assets/images/productos/cheesecake_fresa.jpg',
    'Postres Especiales': 'assets/images/productos/tiramisu.jpg',
    'Mousses': 'assets/images/productos/mousse_limon.jpg',
    'Tartas': 'assets/images/productos/tarta_frutas.jpg',
    'Postres Fríos': 'assets/images/productos/copa_helada_frutas.jpg',
    'Brownies': 'assets/images/productos/brownies.jpg',
    'Muffins': 'assets/images/productos/muffins_arandanos.jpg',
    'Panes Dulces': 'assets/images/productos/pan_banana.jpg',
    'Sin Azúcar': 'assets/images/productos/cheesecake_sin_azucar.jpg',
  };

  static List<String> obtenerCategorias() {
    return [
      'Todos',
      'Cupcakes',
      'Bizcochos',
      'Postres Tradicionales',
      'Galletas',
      'Cheesecakes',
      'Postres Especiales',
      'Mousses',
      'Tartas',
      'Postres Fríos',
      'Brownies',
      'Muffins',
      'Panes Dulces',
      'Sin Azúcar',
    ];
  }
}


