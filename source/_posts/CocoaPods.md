---
title: CocoaPods
date: 2019-08-25 18:23:33
categories: "iOS面试必看"
tags:
---

## CocoaPods的Podfile.lock
1. 在开始使用CocoaPods，执行完pod install之后，会生成一个Podfile.lock文件。该文件用于保存已经安装的Pods依赖库的版本。
2. 当团队中的某个人执行完pod install命令后，生成的Podfile.lock文件就记录下了当时最新Pods依赖库的版本，这时团队中的其它人check下来这份包含Podfile.lock文件的工程以后，再去执行pod install命令时，获取下来的Pods依赖库的版本就和最开始用户获取到的版本一致。如果没有Podfile.lock文件，后续所有用户执行pod install命令都会获取最新版本的库，这就有可能造成同一个团队使用的依赖库版本不一致，这对团队协作来说绝对是个灾难！在这种情况下，如果团队想使用当前最新版本的依赖库，有两种方案：

```
	* 更改Podfile，使其指向最新版本的JSONKIT依赖库；

	* 执行pod update命令；
```