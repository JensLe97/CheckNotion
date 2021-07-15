import 'package:flutter/material.dart';
import 'package:little_tricks/calc.dart';
import 'package:little_tricks/note.dart';
import 'package:little_tricks/quiz.dart';
import 'package:little_tricks/timer.dart';
import 'package:little_tricks/todo.dart';

void main() {
  runApp(LittleTricks());
}

class LittleTricks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
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
    Note(),
    Todo(),
    Quiz(),
    Timer(),
    Calc(),
  ];

  List<Widget> _tabHeaders = <Widget>[
    Text('Notizen'),
    Text('Todo Liste'),
    Text('Quiz'),
    Text('Event-Timer'),
    Text('Taschenrechner'),
  ];

  void _onTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: IndexedStack(children: [
          Center(
            child: _tabHeaders.elementAt(_currentIndex),
          ),
        ]),
      ),
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
              label: 'Todo',
              icon: Icon(Icons.check_box_outlined)
          ),
          BottomNavigationBarItem(
              label: 'Quiz',
              icon: Icon(Icons.quiz_outlined)
          ),
          BottomNavigationBarItem(
              label: 'Timer',
              icon: Icon(Icons.event_outlined)
          ),
          BottomNavigationBarItem(
              label: 'Rechner',
              icon: Icon(Icons.calculate_outlined)
          ),
        ],
      ),
    );
  }
}
