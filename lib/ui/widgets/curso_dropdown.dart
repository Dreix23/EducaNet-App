import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CursoDropdown extends StatelessWidget {
  final dynamic controller;

  CursoDropdown({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Obx(() => Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
        ),
        child: DropdownButtonFormField<String>(
          value: controller.cursoSeleccionado.value.isEmpty ? 'GENERAL' : controller.cursoSeleccionado.value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            hintText: 'Selecciona un curso',
            prefixIcon: Icon(Icons.school, color: Colors.blue),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            isDense: true,
          ),
          items: controller.cursos.map<DropdownMenuItem<String>>((String curso) {
            return DropdownMenuItem<String>(
              value: curso,
              child: Text(curso),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              controller.seleccionarCurso(newValue);
            }
          },
          dropdownColor: Colors.white,
          icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
          elevation: 0,
          style: TextStyle(color: Colors.black, fontSize: 16),
        ),
      )),
    );
  }
}
