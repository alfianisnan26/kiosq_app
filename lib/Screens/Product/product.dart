import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/kiosk_model.dart';
import 'package:kiosq_app/Models/product_model.dart';

class ProductPage extends StatefulWidget {
  final Product model;
  const ProductPage({Key? key, required this.model}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<ProductPage> {
  late Product model = widget.model;
  late int pcs = (model.stock == 0) ? 0 : 1;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(model.name),
          actions: [
            Visibility(
                visible: KioskModel.allMine
                    .where((element) => element.id == model.kioskid)
                    .isNotEmpty,
                child: IconButton(
                    onPressed: () {
                      model.delete();
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.delete)))
          ],
        ),
        body: Stack(children: [
          SingleChildScrollView(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 250,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(model.imageUrl))),
              ),
              Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.description,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Visibility(
                            visible: (model.variant ?? "").isNotEmpty,
                            child: Text("Varian " + (model.variant ?? "N/A"))),
                        Visibility(
                            visible: (model.vendor ?? "").isNotEmpty,
                            child: Text(
                                "Produksi oleh " + (model.vendor ?? "N/A"))),
                        const SizedBox(
                          height: 20,
                        ),
                        Text("Terjual " + model.sold.toString() + " buah")
                      ]))
            ],
          )),
          Column(children: [
            Expanded(
              child: Container(),
            ),
            Column(children: [
              Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(model.priceToString +
                            " x " +
                            pcs.toString() +
                            " pcs"),
                        Text(
                          (model.stock == 0)
                              ? "Habis"
                              : Product.priceStringify(model.price * pcs),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 30),
                        ),
                      ]),
                  width: MediaQuery.of(context).size.width,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.5)),
              Container(
                  color: Theme.of(context).colorScheme.primary,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(children: [
                        IconButton(
                            onPressed: (pcs >= model.stock)
                                ? null
                                : () {
                                    setState(() {
                                      pcs++;
                                    });
                                  },
                            icon: const Icon(Icons.add)),
                        IconButton(
                            onPressed: (pcs <= 1)
                                ? null
                                : () {
                                    setState(() {
                                      pcs--;
                                    });
                                  },
                            icon: const Icon(Icons.remove)),
                      ]),
                      IconButton(
                          onPressed: (model.stock == 0)
                              ? null
                              : () {
                                  model.buy(pcs);
                                  Navigator.of(context).pop();
                                },
                          icon: const Icon(Icons.add_shopping_cart)),
                    ],
                  )),
            ])
          ]),
        ]));
  }
}
