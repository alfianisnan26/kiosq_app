import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/kiosk_model.dart';
import 'package:kiosq_app/Screens/Chat/chats.dart';
import 'package:kiosq_app/Screens/Kiosk/kiosk.dart';
import 'package:kiosq_app/Screens/Kiosk/mykiosklist.dart';
import 'package:kiosq_app/Screens/Main/about.dart';
import 'package:kiosq_app/Screens/Main/help.dart';
import 'package:kiosq_app/Screens/Maps/maps.dart';
import 'package:kiosq_app/Screens/Setting/settings.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class NavDrawer extends StatefulWidget {
  final Function() callback;
  const NavDrawer({
    Key? key,
    required this.callback,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _NavDrawer();
  }
}

class _NavDrawer extends State<NavDrawer> {
  ImageProvider<Object> get dp {
    if (Global.profile.isLogin) {
      return NetworkImage(Global.profile.user!.photoURL!);
    } else {
      return const AssetImage("assets\\images\\icons\\2x\\Asset 1@2x.png");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Stack(alignment: Alignment.topRight, children: [
              Container(
                width: 85,
                height: 25,
                decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                    color: Theme.of(context).colorScheme.background),
                child: Center(
                    child: Text(Global.profile.roleStr(),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold))),
              ),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          image: DecorationImage(image: dp),
                          shape: BoxShape.circle,
                          color: Colors.transparent),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: 185,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                (Global.profile.isLogin)
                                    ? Global.profile.firstname +
                                        " " +
                                        Global.profile.lastname
                                    : "KiosQ",
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                (Global.profile.isLogin)
                                    ? Global.profile.email
                                    : Global.str.visitus,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ]))
                  ])
            ]),
            decoration: BoxDecoration(
                image: const DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(
                        'assets\\images\\bgrole\\2x\\Asset 0@2x.png')),
                color: Theme.of(context).colorScheme.secondary),
          ),
          Visibility(
            visible: kIsWeb,
            child: ListTile(
                leading: const Icon(Icons.download),
                title: Text(Global.str.downloadPascaForAndroid),
                onTap: () => FirebaseStorage.instance
                    .ref("app")
                    .child("app-release.apk")
                    .getDownloadURL()
                    .then((value) => launch(value))),
          ),
          Visibility(
              visible: !Global.profile.isLogin,
              child: ListTile(
                leading: const Icon(Icons.login),
                title: Text(Global.str.signinwithgoogle),
                onTap: (Global.profile.loading)
                    ? null
                    : () async {
                        Global.showBar(
                            context,
                            (await Global.profile.login())
                                ? Global.str.successLogin
                                : Global.str.failedLogin);
                        widget.callback.call();
                      },
              )),
          ListTile(
            leading: const Icon(Icons.map),
            title: Text(Global.str.nearbyKiosks),
            onTap: () => {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => Maps()))
            },
          ),
          Visibility(
              visible: Global.profile.isLogin,
              child: ListTile(
                leading: const Icon(Icons.add_business),
                title: Text(Global.str.myKiosks),
                onTap: () => {
                  Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (context) => const MyKioskList()))
                      .then((value) => setState(() {}))
                },
              )),
          Visibility(
              visible: KioskModel.allMine.isNotEmpty,
              child: Column(
                  children: KioskModel.allMine
                      .map((e) => ListTile(
                            leading: Icon((e.mobile)
                                ? Icons.car_repair
                                : Icons.business_center),
                            title: Text(e.name),
                            onTap: () => {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (context) => Kiosk(e)))
                                  .then((value) => setState(() {}))
                            },
                          ))
                      .toList())),
          Visibility(
              visible: Global.profile.isLogin,
              child: ListTile(
                leading: const Icon(Icons.question_answer),
                title: Text(Global.str.chats),
                onTap: () => {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Chats()))
                },
              )),
          ListTile(
            leading: const Icon(Icons.support),
            title: Text(Global.str.help),
            onTap: () => {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const Help()))
            },
          ),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(Global.str.about),
            onTap: () => {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (context) => const About()))
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(Global.str.settings),
            onTap: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AppSettings()));
            },
          ),
          Visibility(
              visible: Global.profile.role != 0,
              child: ListTile(
                leading: const Icon(Icons.logout),
                title: Text(Global.str.logout),
                onTap: () async {
                  Global.showBar(
                      context,
                      (await Global.profile.logout())
                          ? Global.str.successLogout
                          : Global.str.failedLogout);
                  widget.callback.call();
                  Navigator.of(context).pop();
                },
              )),
        ],
      ),
    );
  }
}
