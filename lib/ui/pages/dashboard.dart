import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_attendance_system/controllers/dashboard_controller.dart';
import 'package:geo_attendance_system/controllers/user_controller.dart';
import 'package:geo_attendance_system/database/DbHelper.dart';
import 'package:geo_attendance_system/drawer/drawer_data.dart';
import 'package:geo_attendance_system/main.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/service/facenet.service.dart';
import 'package:geo_attendance_system/ui/VisionDetectorViews/detector_views.dart';
import 'package:geo_attendance_system/ui/pages/acceptances_page.dart';
import 'package:geo_attendance_system/ui/pages/attendance_approved_report.dart';
import 'package:geo_attendance_system/ui/pages/attendance_report.dart';
import 'package:geo_attendance_system/ui/widgets/custom_text_widget.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:wakelock/wakelock.dart';

class DashboardScreen extends StatefulWidget {
  final bool isMultiUser;
  final bool isAdmin;

  const DashboardScreen({Key key, this.isMultiUser, this.isAdmin})
      : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  DashboardController dashboardController;
  final dbHelper = Get.put(DbHelper());
  final userController = Get.put(UserController());
  final List<DrawerModel> drawerList = [];
  List<String> radioList = ["Manual", "Auto"];
  bool isUser, isMultiUser;
  FaceNetService faceNetService;
  FaceDetector faceDetector;

  GlobalKey<FormState> globalKey;

  // GlobalKey<ScaffoldState> scaffoldState = new GlobalKey<ScaffoldState>();
  DrawerData _drawerData;

