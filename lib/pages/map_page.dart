import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:polgon_and_table/services/location_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? _currentPosition;

  MapboxMap? mapBoxMap;

  final List<List<num>> _points = [];

  String currentPolygonLayerId = "";
  int currentPolygonColor = 0xFF73FF00;

  @override
  void initState() {
    super.initState();

    _setCurrentPositon();
  }

  Future<void> _setCurrentPositon() async {
    await _updateCurrentPosition();

    mapBoxMap?.easeTo(
        CameraOptions(
          center: Point(coordinates: _currentPosition ?? Position(42, 42)),
          zoom: 15,
          bearing: 0,
          pitch: 0,
        ),
        MapAnimationOptions(duration: 1000, startDelay: 0));
  }

  Future<void> _updateCurrentPosition() async {
    var newPos = await getUserLocation();

    setState(() {
      _currentPosition = newPos;
    });
  }

  _onTap(MapContentGestureContext context) {
    setState(() {
      _points.add([
        context.point.coordinates.lng,
        context.point.coordinates.lat,
      ]);
    });

    if (currentPolygonLayerId.isEmpty) {
      _createNewPolygon();
    }

    _updatePolygon();
  }

  void _createNewPolygon() {
    setState(() {
      currentPolygonLayerId =
          "polygon_layer_${DateTime.now().millisecondsSinceEpoch}";
      currentPolygonColor = (Random().nextInt(0xFFFFFF) + 0xFF000000);

      _points.clear();
    });

    mapBoxMap?.style.addSource(
      GeoJsonSource(
        id: '$currentPolygonLayerId _source',
      ),
    );

    mapBoxMap?.style.addLayer(
      FillLayer(
        id: currentPolygonLayerId,
        sourceId: '$currentPolygonLayerId _source',
        fillOpacity: 0.6,
        fillColor: 0xFF73FF00,
        fillOutlineColor: 0xFF51FF00,
      ),
    );

    _updatePolygon();
  }

  void _updatePolygon() {
    if (currentPolygonLayerId.isEmpty) return;

    String _sourceId = '$currentPolygonLayerId _source';

    if (_points.length < 3) {

      //update dont work so we need to remove and add again
      mapBoxMap?.style.removeStyleLayer(currentPolygonLayerId);
      mapBoxMap?.style.removeStyleSource(_sourceId);
      
      mapBoxMap?.style.addSource(GeoJsonSource(
        id: _sourceId,
      ));

      mapBoxMap?.style.addLayer(
        FillLayer(
          id: currentPolygonLayerId,
          sourceId: _sourceId,
        ),
      );

      return;
    }

    final geometry = jsonEncode({
      'type': 'Polygon',
      'coordinates': [
        _points.map((point) => [point[0], point[1]]).toList()
          ..add([_points.first[0], _points.first[1]]),
      ],
    });

    mapBoxMap?.style.removeStyleLayer(currentPolygonLayerId);
    mapBoxMap?.style.removeStyleSource(_sourceId);

    mapBoxMap?.style.addSource(GeoJsonSource(
      id: _sourceId,
      data: geometry,
    ));

    mapBoxMap?.style.addLayer(
      FillLayer(
        id: currentPolygonLayerId,
        sourceId: _sourceId,
        fillOpacity: 0.6,
        fillColor: currentPolygonColor,
      ),
    );
  }

  void _cleanPoligon() async {
    setState(() {
      _points.clear();
    });

    _updatePolygon();
  }

  void _removeLastPoint() {
    setState(() {
      _points.removeLast();
    });

    _updatePolygon();
  }

  void _savePolygon() {
    _createNewPolygon();
  }

  @override
  Widget build(BuildContext context) {
    CameraOptions camera = CameraOptions(
      center: Point(coordinates: Position(0, 0)),
      zoom: 3,
      bearing: 0,
      pitch: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: Stack(
        children: [
          MapWidget(
            cameraOptions: camera,
            onTapListener: _onTap,
            onMapCreated: (map) {
              setState(() {
                mapBoxMap = map;
              });

              map.location.updateSettings(
                LocationComponentSettings(
                  enabled: true,
                ),
              );
            },
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 32,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                    onPressed: _setCurrentPositon,
                    icon: const Icon(Icons.my_location)),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      ElevatedButton(
                          onPressed: _cleanPoligon, child: Text("clean")),
                      const SizedBox(width: 8),
                      ElevatedButton(
                          onPressed: _removeLastPoint,
                          child: Text("remove last point")),
                    ]),
                    ElevatedButton(
                        onPressed: _savePolygon, child: Text("save")),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
