// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:geo_attendance_system/utils/sizes.dart';
//
// class ProfileCircleImage extends StatelessWidget {
//   final double height;
//   final double width;
//   final double assetPadding;
//   final Color borderColor;
//   final String filePath;
//   final String errorWidgetAsset;
//
//   ProfileCircleImage(
//       {Key key,
//       this.height,
//       this.width,
//       this.assetPadding,
//       this.borderColor,
//       this.filePath,
//       this.errorWidgetAsset})
//       : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//         height: height,
//         width: width,
//         child: filePath == ""
//             ? CircularProfileAvatar(
//                 "",
//                 child: Padding(
//                   padding: EdgeInsets.all(assetPadding),
//                   child: Image.asset(errorWidgetAsset),
//                 ),
//                 borderColor: borderColor,
//                 borderWidth: Sizes.s1,
//                 elevation: Sizes.s0,
//                 radius: Sizes.s50,
//               )
//             : filePath.contains("http")
//                 ? CircularProfileAvatar(filePath,
//                     radius: Sizes.s50,
//                     borderWidth: Sizes.s1,
//                     borderColor: borderColor,
//                     elevation: Sizes.s0,
//                     placeHolder: (context, url) => Padding(
//                           padding: EdgeInsets.all(Sizes.s35),
//                           child: CircularProgressIndicator(),
//                         ),
//                     errorWidget: (context, url, error) => Padding(
//                           padding: EdgeInsets.all(assetPadding),
//                           child: Image.asset(errorWidgetAsset),
//                         ))
//                 : CircularProfileAvatar(
//                     "",
//                     child: Image.file(File(filePath)),
//                     borderColor: borderColor,
//                     borderWidth: Sizes.s1,
//                     elevation: Sizes.s0,
//                     radius: Sizes.s50,
//                   ));
//   }
// }
