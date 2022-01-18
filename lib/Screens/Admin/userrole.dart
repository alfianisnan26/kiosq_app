import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Models/theme_model.dart';
import 'package:kiosq_app/Screens/Admin/viewer.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:provider/provider.dart';

class UserRole extends StatefulWidget {
  final Function() callback;
  final Profile profile;
  const UserRole({Key? key, required this.callback, required this.profile})
      : super(key: key);

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<UserRole> {
  late Profile profile = widget.profile;
  final ScrollController _controller = ScrollController();
  late bool _appBarState;
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
    super.dispose();
  }

  void callback() {
    setState(() {});
  }

  Widget uploadTile(String title, String url) {
    return SimpleSettingsTile(
        subtitle: "",
        leading: Icon((url.length < 10) ? Icons.close : Icons.check),
        title: title,
        child: UploadScreen(
          callback: callback,
          urlToImage: url,
          title: title,
          profile: profile,
        ));
  }

  String countAttachment() {
    int a = 0;
    return "$a ${Global.str.of} 4";
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
          appBar: AppBar(
              actions: (profile.role < 3 || profile.uid == profile.uid)
                  ? null
                  : [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          profile.delete().then((value) {
                            widget.callback.call();
                            if (value) {
                              Navigator.of(context).pop();
                            }
                          });
                        },
                      )
                    ],
              elevation: (!_appBarState) ? null : 0,
              shadowColor: (_appBarState) ? Colors.transparent : null,
              backgroundColor: (_appBarState) ? Colors.transparent : null,
              foregroundColor: (_appBarState)
                  ? Theme.of(context).colorScheme.secondary
                  : null,
              title: Text(profile.firstname + " " + profile.lastname)),
          body: SingleChildScrollView(
              controller: _controller,
              child: Column(
                children: [
                  SettingsGroup(title: Global.str.profile, children: <Widget>[
                    SimpleSettingsTile(
                      title: Global.str.firstname,
                      subtitle: profile.firstname,
                    ),
                    SimpleSettingsTile(
                      title: Global.str.lastname,
                      subtitle: profile.lastname,
                    ),
                    SimpleSettingsTile(
                      title: Global.str.address,
                      subtitle: profile.address,
                    ),
                  ]),
                  SettingsGroup(
                      title: Global.str.professional,
                      children: <Widget>[
                        DropDownSettingsTile<int>(
                          enabled: profile.uid != profile.uid,
                          title: Global.str.changeRole,
                          settingKey: profile.uid + "-role",
                          values: {
                            1: Global.str.user,
                            2: Global.str.dentist,
                            3: Global.str.superuser,
                            4: Global.str.admin,
                          },
                          selected: profile.role,
                          onChange: (valueInt) {
                            setState(() {
                              profile.role = valueInt;
                            });
                            profile.updateOn({"role": valueInt});
                          },
                        ),
                        ExpandableSettingsTile(
                            title: Global.str.about + " " + profile.firstname,
                            children: [
                              SimpleSettingsTile(
                                  title: Global.str.porto,
                                  subtitle: profile.portofolio),
                              SimpleSettingsTile(
                                  title: Global.str.profile,
                                  subtitle: profile.profile),
                            ]),
                      ]),
                ],
              )));
    });
  }
}
