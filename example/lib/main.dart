import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:piu_animation/piu_animation.dart';
import 'package:piu_animation/piu_loading_animation_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PiuAnimation'),
        ),
        body: const PiuAnimationDemo(),
      ),
    );
  }
}

class PiuAnimationDemo extends StatefulWidget {
  const PiuAnimationDemo({Key? key}) : super(key: key);

  @override
  State<PiuAnimationDemo> createState() => _PiuAnimationDemoState();
}

class _PiuAnimationDemoState extends State<PiuAnimationDemo> {
  GlobalKey rootKey = GlobalKey();

  GlobalKey topLeftKey = GlobalKey();
  GlobalKey topCenterKey = GlobalKey();
  GlobalKey topRightKey = GlobalKey();
  GlobalKey centerLeftKey = GlobalKey();
  GlobalKey centerKey = GlobalKey();
  GlobalKey centerRightKey = GlobalKey();
  GlobalKey bottomLeftKey = GlobalKey();
  GlobalKey bottomCenterKey = GlobalKey();
  GlobalKey bottomRightKey = GlobalKey();

  GlobalKey loadingTrueKey = GlobalKey();
  GlobalKey loadingFalseKey = GlobalKey();

  GlobalKey floatingKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        key: rootKey,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  key: topLeftKey,
                  onPressed: () {
                    addCart(topLeftKey);
                  },
                  child: const Text("TopLeft"),
                ),
                ElevatedButton(
                  key: topCenterKey,
                  onPressed: () {
                    addCart(topCenterKey);
                  },
                  child: const Text("TopCenter"),
                ),
                ElevatedButton(
                  key: topRightKey,
                  onPressed: () {
                    addCart(topRightKey);
                  },
                  child: const Text("TopRight"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  key: centerLeftKey,
                  onPressed: () {
                    addCart(centerLeftKey);
                  },
                  child: const Text("CenterLeft"),
                ),
                ElevatedButton(
                  key: centerKey,
                  onPressed: () {
                    addCart(centerKey);
                  },
                  child: const Text("Center"),
                ),
                ElevatedButton(
                  key: centerRightKey,
                  onPressed: () {
                    addCart(centerRightKey);
                  },
                  child: const Text("CenterRight"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  key: loadingTrueKey,
                  onPressed: () {
                    addCart(loadingTrueKey,loadingCallBack: loadingSuccessFunction);
                  },
                  child: const Text("LoadingTrue"),
                ),
                ElevatedButton(
                  key: loadingFalseKey,
                  onPressed: () {
                    addCart(loadingFalseKey,loadingCallBack: loadingFieldFunction);
                  },
                  child: const Text("LoadingFalse"),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  key: bottomLeftKey,
                  onPressed: () {
                    addCart(bottomLeftKey);
                  },
                  child: const Text("BottomLeft"),
                ),
                ElevatedButton(
                  key: bottomCenterKey,
                  onPressed: () {
                    addCart(bottomCenterKey);
                  },
                  child: const Text("BottomCenter"),
                ),
                ElevatedButton(
                  key: bottomRightKey,
                  onPressed: () {
                    addCart(bottomRightKey);
                  },
                  child: const Text("BottomRight"),
                ),
              ],
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: floatingKey,
        onPressed: () {
          addCart(floatingKey);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  //任务成功
  Future<bool> loadingSuccessFunction() {
    return Future.delayed(const Duration(milliseconds: 2000),(){
      return true;
    });
  }

  //任务失败
  Future<bool> loadingFieldFunction() {
    return Future.delayed(const Duration(milliseconds: 2000),(){
      return false;
    });
  }

  void addCart(GlobalKey key, {LoadingCallback? loadingCallBack}) {
    //显示的widget
    Widget piuWidget = Container(
      color: Colors.redAccent,
      child: const FlutterLogo(),
    );

    //动画终点坐标
    RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    var offset = box.localToGlobal(Offset.zero);
    Offset endOffset =
        Offset(offset.dx + box.size.width / 2, offset.dy + box.size.height / 2);

    PiuAnimation.addAnimation(rootKey, piuWidget, endOffset,
        maxWidth: MediaQuery.of(context).size.width,
        loadingCallback: loadingCallBack,
        doSomethingBeginCallBack: () {
      print("动画开始");
    }, doSomethingFinishCallBack: (success) {
      if(success){
        print("loading 成功 动画结束");
      }else{
        print("loading 失败 动画结束");
      }
    });
  }
}
