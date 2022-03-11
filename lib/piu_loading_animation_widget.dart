import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

//动画类型
enum PiuAnimationState {
  scaleAnimation, //前置缩放状态
  loadingAnimation, //loading状态
  finishAnimation //结束动画状态
}

//loading回调
typedef LoadingCallback = Future<bool> Function();

class PiuLoadingAnimationWidget extends StatefulWidget {
  const PiuLoadingAnimationWidget(
      {Key? key,
      required this.globalKey,
      required this.piuWidget,
      required this.endOffset,
      required this.maxWidth,
      required this.minWidth,
      required this.millisecond,
      required this.loadingCallback,
      required this.animationFinishCallBack,
      this.doSomethingBeginCallBack,
      this.doSomethingFinishCallBack})
      : super(key: key);

  //主页面GlobalKey
  final GlobalKey globalKey;

  //piu动画widget
  final Widget piuWidget;

  //终点位置
  final Offset endOffset;

  //初始最大宽度
  final double maxWidth;

  //悬停最小宽度
  final double minWidth;

  //动画时长
  final int millisecond;

  //异步回调
  final LoadingCallback loadingCallback;

  //动画结束回调
  final Function? animationFinishCallBack;

  //动画开始事件回调
  final Function? doSomethingBeginCallBack;

  //动画结束时间回调
  final Function? doSomethingFinishCallBack;

  @override
  State<PiuLoadingAnimationWidget> createState() =>
      _PiuLoadingAnimationWidgetState();
}

