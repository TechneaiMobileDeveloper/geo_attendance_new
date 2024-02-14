import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geo_attendance_system/controllers/dashboard_controller.dart';
import 'package:geo_attendance_system/db/database.dart';
import 'package:geo_attendance_system/main.dart';
import 'package:geo_attendance_system/res/res_controller.dart';
import 'package:geo_attendance_system/service/facenet.service.dart';
import 'package:geo_attendance_system/utils/utils_controller.dart';
import 'package:get/get.dart';

// import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock/wakelock.dart';
import '../widgets/custom_text_widget.dart';
import 'camera_view.dart';
import 'painters/face_detector_painter.dart';

class FaceDetectorView extends StatefulWidget {
  final String username, password;
  final bool isSignUp;
  final bool isAuto;

  final String empId;
  final bool isEdit;
  final bool conflict;

  final FaceDetector faceDetector;
  final FaceNetService faceNetService;
  final CameraController cameraController;

  FaceDetectorView(this.username, this.password, this.isSignUp,
      this.faceDetector, this.faceNetService,
      {this.empId,
      this.isEdit = false,
      this.isAuto = false,
      this.conflict = false,
      this.cameraController});

  @override
  _FaceDetectorViewState createState() =>
      _FaceDetectorViewState(this.faceDetector, this.faceNetService);
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  bool save = false;
  bool isBusy = false;
  var modalLoaded = false;
  bool loaded = false;
  bool isDispose = false;
  CustomPaint customPaint;
  Map<String, dynamic> result;
  XFile file;
  String _key = "";
  List<Face> faces = [];
  bool postureError = false;
  InputImage mInputimage;
  Timer _timer;
  String dist;
  DataBaseService _dataBaseService = DataBaseService();
  FaceNetService faceNetService;
  int count = 0;
  bool isEnableButton = false;
  FaceDetector faceDetector;
  CameraController cameraController;
  bool isTakingPicture = false;
  File captureImage;

  final dashboardController = Get.find<DashboardController>();

  _FaceDetectorViewState(this.faceDetector, this.faceNetService);

  @override
  void dispose() {
    faceDetector.close();
    save = false;
    isDispose = true;
    _timer.cancel();
    Wakelock.disable();
    super.dispose();
  }

