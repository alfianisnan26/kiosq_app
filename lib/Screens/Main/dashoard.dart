import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/articlepages_model.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Models/kiosk_model.dart';
import 'package:kiosq_app/Screens/Features/search.dart';
import 'package:kiosq_app/Screens/Kiosk/kiosk.dart';
import 'package:kiosq_app/Screens/Maps/maps.dart';
import 'package:kiosq_app/Screens/Kiosk/kioskList.dart';
import 'package:kiosq_app/Screens/Main/sidemenu.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:kiosq_app/Variables/var_strings.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _Dashboard();
  }
}

class _Dashboard extends State<Dashboard> {
  final ScrollController _controller = ScrollController();
  late bool _appBarState;

  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

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

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, Strings strings, child) {
      Global.str = strings;
      return Scaffold(
          appBar: AppBar(
              title: Text(Global.str.dashboard),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const SearchPage(
                            mostSold: false,
                          ))),
                )
              ],
              elevation: (!_appBarState) ? null : 0,
              backgroundColor: (!_appBarState) ? null : Colors.transparent,
              shadowColor: (!_appBarState) ? null : Colors.transparent,
              foregroundColor: (!_appBarState)
                  ? null
                  : Theme.of(context).colorScheme.secondary),
          drawer: NavDrawer(
            callback: () {
              setState(() {});
            },
          ),
          body: SmartRefresher(
              enablePullDown: true,
              header: const WaterDropHeader(),
              controller: _refreshController,
              scrollController: _controller,
              onRefresh: () async {
                await KioskModel.getAllKiosk();
                setState(() {});
                _refreshController.refreshCompleted();
              },
              child: SingleChildScrollView(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Global.defaultPadding(
                      child: Text(
                    ((Global.profile.isLogin)
                            ? Global.str.hello
                            : Global.str.welcome) +
                        ((Global.profile.isLogin)
                            ? ", " + Global.profile.firstname
                            : ""),
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(fontWeight: FontWeight.bold),
                  )),
                  Global.defaultPadding(
                    bottom: 10,
                    child: Text(
                        (Global.profile.isLogin)
                            ? Global.str.healthwishes
                            : Global.str.signnow,
                        style: Theme.of(context).textTheme.subtitle1),
                  ),
                  Visibility(
                      visible: !Global.profile.isLogin,
                      child: Global.defaultPadding(
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.secondary),
                                  shape: MaterialStateProperty.all(
                                      const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50))))),
                              clipBehavior: Clip.antiAlias,
                              onPressed: (Global.profile.loading)
                                  ? null
                                  : () {
                                      setState(() {
                                        Global.profile.login().then((value) {
                                          Global.showBar(
                                              context,
                                              (value)
                                                  ? Global.str.successLogin
                                                  : Global.str.failedLogin);
                                        });
                                      });
                                    },
                              child: Center(
                                  child: (Global.profile.loading)
                                      ? Container(
                                          height: 30,
                                          width: 30,
                                          padding: const EdgeInsets.all(5),
                                          child:
                                              const CircularProgressIndicator(
                                            color: Colors.white,
                                          ))
                                      : Text(Global.str.signinwithgoogle))))),
                  Visibility(
                      visible: Global.profile.isLogin,
                      child: Global.defaultPadding(
                          child: ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Theme.of(context).colorScheme.secondary),
                                  shape: MaterialStateProperty.all(
                                      const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50))))),
                              clipBehavior: Clip.antiAlias,
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Maps()));
                              },
                              child: Center(
                                  child: Text(
                                Global.str.findNearbyKiosk,
                                style: const TextStyle(color: Colors.white),
                              ))))),
                  FutureBuilder(
                    future: KioskModel.getCards(),
                    builder: (context, AsyncSnapshot<List<Cards>> ss) {
                      return Cards.getWidgets(context,
                          loadingState: !ss.hasData,
                          errorState: ss.hasError,
                          str: Global.str.nearbyKiosks, more: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const NearbyKioskList()));
                      }, onPressed: (e) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => Kiosk(e)));
                      }, items: ss.data);
                    },
                  ),
                  FutureBuilder(
                    future: KioskModel.getCards(movingOnly: true),
                    builder: (context, AsyncSnapshot<List<Cards>> ss) {
                      return Cards.getWidgets(context,
                          loadingState: !ss.hasData,
                          errorState: ss.hasError,
                          str: Global.str.movingKiosks, more: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const NearbyKioskList()));
                      }, onPressed: (e) {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => Kiosk(e)));
                      }, items: ss.data);
                    },
                  ),
                ],
              ))));
    });
  }
}
