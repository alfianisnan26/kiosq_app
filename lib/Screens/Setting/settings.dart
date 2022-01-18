import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiosq_app/Models/theme_model.dart';
import 'package:kiosq_app/Utils/filechoseviewer.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:kiosq_app/Variables/var_strings.dart';
import 'package:provider/provider.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  _AppSettingsState createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {
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

  void callback(String? file) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeModel themeNotifier, child) {
      return Scaffold(
          appBar: AppBar(
              elevation: (!_appBarState) ? null : 0,
              shadowColor: (_appBarState) ? Colors.transparent : null,
              backgroundColor: (_appBarState) ? Colors.transparent : null,
              foregroundColor: (_appBarState)
                  ? Theme.of(context).colorScheme.secondary
                  : null,
              title: Text(
                Global.str.settings,
              )),
          body: SingleChildScrollView(
              controller: _controller,
              child: Column(
                children: [
                  SettingsGroup(title: Global.str.basics, children: <Widget>[
                    DropDownSettingsTile<int>(
                      title: Global.str.theme,
                      settingKey: 'theme-mode',
                      values: {
                        0: Global.str.system,
                        1: Global.str.light,
                        2: Global.str.dark
                      },
                      selected: themeNotifier.modeInt,
                      onChange: (value) {
                        Global.profile.updateOn({"mode": value});
                        themeNotifier.modeInt = value;
                      },
                    ),
                    DropDownSettingsTile<String>(
                      title: Global.str.languages,
                      settingKey: 'key-languages',
                      values: Strings.lang,
                      selected: Global.str.id,
                      onChange: (value) {
                        setState(() {
                          Global.str.id = value;
                        });
                      },
                    ),
                  ]),
                  Visibility(
                      visible: (Global.profile.isLogin),
                      child: SettingsGroup(
                          title: Global.str.profile,
                          children: <Widget>[
                            TextInputSettingsTile(
                              title: Global.str.firstname,
                              settingKey: 'key-firstname',
                              initialValue: Global.profile.firstname,
                              onChange: (value) {
                                Global.profile.updateOn({"firstname": value});
                                Global.profile.firstname = value;
                              },
                            ),
                            TextInputSettingsTile(
                              title: Global.str.lastname,
                              settingKey: 'key-lastname',
                              initialValue: Global.profile.lastname,
                              onChange: (value) {
                                Global.profile.updateOn({"lastname": value});
                                Global.profile.lastname = value;
                              },
                            ),
                            TextInputSettingsTile(
                              title: Global.str.address,
                              settingKey: 'key-address',
                              initialValue: Global.profile.address,
                              onChange: (value) {
                                Global.profile.updateOn({"address": value});
                                Global.profile.address = value;
                              },
                            ),
                          ])),
                ],
              )));
    });
  }
}
