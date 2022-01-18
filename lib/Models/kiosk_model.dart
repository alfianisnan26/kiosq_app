import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kiosq_app/Models/admin_model.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Models/product_model.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Screens/Kiosk/kiosk.dart';
import 'package:kiosq_app/Screens/Maps/maps.dart';
import 'package:kiosq_app/Variables/global.dart';

class KioskModel {
  String name;
  late DateTime lastUpdate;
  LatLng location;
  String imageUrl;
  late List<Profile> users;
  String description;
  String id;
  Marker? marker;
  bool mobile;
  bool _session = false;
  bool get session {
    return _session;
  }

  Timer? _periodic;

  set session(bool value) {
    _session = value;
    FirebaseFirestore.instance
        .collection("kiosk")
        .doc(id)
        .update({"session": (value) ? Global.profile.uid : "N/A"});
    if (value) {
      if (_periodic != null && _periodic!.isActive) _periodic!.cancel();
      debugPrint("Activating Session");
      _periodic = Timer.periodic(const Duration(seconds: 2), (timer) {
        debugPrint("Update Seller's Session");
        Global.profile.updateOnline();
      });
    } else if (_periodic != null && _periodic!.isActive) {
      _periodic!.cancel();
    }
  }

  bool get isMine =>
      users.where((element) => element.uid == Global.profile.uid).isNotEmpty;

  double get distance {
    if (mobile && !session) {
      return -1;
    }
    return Geolocator.distanceBetween(Locations.myPos.latitude,
        Locations.myPos.longitude, location.latitude, location.longitude);
  }

  String get distanceString {
    if (distance < 0) {
      return Global.str.offline;
    } else if (distance > 500) {
      return (distance / 1000).toStringAsFixed(2) + "km";
    } else {
      return distance.toInt().toString() + "m";
    }
  }

  KioskModel(
      {this.mobile = false,
      this.marker,
      this.id = "",
      this.name = "",
      this.description = "",
      DateTime? lastUpdate,
      List<Profile>? users,
      this.imageUrl = "",
      required this.location}) {
    this.users = users ??= [Global.profile];
    this.lastUpdate = lastUpdate ?? DateTime.now();
  }

  static Map<String, KioskModel> all = {};

  static List<KioskModel> get allMine => all.values
      .where((element) => element.users
          .where((element) => element.uid == Global.profile.uid)
          .isNotEmpty)
      .toList();

  static Future<Map<String, KioskModel>> getAllKiosk(
      {bool force = false}) async {
    if (force || all.isEmpty) {
      final users = (await AdminModel.getUsers(force: true)).values;
      final value = await FirebaseFirestore.instance.collection("kiosk").get();
      all.clear();
      for (final element in value.docs) {
        bool mobile = element.get("mobile");
        LatLng location;
        if (mobile && element.get("session") != "N/A") {
          final data = (await FirebaseFirestore.instance
              .collection("users")
              .doc(element.get("session"))
              .get());
          location = LatLng(data.get("lat"), data.get("lng"));
        } else {
          location = LatLng(element.get("lat"), element.get("lng"));
        }
        KioskModel model = KioskModel(
            mobile: element.get("mobile") as bool,
            id: element.id,
            name: element.get("name") as String,
            description: element.get("description") as String,
            lastUpdate: (element.get("last_update") as Timestamp).toDate(),
            imageUrl: element.get("image") as String,
            users: users
                .where((e) => (element.get("users") as List).contains(e.uid))
                .toList(),
            location: location);
        model._session = (element.get("session") as String) != "N/A";
        model.marker = Marker(
            markerId: MarkerId(element.id),
            infoWindow: InfoWindow(
                onTap: () => Navigator.of(Global.navigator.currentContext!)
                    .push(MaterialPageRoute(builder: (_) => Kiosk(model))),
                title: "[${model.distanceString}] " +
                    (element.get("name") as String)),
            position: model.location);
        all[element.id] = model;
      }
    }
    return all;
  }

  Map<String, Product> products = {};

  Future<List<Cards>> getProductCards({bool force = false}) async {
    if (products.isEmpty || force) {
      products.clear();
      for (final i in (await FirebaseFirestore.instance
              .collection("products")
              .where("kioskid", isEqualTo: id)
              .get())
          .docs) {
        products[i.id] = Product.fromDoc(i);
      }
    }
    return products.values
        .map((e) => Cards(
            e.name +
                ((e.variant != null && e.variant!.isNotEmpty)
                    ? " [${e.variant}]"
                    : ""),
            e.lastUpdate,
            e.description,
            e,
            image: e.imageUrl,
            banner: (e.stock == 0) ? Global.str.soldout : e.priceToString))
        .toList();
  }

  static Future<List<Cards>> getCards(
      {bool mine = false, bool force = false, bool movingOnly = false}) async {
    await getAllKiosk(force: force);
    final value = (mine)
        ? allMine
        : (movingOnly)
            ? all.values.where((element) => element.mobile).toList()
            : all.values;
    return value
        .map((e) => Cards(e.name, e.lastUpdate, e.description, e,
            image: e.imageUrl, banner: e.distanceString))
        .toList();
  }

  Future<void> delete() async {
    await FirebaseFirestore.instance.collection("kiosk").doc(id).delete();
    all.remove(id);
  }

  Future<bool> post() async {
    final doc = await FirebaseFirestore.instance.collection("kiosk").add({
      "name": name,
      "image": "N/A",
      "last_update": lastUpdate,
      "lat": location.latitude,
      "lng": location.longitude,
      "mobile": mobile,
      "description": description,
      "session": "N/A",
      "users": users.map((e) => e.uid).toList()
    });
    if (imageUrl.isNotEmpty && !imageUrl.contains("http")) {
      final task = await FirebaseStorage.instance
          .ref("kiosk/photo/" + doc.id)
          .putFile(File(imageUrl));
      imageUrl = await task.ref.getDownloadURL();
      doc.update({"image": imageUrl});
    }
    id = doc.id;
    all[id] = this;
    return true;
  }
}
