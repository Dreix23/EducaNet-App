import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/user.dart';
import '../../../utils/logger.dart';
import '../../widgets/custom_snackbar.dart';
import '../../widgets/padre_perfil_widget.dart';

class PadrePerfilScreen extends StatefulWidget {
  @override
  _PadrePerfilScreenState createState() => _PadrePerfilScreenState();
}

class _PadrePerfilScreenState extends State<PadrePerfilScreen> {
  final UserController _userController = UserController();
  late FormGroup form;
  AppUser? currentUser;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _initForm();
  }

  void _initForm() {
    form = FormGroup({
      'name': FormControl<String>(validators: [Validators.required]),
      'email': FormControl<String>(validators: [Validators.required, Validators.email]),
      'school': FormControl<String>(validators: [Validators.required]),
      'codigoQR': FormArray<String>([], validators: [Validators.required]),
    });
  }

  Future<void> _loadUserData() async {
    try {
      AppUser user = await _userController.getCurrentUser();
      setState(() {
        currentUser = user;
        form.patchValue({
          'name': user.name,
          'email': user.email,
          'school': user.school,
        });

        (form.control('codigoQR') as FormArray<String>).clear();

        user.codigoQR.forEach((code) {
          (form.control('codigoQR') as FormArray<String>).add(FormControl<String>(value: code));
        });
      });
    } catch (e) {
      AppLogger.log("Error al cargar datos del usuario: $e", prefix: 'PERFIL_PADRE:');
    }
  }

  void _toggleEditing() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        _onSubmit();
      }
    });
  }

  void _onSubmit() async {
    if (form.valid) {
      AppLogger.log("Formulario válido. Datos: ${form.value}", prefix: 'PERFIL_PADRE:');
      try {
        List<String> codigoQRList = (form.control('codigoQR') as FormArray<String>).value
            ?.where((code) => code != null)
            .map((code) => code!)
            .toList() ?? [];

        await _userController.updateUserProfile(
          name: form.control('name').value,
          school: form.control('school').value,
          codigoQR: codigoQRList,
        );
        CustomSnackbar.show(context, 'Perfil actualizado con éxito', SnackbarState.completed);
      } catch (e) {
        AppLogger.log("Error al actualizar el perfil: $e", prefix: 'PERFIL_PADRE:');
        CustomSnackbar.show(context, 'Error al actualizar el perfil', SnackbarState.error);
      }
    } else {
      AppLogger.log("Formulario inválido", prefix: 'PERFIL_PADRE:');
      CustomSnackbar.show(context, 'Formulario inválido', SnackbarState.error);
    }
  }

  void _deleteQRCode(int index) async {
    try {
      String qrCodeToDelete = (form.control('codigoQR') as FormArray<String>).controls[index].value ?? '';
      await _userController.deleteQRCode(qrCodeToDelete);
      setState(() {
        (form.control('codigoQR') as FormArray<String>).removeAt(index);
      });
      CustomSnackbar.show(context, 'Código QR eliminado con éxito', SnackbarState.completed);
    } catch (e) {
      AppLogger.log("Error al eliminar el código QR: $e", prefix: 'PERFIL_PADRE:');
      CustomSnackbar.show(context, 'Error al eliminar el código QR', SnackbarState.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Perfil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.save : Icons.edit, color: Colors.cyanAccent),
            onPressed: _toggleEditing,
          ),
        ],
      ),
      body: ReactiveForm(
        formGroup: form,
        child: PadrePerfilWidget(
          form: form,
          userName: currentUser?.name ?? 'Nombre del Padre',
          isEditing: isEditing,
          onDeleteQRCode: _deleteQRCode,
        ),
      ),
    );
  }
}
