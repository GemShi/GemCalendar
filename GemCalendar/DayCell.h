//
//  DayCell.h
//  GemCalendar
//
//  Created by GemShi on 2017/3/31.
//  Copyright © 2017年 GemShi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DayCell : UICollectionViewCell

@property(nonatomic,strong)UILabel *dayLabel;
@property(nonatomic,strong)UIImageView *imgView;

-(void)refreshCellWithDay:(NSInteger)day;

-(void)refreshCellLastMonthWithDay:(NSInteger)day;

-(void)refreshCellNextMonthWithDay:(NSInteger)day;
@end
