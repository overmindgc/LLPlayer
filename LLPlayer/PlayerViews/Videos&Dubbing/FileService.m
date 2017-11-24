//
//  FileService.m
//  LLPlayer
//
//  Created by 辰 宫 on 24/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "FileService.h"
#import "VideoItemModel.h"
#import <AVFoundation/AVFoundation.h>
#import "AVUtils.h"

@implementation FileService

+ (FileService *)shareInstance
{
    static dispatch_once_t once;
    static FileService *shareInstance = nil;
    dispatch_once(&once, ^{
        shareInstance = [[self alloc] init];
    });
    return shareInstance;
}

- (void)searchFilesFromDocument:(BOOL)isDubbing complete:(void(^)(NSMutableArray *modelArray))completeBlock
{
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(globalQueue, ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        if (isDubbing) {
            filePath = [NSString stringWithFormat:@"%@/%@",filePath,DubbingVideoFolder];
        }
        NSError *error;
        // 获取指定路径对应文件夹下的所有文件
        NSArray <NSString *> *fileArray = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
        //    NSLog(@"%@", fileArray);
        //    NSArray <NSFileAttributeKey,id> *attrArray = [fileManager attributesOfItemAtPath:filePath error:&error];
        //    NSLog(@"%@", attrArray);
        NSMutableArray *modelArray = [NSMutableArray array];
        for (NSString *fileName in fileArray) {
            if (!isDubbing) {
                if ([fileName isEqualToString:DubbingVideoFolder]) {
                    continue;
                }
            }
            NSString *fullPath = [NSString stringWithFormat:@"%@/%@",filePath,fileName];
            AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:fullPath] options:nil];
            
            //获得所给文件路径所在文件系统的属性
            NSDictionary *attrs = [fileManager attributesOfItemAtPath:fullPath error:nil];
            //        NSLog(@"%@",attrs);
            NSNumber *fileSize = attrs[NSFileSize];
            NSString *fileMB = [NSString stringWithFormat:@"%.2f",[fileSize doubleValue]/1024.0/1024.0];
            
            VideoItemModel *model = [[VideoItemModel alloc] init];
            model.videoAsset = videoAsset;
            model.name = fileName;
            model.path = fullPath;
            model.size = fileMB;
            model.totalTime = [AVUtils getVideoTotalTime:videoAsset];
//            model.thumbImage = [AVUtils getVideoThumbImage:videoAsset];
            CGSize videoSize = [AVUtils getVideoSize:videoAsset];
            model.videoSize = videoSize;
            model.resolution = [NSString stringWithFormat:@"%0.fx%0.f",videoSize.width,videoSize.height];
            model.canPlay = videoAsset.isReadable;
            if (attrs[NSFileType] == NSFileTypeDirectory) {
                model.isFolder = YES;
            }
            [modelArray addObject:model];
        }
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (completeBlock) {
                completeBlock(modelArray);
                if (modelArray.count > 0) {
                    dispatch_async(globalQueue, ^{
                        for (VideoItemModel *itemModel in modelArray) {
                            if (!itemModel.thumbImage) {
                                itemModel.thumbImage = [AVUtils getVideoThumbImage:itemModel.videoAsset];
                            }
                        }
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            completeBlock(modelArray);
                        });
                    });
                }
            }
        });
    });
}

@end
