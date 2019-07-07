import 'package:flutter/material.dart';


/**
 * 关于
 */
class about extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return new MaterialApp(
      title: "关于",
      home: Scaffold(
        appBar: new AppBar(
          title: new Text("关于"),
          centerTitle: true,
        ),
        body: new Center(
          child: new Text("图片处理工具 - Blur壁纸插件"),
        ),
      ),
    );
  }

}
