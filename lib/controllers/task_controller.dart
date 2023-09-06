import 'package:get/get.dart';
import 'package:todo/db/db_helper.dart';
import 'package:todo/models/task.dart';

class TaskController  extends GetxController{
  void onInit() {
    super.onInit();
    getTask();
  }
  TaskController._();


  static final TaskController instance = TaskController._();
  final RxList<Task> taskList = <Task>[].obs;


  addTask({Task ? task}) async{
    await DBHelper.insert(task!);
    await getTask();
  }

  deleteTask(Task task)async{
    await DBHelper.delete(task);
    await getTask();
  }

  deleteAllTask()async{
    await DBHelper.deleteALL() ;
    await getTask();
  }

  getTask()async{
     final List<Map<String,dynamic>> tasks=await DBHelper.query();
     taskList.assignAll(tasks.map((e) => Task.fromJson(e)).toList());
  }

  markTaskCompleted(int id)async{
    await DBHelper.update(id);
    await getTask();
  }
}
