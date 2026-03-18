import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'assets.dart';

class MapMarkerIcons {
  MapMarkerIcons._();

  static final Map<String, Future<BitmapDescriptor>> _cache = {};
  static const int _markerWidth = 96;
  static const int _selectedMarkerWidth = 112;

  static Future<BitmapDescriptor> busStop({bool selected = false}) {
    return _load(
      cacheKey: 'bus_stop_$selected',
      assetPath: AssetPaths.busStopIcon,
      targetWidth: selected ? _selectedMarkerWidth : _markerWidth,
    );
  }

  static Future<BitmapDescriptor> bus({bool selected = false}) {
    return _load(
      cacheKey: 'bus_$selected',
      assetPath: AssetPaths.busStopIcon,
      targetWidth: selected ? _selectedMarkerWidth : _markerWidth,
    );
  }

  static Future<BitmapDescriptor> startStop({bool selected = false}) {
    return _load(
      cacheKey: 'start_stop_$selected',
      assetPath: AssetPaths.startingStopIcon,
      targetWidth: selected ? _selectedMarkerWidth : _markerWidth,
    );
  }

  static Future<BitmapDescriptor> endStop({bool selected = false}) {
    return _load(
      cacheKey: 'end_stop_$selected',
      assetPath: AssetPaths.endingStopIcon,
      targetWidth: selected ? _selectedMarkerWidth : _markerWidth,
    );
  }

  static Future<BitmapDescriptor> _load({
    required String cacheKey,
    required String assetPath,
    required int targetWidth,
  }) {
    return _cache.putIfAbsent(
      cacheKey,
      () => _descriptorFromAsset(assetPath, targetWidth: targetWidth),
    );
  }

  static Future<BitmapDescriptor> _descriptorFromAsset(
    String assetPath, {
    required int targetWidth,
  }) async {
    final data = await rootBundle.load(assetPath);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: targetWidth,
    );
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.bytes(Uint8List.view(byteData!.buffer));
  }
}