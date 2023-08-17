import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
    httpget("${root_url}server.py", params: {
      "op": "get_profile", "id": Apl.sid.toString()
    }, onResponse: (value){
      print(value);
      final data = jsonDecode(value);
      setState(() {
        Apl.avater = data["avater"];
        Apl.nickname = decode(data["nickname"]);
      });
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
                    var request = http.MultipartRequest('POST', Uri.parse('${root_url}server.py'));
                    request.files.add(await http.MultipartFile.fromPath('file', croppedImage.path));
                    request.fields.addAll({"op" : "upload_avater", "id" : Apl.sid.toString()});
                    var response = await request.send();
                    if(response.statusCode != 200){
                      Fluttertoast.showToast(msg: "上传失败，请检查网络连接！");
                      return;
                    }
                    var res = (await response.stream.bytesToString()).trim();
                    if(res == "Done"){
                      Fluttertoast.showToast(msg: "修改成功");
                      v++;
                      _refresh();
                    }
                    else{
                      Fluttertoast.showToast(msg: decode(res));
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
            httppost("${root_url}server.py",
                params: {"id" : Apl.sid.toString(), "nickname" : _nameController.text,
                  "op" : "edit_nickname"
                },
                onResponse: (value){
                  if(value == "Done") {
                    Fluttertoast.showToast(msg: "修改成功");
                    Navigator.pop(context);
                  } else {
                    Fluttertoast.showToast(msg: decode(value));
                  }
                },
                onFailure: (s){
                  Fluttertoast.showToast(msg: "失败");
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