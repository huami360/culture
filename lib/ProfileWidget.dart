import 'dart:convert';

import 'package:bot_toast/bot_toast.dart';
import 'package:culture/WebWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

import 'EditProfileWidget.dart';
import 'RegisterLoginWidget.dart';
import 'Utils.dart';

class ProfileWidget extends StatefulWidget{
  @override
  State<ProfileWidget> createState() => ProfileState();
}
class ProfileState extends State<ProfileWidget> with SingleTickerProviderStateMixin{
  int following = 0, followed = 0;
  void _refresh(){
    httpget("${server_url}userget/", params: {
      "op": "get_profile",
    }, onResponse: (status, res){
      if(status == 200){
        setState(() {
          Apl.avater = res["avater"];
          Apl.nickname = decode(res["nickname"]);
          Apl.mypostcount = res["post_num"];
          followed = res['followed'];
          following = res['following'];
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
  @override void initState(){
    super.initState();
    controller = TabController(length: 1, vsync: this);
    _refresh();
  }
  late TabController controller;
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
                              /*Text(Apl.sid,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                maxLines: null, softWrap: true, overflow: TextOverflow.ellipsis,)*/
                            ],
                          )),
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
                    Expanded(child: Column(
                      children: [
                        const Text("我的图片", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(Apl.mypostcount.toString())
                      ],
                    )),
                    Expanded(child: GestureDetector(onTap: (){}, child: Column(
                      children: [
                        Text("关注", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(following.toString())
                      ],
                    ))),
                    Expanded(child: GestureDetector(onTap: (){}, child: Column(
                      children: [
                        Text("粉丝", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(followed.toString())
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
            jump(context, WebWidget(url: "https://weidian.com/?userid=1660872820&share_relation=32267953324c9382_1842277930_1&wfr=BuyercopyURL", title: "以文会友"));
          }, child: const ListTile(title: Text("以文会友"),leading: Icon(Icons.local_mall_outlined),),),
          GestureDetector(onTap: (){
            preference.clear();
            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
              return const RegisterLoginPage();
            }), (route) => false);
          }, child: const ListTile(title: Text("退出登录"),leading: Icon(Icons.exit_to_app),),),
          const SizedBox(height: 10,)
        ],
      )
    );
  }
}
var nameFont = const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold);
var idFont = const TextStyle(color: Color.fromARGB(255, 0, 0, 0), fontSize: 18, fontWeight: FontWeight.bold);