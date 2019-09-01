---
title: Category&KVO的实现原理可以从runtime来分析
date: 2019-08-25 18:24:45
categories: "iOS面试必看"
tags: "iOS架构"
---


Category&KVO的实现原理可以从runtime来分析

## iOS category内部实现原理
#### category和extension
```
extension在编译期决议，它就是类的一部分，在编译期和头文件里的@interface以及实现文件里的@implement一起形成一个完整的类，它伴随类的产生而产生，亦随之一起消亡。
 extension一般用来隐藏类的私有信息，你必须有一个类的源码才能为一个类添加extension，所以你无法为系统的类比如NSString添加extension。
 
category是在运行期决议的。 extension可以添加实例变量，而category是无法添加实例变量的（因为在运行期，对象的内存布局已经确定，struct的内存大小已经确定）。
```
```
typedef struct category_t {
    const char *name;
    classref_t cls;
    struct method_list_t *instanceMethods;
    struct method_list_t *classMethods;
    struct protocol_list_t *protocols;
    struct property_list_t *instanceProperties;
} category_t;

需要注意的有两点：
1)、category的方法没有覆盖原来类已经有的方法，attachCategoryMethods完成之后，类的方法列表里会有两个methodA
2)、category的方法被放到了新方法列表的前面，运行时在查找方法的时候是顺着方法列表的顺序查找的一找到对应方法，就会停止查找
category的方法为什么会被放到了新方法列表的前面？
 * +load的执行顺序是先类，后category，而category的+load执行顺序是根据编译顺序决定的，多个category方法重名，会先找到最后一个编译的category里的对应方法

怎么调用到原来类中被category覆盖掉的方法？
 Method *methodList = class_copyMethodList(currentClass, &methodCount);遍历，找到后面的方法
 
 可以给category添加实例变量吗？
	在category里面无法为category添加实例变量。可以使用关联对象在category中添加和对象关联的值
 关联对象又是存在什么地方呢？ 如何存储？ 对象销毁时候如何处理关联对象呢？
	所有的关联对象都由AssociationsManager管理，AssociationsManager里面是由一个静态AssociationsHashMap来存储所有的关联对象的。这相当于把所有对象的关联对象都存在一个全局map里面。而map的的key是这个对象的指针地址（任意两个不同对象的指针地址一定是不同的），而这个map的value又是另外一个AssociationsHashMap，里面保存了关联对象的kv对。 
runtime的销毁对象函数objc_destructInstance里面会判断这个对象有没有关联对象，如果有，会调用_object_remove_assocations做关联对象的清理工作。
```
