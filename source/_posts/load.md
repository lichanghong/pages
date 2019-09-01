---
title: load & initialize
date: 2019-08-25 18:22:45
categories: "iOS面试必看"
tags:
---

 
## load & initialize
1. 加载阶段(build phases -> compile sources)，如果类实现了load方法，系统就会调用它，load方法不参与覆写机制。顺序为父类->子类->分类（不会严格的从上往下遍历文件）
2. initialize是在类或者其子类的第一个方法被调用前调用，子类会调用父类的initialize方法，如果子类没有实现initialize，则父类调两次，这两次调用时的self第一次是父类
