import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeServices {

  GetStorage box = GetStorage();
  String key = 'IsDark';


  saveThemeMode(bool isdark){
    box.write(key, isdark);
  }


  bool loadThememode(){
    return box.read(key)??false;
  }

  ThemeMode get theme {
    return loadThememode()?ThemeMode.dark:ThemeMode.light;
  }

  void switchTheme(){
    Get.changeThemeMode(loadThememode()?ThemeMode.light:ThemeMode.dark);
    saveThemeMode(!loadThememode());
  }
}
