import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:piu_animation/piu_loading_animation_widget.dart';

import 'piu_animation_widget.dart';

class PiuAnimation {
  static void addAnimation(
      GlobalKey rootGlobalKey, Widget piuWidget, Offset endOffset,
      {double maxWidth = 500,
      double minWidth = 90,
      int? millisecond,
      LoadingCallback? loadingCallback,
      Function? doSomethingBeginCallBack,
      Function? doSomethingFinishCallBack}) {
    Function? _finishCallBack;

    //创建浮层
    OverlayEntry _overlayEntry = OverlayEntry(builder: (context) {
      if (loadingCallback == null) {
        return PiuAnimationWidget(
          globalKey: rootGlobalKey,
          piuWidget: piuWidget,
          endOffset: endOffset,
          maxWidth: maxWidth,
          minWidth: minWidth,
          millisecond: millisecond ?? 2000,
          animationFinishCallBack: _finishCallBack,
          doSomethingBeginCallBack: doSomethingBeginCallBack,
          doSomethingFinishCallBack: doSomethingFinishCallBack,
        );
      } else {
        return PiuLoadingAnimationWidget(
          globalKey: rootGlobalKey,
          piuWidget: piuWidget,
          endOffset: endOffset,
          maxWidth: maxWidth,
          minWidth: minWidth,
          millisecond: millisecond ?? 2000,
          loadingCallback: loadingCallback,
          animationFinishCallBack: _finishCallBack,
          doSomethingBeginCallBack: doSomethingBeginCallBack,
          doSomethingFinishCallBack: doSomethingFinishCallBack,
        );
      }
    });

    //主页面插入浮层
    Overlay.of(rootGlobalKey.currentContext!)!.insert(_overlayEntry);

    _finishCallBack = (status) {
      if (status == AnimationStatus.completed) {
        _overlayEntry.remove();
      }
    };
  }

  static const MethodChannel _channel = MethodChannel('piu_animation');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
