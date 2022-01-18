import 'dart:convert';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

class ArticlePagesModel {
  String title;
  String subtitle;
  String urlToImage;
  String urlToContent;
  late DateTime dateUploaded;
  bool liked;
  String get id =>
      md5.convert(utf8.encode(dateUploaded.toIso8601String())).toString();

  ArticlePagesModel(
      {this.title = "N/A",
      this.subtitle = "N/A",
      this.urlToImage = "N/A",
      this.urlToContent = "N/A",
      this.liked = false,
      DateTime? dateUploaded}) {
    this.dateUploaded = dateUploaded ?? DateTime.now();
  }
  factory ArticlePagesModel.fromJson(dynamic json, String? id) {
    bool liked;
    try {
      liked = json["favorites"][id] as bool;
    } catch (_) {
      liked = false;
    }
    return ArticlePagesModel(
        title: json["title"] as String,
        subtitle: json["subtitle"] as String,
        urlToImage: json["image_link"] as String,
        urlToContent: json["content_link"] as String,
        liked: liked,
        dateUploaded: DateTime.parse(json["created_at"] as String));
  }

  Future<bool?> like(String uid) async {
    final ret = (await http.put(
        Uri.parse(
            Global.dbLink + "articles/" + id + "/favorites/" + uid + ".json"),
        body: (!liked) ? "true" : "null"));
    return (ret.statusCode == 200) ? liked = !liked : null;
  }

  static List<ArticlePagesModel> allData = [];

  static String link = Global.dbLink + "articles.json";

  Future<bool> updateOn(String loc, String data) async {
    return (await http.put(
                Uri.parse(Global.dbLink + "articles/" + id + "/$loc.json"),
                body: data))
            .statusCode ==
        200;
  }

  Future<bool> delete() async {
    ListResult list =
        await FirebaseStorage.instance.ref("articles").child(id).listAll();
    for (var element in list.items) {
      element.delete();
    }
    final ret = await http.put(
        Uri.parse(
          Global.dbLink + "articles/" + id + ".json",
        ),
        body: "null");
    return ret.statusCode == 200;
  }

  Future<bool> post(
      {String urlToImage = 'N/A', String urlToContent = 'N/A'}) async {
    final ret =
        (await http.put(Uri.parse(Global.dbLink + "articles/" + id + ".json"),
            body: '{"title":"$title",'
                '"subtitle":"$subtitle",'
                '"image_link":"$urlToImage",'
                '"created_at":"$dateUploaded",'
                '"content_link":"$urlToContent"}'));
    return ret.statusCode == 200;
  }

  static Future<List<ArticlePagesModel>> getData(String? id,
      {bool force = false}) async {
    if (allData.isEmpty || force) {
      var ret = (await http.get(Uri.parse(link)));
      if (ret.statusCode == 200 && ret.body != "null") {
        return allData = (json.decode(ret.body) as Map<String, dynamic>)
            .map((key, e) {
              return MapEntry(key, ArticlePagesModel.fromJson(e, id));
            })
            .values
            .toList();
      } else {
        return [];
      }
    } else {
      return allData;
    }
  }

  static Future<List<Cards>> getCards(
    String? id, {
    bool force = false,
  }) async {
    return [];
    // return (await getData(id, force: force))
    //     .map((e) => Cards(e.title, e.dateUploaded, e.subtitle, e,
    //         image: (e.urlToImage.isNotEmpty && e.urlToImage.length >= 10)
    //             ? e.urlToImage
    //             : ""))
    //     .toList();
  }
}
