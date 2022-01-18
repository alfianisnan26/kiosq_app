import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/admin_model.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Models/chat_model.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Screens/Admin/userrole.dart';
import 'package:kiosq_app/Screens/Chat/chatroom.dart';
import 'package:kiosq_app/Utils/notification.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:math' as math; // import this

class Chats extends StatefulWidget {
  const Chats({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChatsState();
  }
}

class ChatsState extends State<Chats> {
  final ScrollController _controller = ScrollController();
  late bool _appBarState;
  late bool _loadingState;
  late List<Cards>? _data;
  late Timer listener;

  bool _findLoading = false;
  @override
  void initState() {
    listener = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      if (Global.updater && Global.onRoom == null) {
        print("Update on chats");
        _onRefresh();
        Global.updater = false;
      }
    });
    _data = null;
    _loadingState = true;
    _appBarState = true;
    _onRefresh(force: ChatroomModel.allChats.isEmpty).then((value) async {
      _loadingState = false;
    });
    _controller.addListener(() {
      if (_appBarState && _controller.offset > 0) {
        setState(() {
          _appBarState = false;
        });
      } else if (!_appBarState && _controller.offset <= 0) {
        setState(() {
          _appBarState = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    listener.cancel();
    _textController.dispose();
    _controller.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  final TextEditingController _textController = TextEditingController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future _onRefresh({force = false}) async {
    _data = (await ChatroomModel.getCards(force: force))
        .where((element) => element.title.contains(_textController.text))
        .toList();

    if (_sortBy == 1) {
      _data!.sort((a, b) =>
          (_sort) ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    } else {
      _data!.sort((a, b) =>
          (!_sort) ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    }
    Global.onRoom = null;
    setState(() {});
  }

  bool _sort = false;
  int _sortBy = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            actions: [
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: Text(Global.str.sort),
                        children: <Widget>[
                          SimpleDialogOption(
                            onPressed: () {
                              _sortBy = 0;
                              _onRefresh();
                              Navigator.of(context).pop();
                            },
                            child: Text(Global.str.alphabet),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              _sortBy = 1;
                              _onRefresh();
                              Navigator.of(context).pop();
                            },
                            child: Text(Global.str.lastSeen),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.filter_alt)),
              IconButton(
                  onPressed: () {
                    _sort = !_sort;
                    _onRefresh();
                  },
                  icon: (!_sort)
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationX(math.pi),
                          child: const Icon(
                            Icons.sort,
                          ))
                      : const Icon(Icons.sort))
            ],
            elevation: (!_appBarState) ? null : 0,
            shadowColor: (_appBarState) ? Colors.transparent : null,
            backgroundColor: (_appBarState) ? Colors.transparent : null,
            foregroundColor:
                (_appBarState) ? Theme.of(context).colorScheme.secondary : null,
            title: TextField(
                controller: _textController,
                onChanged: (value) => _onRefresh(),
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    hintText: Global.str.search +
                        " " +
                        Global.str.user.toLowerCase(), //+
                    //_controller.offset.toString(),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary),
                    )))),
        body: SmartRefresher(
            enablePullDown: true,
            header: const WaterDropHeader(),
            controller: _refreshController,
            scrollController: _controller,
            onRefresh: () => _onRefresh(force: true)
                .then((value) => _refreshController.refreshCompleted()),
            child: SingleChildScrollView(
              child: Column(children: [
                Cards.getWidgets(context,
                    loadingState: _loadingState, chats: true, onPressed: (e) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => Chatroom(
                              hisProfile: e, callback: () => setState(() {}))))
                      .then((value) => _onRefresh());
                }, items: _data),
                const SizedBox(
                  height: 15,
                )
              ]),
            )));
  }
}
