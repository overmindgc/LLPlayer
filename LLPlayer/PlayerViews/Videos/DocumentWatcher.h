//
//  DocumentWatcher.h
//  LLPlayer
//
//  Created by 辰 宫 on 05/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString *LLFileChangedNotification = @"LLFileChangedNotification";

@interface DocumentWatcher : NSObject

+ (DocumentWatcher *)defaultWatcher;

// 开始监听Document目录文件改动, 一旦发生修改则发出一个名为ZFileChangedNotification的通知
- (void)startMonitoringDocumentAsynchronous;

// 监听指定目录的文件改动
- (void)startMonitoringDirectory:(NSString *)directoryPath;

// 停止监听指定目录的文件改动
- (void)stopMonitoringDocument;

@end
