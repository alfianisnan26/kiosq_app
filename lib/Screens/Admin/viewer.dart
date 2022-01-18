import 'package:flutter/material.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:photo_view/photo_view.dart';

class UploadScreen extends StatefulWidget {
  final String title;
  final String urlToImage;
  final Profile profile;
  final Function() callback;

  const UploadScreen({
    Key? key,
    required this.title,
    required this.urlToImage,
    required this.callback,
    required this.profile,
  }) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _UploadScreen();
  }
}

class _UploadScreen extends State<UploadScreen> {
  late String urlToImage = widget.urlToImage;
  late Profile profile = widget.profile;
  bool isLoading = false;
  double? downloadValue;

  Widget get payload {
    if (!isLoading) {
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
                        Text(Global.str.downloading),
                        Text(
                            "${((downloadValue ?? 0) * 100).toStringAsFixed(2)}%"),
                        const SizedBox(
                          height: 10,
                        ),
                      ])
                ]);
              },
              imageProvider: NetworkImage(urlToImage));
    } else {
      return Stack(alignment: Alignment.center, children: [
        const CircularProgressIndicator(),
        Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(Global.str.loading),
              const SizedBox(
                height: 10,
              ),
            ])
      ]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(child: payload));
  }
}
