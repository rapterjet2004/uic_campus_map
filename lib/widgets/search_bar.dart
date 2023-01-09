// ignore_for_file: prefer_const_literals_to_create_immutables
// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:uic_map/database/database_controller/database_controller.dart';
import 'package:uic_map/database/models/building_info_model.dart';
import 'dart:developer' as developer;

import 'package:uic_map/services/widget_notifications.dart';

class SearchBar extends StatefulWidget {
  final DatabaseController controller;
  final DraggableScrollableController drawerController;
  bool hideResults;
  SearchBar({super.key, required this.controller, required this.hideResults, required this.drawerController});

  @override
  State<SearchBar> createState() => _SearchState();
}

class _SearchState extends State<SearchBar> {
  List<BuildingModel> searchResults = [];

  @override
  Widget build(BuildContext context) {
    // developer.log('widget rebuilt', name: 'my.app.search_bar');
    int size = (searchResults.length <= 3)? searchResults.length : 3;
    // developer.log('Search Result size: $size', name: 'my.app.search_bar');
    // if (size > 0) {
    //   developer.log(searchResults[0].toString(), name: 'my.app.search_bar');
    // }

    return Container(
      alignment: Alignment.center,
      child: Stack(
        children: <Widget>[
          Visibility(
            visible: !widget.hideResults,
            child: Padding(
              padding: const EdgeInsets.only(top: 13.0),
              // Search Result box
              child: Container(
                width: 350,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(45),
                        bottomRight: Radius.circular(45)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        spreadRadius: 1,
                        blurRadius: 5,
                      )
                    ],
                    color: Colors.white),
                child: ListView.builder(
                  itemCount: size,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(searchResults[index].NAME),
                      subtitle: Text(searchResults[index].CAMPUS),
                      leading: Text(searchResults[index].CODE),
                      onTap: () {
                        SearchResultTapped(searchResults[index]).dispatch(context);
                        searchResults = <BuildingModel>[];
                      },
                    );
                  },
                ),
              ),
            ),
          ),
            // SearchBox
          Container(
            width: 350,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(70),
                border: Border.all(width: 1, color: Colors.black)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: const InputDecoration.collapsed(
                  hintText: 'Search',
                ),
                onSubmitted: (query) {
                  if(searchResults.isNotEmpty && query.isNotEmpty) {
                    SearchResultTapped(searchResults[0]).dispatch(context);
                    searchResults = <BuildingModel>[];
                  }
                  else{
                    searchResults = <BuildingModel>[];
                  }
                },
                onChanged: (query) async {
                  List<BuildingModel> tempResults =
                      await widget.controller.searchBuildingInfo(query.toUpperCase());
                  setState(() { 
                    searchResults = tempResults;
                    widget.hideResults = false;
                    });
                },
                onTap: () => setState(() {
                  widget.hideResults = false;
                  widget.drawerController.jumpTo(0.6);
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
