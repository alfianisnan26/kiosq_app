import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:kiosq_app/Models/admin_model.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Screens/Chat/chatroom.dart';
import 'package:kiosq_app/Utils/duration_format.dart';
import 'package:kiosq_app/Utils/filechoseviewer.dart';
import 'package:kiosq_app/Utils/notification.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:crypto/crypto.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatStatus {
  final int _value;
  const ChatStatus._internal(this._value);

  static const sending = ChatStatus._internal(0);
  static const sent = ChatStatus._internal(1);
  static const deliver = ChatStatus._internal(2);
  static const seen = ChatStatus._internal(3);
  static const error = ChatStatus._internal(4);
  static const deleting = ChatStatus._internal(5);
  static const uploading = ChatStatus._internal(6);
  static parse(int value) {
    switch (value) {
      case 1:
        return ChatStatus.sent;
      case 2:
        return ChatStatus.deliver;
      case 3:
        return ChatStatus.seen;
      case 4:
        return ChatStatus.deleting;
      case 5:
        return ChatStatus.uploading;
      case 0:
        return ChatStatus.sending;
      default:
        return Global.str.error.toUpperCase();
    }
  }

  @override
  toString() {
    switch (this) {
      case ChatStatus.sent:
        return Global.str.sent.toUpperCase();
      case ChatStatus.deliver:
        return Global.str.delivered.toUpperCase();
      case ChatStatus.seen:
        return Global.str.seen.toUpperCase();
      case ChatStatus.deleting:
        return Global.str.deleting.toUpperCase();
      case ChatStatus.uploading:
        return Global.str.uploading.toUpperCase();
      case ChatStatus.sending:
        return Global.str.sending.toUpperCase();
      default:
        return Global.str.error.toUpperCase();
    }
  }
}

class ChatModel {
  final Profile his;
  String msg;
  final DateTime date;
  final bool isImage;
  bool oncloud;
  late String id;
  ChatStatus state;
  final bool fromhim;
  DocumentReference<Map<String, dynamic>> get chat =>
      FirebaseFirestore.instance.collection('chats').doc(chatId(his));

  ChatModel(this.his, this.msg, this.date,
      {this.isImage = false,
      this.fromhim = false,
      this.oncloud = true,
      String? id,
      this.state = ChatStatus.sent}) {
    this.id = id ??
        md5.convert(utf8.encode(DateTime.now().toIso8601String())).toString();
  }

  static String chatId(Profile his) {
    return Global.profile.uid.compareTo(his.uid) > 0
        ? Global.profile.uid + his.uid
        : his.uid + Global.profile.uid;
  }

  Future<bool> sendImage({Function(double)? task}) async {
    Reference storageReference = FirebaseStorage.instance
        .ref("chats")
        .child(chatId(his) + "/" + DateTime.now().toIso8601String());
    UploadTask uploadTask = storageReference.putData(
        await FlutterImageCompress.compressWithList(
            await File(msg).readAsBytes(),
            format: CompressFormat.webp,
            minHeight: 1000,
            minWidth: 1000,
            quality: 50));
    uploadTask.snapshotEvents.forEach((element) {
      if (task != null) {
        task.call((element.bytesTransferred / element.totalBytes));
      }
    });
    await uploadTask.whenComplete(() async {
      if (uploadTask.snapshot.bytesTransferred ==
          uploadTask.snapshot.totalBytes) {
        msg = await storageReference.getDownloadURL();
        oncloud = true;
        debugPrint("Upload Complete at : $msg");
        state = ChatStatus.sent;
      } else {
        debugPrint("Upload Failed");
        state = ChatStatus.error;
      }
    });
    return true;
  }

  Future<ChatModel?> send(Function(ChatStatus) callback,
      {Function(double)? task}) async {
    callback.call(state = ChatStatus.sending);

    ChatroomModel.allChats[id] = this;

    if (isImage && !oncloud) {
      callback.call(state = ChatStatus.uploading);
      await sendImage(task: task);
    }
    bool ret = false;
    try {
      Map<String, dynamic> data = {
        "to": his.uid,
        "from": Global.profile.uid,
        "date": date,
        "status": (state = ChatStatus.sent)._value
      };
      if (isImage) {
        data["img"] = msg;
      } else {
        data["msg"] = msg;
      }
      (await chat.collection("messages").doc(id).set(data));
      ret = true;
    } catch (e) {
      state = ChatStatus.error;
      ret = false;
    }
    callback.call(state);
    return (ret) ? this : null;
  }

  Future<bool> delete(Function(ChatStatus) callback) async {
    ChatStatus lastState = state;
    bool value = false;
    try {
      callback.call(state = ChatStatus.deleting);
    } catch (_) {}
    try {
      if (isImage && oncloud) {
        await FirebaseStorage.instance.refFromURL(msg).delete();
      }
      await chat.collection("messages").doc(id).delete();
      ChatroomModel.allChats.remove(id);
      callback.call(state);
      value = true;
    } catch (_) {
      try {
        callback.call(state = lastState);
      } catch (_) {}
      value = false;
    }

    return value;
  }

