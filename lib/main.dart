import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:crypto/crypto.dart';
import 'package:culture/Utils.dart';
import 'package:culture/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'RegisterLoginWidget.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register/Login Demo',
      home: RegisterLoginPage(),
      debugShowCheckedModeBanner: false,
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()]
    );
  }
}