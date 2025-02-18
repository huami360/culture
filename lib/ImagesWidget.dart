
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_view/photo_view.dart';

import 'Utils.dart';

class ImagesWidget extends StatefulWidget{
  @override
  State<ImagesWidget> createState() => ImagesState();
}

class ImagesState extends State<ImagesWidget> with SingleTickerProviderStateMixin{
  List<dynamic> dataList = [];
  int _currentIndex = 0;
  ImagePicker imagePicker = ImagePicker();
  ImageCropper imageCropper = ImageCropper();

  Future<void> _RefreshList() async{
    httpget("${server_url}userget",
      params: {"op" : "get_images"},
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
      appBar: AppBar(title: const Text("广场")),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        backgroundColor: Colors.lightBlue,
        onPressed: () async{
          imagePicker.pickImage(source: ImageSource.gallery).then((value) async {
            if(value == null) return;
            var request = http.MultipartRequest('POST', Uri.parse('${server_url}userpost/'));
            request.files.add(await http.MultipartFile.fromPath('file', value.path));
            request.fields.addAll({"op" : "upload_image"});
            request.headers.addAll({'Authorization': 'Bearer ${Apl.token}'});
            var response = await request.send();
            if(response.statusCode != 200){
              BotToast.showText(text: "上传失败，请检查网络连接！");
              return;
            }
            var res = response.statusCode;
            if(res == 200) {
              BotToast.showText(text: "上传成功");
              _RefreshList();
            }
          });
        },
        child: const Icon(Icons.add, color: Colors.white,),),
      body:RefreshIndicator(
        onRefresh: () async{
          _RefreshList();
        },
        child: GridView(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          children: [
            for(var data in dataList) SizedBox(height: 250,
                child: SingleChildScrollView(child: ImageListItem(data: data, refresh: _RefreshList,),)
            )
          ],
        ),
      )
    );
  }
}
var textFont = const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 20);
class ImageListItem extends StatelessWidget{
  ImageListItem({super.key, required this.data, required this.refresh});
  dynamic data;
  Function refresh;
  @override
  Widget build(BuildContext context){
    return GestureDetector(
      child: Card(child: Padding(padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(backgroundImage: NetworkImage(getAvater(data["avater"]))),
            const SizedBox(width: 5,),
            Expanded(child: Text(decode(data["nickname"]), maxLines: null, softWrap: true, overflow: TextOverflow.ellipsis,))
          ]),
          const SizedBox(height: 5,),
          Image.network(getImage(data["path"]))
        ]))),
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImagePreviewPage(imageUrl: getImage(data["path"]), iid: data["iid"],),
          ),
        ).then((value){
          refresh();
        });
      },
    );
  }
}
class ImagePreviewPage extends StatelessWidget {
  final String imageUrl;
  int iid;
  ImagePreviewPage({required this.imageUrl, required this.iid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('图片预览'), actions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () async {
            if (await Permission.storage.request().isGranted) {
              var response = await http.get(Uri.parse(imageUrl));
              final result = await ImageGallerySaver.saveImage(
                  Uint8List.fromList(response.bodyBytes));
              if (result["isSuccess"] == true) {
                BotToast.showText(text: "保存成功");
              } else {
                BotToast.showText(text: "保存失败");
              }
            }
            else{
              BotToast.showText(text: "权限获取失败！");
            }
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () async {
            httppost("${server_url}userpost/", params: {
              "op": "del_image",
              "iid": iid.toString()
            }, onResponse: (status, res) {
              if (status == 200) {
                BotToast.showText(text: "删除完成");
                Navigator.pop(context);
              }
              else{
                BotToast.showText(text: decode(res['msg']));
              }
            });
          },
        ),
      ],),
      body: Center(
        child: PhotoView(
          imageProvider: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}