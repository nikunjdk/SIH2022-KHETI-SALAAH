import 'package:connection_notifier/connection_notifier.dart';
import 'package:flutter/material.dart';
import 'package:sih/screens/startup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return ConnectionNotifier(
      child: MaterialApp(
        title: 'Kheti Salaah',
        theme: ThemeData(
          primarySwatch: MaterialColor(
              const Color.fromRGBO(38, 140, 67, 1).value, const <int, Color>{
            50: Color.fromRGBO(38, 140, 67, .1),
            100: Color.fromRGBO(38, 140, 67, .2),
            200: Color.fromRGBO(38, 140, 67, .3),
            300: Color.fromRGBO(38, 140, 67, .4),
            400: Color.fromRGBO(38, 140, 67, .5),
            500: Color.fromRGBO(38, 140, 67, .6),
            600: Color.fromRGBO(38, 140, 67, .7),
            700: Color.fromRGBO(38, 140, 67, .8),
            800: Color.fromRGBO(38, 140, 67, .9),
            900: Color.fromRGBO(38, 140, 67, 1),
          }),
        ),
        home: const Startup(),
      ),
    );
  }
}
