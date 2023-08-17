import 'package:culture/ProfileWidget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/services.dart';
import 'dart:convert';
import 'dart:io';

import 'ImagesWidget.dart';
import 'RankWidget.dart';

late String lastest_version, current_version, update_info, download_url;
int compulsory = 0;

bool started_update = false;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage>{
  int _current_index = 0;
  List<Widget> widgets = [];

  @override
  void initState() {
    super.initState();
    //httpget("${root_url}server.py", params: {"op":"updateinfo"});
    widgets.add(RankWidget());
    widgets.add(ImagesWidget());
    widgets.add(ProfileWidget());
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body : Center(child: widgets[_current_index]),
        floatingActionButton: CustomFloatingActionButton(onPress: (){
          setState(() {
            _current_index = 1;
          });
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: Colors.lightBlue,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home, ), label: "排名"),
            BottomNavigationBarItem(icon: Icon(Icons.camera_outlined, color: Colors.transparent,), label: "广场"),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle, ), label: "我的"),
          ],
          currentIndex: _current_index,
          onTap: (int currentIndex){
            //Fluttertoast.showToast(msg: current_index.toString());
            setState(() {
              _current_index = currentIndex;
            });
          },
        ),
      );
  }
}

//凸起圆形按钮，带点按反馈
class CustomFloatingActionButton extends StatefulWidget {
  CustomFloatingActionButton({super.key, required this.onPress});
  Function onPress;
  @override
  _CustomFloatingActionButtonState createState() => _CustomFloatingActionButtonState();
}

class _CustomFloatingActionButtonState extends State<CustomFloatingActionButton> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  final double _scaleFactor = 0.9;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 100),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      onTapDown: (_) => _onTapDown(),
      onTapUp: (_) => _onTapUp(),
      onTapCancel: () => _onTapCancel(),
      child: Transform.scale(
        scale: _isPressed ? _scaleFactor : 1.0,
        child: const FloatingActionButton(
          onPressed: null,
          backgroundColor: Colors.lightBlue,
          shape: CircleBorder(),
          child: Icon(Icons.camera_outlined, color: Colors.white, size: 36,),
        ),
      ),
    );
  }

  void _onTapDown() {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp() {
    _animationController.forward(from: 0).then((_) {
      setState(() {
        _isPressed = false;
      });
      widget.onPress();
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }
}
