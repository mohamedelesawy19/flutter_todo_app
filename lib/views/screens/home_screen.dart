import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:todo/constants.dart';
import 'package:todo/views/widgets/task_view.dart';

import '../../controllers/tasks_controller.dart';
import '../widgets/no_tasks_yet.dart';
import '../widgets/today_reminder.dart';
import '../widgets/top_bar.dart';
import './add_task_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TasksController());
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(double.infinity, height * 0.29),
        child: Container(
          decoration: const BoxDecoration(
            gradient: kGradientAppbar,
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [TopBar(), TodayReminder()],
            ),
          ),
        ),
      ),
      body: Obx(() {
        return controller.tasks.isEmpty
            ? const NoTasksYet()
            : ListView.builder(
                itemCount: controller.length(),
                itemBuilder: (ctx, idx) {
                  return TaskView(
                    index: idx,
                  );
                });
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _modalBottomSheet(context, controller);
        },
        backgroundColor: kSecondColor,
        elevation: 10,
        child: const Icon(Icons.add, size: 40),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _modalBottomSheet(BuildContext context, TasksController controller) {
    controller.resetAddTaskForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.elliptical(200, 40),
        ),
      ),
      builder: (context) {
        return const AddTaskScreen();
      },
    );
  }
}
