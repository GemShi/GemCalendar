//
//  ViewController.m
//  GemCalendar
//
//  Created by GemShi on 2017/3/31.
//  Copyright © 2017年 GemShi. All rights reserved.
//

#import "ViewController.h"
#import "GemCalendarView.h"

#define SCREEN_WIDTH self.view.bounds.size.width
#define SCREEN_HEIGHT self.view.bounds.size.height

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIButton *showCalendarButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.center.x - 100, 100, 200, 50)];
    [showCalendarButton setBackgroundColor:[UIColor orangeColor]];
    [showCalendarButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [showCalendarButton setTitle:@"显示日历" forState:UIControlStateNormal];
    [showCalendarButton addTarget:self action:@selector(showCalendar:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:showCalendarButton];
}

-(void)showCalendar:(UIButton *)button
{
    GemCalendarView *calendarView = [[GemCalendarView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:calendarView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