  @override
  void initState() {
    // TODO: implement initState
    Wakelock.enable();
    initMethods();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: SafeArea(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            key: dashboardController.scaffoldKey,
            appBar: CustomAppBar(
                isHamburger: true,
                title: isMultiUser ? Strings.scanFace : Strings.dashboard,
                textStyle:
                    TextStyles.appBarBold.copyWith(color: AppColors.white),
                color: AppColors.greyText,
                actionWidget: actionWidget(),
                onTapHamburger: tappedOnHamburger),
            endDrawer: _drawerData != null
                ? _drawerData.getDrawerAsPerLevel(getContent(),
                    clearEditController, isMultiUser, widget.isAdmin)
                : null,
            body: Obx(() =>
                dashboardController.isLoadedModal.value ? loader() : wBody()),
          ),
        ));
  }

  void takePhoto(int i) {
    dashboardController.takePhoto(i);
  }

  Widget attendanceDetails() {
    return FutureBuilder<List<Map<String, dynamic>>>(
        builder: (context, data) {
          if (data.hasData) {
            return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: data.data.length,
                    itemBuilder: (context, index) =>
                        _customAttendaceDetailsRow(data.data[index], index),
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics()));
          } else {
            return C10();
          }
        },
        future: dbHelper.getAllRecords());
  }

  _customAttendaceDetailsRow(Map<String, dynamic> row, int index) {
    return Row(
      children: [
        Expanded(
            child: Text("${index + 1}",
                style: TextStyles.textStyle.copyWith(fontSize: Sizes.s10),
                textAlign: TextAlign.center)),
        Expanded(
            child: Text(
                row['inTime'] != null
                    ? DateFormat("dd MMM yy")
                        .format(DateFormat("dd-MM-yyyy").parse(row['c_date']))
                    : "",
                style: TextStyles.textStyle,
                textAlign: TextAlign.center)),
        Expanded(
            child: Text(
                row['inTime'] != null
                    ? DateFormat("hh:mm aa")
                        .format(DateFormat("HH:mm:ss").parse(row['inTime']))
                    : "",
                style: TextStyles.textStyle)),
        Expanded(
            child: Text(
                row['OutTime'] != null
                    ? DateFormat("hh:mm aa")
                        .format(DateFormat("HH:mm:ss").parse(row['OutTime']))
                    : "",
                style: TextStyles.textStyle)),
        Expanded(
            child: Text(
                "${dashboardController.getTimeDifferenceString(row['OutTime'] != null ? row['OutTime'] : Strings.default_date, row['inTime'] != null ? row["inTime"] : Strings.default_date)} h",
                style: TextStyles.textStyle))
      ],
    );
  }

  getPhoneWidth() {
    return MediaQuery.of(context).size.width / 1.5;
  }

  getTableWidth() {
    return MediaQuery.of(context).size.width / 1.5;
  }

  // Widget mapDetails() {
  //   log(dashboardController.listPosition.length.toString() + "alkdfj");
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: dashboardController.listPosition.length > 0
  //         ? ListView.builder(
  //             itemCount: dashboardController.listPosition.length,
  //             itemBuilder: (context, index) =>
  //                 _customRow(dashboardController.listPosition[index]),
  //             shrinkWrap: true,
  //             physics: NeverScrollableScrollPhysics(),
  //           )
  //         : Container(),
  //   );
  // }

  Widget loader() {
    return Center(
        child:
            CircularProgressIndicator(color: Theme.of(context).primaryColor));
  }

  mShowDialog(String mTitle) {
    clearEditController();

    Get.defaultDialog(
      title: mTitle,
      middleText: "You content goes here...",
      content: getContent(),
      barrierDismissible: false,
      radius: Sizes.s20,
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    faceDetector.close();
    Wakelock.disable();
    super.dispose();
  }

  // Widget _customRow(Position data) {
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: Row(
  //       children: [
  //         // Expanded(child:  Text( DateFormat("dd-MM-yyyy").format(data.timestamp.toLocal()) != null ?DateFormat("dd-MM-yyyy").format(data.timestamp.toLocal()) : "",
  //         //                        style: TextStyles.textStyle.copyWith(fontSize: Sizes.s9),
  //         //                        textAlign: TextAlign.center)),
  //         Expanded(
  //             child: Text(
  //                 DateFormat("HH:mm:ss").format(data.timestamp.toLocal()) !=
  //                         null
  //                     ? DateFormat("HH:mm:ss").format(data.timestamp.toLocal())
  //                     : "",
  //                 style: TextStyles.textStyle.copyWith(fontSize: Sizes.s11),
  //                 textAlign: TextAlign.start)),
  //         Expanded(
  //             child: FutureBuilder(
  //           builder: (context, data) {
  //             if (data.hasData) {
  //               return Text(data.data != null ? data.data : "",
  //                   textAlign: TextAlign.start,
  //                   style: TextStyles.textStyle.copyWith(fontSize: Sizes.s11));
  //             } else {
  //               return Container();
  //             }
  //           },
  //           future: dashboardController.getLocationString(data),
  //         )),
  //       ],
  //     ),
  //   );
  // }

  // Moving to scan face

  void navigateToScanFace(String empId, String name,
      {bool isSignUp = true,
      bool mIsAuto = false,
      bool isDemo = false,
      bool conflict = false}) {
    Get.to(() => FaceDetectorView(
        name, empId, isSignUp, faceDetector, faceNetService,
        empId: empId,
        isEdit: false,
        isAuto: mIsAuto,
        conflict: dashboardController.conflict.value)).then((value) {
      try {
        String userName;

        bool isSignUp = value["isSignUp"];
        bool error = value["error"];

        File file = value["image"] as File;

        var result = value["result"];
        var inOut = value['type'];

        dashboardController.usernameController.clear();
        dashboardController.empIdController.clear();
        if (result != null) {
          empId = result.toString().split(":")[1];
          userName = result.toString().split(":")[0];
        }

        if (isSignUp && !error) {
          Common.toast(Strings.userAddedSuccessfully);
        } else if (result != null) {
          int mEmpId;
          mEmpId = (!isMultiUser) ? AuthManager().getLoginData().data.id : 0;
          if (int.parse(empId) == mEmpId && (!isSignUp)) {
            dashboardController.saveFile(file, dashboardController.flag.value,
                empId: int.parse(empId), userName: userName);
          } else {
            if (isMultiUser && (!isSignUp)) {
              dashboardController.saveFile(file, dashboardController.flag.value,
                  empId: int.parse(empId), userName: userName, InOut: inOut);
            }
          }
        } else if (result == null && !isSignUp) {
          empId = value['empId'];
          userName = value['username'];
          dashboardController.saveFile(file, dashboardController.flag.value,
              empId: int.parse(empId),
              acceptance: 0,
              userName: userName,
              InOut: inOut);
        } else if (result == null) {
          showUserNotFoundBottomDialog();
          Common.toast(Strings.userNotExits);
        }
      } catch (e) {
        print(e);
      }
    });
  }

  // void _drawerNavigation(String title) {
  //   Get.back();
  //   switch (title.toLowerCase()) {
  //     case 'dashboard':
  //       Get.to(() => DashboardScreen(isAdmin: false));
  //       break;
  //     case 'add user':
  //       mShowDialog(Strings.addUsersTitle);
  //       break;
  //     case 'setting':
  //       Get.to(Settings());
  //       break;
  //     case 'users':
  //       Get.to(() => Users());
  //       break;
  //     case 'approval':
  //       //Get.to(() => Acceptance());
  //       break;
  //     case 'export':
  //       Get.to(() => AttendanceReport(userType: isMultiUser));
  //       break;
  //     case 'attendance report':
  //       Get.to(() => AttendanceReport());
  //       break;
  //     case 'log out':
  //       Get.find<AuthManager>().logoutUser();
  //       break;
  //   }
  // }

  getContent() {
    return Obx(() => Form(
        key: globalKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AppTextField(
                  hintText: Strings.employeeIdHint,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    LengthLimitingTextInputFormatter(6),
                  ],
                  errorText: dashboardController.errorEmpId.value == 3
                      ? Strings.inActiveEmployee
                      : dashboardController.errorEmpId.value == 0
                          ? Strings.wrongEmployeeId
                          : null,
                  controller: dashboardController.empIdController,
                  hintStyle:
                      TextStyles.textStyle.copyWith(fontSize: Sizes.s13)),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: AppTextField(
                  hintText: Strings.enterUsername,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]*')),
                    LengthLimitingTextInputFormatter(20),
                  ],
                  controller: dashboardController.usernameController,
                  hintStyle:
                      TextStyles.textStyle.copyWith(fontSize: Sizes.s13)),
            ),
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: AppPrimaryButton(
                    fontSize: Sizes.s14,
                    borderColor: Theme.of(context).primaryColor,
                    bgColor: Theme.of(context).primaryColor,
                    text: "Scan",
                    textColor: Colors.black,
                    onPressed: () async {
                      if (dashboardController.empIdController.text.isNotEmpty &&
                          dashboardController
                              .usernameController.text.isNotEmpty) {
                        if (!isEmployeeIdExits(
                            dashboardController.empIdController.text,
                            dashboardController.usernameController.text)) {
                          int isExits =
                              await dashboardController.validateEmpId();
                          if (isExits == 1) {
                            Get.back();
                            navigateToScanFace(
                                dashboardController.empIdController.text,
                                dashboardController.usernameController.text,
                                isSignUp: true,
                                mIsAuto: this.dashboardController.auto.value);
                            dashboardController.empIdController.clear();
                          } else {
                            dashboardController.errorEmpId.value = isExits;
                          }
                        } else {
                          Common.toast(Strings.userDetailsAlreadyExists);
                        }
                      } else {
                        Common.toast(Strings.allFieldsRequired);
                      }
                    }

                    //},
                    ))
          ],
        )));
  }

  getFloatingButton() {
    return AuthManager().getLoginData().data.id == 4057
        ? FloatingActionButton(
            child: Icon(Icons.person_add_alt_1),
            onPressed: () {
              mShowDialog(Strings.addUsersTitle);
            },
          )
        : null;
  }

  void navigateToMapView() {
    // Navigator.of(context).push(MaterialPageRoute(
    //     builder: (context) => MapView(dashboardController.listPosition),
    //     settings: RouteSettings(name: "/map_view")));
  }

  bool isEmployeeIdExits(String empId, String username) {
    bool id, userName;
    id = userController.getIsEmployeeIdExits(empId, Strings.empId, false);
    userName =
        userController.getIsEmployeeIdExits(username, Strings.username, false);
    if (id && userName) {
      return true;
    }
    if (id) {
      //   Common.toast(Strings.userIdAlreadyExits);
      return true;
    }
    // else if (userName) {
    //   Common.toast(Strings.userNameAlreadyExits);
    //   return true;
    // }
    return false;
  }

  void clearEditController() {
    dashboardController.empIdController.clear();
    dashboardController.usernameController.clear();
    dashboardController.errorEmpId.value = 2;
  }

  Widget customCheckbox(String title, Function onChanged, bool mValue) {
    return Row(
      children: [
        Expanded(child: Text(title)),
        Expanded(
            child: Radio(
          value: mValue,
          onChanged: onChanged,
          groupValue: null,
        ))
      ],
    );
  }

  // void _radioGrouponChange(dynamic value) {
  //   dashboardController.verticalGroupValue.value = value;
  //   if (value == "Auto") {
  //     dashboardController.auto.value = true;
  //   } else if (value == "Manual") {
  //     dashboardController.auto.value = false;
  //   } else if (value == "Conflict") {
  //     dashboardController.auto.value = false;
  //     dashboardController.conflict.value = true;
  //   }
  // }

  Future<void> initMethods() async {
    try {
      isMultiUser = widget.isMultiUser;
      dashboardController = Get.put(DashboardController(widget.isMultiUser));

      setState(() {
        _drawerData = DrawerData();
      });

      await loadFacenetService();
      loadGoogleMLKit();

      dashboardController.isLoadedModal.value = false;

      dbHelper.getDashboardContain();

      if (AuthManager().getLoginData().data.role == 1) {
        drawerList.add(DrawerData.data[0]);
        drawerList.add(DrawerData.data[1]);
        drawerList.add(DrawerData.data[2]);
        drawerList.add(DrawerData.data[3]);
        drawerList.add(DrawerData.data[4]);
        drawerList.add(DrawerData.data[5]);
        drawerList.add(DrawerData.data[6]);
      } else {
        drawerList.add(DrawerData.data[0]);
        drawerList.add(DrawerData.data[1]);
        drawerList.add(DrawerData.data[5]);
      }

      setState(() {});
    } catch (ex) {
      dashboardController.isLoadedModal.value = false;
    }
  }

  void showUserNotFoundBottomDialog() {
    showModalBottomSheet<void>(
        isDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
              child: Container(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  color: AppColors.white,
                  child: Center(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(
                        height: FontSizes.s10,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: Get.width / 2,
                          child: Text(
                            Strings.userNotFound,
                            style: TextStyles.defaultRegular
                                .copyWith(fontSize: FontSizes.s20),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: FontSizes.s10,
                      ),
                      ElevatedButton(
                        child: Text('Ok',
                            style: TextStyles.defaultRegular
                                .copyWith(color: Colors.black87)),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(AppColors.primary),
                            textStyle: MaterialStateProperty.all(
                                const TextStyle(color: Colors.black87))),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      SizedBox(
                        height: FontSizes.s10,
                      ),
                    ],
                  ))));
        },
        isScrollControlled: true);
  }

  void showBottomDialog() {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
            child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                color: AppColors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      SizedBox(height: FontSizes.s10),
                      Obx(() => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: Get.width / 2,
                              child: AppTextField(
                                hintText: Strings.employeeIdHint,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                textAlign: TextAlign.center,
                                errorText: dashboardController
                                            .errorEmpId.value ==
                                        3
                                    ? Strings.inActiveEmployee
                                    : dashboardController.errorEmpId.value == 0
                                        ? Strings.wrongEmployeeId
                                        : null,
                                controller: dashboardController.empIdController,
                                hintStyle: TextStyles.textStyle
                                    .copyWith(fontSize: Sizes.s16),
                              ),
                            ),
                          )),
                      SizedBox(
                        height: FontSizes.s10,
                      ),
                      ElevatedButton(
                          child: Text('Scan',
                              style: TextStyles.defaultRegular
                                  .copyWith(color: Colors.white)),
                          onPressed: () async {
                            String empId =
                                dashboardController.empIdController.text.isEmpty
                                    ? null
                                    : dashboardController.empIdController.text;

                            await dashboardController.checkFaceExist(
                                empId, faceNetService);

                            if (dashboardController
                                        .findIsActiveEmployee(empId) ==
                                    2 ||
                                dashboardController
                                        .findIsActiveEmployee(empId) ==
                                    0) {
                              Navigator.pop(context);
                              navigateToScanFace(empId,
                                  dashboardController.usernameController.text,
                                  isSignUp: false,
                                  mIsAuto: true,
                                  isDemo: dashboardController.isDemo);
                            } else {
                              Common.toast(Strings.inActiveEmployee);
                            }
                            dashboardController.empIdController.clear();
                          }),
                      SizedBox(height: FontSizes.s10)
                    ],
                  ),
                )));
      },
      isScrollControlled: true,
    );
  }

  Widget actionWidget() {
    return !isMultiUser
        ? Obx(() {
            return dashboardController.empId.value == 4057
                ? AppPrimaryButton(
                    text: "T",
                    textColor: Colors.black,
                    onPressed: () {
                      setState(() {
                        dashboardController.isDemo =
                            !dashboardController.isDemo;
                      });
                    })
                : Container();
          })
        : Container();
  }

  tappedOnHamburger() async {
    dashboardController.isTappedMenu.value = false;
    if (widget.isAdmin) {
      isMultiUser = false;
    }
    if (dashboardController.scaffoldKey.currentState.isEndDrawerOpen) {
      dashboardController.scaffoldKey.currentState.openDrawer();
    } else {
      dashboardController.scaffoldKey.currentState.openEndDrawer();
    }
    await Future.delayed(Duration(milliseconds: 500));
    dashboardController.isTappedMenu.value = true;
  }

  // Widget getDrawerAsPerLevel() {
  //       return Drawer(
  //        child: Column(
  //          children: [
  //            Container(
  //              width: Get.width,
  //              height: Get.height * 0.08,
  //                color: AppColors.greyText,
  //                child:
  //                Center(
  //                  child: Text(
  //                      AuthManager()
  //                          .getLoginData() != null ? AuthManager()
  //                          .getLoginData().data.name:"",
  //                         style: TextStyles.defaultRegular
  //                                .copyWith(fontSize: Sizes.s20,
  //                                  color: AppColors.white
  //                              )
  //                  ),
  //                )
  //            ),
  //            C20(),
  //            Flexible(
  //                child: Padding(
  //                padding: const EdgeInsets.all(8.0),
  //                child: ListView.separated(
  //                        separatorBuilder: (BuildContext context, int index) =>
  //                             SizedBox(
  //                               height: Sizes.s30,
  //                               child: Divider(color: AppColors.divider,
  //                               thickness: Sizes.s1,
  //                               ),
  //                             ),
  //                        itemCount: drawerList.length,
  //                        itemBuilder: (BuildContext context, int index) {
  //                              return drawerList[index].visible ?
  //                                GestureDetector(
  //                                    onTap: () => _drawerData.drawerNavigation(drawerList[index].title,getContent(),clearEditController,isMultiUser: isMultiUser),
  //                                     child: Container(
  //                                        padding: EdgeInsets.symmetric(vertical: 1, horizontal: Sizes.s7),
  //                                        child: Text(
  //                                            drawerList[index].title,
  //                                            style: TextStyles.defaultRegular.copyWith(
  //                                              fontSize: Sizes.s15
  //                                            ),
  //                                          ),
  //                          ),
  //                                ) : SizedBox(height: 1);
  //                        },
  //                ),
  //              ),
  //            ),
  //          ],
  //        ),
  //      );
  // }

  Future<bool> _onWillPop() async {
    return await Get.dialog(
          AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit an App'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () => Get.back(canPop: false),
                child: Text('No'),
              ),
              ElevatedButton(
                onPressed: () => exit(0),
                child: Text('Yes'),
              ),
            ],
          ),
          barrierDismissible: true,
        ) ??
        false;
  }

  wBody() {
    return isMultiUser
        ? Container(
            height: Get.height,
            child: Center(
              child: Container(
                height: Get.height / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Image.asset(
                      Assets.techAi,
                      height: Sizes.s120,
                      width: Sizes.s120,
                    ),
                    // Obx(()=>Text(dashboardController.currentDateTime.value)),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: Get.width / 2,
                        height: Get.height / 14,
                        child: AppPrimaryButton(
                          text: "Scan Face",
                          fontSize: FontSizes.s16,
                          textColor: Colors.black,
                          onPressed: () {
                            showBottomDialog();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        : AdminSection(dbHelper, this.isMultiUser,
            this.dashboardController.isLoadedModal, dashboardController);
  }

  Future<void> loadFacenetService() async {
    faceNetService = FaceNetService();
    await faceNetService.loadModel();
  }

  void loadGoogleMLKit() {
    try {
      faceDetector = FaceDetector(
          options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
      ));
    } catch (ex) {
      loadGoogleMLKit();
      print(ex.toString());
    }
  }
}

class AdminSection extends StatelessWidget {
  final DbHelper dbHelper;
  final bool isMultiuser;
  final RxBool isLoadedModal;
  final DashboardController controller;

  AdminSection(
      this.dbHelper, this.isMultiuser, this.isLoadedModal, this.controller);

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      height: Get.height,
      padding: EdgeInsets.only(top: Sizes.s5),
      child: ListView(
          physics: AlwaysScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            Center(
                child: SizedBox(
                    height: Get.height * 0.08,
                    child: Center(
                        child: Obx(
                      () => CustomText(
                          text: DateFormat("dd MMM yyyy HH:mm:ss")
                              .format(controller.currentDateTime.value),
                          fontSize: FontSizes.s23,
                          fontWight: FontWeight.w700),
                    )))),
            Obx(() => dbHelper.inOutCount.length > 0
                ? Container(
                    margin: EdgeInsets.only(
                        top: Sizes.s20, left: Sizes.s20, right: Sizes.s20),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.to(() => AttendanceReport(
                                      userType: isMultiuser,
                                      type: Constants.AttendanceTypeIn))
                                  .then((value) async {
                                dashboardController.reloadDashboardContain();
                              });
                            },
                            child: Container(
                              height: Get.height * 0.2,
                              width: Get.width / 1.5,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomText(
                                    text: Strings.totalInCount,
                                    fontSize: FontSizes.s23,
                                  ),
                                  Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    color: Colors.white24,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Icon(
                                          Icons.arrow_downward,
                                          color: Colors.accents.first,
                                          size: FontSizes.s36,
                                        ),
                                        Container(
                                            height: Get.height * 0.11,
                                            width: Get.width * 0.2,
                                            child: Center(
                                              child: CustomText(
                                                  text: dbHelper
                                                      .dashboardContent[
                                                          Strings.punchInCount]
                                                      .toString()),
                                            ))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => AttendanceReport(
                                    userType: isMultiuser,
                                    type: Constants.AttendanceTypeOut,
                                  )).then((value) async {
                                dashboardController.reloadDashboardContain();
                              });
                            },
                            child: Container(
                              height: Get.height * 0.2,
                              width: Get.width / 1.5,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomText(
                                    text: Strings.totalOutCount,
                                    fontSize: FontSizes.s23,
                                  ),
                                  Card(
                                    color: Colors.white24,
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.arrow_upward,
                                          color: Colors.accents.first,
                                          size: FontSizes.s36,
                                        ),
                                        Container(
                                          height: Get.height * 0.11,
                                          width: Get.width * 0.2,
                                          child: Center(
                                              child: CustomText(
                                                  text: dbHelper
                                                      .dashboardContent[
                                                          Strings.punchOutCount]
                                                      .toString())),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              //todo
                              Get.to(() => AcceptancesReport())
                                  .then((value) async {
                                dashboardController.reloadDashboardContain();
                              });
                            },
                            child: Container(
                              height: Get.height * 0.2,
                              width: Get.width / 1.5,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomText(
                                    text: Strings.approve,
                                    fontSize: FontSizes.s23,
                                  ),
                                  Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    color: Colors.white24,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.approval,
                                          color: Colors.accents.first,
                                          size: FontSizes.s36,
                                        ),
                                        Container(
                                          height: Get.height * 0.11,
                                          width: Get.width * 0.2,
                                          child: Center(
                                              child: CustomText(
                                                  text: dbHelper
                                                      .dashboardContent[
                                                          Strings.approve]
                                                      .toString())),
                                          // dbHelper
                                          //     .dashboardContent[
                                          //         Strings.approve]
                                          //     .toString())),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.to(() => ApprovedReport())
                                  .then((value) async {
                                dashboardController.reloadDashboardContain();
                              });
                              //   AttendanceReport(isTodayApproved: true));
                            },
                            child: Container(
                              height: Get.height * 0.2,
                              width: Get.width / 1.5,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  CustomText(
                                    text: Strings.totalApproved,
                                    fontSize: FontSizes.s23,
                                  ),
                                  Card(
                                    clipBehavior: Clip.antiAliasWithSaveLayer,
                                    color: Colors.white24,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Icon(
                                          Icons.approval,
                                          color: Colors.accents.first,
                                          size: FontSizes.s36,
                                        ),
                                        Container(
                                          height: Get.height * 0.11,
                                          width: Get.width * 0.2,
                                          child: Center(
                                              child: CustomText(
                                                  text: dbHelper
                                                      .dashboardContent[
                                                          Strings.totalApproved]
                                                      .toString())),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ]))
                : Center(
                    child: CircularProgressIndicator(),
                  ))
          ]),
    );
  }
}
