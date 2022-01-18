import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/admin_model.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Models/kiosk_model.dart';
import 'package:kiosq_app/Models/product_model.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Screens/Chat/chatroom.dart';
import 'package:kiosq_app/Screens/Chat/chats.dart';
import 'package:kiosq_app/Screens/Features/cashier.dart';
import 'package:kiosq_app/Screens/Kiosk/createkiosk.dart';
import 'package:kiosq_app/Screens/Maps/maps.dart';
import 'package:kiosq_app/Screens/Product/addproduct.dart';
import 'package:kiosq_app/Screens/Product/product.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:math' as math;

class Kiosk extends StatefulWidget {
  final KioskModel model;
  const Kiosk(this.model, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<Kiosk> {
  late KioskModel model = widget.model;
  List<Cards> data = [];
  final ScrollController _controller = ScrollController();
  late bool _appBarState;
  @override
  void initState() {
    if (data.isEmpty) {
      onRefresh(force: true).then((value) => _loadingState = false);
    }
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

  Future<void> onRefresh({bool force = false}) async {
    setState(() => _loadingState = true);
    if (_searchController.text.isNotEmpty) {
      data = (await model.getProductCards(force: force))
          .where((element) =>
              element.title
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()) ||
              element.subtitle
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    } else {
      data = await model.getProductCards(force: force);
    }
    if (sortBy == 1) {
      data.sort((a, b) =>
          (!sort) ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    } else if (sortBy == 0) {
      data.sort((a, b) =>
          (!sort) ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    } else if (sortBy == 2) {
      data.sort((a, b) => (!sort)
          ? (a.object as Product).price.compareTo((b.object as Product).price)
          : (b.object as Product).price.compareTo((a.object as Product).price));
    } else if (sortBy == 3) {
      data.sort((a, b) => (!sort)
          ? (a.object as Product).sold.compareTo((b.object as Product).sold)
          : (b.object as Product).sold.compareTo((a.object as Product).sold));
    }
    setState(() => _loadingState = false);
  }

  bool _loadingState = false;
  bool sort = false;
  int sortBy = 0;

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          Visibility(
              visible: (model.isMine),
              child: FloatingActionButton(
                heroTag: "faba",
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => AddProductPage(
                            kioskmodel: model,
                          )));
                },
                child: const Icon(Icons.add),
              )),
          const SizedBox(
            height: 10,
          ),
          (model.isMine)
              ? FloatingActionButton(
                  heroTag: "fabb",
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) => Cashier(kioskmodel: model)));
                  },
                  child: const Icon(Icons.calculate),
                )
              : FloatingActionButton(
                  heroTag: "fabc",
                  onPressed: () {
                    model.users
                        .sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));
                    Profile his = model.users.first;

                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (_) =>
                            Chatroom(hisProfile: his, callback: setState)));
                  },
                  child: const Icon(Icons.chat),
                ),
          Visibility(
              visible: (model.session && model.mobile) || !model.mobile,
              child: const SizedBox(
                height: 10,
              )),
          Visibility(
              visible: (model.session && model.mobile) || !model.mobile,
              child: FloatingActionButton(
                heroTag: "fabd",
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => Maps(
                            models: [widget.model],
                          )));
                },
                child: const Icon(Icons.map),
              )),
        ]),
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
                              sortBy = 3;
                              onRefresh();
                              Navigator.of(context).pop();
                            },
                            child: Text(Global.str.sold),
                          ),
                          SimpleDialogOption(
                            onPressed: () {
                              sortBy = 2;
                              onRefresh().then((value) => setState(() {}));
                              Navigator.of(context).pop();
                            },
                            child: Text(Global.str.price),
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
              Visibility(
                  visible: widget.model.isMine,
                  child: IconButton(
                      onPressed: () async {
                        await widget.model.delete();
                        KioskModel.all.remove(widget.model);
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.delete))),
              Visibility(
                visible: (widget.model.mobile && widget.model.isMine),
                child: Switch(
                  onChanged: (bool value) {
                    setState(() => widget.model.session = value);
                  },
                  value: widget.model.session,
                ),
              )
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
                    hintText: Global.str.searchProduct + " " + model.name, //+
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
            onRefresh: () {
              setState(() => _loadingState = true);
              onRefresh(force: true).then((value) {
                _refreshController.refreshCompleted();
                setState(() => _loadingState = false);
              });
            },
            child: SingleChildScrollView(
              child: Column(children: [
                Cards.getWidgets(context, loadingState: _loadingState,
                    onPressed: (e) async {
                  await Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (_) => ProductPage(model: e)))
                      .then((value) => setState(() {}));
                }, items: data),
                const SizedBox(
                  height: 15,
                )
              ]),
            )));
  }
}
