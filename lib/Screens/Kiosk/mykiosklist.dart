import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Models/kiosk_model.dart';
import 'package:kiosq_app/Screens/Kiosk/CreateKiosk.dart';
import 'package:kiosq_app/Screens/Kiosk/Kiosk.dart';
import 'package:kiosq_app/Screens/Maps/maps.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'dart:math' as math;
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MyKioskList extends StatefulWidget {
  const MyKioskList({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<MyKioskList> {
  final ScrollController _controller = ScrollController();
  late bool _appBarState;
  @override
  void initState() {
    _loadingState = true;
    _appBarState = true;
    onRefresh().then((value) {
      setState(() {
        _loadingState = false;
      });
    });
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
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Cards> data = [];

  bool _loadingState = false;

  Future<void> onRefresh({bool force = false}) async {
    if (_searchController.text.isNotEmpty) {
      data = (await KioskModel.getCards(force: force))
          .where((element) =>
              element.title.contains(_searchController.text) ||
              element.subtitle.contains(_searchController.text))
          .toList();
    } else {
      data = await KioskModel.getCards(mine: true, force: force);
    }
    if (sortBy == 1) {
      data.sort((a, b) =>
          (!sort) ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    } else if (sortBy == 0) {
      data.sort((a, b) =>
          (!sort) ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    } else {
      data.sort((a, b) => (!sort)
          ? (a.object as KioskModel)
              .distance
              .compareTo((b.object as KioskModel).distance)
          : (b.object as KioskModel)
              .distance
              .compareTo((a.object as KioskModel).distance));
    }
  }

  bool sort = false;
  int sortBy = 0;

  final TextEditingController _searchController = TextEditingController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: (Global.profile.role < 1)
            ? null
            : FloatingActionButton(
                onPressed: () {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (_) => const CreateKiosk()))
                      .then((value) => setState(() {}));
                },
                child: const Icon(Icons.add)),
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
                              sortBy = 2;
                              onRefresh().then((value) => setState(() {}));
                              Navigator.of(context).pop();
                            },
                            child: Text(Global.str.distance),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              sortBy = 0;
                              onRefresh().then((value) => setState(() {}));
                              Navigator.of(context).pop();
                            },
                            child: Text(Global.str.alphabet),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              sortBy = 1;
                              onRefresh().then((value) => setState(() {}));
                              Navigator.of(context).pop();
                            },
                            child: Text(Global.str.date),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.filter_alt)),
              IconButton(
                  onPressed: () {
                    sort = !sort;
                    onRefresh().then((value) => setState(() {}));
                  },
                  icon: (!sort)
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationX(math.pi),
                          child: const Icon(
                            Icons.sort,
                          ))
                      : const Icon(Icons.sort)),
              IconButton(
                  icon: const Icon(Icons.map),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Maps(
                            models: KioskModel.allMine,
                          )))),
            ],
            elevation: (!_appBarState) ? null : 0,
            shadowColor: (_appBarState) ? Colors.transparent : null,
            backgroundColor: (_appBarState) ? Colors.transparent : null,
            foregroundColor:
                (_appBarState) ? Theme.of(context).colorScheme.secondary : null,
            title: TextField(
                onChanged: (value) {
                  onRefresh().then((value) => setState(() {}));
                },
                controller: _searchController,
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    hintText: Global.str.search +
                        " " +
                        Global.str.myKiosks.toLowerCase(), //+
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
            onRefresh: () async {
              setState(() {
                _loadingState = true;
              });
              data = await KioskModel.getCards(mine: true, force: true);
              _refreshController.refreshCompleted();
              setState(() {
                _loadingState = false;
              });
            },
            child: SingleChildScrollView(
              child: Cards.getWidgets(context, loadingState: _loadingState,
                  onPressed: (e) {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => Kiosk(e)));
              }, items: data),
            )));
  }
}
