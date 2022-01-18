import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/file_uploader_model.dart';
import 'package:kiosq_app/Utils/duration_format.dart';
import 'package:kiosq_app/Variables/global.dart';

class FileUploaderPage extends StatefulWidget {
  const FileUploaderPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _FileUploaderPage();
  }
}

class _FileUploaderPage extends State<FileUploaderPage> {
  late Timer timer;

  final ScrollController _controller = ScrollController();
  late bool _appBarState;

  @override
  void initState() {
    _appBarState = true;
    timer =
        Timer.periodic(const Duration(seconds: 1), (timer) => setState(() {}));
    _controller.addListener(() {
      if (_appBarState && _controller.offset > 0) {
        setState(() {
          _appBarState = false;
        });
      } else if (!_appBarState && _controller.offset <= 0) {
        setState(() {
          _appBarState = true;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Widget makeCard({FileUploader? e}) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Global.colorDim(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(10),
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: (e == null)
            ? Center(child: Text(Global.str.empty))
            : Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                  width: MediaQuery.of(context).size.width - 85,
                                  child: Text(
                                    e.title,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                    style:
                                        Theme.of(context).textTheme.headline5,
                                  )),
                              Text(lastSeen(e.createdAt))
                            ]),
                        SizedBox(
                            height: 25,
                            width: 25,
                            child: IconButton(
                                alignment: Alignment.topRight,
                                padding: EdgeInsets.zero,
                                icon: const Icon(Icons.cancel),
                                onPressed: () {
                                  setState(() => e.cancel);
                                })),
                      ]),
                  Text("${((e.uploadValue ?? 0) * 100).toStringAsFixed(1)}%",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  LinearProgressIndicator(
                    value: e.uploadValue,
                  )
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  for (var element in FileUploader.allData) {
                    element.cancel();
                  }
                },
                icon: const Icon(Icons.clear_all))
          ],
          title: Text(Global.str.uploader),
          shadowColor: (_appBarState) ? Colors.transparent : null,
          backgroundColor: (_appBarState) ? Colors.transparent : null,
          foregroundColor:
              (_appBarState) ? Theme.of(context).colorScheme.secondary : null,
        ),
        body: SingleChildScrollView(
            controller: _controller,
            child: FileUploader.allData.isEmpty
                ? makeCard()
                : Column(
                    children: FileUploader.allData
                        .map((e) => makeCard(e: e))
                        .toList())));
  }
}
