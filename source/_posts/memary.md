---
title: 内存相关
date: 2019-08-25 18:28:08
categories: "iOS面试必看"
tags:
---


## linkMap文件
linkMap文件是XCode产生可执行文件（mach-o）的同时生成的链接信息，用来描述可执行文件的构造部分。

## 堆栈 程序存储空间的分配
1. 栈区（stack）—   由编译器自动分配释放，存放函数的参数值，局部变量的值等。
2. 堆区（heap)   一般由程序员分配释放，若程序员不释放，程序结束时可能由OS回收。它与数据结构中的堆是两回事，分配方式倒是类似于链表。
3. 全局区（静态区）（static）—，全局变量和静态变量的存储是放在一块的，初始化的全局变量和静态变量在一块区域，未初始化的全局变量和未初始化的静态变量在相邻的另一块区域。程序结束后由系统释放。
4. 文字常量区   —常量字符串就是放在这里的。   程序结束后由系统释放  
5. 程序代码区—存放函数体的二进制代码

## nonatomic与atomic的区别与作用
1. atomic默认属性和nonatomic区别用来决定编译器生成的getter和setter是否为原子操作。atomic提供多线程安全,是描述该变量是否支持多线程的同步访问,系统会自动的创建lock锁，锁定变量。nonatomic禁止多线程,提高效率。
`
可以看出来，用atomic会在多线程的设值取值时加锁，中间的执行层是处于被保护的一种状态，atomic是oc使用的一种线程保护技术，基本上来讲，就是防止在写入未完成的时候被另外一个线程读取，造成数据错误`

## 理解autorelease Autorelease对象什么时候释放？
* 在没有手加Autorelease Pool的情况下，Autorelease对象是在当前的runloop迭代结束时释放的，而它能够释放的原因是系统在每个runloop迭代中都加入了自动释放池Push和Pop。当然，我们也可以手动干预Autorelease对象的释放时机：@autoreleasepool {}
* Autorelease原理
ARC下，我们使用@autoreleasepool{}来使用一个AutoreleasePool，随后编译器将其改写成下面的样子：
```
void *context =objc_autoreleasePoolPush();// {}中的代码
objc_autoreleasePoolPop(context);
而这两个函数都是对AutoreleasePoolPage的简单封装，所以自动释放机制的核心就在于这个类。
```

	1. AutoreleasePoolPage是一个C++实现的类
