import 'package:flutter/material.dart';
import 'package:kiosq_app/Variables/global.dart';

class Carts extends StatefulWidget {
  const Carts({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _Carts();
  }
}

class _Carts extends State<Carts> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            elevation: (!_appBarState) ? null : 0,
            shadowColor: (_appBarState) ? Colors.transparent : null,
            backgroundColor: (_appBarState) ? Colors.transparent : null,
            foregroundColor:
                (_appBarState) ? Theme.of(context).colorScheme.secondary : null,
            title: Text(Global.str.carts)),
        body: SingleChildScrollView(
          controller: _controller,
        ));
  }
}
