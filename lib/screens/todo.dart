import 'package:flutter/material.dart';
import 'package:little_tricks/helpers/db_helper.dart';
import 'package:little_tricks/models/task_model.dart';

class Todo extends StatefulWidget {
  const Todo({Key? key}) : super(key: key);

  @override
  _TodoState createState() => _TodoState();
}

class _TodoState extends State<Todo> {
  late Future<List<Task>> _taskList;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _updateTaskList();
  }

  _updateTaskList() {
    setState(() {
      _taskList = DbHelper.instance.getTaskList();
    });
  }

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
                          : "Beschreibung erforderlich!";
                    },
                    decoration: InputDecoration(hintText: "Neue Aufgabe..."),
                  )
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (task == null) {
                      Task newTask =
                          Task(title: _textEditingController.text, done: 0);
                      DbHelper.instance.insertTask(newTask);
                      _updateTaskList();
                      Navigator.of(context).pop();
                    } else {
                      task.title = _textEditingController.text;
                      DbHelper.instance.updateTask(task);
                      _updateTaskList();
                      Navigator.of(context).pop();
                    }
                  }
                },
                child: task == null ? Text("Hinzufügen") : Text("Ändern"),
              ),
            ],
          );
        });
  }

  Widget _task(Task task) {
    return Container(
      child: Column(
        children: [
          Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              DbHelper.instance.deleteTask(task.id!);
            },
            direction: DismissDirection.endToStart,
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
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              title: Text(
                task.title,
                style: TextStyle(
                  fontSize: 18,
                  decoration: task.done == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              trailing: IconButton(
                iconSize: 28,
                onPressed: () {
                  task.done = task.done == 1 ? 0 : 1;
                  DbHelper.instance.updateTask(task);
                  _updateTaskList();
                },
                icon: task.done == 1
                    ? Icon(Icons.check_circle_outline)
                    : Icon(Icons.circle_outlined),
                color: task.done == 1 ? Colors.green : Colors.grey,
              ),
              onTap: () => {_showAddTodo(context, task)},
            ),
          ),
          Divider(
            height: 0,
            indent: 40,
            color: Colors.black,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Todo Liste'),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                _showAddTodo(context, null);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: Container(
        child: FutureBuilder(
          future: _taskList,
          builder: (context, AsyncSnapshot<List<Task>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return _task(snapshot.data![index]);
              },
            );
          },
        ),
      ),
    );
  }
}
