import 'package:flutter/material.dart';
import 'package:geo_attendance_system/controllers/setting_controller.dart';
import 'package:geo_attendance_system/res/strings.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:get/get.dart';

class Settings extends StatelessWidget {
  final settingController = Get.find<SettingController>();
  String dropdownValue = 'http';

  Settings({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(title: Strings.setting),
        body: body(),
      ),
    );
  }

  Widget body() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: Sizes.s15),
        margin: EdgeInsets.symmetric(vertical: Sizes.s30),
        child: Column(children: [
          Container(
              height: Get.height * (6.3 / 100),
              decoration: roundedBorder(),
              width: Get.width,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Expanded(flex: 3, child: httpRequest()),
                VerticalDivider(),
                Expanded(
                  flex: 8,
                  child: AppTextField(
                    controller: settingController.ipAddress,
                    hintText: Strings.ipAddress,
                    decoration: InputDecoration(
                        border: InputBorder.none, hintText: Strings.ipAddress),
                  ),
                ),
              ])),
          SizedBox(
            height: Sizes.s50,
          ),
          SizedBox(
            width: Sizes.s80,
            child: ElevatedButton(
                onPressed: () {
                  settingController.setIp();
                  settingController.setHttpMethod();
                  Common.toast(Strings.settingSavedSuccessfully);
                  Get.back();
                },
                child: Text("Save")),
          )
        ]));
  }

  httpRequest() {
    return Obx(
      () => Padding(
        padding: EdgeInsets.symmetric(horizontal: Sizes.s10),
        child: DropdownButton<String>(
          value: settingController.dropdownValue.value,
          icon: const Icon(Icons.arrow_drop_down),
          elevation: 16,
          style: const TextStyle(color: Colors.deepPurple),
          onChanged: (String newValue) {
            settingController.dropdownValue.value = newValue;
          },
          items: <String>['http', 'https']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          underline: Container(),
        ),
      ),
    );
  }
}
