import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiUrl = 'https://todoapp-api.apps.k8s.gu.se/todos';
const String apiKey = '7b3fddd3-a6a0-47be-90e5-6eaf1c2ec073';

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
  String id;
  String title;
  bool done;

  Task({required this.id, required this.title, required this.done});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      done: json['done'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'done': done,
    };
  }
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Task> _tasks = [];
  String _filter = 'All'; 
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await http.get(Uri.parse('$apiUrl?key=$apiKey'));
      if (response.statusCode == 200) {
        final List<dynamic> taskJson = json.decode(response.body);
        setState(() {
          _tasks = taskJson.map((json) => Task.fromJson(json)).toList();
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load tasks';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addTask(String taskTitle) async {
    final newTask = {'title': taskTitle, 'done': false};
    final response = await http.post(
      Uri.parse('$apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(newTask),
    );
    if (response.statusCode == 200) {
      _fetchTasks(); 
    } else {
      print('Failed to add task');
    }
  }

  Future<void> _toggleTaskCompletion(Task task) async {
    final updatedTask = {'title': task.title, 'done': !task.done};
    final response = await http.put(
      Uri.parse('$apiUrl/${task.id}?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(updatedTask),
    );
    if (response.statusCode == 200) {
      _fetchTasks(); 
    } else {
      print('Failed to update task');
    }
  }

  
  Future<void> _deleteTask(String taskId) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$taskId?key=$apiKey'),
    );
    if (response.statusCode == 200) {
      _fetchTasks(); 
    } else {
      print('Failed to delete task');
    }
  }

  
  List<Task> _getFilteredTasks() {
    switch (_filter) {
      case 'Done':
        return _tasks.where((task) => task.done).toList();
      case 'Undone':
        return _tasks.where((task) => !task.done).toList();
      default:
        return _tasks;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : Column(
                  children: <Widget>[
                    Expanded(
                      child: ListView.builder(
                        itemCount: _getFilteredTasks().length,
                        itemBuilder: (context, index) {
                          final task = _getFilteredTasks()[index];
                          return ListTile(
                            title: Text(
                              task.title,
                              style: TextStyle(
                                decoration: task.done
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                            leading: Checkbox(
                              value: task.done,
                              onChanged: (bool? value) {
                                _toggleTaskCompletion(task);
                              },
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteTask(task.id);
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