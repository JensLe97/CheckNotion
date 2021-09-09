import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:little_tricks/helpers/db_helper.dart';
import 'package:little_tricks/models/item_model.dart';
import 'package:little_tricks/models/time_model.dart';

class Timer extends StatefulWidget {
  const Timer({Key? key}) : super(key: key);

  @override
  _TimerState createState() => _TimerState();
}

class _TimerState extends State<Timer> {
  late Future<List<Item>> _timeList;
  final _formKey = GlobalKey<FormState>();

  String _selectedDate = DateTime.now().toIso8601String();

  // Language of Date Formats
  String _locale = 'de';
  String _timeName = ' Uhr';

  @override
  void initState() {
    super.initState();
    _updateTimeList();
  }

  _updateTimeList() {
    setState(() {
      _timeList = DbHelper.instance.getItemList('time_table');
    });
  }

  _pickDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        locale: const Locale('de'),
        initialDate: DateTime.now(),
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 100));
    if (picked != null)
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          DateTime.parse(_selectedDate).hour,
          DateTime.parse(_selectedDate).minute,
        ).toIso8601String();
        controller.text =
            DateFormat.yMMMEd(_locale).format(DateTime.parse(_selectedDate));
      });
  }

  _pickTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        if (MediaQuery.of(context).alwaysUse24HourFormat) {
          return child!;
        } else {
          return Localizations.override(
            context: context,
            locale: Locale('de'),
            child: child,
          );
        }
      },
    );
    if (picked != null)
      setState(() {
        _selectedDate = DateTime(
          DateTime.parse(_selectedDate).year,
          DateTime.parse(_selectedDate).month,
          DateTime.parse(_selectedDate).day,
          picked.hour,
          picked.minute,
        ).toIso8601String();
        controller.text = TimeOfDay.fromDateTime(DateTime.parse(_selectedDate))
                .format(context) +
            _timeName;
      });
  }

  String _format(int? time) {
    return time.toString().padLeft(2, '0');
  }

  String _timeFormat(CurrentRemainingTime time) {
    return '${time.days != null ? _format(time.days) : '00'}:' +
        '${time.hours != null ? _format(time.hours) : '00'}:' +
        '${time.min != null ? _format(time.min) : '00'}:' +
        '${time.sec != null ? _format(time.sec) : '00'}';
  }

  // Alert Dialog Popup for entering a Todo element
  Future<void> _showAddTime(BuildContext context, Time? time) async {
    final TextEditingController _textEditingController =
        TextEditingController(text: time != null ? time.title : null);
    final TextEditingController _dateEditingController = TextEditingController(
        text: time != null
            ? DateFormat.yMMMEd(_locale).format(DateTime.parse(time.time))
            : DateFormat.yMMMEd(_locale).format(DateTime.now()));
    final TextEditingController _timeEditingController = TextEditingController(
        text: time != null
            ? TimeOfDay.fromDateTime(DateTime.parse(time.time))
                    .format(context) +
                _timeName
            : TimeOfDay.now().format(context) + _timeName);
    // Always make sure that the selectedDate is reset for a new entry
    if (time == null) _selectedDate = DateTime.now().toIso8601String();
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Event Countdown"),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _textEditingController,
                    validator: (value) {
                      return value!.isNotEmpty
                          ? null
                          // Text for invalid data
                          : "Beschreibung erforderlich!";
                    },
                    // Text in input field
                    decoration: InputDecoration(hintText: "Neues Event..."),
                  ),
                  SizedBox(height: 20),
                  // DateTime Selection
                  TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(-5.0),
                    ),
                    readOnly: true,
                    controller: _dateEditingController,
                    validator: (value) {
                      return value!.isNotEmpty
                          ? null
                          // Text for invalid data
                          : "Gültiges Datum erforderlich!";
                    },
                    onTap: () {
                      _pickDate(context, _dateEditingController);
                    },
                  ),
                  SizedBox(height: 20),
                  // TimeOfDay Selection
                  TextFormField(
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(-5.0),
                    ),
                    readOnly: true,
                    controller: _timeEditingController,
                    validator: (value) {
                      return value!.isNotEmpty
                          ? null
                          // Text for invalid data
                          : "Gültige Uhrzeit erforderlich!";
                    },
                    onTap: () {
                      _pickTime(context, _timeEditingController);
                    },
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // New time must be created and inserted
                    if (time == null) {
                      Time newTime = Time(
                          title: _textEditingController.text,
                          time: _selectedDate);
                      DbHelper.instance.insertItem(newTime);
                      _updateTimeList();
                      Navigator.of(context).pop();
                    } else {
                      // Update the given time
                      time.title = _textEditingController.text;
                      time.time = _selectedDate;
                      DbHelper.instance.updateItem(time);
                      _updateTimeList();
                      Navigator.of(context).pop();
                    }
                  }
                },
                // Button label
                child: time == null ? Text("Hinzufügen") : Text("Ändern"),
              ),
            ],
          );
        });
  }

  // One single time item for the list
  Widget _time(Time time) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      title: Text(
        time.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      trailing: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Color(0xAAb1b4ba),
            shape: BoxShape.rectangle),
        child: CountdownTimer(
          endTime: DateTime.parse(time.time).millisecondsSinceEpoch,
          widgetBuilder: (_, CurrentRemainingTime? time) {
            // Timer is over
            if (time == null) {
              return Text('Zeit erreicht',
                  style: TextStyle(
                    foreground: Paint()
                      ..shader = ui.Gradient.linear(
                        const Offset(0, 0),
                        Offset(MediaQuery.of(context).size.width, 0),
                        <Color>[
                          Colors.red,
                          Colors.orange,
                          Colors.yellow,
                          Colors.green,
                          Colors.blue,
                          Colors.purple
                        ],
                        <double>[
                          0.0,
                          0.2,
                          0.4,
                          0.6,
                          0.8,
                          1.0,
                        ],
                      ),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ));
            }
            // Timer is still running
            return Text(_timeFormat(time),
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ));
          },
        ),
      ),
      onTap: () => {
        // Update the current time that was clicked
        _showAddTime(context, time),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Whole content containing appbar and ListView
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Event-Timer'),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                // Add new time to the list
                _showAddTime(context, null);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: Container(
        // The Listview is based on the Future<List<Time>>
        child: FutureBuilder(
          future: _timeList,
          builder: (context, AsyncSnapshot<List<Item>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Platform.isIOS
                    ? CupertinoActivityIndicator()
                    : CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              // Build the list with all data from the database and create
              // a _time for each item
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Column(
                    children: [
                      Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          DbHelper.instance.deleteItem(
                              snapshot.data!.cast<Time>()[index],
                              snapshot.data!.cast<Time>()[index].id!);
                          snapshot.data!.removeAt(index);
                        },
                        direction: DismissDirection.endToStart,
                        // Container behind the dismissible -> delete banner
                        background: Container(
                          padding: EdgeInsets.only(right: 20.0),
                          alignment: Alignment.centerRight,
                          color: Colors.red,
                          child: Text(
                            'Löschen',
                            textAlign: TextAlign.right,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        // The actual ListTile
                        child: _time(snapshot.data!.cast<Time>()[index]),
                      ),
                      Divider(
                        height: 0, // Default = 16
                        indent: 40,
                        color: Colors.black,
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
