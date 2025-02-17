
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'Utils.dart';

class RankWidget extends StatefulWidget{
  @override
  State<RankWidget> createState() => RankState();
}

class RankState extends State<RankWidget> with SingleTickerProviderStateMixin{
  List<dynamic> dataList = [];
  int _currentIndex = 0;
  ImagePicker imagePicker = ImagePicker();
  ImageCropper imageCropper = ImageCropper();
  int number = 0;

  Future<void> _RefreshList() async{
    number = 0;
    httpget("${server_url}userget",
        params: {"op" : "get_rank"},
        onResponse: (status, res) {
          if (status == 200) {
            setState(() {
              dataList = res['data'];
            });
          }
        });
  }
  @override
  void initState(){
    super.initState();
    _RefreshList();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("排名")),
      body:RefreshIndicator(
        onRefresh: () async{
          _RefreshList();
        },
        child: ListView(children: [
            for(var data in dataList) RankListItem(data: data, number: ++number,)
          ],
        ),
      )
    );
  }
}
var textFont = const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 20);
class RankListItem extends StatelessWidget{
  RankListItem({super.key, required this.data, required this.number});
  dynamic data;
  int number;
  @override
  Widget build(BuildContext context){
    return ListTile(title: Text(decode(data["nickname"])),
      leading: Row(mainAxisSize:MainAxisSize.min, children: [
        Text(number.toString(), style: const TextStyle(fontSize: 20, color: Colors.blue),),
        const SizedBox(width: 5,),
        CircleAvatar(backgroundImage: NetworkImage(getAvater(data["avater"])))
      ],),
      subtitle: Text("共发布${data["image_num"]}张图片"),
    );
  }
}