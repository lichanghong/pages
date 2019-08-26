---
title: 消息机制
date: 2019-08-25 18:26:15
tags:
---


### 消息机制
* 当执行了[receiver message]的时候，相当于向receiver发送一条消息message。runtime会根据reveiver能否处理这条message，从而做出不同的反应。
* 方法（消息机制）的调用流程
  * 消息直到运行时才绑定到方法的实现上。编译器会将消息表达式[receiver message]转化为一个消息函数，即objc_msgSend(receiver, selector)。
  * objc_msgSend做了如下事情：
		1. 通过对象的isa指针获取类的结构体。
		2. 在结构体的方法表里查找方法的selector。
		3. 如果没有找到selector，则通过objc_msgSend结构体中指向父类的指针找到父类，并在父类的方法表里查找方法的selector。
		4. 依次会一直找到NSObject。
		5. 一旦找到selector，就会获取到方法实现IMP。
		6. 传入相应的参数来执行方法的具体实现。
		7. 如果最终没有定位到selector，就会走消息转发流程。
		
* 消息转发机制
以 [receiver message]的方式调用方法，如果receiver无法响应message，编译器会报错。但如果是以performSelector来调用，则需要等到运行时才能确定object是否能接收message消息。如果不能，则程序崩溃。当对象无法接收消息，就会启动消息转发机制，通过这一机制，告诉对象如何处理未知的消息。
这样就可以采取一些措施，让程序执行特定的逻辑，从而避免崩溃。措施分为三个步骤。
  1. 动态方法解析
对象接收到未知的消息时，首先会调用所属类的类方法+resolveInstanceMethod:(实例方法)或 者+resolveClassMethod:(类方法)。
在这个方法中，我们有机会为该未知消息新增一个”处理方法”。使用该“处理方法”的前提是已经实现，只需要在运行时通过class_addMethod函数，动态的添加到类里面就可以了。代码如下。
![](http://www.2cto.com/uploadfile/Collfiles/20170812/20170812093007924.png)

		```
		网上大都是讲解resolveInstanceMethod，而resolveClassMethod一般都没实现，因为第一次参数必须是元类对象（可以是Object元类），而不能是self
 + (BOOL)resolveClassMethod:(SEL)sel
	{
	NSLog(@"%s %s %s", @encode(void), @encode(id), @encode(SEL));
		    Class meta = objc_getMetaClass([NSStringFromClass(self) UTF8String]);
		    if (sel == @selector(hehe)) {
		        NSLog(@"==hehe");
		        class_addMethod(meta, @selector(hehe), (IMP)resolveMethod, "");
		        return YES;
		    }
		    return [super resolveClassMethod:sel];
		}
		```
	2. 备用接收者
	如果在上一步无法处理消息，则Runtime会继续调下面的方法。forwardingTargetForSelector:(SEL)selector
forwardingTargetForSelector
如果这个方法返回一个对象，则这个对象会作为消息的新接收者。注意这个对象不能是self自身，否则就是出现无限循环。如果没有指定对象来处理aSelector，则应该 return [super forwardingTargetForSelector:aSelector]。
但是我们只将消息转发到另一个能处理该消息的对象上，无法对消息进行处理，例如操作消息的参数和返回值。
![](http://www.2cto.com/uploadfile/Collfiles/20170812/20170812093008926.png)

	3. 完整消息转发

如果在上一步还是不能处理未知消息，则唯一能做的就是启用完整的消息转发机制。此时会调用以下方法：
![](http://www.2cto.com/uploadfile/Collfiles/20170812/20170812093008927.png)
forwardInvocation
这是最后一次机会将消息转发给其它对象。创建一个表示消息的NSInvocation对象，把与消息的有关全部细节封装在anInvocation中，包括selector，目标(target)和参数。在forwardInvocation 方法中将消息转发给其它对象。
forwardInvocation:方法的实现有两个任务：
   	a. 定位可以响应封装在anInvocation中的消息的对象。
	   b. 使用anInvocation作为参数，将消息发送到选中的对象。anInvocation将会保留调用结果，runtime会提取这一结果并发送到消息的原始发送者。
在这个方法中我们可以实现一些更复杂的功能，我们可以对消息的内容进行修改。另外，若发现消息不应由本类处理，则应调用父类的同名方法，以便继承体系中的每个类都有机会处理。
另外，必须重写下面的方法：
![](http://www.2cto.com/uploadfile/Collfiles/20170812/20170812093008928.png)

methodSignatureForSelector
消息转发机制从这个方法中获取信息来创建NSInvocation对象。完整的示例如下：
![](http://www.2cto.com/uploadfile/Collfiles/20170812/20170812093008929.png)

完整消息转发
NSObject的forwardInvocation方法只是调用了doesNotRecognizeSelector方法，它不会转发任何消息。如果不在以上所述的三个步骤中处理未知消息，则会引发异常。
forwardInvocation就像一个未知消息的分发中心，将这些未知的消息转发给其它对象。或者也可以像一个运输站一样将所有未知消息都发送给同一个接收对象，取决于具体的实现。
消息的转发机制可以用下图来帮助理解。
![](http://www.2cto.com/uploadfile/Collfiles/20170812/20170812093008930.png)

### SEL Method IMP 等的解释及关系
* SEL 表示一个方法的selector的指针,映射方法的名字
* IMP 是指向实现函数的指针
* Method 这个结构体相当于在SEL和IMP之间作了一个绑定。

```
struct objc_method {
SEL method_name        OBJC2_UNA VAILABLE;  
char *method_types     OBJC2_UNAVAILABLE; // 参数类型
IMP method_imp         OBJC2_UNAVAILABLE;  // 方法实现
}
```

### 方法缓存：Cache用于缓存最近使用的方法。
方法调用最先是在方法缓存里找的，方法调用是懒调用，第一次调用时加载后加到缓存池里。一个objc程序启动后，需要进行类的初始化、调用方法时的cache初始化，再发送消息的时候就直接走缓存 
 