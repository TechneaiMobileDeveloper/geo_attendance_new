import 'package:flutter/material.dart';
import 'package:geo_attendance_system/main.dart';
import 'package:geo_attendance_system/ui/pages/acceptances_page.dart';
import 'package:geo_attendance_system/ui/widgets/custom_text_widget.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../res/app_colors.dart';
import '../res/strings.dart';
import '../ui/pages/dashboard.dart';
import '../ui/pages/settings.dart';
import '../ui/pages/users.dart';
import '../utils/utils_controller.dart';
import '../ui/pages/attendance_calendar_report.dart' as report;
import '../ui/pages/attendance_report/attendance_report.dart' as r;

class DrawerData {
  List<DrawerModel> actualDrawerData = [];
  static List<DrawerModel> data = [
    DrawerModel(title: 'Dashboard', visible: true),
    DrawerModel(title: 'Add Employee', visible: true),
    DrawerModel(title: 'Employees', visible: true),
    DrawerModel(title: 'Approval', visible: true),
    DrawerModel(title: "Attendance Report", visible: true),
    DrawerModel(title: "Attendance Calendar", visible: true),
    DrawerModel(title: 'Log out', visible: true),
    DrawerModel(title: "Export", visible: false),
    DrawerModel(title: 'Scan', visible: true),
  ];

  DrawerData() {
    if (AuthManager().getLoginData().data.role == 1) {
      actualDrawerData.add(DrawerData.data[0]);
      actualDrawerData.add(DrawerData.data[1]);
      actualDrawerData.add(DrawerData.data[8]);
      actualDrawerData.add(DrawerData.data[2]);
      actualDrawerData.add(DrawerData.data[3]);
      actualDrawerData.add(DrawerData.data[4]);
      actualDrawerData.add(DrawerData.data[5]);
      actualDrawerData.add(DrawerData.data[6]);
      actualDrawerData.add(DrawerData.data[7]);
    } else {
      actualDrawerData.add(DrawerData.data[0]);
      //actualDrawerData.add(DrawerData.data[1]);
      actualDrawerData.add(DrawerData.data[6]);
      // actualDrawerData.add(DrawerData.data[6]);
    }
  }

  Widget getDrawerAsPerLevel(Widget content, Function clearEditController,
      bool isMultiUser, bool isAdmin) {
    return Drawer(
      child: Column(
        children: [
          Container(
              width: Get.width,
              height: Get.height * 0.08,
              color: AppColors.greyText,
              child: Center(
                child: Text(
                    AuthManager().getLoginData() != null
                        ? AuthManager().getLoginData().data.name
                        : "",
                    style: TextStyles.defaultRegular
                        .copyWith(fontSize: Sizes.s20, color: AppColors.white)),
              )),
          C20(),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                  height: Sizes.s30,
                  child: Divider(
                    color: AppColors.divider,
                    thickness: Sizes.s1,
                  ),
                ),
                itemCount: actualDrawerData.length,
                itemBuilder: (BuildContext context, int index) {
                  return actualDrawerData[index].visible
                      ? GestureDetector(
                          onTap: () => drawerNavigation(
                              actualDrawerData[index].title,
                              content,
                              clearEditController,
                              isMultiUser: isMultiUser,
                              isAdmin: isAdmin),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 1, horizontal: Sizes.s7),
                            child: Text(
                              actualDrawerData[index].title,
                              style: TextStyles.defaultRegular
                                  .copyWith(fontSize: Sizes.s15),
                            ),
                          ),
                        )
                      : SizedBox(height: 1);
                },
              ),
            ),
          ),
          Obx(
            () => dashboardController.isTappedMenu.value
                ? FutureBuilder<PackageInfo>(
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            children: [
                              CustomText(
                                text:
                                    "lastSyncTime: ${Get.find<SharedPreferences>().getString(Strings.lastSyncDate)}",
                                fontSize: FontSizes.s13,
                              ),
                              CustomText(
                                text: "Version :${snapshot.data.version}",
                                fontSize: FontSizes.s14,
                              ),
                            ],
                          ),
                        );
                      } else
                        return Container();
                    },
                    future: PackageInfo.fromPlatform())
                : CircularProgressIndicator(),
          )
        ],
      ),
    );
  }

  void drawerNavigation(
      String title, Widget content, Function clearEditController,
      {bool isMultiUser = false, bool isAdmin = false}) {
    Get.back();
    switch (title.toLowerCase()) {
      case 'dashboard':
        Get.offAll(() => DashboardScreen(
              isMultiUser: (isMultiUser && isAdmin)
                  ? false
                  : isMultiUser
                      ? true
                      : false,
              isAdmin: isAdmin,
            ));
        break;
      case 'add employee':
        mShowDialog(Strings.addUsersTitle, content, clearEditController);
        break;
      case 'setting':
        Get.to(Settings());
        break;
      case 'employees':
        Get.to(() => Users());
        break;
      case 'approval':
        Get.to(() => AcceptancesReport()
            //AcceptancesReport()
            // Acceptance()
            );
        break;
      case 'attendance report':
        Get.to(() => r.AttendanceReport());
        //Get.to(() => r.AttendanceReport(userType: isMultiuser,type:Constants.AttendanceTypeIn));
        // r.AttendanceReport());

        //  Get.to(() => AttendanceReport());
        break;
      case 'attendance calendar':
        Get.to(() => report.AttendanceReport());
        break;
      case 'log out':
        Get.find<AuthManager>().logoutUser();
        break;
      case 'scan':
        Get.offAll(
            () => DashboardScreen(isMultiUser: !isMultiUser, isAdmin: true));
        break;
    }
  }

  mShowDialog(
      String mTitle, Widget dialogContent, Function clearEditController) {
    clearEditController();
    Get.defaultDialog(
      title: mTitle,
      middleText: "You content goes here...",
      content: dialogContent,
      barrierDismissible: false,
      radius: Sizes.s20,
    );
  }
}

class DrawerModel {
  String title;
  bool visible;

  DrawerModel({this.title, this.visible});
}
