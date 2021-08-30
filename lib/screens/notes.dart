import 'package:flutter/material.dart';
import 'package:little_tricks/helpers/db_helper.dart';
import 'package:little_tricks/models/item_model.dart';
import 'package:little_tricks/models/note_model.dart';

class Notes extends StatefulWidget {
  const Notes({Key? key}) : super(key: key);

  @override
  _NotesState createState() => _NotesState();
}

class _NotesState extends State<Notes> {
  late Future<List<Item>> _noteList;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _updateNoteList();
  }

  _updateNoteList() {
    setState(() {
      _noteList = DbHelper.instance.getItemList('note_table');
    });
  }

  // Alert Dialog Popup for entering a Todo element
  Future<void> _showAddNote(BuildContext context, Note? note) async {
    final TextEditingController _textEditingController =
        TextEditingController(text: note != null ? note.title : null);
    final TextEditingController _contentEditingController =
        TextEditingController(text: note != null ? note.content : null);
    return await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Notiz"),
            content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      controller: _textEditingController,
                      validator: (value) {
                        return value!.isNotEmpty
                            ? null
                            // Text for invalid data
                            : "Titel erforderlich!";
                      },
                      // Text in input field
                      decoration: InputDecoration(
                          hintText: "Neue Notiz...", border: InputBorder.none),
                    ),
                    TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 10,
                      controller: _contentEditingController,
                      validator: (value) {
                        return value!.isNotEmpty
                            ? null
                            // Text for invalid data
                            : "Beschreibung erforderlich!";
                      },
                      // Text in input field
                      decoration: InputDecoration(hintText: "Inhalt..."),
                    )
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // New note must be created and inserted
                    if (note == null) {
                      Note newNote = Note(
                          title: _textEditingController.text,
                          content: _contentEditingController.text);
                      DbHelper.instance.insertItem(newNote);
                      _updateNoteList();
                      Navigator.of(context).pop();
                    } else {
                      // Update the given note
                      note.title = _textEditingController.text;
                      note.content = _contentEditingController.text;
                      DbHelper.instance.updateItem(note);
                      _updateNoteList();
                      Navigator.of(context).pop();
                    }
                  }
                },
                // Button label
                child: note == null ? Text("Hinzufügen") : Text("Ändern"),
              ),
            ],
          );
        });
  }

  // One single note item for the list
  Widget _note(Note note) {
    return Container(
      child: Column(
        children: [
          Dismissible(
            key: UniqueKey(),
            onDismissed: (direction) {
              DbHelper.instance.deleteItem(note, note.id!);
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
            // Actual list item
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 40, vertical: 10),
              title: Text(
                note.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  decoration: note.title.isNotEmpty
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                note.content,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: TextStyle(
                  fontSize: 18,
                  decoration: note.title.isNotEmpty
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              onTap: () => {
                // Update the current note that was clicked
                _showAddNote(context, note),
              },
            ),
          ),
          Divider(
            height: 0, // Default = 16
            indent: 40,
            color: Colors.black,
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Whole content containing appbar and ListView
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Notizen'),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                // Add new note to the list
                _showAddNote(context, null);
              },
              icon: Icon(Icons.add))
        ],
      ),
      body: Container(
        // The Listview is based on the Future<List<Note>>
        child: FutureBuilder(
          future: _noteList,
          builder: (context, AsyncSnapshot<List<Item>> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            return ListView.builder(
              // Build the list with all data from the database and create
              // a _note for each item
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return _note(snapshot.data!.cast<Note>()[index]);
              },
            );
          },
        ),
      ),
    );
  }
}
