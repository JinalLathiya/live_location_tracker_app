import 'package:flutter/material.dart';

import 'Screens/Homepage.dart';
import 'Screens/web_view_page.dart';

void main() {
  runApp(
    const MyApp(),
  );
}

double lat = 0;
double long = 0;

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const HomePage(),
        'web_view': (context) => const Web_View_Page(),
      },
    );
  }
}
