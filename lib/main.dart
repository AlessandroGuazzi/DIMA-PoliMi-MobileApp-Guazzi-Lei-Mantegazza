import 'package:dima_project/utils/myThemeData.dart';
import 'package:dima_project/screens/authenticationPage.dart';
import 'package:dima_project/services/authService.dart';
import 'package:dima_project/utils/screenSize.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/homePage.dart';

final GlobalKey<_MyAppState> myAppKey = GlobalKey<_MyAppState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: myAppKey);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  ThemeMode _themeMode = ThemeMode.light;

  void toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  ThemeMode get currentTheme => _themeMode;


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simply Travel',
      theme: MyThemeData.getLightTheme(isTablet: ScreenSize.isTablet(context)),
      darkTheme: MyThemeData.getDarkTheme(isTablet: ScreenSize.isTablet(context)),
      themeMode: _themeMode,
      home: StreamBuilder(
          stream: AuthService().authStateChanges,
          builder: (context, snapshot){
            if(snapshot.hasData){
              return const MyHomePage(title: 'Simply Travel');
            }else{
              return const AuthPage();
            }
          }
      ),
    );
  }
}