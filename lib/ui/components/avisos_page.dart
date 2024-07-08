import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/avisos_controller.dart';
import '../widgets/curso_dropdown.dart';

class AvisosPage extends StatelessWidget {
  final AvisosController controller = Get.find<AvisosController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CursoDropdown(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.avisos.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('No hay avisos disponibles', style: TextStyle(fontSize: 18, color: Colors.grey)),
                    ],
                  ),
                );
              } else {
                List<Map<String, dynamic>> avisosOrdenados = controller.avisos.toList()
                  ..sort((a, b) => (b['fechaPublicacion'] ?? '').compareTo(a['fechaPublicacion'] ?? ''));

                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: avisosOrdenados.length,
                  itemBuilder: (context, index) {
                    var aviso = avisosOrdenados[index];
                    String avisoId = aviso['id'] ?? '';
                    String descripcion = aviso['descripcion'] ?? 'Sin descripción';
                    bool esDescripcionLarga = descripcion.length > 100;
                    bool esGeneral = controller.cursoSeleccionado.value == 'GENERAL';

                    return Obx(() {
                      bool isExpanded = controller.avisoExpandido.value == avisoId;
                      return GestureDetector(
                        onTap: esDescripcionLarga ? () => controller.toggleExpand(avisoId) : null,
                        child: Card(
                          elevation: 2,
                          margin: EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: esGeneral ? BorderSide(color: Colors.purple, width: 2) : BorderSide.none,
                          ),
                          color: Colors.white,
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        aviso['titulo'] ?? 'Sin título',
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple),
                                      ),
                                    ),
                                    if (esGeneral)
                                      Icon(Icons.star, color: Colors.purple),
                                  ],
                                ),
                                SizedBox(height: 8),
                                AnimatedCrossFade(
                                  firstChild: Text(
                                    descripcion,
                                    style: TextStyle(color: Colors.grey[600]),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  secondChild: Text(
                                    descripcion,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: Duration(milliseconds: 300),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                                    SizedBox(width: 4),
                                    Text(
                                      'Fecha de Publicación: ${aviso['fechaPublicacion'] ?? 'No especificada'}',
                                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500),
                                    ),
                                  ],
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
