import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../../controllers/attendance_controller.dart';
import '../../../controllers/avisos_controller.dart';
import '../../../controllers/user_controller.dart';
import '../../../controllers/tareas_controller.dart';
import '../../../controllers/asistencias_controller.dart';
import '../../../controllers/notification_controller.dart';
import '../../../dialogs/add_hijo_dialog.dart';
import '../../../models/user.dart';
import '../../../service/auth_service.dart';
import '../../../service/firestore_service.dart';
import '../../../service/notification_service.dart';
import '../../../utils/logger.dart';
import '../../components/padres_box.dart';
import '../../widgets/custom_app_bar.dart';
import '../../components/tareas_page.dart';
import '../../components/asistencias_curso_page.dart';
import '../../components/avisos_page.dart';
import '../WelcomeScreen.dart';
import '../../widgets/children_dropdown.dart';
import '../../../service/alumno_service.dart';
import 'PadrePerfilScreen.dart';

class PadreScreen extends StatefulWidget {
  final FirestoreService firestoreService;

  PadreScreen({Key? key, required this.firestoreService}) : super(key: key);

  @override
  _PadreScreenState createState() => _PadreScreenState();
}

class _PadreScreenState extends State<PadreScreen> {
  String userName = 'Cargando...';
  DateTime fechaSeleccionada = DateTime.now();
  AppUser? currentUser;

  final UserController _userController = UserController();
  final AttendanceController _attendanceController = AttendanceController();
  final AlumnoService _alumnoService = AlumnoService();
  final TareasController _tareasController = Get.put(TareasController());
  final AsistenciasController _asistenciasController = Get.put(AsistenciasController());
  final AvisosController _avisosController = Get.put(AvisosController());
  final NotificationController _notificationController = Get.find<NotificationController>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  AuthService authService = AuthService();

  List<Map<String, String>> alumnos = [];
  String selectedChildQR = '';

  StreamSubscription? _alumnosSubscription;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadAlumnos();
    _updateFCMToken();
  }

  @override
  void dispose() {
    _alumnosSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      AppUser user = await _userController.getCurrentUser();
      if (mounted) {
        setState(() {
          currentUser = user;
          userName = user.name;
        });
      }
    } catch (e) {
      AppLogger.log("Error al cargar datos del usuario: $e");
      if (mounted) {
        setState(() {
          userName = 'Error al cargar';
        });
      }
    }
  }

  Future<void> _loadAlumnos() async {
    try {
      _alumnosSubscription = _alumnoService.obtenerNombresAlumnos().listen((updatedAlumnos) {
        if (mounted) {
          setState(() {
            alumnos = updatedAlumnos;
            if (alumnos.isNotEmpty && selectedChildQR.isEmpty) {
              selectedChildQR = alumnos.first['qr'] ?? '';
              _onChildSelected(selectedChildQR);
            }
          });
        }
      });
    } catch (e) {
      AppLogger.log("Error al cargar alumnos: $e");
    }
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
      locale: const Locale('es', 'ES'),
    );

    if (fechaElegida != null && fechaElegida != fechaSeleccionada && mounted) {
      setState(() {
        fechaSeleccionada = fechaElegida;
      });
    }
  }

  void _onChildSelected(String qr) {
    if (mounted) {
      setState(() {
        selectedChildQR = qr;
      });
      _tareasController.setAlumnoQR(qr);
      _asistenciasController.setAlumnoQR(qr);
      _avisosController.setAlumnoQR(qr);
    }
  }

  Future<void> _updateFCMToken() async {
    try {
      String? token = await _notificationService.obtenerTokenFCM();
      if (token != null) {
        await _notificationService.actualizarTokenFCM(token);
        AppLogger.log("Token FCM actualizado: $token", prefix: 'INFO:');
      }
    } catch (e) {
      AppLogger.log("Error al actualizar el token FCM: $e", prefix: 'ERROR:');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        userName: userName,
        onProfileTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PadrePerfilScreen()),
          );
        },
        onLogoutTap: () async {
          await authService.logout();
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WelcomeScreen()));
        },
      ),
      body: Column(
        children: [
          Obx(() {
            if (_notificationController.selectedIndex.value == 0) {
              return ChildrenDropdown(
                children: alumnos.map((a) => a['nombre'] ?? '').toList(),
                selectedChild: alumnos.firstWhere((a) => a['qr'] == selectedChildQR, orElse: () => {'nombre': ''})['nombre'] ?? '',
                onChildSelected: (nombre) {
                  var alumno = alumnos.firstWhere((a) => a['nombre'] == nombre, orElse: () => {'qr': ''});
                  _onChildSelected(alumno['qr'] ?? '');
                },
              );
            } else {
              return SizedBox.shrink();
            }
          }),
          Expanded(
            child: Obx(() => IndexedStack(
              index: _notificationController.selectedIndex.value,
              children: <Widget>[
                PadresBox(
                  onAdd: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddHijoDialog();
                      },
                    );
                  },
                  floatingActionButton: FloatingActionButton(
                    onPressed: () => _seleccionarFecha(context),
                    child: Icon(Icons.calendar_today),
                    backgroundColor: Colors.pinkAccent[100],
                    shape: CircleBorder(),
                  ),
                  asistenciasStream: currentUser != null
                      ? _attendanceController.getAsistenciasPorPadreYFecha(currentUser!.id, fechaSeleccionada)
                      : Stream.value([]),
                ),
                TareasPage(),
                AsistenciasCursoPage(),
                AvisosPage(),
              ],
            )),
          ),
        ],
      ),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Tareas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Asistencias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Avisos',
          ),
        ],
        currentIndex: _notificationController.selectedIndex.value,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          _notificationController.selectedIndex.value = index;
        },
        elevation: 0,
      )),
    );
  }
}
