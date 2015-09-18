//
//  ViewController.m
//  TryAnimationControlByTimer
//
//  Created by AlanYen on 2015/9/18.
//  Copyright © 2015年 17Life. All rights reserved.
//

#import "ViewController.h"

#define kCellNumber    (30)

@interface CellInfo : NSObject

@property (assign, nonatomic) BOOL isStart;
@property (assign, nonatomic) NSInteger startValue;
@property (assign, nonatomic) NSInteger endValue;
@property (assign, nonatomic) NSInteger curValue;

@end

@implementation CellInfo

@end

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 建立資料
    self.dataArray = [NSMutableArray array];
    for (NSInteger i = 0; i < kCellNumber; i++) {
        CellInfo *info = [CellInfo new];
        info.isStart = NO;
        info.startValue = 1;
        info.endValue = (i + 1 + 10);
        info.curValue = info.startValue;
        [self.dataArray addObject:info];
    }
    
    // 啟動一個 Timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer
                                 forMode:NSRunLoopCommonModes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kCellNumber;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    [self configCell:cell AtIndexPath:indexPath];
    return cell;
}

- (void)configCell:(UITableViewCell *)cell AtIndexPath:(NSIndexPath *)indexPath {
    CellInfo *info = (CellInfo*)[self.dataArray objectAtIndex:indexPath.row];
    if (!info.isStart) {
        // 第一次出現,開始更新數值
        info.isStart = YES;
    }
    
    // 更新目前數值
    cell.textLabel.font = [UIFont systemFontOfSize:18.0f];
    cell.textLabel.text = [NSString stringWithFormat:@"%zd", info.curValue];
    cell.tag = indexPath.row;
}

- (void)updateTime {
    
    BOOL isAllStop = YES;
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        CellInfo *info = (CellInfo*)[self.dataArray objectAtIndex:i];
        if (info.isStart == YES) {
            if (info.curValue < info.endValue) {
                info.curValue += 1;
                
                // 重新載入 cell
                //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                //[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }
        }
        
        if (info.curValue < info.endValue) {
            isAllStop = NO;
        }
    }
    
    // 更新畫面上的 cell
    NSArray *cellArray = [self.tableView visibleCells];
    for (UITableViewCell *cell in cellArray) {
        CellInfo *info = (CellInfo*)[self.dataArray objectAtIndex:cell.tag];
        cell.textLabel.text = [NSString stringWithFormat:@"%zd", info.curValue];
    }

    // 決定是否停止 timer
    if (isAllStop) {
        NSLog(@"Timer 停止了!!");
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
