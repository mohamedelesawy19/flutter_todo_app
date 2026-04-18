import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum Category {
  personal,
  work,
  meeting,
  study,
}

class Task {
  final int? id;
  final String title;
  final Category category;
  final TimeOfDay time;
  final RxBool isDone;

  Task({
    this.id,
    required this.title,
    required this.category,
    required this.time,
    bool isDone = false,
  }) : isDone = isDone.obs;
}