  @override
  void initState() {
    Wakelock.enable();
    loadTensorModal();
    super.initState();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(oneSec, (Timer timer) {
      count++;
      if (count > 10) {
        if (!widget.isSignUp) {
          showConfirmDialog(onRetry, onManual, Strings.userNotFound,
              Strings.tryAgain, Strings.retry, Strings.cancle);
          count = 0;
          if (timer.isActive) {
            timer.cancel();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return faceDetector != null && modalLoaded
        ? WillPopScope(
            onWillPop: () {
              Get.back();
              return;
            },
            child: Stack(alignment: Alignment.center, children: [
              CameraView(
                  title: 'Face Detector',
                  customPaint: customPaint,
                  controller: widget.cameraController,
                  onImage: (inputImage, controller, _cameraController) {
                    this.mInputimage = inputImage;
                    this.cameraController = _cameraController;
                    if (!save) {
                      Future.delayed(Duration.zero, () {
                        processImage(
                            this.mInputimage, controller, _cameraController);
                      });
                    }
                  },
                  initialDirection: CameraLensDirection.front),
              Visibility(
                visible: false,
                child: Positioned(
                    bottom: Sizes.s50,
                    child: Text("Dist=$dist",
                        style: TextStyles.textStyle
                            .copyWith(fontSize: FontSizes.s20))),
              ),
              Visibility(
                visible: !widget.isAuto,
                child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin: EdgeInsets.only(bottom: Sizes.s50),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Visibility(
                            child: SizedBox(
                              width: Sizes.s100,
                              child: AppPrimaryButton(
                                text: "Add User",
                                onPressed: this.isEnableButton
                                    ? () {
                                        signUP(this.mInputimage);
                                      }
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: Sizes.s10,
                          ),
                          Visibility(
                            visible: false,
                            child: Expanded(
                              flex: 1,
                              child: AppPrimaryButton(
                                text: "Capture Image",
                                onPressed: () {
                                  // signIn();
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    )),
              )
            ]),
          )
        : Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
  }

  Future<void> processImage(InputImage inputImage, CameraImage image,
      CameraController cameraController) async {
    try {
      if (inputImage != null) {
        if (isBusy) return;

        if (faceDetector != null) {
          isBusy = true;

          final faces = await faceDetector.processImage(inputImage);

          this.faces = faces;

          print('Found ${faces.length} faces');

          // check face shape parameters rotation,atleast one face detected

          if (inputImage.inputImageData.size != null &&
              inputImage.inputImageData.imageRotation != null &&
              faces.length > 0) {
            final painter = FaceDetectorPainter(
                faces,
                inputImage.inputImageData.size,
                inputImage.inputImageData.imageRotation,
                widget.isSignUp);
            customPaint = CustomPaint(painter: painter);
          } else {
            customPaint = null;
          }

          if (!isDispose) {
            setState(() {});
          }
          await Future.delayed(Duration(milliseconds: 10));

          if (image != null) {
            if (this.faces != null) {
              if (this.faces.length == 1) {
                Face face = this.faces.first;

                // check face headAngle detection

                if (face.headEulerAngleY != null &&
                    face.headEulerAngleY != null &&
                    face.rightEyeOpenProbability != null &&
                    face.leftEyeOpenProbability != null) {
                  if (face.headEulerAngleY < 10 &&
                      face.headEulerAngleY > -10 &&
                      face.rightEyeOpenProbability > 0.5 &&
                      face.leftEyeOpenProbability > 0.5) {
                    if (!isDispose) {
                      setState(() {
                        isEnableButton = true;
                      });
                    }

                    postureError = false;

                    if (!save && modalLoaded) {
                      await faceNetService.setCurrentPrediction(image, face);

                      // checking is not adding user
                      if (!widget.isSignUp) {
                        // searching  all faces from database and signedIn

                        if (widget.empId == null) {
                          result = await signIn(inputImage);
                        }
                        // searching  with taking face by employee key from database and signedIn
                        else if (_key != null) {
                          if (_key.isNotEmpty)
                            result = await signIn(inputImage, key: _key);
                        }

                        if (!isDispose) {
                          if (result != null) {
                            if (result['predRes'] != null) {
                              _timer.cancel();

                              showConfirmDialog(faceDetectedCallback, () {
                                try {
                                  Future.delayed(
                                      Duration.zero,
                                      () => Get.dialog(showBottomDialog(_key),
                                          barrierDismissible: false));
                                } catch (ex) {
                                  print(ex.toString());
                                }
                              },
                                  Strings.faceDetected,
                                  "Hello ${result['predRes'].toString().split(":")[0]}",
                                  Strings.IN,
                                  Strings.OUT,
                                  result: result);
                            } else {
                              isBusy = false;
                              save = false;
                            }
                          } else {
                            isBusy = false;
                            save = false;
                          }
                        }
                      } else {
                        if (widget.isAuto) signUP(inputImage);
                        isBusy = false;
                      }
                    } else {
                      isBusy = false;
                    }
                  } else {
                    postureError = true;
                    if (!isDispose) {
                      setState(() {
                        isEnableButton = false;
                      });
                    }

                    isBusy = false;
                  }
                } else {
                  Common.toast(Strings.suggestion_String_faceDetectionProblem);
                }
              } else {
                isBusy = false;
              }
            } else {
              isBusy = false;
            }
          } else {
            isBusy = false;
          }
        } else {
          isBusy = false;
          loadFaceML();
        }
      } else {
        isBusy = true;
      }
    } on PlatformException catch (ex) {
      Common.toast(Strings.opps);
      loadFaceML();
      isBusy = false;
      logErrorInFile(ex.toString());
      print("platformError=${ex.toString()}");
    }
  }

  void faceDetectedCallback(dynamic result) async {
    try {
      Get.back();

      if (cameraController != null) {
        await Future.delayed(Duration(milliseconds: 100));

        if (cameraController.value.isStreamingImages) {
          await cameraController.stopImageStream();
        }
        await Future.delayed(Duration(milliseconds: 200));

        if (!cameraController.value.isTakingPicture) {
          file = await cameraController.takePicture();
          final bytes = await file.readAsBytes();
          final tempDir = await getTemporaryDirectory();
          captureImage = await File('${tempDir.path}/image.jpeg').create();
          await captureImage.writeAsBytes(bytes);
        }

        faceNetService.setPredictedData([]);
        isDispose = true;
        _timer.cancel();

        Navigator.pop(context, {
          "isSignUp": widget.isSignUp,
          "result": result == null ? null : result['predRes'],
          "empId": widget.empId,
          "username": dashboardController.usernameController.text,
          "image": captureImage,
          "type": result == null ? null : result['type'],
          "error": false
        });
      } else {
        Common.toast(Strings.camera_error);
      }
    } catch (ex) {
      print(ex.toString());
    }
  }

  void signUP(InputImage image) async {
    try {
      bool error = false;
      Map<String, dynamic> result;
      final bytes = image.bytes;
      String predRes;
      final tempDir = await getTemporaryDirectory();

      if (!isDispose) {
        setState(() {
          save = true;
        });
      }
      File captureImage = await File('${tempDir.path}/image.png').create();
      captureImage.writeAsBytes(bytes);

      await _dataBaseService.loadDB();

      if (!widget.isEdit) {
        result = faceNetService.predict();
        if (result != null) predRes = result["predRes"];
      } else {
        result = faceNetService.predict(key: widget.empId, isEdit: true);
        if (result != null) predRes = result["predRes"];
      }

      if (predRes == null && (!postureError)) {
        _dataBaseService.saveData(
            widget.username, widget.password, faceNetService.predictedData,
            isConflict: widget.conflict);
        error = false;
      } else if (postureError) {
        Common.toast(Strings.checkPosture);
      } else {
        error = true;
        Common.toast(Strings.userAlreadyExits);
      }

      Navigator.pop(context, {
        "isSignUp": widget.isSignUp,
        "result": result,
        "image": captureImage,
        "error": error
      });
      isBusy = false;
    } catch (ex) {
      print(ex.toString());
    }
  }

  Future<Map<String, dynamic>> signIn(InputImage image, {String key}) async {
    Map<String, dynamic> result;
    result = key == null
        ? faceNetService.predict()
        : faceNetService.predict(key: key);
    log("result=$result");

    if (!isDispose) {
      isBusy = false;
      save = false;
    }
    return result;
  }

  void loadFaceML() {
    try {
      faceDetector = FaceDetector(
          options: FaceDetectorOptions(
        enableContours: true,
        enableClassification: true,
      ));
    } catch (ex) {
      print(ex.toString());
    }
  }

  void loadTensorModal() async {
    try {
      _key = faceNetService.findKey(widget.empId);
      setState(() {
        modalLoaded = true;
      });
      startTimer();
    } catch (ex) {
      loadTensorModal();
    }
  }

  void changeState() {
    if (mounted) {
      setState(() {
        save = true;
      });
    }
  }

  void showConfirmDialog(Function onConfirm, VoidCallback onCancle,
      String title, String middleText, String textConfirm, String textCancle,
      {dynamic result, dynamic cameraImage, int empId}) async {
    try {
      save = true;
      isBusy = true;
      Get.defaultDialog(
          barrierDismissible: false,
          title: title,
          content: WillPopScope(
            onWillPop: () async {
              Get.back();
              return false;
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: FontSizes.s12),
              child: Column(
                children: [
                  CustomText(
                    text: middleText,
                    fontSize: FontSizes.s18,
                  ),
                  C20(),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () async {
                              try {
                                var out = await dashboardController.dbHelper
                                    .getIsPunched(int.parse(widget.empId));
                                if (out['type'] == "OUT" ||
                                    out['type'] == 'FIRST' ||
                                    textConfirm == "Retry") {
                                  clickEvent(textConfirm, onConfirm,
                                      cameraImage, result);
                                } else {
                                  Common.toast(Strings.alreadyPunchedIn);
                                }
                              } on Exception catch (ex) {
                                Common.toast("InExe- ${ex.toString()}");
                              }
                            },
                            child: CustomText(
                              text: textConfirm,
                              fontSize: FontSizes.s12,
                              color: Colors.white,
                            )),
                      ),
                      C20(),
                      Expanded(
                        child: ElevatedButton(
                            onPressed: () async {
                              try {
                                var out = await dashboardController.dbHelper
                                    .getIsPunched(int.parse(widget.empId),
                                        Inout: 1);
                                if (out['type'] == "IN" ||
                                    textCancle == Strings.cancle) {
                                  outClickEvent(textCancle, onConfirm, onCancle,
                                      result, cameraImage);
                                } else {
                                  if (out['type'] == 'FIRST') {
                                    Common.toast(Strings.not_applicable);
                                  } else {
                                    Common.toast(Strings.alreadyPunchedOut);
                                  }
                                }
                              } on Exception catch (ex) {
                                Common.toast("OutExc-${ex.toString()}");
                              }
                            },
                            child: CustomText(
                              text: textCancle,
                              fontSize: FontSizes.s12,
                              color: Colors.white,
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ));
    } on Exception catch (ex) {
      Common.toast(ex.toString());
    }
  }

  void clickEvent(String textConfirm, Function onConfirm,
      CameraImage cameraImage, dynamic result) {
    dashboardController.inClicked.value = true;
    if (textConfirm == "IN") {
      if (result != null && cameraImage != null) {
        result['type'] = 0;
        onConfirm(result, cameraImage);
      } else if (result != null) {
        result['type'] = 0;
        onConfirm(result);
      } else
        onConfirm();
    } else {
      onConfirm();
    }
    //Get.back();
  }

  outClickEvent(String textCancle, Function onConfirm, VoidCallback onCancle,
      dynamic result, CameraImage cameraImage) {
    dashboardController.outClicked.value = true;
    if (textCancle == "OUT") {
      if (result != null && cameraImage != null) {
        result['type'] = 1;
        onConfirm(result, cameraImage);
      } else if (result != null) {
        result['type'] = 1;
        onConfirm(result);
      } else
        onConfirm();
    } else {
      onCancle();
    }
    //Get.back();
  }

  Widget showBottomDialog(String key) {
    final formKey = GlobalKey<FormState>();
    return AlertDialog(
        content: Container(
            height: Get.height / 6,
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            color: AppColors.white,
            child: Center(
                child: _key == null
                    ? Column(
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
                              child: AppTextField(
                                hintText: Strings.employeeIdHint,
                                keyboardType: TextInputType.number,
                                inputFormatters: <TextInputFormatter>[
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                textAlign: TextAlign.center,
                                controller: Get.find<DashboardController>()
                                    .empIdController,
                                hintStyle: TextStyles.textStyle
                                    .copyWith(fontSize: Sizes.s9),
                                // ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: FontSizes.s10,
                          ),
                          ElevatedButton(
                              child: Text('Scan',
                                  style: TextStyles.defaultRegular
                                      .copyWith(color: Colors.black87)),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      AppColors.primary),
                                  textStyle: MaterialStateProperty.all(
                                      const TextStyle(color: Colors.black87))),
                              onPressed: () {
                                String empId = dashboardController
                                        .empIdController.text.isEmpty
                                    ? null
                                    : dashboardController.empIdController.text;
                                this._key = empId;
                                setState(() {
                                  isBusy = false;
                                  save = false;
                                });
                                Get.back();
                                startTimer();
                                dashboardController.empIdController.clear();
                              }),
                          SizedBox(height: FontSizes.s10),
                        ],
                      )
                    : showTakeScreenShot(formKey))));
  }

  void showInOutDialog(GlobalKey<FormState> formKey) {
    Get.back();
    Future.delayed(Duration(seconds: 1), () {
      Get.dialog(Dialog(
          child: ConstrainedBox(
        constraints: BoxConstraints(
            maxHeight: dashboardController.getDeviceType() == "phone"
                ? Get.height * 0.2
                : Get.height * 0.25),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      onPressed: () => onTappedManualPunchedIn(formKey),
                      child: Text(Strings.IN)),
                ),
                C50(),
                Expanded(
                  child: ElevatedButton(
                      onPressed: () => onTappedManualPunchedOut(formKey),
                      child: Text(Strings.OUT)),
                ),
              ],
            ),
          ),
        ),
      )));
    });
  }

  void checkResultAndVerify(Map<String, dynamic> result,
      CameraController cameraController, XFile file, File captureImage,
      {bool isManual = false, String username, int Inout = -1}) async {
    if (isManual) {
      try {
        result = {};
        result['type'] = Inout;
        faceDetectedCallback(result);
      } catch (ex) {
        print(ex.toString());
      }
    } else {
      print("result update");
    }
  }

  appUsernameEditText() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: Sizes.s15),
      child: AppTextField(
        keyboardType: TextInputType.text,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.allow(RegExp(r'^[a-zA-Z0-9]+$')),
          LengthLimitingTextInputFormatter(20),
        ],
        controller: dashboardController.usernameController,
        hintText: Strings.enterUsername,
        mTextStyle: TextStyles.defaultRegular,
        validator: Validator.validateEmptyCheck,
      ),
    );
  }

