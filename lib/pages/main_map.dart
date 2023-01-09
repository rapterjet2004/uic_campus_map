import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
// ignore: depend_on_referenced_packages
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:uic_map/database/database_controller/database_controller.dart';
import 'package:uic_map/database/models/additional_info_model.dart';
import 'package:uic_map/database/models/building_info_model.dart';
import 'package:uic_map/widgets/drawer.dart';
import 'package:uic_map/services/widget_notifications.dart';
import 'dart:developer' as developer;

class MainMapPage extends StatefulWidget {
  const MainMapPage({super.key});

  @override
  State<MainMapPage> createState() => _MainMapPageState();
}

class _MainMapPageState extends State<MainMapPage> {
  final LatLngBounds bounds =
      LatLngBounds(LatLng(41.86165, -87.6851), LatLng(41.8775, -87.6448));
  late final MapController _mapController;
  // final Location _locationService = Location();
  // LocationData? _currentLocation;
  bool _permission = false;
  // ignore: prefer_final_fields
  // bool _liveUpdate = true;
  // bool _isOutBounds = false;
  // bool _isHome = true;

  List<BuildingModel> _filteredModels = [];
  var _infoModel = ValueNotifier<InfoModel>(InfoModel());
  DraggableScrollableController dscontroller = DraggableScrollableController();


  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _mapController = MapController();
    initLocationService();
  }


  void initLocationService() async {
    _permission = await Permission.locationWhenInUse.request().isGranted;
    // LocationData? location;

    try {
      if (_permission) {
        // await _locationService.changeSettings(
        //   accuracy: LocationAccuracy.high,
        //   interval: 5000,
        // );
        // location = await _locationService.getLocation();
        // _currentLocation = location;
        // _locationService.onLocationChanged.listen((LocationData result) async {
        //   if (mounted) {
        //     setState(() {
        //       _currentLocation = result;
            
        //       if (_liveUpdate) { // Not actually needed but for some reasons a bunch of errors pop up if I remove this
        //         _mapController.move(
        //             LatLng(_currentLocation!.latitude!,
        //                 _currentLocation!.longitude!),
        //             _mapController.zoom);
        //       }
        //       _liveUpdate = false;
        //     });
        //   }
        // });
      } else {
        // The user opted to never again see the permission request dialog for this
        // app. The only way to change the permission's status now is to let the
        // user manually enable it in the system settings.
        openAppSettings();
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
      // location = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // developer.log('widget rebuilt', name: 'my.app.main_map');
    
    // LatLng currentLatLng;
    DatabaseController dbcontroller = DatabaseController('UIC__building_info.db');

    // if (_currentLocation != null) {
    //   currentLatLng =
    //       LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    // } else {
    //   currentLatLng = LatLng(0, 0); //default location is out of map bounds until location is retrieved
    // }

    final overlayImages = <BaseOverlayImage>[
      RotatedOverlayImage(
          topLeftCorner: LatLng(41.8760, -87.6846),
          bottomLeftCorner: LatLng(41.8618, -87.6840),
          bottomRightCorner: LatLng(41.8625, -87.6449),
          // bounds: LatLngBounds(LatLng(41.8614,-87.6843), LatLng( 41.8768, -87.6454)),
          opacity: 1,
          gaplessPlayback: true,
          imageProvider: const AssetImage("assets/images/mappnguntouched.png"))
    ];

    List<Marker> markers = [
      // Marker(
      //   width: 20,
      //   height: 20,
      //   point: currentLatLng,
      //   builder: (ctx) => DefaultLocationMarkerSimple(
      //     child: SvgPicture.asset(
      //       'assets/images/iconly_svg_optimized-optimized.svg',
      //     ),
      //   ),
      // ),
    ];

    _filteredModels.forEach(((m) => markers.add(Marker(
        height: 40,
        width: 40,
        point: LatLng(m.LATITUDE, m.LONGITUDE),
        builder: (ctx) => GestureDetector(
                onDoubleTap: () async {
                  
                  List<InfoModel> tempResults = await dbcontroller.searchAdditionalInfo(m.CODE);
                  setState(() {
                    _infoModel = ValueNotifier<InfoModel>(tempResults[0]);
                    if(tempResults[0] != null) {
                      //dscontroller.animateTo(0.6, duration: const Duration(seconds: 1), curve: Curves.easeIn);
                    }
                    });
                },
                child: SvgPicture.asset(
              'assets/icons/${m.TYPE}.svg',
            ))))));

      return Scaffold(
      body: Stack(
      children: <Widget>[
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            center: LatLng(41.8715, -87.6538),
            zoom: 16,
            minZoom: 15,
            maxZoom: 17,
            rotation: 0.9,
            interactiveFlags: InteractiveFlag.pinchZoom |
                InteractiveFlag.drag |
                InteractiveFlag.flingAnimation,
            maxBounds: bounds,
            slideOnBoundaries: true,
          ),
          
          children: [ // for testing map accuracy
            // TileLayer(
            //   tileProvider: AssetTileProvider(),
            //   maxZoom: 18,
            //   urlTemplate: 'assets/map/uic/{z}/{x}/{y}.png',
            // ),
            OverlayImageLayer(overlayImages: overlayImages),
            CurrentLocationLayer(
              style: LocationMarkerStyle(
              marker: DefaultLocationMarker(
                color: Theme.of(context).primaryColor,
              ),
              markerSize: const Size(20, 20),
              accuracyCircleColor: Theme.of(context).primaryColor.withOpacity(0.1),
              headingSectorColor: Theme.of(context).primaryColor.withOpacity(0.8),
              headingSectorRadius: 40,
            ),),
            MarkerLayer(markers: markers),
          ],
        ),
        NotificationListener<SearchResultTapped>(
            onNotification: (n) {
              setState(() {
                if(_filteredModels.isEmpty) {
                  _filteredModels.add(n.model);
                }
                else {
                  _filteredModels.remove(_filteredModels.last);
                  _filteredModels.add(n.model);
                }
        
                _mapController.move(
                    LatLng(n.model.LATITUDE,
                        n.model.LONGITUDE),
                    _mapController.zoom);
        
                developer.log('Search Result Recieved',
                    name: 'my.app.main_map');
              });
              return true;
            },
            child: RepaintBoundary(child: SearchPage(model: _infoModel, dbcontroller: dbcontroller, dscontroller: dscontroller,))),
        // Visibility(
        //   visible: _currentLocation == null,
        //   child: OutsideBoundsPage())
      ],
    
    )
    );
  }
}
