import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uic_map/database/models/additional_info_model.dart';


class BuildingInfoAndServices extends StatelessWidget {
  final ValueListenable<InfoModel> model;
  /// Create a BuildingInfoAndServices.
  BuildingInfoAndServices({
    super.key,
    required this.model
  });

  @override
  Widget build(BuildContext context) {
  final ScrollController firstController = ScrollController();

    return ValueListenableBuilder(
      valueListenable: model,
      builder: (context, value, child) {
        return Visibility(
          visible: model.value.NAME != null,
          child: Padding(
            padding: const EdgeInsets.only(right: 20, left: 20, top: 20),
            child: Container(
              height: 240,
              child: Scrollbar(
                thumbVisibility: false,
                thickness: 2,
                controller: firstController,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Text("${model.value.NAME} (${model.value.CODE})" ,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 4, 20, 101),
                        fontWeight: FontWeight.bold
                      )),
                      Text("${model.value.ADDRESS}"),
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text("${model.value.INFO}"),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}