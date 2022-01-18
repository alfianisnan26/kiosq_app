import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/kiosk_model.dart';

class Cashier extends StatefulWidget {
  final KioskModel kioskmodel;
  const Cashier({Key? key, required this.kioskmodel}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _State();
  }
}

class _State extends State<Cashier> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold();
  }
}
