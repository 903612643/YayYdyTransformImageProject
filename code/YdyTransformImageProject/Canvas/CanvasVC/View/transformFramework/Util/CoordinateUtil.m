//
//  CoordinateUtil.m
//  ViewTransformDemo
//
//  Created by YSKJ on 2017/10/21.
//  Copyright © 2017年 com.sz.YSKJ. All rights reserved.
//

#import "CoordinateUtil.h"

@implementation CoordinateUtil
+ (LineGeneralFormEquationParam) lineGeneralFormEquationWithPoint1:(CGPoint)point1 point2:(CGPoint)point2{
    LineGeneralFormEquationParam line = {
        (point2.y - point1.y),
        (point1.x - point2.x),
        (point2.x * point1.y - point1.x * point2.y)};
    return line;
}
+(CGFloat)distanceBetweenPointA:(CGPoint)pointA andPointB:(CGPoint)pointB{
    CGFloat x = pointA.x - pointB.x;
    CGFloat y = pointA.y - pointB.y;
    return sqrt(x*x + y*y);
}
+(CGFloat)radiusBetweenPointA:(CGPoint)pointA andPointB:(CGPoint)pointB{
    CGFloat x = pointA.x - pointB.x;
    CGFloat y = pointA.y - pointB.y;
    return atan2(x, y);
}

+ (CGFloat) yForX:(CGFloat)x onLine:(LineGeneralFormEquationParam)line{
    NSAssert(line.B != 0, @"此时y有无穷个，无法计算");
    return (-line.C - line.A * x) / line.B;
}
+ (CGFloat) xForY:(CGFloat)y onLine:(LineGeneralFormEquationParam)line{
    NSAssert(line.A != 0, @"此时x有无穷个，无法计算");
    return (-line.C - line.B * y) / line.A;
}
+ (CGFloat) distanceFromPoint:(CGPoint)point toLine:(LineGeneralFormEquationParam)line{
    return fabs(line.A * point.x + line.B * point.y + line.C)
            /
           (sqrtf(line.A*line.A + line.B * line.B));
}
+(LineGeneralFormEquationParam) linePassPoint:(CGPoint)point perpendicularToLine:(LineGeneralFormEquationParam)line{
    if(line.B == 0){
        LineGeneralFormEquationParam rsLine = {
            0,
            -1,
            point.y
        };
        return rsLine;
    }else if(line.A == 0){
        LineGeneralFormEquationParam rsLine = {
            -1,
            0,
            point.x
        };
        return rsLine;
    }else{
        LineGeneralFormEquationParam rsLine = {
            -line.B,
            line.A,
            (line.B * point.x - line.A * point.y)
        };
        return rsLine;
    }
}
@end
