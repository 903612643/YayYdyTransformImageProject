//
//  CtrlPointCtnView.m
//  ViewTransformDemo
//
//  Created by 刘杰 on 2017/10/24.
//  Copyright © 2017年 com.sz.YSKJ. All rights reserved.
//

#import "CtrlPointCtnView.h"
#import "ViewTransformHander.h"
@implementation CtrlPointCtnView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    for (UIView * v in self.subviews) {
        if(v.tag == CtrlViewType_out){
            if(CGRectContainsPoint(v.frame, point)){
                return v;
            }
        }
    }
    return [super hitTest:point withEvent:event];
}
@end
