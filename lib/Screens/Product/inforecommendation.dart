import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/product_model.dart';
import 'package:kiosq_app/Variables/global.dart';

class InfoRecommendation extends StatelessWidget {
  final List<Product> products;
  const InfoRecommendation({Key? key, required this.products})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(Global.str.selectRelevantOption),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: products
              .map((e) => GestureDetector(
                  onTap: () => Navigator.pop(context, e),
                  child: Card(
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.name,
                                style: Theme.of(context).textTheme.headline6,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                              ),
                              Text(
                                e.description,
                                style: Theme.of(context).textTheme.caption,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                              ),
                              Text("Harga :" + e.priceToString),
                              Text("Varian : " + (e.variant ?? "N/A")),
                              Text("Vendor : " + (e.vendor ?? "N/A")),
                              Text("Dipilih : " + (e.selected.toString()))
                            ],
                          )))))
              .toList(),
        ));
  }
}
