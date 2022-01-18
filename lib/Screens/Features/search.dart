import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Screens/Kiosk/kiosk.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:math' as math;

class SearchPage extends StatefulWidget {
  final bool mostSold;
  const SearchPage({Key? key, required this.mostSold}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<SearchPage> {
  List<Cards> data = [];
  final ScrollController _controller = ScrollController();
  late bool _appBarState;
  bool _loadingState = false;
  @override
  void initState() {
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

  Future<void> onRefresh() async {
    setState(() => _loadingState = true);
    if (sortBy == 1) {
      data.sort((a, b) =>
          (!sort) ? a.date.compareTo(b.date) : b.date.compareTo(a.date));
    } else if (sortBy == 0) {
      data.sort((a, b) =>
          (!sort) ? a.title.compareTo(b.title) : b.title.compareTo(a.title));
    }
    setState(() => _loadingState = false);
  }

  bool sort = false;
  int sortBy = 0;

  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final data = await FlutterBarcodeScanner.scanBarcode(
                "#ff6666", Global.str.cancel, false, ScanMode.DEFAULT);
            if (data != "-1") {
              _searchController.text = data;
              onRefresh().then((value) => setState(() {}));
            }
          },
          child: const Icon(Icons.qr_code),
        ),
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
            ],
            elevation: (!_appBarState) ? null : 0,
            shadowColor: (_appBarState) ? Colors.transparent : null,
            backgroundColor: (_appBarState) ? Colors.transparent : null,
            foregroundColor:
                (_appBarState) ? Theme.of(context).colorScheme.secondary : null,
            title: TextField(
                onChanged: (value) {
                  debugPrint("ON UPDATED");
                  onRefresh().then((value) => setState(() {}));
                },
                controller: _searchController,
                decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    hintText: Global.str.search,
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
              onRefresh().then((value) {
                _refreshController.refreshCompleted();
                setState(() => _loadingState = false);
              });
            },
            child: SingleChildScrollView(
              child: Column(children: [
                Cards.getWidgets(context, loadingState: _loadingState,
                    onPressed: (e) {
                  Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => Kiosk(e)));
                }, items: data),
                const SizedBox(
                  height: 15,
                )
              ]),
            )));
  }
}
