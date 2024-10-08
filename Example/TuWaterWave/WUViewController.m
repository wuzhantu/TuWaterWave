//
//  WUViewController.m
//  TuWaterWave
//
//  Created by wuzhantu on 11/05/2019.
//  Copyright (c) 2019 wuzhantu. All rights reserved.
//

#import "WUViewController.h"
#import "WaterWaveView.h"

#define d_screen_width [UIScreen mainScreen].bounds.size.width
#define d_screen_height [UIScreen mainScreen].bounds.size.height

@interface WUViewController ()

@end

@implementation WUViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupView];
}

- (void)setupView {
    //初始化一个水波视图，比较简单
    WaterWaveView *waterWaveView = [[WaterWaveView alloc] initWithFrame:CGRectMake(0, 0, d_screen_width, 384)];
    [self.view addSubview:waterWaveView];
    [waterWaveView startWave:15];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
