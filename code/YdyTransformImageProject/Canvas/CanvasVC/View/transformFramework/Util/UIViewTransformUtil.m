//
//  UIViewTransformUtil.m
//  01GestureTest
//
//  Created by YSKJ on 2017/10/20.
//  Copyright © 2017年 fcy. All rights reserved.
//

#import "UIViewTransformUtil.h"
#import "CoordinateUtil.h"

@implementation TransformUtil
+ (CGFloat)widthScaleForTransfrom: (CGAffineTransform)transform{
    CGAffineTransform rotation = CGAffineTransformMakeRotation(atan2f(transform.b, transform.a));
    CGAffineTransform invertRotation = CGAffineTransformInvert(rotation);
    CGAffineTransform onlyScale = CGAffineTransformConcat(transform, invertRotation);
    CGFloat xscale = sqrt(onlyScale.a * onlyScale.a + onlyScale.c * onlyScale.c);
    return onlyScale.a < 0 ? -xscale : xscale;

}

+ (CGFloat)heightScaleForTransfrom: (CGAffineTransform)transform{
    CGAffineTransform rotation = CGAffineTransformMakeRotation(atan2f(transform.b, transform.a));
    CGAffineTransform invertRotation = CGAffineTransformInvert(rotation);
    CGAffineTransform onlyScale = CGAffineTransformConcat(transform, invertRotation);
    CGFloat yscale = sqrt(onlyScale.b * onlyScale.b + onlyScale.d * onlyScale.d);
    return onlyScale.d < 0 ? -yscale : yscale;

}

+ (CGFloat)heightScaleFromTransfrom: (CGAffineTransform)transform{
    CGAffineTransform t = transform;
    return sqrt(t.b * t.b + t.d * t.d);
}
@end

@implementation UIColor (Util)
+ (UIColor *)colorWithHex:(NSUInteger)hex{
    CGFloat red, green, blue;
    
    red = ((CGFloat)((hex >> 16) & 0xFF)) / ((CGFloat)0xFF);
    green = ((CGFloat)((hex >> 8) & 0xFF)) / ((CGFloat)0xFF);
    blue = ((CGFloat)((hex >> 0) & 0xFF)) / ((CGFloat)0xFF);
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:1];
}
@end

@implementation UIView (X)

// Coordinate utilities
- (CGPoint) offsetPointToParentCoordinates: (CGPoint) aPoint
{
    return CGPointMake(aPoint.x + self.center.x,
                       aPoint.y + self.center.y);
}

- (CGPoint) pointInViewCenterTerms: (CGPoint) aPoint
{
    return CGPointMake(aPoint.x - self.center.x,
                       aPoint.y - self.center.y);
}

- (CGPoint) pointInTransformedView: (CGPoint) aPoint
{
    CGPoint offsetItem = [self pointInViewCenterTerms:aPoint];
    CGPoint updatedItem = CGPointApplyAffineTransform(
                                                      offsetItem, self.transform);
    CGPoint finalItem =
    [self offsetPointToParentCoordinates:updatedItem];
    return finalItem;
}

- (CGRect) originalFrame
{
    CGAffineTransform currentTransform = self.transform;
    self.transform = CGAffineTransformIdentity;
    CGRect originalFrame = self.frame;
    self.transform = currentTransform;
    
    return originalFrame;
}

// These four methods return the positions of view elements
// with respect to the current transform

- (CGPoint) transformedTopLeft
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedTopRight
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedBottomRight
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.x += frame.size.width;
    point.y += frame.size.height;
    return [self pointInTransformedView:point];
}

- (CGPoint) transformedBottomLeft
{
    CGRect frame = self.originalFrame;
    CGPoint point = frame.origin;
    point.y += frame.size.height;
    return [self pointInTransformedView:point];
}
- (CGPoint) transformedCenter{
    return CGPointMake((self.transformedTopLeft.x + self.transformedBottomRight.x)/2,
                       (self.transformedTopLeft.y + self.transformedBottomRight.y)/2);
}
- (CGFloat) xscale
{
    CGAffineTransform t = self.transform;
    return sqrt(t.a * t.a + t.c * t.c);
}

- (CGFloat) yscale
{
    CGAffineTransform t = self.transform;
    return sqrt(t.b * t.b + t.d * t.d);
}

- (CGFloat) rotation
{
    CGAffineTransform t = self.transform;
    return atan2f(t.b, t.a);
}

- (CGFloat) tx
{
    CGAffineTransform t = self.transform;
    return t.tx;
}

- (CGFloat) ty
{
    CGAffineTransform t = self.transform;
    return t.ty;
}


+(__kindof UIView *) viewWithNib:(NSString*)nib owner:(id)owner {
    NSArray* array =[[NSBundle mainBundle] loadNibNamed:nib owner:owner options:nil];
    return array[0];
}

-(void) offset:(CGPoint)point {
    CGRect frame = self.frame;
    frame.origin.x += point.x;
    frame.origin.y += point.y;
    self.frame = frame;
}

-(void) setOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin.x = origin.x;
    frame.origin.y = origin.y;
    self.frame = frame;
}

-(void) setSize:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

-(CGPoint)origin {
    return self.frame.origin;
}

-(CGSize)size {
    return self.frame.size;
}

-(CGPoint)boundsCenter {
    CGSize size = self.bounds.size;
    return CGPointMake(size.width/2, size.height/2);
}

-(CGFloat) left {
    return self.frame.origin.x;
}

-(CGFloat) top {
    return self.frame.origin.y;
}

-(CGFloat) right {
    return [self left] + [self width];
}

-(CGFloat) bottom {
    return [self top] + [self height];
}

-(CGFloat) width {
    return self.frame.size.width;
}

-(CGFloat) height {
    return self.frame.size.height;
}

-(void) setLeft:(CGFloat)left {
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

-(void) setRight:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

-(void) setTop:(CGFloat)top {
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

-(void) setBottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

-(void) sizeZoomToScale:(CGFloat)scale
{
    CGRect frame = self.frame;
    frame.size.width = frame.size.width*scale;
    frame.size.height = frame.size.height*scale;
    self.frame = CGRectIntegral(frame);
}

-(void)frameZoomToScale:(CGFloat)scale
{
    CGRect frame = self.frame;
    frame.size.width = frame.size.width*scale;
    frame.size.height = frame.size.height*scale;
    frame.origin.x = frame.origin.x*scale;
    frame.origin.y = frame.origin.y*scale;
    self.frame = CGRectIntegral(frame);
}

-(void) setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(void) setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

-(void) clearSubviews {
    id subviews = self.subviews;
    NSUInteger count = [subviews count];
    for (int i = 0; i < count; i++) {
        [subviews[i] removeFromSuperview];
    }
}
@end
@implementation UIViewTransformUtil

@end
