import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:we_talk/screens/splash_screen.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home_screen.dart';

late Size mq;


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
  .then((value){
     _initializeFirebase();
  runApp(const MyApp());
  });

}
class MyApp extends StatelessWidget {
  const MyApp({Key? key});
  @override
  MaterialApp build(BuildContext context) { 
    return MaterialApp(
      title: 'Welcome to We Talk', 
      debugShowCheckedModeBanner:false,
      theme: ThemeData( 
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 1,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
          backgroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen (), 
      );;
  }
}
_initializeFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
);
}

