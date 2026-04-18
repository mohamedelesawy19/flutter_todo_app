import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/tasks_controller.dart';
import 'custom_text.dart';

class TaskView extends StatelessWidget {
  const TaskView({
    Key? key,
    required this.index,
  }) : super(key: key);
  final int index;

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<TasksController>();

    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(top: 12, left: 16, right: 12),
      child: Dismissible(
        background: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Align(
              alignment: Alignment.centerLeft,
              child: Image.asset('images/trash.png')),
        ),
        secondaryBackground: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: Align(
              alignment: Alignment.centerRight,
              child: Image.asset('images/trash.png')),
        ),
        key: ObjectKey(homeController.tasks[index]),
        onDismissed: (direction) async {
          await homeController.removeTask(index);
        },
        child: Card(
          elevation: 2,
          child: Obx(
            () {
              final task = homeController.tasks[index];
              final textDecoration = task.isDone.value
                  ? TextDecoration.lineThrough
                  : TextDecoration.none;
              final isReminderTask =
                  homeController.reminderTaskId.value == task.id;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 6.5,
                    height: height * 0.07,
                    decoration: BoxDecoration(
                      color: homeController.categoryColor(index),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(5),
                        bottomLeft: Radius.circular(5),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Checkbox(
                          value: task.isDone.value,
                          onChanged: (val) async {
                            await homeController.changeIsDone(task);
                          },
                        ),
                        CustomText(
                          title: task.time.format(context),
                          color: Colors.black54,
                          size: 14,
                          decoration: textDecoration,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomText(
                            title: task.title,
                            size: 18,
                            decoration: textDecoration,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      final isSelected = homeController.setReminderTask(task);
                      if (!isSelected) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reminder set for "${task.title}"'),
                          duration: const Duration(milliseconds: 1200),
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.notifications,
                      color: isReminderTask ? Colors.amber : Colors.grey,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