![](http://cc.cocimg.com/api/uploads/20150602/1433231088247726.png)
	2. AutoreleasePool并没有单独的结构，而是由若干个AutoreleasePoolPage以双向链表的形式组合而成（分别对应结构中的parent指针和child指针）。
	3. AutoreleasePool是按线程一一对应的（结构中的thread指针指向当前线程）。
	4. AutoreleasePoolPage每个对象会开辟4096字节内存（也就是虚拟内存一页的大小），除了上面的实例变量所占空间，剩下的空间全部用来储存autorelease对象的地址。
  5. 上面的id *next指针作为游标指向栈顶最新add进来的autorelease对象的下一个位置。
  6. 一个AutoreleasePoolPage的空间被占满时，会新建一个AutoreleasePoolPage对象，连接链表，后来的autorelease对象在新的page加入。
  7. 这一页再加入一个autorelease对象就要满了（也就是next指针马上指向栈顶），这时就要执行上面说的操作，建立下一页page对象，与这一页链表连接完成后，新page的next指针被初始化在栈底（begin的位置），然后继续向栈顶添加新对象。
  8. 所以，向一个对象发送- autorelease消息，就是将这个对象加入到当前AutoreleasePoolPage的栈顶next指针指向的位置。
  9. 释放时刻
     1. 每当进行一次objc_autoreleasePoolPush调用时，runtime向当前的AutoreleasePoolPage中add进一个哨兵对象，值为0（也就是个nil）,objc_autoreleasePoolPush的返回值正是这个哨兵对象的地址，被objc_autoreleasePoolPop(哨兵对象)作为入参，于是
     2. 根据传入的哨兵对象地址找到哨兵对象所处的page。在当前page中，将晚于哨兵对象插入的所有autorelease对象都发送一次- release消息，并向回移动next指针到正确位置。（从最新加入的对象一直向前清理，可以向前跨越若干个page，直到哨兵所在的page）
     3. 在Iphone项目中，大家会看到一个默认的Autorelease pool，程序开始时创建，程序退出时销毁，按照对Autorelease的理解，岂不是所有autorelease pool里的对象在程序退出时才release， 这样跟内存泄露有什么区别？
　　`答案是，对于每一个Runloop， 系统会隐式创建一个Autorelease pool，这样所有的release pool会构成一个象CallStack一样的一个栈式结构，在每一个Runloop结束时，当前栈顶的 Autorelease pool会被销毁，这样这个pool里的每个Object会被release。`

## 内存管理
1. 在ObjC中，对象什么时候会被释放（或者对象占用的内存什么时候会被回收利用）？
`当前runloop循环结束时会释放。对于每一个Runloop，系统会隐式创建一个Autorelease Pool,这样所有的release pool会构成一个栈式结构，在每一个Runloop结束时，当前栈顶的Autorelease pool会被销毁，这样这个pool里的每个Object会被release
`
2. 内存管理机制
 	1. 当对象被创建（通过alloc、new或copy等方法）时，其引用计数初始值为1
 	2. 给对象发送retain消息，其引用计数加1
 	3. 给对象发送release消息，其引用计数减1
 	4. 当对象引用计数归0时，ObjC给对象发送dealloc消息销毁对象
3. iOS的内存管理规则
`在iOS开发中也存在规则来约束开发者进行内存管理，总的来讲有三点：`
    1. 当你通过new、alloc或copy方法创建一个对象时，它的引用计数为1，当不再使用该对象时，应该向对象发送release或者autorelease消息释放对象。
    2. 当你通过其他方法获得一个对象时，如果对象引用计数为1且被设置为autorelease，则不需要执行任何释放对象的操作；
    3. 如果你打算取得对象所有权，就需要保留对象并在操作完成之后释放，且必须保证retain和release的次数对等。
4. ARC 
`ARC不是垃圾回收，也并不是不需要内存管理了，它是隐式的内存管理，编译器在编译的时候会在代码插入合适的ratain和release语句，相当于在背后帮我们完成了内存管理的工作。`

 ```
  *  __unsafe_unretained: 不会对对象进行retain,当对象销毁时,会依然指向之前的内存空间(野指针)  
  *  __weak: 不会对对象进行retain,当对象销毁时,会自动指向nil
 ```
### Weak指针自动被置为nil的实现原理
Runtime维护了一个全局weak_table，用于存储指向某个对象的所有Weak指针
Weak表其实是一个哈希表，Key是所指对象的地址，Value是Weak指针地址的数组,在对象被回收的时候，经过层层调用，会最终触发arr_clear_deallocating将所有Weak指针的值设为nil
简单来说，这个方法首先根据对象地址获取所以Weak指针地址的数组，然后遍历这个数组把其中的数据设为nil，最后把这个entry从Weak表中删除。

5. 属性的内存管理
  `ObjC2.0引入了@property，属性的参数分为三类，基本数据类型默认(atomic,readwrite,assign)，对象类型默认为(atomic,readwrite,strong)`
  1. assign一般用来修饰基本数据类型
  2. release旧值，再retain新值（引用计数＋1），retain和strong一样，都用来修饰ObjC对象。
  3. copy：release旧值，再copy新值
6.  block的内存管理
`iOS中使用block必须自己管理内存，block会对内部使用的对象进行强引用`
 block的存储
	•	Block如果没有引用外部变量 保存在全局区（MRC/ARC一样）
	•	Block如果引用外部变量 ARC保存在堆区； MRC保存在栈区 必须用copy修饰block；
	 在Block的内存存储在堆中时,如果在Block中引用了外面的对象,会对所引用的对象进行一次retain操作,即使在Block自身调用了release操作之后,Block也不会对所引用的对象进行一次release操作,这时会造成内存泄漏 
[block总结1](https://www.cnblogs.com/huntaiji/p/10923836.html). 
[block总结2](https://www.jianshu.com/p/00a7ee0177ea). 
 id obj1 = [[NSString alloc]initWithFormat:@"%@",@"我是李长鸿我是李长鸿我是李长鸿"];
    id obj2 = [obj1 retain];
    id obj3 = [obj2 copy];
    id obj4 = [obj3 mutableCopy];
    id obj5 = [obj4 copy]; 
    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(obj1)));
    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(obj2)));
    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(obj3)));
    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(obj4)));
    printf("retain count = %ld\n",CFGetRetainCount((__bridge CFTypeRef)(obj5)));
  结果：33322
