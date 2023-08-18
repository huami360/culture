import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
void httpget(String url, {Map<String, String>? params, Function(String response)? onResponse, Function(StackTrace? s)? onFailure}){
  if (params != null && params.isNotEmpty) {
    StringBuffer sb = StringBuffer("?");
    params.forEach((key, value) {
      sb.write("$key=$value&");
    });
    String paramStr = sb.toString();
    paramStr = paramStr.substring(0, paramStr.length - 1);
    url += paramStr;
  }
  http.get(Uri.parse(url)).onError((error, stackTrace) => onFailure!(stackTrace)).then((value) => onResponse!(value.body.trim()));
}
void httppost(String url, {Map<String, String>? params, Function(String response)? onResponse, Function(StackTrace? s)? onFailure}){
  //Clipboard.setData(ClipboardData(text: params.toString()));
  http.post(Uri.parse(url), body: params).onError((error, stackTrace) => onFailure!(stackTrace)).then((value) => onResponse!(value.body.trim()));
}
Future<String> httpget_wait(String url, {Map<String, String>? params}) async{
  if (params != null && params.isNotEmpty) {
    StringBuffer sb = StringBuffer("?");
    params.forEach((key, value) {
      sb.write("$key=$value&");
    });
    String paramStr = sb.toString();
    paramStr = paramStr.substring(0, paramStr.length - 1);
    url += paramStr;
  }
  var response = await http.get(Uri.parse(url));
  return response.body.trim();
}

String decode(String str){
  List<int> res = [];
  int len = str.length;
  for(var i = 0; i < len - 1; i += 2) {
    res.add(getasc(str[i]) * 16 + getasc(str[i+1]));
  }
  return utf8.decode(res);
}
int getasc(String x){
  int p = x.codeUnitAt(0);
  if(p >= 97) {
    return p - 87;
  } else {
    return p - 48;
  }
}

Future<void> jump(BuildContext context, Widget widget) async{
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return widget;
  }));
}

String getAvater(String path){
  return "$root_url$path?v=$v";
}
String getImage(String path){
  return "$root_url$path";
}

class Apl{
  static int sid = 0;
  static String sname = "", avater = "avaters/default_avater.png", nickname = "";
  static int mypostcount = 0;
}
final alter_colors = [Colors.grey, Colors.blue];
const root_url = "http://43.139.48.46/summer/";
late SharedPreferences preference;
int v = 0;
final isDigit = RegExp(r'^\d+$');