  confirmButton(GlobalKey<FormState> key, int Inout) {
    //if (!key.currentState.validate()) return;
    checkResultAndVerify(result, cameraController, file, captureImage,
        isManual: true,
        username: dashboardController.usernameController.text,
        Inout: Inout);
  }

  void onTappedManualPunchedIn(GlobalKey<FormState> formKey) async {
    if (!isSyncing) {
      performManualAction(formKey, 1);
    } else {
      Future.delayed(Duration(milliseconds: 1200), () {
        performManualAction(formKey, 1);
      });
    }
  }

  onTappedManualPunchedOut(GlobalKey<FormState> formKey) async {
    if (cameraController.value.isStreamingImages)
      await cameraController.stopImageStream();
    if (!isSyncing) {
      Future.delayed(Duration.zero, () async {
        performManualAction(formKey, 0);
        //  confirmButton(formKey, 1);
      });
    } else {
      Future.delayed(Duration(milliseconds: 1200), () {
        Future.delayed(Duration.zero, () async {
          performManualAction(formKey, 0);
        });
      });
    }
  }

  void performManualAction(GlobalKey<FormState> formKey, int inOut) async {
    var out = await dashboardController.dbHelper
        .getIsPunched(int.parse(widget.empId), Inout: inOut);
    if (inOut == 1) {
      if (out['type'] == "OUT" || out['type'] == 'FIRST') {
        if (cameraController.value.isStreamingImages)
          await cameraController.stopImageStream();
        confirmButton(formKey, 0);
      } else {
        Common.toast(Strings.alreadyPunchedIn);
      }
    } else {
      if (out['type'] == "IN") {
        if (cameraController.value.isStreamingImages)
          await cameraController.stopImageStream();
        confirmButton(formKey, 1);
      } else if (out['type'] == 'FIRST') {
        Common.toast(Strings.notPunchedIn);
      } else {
        Common.toast(Strings.alreadyPunchedOut);
      }
    }
  }

