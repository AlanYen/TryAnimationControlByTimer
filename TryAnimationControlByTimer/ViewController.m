//
//  ViewController.m
//  TryAnimationControlByTimer
//
//  Created by AlanYen on 2015/9/18.
//  Copyright © 2015年 17Life. All rights reserved.
//

#import "ViewController.h"

#define kCellNumber    (30)
#define kTimerInterval (0.05f)

@interface CellInfo : NSObject

@property (assign, nonatomic) BOOL isStart;
@property (assign, nonatomic) CGFloat startValue;
@property (assign, nonatomic) CGFloat endValue;
@property (assign, nonatomic) CGFloat curValue;
@property (assign, nonatomic) CGFloat changeValue;

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
    [self initializeData];
    
    // 啟動一個 Timer
    self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                                  target:self
                                                selector:@selector(updateTime)
                                                userInfo:nil
                                                 repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer
                                 forMode:NSRunLoopCommonModes];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeData {
    
    if (self.dataArray) {
        [self.dataArray removeAllObjects];
        self.dataArray = nil;
    }
    self.dataArray = [NSMutableArray array];
    for (NSInteger i = 0; i < kCellNumber; i++) {
        CellInfo *info = [CellInfo new];
        info.isStart = NO;
        info.startValue = 1.0f;
        info.endValue = (i + 2.0f + i);
        info.curValue = info.startValue;
        info.changeValue = ((info.endValue - info.startValue) / ((1.0f) / kTimerInterval));
        [self.dataArray addObject:info];
    }
}

- (IBAction)onResetButtonPressed:(id)sender {

    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kTimerInterval * 2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initializeData];
        [self.tableView setContentOffset:CGPointMake(0.0f, -self.tableView.contentInset.top) animated:NO];
        [self.tableView reloadData];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerInterval
                                                      target:self
                                                    selector:@selector(updateTime)
                                                    userInfo:nil
                                                     repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.timer
                                     forMode:NSRunLoopCommonModes];
    });
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
    cell.textLabel.text = [NSString stringWithFormat:@"%zd", (NSInteger)info.curValue];
    cell.tag = indexPath.row;
}

- (void)updateTime {
    
    BOOL isAllStop = YES;
    for (NSInteger i = 0; i < self.dataArray.count; i++) {
        CellInfo *info = (CellInfo*)[self.dataArray objectAtIndex:i];
        if (info.isStart == YES) {
            if (info.curValue < info.endValue) {
                info.curValue += info.changeValue;
            }

            if (info.curValue > info.endValue) {
                info.curValue = info.endValue;
            }
        }

        // Debug
        NSLog(@"%f", info.curValue);
        
        if (info.curValue < info.endValue) {
            isAllStop = NO;
        }
    }
    
    // 更新畫面上的 cell
    NSArray *cellArray = [self.tableView visibleCells];
    for (UITableViewCell *cell in cellArray) {
        CellInfo *info = (CellInfo*)[self.dataArray objectAtIndex:cell.tag];
        cell.textLabel.text = [NSString stringWithFormat:@"%zd", (NSInteger)info.curValue];
    }

    // 決定是否停止 timer
    if (isAllStop) {
        NSLog(@"Timer 停止了!!");
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
