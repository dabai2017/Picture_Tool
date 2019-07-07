import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'about.dart';

bool is_save = false;

void main() {
  runApp(new MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyApp createState() => new _MyApp();
}

class _MyApp extends State<MyApp> {




  GlobalKey rootWidgetKey = GlobalKey();

  void showToast(String text) {
    Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
    );
  }

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary boundary =
          rootWidgetKey.currentContext.findRenderObject();
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      return pngBytes; //这个对象就是图片数据
    } catch (e) {
      print(e);
    }
    return null;
  }

  String _capturePath(name) {
    File dir = File("/sdcard/高斯模糊处理过的图片/");
    //在系统临时目录下创建两个目录一个文件
    var dir2 = new Directory(dir.path);
    dir2.createSync(recursive: true);

    String path = "/sdcard/高斯模糊处理过的图片/$name.png";
    return path;
  }

  @override
  Widget build(BuildContext context) {


    // TODO: implement build
    return new MaterialApp(
      routes: {
        "about": (BuildContext context) => new about(),
      },
      theme: ThemeData(primarySwatch: Colors.yellow),
      title: "图片处理",
      home: new Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: new Text("图片处理 - BlurTools"),
            actions: <Widget>[
              new PopupMenuButton(
                  onSelected: (String value) async {
                    switch (value) {
                      case "1":
                        var image = await ImagePicker.pickImage(
                            source: ImageSource.gallery);

                        setState(() {
                          image_path = image.path;
                          is_save = true;
                        });

                        break;
                      case "2":
                        /**
                       * 保存 布局图片到 相册
                       */

                        if (is_save) {
                          File file = File(_capturePath(
                              "blurs_${DateTime.now().millisecondsSinceEpoch}"));

                          List<int> dat = await _capturePng();
                          file.writeAsBytes(dat);
                          Fluttertoast.showToast(msg: "保存完成 - ${file.path}");

                        } else {
                          Fluttertoast.showToast(msg: "必须选择一张图片才能保存");
                        }


                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<String>>[
                        new PopupMenuItem(value: "1", child: new Text("选择图片")),
                        new PopupMenuItem(value: "2", child: new Text("保存图片")),
                      ])
            ],
          ),
          body: RepaintBoundary(
            key: rootWidgetKey,
            child: new HomeContext(),
          )),
    );
  }
}

String image_path = "";

class HomeContext extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Center(
      child: Stack(
        children: [
          Container(
              child: Center(
            child: Image.file(
              new File(image_path),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              fit: BoxFit.cover,
            ),
          )),
          BackdropFilter(
            filter: new ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: new Container(
              color: Colors.white.withOpacity(0.1),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
            ),
          ),
          Container(
              child: Center(
                  child: Text(
            "请单击右上角菜单选择图片",
            style: TextStyle(fontSize: 17.0),
          ))),
          Container(
              padding: EdgeInsets.all(50.0),
              child: Center(
                child: new Card(
                    elevation: 5.0, //设置阴影
                    child: Image.file(
                      new File(image_path),
                      fit: BoxFit.cover,
                    )),
              )),
        ],
      ),
    );
  }
}

class SelectImage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return MySelectImage();
  }
}

class MySelectImage extends State {
  List imgList = new List<File>();

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      imgList.add(image);
    });
  }

  dynamic getBody() {
    if (showLoadingDialog()) {
      return getProgressDialog();
    } else {
      return getListView();
    }
  }

  bool showLoadingDialog() {
    if (imgList.length == 0) {
      return true;
    }
    return false;
  }

  Center getProgressDialog() {
    return new Center(child: new CircularProgressIndicator());
  }

  ListView getListView() => new ListView.builder(
      itemCount: imgList.length,
      itemBuilder: (BuildContext context, int position) {
        return Image.file(imgList[position], height: 300);
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('选择一个图片'),
      ),
      body: getBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Pick Image',
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}