  static Future<ChatModel?> fromDoc(
      DocumentSnapshot<Map<String, dynamic>> doc) async {
    final data = doc.data()!;
    final id = doc.id;
    final bool fromhim = data["to"] as String == Global.profile.uid;
    var model = ChatModel(
        (await AdminModel.getUsers())[
            (fromhim ? data["from"] as String : data["to"] as String)]!,
        (data["msg"] ?? data["img"]) as String,
        (data["date"] as Timestamp).toDate(),
        isImage: data["img"] != null,
        id: id,
        fromhim: fromhim,
        state: ChatStatus.parse(data["status"] as int));
    return model;
  }

  Widget card(BuildContext context, Function callback) {
    seen();
    List<Widget> status = [
      Text(clockFormat(date), style: Theme.of(context).textTheme.caption),
      const SizedBox(
        width: 5,
      ),
      Visibility(
          visible: !fromhim,
          child: Text(state.toString(),
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(fontWeight: FontWeight.bold))),
    ];
    if (!fromhim) status = status.reversed.toList();
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
            crossAxisAlignment:
                fromhim ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              Padding(
                  padding: EdgeInsets.only(
                      left: fromhim ? 15 : 75,
                      right: fromhim ? 75 : 15,
                      top: 5,
                      bottom: 5),
                  child: ElevatedButton(
                      onLongPress: state == ChatStatus.sending ||
                              state == ChatStatus.deleting ||
                              fromhim ||
                              state == ChatStatus.uploading
                          ? null
                          : () => delete((p0) => callback.call()).then((value) {
                                if (!value) {
                                  Global.showBar(
                                      context, Global.str.cannotDeleteObject);
                                }
                              }),
                      onPressed: state == ChatStatus.uploading
                          ? () {
                              state = ChatStatus.error;
                              callback.call();
                            }
                          : (state == ChatStatus.error
                              ? () => send((p0) => callback.call())
                              : ((isImage)
                                  ? () => Navigator.of(context)
                                      .push(MaterialPageRoute(
                                          builder: (_) => UploadScreen(
                                                title: "",
                                                urlToImage: msg,
                                                callback: (_) => callback,
                                              )))
                                  : null)),
                      style: ButtonStyle(
                          backgroundColor: state == ChatStatus.error
                              ? null
                              : MaterialStateProperty.all(
                                  Global.colorDim(context)),
                          shape: MaterialStateProperty.all(
                            const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                          )),
                      child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: fromhim
                                  ? CrossAxisAlignment.start
                                  : CrossAxisAlignment.end,
                              children: [
                                Visibility(
                                    child: const SizedBox(
                                      height: 15,
                                    ),
                                    visible: isImage),
                                isImage
                                    ? Container(
                                        width: (!isImage)
                                            ? null
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                        height: (!isImage)
                                            ? null
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width /
                                                2,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(10))),
                                        child: (!isImage)
                                            ? null
                                            : (oncloud
                                                ? Stack(
                                                    alignment: Alignment.center,
                                                    fit: StackFit.passthrough,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    children: [
                                                        Padding(
                                                          padding: EdgeInsets.all(
                                                              (MediaQuery.of(context)
                                                                          .size
                                                                          .width /
                                                                      4) -
                                                                  20),
                                                          child:
                                                              const CircularProgressIndicator(),
                                                        ),
                                                        Image.network(msg,
                                                            fit: BoxFit.cover),
                                                      ])
                                                : Stack(
                                                    alignment: Alignment.center,
                                                    fit: StackFit.passthrough,
                                                    clipBehavior:
                                                        Clip.antiAlias,
                                                    children: [
                                                        Image.file(
                                                          File(msg),
                                                          fit: BoxFit.cover,
                                                        ),
                                                        Container(
                                                          padding: EdgeInsets.all(
                                                              (MediaQuery.of(context)
                                                                          .size
                                                                          .width /
                                                                      4) -
                                                                  20),
                                                          color: Colors.black
                                                              .withOpacity(0.5),
                                                          child:
                                                              const CircularProgressIndicator(),
                                                        )
                                                      ])),
                                      )
                                    : Text(
                                        msg,
                                        style: Theme.of(context)
                                            .textTheme
                                            .subtitle1,
                                      ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: status)
                              ]))))
            ]));
  }

  Future<void> delivered() async {
    if (fromhim && state == ChatStatus.sent) {
      state = ChatStatus.deliver;
      await chat
          .collection("messages")
          .doc(id)
          .update({"status": ChatStatus.deliver._value});
    }
  }

  Future<void> seen() async {
    if (fromhim && state == ChatStatus.deliver) {
      await chat
          .collection("messages")
          .doc(id)
          .update({"status": ChatStatus.seen._value});
      state = ChatStatus.seen;
    }
  }
}

class ChatroomModel {
  static Map<String, ChatModel> allChats = {};
  static Future<bool> sync() async {
    FirebaseFirestore.instance.collection('chats');
    return true;
  }

  static Future<void> seen(Profile his) async {
    allChats.values
        .where((element) => element.state != ChatStatus.seen && element.fromhim)
        .forEach((element) => element.seen());
  }