class _PiuLoadingAnimationWidgetState extends State<PiuLoadingAnimationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleAnimationController;
  late AnimationController _loadingAnimationController;
  late AnimationController _finishAnimationController;

  late Animation<double> _scaleAnimation; //前置缩放动画
  late Animation<double> _scaleMinAnimation; //后置缩放动画
  late Animation<double> _alphaAnimation; //渐变动画
  late Animation<double> _rotationZAngleAnimation; //翻转动画
  late Animation<double> _loadingRotationZAngleAnimation; //旋转动画
  Animation<double>? _pathAnimation; //piu移动路径动画（贝塞尔曲线）

  //初始化当前动画状态
  PiuAnimationState _piuState = PiuAnimationState.scaleAnimation;

  double _left = 0;
  double _top = 0;
  PathMetric? _metric;
  double _pathListLength = 0;
  bool _loadingFutureFinish = false; //异步任务是否执行结束
  bool _loadingSuccess = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final Future<bool> loadingResult = widget.loadingCallback();
    loadingResult.then((bool success) {
      // print("loading value = $success");
      _loadingFutureFinish = true;
      _loadingSuccess = success;
      if (!_loadingAnimationController.isCompleted) {
        _loadingAnimationController.stop();
      }
      if (_loadingSuccess) {
        //异步任务完成
        //缩放动画执行结束，执行结束动画
        if (_scaleAnimationController.isCompleted) {
          _piuState = PiuAnimationState.finishAnimation;
          _finishAnimationController.forward();
        }
      } else {
        //异步任务失败，执行缩放反向动画
        if (_scaleAnimationController.isCompleted) {
          _piuState = PiuAnimationState.scaleAnimation;
          _scaleAnimationController.reverse();
        }
      }
    });

    //曲线动画
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      Size size = MediaQuery.of(context).size;
      initBezierPathList(Offset((size.width - widget.minWidth) / 2,
          (size.height - widget.minWidth) / 2));
      // print("~~~~~~~~`size = $size");

      _pathAnimation = Tween<double>(begin: 0.0, end: _pathListLength).animate(
        CurvedAnimation(
          parent: _finishAnimationController,
          curve: const Interval(
            0,
            1,
            curve: Curves.easeOutExpo,
          ),
        ),
      );
    });

    //前置缩放动画
    _scaleAnimationController = AnimationController(
      duration: Duration(milliseconds: (widget.millisecond * 0.4).toInt()),
      vsync: this,
    )
      ..addStatusListener((status) {
        // print("scaleAnimation status = $status");
        if (status == AnimationStatus.forward) {
          if (!_loadingFutureFinish) {
            //前置动画启动
            if (widget.doSomethingBeginCallBack != null) {
              widget.doSomethingBeginCallBack!();
            }
          }
        } else if (status == AnimationStatus.completed) {
          if (_loadingFutureFinish && _loadingSuccess) {
            //异步任务返回值为true,执行结束动画
            _piuState = PiuAnimationState.finishAnimation;
            _finishAnimationController.forward();
          } else if (_loadingFutureFinish &&
              _piuState == PiuAnimationState.finishAnimation) {
            //缩放动画还未执行完毕，待缩放动画结束后，直接执行结束动画
            _finishAnimationController.forward();
          } else if (!_loadingFutureFinish) {
            //前置动画结束，启动loading动画
            _piuState = PiuAnimationState.loadingAnimation;
            _loadingAnimationController.repeat();
          } else {
            _scaleAnimationController.reverse();
          }
        } else if (status == AnimationStatus.dismissed) {
          if (!_loadingSuccess) {
            //异步任务返回值为false,执行反向缩放动画，并回调
            if (widget.animationFinishCallBack != null) {
              widget.animationFinishCallBack!(AnimationStatus.completed);
            }
            if (widget.doSomethingFinishCallBack != null) {
              widget.doSomethingFinishCallBack!(false);
            }
          }
        }
      })
      ..addListener(() {
        setState(() {});
      })
      ..forward();

    //loading动画
    _loadingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..addListener(() {
        setState(() {});
      });

    //结束动画
    _finishAnimationController = AnimationController(
      duration: Duration(milliseconds: (widget.millisecond * 0.6).toInt()),
      vsync: this,
    )
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (widget.animationFinishCallBack != null) {
            widget.animationFinishCallBack!(status);
          }
          if (widget.doSomethingFinishCallBack != null) {
            widget.doSomethingFinishCallBack!(true);
          }
        }
      })
      ..addListener(() {
        setState(() {});
      });

    //前置缩放动画
    _scaleAnimation =
        Tween<double>(begin: widget.maxWidth, end: widget.minWidth).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: const Interval(
          0,
          1,
          curve: Curves.easeOutExpo,
        ),
      ),
    );

    _scaleMinAnimation = Tween<double>(begin: widget.minWidth, end: 0).animate(
      CurvedAnimation(
        parent: _finishAnimationController,
        curve: const Interval(
          0,
          1,
          curve: Curves.easeOutExpo,
        ),
      ),
    );

    _alphaAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: const Interval(
          0,
          1,
          curve: Curves.easeOutExpo,
        ),
      ),
    );

    _rotationZAngleAnimation = Tween<double>(begin: 180, end: 0).animate(
      CurvedAnimation(
        parent: _scaleAnimationController,
        curve: const Interval(
          0,
          1,
          curve: Curves.linearToEaseOut,
        ),
      ),
    );

    _loadingRotationZAngleAnimation = Tween<double>(begin: 360, end: 0).animate(
      CurvedAnimation(
        parent: _loadingAnimationController,
        curve: const Interval(
          0,
          1,
          curve: Curves.linearToEaseOut,
        ),
      ),
    );
  }

  //初始化曲线路径及长度
  initBezierPathList(Offset startOffset) {
    Path path = getPath(startOffset, widget.endOffset);
    PathMetrics pathMetrics = path.computeMetrics();
    _metric = pathMetrics.elementAt(0);
    _pathListLength = _metric!.length;
  }

  //路径
  Path getPath(Offset start, Offset end) {
    // print("start dx = ${start.dx}  end dx = ${end.dx}");
    double centerPointX = start.dx > end.dx ? start.dx : end.dx;
    double centerPointY = start.dy > end.dy ? start.dy : end.dy;
    Path path = Path();
    path.moveTo(start.dx, start.dy);
    path.quadraticBezierTo(centerPointX / 2, centerPointY / 2, end.dx, end.dy);
    return path;
  }

  @override
  Widget build(BuildContext context) {
    // print("animation value = ${_scaleAnimation.value}");

    double dx = 0;
    double dy = 0;

    switch (_piuState) {
      case PiuAnimationState.scaleAnimation:
        // TODO: Handle this case.
        _left = (MediaQuery.of(context).size.width - _scaleAnimation.value) / 2;
        _top = (MediaQuery.of(context).size.height - _scaleAnimation.value) / 2;
        break;
      case PiuAnimationState.loadingAnimation:
        // TODO: Handle this case.
        _left = (MediaQuery.of(context).size.width - widget.minWidth) / 2;
        _top = (MediaQuery.of(context).size.height - widget.minWidth) / 2;
        break;
      case PiuAnimationState.finishAnimation:
        // TODO: Handle this case.
        if (_metric != null) {
          Tangent? t = _metric!.getTangentForOffset(_pathAnimation!.value);
          dx = t!.position.dx;
          dy = t.position.dy;
          // print("Tangent dx= ${t.position.dx}  dy = ${t.position.dy}");
        }
        break;
    }

    switch (_piuState) {
      case PiuAnimationState.scaleAnimation:
        // TODO: Handle this case.
        return _scaleAnimationBuilder();
      case PiuAnimationState.loadingAnimation:
        // TODO: Handle this case.
        return _loadingAnimationBuilder();
      case PiuAnimationState.finishAnimation:
        // TODO: Handle this case.
        return _finishAnimationBuilder(dx, dy);
    }
  }

  Widget _scaleAnimationBuilder() {
    return AnimatedBuilder(
      animation: _scaleAnimationController,
      builder: (context, child) {
        return Positioned(
          left: _left,
          top: _top,
          width: _scaleAnimation.value > widget.minWidth
              ? _scaleAnimation.value
              : _scaleMinAnimation.value,
          height: _scaleAnimation.value > widget.minWidth
              ? _scaleAnimation.value
              : _scaleMinAnimation.value,
          child: Container(
            // transform:
            // Matrix4.rotationY(_rotationZAngleAnimation.value * pi / 180),
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) //翻转深度效果
              ..rotateY(_rotationZAngleAnimation.value * pi / 180),
            //翻转弧度
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              // color: Colors.red,
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.minWidth / 2)),
            ),
            clipBehavior: Clip.hardEdge,
            child: Opacity(
              opacity: _alphaAnimation.value,
              child: widget.piuWidget,
            ),
          ),
        );
      },
    );
  }

  Widget _loadingAnimationBuilder() {
    return AnimatedBuilder(
      animation: _loadingAnimationController,
      builder: (context, child) {
        return Positioned(
          left: _left,
          top: _top,
          width: widget.minWidth,
          height: widget.minWidth,
          child: Container(
            // transform:
            // Matrix4.rotationY(_rotationZAngleAnimation.value * pi / 180),
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) //翻转深度效果
              ..rotateY(_loadingRotationZAngleAnimation.value * pi / 180),
            //翻转弧度
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              // color: Colors.red,
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.minWidth / 2)),
            ),
            clipBehavior: Clip.hardEdge,
            child: widget.piuWidget,
          ),
        );
      },
    );
  }

  Widget _finishAnimationBuilder(double dx, double dy) {
    return AnimatedBuilder(
      animation: _finishAnimationController,
      builder: (context, child) {
        return Positioned(
          left: dx,
          top: dy,
          width: _scaleMinAnimation.value,
          height: _scaleMinAnimation.value,
          child: Container(
            //翻转弧度
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              // color: Colors.red,
              borderRadius:
                  BorderRadius.all(Radius.circular(widget.minWidth / 2)),
            ),
            clipBehavior: Clip.hardEdge,
            child: widget.piuWidget,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scaleAnimationController.dispose();
    _loadingAnimationController.dispose();
    _finishAnimationController.dispose();
  }
}
