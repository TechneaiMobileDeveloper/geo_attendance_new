// import 'dart:async';
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
//
// class MapView extends StatelessWidget {
//   List<Position> positions= [];
//   MapView(this.positions);
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Google Maps Demo',
//       home: MapSample(this.positions),
//     );
//   }
// }
//
// class MapSample extends StatefulWidget {
//   List<Position> positions;
//   MapSample(this.positions);
//   @override
//   State<MapSample> createState() => MapSampleState();
// }
//
// class MapSampleState extends State<MapSample> {
//   Completer<GoogleMapController> _controller = Completer();
//   int  _polygonIdCounter = 0;
//   Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
//   Map<PolygonId, double> polygonOffsets = <PolygonId, double>{};
//   PolygonId selectedPolygon;
//
//   static  CameraPosition _kGooglePlex ;
//   Map<PolygonId, Polygon> polygons = <PolygonId, Polygon>{};
//   static final CameraPosition _kLake = CameraPosition(
//       bearing: 192.8334901395799,
//       target: LatLng(37.43296265331129, -122.08832357078792),
//       tilt: 59.440717697143555,
//       zoom: 19.151926040649414);
//
//
//   @override
//   void initState() {
//         _add();
//       fetchCurrentLocation();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return new Scaffold(
//       body: _kGooglePlex != null && polygons.length > 0 ?
//       GoogleMap(
//         mapType: MapType.hybrid,
//         myLocationEnabled: true,
//         markers: Set<Marker>.of(markers.values),
//         initialCameraPosition: _kGooglePlex,
//           polygons: Set<Polygon>.of(polygons.values),
//          onMapCreated: (GoogleMapController controller) {
//           _controller.complete(controller);
//         },
//       ):Center(
//         child:CircularProgressIndicator()
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: _goToTheLake,
//         label: Text('To the lake!'),
//         icon: Icon(Icons.directions_boat),
//       ),
//     );
//   }
//
//   Future<void> _goToTheLake() async {
//     final GoogleMapController controller = await _controller.future;
//     controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
//   }
//
//   void fetchCurrentLocation() async{
//     Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     Map<MarkerId,Marker> mark = Map();
//     final MarkerId markerId =   MarkerId("Hello");
//     final Marker marker =       Marker(
//                                  markerId: markerId,
//                                  position: LatLng(
//           position.latitude ,
//         position.longitude ,
//       ),
//                                  infoWindow: InfoWindow(title: "Hello", snippet: '*'),
//                                  onTap: () {
//
//                                  },
//     );
//     mark[markerId]= marker;
//     markers.addEntries(mark.entries);
//     setState(() {
//       _kGooglePlex  = CameraPosition(
//         target: LatLng(position.latitude, position.longitude),
//         zoom: 14.4746,
//       );
//     });
//   }
//
//   void _add() {
//
//     final String polygonIdVal = 'polygon_id_$_polygonIdCounter';
//     final PolygonId polygonId = PolygonId(polygonIdVal);
//
//     final Polygon polygon = Polygon(
//       polygonId: polygonId,
//       consumeTapEvents: true,
//       strokeColor: Colors.orange,
//       strokeWidth: 5,
//       fillColor: Colors.green,
//       points: _createPoints(),
//       onTap: () {
//         _onPolygonTapped(polygonId);
//       },
//     );
//
//     setState(() {
//       polygons[polygonId] = polygon;
//       polygonOffsets[polygonId] = _polygonIdCounter.ceilToDouble();
//       _polygonIdCounter++;
//     });
//   }
//
//   List<LatLng> _createPoints() {
//     //final int polygonCount = polygons.length;
//     final List<LatLng> points = <LatLng>[];
//     final double offset = _polygonIdCounter.ceilToDouble();
//     for(int i=0;i<widget.positions.length;i++){
//       points.add(_createLatLng(widget.positions[i].latitude+offset, widget.positions[i].longitude));
//     }
//
//     return points;
//   }
//
//   LatLng _createLatLng(double lat, double lng) {
//     return LatLng(lat, lng);
//   }
//
//   void _onPolygonTapped(PolygonId polygonId) {
//     setState(() {
//       selectedPolygon = polygonId;
//     });
//   }
//
//
// }
