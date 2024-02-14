import 'dart:developer';
import 'dart:io';

//import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

class PickerHandler {
  PickerListener _listener;

  PickerHandler(this._listener);

  final picker = ImagePicker();

  pickImageFromGallery() async {
    try {
      var pickedFile = await picker.pickImage(source: ImageSource.gallery);
      File file = File(pickedFile.path);
      if (file != null) {
        _listener.pickerFile(file);
      } else {
        _listener.pickerFile(null);
      }
    } catch (e) {
      log("pickImageFromGallery $e");
    }
  }

  pickImageFromCamera() async {
    try {
      var pickedFile = await picker.pickImage(source: ImageSource.camera);
      File file = File(pickedFile.path);
      if (file != null) {
        _listener.pickerFile(file);
      } else {
        _listener.pickerFile(null);
      }
    } catch (e) {
      log("pickImageFromCamera $e");
    }
  }

  pickVideoFromGallery() async {
    try {
      var pickedFile = await picker.pickVideo(source: ImageSource.gallery);
      File file = File(pickedFile.path);
      if (file != null) {
        _listener.pickerFile(file);
      } else {
        _listener.pickerFile(null);
      }
    } catch (e) {
      log("pickVideoFromGallery $e");
    }
  }

  pickVideoFromCamera() async {
    try {
      var pickedFile = await picker.pickVideo(source: ImageSource.camera);
      File file = File(pickedFile.path);
      if (file != null) {
        _listener.pickerFile(file);
      } else {
        _listener.pickerFile(null);
      }
    } catch (e) {
      log("pickVideoFromCamera $e");
    }
  }
//
//   pickFileFromStorage() async {
//     try {
//       FilePickerResult result = await FilePicker.platform.pickFiles(
//           type: FileType.custom,
//           allowedExtensions: [
//             "odt",
//             "doc",
//             "txt",
//             "docx",
//             "xls",
//             "xlsx",
//             "pdf"
//           ],
//           allowCompression: true,
//           allowMultiple: false);
//       if (result != null) {
//         File file = File(result.files.single.path);
//         _listener.pickerFile(file);
//       } else {
//         _listener.pickerFile(null);
//       }
//     } catch (e) {
//       log("pickFileFromStorage $e");
//     }
//   }
}

abstract class PickerListener {
  pickerFile(File _file);
}
