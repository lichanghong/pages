---
title: runtime总结
date: 2019-08-25 18:23:58
tags:
---


## runtime是什么
` runtime是一套比较底层的纯C语言API。 我们编写的OC代码在程序运行过程中，其实最终都是转成了runtime的C语言代码，动态创建类、方法、属性，遍历类的方法、属性
`

 * 实例对象instance->类class->方法method（->SEL->IMP）->实现函数
实例对象只存放isa指针和实例变量，由isa指针找到所属类，类维护一个运行时可接收的方法列表；方法列表中的每个入口是一个方法(Method)，其中key是一个特定名称，即选择器(SEL)，其对应一个指向底层C实现函数的指针，即实现(IMP)，。运行时机制最关键核心是objc_msgSend函数，通过给target（类）发送selecter（SEL）来传递消息，找到匹配的IMP，指向实现的C函数。
 * 所有实例对象的isa都指向它所属的类，而类的isa是指向它的元类，所有元类的isa指向基类的meta-class，基类的meta-class的isa指向自己。需要注意的是，root-class（基类）的superclass是nil。

``` 
/// An opaque type that represents an Objective-C class.
typedef struct objc_class *Class;

/// Represents an instance of a class.
struct objc_object {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;
};

/// A pointer to an instance of a class.
typedef struct objc_object *id;

struct objc_class {
    Class _Nonnull isa  OBJC_ISA_AVAILABILITY;

#if !__OBJC2__
    Class _Nullable super_class                              OBJC2_UNAVAILABLE;
    const char * _Nonnull name                               OBJC2_UNAVAILABLE;
    long version                                             OBJC2_UNAVAILABLE;
    long info                                                OBJC2_UNAVAILABLE;
    long instance_size                                       OBJC2_UNAVAILABLE;
    struct objc_ivar_list * _Nullable ivars                  OBJC2_UNAVAILABLE;
    struct objc_method_list ** methodLists                   OBJC2_UNAVAILABLE;
    struct objc_cache * _Nonnull cache                       OBJC2_UNAVAILABLE;
    struct objc_protocol_list * _Nullable protocols          OBJC2_UNAVAILABLE;
#endif

} OBJC2_UNAVAILABLE;
```


## self & super的区别
class:获取方法调用类名
superclass:获取方法调用者的父类类名
super:编译修饰符,不是指针,指向父类标志,
本质还是拿到当前对象去调用父类的方法
注意：当使用 self 调用方法时，会从当前类的方法列表中开始找，如果没有，就从父类中再找；而当使用 super 时，则从父类的方法列表中开始找，然后调用父类的这个方法。


