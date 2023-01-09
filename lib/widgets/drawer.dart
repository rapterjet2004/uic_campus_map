import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uic_map/database/database_controller/database_controller.dart';
import 'package:uic_map/database/models/additional_info_model.dart';
import 'package:uic_map/database/models/building_info_model.dart';
import 'package:uic_map/widgets/building_info_services.dart';
import 'package:uic_map/widgets/search_bar.dart';
import 'dart:developer' as developer;

class SearchPage extends StatefulWidget {
  final DatabaseController dbcontroller;
  final DraggableScrollableController dscontroller;
  final ValueListenable<InfoModel> model;
  const SearchPage({super.key, required this.model, required this.dbcontroller, required this.dscontroller});

  @override
  State<SearchPage> createState() => _DrawerState();
}

class _DrawerState extends State<SearchPage> {
  bool hideResults = false;

  @override
  Widget build(BuildContext context) {
    developer.log('widget rebuilt', name: 'my.app.drawer');
    return SizedBox.expand(
        child: DraggableScrollableSheet(
      snap: true,
      snapSizes: [0.4],
      controller: widget.dscontroller,
      maxChildSize: 0.6,
      minChildSize: 0.13,
      initialChildSize: 0.13,
      builder: (BuildContext context, ScrollController scrollController) {
        return GestureDetector(
          onTap: () => setState(() {
            hideResults = true;
          }),
          child: Container(
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(70),
                      topRight: Radius.circular(70)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      spreadRadius: 1,
                      blurRadius: 5,
                    )
                  ]),
              padding: const EdgeInsets.only(top: 20),
              child: CustomScrollView(
                primary: false,
                controller: scrollController,
                // ignore: prefer_const_literals_to_create_immutables
                slivers: <Widget>[
                  SliverPadding(
                    padding: const EdgeInsets.all(0),
                    sliver: SliverGrid.count(
                      crossAxisCount: 1,
                      children: [
                        Stack(
                          // Stack is here to act as a bounding box for all the drawer widgets, removing it results in weird aspect ratio
                          children: [
                            const Positioned(
                              top: 5,
                              left: 0,
                              right: 0,
                              child: Text(
                                "Search",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 4, 20, 101)),
                              ),
                            ),
                            Positioned(
                                top: 80,
                                left: 15,
                                right: 15,
                                child: BuildingInfoAndServices(model: widget.model)),
                            // ignore: prefer_const_constructors
                            Positioned(
                                top: 40, left: 35, right: 35, child: SearchBar(controller: widget.dbcontroller, hideResults: hideResults, drawerController: widget.dscontroller,)),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              )
              ),
        );
      },
    ));
  }
}
