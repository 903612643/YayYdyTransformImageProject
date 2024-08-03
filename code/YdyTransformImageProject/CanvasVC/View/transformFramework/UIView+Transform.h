//
//  UIView+Transform.h
//  01GestureTest
//
//  Created by YSKJ on 2017/10/20.
//  Copyright © 2017年 fcy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewTransformHander.h"
#import "ViewTransformConfiguration.h"
@interface UIView (Transform)
- (void) tf_showTransformOperationWithConfiguration:(ViewTransformConfiguration * _Nullable)configuration
                                           delegate:(id <ViewTransformeDelegate> _Nullable)delegate;
- (void) tf_hideTransformOperation;

- (void) tf_enable:(BOOL)isEnable forControlPoint:(CtrlViewType)controlPoint;
- (void) tf_enableDrag:(BOOL)isEnable;
- (void) tf_enableAll;
- (void) tf_disableAll;

- (void) tf_hideAllControlPoint;
- (void) tf_showAllControlPoint;

- (void) tf_transformRotationToNoAngle;

@end
