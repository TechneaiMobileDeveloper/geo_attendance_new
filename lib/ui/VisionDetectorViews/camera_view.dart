import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geo_attendance_system/controllers/attendance_controller.dart';
import 'package:geo_attendance_system/utils/widget/app_text_field.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:image_picker/image_picker.dart';

import 'package:geo_attendance_system/main.dart';

enum ScreenMode { liveFeed, gallery }

class CameraView extends StatefulWidget {
  CameraView(
      {Key key,
      this.title,
      this.customPaint,
      this.onImage,
      this.controller,
      this.initialDirection = CameraLensDirection.back})
      : super(key: key);

  final String title;
  final CustomPaint customPaint;
  final Function(InputImage inputImage, CameraImage _controller,
      CameraController _cameraController) onImage;
  final CameraLensDirection initialDirection;
  final CameraController controller;

  @override
  _CameraViewState createState() => _CameraViewState(this.controller);
}

class _CameraViewState extends State<CameraView> {
  ScreenMode _mode = ScreenMode.liveFeed;
  XFile _image;
  ImagePicker _imagePicker;
  CameraController _controller;
  int _cameraIndex = 0;
  double zoomLevel = 0.0, minZoomLevel = 0.0, maxZoomLevel = 0.0;
  final attendance_controller = Get.put(AttendanceController());

  String _imagePath;

  _CameraViewState(this._controller);

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
    for (var i = 0; i < cameras.length; i++) {
      if (cameras[i].lensDirection == widget.initialDirection) {
        _cameraIndex = i;
      }
    }
    _startLiveFeed();
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Visibility(
            visible: false,
            child: Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: _switchScreenMode,
                child: Icon(
                  _mode == ScreenMode.liveFeed
                      ? Icons.photo_library_outlined
                      : (Platform.isIOS
                          ? Icons.camera_alt_outlined
                          : Icons.camera),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _body(),
      floatingActionButton: null,
      //_floatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _floatingActionButton() {
    if (_mode == ScreenMode.gallery) return null;
    if (cameras.length == 1) return null;
    return Container(
        height: 70.0,
        width: 70.0,
        child: FloatingActionButton(
          child: Icon(
            Platform.isIOS
                ? Icons.flip_camera_ios_outlined
                : Icons.flip_camera_android_outlined,
            size: 40,
          ),
          onPressed: _switchLiveCamera,
        ));
  }

  Widget _body() {
    Widget body;
    if (_mode == ScreenMode.liveFeed)
      body = _liveFeedBody();
    else
      body = _galleryBody();
    return body;
  }

  Widget _liveFeedBody() {
    if (_controller != null) {
      if (_controller.value.isInitialized == false) {
        return Container();
      }
    } else {
      return Container();
    }
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Column(
            children: [
              // Expanded(
              //     flex:1,
              //     child:Container(
              //       decoration: BoxDecoration(
              //         color: Colors.white
              //       ),
              //       child: Row(
              //         children: [
              //           Expanded(
              //               flex:1,
              //               child: AppTextField(
              //                   hintText: "Enter username",
              //                   controller: attendance_controller.et_username,
              //               )),
              //           Expanded(
              //               flex:1,
              //               child: AppTextField(
              //                 hintText: "Enter password",
              //                 controller:  attendance_controller.et_password,
              //               ))
              //         ],
              //       ),
              //     )
              // ),
              Expanded(flex: 2, child: CameraPreview(_controller)),
            ],
          ),
          if (widget.customPaint != null) widget.customPaint,
          Positioned(
            bottom: 100,
            left: 50,
            right: 50,
            child: Slider(
              value: zoomLevel,
              min: minZoomLevel,
              max: maxZoomLevel,
              onChanged: (newSliderValue) {
                setState(() {
                  zoomLevel = newSliderValue;
                  _controller.setZoomLevel(zoomLevel);
                });
              },
              divisions: (maxZoomLevel - 1).toInt() < 1
                  ? null
                  : (maxZoomLevel - 1).toInt(),
            ),
          )
        ],
      ),
    );
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? Container(
              height: 400,
              width: 400,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(File(_image.path)),
                  if (widget.customPaint != null) widget.customPaint,
                ],
              ),
            )
          : Icon(
              Icons.image,
              size: 200,
            ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processPickedFile(pickedFile);
    } else {
      print('No image selected.');
    }
    setState(() {});
  }

  void _switchScreenMode() async {
    if (_mode == ScreenMode.liveFeed) {
      _mode = ScreenMode.gallery;
      await _stopLiveFeed();
    } else {
      _mode = ScreenMode.liveFeed;
      await _startLiveFeed();
    }
    setState(() {});
  }

  Future _startLiveFeed() async {
    final camera = cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.low,
      enableAudio: false,
    );

    _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }

      Future.delayed(Duration(milliseconds: 500), () {
        _controller.getMinZoomLevel().then((value) {
          zoomLevel = value;
          minZoomLevel = value;
        });

        _controller.getMaxZoomLevel().then((value) {
          maxZoomLevel = value;
        });

        _controller.startImageStream(_processCameraImage);

        setState(() {});
      });
    });
  }

  Future _stopLiveFeed() async {
    if (_controller.value.isStreamingImages) {
      await _controller?.stopImageStream();
      await _controller?.dispose();
    }

    _controller = null;
  }

  Future _switchLiveCamera() async {
    if (_cameraIndex == 0)
      _cameraIndex = 1;
    else
      _cameraIndex = 0;
    await _stopLiveFeed();
    await _startLiveFeed();
  }

  Future _processPickedFile(XFile pickedFile) async {
    setState(() {
      _image = XFile(pickedFile.path);
    });
    final inputImage = InputImage.fromFilePath(pickedFile.path);

    widget.onImage(inputImage, null, _controller);
  }

  Future _processCameraImage(CameraImage image) async {
    final WriteBuffer allBytes = WriteBuffer();
    for (Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize =
        Size(image.width.toDouble(), image.height.toDouble());

    final camera = cameras[_cameraIndex];
    final imageRotation =
        InputImageRotationValue.fromRawValue(camera.sensorOrientation) ??
            InputImageRotation.rotation0deg;

    final inputImageFormat =
        InputImageFormatValue.fromRawValue(image.format.raw) ??
            InputImageFormat.nv21;

    final planeData = image.planes.map(
      (Plane plane) {
        return InputImagePlaneMetadata(
          bytesPerRow: plane.bytesPerRow,
          height: plane.height,
          width: plane.width,
        );
      },
    ).toList();

    final inputImageData = InputImageData(
      size: imageSize,
      imageRotation: imageRotation,
      inputImageFormat: inputImageFormat,
      planeData: planeData,
    );
    try {
      final inputImage =
          InputImage.fromBytes(bytes: bytes, inputImageData: inputImageData);
      widget.onImage(inputImage, image, _controller);
    } on CameraException catch (ex) {}
  }

  Future<XFile> takePicture() async {
    XFile file;
    if (_controller.value.isInitialized == true) {
      file = await _controller.takePicture();
      this._imagePath = file.path;
    }
    return file;
  }
}
