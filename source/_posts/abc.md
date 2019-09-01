---
title: 简单基础
date: 2019-08-25 18:27:20
tags: "iOS基础"
categories: "iOS基础"
---

## json to dic , arr to json
```
json to dic
NSData *data = [@"json str" dataUsingEncoding:NSUTF8StringEncoding];
[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
arr to json
[NSJSONSerialization dataWithJSONObject:arr options:NSJSONWritingPrettyPrinted error:nil];

```
    
## 更改iOS状态栏颜色
```
UIView *statusBar = [[[UIApplication sharedApplication]valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
```

## 判断view是不是指定视图的子视图
```
[statusBar isDescendantOfView:view];
```
## 数字格式化
```
NSNumberFormatter *formater = [NSNumberFormatter new];
formater.numberStyle = NSNumberFormatterPercentStyle;
NSString *str = [formater stringFromNumber:@(45)];
```

## NSStirng 编解码
```
编码：
[@"" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet letterCharacterSet]];

解码：
[@"" stringByRemovingPercentEncoding];
```


## CATransaction使用场景，什么时候触发
CATransaction对象负责将一组动画组合成一个单元来管理，您也可以用它提供的方法来设置动画的持续时间。


## HTTPS
HTTPS和HTTP的区别主要为以下四点：
* https协议需要到ca申请证书(Certificate Authority）
* http是超文本传输协议，信息是明文传输，https 则是具有安全性的ssl加密传输协议
* http和https使用的是完全不同的连接方式，用的端口也不一样，前者是80，后者是443
* http的连接很简单，是无状态的；HTTPS协议是由SSL+HTTP协议构建的可进行加密传输、身份认证的网络协议，比http协议安全。
`SSL依靠证书来验证服务器的身份，并为浏览器和服务器之间的通信加密` 
 
## 性能优化  节省电量，流量
* 如何让你的应用程序更加省电？
答： (1). 如果程序用到定位，需要在定位完毕之后关闭定位，或者降低定位的频率，不停的定位会消耗电量。 (2). 如果用到了蓝牙，需要使用蓝牙时候开启蓝牙，蓝牙用完之后关闭蓝牙，蓝牙也很耗电。 (3). 优化算法，减少循环次数，大量循环会让CPU一直处于忙碌状态，特别费电。 (4). 尽量不要使用网络轮询（心跳包、定时器），使用推送。 (5). timer的时间间隔不宜太短，满足需求即可。 (6). 不要频繁刷新页面，能刷新1行cell的最好刷新一行，尽量不要reloadData。 (7). 线程适量，不宜过多。

* 简单描述一下你在开发的过程中，如何实现程序的性能优化？ 1）.避免庞大的XIB、Storyboard，尽量多用纯代码开发 2）.使用懒加载的方式延迟加载界面 3）.避免反复处理数据 4）.避免使用NSDateFormatter和NSCalendar。 5）.图片缓存的取舍

  
## 简述你对UIView、UIWindow和CALayer的理解
UIView,UIWindow和CALayer都有共同的基类NSObject,UIView继承于UIResponder,所以UIView可以响应用户事件,CALayer是继承于NSObject所以不可以响应用户事件.UIView侧重于对内容的管理,CALayer侧重于对内容的绘制.
UIWindow是特殊的UIView,通常一个app只有一个UIWindow,我们可以创建一个视图控制器,然后将这个视图控制器添加到UIWindow上面

## 为什么delegate属性都是assign而不是strong？为什么block属性都是copy而不是strong？
delegate防止循环引用问题。默认情况下，block是存档在栈中，可能被随时回收,进行一次copy操作，就可以放在堆中了。用retain没有用的原因：retain只是增加一次计数，block内存还是在栈中，并没有转移到堆中

## 简述NotificationCenter、KVC、KVO、Delegate、Block？并说明它们之间的区别?

```kvo只能用来对属性作出反应，而不会用来对方法或者动作作出反应，是实现一个对象与另外一个对象保持同步的一种方法，能够提供观察的属性的最新值以及先前值，同时它是一种响应式编程思想，也就是开发中不需要考虑调用顺序，只需要知道考虑结果，类似于蝴蝶效应，产生一个事件，会影响很多东西，最后影响结果，比如开发中用KVO来监听一个dog类的name属性有没有改变，不需要知道是在哪里做了修改，只要是修改了就收监听到结果。而kvo的底层其实是重写了name属性的set方法，而能够用外界修改name的时候调用set方法就是修改了当前对象的一个isa指针来实现的。它有点类似于swift中的存储型属性中的didSet方法的监听。
 
KVC其实就是键值编码，对象在调用setValue的时候，首先会去找属性的set方法—>成员属性——>直接找对象的这个属性—>报错，比如在字典转模型的时候这个方法就经常会用到，而这里有个坑就是当模型中的属性和字典的key不一一对应，系统就会调用setValue:forUndefinedKey:报错。所以一般我们会重写这个方法防止报错。
 
block 是一种数据类型，我在开发中主要使用在3个场景：1，它作为一个代码块保存在对象中，需要的去调用就可以，在传值的时候用的特别多。2.作为方法的参数，它的实现由外部来决定，这样方法用起来就比较灵活了。3.作为方法的返回值，它的目的就是代替方法，在这个block作为返回值里可以进行很多的操作，外部调用这个方法的时候只需要知道传入的参数是什么就可以，不用知道内部是怎么实现的。实际开发中需要注意的是它的循环引用的问题，block 是 C 的，一般在ARC使用strong,MRC使用copy。
 
代理其实一般是控制器定义的一个协议，当控制器或某个对象遵循了这个协议，并实现了代理方法，就可以通过代理方法来完成不同对象的一些操作或数据传递了。代理有严格的语法，能够实现的方法必须有明确的声明。还有就是代理是一对一的，在一个应用中的控制流程是可以追踪的，而由于通知是可以实现多对多，是很难追踪到的，这点在做调试的时候代理检测起来就比通知好多了，在项目中，代理在控制器值的逆传这块是用得比较多，而且也是比较好用的，做一些简单的回调。比如我在底层界面的功能完成了，需要把一些值传到上一层去，这时候用代理就是比较直接高效了。
 
Notification: 是一种观察者模式，通知的实现比代理要简单得多，而且它是多对多的。通知一般在开发中除了需要监听一些系统的响应，如键盘弹出等，就是用在比如开发模块之间联系不怎么紧密而又需要传值，还有就是多线程之间传值的情况，这时候用通知就比代理来得直接简单了。但使用通知的时候一定要记得在释放对象的时候将通知注销掉，避免出现野指针的现象。
```

 9、 什么是沙盒（sandbox）？沙盒包含哪些文件，描述每个文件的使用场景。如何获取这些文件的路径？如何获取应用程序包中文件的路径？
```
沙盒是指你安装的应用程序只能在该程序所创建的文件系统区域中读取数据，不能去其他地方访问，此区域叫做沙盒.
沙盒路径下的目录：
	Library目录：此目录下主要有两个目录Caches和Preferences：
 1:Documents：应用中用户数据可以放在这里，iTunes备份和恢复的时候会包括此目录 ，iOS 5.0.1以后版本可以设置某些文件不备份， [fileURL setResourceValue:[NSNumber numberWithBool:YES] forKey:NSURLIsExcludedFromBackupKey error:nil]
 2:tmp：存放临时文件，iTunes不会备份和恢复此目录，此目录下文件可能会在应用退出后删除 
 3:Library/Caches：存放缓存文件，iTunes不会备份此目录，此目录下文件不会在应用退出删除
（1）、获取document目录
参数介绍：第一个参数为指向document目录下，第二个参数是在当前程序的沙盒下，第三个参数为是否展开波浪线
NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
（2）、获取cache目录
NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
（3）、获取tmp目录路径的方法：
NSString *tmpDir = NSTemporaryDirectory();
（4）、通过打印前往文件路径来实现：NSHomeDirectory()。
```
 
## initWithCoder 详解

```
大前提是UIViewController有一个UIView.在XCode中 创建一个类和实例化一个类很容易区分,但是在IB(Interface Builder)中有时候就会迷糊.其实也很好区分,孤零零地创建了一个nib文件,没有和其他可被实例化的类有直接或间接关系的时候,这个类或这些类 (一个nib文件俺也可能包含多个类)是没有机会被实例化的,所以这种情况只是通过ib创建了一个类,而没有实例化.真正的实例化还需要通过在Xcode 用代码来读取这个nib文件.知道这两这的区别后这些方法也就容易辨认多了

viewDidLoad其实没什么可混淆的,无论通过什么途径加载完view后肯定会执行这个方法.

loadView需要分两种情况.当你通过Xcode实例化一个类的时候就需要自己在controller中实现这个方法.而在IB中实例化就不需要实现它.

initWithNibName这个方法是在controller的类在IB中创建,通过Xcode实例化controller的时候用的.

awakeFromNib这个方法是一个类在IB中被实例化是被调用的.看了帖子发现大家都推荐使用viewDidLoad而不要使用 awakeFromNib,应为viewDidLoad会被多次调用,而awakeFromNib只会当从nib文件中unarchive的时候才会被调 用一次.实际测试中发现,当一个类的awakeFromNib被调用的时候,那么这个类的viewDidLoad就不会被调用了,这个感觉很奇怪.

initWithCoder是一个类在IB中创建但在xocdde中被实例化时被调用的.比如,通过IB创建一个controller的nib文件,然后在xocde中通过initWithNibName来实例化这个controller,那么这个controller的initWithCoder会被调用.

如果你的对象是UIViewControler的子类，那么你必须调用- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil;方法去调用NIB文件初始化自身，即使那没有使用nib文件也会调用这个函数（默认 情况下init方法已经为你的做这件事情了），如果你调用这个方法，并传递的两个参数为空（nil），然后类会调用-loadView去读取一个名字和你 的UIViewController名字相同的nib文件，来初始化自身。如果没有这样的nib文件，你必须调用-setView:来设置一个 self.view。或者重载-loadView 方法
```

## iOS不同版本的差异简单总结
1. openurl：方法9.0升级application：openurl：
2. remoteNotificationTypes 参数配置接口不同
3. 网络请求用的NSURLConnection换成了NSURLSessionTask
4. uiwebview升级为wkwebview
5. uialertview，uiactionsheet等用uialertcontroller替换
6. iOS程序在后台运行10分钟编程了3分钟

## iOS性能优化方面：
1，能重用的就重用，reuseIdentifier
2，使用缩小后的大图片文件
3，使用cache

## UIView设置部分圆角
```CGRect rect = view.bounds;
CGSize radio = CGSizeMake(30, 30);//圆角尺寸
UIRectCorner corner = UIRectCornerTopLeft|UIRectCornerTopRight;//这只圆角位置
UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corner cornerRadii:radio];
CAShapeLayer *masklayer = [[CAShapeLayer alloc]init];//创建shapelayer
masklayer.frame = view.bounds;
masklayer.path = path.CGPath;//设置路径
view.layer.mask = masklayer;
```

## 图片上绘制文字 写一个UIImage的category

```- (UIImage *)imageWithTitle:(NSString *)title fontSize:(CGFloat)fontSize
{
    //画布大小
    CGSize size=CGSizeMake(self.size.width,self.size.height);
    //创建一个基于位图的上下文
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);//opaque:NO  scale:0.0
    
    [self drawAtPoint:CGPointMake(0.0,0.0)];
    
    //文字居中显示在画布上
    NSMutableParagraphStyle* paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment=NSTextAlignmentCenter;//文字居中
    
    //计算文字所占的size,文字居中显示在画布上
    CGSize sizeText=[title boundingRectWithSize:self.size options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}context:nil].size;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    
    CGRect rect = CGRectMake((width-sizeText.width)/2, (height-sizeText.height)/2, sizeText.width, sizeText.height);
    //绘制文字
    [title drawInRect:rect withAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize:fontSize],NSForegroundColorAttributeName:[ UIColor whiteColor],NSParagraphStyleAttributeName:paragraphStyle}];
    
    //返回绘制的新图形
    UIImage *newImage= UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
```


## UIView的setNeedsLayout, layoutIfNeeded 和 layoutSubviews 方法之间的关系解释
```
layoutSubviews总结

ios layout机制相关方法
- (CGSize)sizeThatFits:(CGSize)size
- (void)sizeToFit
——————-

- (void)layoutSubviews
- (void)layoutIfNeeded
- (void)setNeedsLayout
——————–

- (void)setNeedsDisplay
- (void)drawRect

layoutSubviews在以下情况下会被调用：

1、当View addSubview及被addSubview都会触发（layoutSubviews）
2、addSubview之后init初始化不会触发，initWithFrame当rect的值不为CGRectZero时会触发会触发
3、改变view的Frame会触发，子视图改变会先触发父类的然后自己的，父视图改变只触发父视图的
4、滚动一个UIScrollView会触发ScrollView的layoutSubviews
5、旋转Screen会触发所有view的layoutSubviews

-layoutSubviews方法：这个方法，默认没有做任何事情，需要子类进行重写
-setNeedsLayout方法： 标记为需要重新布局，异步调用layoutSubviews刷新布局
-layoutIfNeeded方法：如果有需要刷新的标记，立即调用layoutSubviews进行布局（如果没有标记，不会调用layoutSubviews）

如果要立即刷新，要先调用[view setNeedsLayout]，把标记设为需要布局，然后马上调用[view layoutIfNeeded]，实现布局
在视图第一次显示之前，标记总是“需要刷新”的，可以直接调用[view layoutIfNeeded]

重绘

-drawRect:(CGRect)rect方法：重写此方法，执行重绘任务
-setNeedsDisplay方法：标记为需要重绘，异步调用drawRect
-setNeedsDisplayInRect:(CGRect)invalidRect方法：标记为需要局部重绘

sizeToFit会自动调用sizeThatFits方法；
sizeToFit不应该在子类中被重写，应该重写sizeThatFits
sizeThatFits传入的参数是receiver当前的size，返回一个适合的size
sizeToFit可以被手动直接调用
sizeToFit和sizeThatFits方法都没有递归，对subviews也不负责，只负责自己

———————————-

layoutSubviews对subviews重新布局
layoutSubviews方法调用先于drawRect
setNeedsLayout在receiver标上一个需要被重新布局的标记，在系统runloop的下一个周期自动调用layoutSubviews
layoutIfNeeded方法如其名，UIKit会判断该receiver是否需要layout.根据Apple官方文档,layoutIfNeeded方法应该是这样的

layoutIfNeeded遍历的不是superview链，应该是subviews链

drawRect是对receiver的重绘，能获得context

setNeedDisplay在receiver标上一个需要被重新绘图的标记，在下一个draw周期自动重绘，iphone device的刷新频率是60hz，也就是1/60秒后重绘 

```

## 整体视图动画
`The key path is relative to the layer the receiver is`
UIView的类方法实现的动画，无法实现改变父视图自动改变子视图。masonry控制constrants，CAKeyframeAnimation控制父视图动画，可以同时适配子视图
```
CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 5;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1f, 0.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 1.0f)]];
    popAnimation.keyTimes = @[@0.2f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.contentView.layer addAnimation:popAnimation forKey:nil];
```
画个曲线跑一圈
```- (void)drawSpaceCurve
{
    UIBezierPath *bezierPath = [[UIBezierPath alloc]init];
    [bezierPath moveToPoint:CGPointMake(0, 150)];
    [bezierPath addCurveToPoint:CGPointMake(300, 150)
                  controlPoint1:CGPointMake(75, 0)
                  controlPoint2:CGPointMake(225, 300)];
    
    
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    pathLayer.path = [bezierPath CGPath];
    pathLayer.fillColor = [[UIColor blackColor] CGColor];
    pathLayer.strokeColor = [[UIColor redColor]CGColor];
    pathLayer.lineWidth   = 3;
   // pathLayer.contents = (__bridge id)[UIImage imageNamed:@"Ship"].CGImage;
    [self.view.layer addSublayer:pathLayer];
    
    CALayer *layer = [CALayer layer];
    layer.position = CGPointMake(0, 150);
    layer.frame = CGRectMake(0, 0, 64, 64);
    layer.backgroundColor = [[UIColor greenColor] CGColor];
    [self.view.layer addSublayer:layer];
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.duration = 4;
    animation.path = bezierPath.CGPath;
    animation.rotationMode = kCAAnimationRotateAuto;
    [layer addAnimation:animation forKey:nil];
}
```

## 为什么刷新UI只能在主线程？
总答：在子线程中无法获取到当前的图形上下文
分答：线程同步开销问题，GUI操作非常复杂，子线程也能操作的话就需要锁操作，性能大大降低。
子线程操作UI为什么不崩溃而且刷新成功：1，幻像，实际是在主线程刷新UI  2，子线程在创建的时候获取了当前的图形上下文。如按钮事件换标题、换背景图。

## volatile 是什么含义，给出三个不同例子
```
含义：当使用volatile声明变量值的时候，系统总是重新从它所在的内存读取数据
            意味着该变量不会被编译器优化，寄存器副本值失效。
例子：1、对全局变量，在不同代码块中异步修改的时候，需要用volatile修饰。
            2、多线程环境下各线程间共享的标志应该加volatile修饰。
            3、存储器映射的硬件寄存器通常也要加voliate，因为每次对它的读写都可能有不同意义。
```


## 网络基础知识
1. 网络由下往上分为物理层、数据链路层、网络层、传输层、会话层、表示层和应用层
2. IP属于网络层、TCP&UDP属于传输层、HTTP是应用层、Socket本身并不是协议，而是一个调用接口（API），是对TCP&UDP/IP协议的封装和应用。通过Socket，我们才能使用TCP/IP协议
3. TCP是面向链接的可靠传输并且保证数据顺序，三次握手连接，四次握手断开
4. UDP非连接的协议不可靠传输并且不保证数据顺序，传输效率高
5. 短连接：连接->传输数据->关闭连接，HTTP是无状态的，SOCKET连接发送后接收完数据马上断开连接。HTTP也可以建立长连接，使用Connection:keep-alive
6. 长连接：连接->传输数据->保持连接 -> 传输数据-> 。。。 ->关闭连接。长连接指建立SOCKET连接后不管是否使用都保持连接

#### GET & POST的区别
1. Get是用来从服务器上获得数据，而Post是用来向服务器上传递数据
2. Get是不安全的，Post的所有操作对用户来说都是不可见的
3. Get传输的数据量小，这主要是因为受URL长度限制；而Post可以传输大量的数据，所以在上传文件只能使用Post
4. Get限制数据集的值必须为ASCII字符,POST没有此限制



