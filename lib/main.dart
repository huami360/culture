import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:culture/Utils.dart';
import 'package:culture/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Register/Login Demo',
      home: RegisterLoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class RegisterLoginPage extends StatefulWidget {
  @override
  _RegisterLoginPageState createState() => _RegisterLoginPageState();
}

class _RegisterLoginPageState extends State<RegisterLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  @override
  void initState(){
    super.initState();
    SharedPreferences.getInstance().then((value){
      preference = value;
      if(preference.getInt("id") != null){
        Apl.sid = preference.getInt("id")!;
        Apl.sname = preference.getString("name")!;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
          return HomePage();
        }), (route) => false);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? '登录' : '注册'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: '用户名',
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return '输入用户名';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '密码',
                    ),
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
                      if (_formKey.currentState!.validate()) {
                        if (_isLogin) {
                          var bytes = utf8.encode(_passwordController.text);
                          var md = md5.convert(bytes).toString();
                          httpget("${root_url}server.py", params: {
                            "op": "login",
                            "username": _usernameController.text,
                            "password": md
                          }, onResponse: (value) {
                            try {
                              var res = jsonDecode(value);
                              if (res["code"] == 0) {
                                Fluttertoast.showToast(msg: "登录成功");
                                Apl.sid = res["uid"];
                                Apl.sname = _usernameController.text;
                                preference.setString("name", Apl.sname);
                                preference.setInt("id", Apl.sid);
                                preference.commit();
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                                  return HomePage();
                                }), (route) => false);
                              } else {
                                Fluttertoast.showToast(msg: decode(res["msg"]));
                              }
                            } catch (e) {
                              print(e);
                            }
                          });
                        } else {
                          // Perform registration logic
                          var bytes = utf8.encode(_passwordController.text);
                          var md = md5.convert(bytes).toString();
                          httpget("${root_url}server.py", params: {
                            "op": "register",
                            "username": _usernameController.text,
                            "password": md
                          }, onResponse: (value) {
                            try {
                              var res = jsonDecode(value);
                              if (res["code"] == 0) {
                                Fluttertoast.showToast(msg: "注册成功");
                                Apl.sid = res["uid"];
                                Apl.sname = _usernameController.text;
                                preference.setString("name", Apl.sname);
                                preference.setInt("id", Apl.sid);
                                preference.commit();
                                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                                  return HomePage();
                                }), (route) => false);
                              } else {
                                Fluttertoast.showToast(msg: decode(res["msg"]));
                              }
                            } catch (e) {

                            }
                          });
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}