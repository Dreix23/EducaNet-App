import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/tareas_controller.dart';
import '../../utils/logger.dart';
import '../widgets/curso_dropdown.dart';

class TareasPage extends StatelessWidget {
  final TareasController controller = Get.put(TareasController());

  bool isTareaVencida(String? fechaEntrega) {
    if (fechaEntrega == null) return false;
    DateTime fechaEntregaDateTime = DateTime.parse(fechaEntrega);
    return fechaEntregaDateTime.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CursoDropdown(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.tareas.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.assignment_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay tareas disponibles', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              } else {
                List<Map<String, dynamic>> tareasOrdenadas = controller.tareas.toList()
                  ..sort((a, b) {
                    bool aVencida = isTareaVencida(a['fechaEntrega']);
                    bool bVencida = isTareaVencida(b['fechaEntrega']);
                    if (aVencida == bVencida) {
                      return (b['fechaEntrega'] ?? '').compareTo(a['fechaEntrega'] ?? '');
                    }
                    return aVencida ? 1 : -1;
                  });

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: tareasOrdenadas.length,
                  itemBuilder: (context, index) {
                    var tarea = tareasOrdenadas[index];
                    String tareaId = tarea['id'] ?? '';
                    bool esVencida = isTareaVencida(tarea['fechaEntrega']);
                    AppLogger.log('Tarea ID: $tareaId, Vencida: $esVencida');

                    String descripcion = tarea['descripcion'] ?? 'Sin descripción';
                    bool esDescripcionLarga = descripcion.length > 100; // Ajusta este valor según tus necesidades

                    return Obx(() {
                      bool isExpanded = controller.tareaExpandida.value == tareaId;
                      return GestureDetector(
                        onTap: esDescripcionLarga ? () => controller.toggleExpand(tareaId) : null,
                        child: Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: esVencida ? Color(0xFFFFF0F5) : Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tarea['titulo'] ?? 'Sin título',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple),
                                ),
                                SizedBox(height: 8),
                                AnimatedCrossFade(
                                  firstChild: Text(
                                    'Descripción: $descripcion',
                                    style: TextStyle(color: Colors.grey[600]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  secondChild: Text(
                                    'Descripción: $descripcion',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: Duration(milliseconds: 300),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: esVencida ? Colors.red : Colors.blue),
                                    SizedBox(width: 4),
                                    Text(
                                      'Fecha de Entrega: ${tarea['fechaEntrega'] ?? 'No especificada'}',
                                      style: TextStyle(color: esVencida ? Colors.red : Colors.blue, fontWeight: FontWeight.w500),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                StreamBuilder<Map<String, dynamic>?>(
                                  stream: controller.obtenerCalificacion(tareaId),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState == ConnectionState.active && snapshot.hasData && snapshot.data != null) {
                                      return Row(
                                        children: [
                                          Icon(Icons.grade, size: 16, color: Colors.green),
                                          SizedBox(width: 4),
                                          Text(
                                            'Calificación: ${snapshot.data!['nota'] ?? 'No disponible'}',
                                            style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return Text('Sin calificar', style: TextStyle(color: Colors.grey));
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    });
                  },
                );
              }
            }),
          ),
        ],
      ),
    );
  }
}
