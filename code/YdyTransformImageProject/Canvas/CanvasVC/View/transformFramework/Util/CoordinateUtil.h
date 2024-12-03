//
//  CoordinateUtil.h
//  ViewTransformDemo
//
//  Created by YSKJ on 2017/10/21.
//  Copyright © 2017年 com.sz.YSKJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//直线的一般式方程参数
typedef struct _LineGeneralFormEquationParam {
    CGFloat A;
    CGFloat B;
    CGFloat C;
}LineGeneralFormEquationParam;


@interface CoordinateUtil : NSObject
//MARK: - 点与点
/**
 返回经过两点的直线的一般式方程的 A、B、C参数。
 */
+ (LineGeneralFormEquationParam) lineGeneralFormEquationWithPoint1:(CGPoint)point1 point2:(CGPoint)point2;

+(CGFloat)distanceBetweenPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;

+(CGFloat)radiusBetweenPointA:(CGPoint)pointA andPointB:(CGPoint)pointB;

//MARK: - 点与直线
/**
 点到直线距离
 */
+ (CGFloat) distanceFromPoint:(CGPoint)point toLine:(LineGeneralFormEquationParam)line;

/**
 已知直线和该直线上一点的x坐标，求y坐标。
 */
+ (CGFloat) yForX:(CGFloat)x onLine:(LineGeneralFormEquationParam)line;
/**
 已知直线和该直线上一点的y坐标，求x坐标。
 */
+ (CGFloat) xForY:(CGFloat)y onLine:(LineGeneralFormEquationParam)line;


/**
 返回经过指定点并与指定直线垂直的直线

 @param point 经过的点
 @param line 指定垂直的直线
 */
+(LineGeneralFormEquationParam) linePassPoint:(CGPoint)point perpendicularToLine:(LineGeneralFormEquationParam)line;

//MARK: - 直线与直线
@end
