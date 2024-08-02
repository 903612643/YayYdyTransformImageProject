//
//  ViewTransformConfiguration.h
//  ViewTransformer
//
//  Created by YSKJ on 2017/10/22.
//  Copyright © 2017年 com.sz.YSKJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ViewTransformHander.h"
@interface ViewTransformConfiguration : NSObject
///控制点边长, 默认 15。（注：控制点是正方形）
@property(assign,nonatomic) CGFloat controlPointSideLen;
///控制点与目标view的间距, 默认 8。
@property(assign,nonatomic) CGFloat controlPointTargetViewInset;
///手势控制点手势识别热点扩展
/*
 默认手势检测区与控制点区域一致
 该参数用于扩展该区域 x >0 表示水平向外扩展 x<0 表示水平向内扩展，y同理
 默认(10,10)
 */
@property(assign,nonatomic) CGPoint expandInsetGestureRecognition;
///设置控制点背景色
- (void) configAllControlPointBackgroundColor:(UIColor *)color;
- (void) configBackgroundColor:(UIColor *)color forControlPointType:(CtrlViewType)ctrlPointType;
@property (strong,nonatomic,readonly) NSMutableDictionary * controlPointToBackgroundColor;
/**
 设置控制点背景图(注：背景图的设置会覆盖背景色的设置)
 @param img 背景图
 @param ctrlPointType 控制点类型
 */
- (void) configBackgroundImage:(UIImage *)img forControlPointType:(CtrlViewType)ctrlPointType;
@property (strong,nonatomic,readonly) NSMutableDictionary * controlPointToBackgroundImage;

/**
 设置控制点拥有的能力能力，默认情况下，各控制点能力如下：
 左上角、左下角、右下角 ：双轴缩放
 右上角：旋转
 左边、右边：水平方向缩放
 上边、下边：垂直方向缩放
 
 @param capacities 能力，用 | 符号连接多种能力
 @param ctrlPointType 控制点类型
 */
- (void) configCtrlPointCapacity:(CtrlViewCapacity)capacities forControlPointType:(CtrlViewType)ctrlPointType;

///外部控制点距离其他8个控制点所组成的矩形的距离 (目前这个属性有的bug 不精确 但是只是常量偏差)
@property(assign,nonatomic) CGFloat outsideControlPointInset;

///连接外部控制点的连线是否要用虚线 默认YES
@property(assign,nonatomic) BOOL isOutsideControlPointLineUsingImaginaryLine;
@property(strong,nonatomic) NSArray<NSNumber *> * outsideControlPointLineImaginaryLineDashPattern;

@property(strong,nonatomic,readonly) NSMutableDictionary * controlPointToCapacities;
///控制点之间连线的颜色
@property(strong,nonatomic) UIColor * connectionLineColor;
///控制点之间连线的宽度
@property(assign,nonatomic) CGFloat connectionLineWidth;

@property (assign,nonatomic) CGFloat maxWidth;
@property (assign,nonatomic) CGFloat minWidth;

@property (assign,nonatomic) CGFloat maxHeight;
@property (assign,nonatomic) CGFloat minHeight;

@property (nonatomic ,strong) CAShapeLayer *shapeLayer;


@end
