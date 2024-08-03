//
//  YSKJ_NaviView.m
//  YSKJ_MATCH
//
//  Created by YSKJ on 17/10/31.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import "YSKJ_NaviView.h"

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

#define FONT_Medium_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Medium" size:_size_]
#define FONT_Semibold_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Semibold" size:_size_]
#define FONT_Regular_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Regular" size:_size_]

// 16进制颜色值，如：#000000 , 注意：在使用的时候hexValue写成：0x000000
#define HexColor(hexValue) [UIColor colorWithRed:((float)(((hexValue) & 0xFF0000) >> 16))/255.0 green:((float)(((hexValue) & 0xFF00) >> 8))/255.0 blue:((float)((hexValue) & 0xFF))/255.0 alpha:1.0]

@implementation YSKJ_NaviView

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = HexColor(0x222A36);
        
        UIButton *addProBtn = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 60, 28, 50, 34)];
        [addProBtn setTitle:@"相册" forState:UIControlStateNormal];
        addProBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        addProBtn.tag = 1006;
        addProBtn.backgroundColor = [UIColor greenColor];
        addProBtn.layer.cornerRadius = 4;
        addProBtn.layer.masksToBounds = YES;
        [addProBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self addSubview:addProBtn];
        
        UIButton *addProBtn1 = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 60 - 60, 28, 50, 34)];
        [addProBtn1 setTitle:@"仓库" forState:UIControlStateNormal];
        addProBtn1.titleLabel.font = FONT_Semibold_SIZE(14);
        addProBtn1.tag = 1008;
        [addProBtn1 setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [self addSubview:addProBtn1];
        
        NSArray *image = @[@"whiteBack",@"Revoke",@"Forward",@"mirror",@"copy",@"delete.jpg"];
        NSArray *heiImage = @[@"whiteBack",@"Revoke1",@"Forward1",@"mirror1",@"copy1",@"delete1.jpg"];
        for (int i=0; i<image.count; i++) {
            UIButton *but = [[UIButton alloc] initWithFrame:CGRectMake(40*i , 27, 40, 40)];
            but.tag = 1000 + i;
          //  but.enabled = NO;
            [but setImage:[UIImage imageNamed:image[i]] forState:UIControlStateNormal];
            [but setImage:[UIImage imageNamed:heiImage[i]] forState:UIControlStateHighlighted];
            if (i==0) {
                but.imageEdgeInsets = UIEdgeInsetsMake(6, 14, 12, 6);
            }else{
                but.imageEdgeInsets = UIEdgeInsetsMake(10, 12, 16, 12);
            }
            if (i==3) {
                self.btn1 = but;
            }else  if (i==4) {
                self.btn2 = but;
            }else  if (i==5) {
                self.btn3 = but;
            }
            [self addSubview:but];
        }
        
        UIButton *lastBtn = [self viewWithTag:1005];
        
        UIButton *deleAll = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lastBtn.frame), 23, 44, 44)];
        deleAll.tag = 1007;
        [deleAll setTitle:@"清空" forState:UIControlStateNormal];
        deleAll.titleLabel.font = [UIFont systemFontOfSize:12];
        deleAll.enabled = NO;
        self.btn4 = deleAll;
        [deleAll setTitleColor:[HexColor(0xb1c0c8) colorWithAlphaComponent:0.6] forState:UIControlStateDisabled];
        [deleAll setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [self addSubview:deleAll];
        
        [self unCheckAction];
        
    }
    return self;
}

-(void)checkAction;
{
    self.btn1.enabled = YES;
    self.btn2.enabled = YES;
    self.btn3.enabled = YES;
}

-(void)unCheckAction;
{
    self.btn1.enabled = NO;
    self.btn2.enabled = NO;
    self.btn3.enabled = NO;
}

@end
