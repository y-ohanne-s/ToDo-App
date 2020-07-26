import 'package:crud_app/DbHelper.dart';
import 'package:crud_app/Todo.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoAlter extends StatefulWidget {
  final String appBarTitle;
  final Todo todo;

  TodoAlter(this.todo, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return TodoAlterState(this.todo, this.appBarTitle);
  }
}

class TodoAlterState extends State<TodoAlter> {
  static var _priorities = ['High', 'Low'];

  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Todo todo;

  TextEditingController titleController = TextEditingController();
  TextEditingController descController = TextEditingController();

  TodoAlterState(this.todo, this.appBarTitle);

  void updatePriorityAsInt(String value) {
    switch (value) {
      case 'High':
        todo.priority = 1;
        break;
      case 'Low':
        todo.priority = 2;
        break;
    }
  }

  String getPriorityAsString(int value) {
    String priority;
    switch (value) {
      case 1:
        priority = _priorities[0];
        break;
      case 2:
        priority = _priorities[1];
        break;
    }
    return priority;
  }

  void updateTitle() {
    todo.title = titleController.text;
  }

  void updateDescription() {
    todo.description = descController.text;
  }

  void _save() async {
    Navigator.pop(context, true);

    todo.date = DateFormat.yMMMd().format(DateTime.now());
    int result;
    if (todo.id != null) {
      result = await helper.updateNote(todo);
    } else {
      result = await helper.insertNote(todo);
    }

    if (result != 0) {
      _showAlertDialog('Status', 'Todo Saved Successfully');
    } else {
      _showAlertDialog('Status', 'Problem Saving Todo');
    }
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  Container _buildForm() {
    return Container(
      height: 370.0,
      padding: EdgeInsets.only(top: 10.0, left: 20.0, right: 20.0),
      margin: EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Color(0xFFE0F2F1).withOpacity(0.9),
      ),
      child: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.fromLTRB(85, 0, 85, 0),
            child: RaisedButton(
              onPressed: () {},
              elevation: 10,
              color: Color(0xFFE0F2F1).withOpacity(0.9),
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  style: TextStyle(color: Colors.indigo, fontSize: 15),
                  value: getPriorityAsString(todo.priority),
                  onChanged: (valueSelectedByUser) {
                    setState(() {
                      debugPrint('User selected $valueSelectedByUser');
                      updatePriorityAsInt(valueSelectedByUser);
                    });
                  }),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: TextFormField(
              controller: titleController,
              style: TextStyle(),
              onChanged: (value) {
                updateTitle();
              },
              decoration: InputDecoration(
                  labelText: 'Title (required)',
                  labelStyle: TextStyle(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15.0))),
              maxLines: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: TextFormField(
              controller: descController,
              style: TextStyle(),
              onChanged: (value) {
                updateDescription();
              },
              decoration: InputDecoration(
                  labelText: 'More Info (optional)',
                  labelStyle: TextStyle(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(35.0))),
              maxLines: 5,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  color: Colors.indigo,
                  textColor: Colors.white,
                  elevation: 5.0,
                  child: Text(
                    'SAVE',
                    textScaleFactor: 1.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  onPressed: () {
                    setState(() {
                      if (titleController.text == '') {
                        _showAlertDialog('Error', 'Title Cannot be empty');
                      } else {
                        _save();
                      }
                    });
                  },
                ),
                SizedBox(
                  width: 10,
                ),
                RaisedButton(
                  color: Colors.indigo,
                  textColor: Colors.white,
                  elevation: 5.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Text(
                    'CANCEL',
                    textScaleFactor: 1.0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    titleController.text = todo.title;
    descController.text = todo.description;

    return Scaffold(
      backgroundColor: Color(0xFFE0F2F1).withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Color(0xFFE0F2F1).withOpacity(0.7),
        title: Text(
          appBarTitle,
          style: TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
      ),
      body: _buildForm(),
    );
  }
}
