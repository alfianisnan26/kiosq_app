import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Models/file_uploader_model.dart';
import 'package:kiosq_app/Models/kiosk_model.dart';
import 'package:kiosq_app/Screens/Maps/maps.dart';
import 'package:kiosq_app/Utils/filechoseviewer.dart';
import 'package:kiosq_app/Variables/global.dart';

class CreateKiosk extends StatefulWidget {
  const CreateKiosk({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<CreateKiosk> {
  final ScrollController _controller = ScrollController();
  KioskModel model = KioskModel(location: Locations.myPos);
  late bool _appBarState;
  bool _saving = false;
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

  Widget uploadTile(String title, String url) {
    return SimpleSettingsTile(
        subtitle: "",
        leading: Icon((url.length < 5) ? Icons.close : Icons.check),
        title: title,
        child: UploadScreen(
          callback: (url) {
            setState(() {
              model.imageUrl = url ?? "";
            });
          },
          urlToImage: url,
          title: title,
        ));
  }

  bool pinning = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Scaffold(
            appBar: AppBar(
                actions: [
                  IconButton(
                    icon: _saving
                        ? SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                                color: _appBarState
                                    ? null
                                    : Theme.of(context).colorScheme.background))
                        : const Icon(Icons.check),
                    onPressed: () async {
                      setState(() {
                        _saving = true;
                      });
                      if (model.name.length < 5) {
                        Global.showBar(context,
                            Global.str.error + "!, " + Global.str.addtitle);
                      } else if (model.description.length < 5) {
                        Global.showBar(
                            context,
                            Global.str.error +
                                "!, " +
                                Global.str.adddescription);
                      } else if (model.imageUrl.length < 5) {
                        Global.showBar(context,
                            Global.str.error + "!, " + Global.str.addcontent);
                      } else if (model.location == null &&
                          model.mobile == false) {
                        Global.showBar(context,
                            Global.str.error + "!, " + Global.str.pinLocation);
                      } else if (await model.post()) {
                        Navigator.of(context).pop();
                      } else {
                        Global.showBar(context, Global.str.cannotAddObject);
                      }
                      setState(() {
                        _saving = false;
                      });
                    },
                  )
                ],
                elevation: (_appBarState) ? 0 : null,
                shadowColor: (_appBarState) ? Colors.transparent : null,
                backgroundColor: (_appBarState) ? Colors.transparent : null,
                foregroundColor: (_appBarState)
                    ? Theme.of(context).colorScheme.secondary
                    : null,
                title: Text(Global.str.createANewKiosk)),
            body: SingleChildScrollView(
                controller: _controller,
                child: Column(
                  children: [
                    Container(
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 10),
                        height: MediaQuery.of(context).size.width * (9 / 16),
                        child: Cards.cardModel(context,
                            i: Cards(
                              (model.name.isEmpty)
                                  ? Global.str.addtitle
                                  : model.name,
                              model.lastUpdate,
                              (model.description.isEmpty)
                                  ? Global.str.adddescription
                                  : model.description,
                              model,
                              image: "",
                              forceImage: (model.imageUrl.length < 5)
                                  ? null
                                  : Image.file(
                                      File(model.imageUrl),
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(children: [
                          TextField(
                            maxLength: 40,
                            decoration: InputDecoration(
                              label: Text(Global.str.addtitle),
                            ),
                            onChanged: (value) {
                              setState(() {
                                model.name = value;
                              });
                            },
                            enabled: true,
                          ),
                          TextField(
                            maxLines: null,
                            maxLength: 500,
                            decoration: InputDecoration(
                              label: Text(Global.str.adddescription),
                            ),
                            onChanged: (value) {
                              setState(() {
                                model.description = value;
                              });
                            },
                            enabled: true,
                          ),
                        ])),
                    SwitchSettingsTile(
                        onChange: (v) {
                          setState(() {
                            model.mobile = v;
                          });
                        },
                        title: Global.str.movingKiosks,
                        settingKey: "moving_kiosk"),
                    uploadTile(Global.str.addthumbnail, model.imageUrl),
                    Visibility(
                        visible: !model.mobile,
                        child: SimpleSettingsTile(
                            subtitle: "",
                            leading:
                                Icon((pinning) ? Icons.check : Icons.close),
                            title: Global.str.pinLocation,
                            child: Maps(pinning: (loc) {
                              setState(() => pinning = true);
                              model.location = loc;
                            })))
                  ],
                ))),
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()));
  }
}
