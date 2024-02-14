import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:geo_attendance_system/db/database.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'image_converter.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as imglib;

class FaceNetService {
  // singleton boilerplate
  static final FaceNetService _faceNetService = FaceNetService._internal();

  factory FaceNetService() {
    return _faceNetService;
  }

  // singleton boilerplate
  FaceNetService._internal();

  DataBaseService _dataBaseService = DataBaseService();

  Interpreter _interpreter;

  double threshold = 1.0;

  List _predictedData;

  List get predictedData => this._predictedData;

  //  saved users data
  dynamic data = {};

  Future loadModel() async {
    Delegate delegate;
    try {
      if (Platform.isAndroid) {
        delegate = GpuDelegateV2(options: GpuDelegateOptionsV2());
      } else if (Platform.isIOS) {
        delegate = GpuDelegate(
          options: GpuDelegateOptions(),
        );
      }
      var interpreterOptions = InterpreterOptions()..addDelegate(delegate);

      this._interpreter = await Interpreter.fromAsset('mobilefacenet.tflite',
          options: interpreterOptions);
      print('model loaded successfully');
    } catch (e) {
      print('Failed to load model.');
      print(e);
    }
  }

  Future<void> setCurrentPrediction(CameraImage cameraImage, Face face) async {
    /// crops the face from the image and transforms it to an array of data
    List input = _preProcess(cameraImage, face);

    /// then reshapes input and output to model format 🧑‍🔧
    input = input.reshape([1, 112, 112, 3]);
    List output = List.generate(1, (index) => List.filled(192, 0));
    this._interpreter.run(input, output);
    output = output.reshape([192]);
    this._predictedData = List.from(output);
  }

  /// takes the predicted data previously saved and do inference
  Map<String, dynamic> predict({String key, bool isEdit = false}) {
    /// search closer user prediction if exists
    if (key == null)
      return _searchResult(this._predictedData);
    else
      return _searchResult(this._predictedData, key: key, isEdit: isEdit);
  }

  /// _preProess: crops the image to be more easy
  /// to detect and transforms it to model input.
  /// [cameraImage]: current image
  /// [face]: face detected
  List _preProcess(CameraImage image, Face faceDetected) {
    // crops the face 💇
    imglib.Image croppedImage = _cropFace(image, faceDetected);
    imglib.Image img = imglib.copyResizeCropSquare(croppedImage, 112);
    // transforms the cropped face to array data
    Float32List imageAsList = imageToByteListFloat32(img);
    return imageAsList;
  }

  /// crops the face from the image 💇
  /// [cameraImage]: current image
  /// [face]: face detected
  imglib.Image _cropFace(CameraImage image, Face faceDetected) {
    imglib.Image convertedImage = _convertCameraImage(image);
    double x = faceDetected.boundingBox.left - 10.0;
    double y = faceDetected.boundingBox.top - 10.0;
    double w = faceDetected.boundingBox.width + 10.0;
    double h = faceDetected.boundingBox.height + 10.0;
    return imglib.copyCrop(
        convertedImage, x.round(), y.round(), w.round(), h.round());
  }

  /// converts ___CameraImage___ type to ___Image___ type
  /// [image]: image to be converted
  imglib.Image _convertCameraImage(CameraImage image) {
    var img = convertToImage(image);
    var img1 = imglib.copyRotate(img, -90);
    return img1;
  }

  Float32List imageToByteListFloat32(imglib.Image image) {
    /// input size = 112
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;

    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);

        /// mean: 128
        /// std: 128
        buffer[pixelIndex++] = (imglib.getRed(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getGreen(pixel) - 128) / 128;
        buffer[pixelIndex++] = (imglib.getBlue(pixel) - 128) / 128;
      }
    }

    return convertedBytes.buffer.asFloat32List();
  }

  /// searchs the result in the DDBB (this function should be performed by Backend)
  /// [predictedData]: Array that represents the face by the MobileFaceNet model
  Map<String, dynamic> _searchResult(List predictedData,
      {String key, double minDist, bool isEdit = false}) {
    Map<String, dynamic> data = _dataBaseService.db;
    //  List<String> dist= [];
    double currDist = 0.0;
    String predRes;
    dynamic faceData;

    /// if no faces saved
    if (data?.length == 0) return null;

    Map<String, dynamic> output = {};

    if (minDist == null) minDist = 0.80;

    /// search the closest result 👓

    if (key == null || isEdit) {

      for (String label in data.keys) {

        if (isEdit) {
          if (label.split(":")[1].trim() == key) {
            continue;
          }
        }

        //  print("face = ${data[label]['faceData']}");
        //todo
        //   currDist = _euclideanDistance(data[label], predictedData);

        if (data[label]['faceData'].runtimeType != String) {
            faceData = data[label]['faceData'];
         } else {

          faceData = data[label];

        }
        currDist = _euclideanDistance(
            faceData != null ? data[label]['faceData'] : data[label],
            predictedData);

        if (currDist <= threshold && currDist < minDist) {
          minDist = currDist;
          predRes = label;
          output['predRes'] = predRes;
        }
      }
    }
    else {
      //todo
      // currDist = _euclideanDistance(data[key], predictedData);
      currDist = _euclideanDistance(data[key]['faceData'], predictedData);
      print("face = ${data[key]['faceData']}");
      if (currDist <= threshold && currDist < minDist) {
        minDist = currDist;
        predRes = key;
        output['predRes'] = predRes;
      }
    }

    return output;
  }

  String findKey(String empId) {
    String key = "";
    Map<String, dynamic> data = _dataBaseService.db;
    for (String label in data.keys) {
      if (label.split(":")[1] == empId) {
        key = label;
        break;
      }
    }
    return key;
  }

  /// Adds the power of the difference between each point
  /// then computes the sqrt of the result 📐
  double _euclideanDistance(List e1, List e2) {
    if (e1 == null || e2 == null) throw Exception("Null argument");

    double sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow((e1[i] - e2[i]), 2);
    }
    return sqrt(sum);
  }

  void setPredictedData(value) {
    this._predictedData = value;
  }
}
