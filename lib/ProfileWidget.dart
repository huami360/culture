import 'dart:convert';


import 'package:culture/main.dart';
import 'package:flutter/material.dart';

import 'EditProfileWidget.dart';
import 'Utils.dart';

class ProfileWidget extends StatefulWidget{
  @override
  State<ProfileWidget> createState() => ProfileState();
}
class ProfileState extends State<ProfileWidget>{
  void _refresh(){
    print(Apl.sid);
    httpget("${root_url}server.py", params: {
      "op": "get_profile", "id": Apl.sid.toString()
    }, onResponse: (value){
      final data = jsonDecode(value);
      setState(() {
        Apl.avater = data["avater"];
        Apl.nickname = decode(data["nickname"]);
        Apl.mypostcount = data["image_num"];
      });
    });
  }
  @override void initState(){
    super.initState();
    _refresh();
  }
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("我的"),),
      body: Column(
        children: [
          Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0),),
              child: Column(children: [
                Container(
                  decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/icons/sky.jpg"), fit: BoxFit.fill),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0))),
                  child: Padding(padding: const EdgeInsets.all(10), child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(getAvater(Apl.avater)),
                          ),
                          const SizedBox(width: 10,),
                        Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(Apl.nickname,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                maxLines: null, softWrap: true, overflow: TextOverflow.ellipsis,),
                            ],
                          ),
                          ),
                          TextButton(onPressed: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                              return EditProfileWidget();
                            })).then((value) => _refresh());
                          }, child: const Text("编辑资料>", style: TextStyle(color: Colors.white),))
                        ],
                      ),
                    ],
                  ),)
                ),
                const SizedBox(height: 5,),
                Flex(
                  direction: Axis.horizontal,
                  children: [
                    Expanded(child: GestureDetector(onTap: (){}, child: Column(
                      children: [
                        const Text("我的图片", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(Apl.mypostcount.toString())
                      ],
                    ))),
                    Expanded(child: GestureDetector(onTap: (){}, child: const Column(
                      children: [
                        Text("关注", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("0")
                      ],
                    ))),
                    Expanded(child: GestureDetector(onTap: (){}, child: const Column(
                      children: [
                        Text("粉丝", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text("0")
                      ],
                    ))),
                  ],
                ),
                const SizedBox(height: 5,)
              ],
            ),
          ),
          Expanded(child: Container()),
          GestureDetector(onTap: (){
            preference.remove("id");
            preference.commit();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return RegisterLoginPage();
            }), (route) => false);
          }, child:
            const ListTile(title: Text("退出登录"), leading: Icon(Icons.close, color: Colors.red,),),
          ),
          SizedBox(height: 10,)
        ],
      )
    );
  }
}
var nameFont = const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
var idFont = const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18, fontWeight: FontWeight.bold);