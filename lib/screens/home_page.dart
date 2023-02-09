import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:to_do_app/data/local_storage.dart';
import 'package:to_do_app/main.dart';
import 'package:to_do_app/models/task_model.dart';
import 'package:to_do_app/screens/custom_search_delegate.dart';
import 'package:to_do_app/widgets/task_list_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<Task> _allTasks;
  late LocalStorage _localStorage;

  @override
  void initState() {
    super.initState();
    _localStorage = locator<LocalStorage>();
    _allTasks = <Task>[];
    getAllTaskFromDb();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          appBar: AppBar(
            title: GestureDetector(
              onTap: () {
                _showAddTaskBottomSheet(context);
              },
              child: const Text(
                'test',
                style: TextStyle(color: Colors.black),
              ).tr(),
            ),
            centerTitle: false,
            actions: [
              IconButton(
                onPressed: () {
                  _showSearchPage();
                },
                icon: const Icon(Icons.search),
              ),
              IconButton(
                onPressed: () {
                  _showAddTaskBottomSheet(context);
                },
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          body: _allTasks.isNotEmpty
              ? ListView.builder(
                  itemBuilder: (context, index) {
                    var _nowListElement = _allTasks[index];
                    return Dismissible(
                      background: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.delete,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          const Text('remove_task').tr()
                        ],
                      ),
                      key: Key(_nowListElement.id),
                      onDismissed: (direction) {
                        _allTasks.removeAt(index);
                        _localStorage.deleteTask(task: _nowListElement);
                        setState(() {});
                      },
                      child: TaskItem(task: _nowListElement),
                    );
                  },
                  itemCount: _allTasks.length,
                )
              : Center(
                  child: const Text('empty_task_list').tr(),
                )),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            width: MediaQuery.of(context).size.width,
            child: ListTile(
              title: TextField(
                autofocus: true,
                style: const TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'add_task'.tr(),
                  border: InputBorder.none,
                ),
                onSubmitted: (value) {
                  Navigator.of(context).pop();
                  if (value.length > 3) {
                    DatePicker.showTimePicker(
                      context,
                      showSecondsColumn: false,
                      onConfirm: (time) async {
                        var newAddTask =
                            Task.create(name: value, createdAt: time);

                        _allTasks.insert(0, newAddTask);
                        await _localStorage.addTask(task: newAddTask);
                        setState(() {});
                      },
                    );
                  }
                },
              ),
            ),
          );
        });
  }

  void getAllTaskFromDb() async {
    _allTasks = await _localStorage.getAllTasks();
    setState(() {});
  }

  void _showSearchPage() async {
    await showSearch(
        context: context, delegate: CustomSearchDelegate(allTasks: _allTasks));
    getAllTaskFromDb();
  }
}
