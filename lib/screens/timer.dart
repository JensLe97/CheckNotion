import 'package:flutter/material.dart';

class Timer extends StatefulWidget {
  const Timer({Key? key}) : super(key: key);

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: IndexedStack(children: [
          Center(
            child: Text('Event-Timer'),
          ),
        ]),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                //
              },
              icon: Icon(Icons.add))
        ],
      ),
      // body:
    );
  }
}
