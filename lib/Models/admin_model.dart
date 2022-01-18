import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Models/profile_model.dart';

class AdminModel {
  static Map<String, Profile> profiles = {};

  static Future<Map<String, Profile>> getUsers({bool force = false}) async {
    if (force || profiles.isEmpty) {
      try {
        (await FirebaseFirestore.instance.collection("users").get())
            .docs
            .toList()
            .forEach((e) => profiles[e.id] =
                Profile(withPrefs: false, uid: e.id).fromData(e.data()));
        return profiles;
      } catch (_) {
        return profiles;
      }
    } else {
      return profiles;
    }
  }

  static Future<List<Cards>> getCards({bool force = false}) async {
    return (await getUsers(force: force))
        .values
        .map((e) => Cards(e.firstname + " " + e.lastname, e.lastUpdate,
            (e.role.toString()), e,
            image: (e.urlPhoto.isNotEmpty && e.urlPhoto.length >= 10)
                ? e.urlPhoto
                : ""))
        .toList();
  }
}
