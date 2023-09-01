import 'package:flutter/material.dart';
import 'package:princes/logic.dart';

import 'todo_form_page.dart';

class ViewTodoPage extends StatelessWidget {
  final Todo todo;
  final TodoDB db;
  const ViewTodoPage({
    super.key,
    required this.db,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(todo.title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Text(todo.description),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TodoFormPage(
                        db: db,
                        todo: todo,
                      )));
        },
        child: Icon(Icons.edit),
      ),
    );
  }
}
