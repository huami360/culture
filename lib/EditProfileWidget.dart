import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;

import 'Utils.dart';
class EditProfileWidget extends StatefulWidget {
  @override
  State<EditProfileWidget> createState() => EditProfileState();
}
class EditProfileState extends State<EditProfileWidget>{
  ImagePicker imagePicker = ImagePicker();
  ImageCropper imageCropper = ImageCropper();
  void _refresh(){
    httpget("${server_url}userget/", params: {
      "op": "get_profile",
    }, onResponse: (status, res){
      if(status == 200){
        setState(() {
          Apl.avater = res["avater"];
          Apl.nickname = decode(res["nickname"]);
        });
      }
      else{
        if(res.containsKey('msg')) {
          BotToast.showText(text:decode(res['msg']));
        }
        else{
          BotToast.showText(text: "请求出错");
        }
      }

    });
  }
  @override
  void initState(){
    super.initState();
    _refresh();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("编辑资料"),),
      body: ListView(children: [
        GestureDetector(
          child: Center(child: ClipOval(child: Image.network(getAvater(Apl.avater), width: 80, height: 80, fit: BoxFit.cover,)),),
          onTap: () async {
            imagePicker.pickImage(source: ImageSource.gallery).then((value){
              if(value == null) return;
              imageCropper.cropImage(sourcePath: value.path, aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1))
                  .then((croppedImage) async{
                    if(croppedImage == null) return;
                    var request = http.MultipartRequest('POST', Uri.parse('${server_url}userpost/'));
                    request.files.add(await http.MultipartFile.fromPath('file', croppedImage.path));
                    request.fields.addAll({"op" : "upload_avater"});
                    request.headers.addAll({'Authorization': 'Bearer ${Apl.token}'});
                    var response = await request.send();
                    if(response.statusCode != 200){
                      BotToast.showText(text: "上传失败，请检查网络连接！");
                      return;
                    }
                    var res = response.statusCode;
                    if(res == 200){
                      BotToast.showText(text: "修改成功");
                      v++;
                      _refresh();
                    }
                    else{
                      BotToast.showText(text: "修改失败");
                    }
                  });
            });
          }
        ),
        EditItem(keyvalue: "nickname", title: "昵称", current: Apl.nickname, refresh: _refresh,)
      ],)
    );
  }
}
class EditItem extends StatelessWidget{
  EditItem({super.key, required this.keyvalue, required this.title, required this.current, required this.refresh});
  String keyvalue, title, current;
  Function refresh;
  //Function onTap;
  @override
  Widget build(BuildContext context){
    return GestureDetector(onTap: (){
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return EditProfilePage();
      })).then((value) => refresh());
    }, child: Padding(padding: const EdgeInsets.all(10),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(title, style: const TextStyle(fontSize: 18, color: Colors.black),),
        Expanded(child: Container()),
        Text("$current >", style:const TextStyle(fontSize: 18, color: Colors.grey))
      ],
    ),),);
  }
}

class EditProfilePage extends StatefulWidget {
  @override
  State<EditProfilePage> createState() => EditProfilePageState();
}
class EditProfilePageState extends State<EditProfilePage>{
  final TextEditingController _nameController = TextEditingController();
  var submitButtons = [];
  int _submitState = 0;
  var _typeindex = 0;

  @override
  void initState(){
    super.initState();
    submitButtons = [
      const OutlinedButton(
        onPressed: null,
        child: Text("完成", style: TextStyle(color: Colors.black),),
      ),
      FilledButton(
          onPressed: (){
            if(_nameController.text.length > 10){
              BotToast.showText(text: "昵称长度不能超过10！");
              return;
            }
            httppost("${server_url}userpost/",
                params: {
                  "nickname" : _nameController.text,
                  "op" : "edit_nickname"
                },
                onResponse: (status, res){
                  if(status == 200){
                    BotToast.showText(text: decode(res['msg']));
                    Navigator.pop(context);
                  }
                  else{
                    if(res.containsKey('msg')) {
                      BotToast.showText(text:decode(res['msg']));
                    }
                    else{
                      BotToast.showText(text: "请求出错");
                    }
                  }
                },
                onFailure: (s){
                  BotToast.showText(text: "连接失败，请检查网络");
                });
          },
          style: const ButtonStyle(backgroundColor: MaterialStatePropertyAll(Colors.blue)),
          child: const Text("完成", style: TextStyle(color: Colors.white),)
      )
    ];
    _nameController.addListener(() {
      setState(() {
        _submitState = _nameController.text.isNotEmpty ? 1 : 0;
      });
    });
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
        appBar: AppBar(title: const Text("修改昵称"),
          actions: [
            Center(
                child:submitButtons[_submitState])
          ],),
        body:Padding(padding: const EdgeInsets.only(left: 10, right: 10),
            child: Column(
              children: [
                const SizedBox(height: 10,),
                TextField(controller: _nameController,
                  decoration:  const InputDecoration(label:Text("昵称"),
                      border: InputBorder.none,
                      hintText: "输入新昵称"), style: const TextStyle(fontSize: 20),),
                const SizedBox(height: 10,),
              ],
            )
        )
    );
  }
}