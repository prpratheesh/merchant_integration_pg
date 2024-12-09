import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_page.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainPage());
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return MainPageState();
  }
}

class MainPageState extends State<MainPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "NextGen Robotics",
        theme: ThemeData(
          textTheme: GoogleFonts.caladeaTextTheme(), // Set font globally
          scaffoldBackgroundColor: Colors.white, // Set the default background color to white
          appBarTheme: const AppBarTheme(
            color: Color(0xFF003323), // Customize AppBar background color
          ),
          // textTheme: const TextTheme(
          //   bodyMedium: TextStyle(color: Colors.black), // Set default text color
          // ),
        ),
        debugShowCheckedModeBanner: false,
        home: const LoginPage());
  }
}
