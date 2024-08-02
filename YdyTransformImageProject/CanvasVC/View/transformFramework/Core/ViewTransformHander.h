//
//  ImageTransform.h
//  01GestureTest
//
//  Created by YSKJ on 2017/10/19.
//  Copyright © 2017年 fcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class ViewTransformConfiguration;

typedef NS_ENUM(NSInteger,CtrlViewType){
    CtrlViewType_lt=1,
    CtrlViewType_lb=2,
    CtrlViewType_rb=3,
    CtrlViewType_rt=4,
    
    CtrlViewType_ls=6,
    CtrlViewType_ts=7,
    CtrlViewType_rs=8,
    CtrlViewType_bs=9,
    
    CtrlViewType_out=10
    
};

typedef NS_OPTIONS(NSInteger,CtrlViewCapacity){
    CtrlViewCapacity_rotate = 1 << 0,
    CtrlViewCapacity_move = 1 << 1,
    CtrlViewCapacity_scale = 1 << 2,
};

@protocol ViewTransformeDelegate <NSObject>
@optional
- (void) onScaleTotal:(CGPoint)totalScale panDurationScale:(CGPoint)panDurationScale targetView:(UIView*)targetView ges:(UIPanGestureRecognizer*)ges;

- (void) onRotateTotal:(CGFloat)totalAngle panDurationAngle:(CGFloat)panDurationAngle targetView:(UIView*)targetView ges:(UIPanGestureRecognizer*)ges ;

- (void) onDragPanDurationOffset:(CGPoint)panDurationOffset targetView:(UIView*)targetView ges:(UIPanGestureRecognizer*)ges;

- (void)tapGWihttargetView:(UIView*)targetView ges:(UITapGestureRecognizer*)ges;

@end

@interface ViewTransformHander : NSObject
- (instancetype) initWith:(UIView * )targetView
            configuration:(ViewTransformConfiguration *)configuration
                 delegate:(id<ViewTransformeDelegate>)delegate;

- (void) showTransformOperation;
- (void) hideTransformOperation;

- (void) enable:(BOOL)isEnable forControlPoint:(CtrlViewType)controlPoint;
- (void) enableDrag:(BOOL)isEnable;
- (void) enableAll;
- (void) disableAll;


- (void) hideAllControlPoint;
- (void) showAllControlPoint;

- (void) transformRotationToNoAngle;


@end

