import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notify {
  static final Map<String, Notify> cache = {};

  final String key;
  String title;
  String? body;
  Function()? callback;
  Importance importance;
  Priority priority;
  bool sound;
  bool onlyAlertOnce;
  bool vibrate;
  double? progress;
  bool progressIndetermine;
  String channel;
  bool autoCancel;

  int get id {
    return cache.values.toList().indexOf(this);
  }

  bool get ongoing =>
      (progress != null && progress != 1) || (progressIndetermine);

  bool get showProgress => (progress != null || (progressIndetermine));

  Notify({
    this.key = "default",
    this.title = "Pasca App",
    this.body,
    this.callback,
    this.importance = Importance.max,
    this.priority = Priority.max,
    this.sound = true,
    this.onlyAlertOnce = true,
    this.vibrate = true,
    this.progress,
    this.progressIndetermine = false,
    this.channel = "Notifications",
    this.autoCancel = true,
  }) {
    cache[key] = this;
  }

  static final FlutterLocalNotificationsPlugin _notify =
      FlutterLocalNotificationsPlugin();

  Notify push(
      {String? title,
      String? body,
      Function()? callback,
      Importance? importance,
      Priority? priority,
      bool? sound,
      bool? onlyAlertOnce,
      bool? vibrate,
      double? progress,
      bool? progressIndetermine,
      bool? autoCancel,
      String? channel}) {
    if (title != null) this.title = title;
    if (body != null) this.body = body;
    if (callback != null) this.callback = callback;
    if (importance != null) this.importance = importance;
    if (priority != null) this.priority = priority;
    if (sound != null) this.sound = sound;
    if (onlyAlertOnce != null) this.onlyAlertOnce = onlyAlertOnce;
    if (vibrate != null) this.vibrate = vibrate;
    if (progress != null) this.progress = progress;
    if (progressIndetermine != null) {
      this.progressIndetermine = progressIndetermine;
    }
    if (channel != null) this.channel = channel;
    if (autoCancel != null) this.autoCancel = autoCancel;

    const initSetting = InitializationSettings(
        android: AndroidInitializationSettings("app_icon"));
    if (callback != null) {
      _notify.initialize(initSetting,
          onSelectNotification: (q) => callback.call());
    } else {
      _notify.initialize(initSetting);
    }
    _notify.show(
        id,
        this.title,
        this.body,
        NotificationDetails(
            android: AndroidNotificationDetails(this.channel, this.channel,
                autoCancel: this.autoCancel,
                ongoing: ongoing,
                onlyAlertOnce: this.onlyAlertOnce,
                showProgress: showProgress,
                progress: _currentProgress,
                maxProgress: 100000,
                enableVibration: this.vibrate,
                playSound: this.sound,
                indeterminate: this.progressIndetermine,
                icon: "@mipmap/ic_launcher",
                sound:
                    const RawResourceAndroidNotificationSound('notification'),
                priority: this.priority)));
    if (this.progress == 1 && this.autoCancel) cancel();
    return cache[key] = this;
  }

  int get _currentProgress {
    int val = (progress == null) ? 0 : (progress! * 100000.0).toInt();
    debugPrint(val.toString());
    return val;
  }

  void cancel() {
    _notify.cancel(id);
    cache.remove(key);
  }

  static void cancelAll() {
    _notify.cancelAll();
    cache.clear();
  }

  static Notify? getNotify({int? id, String? key}) {
    if (id != null) {
      for (var _key in cache.keys) {
        Notify? val;
        if ((val = cache[_key])!.id == id) return val;
      }
    } else if (key != null) {
      return cache[key];
    }
  }
}
