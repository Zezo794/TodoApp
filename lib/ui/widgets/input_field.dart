import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../theme.dart';

class InputField extends StatelessWidget {
  final String title;
  final String note;
  Widget? widget;
  final TextEditingController? controller;

  InputField(
      {required this.title, required this.note, this.widget, this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
          child: Text(
            title,
            style: Themes().headingStyle,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          margin: EdgeInsets.only(left: 10, right: 10),
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey)),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  cursorColor: Get.isDarkMode?Colors.grey[100]:Colors.grey[700],
                  readOnly: widget!=null?true:false,
                  style:Themes().subtitleStyle ,
                  decoration: InputDecoration(
                      hintText: note, hintStyle: Themes().subtitleStyle,
                    focusedBorder: InputBorder.none,
                    border: InputBorder.none,

                  ),

                ),
              ),
              widget ?? Container(),
            ],
          ),
        )
      ],
    );
  }
}
