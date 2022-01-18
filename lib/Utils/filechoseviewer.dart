import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:photo_view/photo_view.dart';

class UploadScreen extends StatefulWidget {
  final String title;
  final String urlToImage;
  final Function(String? file) callback;

  const UploadScreen({
    Key? key,
    required this.title,
    required this.urlToImage,
    required this.callback,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _UploadScreen();
  }
}

class _UploadScreen extends State<UploadScreen> {
  late String urlToImage = widget.urlToImage;

  get imageProvider => (!urlToImage.contains("http"))
      ? FileImage(File(urlToImage))
      : NetworkImage(urlToImage);

  double? downloadValue;

  Widget get payload {
    return (urlToImage.length < 10)
        ? Text(Global.str.empty)
        : PhotoView(
            loadingBuilder:
                (BuildContext context, ImageChunkEvent? loadingProgress) {
              return Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(
                  value: downloadValue = (loadingProgress != null)
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!.toDouble()
                      : null,
                ),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text((downloadValue == null)
                          ? ""
                          : Global.str.downloading),
                      Text((downloadValue == null)
                          ? Global.str.loading
                          : "${(downloadValue! * 100).toStringAsFixed(2)}%"),
                      const SizedBox(
                        height: 10,
                      ),
                    ])
              ]);
            },
            imageProvider: imageProvider);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: widget.title.isEmpty
              ? null
              : [
                  IconButton(
                      onPressed: (urlToImage.length < 10)
                          ? null
                          : () async {
                              if (widget.title == Global.str.sendImage) {
                                widget.callback.call(urlToImage);
                                Navigator.of(context).pop();
                                return;
                              }
                              urlToImage = 'N/A';

                              widget.callback.call(null);
                              setState(() {});
                            },
                      icon: Icon(Global.str.sendImage == widget.title
                          ? Icons.send
                          : Icons.delete))
                ],
        ),
        floatingActionButton: (widget.title.isEmpty)
            ? null
            : Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Visibility(
                    visible: Global.str.addcontent != widget.title,
                    child: FloatingActionButton(
                        heroTag: "fab1",
                        onPressed: (kIsWeb)
                            ? () => Global.alertOnlyOnApp(context)
                            : () => imageLoad(ImageSource.gallery),
                        child: const Icon(Icons.image_search))),
                const SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                    heroTag: "fab2",
                    onPressed: (kIsWeb)
                        ? () => Global.alertOnlyOnApp(context)
                        : () => imageLoad(ImageSource.camera),
                    child: Icon(Global.str.addcontent != widget.title
                        ? Icons.add_a_photo
                        : Icons.attach_file))
              ]),
        body: Center(child: payload));
  }

  void imageLoad(ImageSource source) async {
    XFile? file = await Global.picker.pickImage(source: source);
    setState(() {
      urlToImage = file?.path ?? "";
    });
    widget.callback.call(urlToImage);
  }
}