  Widget showTakeScreenShot(GlobalKey<FormState> formKey) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ElevatedButton(
              onPressed: () {
                Get.back();
                Future.delayed(Duration(seconds: 1), () {
                  Get.dialog(SimpleDialog(
                    title: Text(
                      Strings.manual_punch_dialog_title,
                      style: TextStyles.title,
                    ),
                    children: [
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            appUsernameEditText(),
                            C15(),
                            Flexible(
                              child: ElevatedButton(
                                  onPressed: () {
                                    if (!isFormValid(formKey)) {
                                      return;
                                    }
                                    showInOutDialog(formKey);
                                    //  performManualAction(formKey);
                                  },
                                  child: CustomText(
                                      text: Strings.ok,
                                      color: AppColors.white)),
                            )
                            //confirmButton(formKey, 0)
                          ],
                        ),
                      )
                    ],
                  ));
                });
                // });
              },
              child: CustomText(
                text: Strings.takeScreenShot,
                fontSize: FontSizes.s12,
                color: AppColors.white,
              )),
        )
      ],
    );
  }

  onRetry() async {
    isBusy = false;
    save = false;
    await Future.delayed(Duration.zero);
    Get.back();
    startTimer();
  }

  void onManual() {
    isBusy = false;
    save = false;
    try {
      dashboardController.usernameController.text = "";
      if (_timer.isActive) _timer.cancel();
      Get.back();
      Future.delayed(Duration.zero,
          () => Get.dialog(showBottomDialog(_key), barrierDismissible: false));
    } catch (ex) {
      print(ex.toString());
    }
  }
}

