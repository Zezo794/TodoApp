import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/task.dart';
import 'package:todo/ui/widgets/input_field.dart';

import '../../controllers/task_controller.dart';
import '../../services/theme_services.dart';
import '../theme.dart';
import '../widgets/button.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final taskController =TaskController.instance;
  TextEditingController titleController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  String startTime = DateFormat('hh:mm a').format(DateTime.now()).toString();
  String endTime = DateFormat('hh:mm a')
      .format(DateTime.now().add(Duration(minutes: 15)))
      .toString();
  int selectedRemind = 5;
  List<int> remindList = [0, 5, 10, 15, 20];
  String selectedRepeat = 'None';
  List<String> repeatList = ['None', 'Daily', 'Weekly', 'Monthly'];
  int selectedColor = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: context.theme.backgroundColor,
        leading: IconButton(
          onPressed: () async {
            await taskController.getTask();
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),
        elevation: 0,
        actions: [
          CircleAvatar(
            backgroundImage: AssetImage('images/person.jpeg'),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 10,
            ),
            Text(
              'Add Task',
              style: Themes().headingStyle,
            ),
            SizedBox(
              height: 10,
            ),
            InputField(
              title: 'Title',
              note: 'Enter title here.',
              controller: titleController,
            ),
            SizedBox(
              height: 10,
            ),
            InputField(
              title: 'Note',
              note: 'Enter note here.',
              controller: noteController,
            ),
            SizedBox(
              height: 10,
            ),
            InputField(
              title: 'Date',
              note: DateFormat.yMd().format(selectedDate),
              widget: IconButton(
                onPressed: () {
                  getDateFromUser();
                },
                icon: Icon(
                  Icons.calendar_today_outlined,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Expanded(
                  child: InputField(
                    title: 'Start Time',
                    note: startTime,
                    widget: IconButton(
                      onPressed: () {
                        getTimeFromUser(true);
                      },
                      icon: Icon(
                        Icons.access_time_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: InputField(
                    title: 'End Time',
                    note: endTime,
                    widget: IconButton(
                      onPressed: () {
                        getTimeFromUser(false);
                      },
                      icon: Icon(
                        Icons.access_time_rounded,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            InputField(
                title: 'Remind',
                note: '$selectedRemind minutes early',
                widget: Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Colors.blueGrey,
                      icon: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: Colors.grey,
                      ),
                      items: remindList
                          .map<DropdownMenuItem<String>>(
                              (e) => DropdownMenuItem(
                                  value: e.toString(),
                                  child: Text(
                                    '$e',
                                    style: TextStyle(color: Colors.white),
                                  )))
                          .toList(),
                      onChanged: (newvalue) {
                        setState(() {
                          selectedRemind = int.parse(newvalue.toString());
                        });
                      },
                    ),
                    SizedBox(
                      width: 7,
                    ),
                  ],
                )),
            SizedBox(
              height: 10,
            ),
            InputField(
                title: 'Repeat',
                note: selectedRepeat,
                widget: Row(
                  children: [
                    DropdownButton(
                      dropdownColor: Colors.blueGrey,
                      icon: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: Colors.grey,
                      ),
                      items: repeatList
                          .map<DropdownMenuItem<String>>(
                              (e) => DropdownMenuItem(
                                  value: e.toString(),
                                  child: Text(
                                    '$e',
                                    style: TextStyle(color: Colors.white),
                                  )))
                          .toList(),
                      onChanged: (newvalue) {
                        setState(() {
                          selectedRepeat = newvalue.toString();
                        });
                      },
                    ),
                    SizedBox(
                      width: 7,
                    ),
                  ],
                )),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Color',
                        style: Themes().headingStyle,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Row(
                        children: [
                          ...List.generate(
                              3, (index) => buildGestureDetector(index))
                        ],
                      ),
                    ],
                  ),
                  Spacer(),
                  MyButton(
                    ontap: () async{
                      await validateDate();
                    },
                    label: 'Add Task',
                  ),
                  SizedBox(
                    width: 5,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Padding buildGestureDetector(index) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedColor = index;
          });
        },
        child: CircleAvatar(
          backgroundColor: index == 0
              ? primaryClr
              : index == 1
                  ? orangeClr
                  : pinkClr,
          child: selectedColor == index ? Icon(Icons.done) : null,
        ),
      ),
    );
  }

  addTasktoDb() async {
    try {
      int ? value = await taskController.addTask(
          task: Task(
        title: titleController.text,
        note: noteController.text,
        isCompleted: 0,
        startTime: startTime,
        endTime: endTime,
        date: DateFormat.yMd().format(selectedDate),
        color: selectedColor,
        remind: selectedRemind,
        repeat: selectedRepeat,
      ));

    } catch (e) {
      print(e);
    }
  }

  validateDate()async {
    if (titleController.text.isNotEmpty && noteController.text.isNotEmpty) {
      addTasktoDb();
      await taskController.getTask();
      Get.back();
    } else if (titleController.text.isEmpty || noteController.text.isEmpty) {
      Get.snackbar('required', 'title or note shoudn\'t be empty ',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: pinkClr,
          icon: Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
          ));
    } else {
      print('something bad happened');
    }
  }

  getDateFromUser() async {
    DateTime? pickedTime = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2016),
        lastDate: DateTime(2030));
    if (pickedTime != null)
      setState(() {
        selectedDate = pickedTime;
      });
  }

  getTimeFromUser(bool isStarttime) async {
    TimeOfDay? pickedTime = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: isStarttime
            ? TimeOfDay.fromDateTime(DateTime.now())
            : TimeOfDay.fromDateTime(
                DateTime.now().add(Duration(minutes: 20))));

    String? fromatedTime = pickedTime?.format(context);

    if (fromatedTime != null && isStarttime) {
      DateTime selectedDateTime = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        pickedTime!.hour,
        pickedTime.minute,
      );
      selectedDateTime = selectedDateTime.add(Duration(minutes: 20));
      TimeOfDay newTime = TimeOfDay.fromDateTime(selectedDateTime);
      String fromatedTime2 = newTime.format(context);
      setState(() {
        startTime = fromatedTime;
        endTime = fromatedTime2;
      });
    } else if (fromatedTime != null && !isStarttime) {
      setState(() {
        endTime = fromatedTime;
      });
    }
  }
}
