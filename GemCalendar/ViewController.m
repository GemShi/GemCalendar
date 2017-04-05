//
//  ViewController.m
//  GemCalendar
//
//  Created by GemShi on 2017/3/31.
//  Copyright © 2017年 GemShi. All rights reserved.
//

#import "ViewController.h"
#import "DayCell.h"

#define SCREEN_WIDTH self.view.bounds.size.width
#define SCREEN_HEIGHT self.view.bounds.size.height

@interface ViewController ()<UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,assign)NSInteger dayOfMonthAfter;//一个月有几天
@property(nonatomic,assign)NSInteger dayOfMonthPresent;//一个月有几天
@property(nonatomic,assign)NSInteger dayOfMonthBefore;//一个月有几天
@property(nonatomic,strong)NSArray *allDaysArrayAfter;//每一天都是周几
@property(nonatomic,strong)NSArray *allDaysArrayPresent;//每一天都是周几
@property(nonatomic,strong)NSArray *allDaysArrayBefore;//每一天都是周几
@property(nonatomic,assign)NSInteger rowsAfter;//日历中该月的行数
@property(nonatomic,assign)NSInteger rowsPresent;//日历中前月的行数
@property(nonatomic,assign)NSInteger rowsBefore;//日历中前前月的行数
@property(nonatomic,copy)NSString *dispalyMonth;//当前显示月
@end

static NSString *cellID = @"cellCalendar";

@implementation ViewController
{
    UIView *_calendarView;
    UIScrollView *_scrollView;
    UICollectionView *_collectionBefore;
    UICollectionView *_collectionPresent;
    UICollectionView *_collectionAfter;
    UILabel *_yearMonthLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    
    [self initData];
    
    [self createUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)initData
{
    self.allDaysArrayAfter = [[NSArray alloc]initWithArray:[self getAllDaysWithCalender:[NSDate date]]];
    self.dayOfMonthAfter = [self getNumberOfDaysInMonthWithDate:[NSDate date]]; //一个月的总天数
    self.rowsAfter = [self getRowsInMonthWithAllDaysArray:_allDaysArrayAfter];
    
    NSDate *lastMonth = [self getMonthWithDistance:1 AndOrder:NSOrderedDescending];
    NSDate *lastTwoMonth = [self getMonthWithDistance:2 AndOrder:NSOrderedDescending];
    
    self.allDaysArrayPresent = [[NSArray alloc]initWithArray:[self getAllDaysWithCalender:lastMonth]];
    self.dayOfMonthPresent = [self getNumberOfDaysInMonthWithDate:lastMonth];
    self.rowsPresent = [self getRowsInMonthWithAllDaysArray:_allDaysArrayPresent];
    
    self.allDaysArrayBefore = [[NSArray alloc]initWithArray:[self getAllDaysWithCalender:lastTwoMonth]];
    self.dayOfMonthBefore = [self getNumberOfDaysInMonthWithDate:lastTwoMonth];
    self.rowsBefore = [self getRowsInMonthWithAllDaysArray:_allDaysArrayBefore];
    
    //获取当前显示月
    self.dispalyMonth = [self getDisplayMonthWithDate:[NSDate date]];
    
//    NSLog(@"%@",_dispalyMonth);
    //[self getMonthWithDistance:1 AndOrder:NSOrderedDescending]
}

/**
  *  获取当月中所有天数是周几
  */
- (NSArray *) getAllDaysWithCalender:(NSDate *)date
{
    NSInteger dayCount = [self getNumberOfDaysInMonthWithDate:date]; //一个月的总天数
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSDate * currentDate = date;
    [formatter setDateFormat:@"yyyy-MM"];
    NSString * str = [formatter stringFromDate:currentDate];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSMutableArray *dayArray = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i <= dayCount; i++) {
        NSString * sr = [NSString stringWithFormat:@"%@-%ld",str,i];
        NSDate *suDate = [formatter dateFromString:sr];
        [dayArray addObject:[self getweekDayWithDate:suDate]];
    }
    return dayArray;
}

/**
 *  获得某天的数据
 *
 *  获取指定的日期是星期几
 */
- (id) getweekDayWithDate:(NSDate *) date
{
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // 指定日历的算法
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:date];
    
    // 1周日，2周一 3.以此类推
    return @([comps weekday]);
}

// 获取当月的天数
- (NSInteger)getNumberOfDaysInMonthWithDate:(NSDate *)date
{
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]; // 指定日历的算法
    NSDate * currentDate = date; // 这个日期可以你自己给定
    NSRange range = [calendar rangeOfUnit:NSCalendarUnitDay
                                   inUnit: NSCalendarUnitMonth
                                  forDate:currentDate];
    return range.length;
}

