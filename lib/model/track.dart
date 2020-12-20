import 'package:flutter/material.dart';

enum TrackStatus {
  neutral,
  like,
  disLike,
}

class Track with ChangeNotifier {
  final String id;
  final String trackName;
  final String trackBand;
  final String releaseYear;
  final String image;
  final TrackStatus trackStatus;

  Track({
    this.id,
    this.trackName,
    this.trackBand,
    this.releaseYear,
    this.image,
    this.trackStatus,
  });
}
