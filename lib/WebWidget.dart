import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
class WebWidget extends StatefulWidget{
  WebWidget({super.key, required this.url, required this.title});
  String url, title;
  @override
  State<WebWidget> createState() => WebState();
}
class WebState extends State<WebWidget>{
  // var controller = WebViewController();
  late InAppWebViewController _controller;
  late InAppWebViewSettings _settings;
  bool webMode = false;
  @override
  void initState(){
    super.initState();
  }
  @override
  Widget build(BuildContext context){
    return WillPopScope(onWillPop: () async{
      if(widget.title == "教务系统" && await _controller.canGoBack()){
        _controller.goBack();
        return false;
      }
      else {
        return true;
      }
    }, child: Scaffold(
      appBar: AppBar(
        title: Column(children: [
          Text(widget.title),
          /*GestureDetector(
              child: Text(webMode ? "兼容模式>" : "自适应模式>", style: const TextStyle(fontSize: 11, color: Colors.blue),),
              onTap: (){
                setState(() {
                  webMode = !webMode;
                  _settings.loadWithOverviewMode = webMode;
                  _settings.useWideViewPort = webMode;
                  _controller.setSettings(settings: _settings);
                });
              }),*/
        ],),
        centerTitle: true,
        actions: [],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri.uri(Uri.parse(widget.url))),
        onWebViewCreated: (control) async{
            _controller = control;
            _settings = (await _controller.getSettings())!;
        },
        onLoadStart: (controller, uri) async{
          if(uri.toString() == "https://jwxt.cumtb.edu.cn/student/home" && widget.url != "https://jwxt.cumtb.edu.cn/student/home") {
            controller.loadUrl(urlRequest: URLRequest(url: WebUri.uri(Uri.parse(widget.url))));
          }
        },
        onLoadStop: (controller, uri){
          var url = uri.toString();
          if(url.indexOf("https://jwxt.cumtb.edu.cn/student/login") == 0) {
            controller.loadUrl(urlRequest: URLRequest(url: WebUri.uri(Uri.parse("https://auth.cumtb.edu.cn/authserver/login?service=https%3A%2F%2Fjwxt.cumtb.edu.cn%2Fstudent%2Fsso%2Flogin"))));
          }
        },
        /*shouldOverrideUrlLoading: (controller, navigationAction) async {
          var uri = navigationAction.request.url!;

          // 根据协议头判断是否为非HTTP/HTTPS协议的URL
          if (!(uri.scheme.startsWith('http') || uri.scheme.startsWith('https'))) {
            // 这里你可以做一些自定义操作，例如提示用户
            if(Platform.isIOS) {
              launchUrl(Uri.parse(uri.toString()));
            }
            else {
              launch(uri.toString());
            }
            // 返回阻止处理的命令
            return NavigationActionPolicy.CANCEL;
          }

          // 对其他正常的HTTP/HTTPS请求，返回允许进行的命令
          return NavigationActionPolicy.ALLOW;
        },*/
        initialSettings: InAppWebViewSettings(
          useWideViewPort: false,
          loadWithOverviewMode: false
        )
      ),
    ));
  }
}