//获取一个月的行数
-(NSInteger)getRowsInMonthWithAllDaysArray:(NSArray *)allDaysArray
{
    NSInteger firstDay = [[allDaysArray firstObject] integerValue];
    NSInteger rows = (allDaysArray.count - (8 - firstDay)) / 7 + 1;
    return (allDaysArray.count - (8 - firstDay)) % 7 > 0 ? rows + 1 : rows;
}

//获取上几个月或者下几个月
-(NSDate *)getMonthWithDistance:(NSInteger)distance AndOrder:(NSComparisonResult)comparisonResult
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *cmp = [calendar components:(NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:[[NSDate alloc] init]];
    NSDate *date = [calendar dateFromComponents:cmp];
    
    if (comparisonResult == NSOrderedAscending) {
        //升序
        [cmp setMonth:[cmp month] + distance];
        date = [calendar dateFromComponents:cmp];
    }else if (comparisonResult == NSOrderedDescending){
        //降序
        [cmp setMonth:[cmp month] - distance];
        date = [calendar dateFromComponents:cmp];
    }
    return date;
}

-(void)createUI
{
    _calendarView = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 167, 125, 334, 306)];
    _calendarView.layer.cornerRadius = 5.0;
    _calendarView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_calendarView];
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _calendarView.frame.size.height - 187, _calendarView.frame.size.width, 187)];
    _scrollView.contentSize = CGSizeMake(_calendarView.frame.size.width * 3, 0);
    _scrollView.pagingEnabled = YES;
    _scrollView.backgroundColor = [UIColor whiteColor];
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.contentOffset = CGPointMake(_calendarView.frame.size.width * 2, 0);
    [_calendarView addSubview:_scrollView];
    
    //标题栏
    UIView *titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _calendarView.frame.size.width, 47)];
    titleView.backgroundColor = [UIColor redColor];
    [_calendarView addSubview:titleView];
    UIButton *offButton = [[UIButton alloc]initWithFrame:CGRectMake(titleView.frame.size.width - 20, 10, 10, 10)];
    [offButton setBackgroundImage:[UIImage imageNamed:@"off"] forState:UIControlStateNormal];
    [offButton addTarget:self action:@selector(closeCalendar:) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:offButton];
    
    //年月
    _yearMonthLabel = [[UILabel alloc]initWithFrame:CGRectMake(_calendarView.center.x - _calendarView.frame.origin.x - 50, titleView.frame.origin.y + titleView.frame.size.height, 100, 48)];
    _yearMonthLabel.text = _dispalyMonth;
    _yearMonthLabel.textAlignment = NSTextAlignmentCenter;
    _yearMonthLabel.font = [UIFont systemFontOfSize:16];
    [_calendarView addSubview:_yearMonthLabel];
    
    UIButton *leftButton = [[UIButton alloc]initWithFrame:CGRectMake(_yearMonthLabel.frame.origin.x - 30, _yearMonthLabel.center.y - 5, 10, 10)];
    [leftButton setBackgroundImage:[UIImage imageNamed:@"zuo"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(leftSlide:) forControlEvents:UIControlEventTouchUpInside];
    [_calendarView addSubview:leftButton];
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(_yearMonthLabel.frame.origin.x + _yearMonthLabel.frame.size.width + 20, _yearMonthLabel.center.y - 5, 10, 10)];
    [rightButton setBackgroundImage:[UIImage imageNamed:@"you"] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightSlide:) forControlEvents:UIControlEventTouchUpInside];
    [_calendarView addSubview:rightButton];
    
    //星期
    UIView *weekView = [[UIView alloc]initWithFrame:CGRectMake(0, _yearMonthLabel.frame.origin.y + _yearMonthLabel.frame.size.height, _calendarView.frame.size.width, 25)];
    weekView.backgroundColor = [UIColor colorWithRed:0.98 green:0.90 blue:0.91 alpha:1.00];
    [_calendarView addSubview:weekView];
    NSArray *weekArray = @[@"日",@"一",@"二",@"三",@"四",@"五",@"六"];
    for (int i = 0; i < weekArray.count; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(weekView.frame.size.width / weekArray.count * i, 0, weekView.frame.size.width / weekArray.count, weekView.frame.size.height)];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = [NSString stringWithFormat:@"%@",weekArray[i]];
        label.textColor = [UIColor redColor];
        label.font = [UIFont systemFontOfSize:12];
        [weekView addSubview:label];
    }
    
    //日历
    UICollectionViewFlowLayout *flowLayout1 = [[UICollectionViewFlowLayout alloc]init];
    flowLayout1.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionBefore = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) collectionViewLayout:flowLayout1];
    _collectionBefore.backgroundColor = [UIColor whiteColor];
    _collectionBefore.delegate = self;
    _collectionBefore.dataSource = self;
    _collectionBefore.scrollEnabled = NO;
    [_scrollView addSubview:_collectionBefore];
    
    UICollectionViewFlowLayout *flowLayout2 = [[UICollectionViewFlowLayout alloc]init];
    flowLayout2.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionPresent = [[UICollectionView alloc]initWithFrame:CGRectMake(_scrollView.frame.size.width, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) collectionViewLayout:flowLayout2];
    _collectionPresent.backgroundColor = [UIColor whiteColor];
    _collectionPresent.delegate = self;
    _collectionPresent.dataSource = self;
    _collectionPresent.scrollEnabled = NO;
    [_scrollView addSubview:_collectionPresent];
    
    UICollectionViewFlowLayout *flowLayout3 = [[UICollectionViewFlowLayout alloc]init];
    flowLayout3.scrollDirection = UICollectionViewScrollDirectionVertical;
    _collectionAfter = [[UICollectionView alloc]initWithFrame:CGRectMake(_scrollView.frame.size.width * 2, 0, _scrollView.frame.size.width, _scrollView.frame.size.height) collectionViewLayout:flowLayout3];
    _collectionAfter.backgroundColor = [UIColor whiteColor];
    _collectionAfter.delegate = self;
    _collectionAfter.dataSource = self;
    _collectionAfter.scrollEnabled = NO;
    [_scrollView addSubview:_collectionAfter];
    
    [_collectionBefore registerClass:[DayCell class] forCellWithReuseIdentifier:cellID];
    [_collectionPresent registerClass:[DayCell class] forCellWithReuseIdentifier:cellID];
    [_collectionAfter registerClass:[DayCell class] forCellWithReuseIdentifier:cellID];
}

