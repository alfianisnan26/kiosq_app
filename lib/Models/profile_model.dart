import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:kiosq_app/Database/DBMS/authentication.dart';
import 'package:kiosq_app/Database/Preferences/user_preferences.dart';
import 'package:kiosq_app/Models/admin_model.dart';
import 'package:kiosq_app/Screens/Maps/maps.dart';
import 'package:kiosq_app/Variables/global.dart';

class Profile extends ChangeNotifier {
  User? user;
  String firstname = "N/A";
  String lastname = "N/A";
  String address = "N/A";
  String email = "N/A";
  String portofolio = "N/A";
  String profile = "N/A";
  String urlPhoto = "N/A";
  bool loading = false;
  int role = 0;
  int mode = 0;
  String uid = "N/A";
  late DateTime lastUpdate;

  Profile fromData(Map<String, dynamic> json) {
    firstname = json["firstname"] as String? ?? "N/A";
    lastname = json["lastname"] as String? ?? "N/A";
    address = json["address"] as String? ?? "N/A";
    email = json["email"] as String? ?? "N/A";
    role = json["role"] as int? ?? 0;
    portofolio = json["pro_porto"] as String? ?? "N/A";
    profile = json["pro_profile"] as String? ?? "N/A";
    mode = json["mode"] as int? ?? 0;
    lastUpdate =
        ((json["last_seen"] as fs.Timestamp?) ?? fs.Timestamp.now()).toDate();
    urlPhoto = json["photo"] as String? ?? "N/A";
    return this;
  }

  final UserPreferences _preferences = UserPreferences();

  Profile({withPrefs = true, this.uid = ""}) {
    if (withPrefs) getPreferences();
    lastUpdate = DateTime.now();
  }

  getPreferences() async {
    bool hasLogin = await _preferences.getUser() ?? false;
    if (hasLogin) {
      debugPrint("Trying to login");
      await login();
    }
  }

  bool get isLogin => role > 0;

  Color roleColor({from = -1}) {
    switch ((from >= 0) ? from : role) {
      case 1:
        return Colors.purple;
      case 2:
        return Colors.green;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  String roleStr({from = -1}) {
    switch ((from >= 0) ? from : role) {
      case 1:
        return "USER";
      case 2:
        return "PRO";
      case 3:
        return "SU";
      case 4:
        return "ADMIN";
      default:
        return "GUEST";
    }
  }

  Timer? periodic;

  Future<bool> updateOnline() async {
    final location =
        await Locations.getMyPosition(Global.navigator.currentContext);
    await updateOn({
      "last_seen": DateTime.now(),
      "lat": location.latitude,
      "lng": location.longitude
    });
    //await AdminModel.getUsers(force: true);
    return true;
  }

  Future<bool> delete() async {
    ListResult list =
        await FirebaseStorage.instance.ref("professional").child(uid).listAll();
    for (final element in list.items) {
      element.delete();
    }
    await fs.FirebaseFirestore.instance.collection("users").doc(uid).delete();
    return true;
  }

  Future<bool> updateOn(Map<String, dynamic> data) async {
    await fs.FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update(data);
    return true;
  }

  Future<bool> putData() async {
    final location =
        await Locations.getMyPosition(Global.navigator.currentContext);
    await fs.FirebaseFirestore.instance.collection("users").doc(uid).set({
      "address": address,
      "email": email,
      "firstname": firstname,
      "lastname": lastname,
      "mode": mode,
      "pro_porto": portofolio,
      "pro_profile": profile,
      "role": role,
      "photo": urlPhoto,
      "last_seen": lastUpdate,
      "lat": location.latitude,
      "lng": location.longitude
    });

    return true;
  }

  Future<bool> getData() async {
    try {
      uid = user!.uid;
    } catch (_) {}
    final Map<String, dynamic>? data =
        (await fs.FirebaseFirestore.instance.collection("users").doc(uid).get())
                .data() ??
            {};
    if (data == null || data.isEmpty) {
      var name = user!.displayName!.split(" ");
      name = name
          .map((e) => "${e[0].toUpperCase()}${e.substring(1).toLowerCase()}")
          .toList();
      firstname = name.removeAt(0);
      lastname = name.join(" ");
      email = user!.email ?? "N/A";
      address = "N/A";
      role = 1;
      portofolio = "N/A";
      profile = "N/A";
      mode = 0;
    } else {
      fromData(data);
    }
    urlPhoto = user!.photoURL!;
    return await putData();
  }

  Future<bool> login() async {
    loading = true;
    notifyListeners();
    user = await Authentication.signInWithGoogle();
    if (user != null && await getData()) {
      _preferences.setUser(true);
      loading = false;
      Settings.clearCache();
      notifyListeners();
      periodic = Timer.periodic(const Duration(seconds: 30), (timer) async {
        debugPrint("Update at ${DateTime.now()} : " +
            (await updateOnline()).toString());
      });
      return true;
    } else {
      loading = false;
      role = 0;
      notifyListeners();
      return false;
    }
  }

  Future<bool> logout() async {
    if (await Authentication.signOut()) {
      role = 0;
      notifyListeners();
      _preferences.setUser(false);
      periodic!.cancel();
      return true;
    }
    return false;
  }
}
