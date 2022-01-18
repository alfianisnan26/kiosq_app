import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kiosq_app/Models/kiosk_model.dart';
import 'package:kiosq_app/Screens/Kiosk/kiosk.dart';
import 'package:kiosq_app/Variables/global.dart';

class Locations {
  static late LatLng myPos;
  static Future<Position> getMyPosition([BuildContext? context]) async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Global.showBar(context, Global.str.lsad);
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Global.showBar(context, Global.str.lpad);
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Global.showBar(context, Global.str.lppd);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    var pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    myPos = LatLng(pos.latitude, pos.longitude);
    return pos;
  }
}

// ignore: must_be_immutable
class Maps extends StatefulWidget {
  final Function(LatLng)? pinning;
  late List<KioskModel> models;
  Maps({
    Key? key,
    this.pinning,
    List<KioskModel>? models,
  }) : super(key: key) {
    this.models = models ?? KioskModel.all.values.toList();
  }
  @override
  State<StatefulWidget> createState() {
    return _Maps();
  }
}

class _Maps extends State<Maps> {
  @override
  void initState() {
    if (widget.pinning == null) {
      KioskModel.getAllKiosk();
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Marker? amarker;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (widget.pinning != null) widget.pinning?.call(amarker!.position);
            Navigator.of(context).pop();
          },
          child:
              Icon((widget.pinning != null) ? Icons.check : Icons.arrow_back),
        ),
        body: FutureBuilder(
          future: Locations.getMyPosition(context),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasData) {
              Position pos = (snapshot.data as Position);
              amarker = amarker ??
                  Marker(
                      markerId: const MarkerId("mine"),
                      position: LatLng(pos.latitude, pos.longitude));
              return GoogleMap(
                  padding: const EdgeInsets.only(top: 25),
                  myLocationButtonEnabled: true,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  markers: (widget.pinning != null)
                      ? {amarker!}
                      : widget.models
                          .where((element) => element.marker != null)
                          .map((e) => e.marker!)
                          .toSet(),
                  onTap: (widget.pinning == null)
                      ? null
                      : (pos) {
                          setState(() {
                            amarker = Marker(
                                markerId: const MarkerId("mine"),
                                position: LatLng(pos.latitude, pos.longitude));
                          });
                        },
                  initialCameraPosition: CameraPosition(
                      zoom: 12,
                      target: (widget.models.length == 1)
                          ? widget.models.single.location
                          : LatLng(pos.latitude, pos.longitude)));
            } else if (snapshot.hasError) {
              return const Center(child: Icon(Icons.error));
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ));
  }
}
