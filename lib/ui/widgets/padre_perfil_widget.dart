import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class PadrePerfilWidget extends StatelessWidget {
  final FormGroup form;
  final String userName;
  final bool isEditing;
  final Function(int) onDeleteQRCode;

  const PadrePerfilWidget({
    Key? key,
    required this.form,
    required this.userName,
    required this.isEditing,
    required this.onDeleteQRCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildProfileHeader(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Información Personal'),
                    _buildInfoField('name', 'Nombre', Icons.person),
                    _buildInfoField('email', 'Correo electrónico', Icons.email),
                    _buildInfoField('school', 'Escuela', Icons.school),
                    SizedBox(height: 16),
                    _buildSectionTitle('Códigos QR de hijos'),
                    _buildQRCodesList(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Center(
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: Icon(Icons.person, size: 50, color: Colors.purple),
            ),
            SizedBox(height: 8),
            Text(
              userName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
      ),
    );
  }

  Widget _buildInfoField(String formControlName, String labelText, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ReactiveTextField(
        formControlName: formControlName,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: Colors.pink),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.pink),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.pink.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.pink, width: 2),
          ),
        ),
        readOnly: !isEditing,
      ),
    );
  }

  Widget _buildQRCodesList() {
    return ReactiveFormArray(
      formArrayName: 'codigoQR',
      builder: (context, formArray, child) {
        return Column(
          children: formArray.controls.asMap().entries.map((entry) {
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                leading: Icon(Icons.qr_code, color: Colors.purple, size: 30),
                title: ReactiveTextField(
                  formControl: entry.value as FormControl<String>,
                  decoration: InputDecoration(
                    labelText: 'Código QR ${entry.key + 1}',
                    border: InputBorder.none,
                  ),
                  readOnly: !isEditing,
                ),
                trailing: isEditing
                    ? IconButton(
                  icon: Icon(Icons.delete, color: Colors.pink),
                  onPressed: () => onDeleteQRCode(entry.key),
                )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
