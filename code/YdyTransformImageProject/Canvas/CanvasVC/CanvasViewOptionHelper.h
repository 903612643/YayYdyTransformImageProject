//
//  CanvasViewOptionHelper.h
//  YSKJ_MATCH
//
//  Created by yangdeyuan on 2024/5/16.
//  Copyright © 2024 com.yskj. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YSKJ_drawModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface CanvasViewOptionHelper : NSObject

//添加4个控制点与操作视图
-(void)addContorlPointViewWithFromSupView:(UIView*)canvas drawModel:(YSKJ_drawModel*)model block:(void(^)(UIImageView *target,UIButton*_tempTLbutton,UIButton*_tempTRbutton,UIButton*_tempBLbutton,UIButton*_tempBRbutton))block;

@end

NS_ASSUME_NONNULL_END
