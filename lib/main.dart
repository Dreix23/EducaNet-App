import 'package:educanet/service/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'controllers/notification_controller.dart';
import 'firebase_options.dart';
import 'service/auth_service.dart';
import 'service/firestore_service.dart';
import 'ui/screens/WelcomeScreen.dart';
import 'ui/screens/padre/PadreScreen.dart';
import 'ui/screens/profesor/ProfesorScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Get.putAsync(() => NotificationService().init());
  Get.put(NotificationController());
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('es', 'ES'),
      ],
      locale: const Locale('es', 'ES'),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return WelcomeScreen();
            } else {
              return FutureBuilder<String?>(
                future: _authService.getUserRole(user),
                builder: (context, roleSnapshot) {
                  if (roleSnapshot.connectionState == ConnectionState.done) {
                    if (roleSnapshot.data == 'profesor') {
                      return ProfesorScreen();
                    } else {
                      return PadreScreen(firestoreService: _firestoreService);
                    }
                  }
                  return SpinKitThreeInOut(
                    color: Colors.pinkAccent,
                    size: 40.0,
                  );
                },
              );
            }
          }
          return SpinKitThreeInOut(
            color: Colors.pinkAccent,
            size: 40.0,
          );
        },
      ),
    );
  }
}
