import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'coordinates_translator.dart';

class FaceDetectorPainter extends CustomPainter {
  FaceDetectorPainter(
      this.faces, this.absoluteImageSize, this.rotation, this.isSignIn);

  final List<Face> faces;
  final Size absoluteImageSize;
  final InputImageRotation rotation;
  final bool isSignIn;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint();
    final face = faces.first;
    if (face.headEulerAngleY != null &&
        face.headEulerAngleY != null &&
        face.rightEyeOpenProbability != null &&
        face.leftEyeOpenProbability != null) {

      if (face.headEulerAngleY > 10 ||
          face.headEulerAngleY < -10 ||
          face.rightEyeOpenProbability < 0.1 ||
          face.leftEyeOpenProbability < 0.1) {
        paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.red;
      } else {
        paint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.green;
      }
      canvas.drawRect(
        Rect.fromLTRB(
          translateX(face.boundingBox.left, rotation, size, absoluteImageSize),
          translateY(face.boundingBox.top, rotation, size, absoluteImageSize),
          translateX(face.boundingBox.right, rotation, size, absoluteImageSize),
          translateY(
              face.boundingBox.bottom, rotation, size, absoluteImageSize),
        ),
        paint,
      );
    }

    // void paintContour(FaceContourType type) {
    //   final faceContour = face.getContour(type);
    //   if (faceContour?.positionsList != null) {
    //     for (Offset point in faceContour.positionsList) {
    //       canvas.drawCircle(
    //           Offset(
    //             translateX(point.dx, rotation, size, absoluteImageSize),
    //             translateY(point.dy, rotation, size, absoluteImageSize),
    //           ),
    //           1,
    //           paint);
    //     }
    //   }
    // }
    //  if(isSignIn) {
    //
    //    paintContour(FaceContourType.face);
    //    paintContour(FaceContourType.leftEyebrowTop);
    //    paintContour(FaceContourType.leftEyebrowBottom);
    //    paintContour(FaceContourType.rightEyebrowTop);
    //    paintContour(FaceContourType.rightEyebrowBottom);
    //    paintContour(FaceContourType.leftEye);
    //    paintContour(FaceContourType.rightEye);
    //    paintContour(FaceContourType.upperLipTop);
    //    paintContour(FaceContourType.upperLipBottom);
    //    paintContour(FaceContourType.lowerLipTop);
    //    paintContour(FaceContourType.lowerLipBottom);
    //    paintContour(FaceContourType.noseBridge);
    //    paintContour(FaceContourType.noseBottom);
    //    paintContour(FaceContourType.leftCheek);
    //    paintContour(FaceContourType.rightCheek);
    //
    //  //}
    //
    // }
  }

  @override
  bool shouldRepaint(FaceDetectorPainter oldDelegate) {
    return oldDelegate.absoluteImageSize != absoluteImageSize ||
        oldDelegate.faces != faces;
  }
}
