//
//  WaterWaveView.m
//  TuWaterWave
//
//  Created by zhantu wu on 2018/1/24.
//  Copyright © 2018年 weiqitong. All rights reserved.
//

#import "WaterWaveView.h"

//颜色RGB 16进制
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define waterColor UIColorFromRGB(0xC1EBFD)
#define mainColor UIColorFromRGB(0x41BEF8)

@interface WaterWaveView ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;   //渐变layer
@property (nonatomic, strong) CAShapeLayer *topLayer;           //视图起始位置与波纹顶部围成的区域layer
@property (nonatomic, strong) CAShapeLayer *waveLayer;          //波纹layer
@property (nonatomic, assign) CGFloat waveAmplitude;            //波纹振幅，A
@property (nonatomic, assign) CGFloat waveCycle;                //波纹周期，T = 2π/ω
@property (nonatomic, assign) CGFloat offsetX;                  //波浪x位移，φ
@property (nonatomic, assign) CGFloat waveSpeed;                //波纹速度，用来累加到相位φ上，达到波纹水平移动的效果
@property (nonatomic, assign) CGFloat currentWavePointY;        //当前波浪高度，k
@end

@implementation WaterWaveView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
    self.waveCycle = 2 * M_PI / CGRectGetWidth(self.frame);     //设置视图的整个宽度正好一个周期
    self.waveSpeed = - 0.1 / (2 * M_PI) ; //移动速率，-表示从左往右
    self.offsetX = 0;
}

- (void)startWave:(CGFloat)waveAmplitude
{
    self.waveAmplitude = waveAmplitude;
    self.currentWavePointY = CGRectGetHeight(self.frame) - waveAmplitude;
    
    [self setLayer];
    
    // 启动同步渲染绘制波纹
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setCurrentWave:)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)setLayer
{
    self.gradientLayer = [CAGradientLayer layer];
    self.gradientLayer.frame = self.bounds;
    self.gradientLayer.colors = @[(__bridge id)UIColorFromRGB(0x38BEFB).CGColor,(__bridge id)UIColorFromRGB(0x37B7FB).CGColor,(__bridge id)UIColorFromRGB(0x35A8FC).CGColor]; //设置渐变色
    self.gradientLayer.locations = @[@(0.25f),@(0.5f),@(0.75f)]; // 设置渐变点
    self.gradientLayer.startPoint = CGPointMake(0.0, 0.0); // 设置渐变起点
    self.gradientLayer.endPoint = CGPointMake(1.0, 0.0);   // 设置渐变终点
    
    self.topLayer = [CAShapeLayer layer];
    self.topLayer.fillColor = mainColor.CGColor;
    self.topLayer.strokeColor = mainColor.CGColor;
    
    self.waveLayer = [CAShapeLayer layer];
    self.waveLayer.fillColor = waterColor.CGColor;
    self.waveLayer.strokeColor = waterColor.CGColor;
    
    [self.layer addSublayer:self.gradientLayer];
    [self.gradientLayer setMask:self.topLayer];
    [self.layer addSublayer:self.waveLayer];
}

- (void)setCurrentWave:(CADisplayLink *)displayLink
{
    self.offsetX += self.waveSpeed;
    [self setCurrentWaveLayerPath];
}

- (void)setCurrentWaveLayerPath
{
    // 通过正弦曲线来绘制波浪形状
    CGMutablePathRef path = CGPathCreateMutable();
    CGMutablePathRef topPath = CGPathCreateMutable();
    
    CGFloat sinY = self.currentWavePointY;
    CGFloat cosY = sinY;
    float sinX,cosX;
    
    CGPathMoveToPoint(path, nil, 0, sinY);
    CGPathMoveToPoint(topPath, nil, 0, sinY);
    
    CGFloat width = CGRectGetWidth(self.frame);
    for (sinX = 0.0f; sinX <= width; sinX++)
    {
        // 正弦波浪公式
        sinY = self.waveAmplitude * sin(self.waveCycle * sinX + self.offsetX) + self.currentWavePointY;
        cosY = self.waveAmplitude * cos(self.waveCycle * sinX + self.offsetX) + self.currentWavePointY;
        CGPathAddLineToPoint(path, nil, sinX, sinY);
        
        //设置顶部填充路径
        if (sinY <= cosY) {
            CGPathAddLineToPoint(topPath, nil, sinX, sinY);
        } else {
            CGPathAddLineToPoint(topPath, nil, sinX, cosY);
        }
    }
    
    for (cosX = width; cosX >= 0; cosX--)
    {
        // 余弦波浪公式
        cosY = self.waveAmplitude * cos(self.waveCycle * cosX + self.offsetX) + self.currentWavePointY;
        CGPathAddLineToPoint(path, nil, cosX, cosY);
    }
    
    //设置顶部填充路径
    CGPathAddLineToPoint(topPath, nil, width, 0);
    CGPathAddLineToPoint(topPath, nil, 0, 0);
    
    CGPathCloseSubpath(path);
    CGPathCloseSubpath(topPath);
    
    self.waveLayer.path = path;
    self.topLayer.path = topPath;
    
    CGPathRelease(path);
    CGPathRelease(topPath);
}

@end
