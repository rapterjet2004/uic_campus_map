import 'package:flutter/material.dart';
import 'package:uic_map/database/models/building_info_model.dart';

class SearchResultTapped extends Notification {
  final BuildingModel model;
  SearchResultTapped(this.model);
}