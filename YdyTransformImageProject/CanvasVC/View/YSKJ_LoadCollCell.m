//
//  YSKJ_LoadCollCell.m
//  YSKJ_MATCH
//
//  Created by YSKJ on 17/12/18.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import "YSKJ_LoadCollCell.h"

@implementation YSKJ_LoadCollCell


-(id)initWithFrame:(CGRect)frame
{
    if (self == [super initWithFrame:frame]) {
        
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        self.backgroundColor = [UIColor whiteColor];
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.frame.size.width, self.frame.size.height)];
        bgView.layer.cornerRadius = 4;
        bgView.layer.masksToBounds = YES;
        bgView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.6].CGColor;
        bgView.layer.borderWidth = 0.5;
        [self addSubview:bgView];
        
        self.button = [[UIButton alloc]initWithFrame:bgView.bounds];
        self.button.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [bgView addSubview:self.button];
        
        self.panBut = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, self.frame.size.width-40, self.frame.size.height - 40)];
        self.panBut.alpha = 0.03;
        self.panBut.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.panBut];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [self.panBut addGestureRecognizer:pan];
        
        UIButton *addBut = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width-36, 0, 36 , 36)];
        [addBut setImage:[UIImage imageNamed:@"AddTo"] forState:UIControlStateNormal];
        _addBtn = addBut;
        [addBut addTarget:self action:@selector(addToCanvas:) forControlEvents:UIControlEventTouchUpInside];
        addBut.layer.cornerRadius = 5;
        addBut.layer.masksToBounds = YES;
        addBut.imageEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
        [self addSubview:addBut];
        
    }
    
    return self;
}



-(void)addToCanvas:(UIButton*)sender
{
    UICollectionViewCell *cell = (UICollectionViewCell*)sender.superview;
    
    NSIndexPath *indexPath = [(UICollectionView*)cell.superview indexPathForCell:cell];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(getRow:)]) {
        [self.delegate getRow:indexPath.row];
    }
}


-(void)setObjDict:(NSDictionary *)objDict
{
    _objDict = objDict;
    [self.button setImage:self.objDict[@"thumb_file"] forState:UIControlStateNormal];
    [self.panBut setImage:self.objDict[@"thumb_file"] forState:UIControlStateNormal];
}

-(void)pan:(UIPanGestureRecognizer*)ges
{
    
    NSDictionary *dict = @{@"ges":ges,
                           @"button":ges.view,
                           @"dict":self.objDict
                           };
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"panNotification" object:nil userInfo:dict];
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"beganPanNotification" object:nil userInfo:dict];
    }
    
    if (ges.state == UIGestureRecognizerStateEnded || ges.state == UIGestureRecognizerStateFailed){
        

       UIImage *image = self.objDict[@"thumb_file"];
        
        NSMutableDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:self.objDict];

        [tempDict setValue:[NSString stringWithFormat:@"%f",image.size.width] forKey:@"netW"];
        [tempDict setValue:[NSString stringWithFormat:@"%f",image.size.height] forKey:@"netH"];
      
        NSDictionary *dict = @{@"ges":ges,
                               @"button":ges.view,
                               @"dict":tempDict
                               };
        [[NSNotificationCenter defaultCenter] postNotificationName:@"endPanNotification" object:nil userInfo:dict];
            
    
        
    }
    
}

@end
