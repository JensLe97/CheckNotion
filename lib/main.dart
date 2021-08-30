import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:little_tricks/screens/calc.dart';
import 'package:little_tricks/screens/notes.dart';
import 'package:little_tricks/screens/quiz.dart';
import 'package:little_tricks/screens/timer.dart';
import 'package:little_tricks/screens/todo.dart';

void main() {
  runApp(LittleTricks());
}

class LittleTricks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale('de'),
        const Locale('en'),
      ],
      // Language of the App is German
      locale: Locale('de'),
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(centerTitle: true)),
      home: NavBar(title: 'Little Tricks'),
    );
  }
}

class NavBar extends StatefulWidget {
  NavBar({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int _currentIndex = 0;
  List<Widget> _tabs = <Widget>[
    Notes(),
    Todo(),
    Quiz(),
    Timer(),
    Calc(),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(children: [
        Center(
          child: _tabs.elementAt(_currentIndex),
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        onTap: _onTap,
        items: [
          BottomNavigationBarItem(
            label: 'Notizen',
            icon: Icon(Icons.sticky_note_2_outlined),
          ),
          BottomNavigationBarItem(
              label: 'Todo', icon: Icon(Icons.check_box_outlined)),
          BottomNavigationBarItem(
              label: 'Quiz', icon: Icon(Icons.quiz_outlined)),
          BottomNavigationBarItem(
              label: 'Timer', icon: Icon(Icons.event_outlined)),
          BottomNavigationBarItem(
              label: 'Rechner', icon: Icon(Icons.calculate_outlined)),
        ],
      ),
    );
  }
}
