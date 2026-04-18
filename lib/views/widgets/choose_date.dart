import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/tasks_controller.dart';
import 'custom_text.dart';

class ChooseDate extends StatelessWidget {
  const ChooseDate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TasksController>();

    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton(
          onPressed: (){
            _selectTime(context);
          },
          child: Row(
            children: [
              Obx(
                    () =>  CustomText(title: 'Choose date - ${controller.selectedTime.value.format(context)} ', fontWeight: FontWeight.w500,),),
              const Icon(Icons.arrow_downward_rounded, color: Colors.black,)
            ],
          )
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final controller = Get.find<TasksController>();
    final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: controller.selectedTime.value,
        builder: (BuildContext context, Widget? child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      );});

    if (picked != null && picked != controller.selectedTime.value ) {
      controller.selectedTime.value = picked;
    }
  }

}
