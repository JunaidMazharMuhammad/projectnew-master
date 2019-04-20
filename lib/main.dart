
import 'dart:async';

import 'package:flutter/material.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project/Compass.dart';
import "package:google_maps_webservice/geocoding.dart";
import 'package:geo_location_finder/geo_location_finder.dart';
import 'package:google_maps_webservice/places.dart';


void main() => runApp(MyApp());



class MyApp extends StatefulWidget {

  @override

  _MyAppState createState() => _MyAppState();

}



class _MyAppState extends State<MyApp> {

  Completer<GoogleMapController> _controller = Completer();

  final homeScaffoldKey = GlobalKey<ScaffoldState>();

  static const kGoogleApiKey = "AIzaSyC_2vdelF5OBkFaphMp265a44jVwcF_eYI";

  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

  static  LatLng _center =  LatLng(24.773, 67.0762);


  final Set<Marker> _markers = {};


  static  LatLng _lastMapPosition = _center;


  MapType _currentMapType = MapType.normal;


  List<PlacesSearchResult> places = [];

  void _onMapTypeButtonPressed() {

    setState(() {

      _currentMapType = _currentMapType == MapType.normal

          ? MapType.satellite

          : MapType.normal;

    });

  }

  Future<void> _setLocation() async {
    Map<dynamic, dynamic> locationMap;
    String result;
    try {
      locationMap = await GeoLocation.getLocation;

      var status = locationMap["status"];
      if ((status is String && status == "true") ||
          (status is bool) && status) {
        var lat = locationMap["latitude"];
        var lng = locationMap["longitude"];
        if (lat is String) {
          result = "Location: ($lat, $lng)";

          _center=LatLng(double.parse(lat),double.parse(lng));

//          print(double.parse(lat));
        } else {
          // lat and lng are not string, you need to check the data type and use accordingly.
          // it might possible that else will be called in Android as we are getting double from it.
          _center=LatLng(lat, lng);
          result = "Location: ($lat, $lng)";
        }
      } else {
        result = locationMap["message"];
      }

    }
    catch(e){

    }

  }




  void _onAddMarkerButtonPressed() async {

    _goToTheLocation();
    var location = Location(_center.latitude,_center.longitude);

    final result = await _places.searchByText("Masjid",location: location, radius: 1000,type: "Masjid");
    setState(() {
      result.results.forEach((f) {

        this.places = result.results;

        LatLng newloc= LatLng(f.geometry.location.lat, f.geometry.location.lng);
        print(f.name);


        _lastMapPosition=newloc;
        print(f.geometry.location.lat.toString() + f.geometry.location.lng.toString());
        _markers.add(Marker(


          // This marker id can be anything that uniquely identifies each marker.

          markerId: MarkerId(_lastMapPosition.toString()),

          position:  _lastMapPosition,

          infoWindow: InfoWindow(

            title: f.name,

            snippet:f.formattedAddress,



          ),

          icon: BitmapDescriptor.defaultMarker,
        ));
      });

    });


  }



  void _onCameraMove(CameraPosition position) {
    _lastMapPosition = position.target;
  }
  Future<void> _goToTheLocation() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_center,17));

  }



  Future _onMapCreated(GoogleMapController controller) async {
    Map<dynamic, dynamic> locationMap;
    String result;
    try {
      locationMap = await GeoLocation.getLocation;

      var status = locationMap["status"];
      if ((status is String && status == "true") ||
          (status is bool) && status) {
        var lat = locationMap["latitude"];
        var lng = locationMap["longitude"];
        if (lat is String) {
          result = "Location: ($lat, $lng)";

          _center=LatLng(double.parse(lat),double.parse(lng));

//          print(double.parse(lat));
        } else {
          // lat and lng are not string, you need to check the data type and use accordingly.
          // it might possible that else will be called in Android as we are getting double from it.
          _center=LatLng(lat, lng);
          result = "Location: ($lat, $lng)";
        }
      } else {
        result = locationMap["message"];
      }

    }
    catch(e){

    }
     _controller.complete(controller);

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(

      home: Scaffold(

        appBar: AppBar(

          title: Text('Maps Sample App'),

          backgroundColor: Colors.green[700],

        ),

        body: Stack(

          children: <Widget>[

            GoogleMap(

              onMapCreated: _onMapCreated,


              initialCameraPosition: CameraPosition(

                target: _center,

                zoom: 10.0,

              ),

              mapType: _currentMapType,

              markers: _markers,

              onCameraMove: _onCameraMove,

              myLocationEnabled:true,

            ),

            Padding(

              padding: const EdgeInsets.all(16.0),

              child: Align(

                alignment: Alignment.topRight,

                child: Column(



                  children: <Widget>[

                    SizedBox(height: 60.0),


                    FloatingActionButton(

                      onPressed: _onMapTypeButtonPressed,

                      materialTapTargetSize: MaterialTapTargetSize.padded,

                      backgroundColor: Colors.green,

                      child: const Icon(Icons.map, size: 36.0),


                    ),

                    SizedBox(height: 16.0),

                    FloatingActionButton(

                      onPressed: _onAddMarkerButtonPressed,

                      materialTapTargetSize: MaterialTapTargetSize.padded,

                      backgroundColor: Colors.green,

                      child: const Icon(Icons.add_location, size: 36.0),

                    ),

                    SizedBox(height: 16.0),

                    FloatingActionButton(
                      onPressed: (){
                        Route route = MaterialPageRoute(builder: (context) => Compass());
                        Navigator.push(context, route);
                        },

                      materialTapTargetSize: MaterialTapTargetSize.padded,

                      backgroundColor: Colors.green,

                      child: const Icon(Icons.near_me, size: 36.0),


                    ),



                  ],

                ),

              ),

            ),

          ],

        ),

      ),

    );

  }

  void openCompass() async {


    Navigator.of(context).pushNamed('/compass');
  }
}