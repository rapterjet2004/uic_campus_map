import 'package:flutter/material.dart';
import 'package:uic_map/database/database_controller/database_controller.dart';
import 'package:uic_map/database/models/building_info_model.dart';
import 'dart:developer' as developer;

import 'package:uic_map/services/widget_notifications.dart';

class Filter extends StatefulWidget {
  DatabaseController dbcontroller;
  Filter({super.key, required this.dbcontroller});

  @override
  State<Filter> createState() => _FilterState();
}

class _FilterState extends State<Filter> {
  List<bool> filterTapped = [false, false, false, false, false];
  List<String> filters = [ // This list determines the order of the markers on screen
    "Bathrooms",
    "Study Locations",
    "Dining",
    "Computer Labs",
    "ATMS"
  ];

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Container(
        height: 50,
        child: Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: (() async {
                    List<BuildingModel> tempResults = [];
                    if(!filterTapped[index]) {
                      tempResults = await widget.dbcontroller.searchFilterInfo(filters[index]);
                    }
                    setState(() {
                      filterTapped[index] = !filterTapped[index]; // flips filter color to red or gray on click
                      FilterTapped(tempResults, index).dispatch(context);
                    });
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Container(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(70),
                            color: (filterTapped[index])
                                ? Theme.of(context).primaryColor
                                : const Color.fromARGB(255, 245, 245, 245)),
                        child: Center(
                            child: Text(
                          filters[index],
                          style: TextStyle(
                            color: (filterTapped[index])
                                ? Colors.white
                                : Colors.black,
                          ),
                          textAlign: TextAlign.center,
                        ))),
                  ),
                );
              }),
        ),
      ),
    );
  }
}
