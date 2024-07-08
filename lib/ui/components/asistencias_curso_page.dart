import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../controllers/asistencias_controller.dart';
import '../widgets/curso_dropdown.dart';
import '../../utils/calendar_localization.dart';

class AsistenciasCursoPage extends StatelessWidget {
  final AsistenciasController controller = Get.put(AsistenciasController());

  AsistenciasCursoPage() {
    _inicializarLocalizacion();
  }

  void _inicializarLocalizacion() async {
    await CalendarLocalization.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CursoDropdown(controller: controller),
          _construirLeyenda(),
          Expanded(
            child: Obx(() => TableCalendar(
              locale: 'es_ES',
              firstDay: DateTime.utc(2024, 1, 1),
              lastDay: DateTime.utc(2024, 12, 31),
              focusedDay: controller.focusedDay.value,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => false,
              onDaySelected: (selectedDay, focusedDay) {
                controller.onDaySelected(selectedDay, focusedDay);
              },
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, date, _) {
                  return _construirDiaCalendario(date);
                },
                todayBuilder: (context, date, _) {
                  return Container(
                    margin: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purple, width: 2),
                    ),
                    child: _construirDiaCalendario(date),
                  );
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleTextFormatter: (date, locale) => CalendarLocalization.formatDate(date),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.black),
                weekendStyle: TextStyle(color: Colors.red),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _construirLeyenda() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _construirItemLeyenda('Presente', Colors.green),
          _construirItemLeyenda('Retardo', Colors.orange),
          _construirItemLeyenda('Falta', Colors.red),
          _construirItemLeyenda('Permiso', Colors.blue),
        ],
      ),
    );
  }

  Widget _construirItemLeyenda(String texto, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4),
        Text(texto),
      ],
    );
  }

  Widget _construirDiaCalendario(DateTime date) {
    return Obx(() => Container(
      margin: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: controller.getAsistenciaColor(date),
        shape: BoxShape.circle,
      ),
      child: Text(
        '${date.day}',
        style: TextStyle(color: controller.getAsistenciaColor(date) != Colors.grey ? Colors.white : Colors.black),
      ),
    ));
  }
}