#pragma mark - collectionView代理方法
//确定section的个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//确定其中的item数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (collectionView == _collectionAfter) {
        return 7 * _rowsAfter;
    }else if (collectionView == _collectionPresent){
        return 7 * _rowsPresent;
    }else{
        return 7 * _rowsBefore;
    }
}

//创建cell
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DayCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];\
    if (collectionView == _collectionAfter) {
        if (indexPath.item >= [[_allDaysArrayAfter firstObject] integerValue] - 1 && indexPath.item < _dayOfMonthAfter + ([[_allDaysArrayAfter firstObject] integerValue] - 1)) {
            NSInteger index = indexPath.item - ([[_allDaysArrayAfter firstObject] integerValue] - 1);
            [cell refreshCellWithDay:index + 1];
        }else if (indexPath.item < [[_allDaysArrayAfter firstObject] integerValue] - 1){
            NSInteger lastMonthDay = [self getNumberOfDaysInMonthWithDate:[self getMonthWithDistance:1 AndOrder:NSOrderedDescending]];
            NSInteger lastDay = lastMonthDay - ([[_allDaysArrayAfter firstObject] integerValue] - 1) + 1;
            [cell refreshCellLastMonthWithDay:lastDay + indexPath.item];
            
        }else{
            NSInteger monthDay = [self getNumberOfDaysInMonthWithDate:[NSDate date]];
            NSInteger nextDay = monthDay + [[_allDaysArrayAfter firstObject] integerValue] - 1;
            [cell refreshCellNextMonthWithDay:indexPath.item + 1 - nextDay];
            
        }
    }else if (collectionView == _collectionPresent){
        if (indexPath.item >= [[_allDaysArrayPresent firstObject] integerValue] - 1 && indexPath.item < _dayOfMonthPresent + ([[_allDaysArrayPresent firstObject] integerValue] - 1)) {
            NSInteger index = indexPath.item - ([[_allDaysArrayPresent firstObject] integerValue] - 1);
            [cell refreshCellWithDay:index + 1];
        }else if (indexPath.item < [[_allDaysArrayPresent firstObject] integerValue] - 1){
            NSInteger lastMonthDay = [self getNumberOfDaysInMonthWithDate:[self getMonthWithDistance:2 AndOrder:NSOrderedDescending]];
            NSInteger lastDay = lastMonthDay - ([[_allDaysArrayPresent firstObject] integerValue] - 1) + 1;
            [cell refreshCellLastMonthWithDay:lastDay + indexPath.item];
        }else{
            NSInteger monthDay = [self getNumberOfDaysInMonthWithDate:[self getMonthWithDistance:1 AndOrder:NSOrderedDescending]];
            NSInteger nextDay = monthDay + [[_allDaysArrayPresent firstObject] integerValue] - 1;
            [cell refreshCellNextMonthWithDay:indexPath.item + 1 - nextDay];
        }
    }else{
        if (indexPath.item >= [[_allDaysArrayBefore firstObject] integerValue] - 1 && indexPath.item < _dayOfMonthBefore + ([[_allDaysArrayBefore firstObject] integerValue] - 1)) {
            NSInteger index = indexPath.item - ([[_allDaysArrayBefore firstObject] integerValue] - 1);
            [cell refreshCellWithDay:index + 1];
        }else if (indexPath.item < [[_allDaysArrayBefore firstObject] integerValue] - 1){
            NSInteger lastMonthDay = [self getNumberOfDaysInMonthWithDate:[self getMonthWithDistance:3 AndOrder:NSOrderedDescending]];
            NSInteger lastDay = lastMonthDay - ([[_allDaysArrayBefore firstObject] integerValue] - 1) + 1;
            [cell refreshCellLastMonthWithDay:lastDay + indexPath.item];
        }else{
            NSInteger monthDay = [self getNumberOfDaysInMonthWithDate:[self getMonthWithDistance:2 AndOrder:NSOrderedDescending]];
            NSInteger nextDay = monthDay + [[_allDaysArrayBefore firstObject] integerValue] - 1;
            [cell refreshCellNextMonthWithDay:indexPath.item + 1 - nextDay];
        }
    }
    return cell;
}

