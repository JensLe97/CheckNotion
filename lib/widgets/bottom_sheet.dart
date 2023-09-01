import 'package:checknotion/screens/settings.dart';
import 'package:flutter/material.dart';

class MenuItems extends StatelessWidget {
  const MenuItems({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ListTile(
            leading: new Icon(Icons.settings),
            title: new Text('Einstellungen'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const Settings(),
                ),
              );
            },
          ),
          ListTile(
            leading: new Icon(Icons.photo),
            title: new Text('Fotos'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: new Icon(Icons.music_note),
            title: new Text('Musik'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: new Icon(Icons.videocam),
            title: new Text('Video'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: new Icon(Icons.share),
            title: new Text('Teilen'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
