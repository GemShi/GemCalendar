//
//  DayCell.m
//  GemCalendar
//
//  Created by GemShi on 2017/3/31.
//  Copyright © 2017年 GemShi. All rights reserved.
//

#import "DayCell.h"

@implementation DayCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self createLayout];
    }
    return self;
}

-(void)createLayout
{
    self.dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height / 3 * 2)];
    self.dayLabel.textAlignment = NSTextAlignmentCenter;
    self.dayLabel.textColor = [UIColor colorWithRed:0.38 green:0.38 blue:0.38 alpha:1.00];
    self.dayLabel.font = [UIFont systemFontOfSize:16];
    [self.contentView addSubview:_dayLabel];
    self.imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, _dayLabel.frame.origin.y + _dayLabel.frame.size.height, self.contentView.bounds.size.width, self.contentView.bounds.size.height / 3)];
    [self.contentView addSubview:_imgView];
}

-(void)refreshCellWithDay:(NSInteger)day
{
    self.dayLabel.text = [NSString stringWithFormat:@"%ld",day];
}

-(void)refreshCellLastMonthWithDay:(NSInteger)day
{
    self.dayLabel.text = [NSString stringWithFormat:@"%ld",day];
    self.dayLabel.textColor = [UIColor colorWithRed:0.81 green:0.81 blue:0.81 alpha:1.00];
}

-(void)refreshCellNextMonthWithDay:(NSInteger)day
{
    self.dayLabel.text = [NSString stringWithFormat:@"%ld",day];
    self.dayLabel.textColor = [UIColor colorWithRed:0.81 green:0.81 blue:0.81 alpha:1.00];
}

@end