//  Get.back();
// return Center(
//   child: SizedBox(
//     width: Get.width * 0.25,
//     child: ElevatedButton(
//       onPressed: () {
//
//       },
//       child: Row(
//         children: [
//           Text(Strings.done,
//               style: TextStyles.defaultRegular
//                   .copyWith(fontSize: FontSizes.s14, color: Colors.white))
//         ],
//       ),
//     ),
//   ),
// );
// Future.delayed(Duration.zero, () {
//   Get.dialog(SimpleDialog(
//     title: Text(
//       Strings.manual_punch_dialog_title,
//       style: TextStyles.title,
//     ),
//     children: [
//       Form(
//         key: formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             appUsernameEditText(),
//             C15(),
//           //  confirmButton(formKey, 1)
//           ],
//         ),
//       )
//     ],
//   ));
// });

// Future.delayed(Duration.zero, () {
//   Get.dialog(SimpleDialog(
//     title: Text(
//       Strings.manual_punch_dialog_title,
//       style: TextStyles.title,
//     ),
//     children: [
//       Form(
//         key: formKey,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             appUsernameEditText(),
//             C15(),
//           //  confirmButton(formKey, 1)
//           ],
//         ),
//       )
//     ],
//   ));
// });

// showModalBottomSheet<void>(
//   context: context,
//   builder: (BuildContext context) {
//     return SingleChildScrollView(
//       child: Container(
//         padding:
//         EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
//         color: AppColors.white,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: <Widget>[
//               SizedBox(
//                 height: FontSizes.s10,
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(8.0),
//                 child: SizedBox(
//                   width: Get.width/2,
//                   child: AppTextField(
//                           hintText: Strings.employeeIdHint,
//                           keyboardType:TextInputType.number,
//                           inputFormatters: <TextInputFormatter>[
//                             FilteringTextInputFormatter.digitsOnly,
//                             LengthLimitingTextInputFormatter(6),
//                           ],
//                     textAlign: TextAlign.center,
//                     controller: Get.find<DashboardController>().empIdController,
//                     hintStyle: TextStyles.textStyle.copyWith(fontSize: Sizes.s9),
//                   ),
//                 ),
//               ) ,
//               SizedBox(
//                 height: FontSizes.s10,
//               ),
//               ElevatedButton(
//                 child:  Text('Capture',style:  TextStyles.defaultRegular.copyWith(color: Colors.black87)),
//                 style: ButtonStyle(
//                     backgroundColor: MaterialStateProperty.all(AppColors.primary),
//                     textStyle: MaterialStateProperty.all(const TextStyle(color: Colors.black87))
//                 ),
//                 onPressed: () {
//                   String empId = dashboardController.empIdController.text.isEmpty ? null:dashboardController.empIdController.text;
//
//                       setState(() {
//                         this._key = empId;
//                         isBusy = false;
//                       });
//
//                   Navigator.pop(context);
//
//               //    navigateToScanFace(empId,dashboardController.usernameController.text,isSignUp:false,mIsAuto: true,isDemo:dashboardController.isDemo);
//                   dashboardController.empIdController.clear();
//                 },
//               ),
//               SizedBox(
//                 height: FontSizes.s10,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   },
//   isScrollControlled: true ,
// );

