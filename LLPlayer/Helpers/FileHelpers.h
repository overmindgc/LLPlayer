//
//  AppHelpers.h
//  ITAS2_New
//
//  Created by 辰 宫 on 15/2/12.
//  Copyright (c) 2015年 overmindgc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FileHelpers : NSObject

/**保存图片到沙盒*/
+ (NSString *)saveImageToCacheSandBoxWithData:(UIImage *)image folder:(NSString *)folderName fileName:(NSString *)fileName;
+ (NSString *)saveImageToDocumentSandBoxWithData:(UIImage *)image folder:(NSString *)folderName fileName:(NSString *)fileName;

/**删除沙盒里的文件夹*/
+ (void)deleteFolderFromCacheSandBoxWithName:(NSString *)folderName;
+ (void)deleteFolderFromDocumentSandBoxWithName:(NSString *)folderName;

/**删除沙盒里的文件*/
+ (void)deleteFileFromSandBoxWithFilePath:(NSString *)filePath;

/**从沙盒读取图片*/
+ (UIImage *)getImageFromSandBoxWithFilePath:(NSString *)filePath;

@end
