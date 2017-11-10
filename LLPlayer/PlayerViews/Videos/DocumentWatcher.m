//
//  DocumentWatcher.m
//  LLPlayer
//
//  Created by 辰 宫 on 05/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "DocumentWatcher.h"

@implementation DocumentWatcher
// 这里边需要定义两个成员变量
{
    dispatch_queue_t _zDispatchQueue;
    dispatch_source_t _zSource;
}

+ (DocumentWatcher *)defaultWatcher
{
    static dispatch_once_t once;
    static DocumentWatcher *sharedInstance = nil;
    dispatch_once(&once, ^
                  {
                      sharedInstance = [[self alloc] init];
                  });
    
    return sharedInstance;
}

// 开始监听Document目录文件改动, 一旦发生修改则发出一个名为ZFileChangedNotification的通知
- (void)startMonitoringDocumentAsynchronous
{
    // 获取沙盒的Document目录
    NSString *docuPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    [self startMonitoringDirectory:docuPath];
}

// 监听指定目录的文件改动
- (void)startMonitoringDirectory:(NSString *)directoryPath
{
    // 创建 file descriptor (需要将NSString转换成C语言的字符串)
    // open() 函数会建立 file 与 file descriptor 之间的连接
    int filedes = open([directoryPath cStringUsingEncoding:NSASCIIStringEncoding], O_EVTONLY);
    
    // 创建 dispatch queue, 当文件改变事件发生时会发送到该 queue
    _zDispatchQueue = dispatch_queue_create("LLFileMonitorQueue", 0);
    
    // 创建 GCD source. 将用于监听 file descriptor 来判断是否有文件写入操作
    _zSource = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE, filedes, DISPATCH_VNODE_WRITE, _zDispatchQueue);
    
    // 当文件发生改变时会调用该 block
    dispatch_source_set_event_handler(_zSource, ^{
        // 在文件发生改变时发出通知
        // 在子线程发送通知, 这个通知触发的方法会在子线程当中执行
        [[NSNotificationCenter defaultCenter] postNotificationName:LLFileChangedNotification object:nil userInfo:nil];
    });
    
    // 当文件监听停止时会调用该 block
    dispatch_source_set_cancel_handler(_zSource, ^{
        // 关闭文件监听时, 关闭该 file descriptor
        close(filedes);
    });
    
    // 开始监听文件
    dispatch_resume(_zSource);
}

// 停止监听指定目录的文件改动
- (void)stopMonitoringDocument
{
    dispatch_cancel(_zSource);
}
@end
