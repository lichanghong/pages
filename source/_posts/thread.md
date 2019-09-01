---
title: 对线程处理有哪几种？优缺点，在什么场景使用
date: 2019-08-25 18:21:38
categories: "iOS面试必看"
tags:
---

## 对线程处理有哪几种？优缺点，在什么场景使用
 * pthread C 跨平台通用，手动管理线程生命周期，使用难度大
 * NSThread OC 面向对象使用简单，需自己管理生命周期线程同步锁
 * GCD C 替代NSThread 等线程技术，可以充分利用线程多核，线程生命周期自动管理
 * NSOperation OC基于GCD，比GCD多一些简单使用功能，面向对象，自动管理生命周期。

 题目：有五个异步线程，如何在处理完之后再处理后来的任务？
  ```
 1，CFRunLoopRun();CFRunLoopStop(runloop); 只能在主线程处理异步线程，不符合要求
 2，dispatch_group_async,dispatch_group_notify 处理同步任务的时候可以，异步任务不行
 3，dispatch_group_enter，dispatch_group_leave，dispatch_group_notify 达到要求
 4，dispatch_barrier_sync 达到要求 
 5，NSOperationQueue中NSOperation addDependency ，和2同 
 6，dispatch_semaphore_create，dispatch_semaphore_signal，dispatch_semaphore_wait 达到要求。
 wait:Decrement the counting semaphore. If the resulting value is less than zero, 
 this function waits for a signal to occur before returning.
  ```

 
 ```
 进程：是系统进行资源分配和调度的基本单位
 线程：是程序执行流的最小单位
 ```



## iOS中的线程死锁和循环引用问题
* `dispatch_queue_t queue = dispatch_queue_create("test", nil);
`这行代码中，第二个参数为nil值，相当与值为DISPATCH_QUEUE_SERIAL，即为串行的。
如果把值改成DISPATCH_QUEUE_CONCURRENT，即为并行的，就不会导致两个同步线程死锁.或者使用dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),dispatch_get_global_queue是并行队列。主线程其实就是在一个串行队列里的.
* 我们要做的就是将任务放到队列里执行，GCD会自动将队列中的任务按先进先出的方式取出并交给对应线程执行。注意任务的取出是按照先进先出的方式，这也是队列的特性，但是取出后的执行顺序则不一定，
* 有两种队列：串行队列和并行队列。串行队列：同步执行，尽可能在当前线程执行，以优化性能；并行队列：可由多个线程异步执行，但任务的取出还是FIFO的.
* 另外系统提供了两种队列：全局队列和主队列。
* 全局队列属于并行队列，只不过已由系统创建的没有名字，且在全局可见（可用）。获取全局队列：

```
/* 取得全局队列
 第一个参数：线程优先级,设为默认即可，个人习惯写0，等同于默认
 第二个参数：标记参数，目前没有用，一般传入0
 */
serialQ = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
```
* 主队列属于串行队列，也由系统创建，只不过运行在主线程（UI线程）。获取主队列：
```
// 获取主队列
serialQ = dispatch_get_main_queue();
```
* 关于内存：queue属于一个对象，也是占用内存的，也会使用引用计数，当向queue添加一个任务时就会将这个queue retain一下，引用计数+1，直到所有任务都完成内存才会释放。（我们在声明一个queue属性时要用strong)。

* 执行方式——2种(同步执行和异步执行)
  * 同步执行：不会开启新的线程，在当前线程执行(绝大部分情况如此)；同步执行的话，不会对block进行copy.
  * 异步执行：gcd管理的线程池中有空闲线程就会从队列中取出任务执行，会开启线程。
* 下面为实现同步和异步的函数，函数功能为：将任务添加到队列并执行。

```
将任务添加到队列并执行。
/* 同步执行
 第一个参数：执行任务的队列：串行、并行、全局、主队列
 第二个参数：block任务
 */
void dispatch_sync(dispatch_queue_t queue, dispatch_block_t block);
有一种情况要用这个dispatch_sync，就是要保证线程安全的情况。dispatch_sync会加锁。
比如说这个：
- (NSArray *)photos
{
	__block NSArray *array;
	dispatch_sync(self.concurrentPhotoQueue, ^{
		array = [NSArray arrayWithArray:_photoArray];
	});
	return array;
}
_photoArray是NSMutableArray类型的，是非线程安全的。故要加一个锁，防止出现问题
dispatchsync，在底层是对queue进行了加锁
// 异步执行
void dispatch_async(dispatch_queue_t queue, dispatch_blo
```
注意：默认情况下，新线程都没有开启runloop，所以当block任务完成后，线程都会自动被回收，假设我们想在新开的线程中使用NSTimer，就必须开启runloop，可以使用[[NSRunLoop currentRunLoop] run]开启当前线程，这是就要自己管理线程的回收等工作。

