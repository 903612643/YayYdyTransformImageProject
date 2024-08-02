//
//  ImageTransform.m
//  01GestureTest
//
//  Created by YSKJ on 2017/10/19.
//  Copyright © 2017年 fcy. All rights reserved.
//
#import "ViewTransformConfiguration.h"
#import "CoordinateUtil.h"
#import "UIViewTransformUtil.h"
@implementation ViewTransformConfiguration
- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
        _controlPointSideLen = 15.0;
        _outsideControlPointLineImaginaryLineDashPattern = @[@4,@3];
        _controlPointTargetViewInset = 2.0;
        _isOutsideControlPointLineUsingImaginaryLine = YES;
        _connectionLineColor = [UIColor blackColor];
        _connectionLineWidth = 1 / [UIScreen mainScreen].scale;
        
        _shapeLayer = [[CAShapeLayer alloc] init];
        
        _outsideControlPointInset = 2;
        _controlPointToCapacities = @{
                                      @(CtrlViewType_lb) : @(CtrlViewCapacity_scale),
                                      @(CtrlViewType_lt) : @(CtrlViewCapacity_scale),
                                      @(CtrlViewType_rb) : @(CtrlViewCapacity_scale),
                                      @(CtrlViewType_rt) : @(CtrlViewCapacity_rotate),
                                      
                                      @(CtrlViewType_ls) : @(CtrlViewCapacity_scale),
                                      @(CtrlViewType_ts) : @(CtrlViewCapacity_scale),
                                      @(CtrlViewType_rs) : @(CtrlViewCapacity_scale),
                                      @(CtrlViewType_bs) : @(CtrlViewCapacity_scale),
                                      
                                      @(CtrlViewType_out) : @(CtrlViewCapacity_rotate)
                                      }.mutableCopy;
        //控制点 -> 背景色
        _controlPointToBackgroundColor = @{}.mutableCopy;
        for (id ctrlTypeObj in [ViewTransformConfiguration getAllControlPointType]){
            _controlPointToBackgroundColor[ctrlTypeObj] = [UIColor colorWithHex:0xB2CCFF];
        }
        //控制点 -> 背景图
        _controlPointToBackgroundImage = @{}.mutableCopy;
        _expandInsetGestureRecognition = CGPointMake(10,10);

        _maxWidth = CGFLOAT_MAX;
        _minWidth = CGFLOAT_MIN;
        _maxHeight = CGFLOAT_MAX;
        _minHeight = CGFLOAT_MIN;

    }
    
    return self;
}

- (void) configCtrlPointCapacity:(CtrlViewCapacity)capacities forControlPointType:(CtrlViewType)ctrlPointType{
    _controlPointToCapacities[@(ctrlPointType)] = @(capacities);
}
- (void) configBackgroundImage:(UIImage *)img forControlPointType:(CtrlViewType)ctrlPointType{
    _controlPointToBackgroundImage[@(ctrlPointType)] = img;
}
- (void) configBackgroundColor:(UIColor *)color forControlPointType:(CtrlViewType)ctrlPointType{
    _controlPointToBackgroundColor[@(ctrlPointType)] = color;
}
- (void) configAllControlPointBackgroundColor:(UIColor *)color{
    for (id ctrlTypeObj in [ViewTransformConfiguration getAllControlPointType]){
        _controlPointToBackgroundColor[ctrlTypeObj] = color;
    }
}
+ (NSArray*) getAllControlPointType{
    return @[
             @(CtrlViewType_lt),
             @(CtrlViewType_lb),
             @(CtrlViewType_rb),
             @(CtrlViewType_rt),
             
             @(CtrlViewType_ls),
             @(CtrlViewType_ts),
             @(CtrlViewType_rs),
             @(CtrlViewType_bs),
             @(CtrlViewType_out)
             ];
}
@end