// void paintContour(FaceContourType type) {
//   final faceContour = faces[0].getContour(type);
//   if (faceContour.positionsList != null) {
//     for (Offset point in faceContour.positionsList) {
//       log("type=${type.toString()},${point.toString()}");
//     }
//   }
// }

// void faceDetectedCallback(dynamic result) async {
//   try {
//     if (cameraController != null) {
//       await Future.delayed(Duration(seconds: 1));
//       if (cameraController.value.isStreamingImages) {
//         await cameraController.stopImageStream();
//       }
//
//       await Future.delayed(Duration(seconds:1));
//
//       if (!cameraController.value.isTakingPicture) {
//         file = await cameraController.takePicture();
//
//         final bytes = await file.readAsBytes();
//         final tempDir = await getTemporaryDirectory();
//
//         captureImage = await File('${tempDir.path}/image.jpeg').create();
//
//         await captureImage.writeAsBytes(bytes);
//       }
//
//       faceNetService.setPredictedData(null);
//       isDispose = true;
//       _timer.cancel();
//
//       Navigator.pop(context, {
//         "isSignUp": widget.isSignUp,
//         "result": result == null ? null : result['predRes'],
//         "empId": widget.empId,
//         "username": dashboardController.usernameController.text,
//         "image": captureImage,
//         "error": false
//       });
//     } else {
//       Common.toast(Strings.camera_error);
//     }
//   } catch (ex) {
//     print(ex.toString());
//   }
// }
