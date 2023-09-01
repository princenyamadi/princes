import 'package:flutter/material.dart';
import 'package:princes/logic.dart';

class TodoFormPage extends StatefulWidget {
  final TodoDB db;
  final Todo? todo;
  const TodoFormPage({required this.db, this.todo, super.key});

  @override
  State<TodoFormPage> createState() => _TodoFormPageState();
}

class _TodoFormPageState extends State<TodoFormPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    if (widget.todo != null) {
      titleController.text = widget.todo!.title;
      descriptionController.text = widget.todo!.description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(widget.todo == null ? 'Create New Todo' : 'Update todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'eg. Clean my room',
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: descriptionController,
                maxLines: 8,
                minLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'eg Pack my things, move them',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    if (widget.todo == null) {
                      final result = await widget.db.create(
                          titleController.text, descriptionController.text);

                      if (result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Created todo successfully.')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error creating todo.')));
                      }
                    } else {
                      final newTodo = Todo(widget.todo!.id,
                          titleController.text, descriptionController.text);
                      final result = await widget.db.update(newTodo);

                      if (result) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Updated todo successfully.')));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Error updating todo.')));
                      }
                      Navigator.pop(context);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
