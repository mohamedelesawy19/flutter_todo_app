import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../constants.dart';
import '../../controllers/tasks_controller.dart';
import 'custom_text.dart';

class TodayReminder extends StatelessWidget {
  const TodayReminder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();
    final height = MediaQuery.of(context).size.height;

    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 0, bottom: 16, right: 16),
      child: Container(
        padding:
            const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 16),
        decoration: BoxDecoration(
          gradient: kGradientContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Obx(() {
          final reminderTask = controller.reminderTask;
          final title = reminderTask?.title ?? 'Tap bell icon in any task';
          final time = reminderTask?.time.format(context) ?? '--:--';

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomText(
                        title: 'Today Reminder',
                        color: Colors.white,
                        size: 22.2,
                        fontWeight: FontWeight.w700),
                    const SizedBox(height: 16),
                    CustomText(
                      title: title,
                      size: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    CustomText(
                        title: time,
                        size: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Image.asset('images/golden_bell_icon.png', height: height * .13)
            ],
          );
        }),
      ),
    );
  }
}
