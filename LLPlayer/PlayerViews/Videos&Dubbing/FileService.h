//
//  FileService.h
//  LLPlayer
//
//  Created by 辰 宫 on 24/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileService : NSObject

+ (FileService *)shareInstance;

- (void)searchFilesFromDocument:(BOOL)isDubbing complete:(void(^)(NSMutableArray *modelArray))completeBlock;

@end
