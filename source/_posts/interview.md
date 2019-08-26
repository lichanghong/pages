---
title: interview
date: 2019-08-25 18:33:53
tags:
---


## sqlite的版本升级
coredata界面化的可以使用MagicalRecord简单操作，sqlite可以使用FMDB，有FMDBMigrationManager可以简单操作版本升级，提供了两种方式，推荐创建Migration类。另外推荐一种命令行工具sqlite3，mac自带。另一种界面化的：sqlitebrowser。如有其它更好的版本升级及好用的工具，可讨论。最后，   NSString *path = [[[NSBundle mainBundle]bundlePath]stringByAppendingPathComponent:@"aa.txt"];
[@"test" writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil] 沙盒有权限写入，真机无法写入

## 今日头条的面试题
#### View上有很多button，也有子view，subview上有button，还有uitableview的cell上也有button，如何写一个方法设置所有button失去响应事件的能力？代码是手写，我当时用响应者琏写的，这是个陷阱，思路完全相反。以下是我事后写的实现方法。

```
+ (void)disabelActionsInView:(UIView *)view
{
    for (UIView *v in view.subviews) {
        if ([v isMemberOfClass:[UIButton class]] && v.userInteractionEnabled) {
            UIButton *btn = (UIButton *)v;
            NSLog(@"view  setEnabled  = %@",btn);
            [btn setUserInteractionEnabled:NO];
        }
        else if(v.userInteractionEnabled && [v isKindOfClass:[UIResponder class]] && v.subviews)
        {
            NSLog(@"view  else  = %@",v);
            [ViewController disabelActionsInView:v];
        }
    }
}

```

#### 对可变数组的count使用kvo监听，kvo使用注意点
iOS默认不支持对数组的KVO,因为普通方式监听的对象的地址的变化，而数组地址不变，而是里面的值发生了改变,当对同一个keypath进行两次removeObserver时会导致程序crash，这种情况常常出现在父类有一个kvo，父类在dealloc中remove了一次，子类又remove了一次的情况下。
目前的代码中context字段都是nil，那能否利用该字段来标识出到底kvo是superClass注册的，还是self注册的？我们可以分别在父类以及本类中定义各自的context字符串，比如在本类中定义context为@"ThisIsMyKVOContextNotSuper";然后在dealloc中remove observer时指定移除的自身添加的observer。这样iOS就能知道移除的是自己的kvo，而不是父类中的kvo，避免二次remove造成crash。


## ipad使用UIAlertController时，和iphone有点区别，需要加上如下三句才不会崩溃

```
[alert.popoverPresentationController setPermittedArrowDirections:0];
alert.popoverPresentationController.sourceView=sender;
alert.popoverPresentationController.sourceRect=CGRectMake(CGRectGetMidX(sender.bounds), CGRectGetMidY(sender.bounds),0,0);
```

## 陌陌科技面试遇到的问题坑
### viewdidload里面开启4个nstimer对可变数组操作，需要锁吗？用什么锁？
因为是在主线程同一个运行循环里，所有任务都是顺序执行的，所以不需要加锁
那如果是多线程同时对可变数组操作需要加锁吗？你会用什么锁？atomic和其他所的区别
这里主要是想问atomic加锁方式，就是对对象的set和get方法进行加锁，而其他的锁都是手动加入到需要锁的地方。

关于锁：(不加锁的情况下一个元素会很多次的remove)
  
``` 
NSMutableArray *arr = [NSMutableArray array];
    [arr addObject:@"hehe"];
   // NSLock *lock = [[NSLock alloc]init];

    for (int i=0; i<50; i++) {
        NSString *str = [NSString stringWithFormat:@"xixi%d",i];
        dispatch_async(dispatch_queue_create([str UTF8String], 0), ^{
           // [lock lock];
            if (arr.count>0) {
                NSLog(@"arr count > 0  %@",arr);
                [arr removeLastObject];
            }
          //  [lock unlock];
        });
    }
    
     @synchronized(self){}也能实现加锁,dispatch_semaphore_t同步也可以

```
同一个url在sdwebimage里发送几次请求
uiview的父视图有pan手势，uiview拖动的时候会调用父视图的手势吗
retain assign Timer会导致循环引用吗？为什么

## 作业盒子面试的坑
### frame和bounds的区别，主要问view经过旋转或transform之后分别多大，frame改变之后bounds大小也会变，但是transform改变大小之后frame会变，bounds还是原来的大小

### readonly声明的属性如何在.m类中修改？使用属性生成的成员变量即可直接复制修改，readonly针对的是get、set方法只读

离屏渲染
 
### uiview pangesture
父view加上pan手势，子view覆盖其上，拖动子view会调用pan手势

隐藏cer

### 关于const
static nsstring const* name
static const nsstring* name
static nsstring *const name

const关键字放在类型或变量名之前等价的
const int n=5; //same as below
int const m=10
const int a; int const a; 这两个写法是等同的，表示a是一个int常量。
const int *a; 表示a是一个指针，可以任意指向int常量或者int变量，它总是把它所指向的目标当作一个int常量。也可以写成int const* a;含义相同。
int * const a; 表示a是一个指针常量，初始化的时候必须固定指向一个int变量，之后就不能再指向别的地方了。
int const * a const;这个写法没有，倒是可以写成int const * const a;表示a是一个指针常量，初始化的时候必须固定指向一个int常量或者int变量，之后就不能再指向别的地方了，它总是把它所指向的目标当作一个int常量。也可以写成const int* const a;含义相同。

# 2019年最新面试题：
1、
```
 #define max(a,b)  (a>b?a:b)
  int a=1;
        NSLog(@"%f",max(a++,1.5));
        NSLog(@"%d",a);
输出结果是什么？
```
2、
@interface NSObject (NSObject)
- (void)test;
+ (void)test1;
@end
@implementation NSObject  (NSObject)
+ (void)test
{
    NSLog(@"aaaa");
}
- (void)test1
{
    NSLog(@"bbbb");
}
@end
以下输出结果： 3，4崩溃
  [NSObject test1];
    [Person test1];
   [[[NSObject alloc]init] test];
   [[[Person alloc]init] test];
NSObject元类对象是自己，所以NSObject能够直接调用类方法和实例方法
3、



