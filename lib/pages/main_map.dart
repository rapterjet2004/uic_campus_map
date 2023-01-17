import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
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
  bool _permission = false;
  DatabaseController dbcontroller = DatabaseController('UIC__building_info.db');
  // Default searched model when not searched
  BuildingModel searchedModel = const BuildingModel(
      ADDRESS: "ADDRESS",
      LATITUDE: 0,
      LONGITUDE: 0,
      CODE: "CODE",
      NAME: "NAME",
      TYPE: "Libraries",
      CAMPUS: "CAMPUS");
  List<List<BuildingModel>> filterModels = List.filled(5, <BuildingModel>[]);
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

    try {
      if (!_permission) {
        // The user opted to never again see the permission request dialog for this
        // app. The only way to change the permission's status now is to let the
        // user manually enable it in the system settings.
        openAppSettings();
      }
    } on PlatformException catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    List<BuildingModel> renderedModels = [];

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

    // I should make sure to create a way to remove duplicates
    // By default contains one widget at all times, which is the search widget
    List<Marker> searchMarker = [
      Marker(
          point: LatLng(searchedModel.LATITUDE, searchedModel.LONGITUDE),
          builder: (ctx) => GestureDetector(
              onDoubleTap: () => setState(() {
                    searchedModel = const BuildingModel(
                        ADDRESS: "ADDRESS",
                        LATITUDE: 0,
                        LONGITUDE: 0,
                        CODE: "CODE",
                        NAME: "NAME",
                        TYPE: "Libraries",
                        CAMPUS: "CAMPUS");
                  }),
              onTap: () async {
                List<InfoModel> tempResults =
                    await dbcontroller.searchAdditionalInfo(searchedModel.CODE);
                setState(() {
                  _infoModel = ValueNotifier<InfoModel>(tempResults[0]);
                });
                if (tempResults[0] != null) {
                  // animation seems more trouble than it's worth, but I'll
                  // keep this around for now
                  // dscontroller.animateTo(0.6,
                  //     duration: const Duration(seconds: 1),
                  //     curve: Curves.decelerate);
                }
              },
              child: SvgPicture.asset(
                'assets/icons/${searchedModel.TYPE}.svg',
              )))
    ];

    List<Marker> markers = [];

    for (int i = 0; i < filterModels.length; i++) {
      filterModels[i].forEach((m) {
        renderedModels.add(m);
      });
    }

    developer.log("Rendered Models: ${renderedModels.length}");
    // Determines the builder widget for each marker on screen

    
    renderedModels.forEach(((m) => markers.add(Marker(
        height: 20,
        width: 20,
        point: LatLng(m.LATITUDE, m.LONGITUDE),
        builder: (ctx) => GestureDetector(
            onTap: () async {
              List<InfoModel> tempResults =
                  await dbcontroller.searchAdditionalInfo(m.CODE);
              setState(() {
                _infoModel = ValueNotifier<InfoModel>(tempResults[0]);
                if (tempResults[0] != null) {
                  // dscontroller.animateTo(0.6,
                  //     duration: const Duration(seconds: 1),
                  //     curve: Curves.decelerate);
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
          children: [
            OverlayImageLayer(overlayImages: overlayImages),
            CurrentLocationLayer(
              style: LocationMarkerStyle(
                marker: DefaultLocationMarker(
                  color: Theme.of(context).primaryColor,
                ),
                markerSize: const Size(20, 20),
                accuracyCircleColor:
                    Theme.of(context).primaryColor.withOpacity(0.1),
                headingSectorColor:
                    Theme.of(context).primaryColor.withOpacity(0.8),
                headingSectorRadius: 40,
              ),
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                  maxClusterRadius: 40,
                  size: const Size(20, 20),
                  markers: markers,
                  builder: ((context, markers) {
                    return FloatingActionButton(
                        onPressed: null,
                        child: Text(
                          markers.length.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                  })),
            ),
            MarkerLayer(markers: searchMarker),
          ],
        ),
        NotificationListener<FilterTapped>(
          onNotification: (n) {
            setState(() {
              filterModels[n.filterNum] = n.models;
              developer.log(
                  "filter tap detected on index ${n.filterNum} with ${n.models.length} models");
            });

            return true;
          },
          child: NotificationListener<SearchResultTapped>(
              onNotification: (n) {
                setState(() {
                  searchedModel = n.model;

                  _mapController.move(
                      LatLng(n.model.LATITUDE, n.model.LONGITUDE),
                      _mapController.zoom);

                  developer.log('Search Result Recieved',
                      name: 'my.app.main_map');
                });
                return true;
              },
              child: SearchPage(
                model: _infoModel,
                dbcontroller: dbcontroller,
                dscontroller: dscontroller,
              )),
        ),
      ],
    ));
  }
}
