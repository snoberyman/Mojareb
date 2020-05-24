import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_mentor_screen.dart';

import '../providers/mentors.dart';

class UserMentorItem extends StatelessWidget {
  final String id;
  final String name;
  final String imageUrl;

  UserMentorItem(this.id, this.name, this.imageUrl);

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text(
        "Delete",
        style: TextStyle(color: Colors.red),
      ),
      onPressed: () async {
        final scaffold = Scaffold.of(context);
        try {
          await Provider.of<Mentors>(context, listen: false).deleteMentor(id);
          // Navigator.of(context).pop();
        } catch (error) {
          scaffold.showSnackBar(SnackBar(
            content: Text(
              'something went wrong! deleting failed',
              textAlign: TextAlign.center,
            ),
          ));
        }
        Navigator.of(context).pop();
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text("Are you sure you want to delete this mentor permenantly?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(name),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditMentorscreen.routeName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showAlertDialog(context);
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
