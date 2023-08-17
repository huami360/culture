import 'dart:ffi';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
String getkey(String str, String key1, String key2){
  try{
    int cur = str.indexOf(key1), len = key1.length, cur2 = str.indexOf(key2, cur + len);
    return str.substring(cur + len, cur2);
  }catch(e){
    return "";
  }
}

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

String timeformater(DateTime date, TimeOfDay time){
  String ans = date.toString().substring(0, 11);
  if(time.hour < 10) ans += "0";
  ans += "${time.hour}:";
  if(time.minute < 10) ans += "0";
  ans += "${time.minute}:00";
  return ans;
}

String timeprocesser(String time){
  DateTime postdate = DateTime.parse(time), now = DateTime.now();
  var diff = now.difference(postdate);
  String timepast = "刚刚";
  if(diff.inMinutes > 5) timepast = "${diff.inMinutes}分钟前";
  if(diff.inHours > 0) timepast = "${diff.inHours}小时前";
  if(diff.inDays == 1) {
    timepast = "昨天";
  } else if(diff.inDays > 1){
    timepast = time.substring(0, 10);
  }
  return timepast;
}

String getAvater(String path){
  return "$root_url$path?v=$v";
}
String getImage(String path){
  return "$root_url$path";
}
class TimeManager {
  int minutes = 0;

  TimeManager(int m) {
    minutes = m;
  }

  TimeManager.ints(int h, int m) {
    minutes = m + h * 60;
  }

  TimeManager.date(DateTime calendar) {
    minutes = calendar.hour * 60 + calendar.minute;
  }

  TimeManager minus(TimeManager pre) {
    return TimeManager(minutes - pre.minutes);
  }

  String toNumber() {
    return "${(minutes ~/ 60).toString().padLeft(2, '0')}:${(minutes % 60).toString().padLeft(2, '0')}";
  }

  int getHour() {
    return minutes ~/ 60;
  }

  int getMinutes() {
    return minutes % 60;
  }

  String format() {
    String result = "${(minutes % 60).toString()}分钟";
    if (minutes >= 60) {
      result = "${(minutes ~/ 60).toString()}小时$result";
    }
    return result;
  }

  bool during(TimeManager start, TimeManager end) {
    return minutes >= start.minutes && minutes <= end.minutes;
  }

  bool before(TimeManager t) {
    return minutes < t.minutes;
  }
}

class Apl{
  static int sid = 0;
  static String sname = "", avater = "avaters/default_avater.png", nickname = "";
  static int mypostcount = 0;
}
final alter_colors = [Colors.grey, Colors.blue];
final week_chinese = ["零", "一", "二", "三", "四", "五", "六", "日"];
const root_url = "http://43.139.48.46/summer/";
const root_download_url = "http://43.139.48.46/summer/data";
late SharedPreferences preference;
int v = 0;
final isDigit = RegExp(r'^\d+$');