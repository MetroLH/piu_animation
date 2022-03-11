# 类似加入购物车动画【PiuAnimation】

PiuAnimation，piu~~~的一下，可用作加入购物车、保存截屏等动画特效

## Look

![MacDown Screenshot](https://github.com/MetroLH/piu_animation/blob/main/screenshot/Simulator%20Screen%20Recording%20-%20iPhone%2013%20Pro%20-%202022-03-10%20at%2013.45.04.gif?raw=true)

## 无用功能第一弹：

### 悬停动画一【异步任务返回true】：

![MacDown Screenshot](https://github.com/MetroLH/piu_animation/blob/main/screenshot/loading_true.gif?raw=true)

### 悬停动画er【异步任务返回false】：

![MacDown Screenshot](https://github.com/MetroLH/piu_animation/blob/main/screenshot/loading_false.gif?raw=true)

### 添加方法【第一种，普通的缩放piu动画】

```java
PiuAnimation.addAnimation(
        rootKey,   //主Widget GlobalKey
        piuWidget, //Child
        endOffset, //终点坐标
        maxWidth:MediaQuery.of(context).size.width, //Child最大宽度
        doSomethingBeginCallBack:(){ //动画开始回调
            print("动画开始");
        },
        doSomethingFinishCallBack:(){ //动画结束回调
            print("动画结束");
        });
//其中还有动画时长、悬停最小宽度等属性设置
```

### 添加方法【第er种，悬停loading动画】

```java
PiuAnimation.addAnimation(rootKey,piuWidget,endOffset,
        maxWidth:MediaQuery.of(context).size.width,
        loadingCallback:loadingCallBack,
        doSomethingBeginCallBack:(){
            print("动画开始");
        },doSomethingFinishCallBack:(success){
            if(success){
                print("loading 成功 动画结束");
            }else{
                print("loading 失败 动画结束");
            }
        });

//异步方法定义，demo先通过delayed使用，正常业务逻辑中可以通过接口回调控制true和false
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

```

### 使用方式详见main.dart

```
//通过GlobalKey获取终点坐标，及大小等
//demo终点坐标为按钮的中心点
RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
    var offset = box.localToGlobal(Offset.zero);
    Offset endOffset =
        Offset(offset.dx + box.size.width / 2, offset.dy + box.size.height / 2);
```

GitHub地址: [GitHub](https://github.com/MetroLH/piu_animation)