//设置cell大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (collectionView == _collectionAfter) {
        return CGSizeMake((_collectionAfter.frame.size.width - 15) / 7, _collectionAfter.frame.size.height / _rowsAfter);
    }else if (collectionView == _collectionPresent){
        return CGSizeMake((_collectionPresent.frame.size.width - 15) / 7, _collectionPresent.frame.size.height / _rowsPresent);
    }else{
        return CGSizeMake((_collectionBefore.frame.size.width - 15) / 7, _collectionBefore.frame.size.height / _rowsBefore);
    }
}

//设置间距
//垂直间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

//水平间距
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

//四周间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    //上左下右
    return UIEdgeInsetsMake(0, 1, 0, 1);
}

//点击方法
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld  %ld",indexPath.item,indexPath.row);
}

#pragma mark - 滑动按钮and代理方法
-(void)leftSlide:(UIButton *)button
{
    NSInteger index = _scrollView.contentOffset.x / _calendarView.frame.size.width;
    if (index > 0) {
        index--;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointMake(_calendarView.frame.size.width * index, 0);
    }];
    self.dispalyMonth = [self getDisplayMonthWithDate:[self getMonthWithDistance:labs(index - 2) AndOrder:NSOrderedDescending]];
    _yearMonthLabel.text = _dispalyMonth;
}

-(void)rightSlide:(UIButton *)button
{
    NSInteger index = _scrollView.contentOffset.x / _calendarView.frame.size.width;
    if (index < 2) {
        index++;
    }
    [UIView animateWithDuration:0.3 animations:^{
        _scrollView.contentOffset = CGPointMake(_calendarView.frame.size.width * index, 0);
    }];
    self.dispalyMonth = [self getDisplayMonthWithDate:[self getMonthWithDistance:labs(2 - index) AndOrder:NSOrderedDescending]];
    _yearMonthLabel.text = _dispalyMonth;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat halfWidth = _scrollView.frame.size.width / 2;
    CGFloat offsetX = scrollView.contentOffset.x;
    if (offsetX <= halfWidth) {
        self.dispalyMonth = [self getDisplayMonthWithDate:[self getMonthWithDistance:2 AndOrder:NSOrderedDescending]];
        _yearMonthLabel.text = _dispalyMonth;
    }else if (offsetX >= halfWidth * 3){
        self.dispalyMonth = [self getDisplayMonthWithDate:[NSDate date]];
        _yearMonthLabel.text = _dispalyMonth;
    }else{
        self.dispalyMonth = [self getDisplayMonthWithDate:[self getMonthWithDistance:1 AndOrder:NSOrderedDescending]];
        _yearMonthLabel.text = _dispalyMonth;
    }
}

#pragma mark - 关闭按钮
-(void)closeCalendar:(UIButton *)button
{
    
}

#pragma mark - 获取当前显示月
-(NSString *)getDisplayMonthWithDate:(NSDate *)date
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSDate * currentDate = date;
    [formatter setDateFormat:@"yyyy-MM"];
    NSString *str = [formatter stringFromDate:currentDate];
    NSArray *strArr = [str componentsSeparatedByString:@"-"];
    NSString *displayStr = [NSString stringWithFormat:@"%@年%@月",[strArr firstObject],[strArr lastObject]];
    return displayStr;
}

@end
