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

/**
 * 弱引用/强引用
 */
#define LLWeakSelf(type)   __weak typeof(type) weak##type = type;
#define LLStrongSelf(type) __strong typeof(type) type = weak##type;

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
