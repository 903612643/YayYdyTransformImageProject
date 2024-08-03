//
//  CanvasViewOptionHelper.m
//  YSKJ_MATCH
//
//  Created by yangdeyuan on 2024/5/16.
//  Copyright © 2024 com.yskj. All rights reserved.
//

#import "CanvasViewOptionHelper.h"

@implementation CanvasViewOptionHelper

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

//添加4个控制点与操作视图
-(void)addContorlPointViewWithFromSupView:(UIView*)canvas  drawModel:(YSKJ_drawModel*)model block:(void(^)(UIImageView *target,UIButton*_tempTLbutton,UIButton*_tempTRbutton,UIButton*_tempBLbutton,UIButton*_tempBRbutton))block;
{
    
    NSArray *arr = model.contorlPointArr;
    
     UIButton *tempTLbutton,*tempTRbutton,*tempBLbutton,*tempBRbutton;
     NSMutableArray *centerPointArr = [[NSMutableArray alloc] init];
     for (int i=0;i<arr.count;i++) {
         
         NSDictionary *contorlPointDict=arr[i];
         float ctx=[[contorlPointDict objectForKey:@"centerX"] floatValue];
         float cty=[[contorlPointDict objectForKey:@"centerY"] floatValue];
         UIButton *controlpoint=[[UIButton alloc] initWithFrame:CGRectMake(ctx-15, cty-15, 30, 30)];
         controlpoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
         [controlpoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
       //  controlpoint.backgroundColor = [UIColor purpleColor];
         [canvas addSubview:controlpoint];
         
         [centerPointArr addObject:@{@"centerX":[NSString stringWithFormat:@"%f",controlpoint.center.x],@"centerY":[NSString stringWithFormat:@"%f",controlpoint.center.y]}];
         
         if (i==0) { tempTLbutton=controlpoint;}else if (i==1){tempTRbutton=controlpoint;}else if (i==2){ tempBLbutton=controlpoint;}else if (i==3){tempBRbutton=controlpoint;}
     }
     
     if (centerPointArr.count>0) {
         __block CGFloat minX = [centerPointArr[0][@"centerX"] floatValue];
         __block CGFloat maxX = 0;
         __block CGFloat minY = [centerPointArr[0][@"centerY"] floatValue];
         __block CGFloat maxY = 0;
         NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
         [centerPointArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             if ([obj[@"centerX"] floatValue] < minX) {
                 minX = [obj[@"centerX"] floatValue];
             }
             if ([obj[@"centerX"] floatValue] > maxX) {
                 maxX = [obj[@"centerX"] floatValue];
             }
             if ([obj[@"centerY"] floatValue] < minY) {
                 minY = [obj[@"centerY"] floatValue];
             }
             if ([obj[@"centerY"] floatValue] > maxY) {
                 maxY = [obj[@"centerY"] floatValue];
             }
         }];
         [dict setObject:[NSString stringWithFormat:@"%f",minX] forKey:@"minX"];
         [dict setObject:[NSString stringWithFormat:@"%f",minY] forKey:@"minY"];
         [dict setObject:[NSString stringWithFormat:@"%f",maxX] forKey:@"maxX"];
         [dict setObject:[NSString stringWithFormat:@"%f",maxY] forKey:@"maxY"];
         
         UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(minX, minY, maxX - minX, maxY-minY)];
       //  view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
         view.userInteractionEnabled = YES;
         view.tag = 2024;
         [canvas addSubview:view];
         
         CGPoint point = [tempTRbutton convertPoint:CGPointMake(30.0, 30.0) toView:view];
         UIView *view1= [[UIView alloc] initWithFrame:CGRectMake(point.x - 30, point.y - 30, 30, 30)];
       //  view1.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.6];
         view1.tag = 1000;
         [view addSubview:view1];
         
         CGPoint point1 = [tempTLbutton convertPoint:CGPointMake(30.0, 30.0) toView:view];
         UIView *view2= [[UIView alloc] initWithFrame:CGRectMake(point1.x - 30, point1.y - 30, 30, 30)];
        // view2.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.6];
         view2.tag = 1001;
         [view addSubview:view2];
         
         CGPoint point2 = [tempBLbutton convertPoint:CGPointMake(30.0, 30.0) toView:view];
         UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(point2.x - 30, point2.y - 30, 30, 30)];
       //  view3.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.6];
         view3.tag = 1002;
         [view addSubview:view3];
         
         CGPoint point3 = [tempBRbutton convertPoint:CGPointMake(30.0, 30.0) toView:view];
         UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(point3.x - 30, point3.y - 30, 30, 30)];
      //   view4.backgroundColor = [[UIColor yellowColor] colorWithAlphaComponent:0.6];
         view4.tag = 1003;
         [view addSubview:view4];
         

         //把选中的controlPoint置前
         [tempTLbutton.superview bringSubviewToFront:tempTLbutton];
         [tempTRbutton.superview bringSubviewToFront:tempTRbutton];
         [tempBLbutton.superview bringSubviewToFront:tempBLbutton];
         [tempBRbutton.superview bringSubviewToFront:tempBRbutton];
         
         block(view,tempTLbutton,tempTRbutton,tempBLbutton,tempBRbutton);
       
     }
    
}

@end
