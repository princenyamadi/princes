import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:princes/logic.dart';
import 'package:princes/todo_form_page.dart';
import 'package:princes/view_todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final TodoDB _crudStorage;

  @override
  void initState() {
    _crudStorage = TodoDB('db.sqlite');
    _crudStorage.open();
    super.initState();
  }

  Future<bool> showDeleteDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (conext) {
          return AlertDialog(
            content: Text('Are you sure you want to delete this item?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text('Delete'),
              ),
            ],
          );
        }).then((value) => value ?? false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text('Table Resolver'),
      ),
      body: StreamBuilder(
        stream: _crudStorage.all(),
        builder: (context, snapshot) {
          print('snapshot: $snapshot');
          switch (snapshot.connectionState) {
            case ConnectionState.active:
            case ConnectionState.waiting:
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              final todos = snapshot.data as List<Todo>;

              return Column(
                children: [
                  // CompseWidget(
                  //   onCompose: (firstName, lastName) async {
                  //     print('firstName: $firstName, lastName: $lastName');
                  //     await _crudStorage.create(firstName, lastName);
                  //   },
                  // ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      return ListTile(
                        onTap: () {
                          // showUpdateDialog(context, todo).then((value) {
                          //   if (value != null) {
                          //     _crudStorage.update(value);
                          //   }
                          // });

                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ViewTodoPage(
                                      db: _crudStorage, todo: todo)));
                        },
                        title: Text(todo.title),
                        trailing: TextButton(
                          child: const Icon(Icons.disabled_by_default),
                          onPressed: () async {
                            final showDelete = await showDeleteDialog(context);
                            if (showDelete) {
                              // todo: make deletion here
                              log('deleting');
                              await _crudStorage.delete(todo);
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              );

            case ConnectionState.none:
              break;
            case ConnectionState.done:
              break;

            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }

          return SizedBox(
            child: Text('Simple things'),
          );
          // return ListView.builder(itemBuilder: (context, index) {
          //   return Card(
          //     elevation: 0,
          //     color: Colors.grey[200],
          //     child: ListTile(
          //       onTap: () {
          //         Navigator.push(context,
          //             MaterialPageRoute(builder: (context) => ViewTodoPage()));
          //       },
          //       title: Text('$index'),
          //     ),
          //   );
          // });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TodoFormPage(
                        db: _crudStorage,
                      )));
        },
        tooltip: 'Add a new todo',
        child: Icon(Icons.add),
      ),
    );
  }

  //    Future<bool> showDeleteDialog(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       builder: (conext) {
  //         return AlertDialog(
  //           content: Text('Are you sure you want to delete this item?'),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop(false);
  //               },
  //               child: const Text('No'),
  //             ),
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pop(true);
  //               },
  //               child: const Text('Delete'),
  //             ),
  //           ],
  //         );
  //       }).then((value) => value ?? false);
  // }
}
