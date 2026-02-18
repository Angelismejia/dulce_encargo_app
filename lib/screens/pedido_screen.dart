import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';
import '../services/database_services.dart';
import '../utils/colores.dart';

class PedidoScreen extends StatefulWidget {
  @override
  _PedidoScreenState createState() => _PedidoScreenState();
}

class _PedidoScreenState extends State<PedidoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();
  final _notasController = TextEditingController();

  DateTime _fechaEntrega = DateTime.now().add(Duration(days: 1));
  TimeOfDay _horaEntrega = TimeOfDay(hour: 14, minute: 0);
  bool _isLoading = false;
  bool _recordarDatos = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosGuardados();
    _setFechaMinima();
  }

  void _cargarDatosGuardados() {
    final datosCliente = DatabaseService.cargarDatosCliente();
    _nombreController.text = datosCliente['nombre'] ?? '';
    _telefonoController.text = datosCliente['telefono'] ?? '';
    _direccionController.text = datosCliente['direccion'] ?? '';
  }

  void _setFechaMinima() {
    final ahora = DateTime.now();
    // Si son más de las 6 PM, la fecha mínima es mañana
    if (ahora.hour >= 18) {
      _fechaEntrega = DateTime(ahora.year, ahora.month, ahora.day + 1);
    } else {
      _fechaEntrega = DateTime(ahora.year, ahora.month, ahora.day);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Realizar Pedido'),
        elevation: 0,
      ),
      body: Consumer<CarritoProvider>(
        builder: (context, carrito, child) {
          if (carrito.items.isEmpty) {
            return _buildCarritoVacio();
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildResumenPedido(carrito),
                      SizedBox(height: 25),
                      _buildDatosCliente(),
                      SizedBox(height: 25),
                      _buildFechaHoraEntrega(),
                      SizedBox(height: 25),
                      _buildNotasEspeciales(),
                      SizedBox(height: 25),
                      _buildOpcionRecordar(),
                      SizedBox(height: 100), // Espacio para el botón flotante
                    ],
                  ),
                ),
              ),
              _buildBotonConfirmar(carrito),
              if (_isLoading) _buildLoadingOverlay(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCarritoVacio() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Text(
            'No tienes productos en el carrito',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/catalogo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            child: Text(
              'Ver Catálogo',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumenPedido(CarritoProvider carrito) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.receipt_long, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Text(
                  'Resumen del Pedido',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Container(
              constraints: BoxConstraints(maxHeight: 150),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: carrito.items.length,
                separatorBuilder: (context, index) => Divider(height: 8),
                itemBuilder: (context, index) {
                  final item = carrito.items[index];
                  return Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: NetworkImage(item.producto.imagen),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.cantidad}x ${item.producto.nombre}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            if (item.personalizacion != null)
                              Text(
                                item.personalizacion!,
                                style: TextStyle(
                                  fontSize: 12,
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
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            Divider(thickness: 2),
            Row(
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
                  'RD\$ ${carrito.total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatosCliente() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Text(
                  'Datos del Cliente',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.person_outline),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa tu nombre completo';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _telefonoController,
              decoration: InputDecoration(
                labelText: 'Teléfono *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.phone_outlined),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: '809-123-4567',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa tu teléfono';
                }
                if (value.trim().length < 10) {
                  return 'Ingresa un número válido';
                }
                return null;
              },
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _direccionController,
              decoration: InputDecoration(
                labelText: 'Dirección de Entrega *',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Icon(Icons.location_on_outlined),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'Calle, número, sector, ciudad',
              ),
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor ingresa la dirección de entrega';
                }
                if (value.trim().length < 10) {
                  return 'Por favor proporciona una dirección completa';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFechaHoraEntrega() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.schedule, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Text(
                  'Fecha y Hora de Entrega',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    leading: Icon(Icons.calendar_today, color: AppColors.primary),
                    title: Text('Fecha'),
                    subtitle: Text(
                      _formatearFecha(_fechaEntrega),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: _seleccionarFecha,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                    leading: Icon(Icons.access_time, color: AppColors.primary),
                    title: Text('Hora'),
                    subtitle: Text(
                      _horaEntrega.format(context),
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    onTap: _seleccionarHora,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[800], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Horario de entrega: 9:00 AM - 8:00 PM. Pedidos después de las 6 PM se entregan al día siguiente.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotasEspeciales() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.note_outlined, color: AppColors.primary, size: 24),
                SizedBox(width: 10),
                Text(
                  'Notas Especiales',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            TextFormField(
              controller: _notasController,
              decoration: InputDecoration(
                labelText: 'Instrucciones especiales (Opcional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                hintText: 'Ej: "Sin azúcar", "Decoración con flores", "Llamar al llegar"...',
              ),
              maxLines: 3,
              maxLength: 200,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOpcionRecordar() {
    return CheckboxListTile(
      value: _recordarDatos,
      onChanged: (bool? value) {
        setState(() {
          _recordarDatos = value ?? true;
        });
      },
      title: Text('Recordar mis datos para próximos pedidos'),
      subtitle: Text('Esto guardará tu información de contacto localmente'),
      activeColor: AppColors.primary,
    );
  }

  Widget _buildBotonConfirmar(CarritoProvider carrito) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(25),
            onTap: _isLoading ? null : () => _confirmarPedido(context, carrito),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Confirmar Pedido - RD\$ ${carrito.total.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: 16),
                Text('Procesando tu pedido...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final fecha = await showDatePicker(
      context: context,
      initialDate: _fechaEntrega,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 30)),
      locale: Locale('es', 'DO'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (fecha != null) {
      setState(() {
        _fechaEntrega = fecha;
      });
    }
  }

  Future<void> _seleccionarHora() async {
    final hora = await showTimePicker(
      context: context,
      initialTime: _horaEntrega,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (hora != null) {
      // Validar horario de entrega
      if (hora.hour < 9 || hora.hour > 20) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('El horario de entrega es de 9:00 AM a 8:00 PM'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      setState(() {
        _horaEntrega = hora;
      });
    }
  }

  String _formatearFecha(DateTime fecha) {
    final hoy = DateTime.now();
    final manana = hoy.add(Duration(days: 1));

    if (_esMismoDia(fecha, hoy)) {
      return 'Hoy, ${fecha.day}/${fecha.month}';
    } else if (_esMismoDia(fecha, manana)) {
      return 'Mañana, ${fecha.day}/${fecha.month}';
    } else {
      return '${fecha.day}/${fecha.month}/${fecha.year}';
    }
  }

  bool _esMismoDia(DateTime fecha1, DateTime fecha2) {
    return fecha1.year == fecha2.year &&
        fecha1.month == fecha2.month &&
        fecha1.day == fecha2.day;
  }

  void _confirmarPedido(BuildContext context, CarritoProvider carrito) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor completa todos los campos requeridos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validar fecha y hora
    final fechaHoraEntrega = DateTime(
      _fechaEntrega.year,
      _fechaEntrega.month,
      _fechaEntrega.day,
      _horaEntrega.hour,
      _horaEntrega.minute,
    );

    final ahora = DateTime.now();
    if (fechaHoraEntrega.isBefore(ahora.add(Duration(hours: 2)))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La entrega debe ser al menos 2 horas después de ahora'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Guardar datos del cliente si está marcada la opción
      if (_recordarDatos) {
        await DatabaseService.guardarDatosCliente(
          nombre: _nombreController.text.trim(),
          telefono: _telefonoController.text.trim(),
          direccion: _direccionController.text.trim(),
        );
      }

      // Realizar el pedido
      await carrito.realizarPedido(
        nombreCliente: _nombreController.text.trim(),
        telefono: _telefonoController.text.trim(),
        direccion: _direccionController.text.trim(),
        fechaEntrega: fechaHoraEntrega,
        notas: _notasController.text.trim().isEmpty
            ? null
            : _notasController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      // Mostrar confirmación mejorada
      await _mostrarConfirmacion(context);

    } catch (error) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al procesar el pedido. Intenta nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _mostrarConfirmacion(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 60,
                ),
              ),
              SizedBox(height: 20),
              Text(
                '¡Pedido Confirmado!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              Text(
                'Tu pedido ha sido recibido correctamente.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Te contactaremos pronto para confirmar los detalles de tu pedido.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/historial');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      child: Text(
                        'Ver Pedidos',
                        style: TextStyle(color: AppColors.primary),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(context, '/');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Ir al Inicio',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _telefonoController.dispose();
    _direccionController.dispose();
    _notasController.dispose();
    super.dispose();
  }
}