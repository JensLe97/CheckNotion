import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:checknotion/screens/calc.dart';
import 'package:checknotion/screens/notes.dart';
import 'package:checknotion/screens/quiz.dart';
import 'package:checknotion/screens/timer.dart';
import 'package:checknotion/screens/todo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(CheckNotion());
}

class CheckNotion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('de'),
          const Locale('en'),
        ],
        // Language of the App is German
        locale: Locale('de'),
        title: 'CheckNotion',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(centerTitle: true),
          bottomSheetTheme:
              const BottomSheetThemeData(backgroundColor: Colors.transparent),
        ),
        home: NavBar(),
      ),
    );
  }
}

class NavBar extends StatefulWidget {
  NavBar({Key? key}) : super(key: key);

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
