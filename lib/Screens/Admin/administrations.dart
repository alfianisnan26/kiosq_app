import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/admin_model.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Screens/Admin/userrole.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:math' as math; // import this

class Administrator extends StatefulWidget {
  const Administrator({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Administrator();
  }
}

class _Administrator extends State<Administrator> {
  final ScrollController _controller = ScrollController();
  late bool _appBarState;

  late bool _loadingState;
  List<Cards>? _data;

  @override
  void initState() {
    _loadingState = true;
    _appBarState = true;
    _onRefresh(withBanner: false).then((value) => _loadingState = false);
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
    _controller.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future _onRefresh({bool force = false, withBanner = true}) async {
    if (_data == null || force) _data = await AdminModel.getCards(force: force);
    if (_sortBy == 1) {
      _data!.sort((a, b) =>
          (_sort) ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    } else {
      _data!.sort((a, b) =>
          (!_sort) ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    }
    setState(() {});
    if (withBanner) _refreshController.refreshCompleted();
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
                              setState(() {
                                _data!.sort((a, b) => (!_sort)
                                    ? a.title.compareTo(b.title)
                                    : b.title.compareTo(a.title));
                                _sortBy = 0;
                              });

                              Navigator.of(context).pop();
                            },
                            child: Text(Global.str.alphabet),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              setState(() {
                                _data!.sort((a, b) => (_sort)
                                    ? a.date.compareTo(b.date)
                                    : b.date.compareTo(a.date));

                                _sortBy = 1;
                              });
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
                    setState(() {
                      if (_sortBy == 1) {
                        _data!.sort((a, b) => (!_sort)
                            ? a.date.compareTo(b.date)
                            : b.date.compareTo(a.date));
                      } else {
                        _data!.sort((a, b) => (_sort)
                            ? a.title.compareTo(b.title)
                            : b.title.compareTo(a.title));
                      }
                      _sort = !_sort;
                    });
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
                onChanged: (value) async {
                  _data = (await AdminModel.getCards())
                      .where((element) => element.title
                          .toLowerCase()
                          .contains(value.toLowerCase()))
                      .toList();
                  setState(() {});
                },
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
            onRefresh: () => _onRefresh(force: true),
            child: SingleChildScrollView(
              child: Column(children: [
                Cards.getWidgets(context,
                    loadingState: _loadingState, admin: true, onPressed: (e) {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => UserRole(
                            profile: e as Profile,
                            callback: () {
                              _onRefresh(withBanner: false);
                            },
                          )));
                }, items: _data),
                const SizedBox(
                  height: 15,
                )
              ]),
            )));
  }
}
