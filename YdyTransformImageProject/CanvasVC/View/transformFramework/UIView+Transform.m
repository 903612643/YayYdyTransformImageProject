//
//  UIView+Transform.m
//  01GestureTest
//
//  Created by YSKJ on 2017/10/20.
//  Copyright © 2017年 fcy. All rights reserved.
//

#import "UIView+Transform.h"
#import "ViewTransformHander.h"
#import <objc/runtime.h>
#import "UIViewTransformUtil.h"

@implementation UIView (Transform)

- (void)setTransformer:(ViewTransformHander *)transformer{
    objc_setAssociatedObject(self, "_transformer", transformer, OBJC_ASSOCIATION_RETAIN);
}

- (ViewTransformHander *)transformer{
    return objc_getAssociatedObject(self, "_transformer");
}

- (void) tf_showTransformOperationWithConfiguration:(ViewTransformConfiguration * _Nullable)configuration
                                           delegate:(id <ViewTransformeDelegate> _Nullable)delegate{
    if (!self.transformer){
        self.transformer = [[ViewTransformHander alloc]initWith:self
                                              configuration:configuration
                                                   delegate:delegate];
    }
    [self.transformer showTransformOperation];
}
- (void) tf_hideTransformOperation{
    [self.transformer hideTransformOperation];
    self.transformer = nil;
}
- (void) tf_enable:(BOOL)isEnable forControlPoint:(CtrlViewType)controlPoint{
    [self.transformer enable:isEnable forControlPoint:controlPoint];
}
- (void) tf_enableDrag:(BOOL)isEnable{
    [self.transformer enableDrag:isEnable];
}
- (void) tf_enableAll{
    [self.transformer enableAll];
}
- (void) tf_disableAll{
    [self.transformer disableAll];
}

- (void) tf_hideAllControlPoint{
    [self.transformer hideAllControlPoint];
}
- (void) tf_showAllControlPoint{
    [self.transformer showAllControlPoint];
}

- (void) tf_transformRotationToNoAngle;
{
    [self.transformer transformRotationToNoAngle];
}

@end
