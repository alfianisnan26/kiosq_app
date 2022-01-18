import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/chat_model.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Utils/duration_format.dart';
import 'package:kiosq_app/Utils/filechoseviewer.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Chatroom extends StatefulWidget {
  final Profile hisProfile;
  final Function callback;
  const Chatroom({
    Key? key,
    required this.hisProfile,
    required this.callback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Chatroom();
  }
}

class _Chatroom extends State<Chatroom> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _controller = ScrollController();
  late bool _appBarState;
  late Timer listener;
  bool _readyToSend = false;
  @override
  void initState() {
    Global.onRoom = widget.hisProfile.uid;
    listener = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (Global.updater) {
        print("Update on chatroom at : " +
            widget.hisProfile.firstname +
            " " +
            widget.hisProfile.lastname);
        setState(() {});
        Global.updater = false;
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });

    _appBarState = true;
    _controller.addListener(() {
      if (_appBarState && _controller.offset != 0) {
        setState(() {
          _appBarState = false;
        });
      } else if (!_appBarState && _controller.offset == 0) {
        setState(() {
          _appBarState = true;
        });
      }
    });
    Timer(const Duration(milliseconds: 1), () {
      // ignore: invalid_use_of_protected_member
      if (_controller.positions.isNotEmpty) {
        _controller.jumpTo(_controller.position.maxScrollExtent);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  bool _deleting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: _deleting
                      ? null
                      : () => Global.showBar(context, Global.str.areYouSure,
                          action: SnackBarAction(
                              label: Global.str.ok,
                              onPressed: () async {
                                setState(() => _deleting = true);
                                await ChatroomModel.delete(widget.hisProfile,
                                    (state) => setState(() {}));
                                setState(() => _deleting = false);
                                widget.callback.call();
                                Navigator.pop(context);
                              })),
                  icon: _deleting
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child: CircularProgressIndicator())
                      : const Icon(Icons.delete))
            ],
            elevation: (!_appBarState) ? null : 0,
            shadowColor: (_appBarState) ? Colors.transparent : null,
            backgroundColor: (_appBarState) ? Colors.transparent : null,
            foregroundColor:
                (_appBarState) ? Theme.of(context).colorScheme.secondary : null,
            title: Row(children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: NetworkImage(widget.hisProfile.urlPhoto))),
              ),
              const SizedBox(
                width: 25,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  widget.hisProfile.firstname +
                      " " +
                      widget.hisProfile.lastname,
                  overflow: TextOverflow.fade,
                  maxLines: 1,
                  softWrap: false,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                        height: 5,
                        width: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: (const Duration(minutes: 2).compareTo(
                                      DateTime.now().difference(
                                          widget.hisProfile.lastUpdate)) >=
                                  0)
                              ? Colors.green
                              : Colors.red,
                        )),
                    const SizedBox(
                      width: 5,
                    ),
                    Text(lastSeen(widget.hisProfile.lastUpdate),
                        style: Theme.of(context)
                            .textTheme
                            .subtitle2!
                            .copyWith(fontStyle: FontStyle.italic)),
                  ],
                )
              ])
            ])),
        body: GestureDetector(
            onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: (ChatroomModel.allChats.isEmpty)
                      ? Center(
                          child: Text(Global.str.letsStartTheConversation),
                        )
                      : SingleChildScrollView(
                          controller: _controller,
                          child: Column(children: [
                            const SizedBox(
                              height: 15,
                            ),
                            Column(
                              children: ChatroomModel.chatSorted
                                  .where((element) =>
                                      element.his.uid == widget.hisProfile.uid)
                                  .map((e) {
                                return e.card(context, () {
                                  setState(() {});
                                });
                              }).toList(),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                          ])),
                ),
                Material(
                    elevation: 20,
                    child: Container(
                        color: Global.colorDim(context),
                        child: Row(
                          children: [
                            IconButton(
                                onPressed: (kIsWeb)
                                    ? () => Global.alertOnlyOnApp(context)
                                    : () {
                                        Navigator.of(context)
                                            .push(MaterialPageRoute(
                                                builder: (_) => UploadScreen(
                                                      title:
                                                          Global.str.sendImage,
                                                      urlToImage: "N/A",
                                                      callback: (file) {
                                                        if (file != null) {
                                                          ChatModel(
                                                            widget.hisProfile,
                                                            file,
                                                            DateTime.now(),
                                                            isImage: true,
                                                            oncloud: false,
                                                          ).send((state) {
                                                            setState(() {});
                                                          });
                                                        }
                                                      },
                                                    )));
                                      },
                                icon: const Icon(Icons.photo)),
                            Expanded(
                                child: Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: TextField(
                                      autofocus: false,
                                      onChanged: (val) {
                                        if (_readyToSend && val.isEmpty) {
                                          setState(() {
                                            _readyToSend = true;
                                          });
                                        } else if (!_readyToSend &&
                                            val.isNotEmpty) {
                                          setState(() {
                                            _readyToSend = false;
                                          });
                                        }
                                      },
                                      controller: _textController,
                                      maxLines: null,
                                    ))),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: _textController.text.isEmpty
                                  ? null
                                  : () {
                                      ChatModel(
                                              widget.hisProfile,
                                              _textController.text,
                                              DateTime.now())
                                          .send((state) {
                                        setState(() {});
                                      });

                                      setState(() {
                                        _textController.text = "";
                                      });
                                      Timer(const Duration(milliseconds: 125),
                                          () {
                                        if (_controller.positions.isNotEmpty) {
                                          _controller.animateTo(
                                              _controller
                                                  .position.maxScrollExtent,
                                              curve: Curves.easeInOutSine,
                                              duration: const Duration(
                                                  milliseconds: 125));
                                        }
                                      });
                                    },
                            )
                          ],
                        )))
              ],
            )));
  }
}
