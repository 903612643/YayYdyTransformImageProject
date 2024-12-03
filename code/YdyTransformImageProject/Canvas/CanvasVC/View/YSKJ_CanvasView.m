//
//  YSKJ_CanvasView.m
//  YSKJ_MATCH
//
//  Created by YSKJ on 17/10/31.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import "YSKJ_CanvasView.h"

@implementation YSKJ_CanvasView

-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
//        self.layer.cornerRadius = 5;
//        self.layer.masksToBounds = YES;
  //      self.layer.shadowColor = [UIColor blackColor].CGColor;
//        self.layer.shadowOffset = CGSizeMake(4, 7);
//        self.layer.shadowOpacity = 0.4f;
//        self.layer.shadowRadius = 4.0;
        self.clipsToBounds = NO;
        
    }
    return self;
}

@end
