import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:checknotion/helpers/db_helper.dart';
import 'package:checknotion/models/item_model.dart';
import 'package:checknotion/models/task_model.dart';

class Todo extends StatefulWidget {
  const Todo({Key? key}) : super(key: key);

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  late Future<List<Item>> _itemList;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      // Items are of type Task
      _itemList = DbHelper.instance.getItemList('task_table');
    });
  }

  // Alert Dialog Popup for entering a Todo element
  Future<void> _showAddTodo(BuildContext context, Task? task) async {
    final TextEditingController _textEditingController =
        TextEditingController(text: task != null ? task.title : null);
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Todo Eintrag"),
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
                    decoration: InputDecoration(hintText: "Neue Aufgabe..."),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // New task must be created and inserted
                    if (task == null) {
                      Task newTask =
                          Task(title: _textEditingController.text, done: 0);
                      DbHelper.instance.insertItem(newTask);
                      _updateTaskList();
                      Navigator.of(context).pop();
                    } else {
                      // Update the given task
                      task.title = _textEditingController.text;
                      DbHelper.instance.updateItem(task);
                      _updateTaskList();
                      Navigator.of(context).pop();
                    }
                  }
                },
                // Button label
                child: task == null ? Text("Hinzufügen") : Text("Ändern"),
              ),
            ],
          );
        });
  }

  // One single task item for the list
  Widget _task(Task task) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
      title: Text(
        task.title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
        style: TextStyle(
          fontSize: 18,
          decoration:
              task.done == 0 ? TextDecoration.none : TextDecoration.lineThrough,
        ),
      ),
      trailing: IconButton(
        iconSize: 28,
        onPressed: () {
          task.done = task.done == 1 ? 0 : 1;
          DbHelper.instance.updateItem(task);
          _updateTaskList();
        },
        icon: task.done == 1
            ? Icon(Icons.check_circle)
            : Icon(Icons.circle_outlined),
        color: task.done == 1 ? Colors.green : Colors.grey,
      ),
      onTap: () => {
        // Update the current task that was clicked
        _showAddTodo(context, task),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Whole content containing appbar and ListView
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Todo Liste'),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                // Add new task to the list
                _showAddTodo(context, null);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: Container(
        // The Listview is based on the Future<List<Task>>
        child: FutureBuilder(
          future: _itemList,
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
              // a _task for each item
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  child: Column(
                    children: [
                      Dismissible(
                        key: UniqueKey(),
                        onDismissed: (direction) {
                          DbHelper.instance.deleteItem(
                              snapshot.data!.cast<Task>()[index],
                              snapshot.data!.cast<Task>()[index].id!);
                          snapshot.data!.removeAt(index);
                          _updateTaskList();
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
                        child: _task(snapshot.data!.cast<Task>()[index]),
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
