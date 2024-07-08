class Alumno {
  final String nombre;
  final String qr;

  Alumno({required this.nombre, required this.qr});

  Map<String, dynamic> toMap() {
    return {
      'NOM_ALUMNO': nombre,
      'QR': qr,
    };
  }
}
