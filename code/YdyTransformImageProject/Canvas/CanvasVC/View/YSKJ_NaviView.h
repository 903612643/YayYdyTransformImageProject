//
//  YSKJ_NaviView.h
//  YSKJ_MATCH
//
//  Created by YSKJ on 17/10/31.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSKJ_NaviView : UIView

@property (strong, nonatomic)UIButton *btn1;
@property (strong, nonatomic)UIButton *btn2;
@property (strong, nonatomic)UIButton *btn3;
@property (strong, nonatomic)UIButton *btn4;

-(void)checkAction;

-(void)unCheckAction;

@end
