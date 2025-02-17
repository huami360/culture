import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Utils.dart';
import 'home.dart';

class RegisterLoginPage extends StatefulWidget {
  const RegisterLoginPage({super.key});

  @override
  _RegisterLoginPageState createState() => _RegisterLoginPageState();
}

class _RegisterLoginPageState extends State<RegisterLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _ipController = TextEditingController();
  bool _isLogin = true;
  bool _finishRead = false;

  @override
  void initState(){
    super.initState();
    SharedPreferences.getInstance().then((value){
      preference = value;
      _ipController.text = server_url;
      if(preference.getString("token") != null){
        //Apl.sid = preference.getInt("id")!;
        Apl.token = preference.getString("token")!;
        Apl.refresh = preference.getString("refresh")!;
        Apl.username = preference.getString("username")!;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
          return HomePage();
        }), (route) => false);
      }
      setState(() {
        _finishRead = true;
      });
    });
  }

  void login(String username, String password) {
    http.post(Uri.parse("${server_url}api/login/"), body: {
      "username": username,
      "password": password
    }).timeout(const Duration(seconds: 2)).then((raw) {
      var value = raw.body, code = raw.statusCode;
      try {
        var res = jsonDecode(value);
        if (code == 200) {
          BotToast.showText(text: '登录成功！');
          Apl.token = res['access'];
          Apl.refresh = res['refresh'];
          Apl.username = username;
          preference.setString('token', Apl.token);
          preference.setString('refresh', Apl.refresh);
          preference.setString("username", Apl.username);
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
            return HomePage();
          }), (route) => false);
        } else {
          String msg = '';
          for(var key in res.values) {
            msg += key + '\n';
          }
          msg = decode(msg);
          BotToast.showText(text: msg);
        }
      } catch (e) {
        print(e);
      }
    }).catchError((error){
      BotToast.showText(text: "连接服务器失败");
    });
  }
  void register(String name, String username, String password) {
    http.post(Uri.parse("${server_url}api/register/"), body: {
      "username": username,
      "password": password,
      "name": name
    }).timeout(const Duration(seconds: 2)).then((raw) {
      var value = raw.body, code = raw.statusCode;
      try {
        var res = jsonDecode(value);
        print(code);
        if (code == 201) {
          BotToast.showText(text: decode(res['msg']));
          login(username, password);
        } else {
          // String msg = '';
          // for(var key in res.values) {
          //   msg += key + '\n';
          // }
          // BotToast.showText(text: msg);
          BotToast.showText(text: decode(res['msg']));
        }
      } catch (e) {
        // var res = jsonDecode(value);
        BotToast.showText(text: value);
      }
    }).catchError((error){
      BotToast.showText(text: "$error连接服务器失败");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? '登录' : '注册'),
      ),
      body: Center(
        child: _finishRead ? SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  if(!_isLogin) TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: '昵称',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '输入昵称';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(controller: _usernameController, decoration: const InputDecoration(labelText: '用户名',),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '输入用户名';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: '密码',),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '输入密码';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32.0),
                  FilledButton(
                    onPressed: () {
                      preference.setString('server_url', server_url);
                      //preference.commit();
                      if (_formKey.currentState!.validate()) {
                        if (_isLogin) {
                          login(_usernameController.text, _passwordController.text);
                        } else {
                          register(_nameController.text, _usernameController.text, _passwordController.text);
                        }
                      }
                    },
                    child: Text(_isLogin ? '登录' : '注册 '),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                      });
                    },
                    child: Text(_isLogin ? '还没有账号？点击注册' : '已经有账号了？点击登录'),
                  )
                ],
              ),
            ),
          ),
        ) : Container(),
      ),
    );
  }
}