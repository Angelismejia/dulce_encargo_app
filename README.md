# DulceEncargo 🧁


DulceEncargo es una aplicación de pedidos de repostería artesanal, usando Flutter y Hive. Permite gestionar productos, carrito de compras, pedidos e historial, con persistencia offline y un diseño moderno y responsive.

##  Demo en vivo
Puedes probar la app directamente en tu navegador:  
🔗 https://dulce-encargo.web.app/

##  Funcionalidades principales
- **Catálogo de productos:** Visualización de productos con imágenes y descripciones en un diseño responsivo.
- **Carrito de compras:** Agregar y modificar productos, con actualización automática gracias a **Provider**.
- **Pedidos:** Formularios de pedidos con validación en tiempo real y selección de fecha/hora.
- **Historial:** Consulta y duplicación de pedidos anteriores, con filtros por estado.
- **Persistencia offline:** Todos los datos se guardan localmente con **Hive**, permitiendo usar la app sin conexión.
- **Widgets reutilizables:** Componente modular para mantener consistencia visual y código escalable.
- **Debug interno:** Pantalla de depuración para monitorear base de datos y funcionalidades.

##  Arquitectura y tecnologías
- **Lenguaje:** Dart
- **Framework:** Flutter
- **Gestión de estado:** Provider Pattern con ChangeNotifier y Consumer
- **Base de datos:** Hive (NoSQL local)

##  Cómo ejecutar
1. Clonar el repositorio: `git clone <URL>`
2. Instalar dependencias: `flutter pub get`
3. Ejecutar la app: `flutter run` o instalar el APK

