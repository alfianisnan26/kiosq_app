import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart' as fc;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:kiosq_app/Models/cards_model.dart';
import 'package:kiosq_app/Models/kiosk_model.dart';
import 'package:kiosq_app/Models/product_model.dart';
import 'package:kiosq_app/Screens/Product/inforecommendation.dart';
import 'package:kiosq_app/Utils/filechoseviewer.dart';
import 'package:kiosq_app/Variables/global.dart';

class AddProductPage extends StatefulWidget {
  final KioskModel kioskmodel;
  const AddProductPage({
    Key? key,
    required this.kioskmodel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _AddProductPage();
  }
}

class _AddProductPage extends State<AddProductPage> {
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

  late Product model = Product(id: "N/A", kioskid: widget.kioskmodel.id);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    Settings.clearCache();
  }

  bool _saving = false;

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

  Future<void> onRefresh(String ean) async {
    fc.QuerySnapshot<Map<String, dynamic>> data;
    try {
      data = await fc.FirebaseFirestore.instance
          .collection("products")
          .where("ean", isEqualTo: ean)
          .orderBy("selected")
          .limit(10)
          .get();
    } catch (_) {
      data = await fc.FirebaseFirestore.instance
          .collection("products")
          .where("ean", isEqualTo: ean)
          .get();
    }
    if (data.docs.isNotEmpty) {
      Product? product;
      if (data.docs.length > 1) {
        product = await Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => InfoRecommendation(
                  products: data.docs.map((e) => Product.fromDoc(e)).toList(),
                )));
      } else {
        product = Product.fromDoc(data.docs.single);
      }

      if (product != null) {
        product.select();
        Settings.setValue("add-name", product.name, notify: true);
        Settings.setValue("add-desc", product.description, notify: true);
        Settings.setValue("add-price", product.price.toString(), notify: true);
        Settings.setValue("add-variance", product.variant, notify: true);
        Settings.setValue("add-vendor", product.vendor, notify: true);
        setState(() {
          model = product!;
          model.selected = 0;
          model.lastUpdate = DateTime.now();
          model.kioskid = widget.kioskmodel.id;
          model.stock = 0;
        });
        Global.showBar(context, Global.str.successToFetchData);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                final data = await FlutterBarcodeScanner.scanBarcode(
                    "#ff6666", Global.str.cancel, false, ScanMode.DEFAULT);

                if (data != "-1") {
                  model.ean = data;

                  onRefresh(data).then((value) =>
                      Settings.setValue("add-ean", data, notify: true)
                          .then((value) => setState(() {})));
                }
              },
              child: const Icon(Icons.qr_code),
            ),
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
                      if (model.name.length < 3) {
                        Global.showBar(
                            context,
                            Global.str.error +
                                "!, " +
                                Global.str.addproductsname);
                      } else if (model.description.length < 5) {
                        Global.showBar(
                            context,
                            Global.str.error +
                                "!, " +
                                Global.str.adddescription);
                      } else if (model.imageUrl.length < 5 || model.price < 0) {
                        Global.showBar(context,
                            Global.str.error + "!, " + Global.str.addcontent);
                      } else if (model.stock <= 0) {
                        Global.showBar(context,
                            Global.str.error + "!, " + Global.str.addstock);
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
                title: Text(Global.str.addproduct)),
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
                                  ? Global.str.addproductsname
                                  : model.name,
                              model.lastUpdate,
                              (model.description.isEmpty)
                                  ? Global.str.adddescription
                                  : model.description,
                              model,
                              image: "",
                              forceImage: (model.imageUrl.length < 5)
                                  ? null
                                  : (model.imageUrl.contains("http"))
                                      ? Image.network(
                                          model.imageUrl,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.file(
                                          File(model.imageUrl),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                            ))),
                    Padding(
                        padding: const EdgeInsets.all(25),
                        child: Column(children: [
                          SettingsGroup(
                              title: Global.str.recommended,
                              children: [
                                TextInputSettingsTile(
                                    keyboardType: TextInputType.number,
                                    title: Global.str.addean,
                                    onChange: (v) {
                                      model.ean = v;
                                      onRefresh(v);
                                    },
                                    settingKey: "add-ean")
                              ]),
                          SettingsGroup(title: Global.str.required, children: [
                            TextInputSettingsTile(
                                keyboardType: TextInputType.name,
                                title: Global.str.addproductsname,
                                onChange: (v) {
                                  setState(() {
                                    model.name = v;
                                  });
                                },
                                settingKey: "add-name"),
                            TextInputSettingsTile(
                              keyboardType: TextInputType.text,
                              title: Global.str.adddescription,
                              settingKey: "add-desc",
                              onChange: (v) {
                                setState(() {
                                  model.description = v;
                                });
                              },
                            ),
                            TextInputSettingsTile(
                              keyboardType: TextInputType.number,
                              title: Global.str.addprice,
                              settingKey: "add-price",
                              onChange: (v) {
                                model.price = double.parse(v);
                              },
                            ),
                            TextInputSettingsTile(
                              keyboardType: TextInputType.number,
                              title: Global.str.addstock,
                              settingKey: "add-stock",
                              onChange: (v) {
                                model.stock = int.parse(v);
                              },
                            ),
                          ]),
                          SettingsGroup(title: Global.str.optional, children: [
                            TextInputSettingsTile(
                              keyboardType: TextInputType.name,
                              title: Global.str.addvariance,
                              settingKey: "add-variance",
                              onChange: (v) {
                                model.variant = v;
                              },
                            ),
                            TextInputSettingsTile(
                              keyboardType: TextInputType.name,
                              title: Global.str.addvendor,
                              settingKey: "add-vendor",
                              onChange: (v) {
                                model.vendor = v;
                              },
                            ),
                          ])
                        ])),
                    uploadTile(Global.str.addthumbnail, model.imageUrl),
                  ],
                ))),
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()));
  }
}
