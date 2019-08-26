---
title: Runloop是什么？使用Runloop的目的是什么？注意内容
date: 2019-08-25 18:15:41
tags:
---

 ## Runloop是什么？使用Runloop的目的是什么？注意内容
[线程runloop网络资源](http://www.jianshu.com/p/d260d18dd551)

* Runloop是事件接收和分发机制的一个实现
* 主要目的：保证程序执行的线程不会被系统终止，runloop对象在循环中处理程序运行过程中出现的各种事件，从而保持程序的持续运行；为节省cpu资源会在没有事件处理的时候进入睡眠模式。

* 注意事项：应用不能创建和显示的管理Runloop对象

#### runloop跟线程的关系、何时创建、何时销毁
* 每条线程都有唯一一个与之对应的RunLoop对象
* 只能在当前线程操作当前线程的RunLoop
* RunLoop对象在第一次获取RunLoop时创建，销毁则是在线程结束的时候。
* 主线程的RunLoop对象系统自动帮助我们创建好了，而子线程的RunLoop对象需要我们主动创建。
  	
  	* Core Foundation框架下关于RunLoop的5个类
	 1.	CFRunLoopRef：代表RunLoop的对象
	 2.	CFRunLoopModeRef：RunLoop的运行模式
	 3.	CFRunLoopSourceRef：就是RunLoop模型图中提到的输入源/事件源
	 4.	CFRunLoopTimerRef：就是RunLoop模型图中提到的定时源
	 5.	CFRunLoopObserverRef：观察者，能够监听RunLoop的状态改变

 	* runloop的几种Mode
      1. kCFRunLoopDefaultMode：App的默认运行模式，通常主线程是在这个运行模式下运行
	  2. UITrackingRunLoopMode：跟踪用户交互事件（用于 ScrollView 追踪触摸滑动，保证界面滑动时不受其他Mode影响）
	  3. UIInitializationRunLoopMode：在刚启动App时第进入的第一个 Mode，启动完成后就不再使用
	  4. GSEventReceiveRunLoopMode：接受系统内部事件，通常用不到
	  5. kCFRunLoopCommonModes：伪模式，不是一种真正的运行模式（后边会用到）
  