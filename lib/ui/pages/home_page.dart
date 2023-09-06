import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:todo/controllers/task_controller.dart';
import 'package:todo/ui/widgets/task_tile.dart';

import '../../models/task.dart';
import '../../services/notification_services.dart';
import '../../services/theme_services.dart';
import '../size_config.dart';
import '../theme.dart';
import '../widgets/button.dart';
import 'add_task_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime selectedDate = DateTime.now();
  late NotifyHelper notifyHelper;

  final taskController = TaskController.instance;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();
    taskController.getTask();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.backgroundColor,
        leading: IconButton(
          onPressed: () {
            ThemeServices().switchTheme();
            notifyHelper.displayNotification(title: 'lol', body: 'lol');
          },
          icon: Icon(
            Icons.sunny,
            color: Get.isDarkMode ? Colors.white : darkGreyClr,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
             taskController.deleteAllTask();
             notifyHelper.cancelAllNotification();
            },
            icon: Icon(
              Icons.cleaning_services_outlined,
              color: Get.isDarkMode ? Colors.white : darkGreyClr,
            ),
          ),
          CircleAvatar(
            backgroundImage: AssetImage('images/person.jpeg'),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TaskBar(),
          dateTime(),
          SizedBox(
            height: 10,
          ),
          showTasks(),
        ],
      ),
    );
  }

  TaskBar() {
    return Container(
      margin: EdgeInsets.only(left: 20, top: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormat.yMMMMd().format(DateTime.now()),
                style: Themes().subheadingStyle,
              ),
              Text(
                'Today',
                style: Themes().headingStyle,
              ),
            ],
          ),
          MyButton(
              ontap: () {
                Get.to(() => AddTaskPage());
                taskController.getTask();
              },
              label: '+ Add Task'),
        ],
      ),
    );
  }

  dateTime() {
    return Container(
      margin: EdgeInsets.only(left: 20, top: 10),
      child: DatePicker(
        DateTime.now(),
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryClr,
        onDateChange: (val) {
          setState(() {
            selectedDate = val;
          });
        },
        monthTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        )),
        dayTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        )),
        dateTextStyle: GoogleFonts.lato(
            textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        )),
      ),
    );
  }

  showTasks() {
    if (taskController.taskList.length > 0) {
      return Flexible(
        fit: FlexFit.loose,
        child: Obx(
          () => ListView.builder(
            scrollDirection: SizeConfig.orientation == Orientation.landscape
                ? Axis.horizontal
                : Axis.vertical,
            itemBuilder: (context, index) {
              var task = taskController.taskList[index];
              if (task.repeat == 'Daily' ||
                  task.date == DateFormat.yMd().format(selectedDate) ||
                  (task.repeat == 'Weekly' &&
                      selectedDate.difference(DateFormat.yMd().parse(task.date!)).inDays % 7 == 0) ||
                  (task.repeat=='Monthly' && selectedDate.day==DateFormat.yMd().parse(task.date!).day)
              ) {
                DateTime parsedTime =
                    DateFormat('hh:mm a').parse(task.startTime!);
                notifyHelper.scheduledNotification(
                  parsedTime.hour,
                  parsedTime.minute,
                  task,
                );

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: Duration(milliseconds: 1375),
                  child: SlideAnimation(
                    horizontalOffset: 300,
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          showBottomSheet(context, task);
                        },
                        child: TaskTile(
                          task: taskController.taskList[index],
                        ),
                      ),
                    ),
                  ),
                );
              } else
                return Container();
            },
            itemCount: taskController.taskList.length,
          ),
        ),
      );
    } else {
      return noTasks();
    }
  }

  noTasks() {
    return Stack(children: [
      SingleChildScrollView(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          alignment: WrapAlignment.center,
          direction: SizeConfig.orientation == Orientation.landscape
              ? Axis.horizontal
              : Axis.vertical,
          children: [
            SizeConfig.orientation == Orientation.landscape
                ? SizedBox(
                    height: 6,
                  )
                : SizedBox(
                    height: 220,
                  ),
            SvgPicture.asset(
              'images/task.svg',
              height: 90,
              color: primaryClr.withOpacity(0.7),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Text(
                'You dont have any task\'s yet \nAdd new tasks to make your days productive.',
                style: Themes().subtitleStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  showBottomSheet(BuildContext context, Task task) {
    return Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(top: 4),
        width: SizeConfig.screenWidth,
        height: (SizeConfig.orientation == Orientation.landscape)
            ? (task.isCompleted == 1
                ? SizeConfig.screenHeight * 0.6
                : SizeConfig.screenHeight * 0.8)
            : (task.isCompleted == 1
                ? SizeConfig.screenHeight * 0.30
                : SizeConfig.screenHeight * 0.39),
        color: Get.isDarkMode ? darkHeaderClr : Colors.white,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  height: 6,
                  width: 120,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color:
                          Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              task.isCompleted == 1
                  ? Container()
                  : buildBootemSheet(
                      label: 'Task Completed',
                      ontab: () {
                        taskController.markTaskCompleted(task.id!);
                        notifyHelper.cancelNotification(task);
                        Get.back();
                      },
                      clr: primaryClr,
                    ),
              buildBootemSheet(
                label: 'delete Task ',
                ontab: () {
                  taskController.deleteTask(task);
                  notifyHelper.cancelNotification(task);
                  Get.back();
                },
                clr: primaryClr,
              ),
              Divider(
                color: Get.isDarkMode ? Colors.grey : darkGreyClr,
              ),
              buildBootemSheet(
                label: 'Cancel',
                ontab: () {
                  Get.back();
                },
                clr: primaryClr,
              ),
              SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  buildBootemSheet({
    required String label,
    required Function() ontab,
    required Color clr,
    bool isclosed = false,
  }) {
    return GestureDetector(
      onTap: ontab,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4),
        width: SizeConfig.screenWidth * 0.9,
        height: 65,
        decoration: BoxDecoration(
          border: Border.all(
            width: 2,
            color: isclosed
                ? Get.isDarkMode
                    ? Colors.grey[600]!
                    : Colors.grey[300]!
                : clr,
          ),
          color: isclosed ? Colors.transparent : clr,
        ),
        child: Center(
          child: Text(
            label,
            style: isclosed
                ? Themes().titleStyle
                : Themes().titleStyle.copyWith(
                      color: Colors.white,
                    ),
          ),
        ),
      ),
    );
  }
}
