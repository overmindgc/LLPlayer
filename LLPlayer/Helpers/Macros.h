//
//  Macros.h
//  duxin
//
//  Created by 辰 宫 on 25/10/2017.
//  Copyright © 2017 TMO. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

/**
 *  一些经常用的宏
 */
#define AppKeyWindow [UIApplication sharedApplication].delegate.window    // KeyWindow
#define StandarDefaults [NSUserDefaults standardUserDefaults]           // 轻量级缓存
// 颜色值RGB
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
// 屏幕的宽
#define SCREE_WIDTH                         [[UIScreen mainScreen] bounds].size.width
// 屏幕的高
#define SCREE_HEIGHT                        [[UIScreen mainScreen] bounds].size.height

/**
 * 弱引用/强引用 from YYKit
 MyObject *obj = [[MyObject alloc] init];
 self.myObj = obj;
 @weakify(self)
 self.myObj.test = ^(){
 @strongify(self)
 self.mLabel.text = @"aaa";
 };
 */
#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

/**
 * 常用常量
 */
#define MainColor           RGBA(0, 162, 95, 1)
#define MainColor_Light     RGBA(83, 215, 205, 1)
#define RecordAudioCacheFolder  @"AudioCache"
#define RecordAudioFileName     @"recordCache.aac"

/**
 *  仅仅在DEBUG环境下打印
 */
#ifdef DEBUG
#define NSLog(...) NSLog(__VA_ARGS__)
#define debugMethod() NSLog(@"%s", __func__)
#else
#define NSLog(...)
#define debugMethod()
#endif

#endif /* Macros_h */