  static Future<bool> delete(Profile his, Function(ChatStatus) callback) async {
    try {
      for (final element in allChats.values
          .where((element) => element.his.uid == his.uid)
          .toList()) {
        await element.delete(callback);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<Profile?> getOnlineDoctor() async {
    try {
      var value = (await AdminModel.getUsers(force: true))
          .values
          .where((element) => element.role == 2)
          .toList();
      value.sort((b, a) => a.lastUpdate.compareTo(b.lastUpdate));
      String id = ChatModel.chatId(value.first);
      await FirebaseFirestore.instance.collection("chats").doc(id).set({
        "users": [
          id.substring(0, (id.length / 2).ceil()),
          id.substring((id.length / 2).ceil())
        ],
      });
      listen();
      return value.first;
    } catch (_) {
      return null;
    }
  }

  static Future<List<Cards>> getCards({bool force = false}) async {
    Map<String, ChatModel> room = {};
    if (force) {
      allChats.clear();
      for (final element in (await FirebaseFirestore.instance
              .collection("chats")
              .where("users", arrayContains: Global.profile.uid)
              .get())
          .docs
          .map((e) => e.id)
          .toList()) {
        for (final e in (await FirebaseFirestore.instance
                .collection("chats")
                .doc(element)
                .collection("messages")
                .get())
            .docs) {
          final data = await ChatModel.fromDoc(e);
          if (data != null) {
            allChats[e.id] = (data);
          }
        }
      }
    }

    for (var element in allChats.values) {
      if (room.containsKey(element.his) &&
          element.date.compareTo(room[element.his]!.date) < 0) continue;
      room[element.his.uid] = element;
    }
    return (await AdminModel.getUsers(force: force))
        .values
        .where((element) => room.containsKey(element.uid))
        .map((e) => Cards(e.firstname + " " + e.lastname, room[e.uid]!.date,
            room[e.uid]!.isImage ? Global.str.photo : room[e.uid]!.msg, e,
            image: (e.urlPhoto.isNotEmpty && e.urlPhoto.length >= 10)
                ? e.urlPhoto
                : ""))
        .toList();
  }

  static Map<String, StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
      streams = {};
  static void dispose() {
    for (var element in streams.values) {
      element.cancel();
    }
  }

  static void listen() => FirebaseFirestore.instance
          .collection("chats")
          .where("users", arrayContains: Global.profile.uid)
          .get()
          .then((value) {
        for (final element in value.docs) {
          if (!streams.containsKey(element.id)) {
            streams[element.id] = (FirebaseFirestore.instance
                .collection("chats")
                .doc(element.id)
                .collection("messages")
                .orderBy("date")
                .limit(25)
                .snapshots()
                .listen((event) async {
              List<ChatModel> notifier = [];
              for (final element in event.docChanges) {
                final value = await ChatModel.fromDoc(element.doc);
                List<ChatModel> models = ChatroomModel.allChats.values
                    .where((model) => model.id == element.doc.id)
                    .toList();

                if (models.isEmpty && value != null) {
                  print("Add");
                  ChatroomModel.allChats[value.id] = (value);
                  Global.updater = true;
                } else if (models.isNotEmpty &&
                    value != null &&
                    element.type == DocumentChangeType.modified) {
                  print("Update");
                  models.single.state = value.state;
                  Global.updater = true;
                } else if (models.isNotEmpty &&
                    element.type == DocumentChangeType.removed) {
                  print("Remove");
                  ChatroomModel.allChats.remove(models.single.id);
                  Global.updater = true;
                }
                if (value != null &&
                    value.fromhim &&
                    value.state == ChatStatus.sent) {
                  await value.delivered();
                  print("Update Delivered");
                  if (Global.onRoom != value.his.uid) {
                    notifier.add(value);
                  }
                }
              }
              if (notifier.isNotEmpty) {
                Notify(
                        key: (notifier.length == 1)
                            ? notifier.single.id
                            : element.id,
                        channel: "New Messages")
                    .push(
                        importance: Importance.max,
                        priority: Priority.max,
                        sound: true,
                        vibrate: true,
                        callback: () {
                          if (Global.onRoom != null) {
                            Global.navigator.currentState!.pop();
                          }
                          Global.navigator.currentState!
                              .push(MaterialPageRoute(builder: (context) {
                            return Chatroom(
                                hisProfile: notifier.first.his,
                                callback: () {});
                          }));
                        },
                        onlyAlertOnce: false,
                        title: notifier.first.his.firstname +
                            " " +
                            notifier.first.his.lastname,
                        body: (notifier.length > 1)
                            ? (notifier.length.toString() +
                                " " +
                                Global.str.newMessages)
                            : ((notifier.first.isImage)
                                ? Global.str.photo
                                : notifier.first.msg));
              }
            }));
          }
        }
      });

  static List<ChatModel> get chatSorted {
    final chats = allChats.values.toList();
    chats.sort((a, b) => a.date.compareTo(b.date));
    return chats;
  }
}
