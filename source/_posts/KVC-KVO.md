---
title: KVC & KVO 详解
date: 2019-08-25 18:25:20
tags:
---


## KVC & KVO 详解

### KVC概述

* KVC是Key Value Coding的简称。它是一种可以通过字符串的名字（key）来访问类属性的机制。而不是通过调用Setter、Getter方法访问。
* 关键方法定义在 NSKeyValueCodingProtocol
* KVC支持类对象和内建基本数据类型。

### KVO概述
`键值观察Key-Value-Observer就是观察者模式。`
* 观察者模式的定义：一个目标对象管理所有依赖于它的观察者对象，并在它自身的状态改变时主动通知观察者对象。这个主动通知通常是通过调用各观察者对象所提供的接口方法来实现的。观察者模式较完美地将目标对象与观察者对象解耦。
* 当需要检测其他类的属性值变化，但又不想被观察的类知道，有点像FBI监视嫌疑人，这个时候就可以使用KVO了。KVO同KVC一样都依赖于Runtime的动态机制
* KVO实现步骤
  
1. 注册
	```
	//keyPath就是要观察的属性值
	//options给你观察键值变化的选择
	//context方便传输你需要的数据
	-(void)addObserver:(NSObject *)anObserver 
	        forKeyPath:(NSString *)keyPath 
	           options:(NSKeyValueObservingOptions)options 
	           context:(void *)context
	```
 2. 实现方法
	```
//change里存储了一些变化的数据，比如变化前的数据，变化后的数据；如果注册时context不为空，这里context就能接收到。
-(void)observeValueForKeyPath:(NSString *)keyPath 
                     ofObject:(id)object
                       change:(NSDictionary *)change 
                      context:(void *)context
	```
 3. 移除
	```
		- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;
	```
`
KVO的实现分析
KVO的实现用了所谓的“isa-swizzling”的技术
系统实现KVO有以下几个步骤：
	•	当类A的对象第一次被观察的时候，系统会在运行期动态创建类A的子类。我们称为B。
	•	在派生类B中重写类A的setter方法，B类在被重写的setter方法中实现通知机制。
	•	类B重写会 class方法，将自己伪装成类A。类B还会重写dealloc方法释放资源。
	•	系统将所有指向类A对象的isa指针指向类B的对象。
当观察者被注册为一个对象的属性的观察对象的isa指针被修改，指向一个中间类，而不是在真实的类。其结果是，isa指针的值并不一定反映实例的实际类。
所以不能依靠isa指针来确定对象是否是一个类的成员。应该使用class方法来确定对象实例的类。
`

## 简述NotificationCenter的工作机制，并说明KVO、KVC的区别
Notification 是观察者模式的实现，KVO是观察者模式的OC底层实现。
NOtification 通过 notifydcation addobserver 和 remove observer 工作。
KVO是键值监听，当监听的数值改动时，会通知注册的观察对象。
KVC是键值编码，通过一种 hash 把属性映射到一个管理字典上。

在发布环境打包的时候，编译器会引入一系列提高性能的优化，例如去掉调试符号或者移除并重新组织代码.另iOS引入一种"Watch Dog"机制.不同的场景下，“看门狗”会监测应用的性能。如果超出了该场景所规定的运行时间，“看门狗”就会强制终结这个应用的进程

[github上的不错的iOS框架](获取ipa包：/Music/iTunes/iTunes Media/Mobile Applications
github上的不错的iOS框架： https://www.zhihu.com/question/22914651
)

[instruments的使用](https://segmentfault.com/a/1190000002568993)
