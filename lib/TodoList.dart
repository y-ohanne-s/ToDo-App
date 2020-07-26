import 'dart:async';
import 'package:crud_app/TodoAlter.dart';
import 'package:crud_app/DbHelper.dart';
import 'package:crud_app/Todo.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return TodoListState();
  }
}

class TodoListState extends State<TodoList> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Todo> todoList;
  int count = 0;
  bool isChecked = false;

  Color getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.indigo;
        break;

      default:
        return Colors.indigo;
    }
  }

  Icon getPriorityIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;

      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _delete(BuildContext context, Todo todo) async {
    int result = await databaseHelper.deleteNote(todo.id);
    if (result != 0) {
      _showSnackBar(context, 'Todo Deleted Successfully');
      updateListView();
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void navigateToDetail(Todo todo, String title) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return TodoAlter(todo, title);
    }));

    if (result == true) {
      updateListView();
    }
  }

  void updateListView() {
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    dbFuture.then((database) {
      Future<List<Todo>> noteListFuture = databaseHelper.getNoteList();
      noteListFuture.then((todoList) {
        setState(() {
          this.todoList = todoList;
          this.count = todoList.length;
        });
      });
    });
  }

  Container noteContainer() {
    return Container(
      height: 200,
      width: 370,
      margin: EdgeInsets.all(15.0),
      padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Color(0xFFE0F2F1),
      ),
      child: getNoteListView(),
    );
  }

  ListView getNoteListView() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (context, index) {
        return Column(
          children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(width: 10.0),
                  Icon(
                    Icons.star,
                    color: getPriorityColor(this.todoList[index].priority),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Expanded(
                    child: Text(
                      this.todoList[index].title,
                      style: TextStyle(
                          fontSize: 20,
                          decoration:
                              isChecked ? TextDecoration.lineThrough : null,
                          fontStyle:
                              isChecked ? FontStyle.italic : FontStyle.normal,
                          fontWeight: isChecked ? FontWeight.w200 : null),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      navigateToDetail(this.todoList[index], 'View Todo');
                    },
                    child: Icon(
                      Icons.edit,
                      color: Colors.indigo[300],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      _delete(context, todoList[index]);
                      updateListView();
                    },
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            
            SizedBox(
              height: 20.0,
            ),
          ],
        );
      },
    );
  }

  Widget getDetailView() {
    return Expanded(
      child: Stack(
        children: <Widget>[
          Container(
            height: 250,
            width: 370,
            margin: EdgeInsets.all(15.0),
            padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Color(0xFFE0F2F1),
            ),
          ),
          ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: count,
            itemBuilder: (context, index) {
              return Container(
                height: 100,
                width: 150,
                margin: EdgeInsets.fromLTRB(40, 30, 0, 70),
                padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.grey[300],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Text(
                        this.todoList[index].title.toUpperCase(),
                        style: TextStyle(
                          color: Colors.indigo,
                          fontSize: 20,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                        this.todoList[index].description,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    if (todoList == null) {
      todoList = List<Todo>();
      updateListView();
    }
    return Scaffold(
      backgroundColor: Color(0xFFE0F2F1).withOpacity(0.9),
      appBar: AppBar(
        backgroundColor: Color(0xFFE0F2F1).withOpacity(0.7),
        elevation: 0.0,
        title: Text(
          'SIMPLE TO-DO',
          style: TextStyle(color: Colors.indigo),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 5.0,
          ),
          Center(
            child: Text(
              'QUICK TODOS',
              style: TextStyle(color: Colors.indigo, fontSize: 20.0),
            ),
          ),
          noteContainer(),
          getDetailView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          navigateToDetail(Todo('', '', 2), 'Add Todo');
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.indigo,
        tooltip: 'To create a new to-do',
      ),
    );
  }
}
