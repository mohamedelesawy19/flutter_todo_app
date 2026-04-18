import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import '../constants.dart';
import '../models/task.dart';

class TasksController extends GetxController {
  Database? database;
  final RxList<Task> tasks = <Task>[].obs;
  final RxnInt reminderTaskId = RxnInt();

  // Add task screen state.
  final selectedTime = TimeOfDay.now().obs;
  final titleController = TextEditingController().obs;
  final category = Category.personal.obs;

  int length() => tasks.length;

  Task? get reminderTask {
    final selectedId = reminderTaskId.value;
    if (selectedId == null) {
      return null;
    }

    for (final task in tasks) {
      if (task.id == selectedId) {
        return task;
      }
    }

    return null;
  }

  bool setReminderTask(Task task) {
    if (task.id == null) {
      return false;
    }

    reminderTaskId.value = task.id;
    return true;
  }

  @override
  void onInit() {
    super.onInit();
    createDatabase();
  }

  @override
  void onClose() {
    titleController.value.dispose();
    super.onClose();
  }

  Future<void> removeTask(int idx) async {
    if (idx < 0 || idx >= tasks.length) return;
    final task = tasks[idx];

    if (task.id == reminderTaskId.value) {
      reminderTaskId.value = null;
    }

    tasks.removeAt(idx);

    if (task.id != null) {
      await database?.delete(
        'tasks',
        where: 'id = ?',
        whereArgs: [task.id],
      );
    }
  }

  Color categoryColor(int idx) {
    switch (tasks[idx].category) {
      case Category.personal:
        return kPersonalColor;
      case Category.meeting:
        return kMeetingColor;
      case Category.study:
        return kStudyColor;
      case Category.work:
        return kWorkColor;
    }
  }

  Future<void> changeIsDone(Task task) async {
    final newValue = !task.isDone.value;
    task.isDone.value = newValue;

    if (task.id != null) {
      await database?.update(
        'tasks',
        {'done': newValue ? 1 : 0},
        where: 'id = ?',
        whereArgs: [task.id],
      );
    }
  }

  Future<void> createDatabase() async {
    database = await openDatabase(
      'todo.db',
      version: 1,
      onCreate: (database, version) async {
        await database.execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, time TEXT, category INTEGER, done INTEGER)',
        );
        debugPrint('database created');
      },
      onOpen: (database) async {
        debugPrint('database opened');
        await getTasksFromDB(database);
      },
    );

    if (database != null) {
      await getTasksFromDB(database!);
    }
  }

  Future<void> getTasksFromDB(Database database) async {
    final data = await database.query('tasks');
    final parsedTasks = data.map(_taskFromMap).toList()
      ..sort(_compareTasksByTime);
    tasks.assignAll(parsedTasks);

    final selectedReminderId = reminderTaskId.value;
    if (selectedReminderId != null) {
      final stillExists =
          parsedTasks.any((task) => task.id == selectedReminderId);
      if (!stillExists) {
        reminderTaskId.value = null;
      }
    }
  }

  int _compareTasksByTime(Task a, Task b) {
    final byTime = _toTotalMinutes(a.time).compareTo(_toTotalMinutes(b.time));
    if (byTime != 0) {
      return byTime;
    }

    final aId = a.id ?? -1;
    final bId = b.id ?? -1;
    return bId.compareTo(aId);
  }

  int _toTotalMinutes(TimeOfDay time) {
    return (time.hour * 60) + time.minute;
  }

  Task _taskFromMap(Map<String, Object?> map) {
    final idValue = map['id'];
    final taskId =
        idValue is int ? idValue : int.tryParse(idValue?.toString() ?? '');

    final doneValue = map['done'];
    final isDone =
        doneValue is int ? doneValue == 1 : doneValue?.toString() == '1';

    final categoryIndex = _safeCategoryIndex(map['category']);
    final dbTime = map['time']?.toString() ?? '09:00';

    return Task(
      id: taskId,
      title: map['title']?.toString() ?? '',
      category: Category.values[categoryIndex],
      time: _timeFromDB(dbTime),
      isDone: isDone,
    );
  }

  int _safeCategoryIndex(Object? value) {
    final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
    if (parsed == null) return 0;
    if (parsed < 0 || parsed >= Category.values.length) return 0;
    return parsed;
  }

  TimeOfDay _timeFromDB(String storedTime) {
    final parts = storedTime.split(':');
    if (parts.length != 2) {
      return TimeOfDay.now();
    }

    final parsedHour = int.tryParse(parts[0]);
    final parsedMinute = int.tryParse(parts[1]);

    if (parsedHour == null || parsedMinute == null) {
      return TimeOfDay.now();
    }

    final hour = parsedHour < 0 ? 0 : (parsedHour > 23 ? 23 : parsedHour);
    final minute =
        parsedMinute < 0 ? 0 : (parsedMinute > 59 ? 59 : parsedMinute);

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _timeToDB(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<bool> addTaskToDB({
    required String title,
    required TimeOfDay time,
    required Category category,
  }) async {
    final cleanedTitle = title.trim();
    if (cleanedTitle.isEmpty) return false;

    if (database == null) {
      await createDatabase();
    }

    final db = database;
    if (db == null) return false;

    try {
      await db.insert('tasks', {
        'title': cleanedTitle,
        'time': _timeToDB(time),
        'category': category.index,
        'done': 0,
      });
      await getTasksFromDB(db);
      return true;
    } catch (error) {
      debugPrint('error: $error');
      return false;
    }
  }

  void resetAddTaskForm() {
    titleController.value.clear();
    selectedTime.value = TimeOfDay.now();
    category.value = Category.personal;
  }
}