*  另外还有两个方法

```
*  另外还有两个方法
dispatch_barrier_sync(dispatch_queue_t queue, dispatch_block_t block);
dispatch_barrier_async(dispatch_queue_t queue, dispatch_block_t block);
加了一个barrier，意义在于：当开始处理队列中barrier的block时，必须处理完之后，才能处理其它的block
```
* 四种情况：串行队列同步执行、串行队列异步执行、并行队列同步执行、并行队列异步执行


```
	1.	串行队列，同步执行-----串行队列意味着顺序执行，同步执行意味着不开启线程（在当前线程执行）
	2.	串行队列,异步执行-----串行队列意味着任务顺序执行，异步执行说明要开线程, （如果开多个线程的话，不能保证串行队列顺序执行，所以只开一个线程）
	3.	并行队列,异步执行-----并行队列意味着执行顺序不确定，异步执行意味着会开启线程，而并行队列又允许不按顺序执行，所以系统为了提高性能会开启多个线程，来队列取任务（队列中任务取出仍然是顺序取出的，只是线程执行无序）。
	4.	并行队列,同步执行-----同步执行意味着不开线程,则肯定是顺序执行
	5.	死锁-----程序执行不出来(死锁) ；
```

* 死锁举例
   1. 	主队列死锁
		` 1. 主队列死锁
		   主队列，如果主线程正在执行代码，就不调度任务；同步执行：一直执行第一个任务直到结`
		
		```
		- (void)mainThreadDeadLockTest {
		    NSLog(@"begin");
		    dispatch_sync(dispatch_get_main_queue(), ^{
		        // 发生死锁下面的代码不会执行
		        NSLog(@"middle");
		    });
		    // 发生死锁下面的代码不会执行，当然函数也不会返回，后果也最为严重
		    NSLog(@"end");
		}
		```
		
  2. 在其它线程死锁，这种不会影响主线程
```
  - (void)deadLockTest {
    // 其它线程的死锁
    dispatch_queue_t serialQueue = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL);
    dispatch_async(serialQueue, ^{
        // 串行队列block1
        NSLog(@"begin");
        dispatch_sync(serialQueue, ^{
            // 串行队列block2 发生死锁，下面的代码不会执行
            NSLog(@"middle");
        });
        // 不会打印
        NSLog(@"end");
    });
    // 函数会返回，不影响主线程
    NSLog(@"return");
}
```

* 常用举例
  1. 线程间通讯
`为了提高用户体验，我们一般在其他线程（非主线程）下载图片或其它网络资源，下载完成后我们要更新UI，而UI更新必须在主线程执`
  
	  ```
	// 同步执行，会阻塞直到下面block中的代码执行完毕
	dispatch_sync(dispatch_get_main_queue(), ^{
	    // 主线程，UI更新
	});
	// 异步执行
	dispatch_async(dispatch_get_main_queue(), ^{
	    // 主线程，UI更新
	});
	  ```
	
   2. 信号量的使用也属于线程间通讯
		`在网络访问中，NSURLSession类都是异步的(找了很久没有找到同步的方法)，而有时我们希望能够像NSURLConnection一样可以同步访问，即在网络block调用完成之后做一些操作。那我们可以使用dispatch的信号量来解决：
	`
	
	  ```
	// 用于线程间通讯，下面是等待一个网络完成
	- (void)dispatchSemaphore {
	    NSString *urlString = [@"https://www.baidu.com" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
	    // 设置缓存策略为每次都从网络加载 超时时间30秒
	    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
	    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
	    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
	        // 处理完成之后，发送信号量
	        NSLog(@"正在处理...");
	        dispatch_semaphore_signal(semaphore);
	    }] resume];
	    // 等待网络处理完成
	    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
	    NSLog(@"处理完成！");
	}
	  ```
	  `在上面的举例中dispatch_semaphore_signal的调用必须是在另一个线程调用，因为当前线程已经dispatch_semaphore_wait阻塞。另外，dispatch_semaphore_wait最好不要在主线程调用
	  `

 3. 全局队列，实现并发  
   
		```
	dispatch_async(dispatch_get_global_queue(0, 0), ^{
		    // 要执行的代码
		});
		```
  
* 关于Dispatch对象内存管理问题
`根据上面的代码，可以看出有关dispatch的对象并不是OC对象，那么，用不用像对待Core Foundation框架的对象一样，使用retain/release来管理呢？答案是不用的！
如果是ARC环境，我们无需管理，会像对待OC对象一样自动内存管理。
如果是MRC环境，不是使用retain/release，而是使用dispatch_retain/dispatch_release来管理。
`



