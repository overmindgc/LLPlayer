//
//  VideosViewController.m
//  LLPlayer
//
//  Created by 辰 宫 on 05/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "VideosViewController.h"
#import "VideoTableViewCell.h"
#import "VideoItemModel.h"
#import "DocumentWatcher.h"
#import "VideoItemModel.h"
#import "VideoPlayerViewController.h"
#import "AVUtils.h"

static NSString * tableCellIndentifer = @"TableCellIndentifer";

@interface VideosViewController () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataSource;

@end

@implementation VideosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoTableViewCell" bundle:nil] forCellReuseIdentifier:tableCellIndentifer];
    
    self.dataSource = [NSMutableArray array];
    
    // 监听Document目录的文件改动
    [[DocumentWatcher defaultWatcher] startMonitoringDocumentAsynchronous];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileChanageAction:) name:LLFileChangedNotification object:nil];
    
    [self searchFilesFromDocument];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (BOOL)prefersStatusBarHidden
//{
//    return NO;
//}
//- (UIStatusBarStyle)preferredStatusBarStyle{
//    return UIStatusBarStyleLightContent;
//}

#pragma mark UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
//    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    VideoTableViewCell *cell = (VideoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:tableCellIndentifer];
    if (cell == nil) {
        cell = [[VideoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableCellIndentifer];
    }
    VideoItemModel *model = [self.dataSource objectAtIndex:row];
    cell.nameLabel.text = model.name;
    if (model.canPlay) {
        cell.propertyLabel.text = [NSString stringWithFormat:@"Video:%@, Size:%@MB",model.resolution,model.size];
    } else if (model.isFolder) {
        cell.propertyLabel.text = [NSString stringWithFormat:@"Folder, Size:%@MB",model.size];
    } else {
        cell.propertyLabel.text = [NSString stringWithFormat:@"Unsupported Type, Size:%@MB",model.size];
    }
    if (model.thumbImage && model.canPlay) {
        cell.videoImageView.image = model.thumbImage;
    } else {
        cell.videoImageView.image = [UIImage imageNamed:@"default_video"];
    }
    if (model.totalTime && model.canPlay) {
        [cell.totalTimeLabel setHidden:NO];
        cell.totalTimeLabel.text = model.totalTime;
    } else {
        [cell.totalTimeLabel setHidden:YES];
    }
    return cell;
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    VideoTableViewCell *currCell = (VideoTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    currCell.selected = NO;
    VideoItemModel *model = [self.dataSource objectAtIndex:row];
    
    if (model.canPlay) {
        VideoPlayerViewController *playerVC = [[VideoPlayerViewController alloc] init];
        playerVC.videoPath = model.path;
        playerVC.videoName = model.name;
        playerVC.videoSize = model.videoSize;
        //    UINavigationController *playerNav = [[UINavigationController alloc] initWithRootViewController:playerVC];
        //    [self.navigationController presentViewController:playerNav animated:YES completion:^{
        //
        //    }];
        [self.navigationController pushViewController:playerVC animated:YES];
    } else {
        
    }
}

#pragma mark EmptyDataSetDelegate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Videos";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"empty_videos"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return YES;
}

- (CGPoint)offsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return CGPointMake(0, -100);
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView
{
    return YES;
}

#pragma mark actions
- (void)fileChanageAction:(NSNotification *)notification
{
    // ZFileChangedNotification 通知是在子线程中发出的, 因此通知关联的方法会在子线程中执行
    NSLog(@"文件发生了改变, %@", [NSThread currentThread]);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self searchFilesFromDocument];
    });
}

- (void)searchFilesFromDocument
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *filePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSError *error;
    // 获取指定路径对应文件夹下的所有文件
    NSArray <NSString *> *fileArray = [fileManager contentsOfDirectoryAtPath:filePath error:&error];
//    NSLog(@"%@", fileArray);
//    NSArray <NSFileAttributeKey,id> *attrArray = [fileManager attributesOfItemAtPath:filePath error:&error];
//    NSLog(@"%@", attrArray);
    
    [self.dataSource removeAllObjects];
    for (NSString *fileName in fileArray) {
        NSString *fullPath = [NSString stringWithFormat:@"%@/%@",filePath,fileName];
        AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:fullPath] options:nil];
        
        //获得所给文件路径所在文件系统的属性
        NSDictionary *attrs = [fileManager attributesOfItemAtPath:fullPath error:nil];
//        NSLog(@"%@",attrs);
        NSNumber *fileSize = attrs[NSFileSize];
        NSString *fileMB = [NSString stringWithFormat:@"%.2f",[fileSize doubleValue]/1024.0/1024.0];
        
        VideoItemModel *model = [[VideoItemModel alloc] init];
        model.name = fileName;
        model.path = fullPath;
        model.size = fileMB;
        model.totalTime = [AVUtils getVideoTotalTime:videoAsset];
        model.thumbImage = [AVUtils getVideoThumbImage:videoAsset];
        CGSize videoSize = [AVUtils getVideoSize:videoAsset];
        model.videoSize = videoSize;
        model.resolution = [NSString stringWithFormat:@"%0.fx%0.f",videoSize.width,videoSize.height];
        model.canPlay = videoAsset.isReadable;
        if (attrs[NSFileType] == NSFileTypeDirectory) {
            model.isFolder = YES;
        }
        [self.dataSource addObject:model];
    }
    [self.tableView reloadData];
}

- (void)dealloc
{
    // 取消监听Document目录的文件改动
    [[DocumentWatcher defaultWatcher] stopMonitoringDocument];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
