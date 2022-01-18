import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:money_formatter/money_formatter.dart';

class Product {
  String name;
  String id;
  String? ean;
  String description;
  double price;
  String? variant;
  String? vendor;
  int stock;
  int sold;
  String kioskid;
  String imageUrl;
  int selected = 0;
  late DateTime lastUpdate;
  factory Product.fromDoc(i) {
    return Product(
        id: i.id,
        kioskid: i.get("kioskid"),
        description: i.get("description"),
        ean: i.get("ean"),
        imageUrl: i.get("image"),
        lastUpdate: (i.get("last_update") as Timestamp).toDate(),
        name: i.get("name"),
        price: i.get("price"),
        sold: i.get("sold"),
        stock: i.get("stock"),
        variant: i.get("variant"),
        vendor: i.get("vendor"),
        selected: i.get("selected"));
  }
  Product(
      {this.name = "",
      required this.id,
      this.ean,
      DateTime? lastUpdate,
      required this.kioskid,
      this.description = "",
      this.price = 0,
      this.imageUrl = "N/A",
      this.variant,
      this.selected = 0,
      this.vendor,
      this.stock = 0,
      this.sold = 0}) {
    this.lastUpdate = lastUpdate ?? DateTime.now();
  }
  Future<void> select() async {
    selected++;
    await FirebaseFirestore.instance
        .collection("products")
        .doc(id)
        .update({"selected": selected});
  }

  delete() {
    FirebaseFirestore.instance.collection("products").doc(id).delete();
  }

  Future<bool> post() async {
    final doc = await FirebaseFirestore.instance.collection("products").add({
      "name": name,
      "image": imageUrl,
      "last_update": lastUpdate,
      "description": description,
      "kioskid": kioskid,
      "price": price,
      "variant": variant,
      "stock": stock,
      "sold": sold,
      "vendor": vendor,
      "ean": ean,
      "selected": selected,
    });
    if (imageUrl.isNotEmpty && !imageUrl.contains("http")) {
      final task = await FirebaseStorage.instance
          .ref("product/photo/" + doc.id)
          .putFile(File(imageUrl));
      imageUrl = await task.ref.getDownloadURL();
      doc.update({"image": imageUrl});
    }
    id = doc.id;
    return true;
  }

  static String priceStringify(double price) {
    MoneyFormatter fmf = MoneyFormatter(
        amount: price,
        settings: MoneyFormatterSettings(
            symbol: 'Rp.',
            thousandSeparator: '.',
            decimalSeparator: ',',
            symbolAndNumberSeparator: ' ',
            fractionDigits: 2));
    return fmf.output.symbolOnLeft;
  }

  String get priceToString {
    return priceStringify(price);
  }

  Future<void> buy(int pcs) async {
    sold += pcs;
    stock -= pcs;
    await FirebaseFirestore.instance
        .collection("products")
        .doc(id)
        .update({"sold": sold, "stock": stock});
  }
}