7. 经典内存泄漏及其解决方案
	1. 僵尸对象和野指针
		* 僵尸对象：内存已经被回收的对象。
		* 野指针：指向僵尸对象的指针，向野指针发送消息会导致崩溃。
		`访问了一块已经不属于你的内存会出现野指针错误，表现为：Thread 1：EXC_BAD_ACCESS
`
		* 解决方案： 对象已经被释放后，应将其指针置为空指针（没有指向任何对象的指针，给空指针发送消息不会报错）。
			* 检测工具：
				1. edit scheme－diagnostics中将enable zombie objects勾选
				2. Instruments选择Zombies工具
	2. 循环引用
	   * 检测工具：
			1. product－Analyze中使用静态分析来检测代码中可能存在循环引用的问题
			2. Instruments，选择Leaks工具可以对已安装的应用进行内存泄漏检测,Leaks工具虽然强大，			但是它不能检测到block循环引用导致的内存泄漏
			3. 循环中对象占用内存大这个问题常见于循环次数较大，循环体生成的对象占用内存较大的情景。每一轮循环都加入autoreleasepool解决。
			4. 无限循环
				当你启动了一个无限循环的时候，ARC会默认该方法用不会执行完毕，方法里面的对象就永不释放，内存无限上涨，导致内存泄漏。
 
## iOS 深拷贝 浅拷贝
1. 对于系统的非容器类对象，对一不可变对象复制，copy是指针复制（浅拷贝）和mutableCopy就是对象复制（深拷贝）。如果是对可变对象复制，都是深拷贝，但是copy返回的对象是不可变的。
2. 对于系统的容器类对象，以上规则同样适用，但是容器内的元素全部都是浅拷贝，也就是说所有的元素拷贝的仅仅是指针，内存没素复制。
3. 首先通过一句话来解释：深拷贝就是内容拷贝，浅拷贝就是指针拷贝。
4. 深拷贝就是拷贝出和原来仅仅是值一样，但是内存地址完全不一样的新的对象，创建后和原对象没有任何关系。浅拷贝就是拷贝指向原来对象的指针，使原对象的引用计数+1，可以理解为创建了一个指向原对象的新指针而已，并没有创建一个全新的对象。
5. 只有遵守NSCopying协议的类可以发送copy消息，遵守NSMutableCopying协议的类才可以发送mutableCopy消息，否则就会崩溃

## Timer循环引用的原理
timer会被添加到runloop中，否则不会运行，当然添加的runloop不存在也不会运行。
timer需要添加到runloop的一个或多个模式中，模式不对也不会运行。
runloop会对timer进行强引用，timer会对目标对象target进行强引用。
看到最后一点应该差不多清晰了，当timer作为一个属性或者成员变量时，是被self强引用的，通常timer的目标target都是self，这个时候就导致循环引用了。
 *  解决：invalidate、中间类实现NSTimer逻辑、viewDidDisappear。
CFRunloopTimerRef 与 NSTimer是toll-free bridged的，可混用

