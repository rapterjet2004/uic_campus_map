import 'package:flutter/material.dart';
import 'package:uic_map/database/models/building_info_model.dart';

class SearchResultTapped extends Notification {
  final BuildingModel model;
  SearchResultTapped(this.model);
}

class FilterTapped extends Notification {
  final List<BuildingModel> models;
  final int filterNum;
  FilterTapped(this.models, this.filterNum);
}