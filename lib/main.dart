import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class Task {
  String name;
  bool isCompleted;

  Task(this.name, {this.isCompleted = false});
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> _tasks = [];
  String _filter = 'All'; // Hantera filtreringen (All, Done, Undone)

  void _addTask(String taskName) {
    setState(() {
      _tasks.add(Task(taskName));
    });
  }

  void _toggleTaskCompletion(int index) {
    setState(() {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
    });
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  List<Task> _getFilteredTasks() {
    if (_filter == 'Done') {
      return _tasks.where((task) => task.isCompleted).toList();
    } else if (_filter == 'Undone') {
      return _tasks.where((task) => !task.isCompleted).toList();
    }
    return _tasks; // Visa alla uppgifter
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To do'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(onTaskAdded: _addTask),
                ),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String result) {
              setState(() {
                _filter = result;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'All',
                child: Text('Show All'),
              ),
              const PopupMenuItem<String>(
                value: 'Done',
                child: Text('Show Done'),
              ),
              const PopupMenuItem<String>(
                value: 'Undone',
                child: Text('Show Undone'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _getFilteredTasks().length,
              itemBuilder: (context, index) {
                final task = _getFilteredTasks()[index];
                return ListTile(
                  title: Text(
                    task.name,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteTask(index);
                    },
                  ),
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      _toggleTaskCompletion(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AddTaskScreen extends StatelessWidget {
  final Function(String) onTaskAdded;
  final TextEditingController _controller = TextEditingController();

  AddTaskScreen({super.key, required this.onTaskAdded});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Task'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'What are you going to do?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_controller.text.isNotEmpty) {
                  onTaskAdded(_controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}