// return Obx(() => reportController.attendanceData.value.data != null ?
//                  reportController.attendanceData.value.data.length > 0  ?   ListView(
//                   children: [
//                      listHeader(),
//                       listBody()
//                   ]
//               ):
//        noDataFound(): noDataFound()
// // );
//
// return Obx(()=> reportController.attendanceData.value.data != null ?
// reportController.attendanceData.value.data.length > 0 ?
// ListView.separated(
// shrinkWrap: true,
// itemBuilder: (context,index)=>customRowApproval(reportController.attendanceData.value.data[index],index),
// separatorBuilder: (context,index){
// return Divider(
// thickness: 1,
// );
// }, itemCount: reportController.attendanceData.value.data.length): noDataFound(): noDataFound(),
// );

// Obx((){
//   return  Stack(
//     alignment: Alignment.center,
//     children:[
//       Padding(
//           padding:  EdgeInsets.only(top:Sizes.s50 ),
//           child: CircularPercentIndicator(
//                 radius:    Sizes.s100,
//                 lineWidth: Sizes.s5,
//                 progressColor:   Theme.of(context).buttonTheme.colorScheme.background ,
//                 backgroundColor: Theme.of(context).primaryColor,
//                 percent: dashboardController.mProgress.value,
//                 center: Text(dashboardController.totalTime.value+" h",
//                     style: TextStyles.defaultRegular.copyWith(fontSize: Sizes.s14,color: Colors.black)),
//               ),
//       ),
//       Obx((){
//         return  dashboardController.checkIn.value.isNotEmpty ?
//         Positioned(
//             top:   0,
//             right: 0,
//             child:
//             Obx((){
//               return  Column(
//                         mainAxisSize: MainAxisSize.min,
//                       children: [
//                       if(dashboardController.flag.value == 1 || dashboardController.flag.value == 2)
//                         Container(
//                           margin:EdgeInsets.all(Sizes.s10),
//                           width:  Get.width*  (20 / 100),
//                           height: Get.height*  (8/100),
//                           decoration:BoxDecoration(
//                               border: Border.all(color: Colors.white),
//                               color: AppColors.primary
//                           ),
//                           child: Center(
//                               child:
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                     children: [
//                                       Text(Strings.checkIN,
//                                         style: TextStyles.title.copyWith(fontSize: FontSizes.s12,color:AppColors.black),),
//                                       Row(
//                                         children: [
//                                           Icon(Icons.timer_sharp,color: Colors.black),
//                                           Text((dashboardController.checkIn.value.isNotEmpty)
//                                               ? dashboardController.checkIn.value:Strings.NotAvailable
//                                               ,  style: TextStyles.title.copyWith(fontSize: FontSizes.s12,color:AppColors.black) ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//
//                                 ],
//                               ))
//                       ),
//                     if(dashboardController.flag.value == 2)
//                       Container(
//                           margin:EdgeInsets.all(Sizes.s10),
//                           width:  Get.width*  (20 / 100),
//                           height: Get.height*  (8/100),
//                           decoration:BoxDecoration(
//                               border: Border.all(color: Colors.white), color: AppColors.primary
//                           ),
//                           child: Center(
//                               child:
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Column(
//                                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                                     children: [
//                                       Text(Strings.checkOUT,
//                                         style: TextStyles.title.copyWith(fontSize: FontSizes.s12,color:AppColors.black),),
//                                       Row(
//                                         children: [
//                                           Icon(Icons.timer_sharp,color: Colors.black),
//                                           Text((dashboardController.checkOut.value.isNotEmpty)
//                                               ? dashboardController.checkOut.value:Strings.NotAvailable
//                                               ,style: TextStyles.title.copyWith(fontSize: FontSizes.s12,color:AppColors.black) ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//
//                                 ],
//                               ))
//                       ),
//                   ]);
//             })
//         ):
//         Container();
//       }
//       ),
//     ],
//   );
// }),
// SizedBox(
//   height: 50,
// ),
// Center(
//     child:
//     Container(
//         width:  dashboardController.getDeviceType() == "phone" ? getPhoneWidth():getTableWidth(),
//         child: Obx((){
//           return  Visibility(
//             visible: (dashboardController.isIn.value == 0 || dashboardController.isIn.value == 1) ? true:false,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 (dashboardController.isIn.value == 0)  ?
//                 Expanded(
//                   child: AppPrimaryButton(
//                     text: Strings.punchin,
//                     onPressed: (){
//                       dashboardController.flag.value = 0;
//                       navigateToScanFace("${AuthManager().getLoginData().data[0].employeeId}",
//                           AuthManager().getLoginData().data[0].employeeNm,
//                           isSignUp: false,mIsAuto: true
//                       );
//                     },
//                     textColor: Colors.black,
//                     borderColor:Theme.of(context).primaryColor ,
//                     bgColor: Theme.of(context).primaryColor,
//                   ),
//                 ):
//                 Expanded(
//                   child: AppPrimaryButton(
//                     text: Strings.punchout,
//                     onPressed: (){
//                       dashboardController.flag.value = 1;
//                       navigateToScanFace(
//                           "${AuthManager().getLoginData().data[0].employeeId}",
//                           AuthManager().getLoginData().data[0].employeeNm,
//                           isSignUp: false,mIsAuto: true
//                       );
//                     },
//                     textColor: Colors.black,
//                     borderColor:Theme.of(context).primaryColor ,
//                     bgColor: Theme.of(context).primaryColor,
//                   ),
//                 )
//               ],
//             ),
//           );
//         })
//
//     )
// ),
// SizedBox(
//   height: 50,
// ),
// Row(
//   mainAxisSize: MainAxisSize.max,
//   children: [
//     Visibility(
//       visible: false,
//       child: Expanded(
//         flex:1,
//         child:   Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                       child: Text("Time Diff")
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: Sizes.s15),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 NumberPicker(
//                   decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(16),
//                       border: Border.all(color: Colors.black26)
//                   ),
//                     value: dashboardController.timeIntValue,
//                     axis:Axis.horizontal,
//                     itemCount: 1,
//                     minValue: 1,
//                     maxValue: 60,
//                     itemHeight: 40,
//                     itemWidth: 62,
//                     onChanged: (value){
//                        dashboardController.readAllLocationsAndFilter(time: value);
//                         setState((){
//                           dashboardController.timeIntValue = value;
//                         }
//                         );
//                   },
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     ),
//     Visibility(
//       visible: false,
//       child: Expanded(
//         flex:1,
//         child: Align(
//             alignment: Alignment.bottomRight,
//             child:Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: AppPrimaryButton(
//                 isAsset: true,
//                 assetName:Assets.direction,
//                 bgColor: Theme.of(context).primaryColor,
//                 text:"Direction",
//                 textColor: Colors.black,
//                 onPressed: (){
//                   navigateToMapView();
//                 },
//               ),
//             )
//         ),
//       ),
//     ),
//   ],
// ),
// Column(
//   mainAxisSize: MainAxisSize.min,
//   children: [
//     Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Container(
//         decoration: BoxDecoration(
//             color: Theme.of(context).primaryColor
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             children: [
//               Expanded(child: Text("Sr No",               style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold), textAlign:    TextAlign.center,)),
//               Expanded(child: Text("Date",                style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold), textAlign:    TextAlign.center,)),
//               Expanded(child: Text("Check In",            style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold), textAlign:    TextAlign.start)),
//               Expanded(child: Text("Check Out",           style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold), textAlign:    TextAlign.start)),
//               //Expanded(child: Text("Time",  style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold),textAlign: TextAlign.start)),
//               //Expanded(child: Text("Location", style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold),textAlign: TextAlign.start)),
//               Expanded(child: Text("Total Hours",          style: TextStyles.textStyle.copyWith(fontWeight: FontWeight.bold),textAlign: TextAlign.center)),
//             ],
//           ),
//         ),
//       ),
//     ),
//     attendanceDetails(),
//   ],
// )

// _database = await openAppDatabase();
// String query = "select count(NULLIF(inTime,'')) as inCount,count(NULLIF(OutTime,'')) as outCount from tbl_attendance";
//  List<int> result =  await _database.transaction((txn) async{
//   List<int> inOutCount = [];
//    List<Map<String,dynamic>> result =  await txn.rawQuery(query);
//    inOutCount.add(result[0]["inCount"]);
//    inOutCount.add(result[0]["outCount"]);
//    return inOutCount;
// });
