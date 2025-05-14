import 'package:dima_project/utils/myThemeData.dart';
import 'package:dima_project/screens/authenticationPage.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/homePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simply Travel',
      theme: MyThemeData.getTheme(isTablet: ScreenSize.isTablet(context)),
      home: StreamBuilder(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot){
            if(snapshot.hasData){
              print(ScreenSize.isTablet(context));
              return const MyHomePage(title: 'Simply Travel');
            }else{
              return AuthPage();
            }
          }
      ),
    );
  }
}