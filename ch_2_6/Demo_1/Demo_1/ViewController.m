//
//  ViewController.m
//  Demo_1
//
//  Created by nethanhan on 2017/9/18.
//  Copyright © 2017年 ArWriter. All rights reserved.
//

#import "ViewController.h"
#import <ARKit/ARKit.h>

@interface ViewController ()<ARSCNViewDelegate>

// AR视图
@property (nonatomic, strong) ARSCNView *scnView;
// 会话配置
@property (nonatomic, strong) ARConfiguration *sessionConfig;

// 遮罩视图
@property (nonatomic, strong) UIView *maskView;
// 提示标签
@property (nonatomic, strong) UILabel *tipLabel;
// 信息展示标签
@property (nonatomic, strong) UILabel *infoLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 添加AR视图和界面元素
    [self.view addSubview:self.scnView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.tipLabel];
    [self.view addSubview:self.infoLabel];
    
    // 设置AR视图代理
    self.scnView.delegate = self;
    // 显示视图的FPS信息
    self.scnView.showsStatistics = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // 运行视图中自带的会话
    [self.scnView.session runWithConfiguration:self.sessionConfig];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // 暂停会话
    [self.scnView.session pause];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    // 当用户点击屏幕时，取出会话输出的帧
    matrix_float4x4 transform = self.scnView.session.currentFrame.camera.transform;
    NSMutableString *infoStr = [NSMutableString new];
    
    // 输出位姿信息
    for (int i=0; i<4; i++)
    {
        [infoStr appendString:[NSString stringWithFormat:@"%f,%f,%f,%f ",
                               transform.columns[i].x,transform.columns[i].y,
                               transform.columns[i].z,transform.columns[i].w]];
    }
    
    self.infoLabel.text = infoStr;
}

#pragma mark - ARSCNViewDelegate

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera
{
    // 判断状态
    switch (camera.trackingState)
    {
        case ARTrackingStateNotAvailable:
        {
            // 当追踪不可用时显示遮罩视图
            self.tipLabel.text = @"追踪不可用";
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha = 0.7;
            }];
        }
            break;
        case ARTrackingStateLimited:
        {
            // 当追踪有限时输出原因并显示遮罩视图
            NSString *title = @"有限的追踪，原因为：";
            NSString *desc;
            // 判断原因
            switch (camera.trackingStateReason)
            {
                case ARTrackingStateReasonNone:
                {
                    desc = @"不受约束";
                }
                    break;
                case ARTrackingStateReasonInitializing:
                {
                    desc = @"正在初始化，请稍等";
                }
                    break;
                case ARTrackingStateReasonExcessiveMotion:
                {
                    desc = @"设备移动过快，请注意";
                }
                    break;
                case ARTrackingStateReasonInsufficientFeatures:
                {
                    desc = @"提取不到足够的特征点，请移动设备";
                }
                    break;
                default:
                    break;
            }
            self.tipLabel.text = [NSString stringWithFormat:@"%@%@", title, desc];
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha = 0.6;
            }];
        }
            break;
        case ARTrackingStateNormal:
        {
            // 当追踪正常时遮罩视图隐藏
            self.tipLabel.text = @"追踪正常";
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha = 0.0;
            }];
        }
            break;
        default:
            break;
    }
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error
{
    // 当会话出错时输出出错信息
    switch (error.code)
    {
            // errorCode=100
        case ARErrorCodeUnsupportedConfiguration:
            self.tipLabel.text = @"当前设备不支持";
            break;
            // errorCode=101
        case ARErrorCodeSensorUnavailable:
            self.tipLabel.text = @"传感器不可用，请检查传感器";
            break;
            // errorCode=102
        case ARErrorCodeSensorFailed:
            self.tipLabel.text = @"传感器出错，请检查传感器";
            break;
            // errorCode=103
        case ARErrorCodeCameraUnauthorized:
            self.tipLabel.text = @"相机不可用，请检查相机";
            break;
            // errorCode=200
        case ARErrorCodeWorldTrackingFailed:
            self.tipLabel.text = @"追踪出错，请重置";
            break;
        default:
            break;
    }
}

- (void)sessionWasInterrupted:(ARSession *)session
{
    self.tipLabel.text = @"会话中断";
}

- (void)sessionInterruptionEnded:(ARSession *)session
{
    self.tipLabel.text = @"会话中断结束，已重置会话";
    [self.scnView.session runWithConfiguration:self.sessionConfig options: ARSessionRunOptionResetTracking];
}

#pragma mark - lazy

- (UILabel *)infoLabel
{
    if (nil == _infoLabel)
    {
        // 创建显示位姿的Label
        _infoLabel = [[UILabel alloc] init];
        _infoLabel.frame = CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame), CGRectGetWidth(self.tipLabel.frame), 150);
        _infoLabel.numberOfLines = 0;
        _infoLabel.textColor = [UIColor blackColor];
    }
    
    return _infoLabel;
}

- (UILabel *)tipLabel
{
    if (nil == _tipLabel)
    {
        // 创建提示信息的Label
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.frame = CGRectMake(0, 30, CGRectGetWidth(self.scnView.frame), 50);
        _tipLabel.numberOfLines = 0;
        _tipLabel.textColor = [UIColor blackColor];
    }
    
    return _tipLabel;
}

- (UIView *)maskView
{
    if (nil == _maskView)
    {
        // 创建遮罩视图
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        // 初始状态为白色蒙版遮罩
        _maskView.backgroundColor = [UIColor whiteColor];
        _maskView.alpha = 0.6;
    }
    
    return _maskView;
}

- (ARSCNView *)scnView
{
    if (nil == _scnView)
    {
        // 创建AR视图
        _scnView = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    }
    
    return _scnView;
}

- (ARConfiguration *)sessionConfig
{
    
    if (nil == _sessionConfig)
    {
        // 创建会话配置
        if ([ARWorldTrackingConfiguration isSupported])
        {
            // 创建可追踪6DOF的会话配置
            ARWorldTrackingConfiguration *worldConfig = [ARWorldTrackingConfiguration new];
            worldConfig.planeDetection = ARPlaneDetectionHorizontal;
            worldConfig.lightEstimationEnabled = YES;
            
            _sessionConfig = worldConfig;
            
        }else
        {
            // 创建可追踪3DOF的会话配置
            AROrientationTrackingConfiguration *orientationConfig = [AROrientationTrackingConfiguration new];
            _sessionConfig = orientationConfig;
            self.tipLabel.text = @"当前设备不支持6DOF追踪";
        }
    }
    
    return _sessionConfig;
}


@end
