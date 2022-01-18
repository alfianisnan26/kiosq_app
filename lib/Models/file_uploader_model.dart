import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:kiosq_app/Screens/Features/file_uploader.dart';
import 'package:kiosq_app/Utils/notification.dart';
import 'package:kiosq_app/Variables/global.dart';

class FileUploader {
  static List<FileUploader> allData = [];

  late Notify notify;
  final File file;
  final Function(String url) onFinished;
  final String title;
  late DateTime createdAt;
  double? uploadValue;
  UploadTask? uploadTask;

  FileUploader(
    this.file,
    this.onFinished,
    this.title,
  ) {
    createdAt = DateTime.now();
  }

  Future<String> upload(String root, String location,
      {bool imageCompress = false}) async {
    Reference storageReference =
        FirebaseStorage.instance.ref(root).child(location);
    allData.add(this);
    notify = Notify(
        progress: 0,
        key: "uploader-" + DateTime.now().toIso8601String(),
        title: title,
        body: Global.str.loading,
        channel: "Uploading File",
        callback: () => Global.navigator.currentState!
            .push(MaterialPageRoute(builder: (_) => const FileUploaderPage())));
    uploadTask = storageReference.putData(imageCompress
        ? await FlutterImageCompress.compressWithList(await file.readAsBytes(),
            format: CompressFormat.webp,
            minHeight: 1000,
            minWidth: 1000,
            quality: 50)
        : await file.readAsBytes());
    uploadTask!.snapshotEvents.forEach((element) {
      uploadValue = (element.bytesTransferred / element.totalBytes);
      notify.push(
          progress: uploadValue,
          body:
              "${Global.str.uploading} ${(uploadValue ?? 0 * 100).toStringAsFixed(2)}%");
    });
    String url = 'N/A';
    await uploadTask!.whenComplete(() async {
      notify.cancel();
      if (uploadValue == 1) {
        url = await storageReference.getDownloadURL();
        debugPrint("Upload Complete at : $url");
        onFinished.call(url);
      } else {
        uploadValue = null;
        debugPrint("Upload Failed");
        onFinished.call(url);
      }
    });
    return url;
  }

  void cancel() async {
    debugPrint("Cancelling : $title");
    try {
      if (uploadTask != null) {
        await uploadTask!.cancel();
      }
      // ignore: empty_catches
    } catch (i) {}
    allData.remove(this);
  }
}
