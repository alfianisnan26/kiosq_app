import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_settings_screens/flutter_settings_screens.dart';
import 'package:kiosq_app/Models/chat_model.dart';
import 'package:kiosq_app/Models/profile_model.dart';
import 'package:kiosq_app/Models/theme_model.dart';
import 'package:kiosq_app/Screens/Main/dashoard.dart';
import 'package:kiosq_app/Variables/global.dart';
import 'package:kiosq_app/Variables/var_strings.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  initSettings().then((_) {
    runApp(const MyHomePage());
  });
}

Future<void> initSettings() async {
  if (kIsWeb) setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Settings.init(
    cacheProvider: SharePreferenceCache(),
  );
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool firstLoading = false;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => Strings(),
          ),
          ChangeNotifierProvider(
            create: (_) => ThemeModel(),
          ),
          ChangeNotifierProvider(create: (_) => Profile())
        ],
        child: Consumer2(
          builder: (context, ThemeModel themeNotifier, Profile profile, child) {
            Global.profile = profile;
            if (profile.loading) {
              firstLoading = true;
            } else if (firstLoading && profile.isLogin) {
              if ((themeNotifier.modeInt != profile.mode)) {
                Timer(const Duration(seconds: 2), () {
                  themeNotifier.modeInt = profile.mode;
                });
              }
              firstLoading = false;
            } else if (profile.isLogin) {
              profile.mode = themeNotifier.modeInt;
              ChatroomModel.listen();
            } else if (!profile.isLogin) {
              ChatroomModel.dispose();
            }
            return MaterialApp(
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: const [
                  Locale('en', 'US'), // English, no country code
                  Locale('id', '')
                ], // Spanish, no country code
                title: 'Kiosq App',
                navigatorKey: Global.navigator,
                themeMode: themeNotifier.mode,
                theme: ThemeData(
                  brightness: Brightness.light,
                  fontFamily: 'PlusJakartaSans',
                  primaryColor: profile.roleColor(),
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                darkTheme: ThemeData(
                  brightness: Brightness.dark,
                  fontFamily: 'PlusJakartaSans',
                  primaryColor: profile.roleColor(),
                  visualDensity: VisualDensity.adaptivePlatformDensity,
                ),
                debugShowCheckedModeBanner: false,
                home: const Dashboard());
          },
        ));
  }
}
