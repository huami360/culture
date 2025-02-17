import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
void httpget(String url, {Map<String, String>? params, Function(int status, dynamic res)? onResponse,
  Function(StackTrace? s)? onFailure}){
  if (params != null && params.isNotEmpty) {
    StringBuffer sb = StringBuffer("?");
    params.forEach((key, value) {
      sb.write("$key=$value&");
    });
    String paramStr = sb.toString();
    paramStr = paramStr.substring(0, paramStr.length - 1);
    url += paramStr;
  }
  http.get(Uri.parse(url), headers: {
    'Authorization': 'Bearer ${Apl.token}',
  }).timeout(const Duration(seconds: 2))
      .catchError((error){
    BotToast.showText(text: "连接服务器失败");
    reLogin();
  }).then((value) {
    if (value.statusCode == 401) {
      httppost("${server_url}api/token/refresh/", params: {'refresh': Apl.refresh}, onResponse: (status, res){
        if (status == 200) {
          Apl.token = res['access'];
          httpget(url, params: params, onResponse: onResponse, onFailure: onFailure);
        }
        else {
          reLogin();
        }
      }, refresh: true);
    }
    else {
      onResponse!(value.statusCode, jsonDecode(value.body.trim()));
    }
  });
}
Function() reLogin = (){};
void httppost(String url, {Map<String, String>? params, Function(int status, dynamic res)? onResponse,
  Function(StackTrace? s)? onFailure, bool refresh = false}){
  //Clipboard.setData(ClipboardData(text: params.toString()));
  http.post(Uri.parse(url), body: params, headers: {
    'Authorization': 'Bearer ${Apl.token}',
  }).onError((error, stackTrace) => onFailure!(stackTrace)).then((value){
    if (value.statusCode == 401) {
      if (refresh) {
        reLogin();
      } else {
        httppost("${server_url}api/token/refresh/", params: {'refresh': Apl.refresh},
            onResponse: (status, res) {
              if (status == 200) {
                Apl.token = res['access'];
                httpget(url, params: params,
                    onResponse: onResponse,
                    onFailure: onFailure);
              } else {
                reLogin();
              }
            },
            refresh: true);
      }
    }
    else {
      onResponse!(value.statusCode, jsonDecode(value.body.trim()));
    }
  });
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
Future<void> jumpAndRemove(BuildContext context, Widget widget) async{
  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
    return widget;
  }), (route) => false);
}

String getAvater(String path){
  return "$root_url$path?v=$v";
}
String getImage(String path){
  return "$root_url$path";
}

class Apl{
  static int sid = 0;
  static String avater = "avaters/default_avater.png", token = "", refresh = "", username = "";
  static bool isAdmin = false;
  static int mypostcount = 0;
  static String nickname = "";
}
var server_url = "http://www.cumtb-helper.top:8001/";
var root_url = "http://www.cumtb-helper.top/culture/";
late SharedPreferences preference;
int v = 0;
final isDigit = RegExp(r'^\d+$');