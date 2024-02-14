import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_attendance_system/controllers/dashboard_controller.dart';
import 'package:geo_attendance_system/controllers/user_controller.dart';
import 'package:geo_attendance_system/db/database.dart';
import 'package:geo_attendance_system/res/app_colors.dart';
import 'package:geo_attendance_system/res/strings.dart';
import 'package:geo_attendance_system/service/facenet.service.dart';
import 'package:geo_attendance_system/style/style.dart';
import 'package:geo_attendance_system/ui/widgets/custom_text_widget.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';

import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:toggle_switch/toggle_switch.dart';

class Users extends StatefulWidget {
  const Users({Key key}) : super(key: key);

  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  Map<String, dynamic> _users;

  List<Map<String, dynamic>> userList = [];
  DataBaseService _dataBaseService;
  FaceNetService faceNetService;
  FaceDetector faceDetector;

  final userController = Get.put(UserController());
  final dashboardController = Get.put(DashboardController(false));

  @override
  void initState() {
    // TODO: implement initState
    initMethods();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              userController.generateExampleDocument(userList);
            },
            child: Icon(
              Icons.download,
              color: AppColors.white,
            ),
          ),
          appBar: AppBar(
            title: CustomText(
              text: Strings.users,
              fontSize: FontSizes.s16,
            ),
          ),
          // CustomAppBar(
          //           isHamburger: false,
          //           title: Strings.users,color: AppColors.greyTextMedium,
          //           textStyle: TextStyles.appBarTittle.copyWith(color: AppColors.white),

          //),
          body: SingleChildScrollView(
            child: Container(
              height: Get.height,
              child: ListView(
                scrollDirection: Axis.vertical,
                children: [
                  C5(),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: Sizes.s10),
                    child: AppTextField(
                            isBoarder: false,
                            decoration: InputDecoration(
                            label: Text("Search Employee"),
                            counterText: '',
                            counter: null,
                            border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.blueAccent, width: 32.0),
                            borderRadius: BorderRadius.circular(Sizes.s18)),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: Sizes.s12, horizontal: Sizes.s10),
                        hintStyle: TextStyles.defaultRegular
                            .copyWith(fontSize: FontSizes.s15),
                      ),
                      inputFormatters: <TextInputFormatter>[
                        // FilteringTextInputFormatter.allow(RegExp("[0-9a-zA-Z]")),
                        LengthLimitingTextInputFormatter(35),
                      ],
                      keyboardType: TextInputType.text,
                      onTextChanged: (val) {
                        //reportController.allEmployeeFilterReport(val);
                        initMethodsSearchFiltter(text: val);
                      },
                      suffixIcon: Icon(Icons.search, color: AppColors.black),
                    ),
                  ),

                  C5(),

                  C10(),
                  usersList(),
                  SizedBox(height: Get.height * (1 / 5))
                ],
              ),
            ),
          )),
    );
  }

  void initMethodsSearchFiltter({String text}) async {
    _dataBaseService = DataBaseService();
    loadUsers(text);
    //  await loadFacenetService();

    loadGoogleMLKit();
  }

  void initMethods({String text}) async {
    _dataBaseService = DataBaseService();
    loadUsers(text);
    await loadFacenetService();
    loadGoogleMLKit();
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

  tappedOnHamburger() {
    if (dashboardController.scaffoldKey.currentState.isEndDrawerOpen) {
      dashboardController.scaffoldKey.currentState.openDrawer();
    } else {
      dashboardController.scaffoldKey.currentState.openEndDrawer();
    }
  }

  //List Widget to show users

  Widget usersList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Sizes.s10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          listHeader(),
          SizedBox(
            height: 10,
          ),
          userList.length > 0
              ? ListView.separated(
                  itemBuilder: (context, index) => customRow(
                      userList[index]['key'], index,
                      isActive: userList[index]['is_active']),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) =>
                      Divider(color: AppColors.divider),
                  itemCount: userList.length)
              : Container(),
        ],
      ),
    );
  }

  //Custom row widget for ListView

  Widget customRow(String user, int index, {int isActive = 1}) {
    return Container(
        padding: EdgeInsets.all(Sizes.s6),
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text((index + 1).toString(),
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 2,
                child: Text(
                    user != null
                        ? user.split(":")[0] != null
                            ? user.split(":")[0]
                            : ""
                        : "",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 1,
                child: Text(
                    user != null
                        ? user.split(":").length > 1
                            ? user.split(":")[1]
                            : ""
                        : "",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle
                        .copyWith(fontWeight: FontWeight.normal))),
            Expanded(
                flex: 1,
                child: InkWell(
                  child: Icon(
                    Icons.camera_alt,
                    color: AppColors.greyText,
                  ),
                  onTap: () async {
                    userController.navigateToScanFaceEmpolyee(
                        user.split(":")[1] != null ? user.split(":")[1] : '0',
                        user.split(":")[0] != null ? user.split(":")[0] : "0",
                        faceNetService,
                        faceDetector,
                        isSignUp: true,
                        isEdit: true);
                  },
                )),
            Expanded(
                flex: 1,
                child: InkWell(
                  child: Icon(
                    Icons.edit,
                    color: AppColors.greyText,
                  ),
                  onTap: () {
                    dashboardController.empIdController.text =
                        user.split(":")[1];
                    dashboardController.usernameController.text =
                        user.split(":")[0];
                    userController.prevEmpId.value = user.split(":")[1];
                    mshowDialog(Strings.edit_details, user: user);
                    //  userController.navigateToScanFace(user.split(":")[1] != null ? user.split(":")[1]:'0', user.split(":")[0] != null ? user.split(":")[0]:"0",isSignUp: true,isEdit: true);
                  },
                )),
            Flexible(
              flex: 3,
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: ToggleSwitch(
                    initialLabelIndex: isActive == 1
                        ? UserType.inactive.index
                        : UserType.active.index,
                    cornerRadius: 10.0,
                    activeBgColors: [
                      [Colors.green],
                      [Colors.red]
                    ],
                    customWidths: [Sizes.s50, Sizes.s50],
                    activeFgColor: Colors.white,
                    inactiveBgColor: Colors.grey,
                    inactiveFgColor: Colors.transparent,
                    totalSwitches: 2,
                    labels: ['Yes', 'No'],
                    onToggle: (index) async {
                      int isActive = UserType.active.index;
                      if (index == 0) {
                        isActive = UserType.active.index;
                      } else {
                        isActive = UserType.inactive.index;
                      }
                      if (userController != null) {
                        await userController.deleteUser(user,
                            isActive: isActive);
                        initMethods();
                      }
                      print('switched to: $index');
                    }),
              ),

              //       child: InkWell(
              //   child: Icon(Icons.delete,
              //     color: AppColors.greyText,
              //   ),
              //   onTap: () {
              //     if (userController != null) {
              //       userController.deleteUser(user).then((val) {
              //         Common.toast(Strings.userDeletedSuccessfully);
              //         initMethods();
              //       });
              //     }
              //   },
              // )
            )
          ],
        ));
  }

  // header widget of users list
  listHeader() {
    return Container(
        padding: EdgeInsets.all(Sizes.s8),
        color: AppColors.greyText,
        child: Row(
          children: [
            Expanded(
                flex: 1,
                child: Text(
                  "Sr No",
                  textAlign: TextAlign.center,
                  style: TextStyles.textStyle.copyWith(
                      fontSize: FontSizes.s12, fontWeight: FontWeight.normal),
                )),
            Expanded(
                flex: 2,
                child: Text("Username",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle.copyWith(
                        fontSize: FontSizes.s12,
                        fontWeight: FontWeight.normal))),
            Expanded(
                flex: 1,
                child: Text("Emp Id",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle.copyWith(
                        fontSize: FontSizes.s12,
                        fontWeight: FontWeight.normal))),
            Expanded(
                flex: 1,
                child: Text("Recapture",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle.copyWith(
                        fontSize: FontSizes.s12,
                        fontWeight: FontWeight.normal))),
            Expanded(
                flex: 1,
                child: Text("Edit",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle.copyWith(
                        fontSize: FontSizes.s12,
                        fontWeight: FontWeight.normal))),
            Expanded(
                flex: 3,
                child: Text("Active",
                    textAlign: TextAlign.center,
                    style: TextStyles.textStyle.copyWith(
                        fontSize: FontSizes.s12,
                        fontWeight: FontWeight.normal)))
          ],
        ));
  }

  // dialog widget for editing in users
  mshowDialog(String mtitle, {String user}) {
    Get.defaultDialog(
      title: mtitle,
      middleText: "You content goes here...",
      content: getContent(user),
      barrierDismissible: false,
      radius: 50.0,
    );
  }

  // body of of editing dialog widget
  getContent(String user) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppTextField(
            hintText: "Enter userId",
            controller: dashboardController.empIdController,
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly,
              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              LengthLimitingTextInputFormatter(6),
            ],
            hintStyle: TextStyles.textStyle.copyWith(fontSize: Sizes.s14),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppTextField(
              keyboardType: TextInputType.text,
              inputFormatters: [
                LengthLimitingTextInputFormatter(35),
                FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$'))
              ],
              hintText: "Enter username",
              controller: dashboardController.usernameController,
              hintStyle: TextStyles.textStyle.copyWith(fontSize: Sizes.s14)),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: AppPrimaryButton(
            fontSize: Sizes.s14,
            borderColor: Theme.of(context).primaryColor,
            bgColor: Theme.of(context).primaryColor,
            text: "Save",
            textColor: Colors.black,
            onPressed: () {
              String username, empId;
              if (!isEmployeeIdExits(dashboardController.empIdController.text,
                  dashboardController.usernameController.text)) {
                if (dashboardController.empIdController.text.isNotEmpty &&
                    dashboardController.usernameController.text.isNotEmpty) {
                  Get.back();
                  username = dashboardController.usernameController.text;
                  empId = dashboardController.empIdController.text;
                  userController.EditDetails(username, empId, user)
                      .then((value) {
                    loadUsers(null);
                  });
                } else {
                  Common.toast(Strings.allFieldsRequired);
                }
              }
            },
          ),
        )
      ],
      //),
    );
  }

  // This method will useful to check employee face data already exits in database
  bool isEmployeeIdExits(String empId, String username) {
    bool id, userName;

    id = userController.getIsEmployeeIdExits(empId, Strings.empId, true,
        prevEmpId: userController.prevEmpId.value);

    userName =
        userController.getIsEmployeeIdExits(username, Strings.username, true);

    if (id && userName) {
      return true;
    }
    if (id) {
      Common.toast(Strings.userIdAlreadyExits);
      return true;
    } else if (userName) {
      return false;
    }

    return false;
  }

  // This method will call in init state for loading users from database
  void loadUsers(String text) async {
    if (text == null) await _dataBaseService.loadDB();

    _users = _dataBaseService.db;

    List<MapEntry> list = _users.entries.toList();

    list.sort(((a, b) => int.parse(b.key.split(":")[1])
        .compareTo(int.parse(a.key.split(":")[1]))));

    if (text == null) {
      userList.clear();
    } else if (text.isNotEmpty) {
      userList.clear();
    } else {
      userList.clear();
      text = null;
    }
    String key;

    for (int i = 0; i < list.length; i++) {
      try {
        key = list[i].key;
        int active;
        if (list[i].value['is_active'].runtimeType != String) {
          active = list[i].value['is_active'];
        } else {
          active = 0;
        }
        addEmployeeList(active, text, key);
      } catch (ex) {
        addEmployeeList(0, text, key);
      }
    }
    userList = userList.reversed.toList();
    setState(() {});
  }

  Widget exportData() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
          padding:
              EdgeInsets.symmetric(vertical: Sizes.s10, horizontal: Sizes.s15),
          child: ElevatedButton(
            onPressed: () {
              userController.generateExampleDocument(userList);
            },
            style: buttonStyle(),
            child: CustomText(
              text: Strings.export,
            ),
          )),
    );
  }

  void addEmployeeList(int active, String text, String key) {
    Map<String, dynamic> label = {};
    if (text == null) {
      label['key'] = key;
      label['is_active'] = active;
      userList.add(label);
    } else {
      if (text.isNotEmpty) {
        if (key.toLowerCase().contains(text.toLowerCase())) {
          label['key'] = key;
          label['is_active'] = active;
          userList.add(label);
        }
      }
    }
  }
}

// Container(
//   margin: EdgeInsets.symmetric(
//       horizontal: Sizes.s10, vertical: Sizes.s10),
//   child: AppTextField(
//     isBoarder: false,
//     decoration: InputDecoration(
//       label: Text("Search employee"),
//    //   hintText: "Search employee",
//       counterText: '',
//       counter: null,
//       border: OutlineInputBorder(
//           borderSide: BorderSide(
//               color: Colors.blueAccent, width: 32.0),
//           borderRadius: BorderRadius.circular(Sizes.s18)),
//       contentPadding: EdgeInsets.symmetric(
//           vertical: Sizes.s12, horizontal: Sizes.s10),
//       hintStyle: TextStyles.defaultRegular
//           .copyWith(fontSize: FontSizes.s15),
//     ),
//     inputFormatters: <TextInputFormatter>[
//       FilteringTextInputFormatter.allow(
//           RegExp("[0-9a-zA-Z]")),
//     ],
//     keyboardType: TextInputType.text,
//     onTextChanged: (val) {
//       initMethods(text: val);
//       //initMethods(text: val);
//     },
//     suffixIcon: Icon(Icons.search, color: AppColors.black),
//   ),
// ),
