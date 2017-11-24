//
//  DubbingViewController.m
//  LLPlayer
//
//  Created by 辰 宫 on 13/11/2017.
//  Copyright © 2017 GC. All rights reserved.
//

#import "DubbingViewController.h"
#import "VideoTableViewCell.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "VideoItemModel.h"
#import "VideoItemModel.h"
#import "MoviePlayerViewController.h"
#import "FileHelpers.h"
#import "FileService.h"

static NSString * tableCellIndentifer = @"TableCellIndentifer";

@interface DubbingViewController () <UITableViewDelegate, UITableViewDataSource, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong) NSMutableArray *dataSource;

@property (nonatomic) NSInteger currentRow;//记录当前点击的行数

@end

@implementation DubbingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tableView registerNib:[UINib nibWithNibName:@"VideoTableViewCell" bundle:nil] forCellReuseIdentifier:tableCellIndentifer];
    
    self.dataSource = [NSMutableArray array];
    
    //videos里边已经开始监听过文件变动了，这里只响应变动就可以
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileChanageAction:) name:LLClipOrDubbingCreatedNotification object:nil];
    
    [self searchFilesFromDocument];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

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
    self.currentRow = row;
    VideoTableViewCell *currCell = (VideoTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    currCell.selected = NO;
    VideoItemModel *model = [self.dataSource objectAtIndex:row];
    
    if (model.canPlay) {
        //        VideoPlayerViewController *playerVC = [[VideoPlayerViewController alloc] init];
        //        playerVC.videoPath = model.path;
        //        playerVC.videoName = model.name;
        //        playerVC.videoSize = model.videoSize;
        [self performSegueWithIdentifier:@"showMovieView" sender:self];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
    
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"Delete";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        VideoItemModel *model = [self.dataSource objectAtIndex:indexPath.row];
        BOOL isSuccess = [FileHelpers deleteFileFromSandBoxWithFilePath:model.path];
        if (isSuccess) {
            [self.dataSource removeObjectAtIndex:indexPath.row];
            [tableView reloadData];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

#pragma mark EmptyDataSetDelegate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"No Clips";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:16.0f],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"empty_clips"];
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

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    MoviePlayerViewController *movie = (MoviePlayerViewController *)segue.destinationViewController;
    VideoItemModel *model = [self.dataSource objectAtIndex:self.currentRow];
    NSURL *URL                       = [NSURL fileURLWithPath:model.path];
    movie.videoURL                   = URL;
    movie.videoTitle = model.name;
    movie.defaultThumblImg = model.thumbImage;
}

#pragma mark actions
- (void)fileChanageAction:(NSNotification *)notification
{
    // ZFileChangedNotification 通知是在子线程中发出的, 因此通知关联的方法会在子线程中执行
    NSLog(@"文件发生了改变, %@", [NSThread currentThread]);
    
    [self searchFilesFromDocument];
}

- (void)searchFilesFromDocument
{
    [[FileService shareInstance] searchFilesFromDocument:YES complete:^(NSMutableArray *modelArray) {
        self.dataSource = modelArray;
        [self.tableView reloadData];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
