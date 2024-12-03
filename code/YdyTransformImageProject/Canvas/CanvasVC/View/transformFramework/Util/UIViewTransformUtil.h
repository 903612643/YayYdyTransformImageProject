//
//  UIViewTransformUtil.h
//  01GestureTest
//
//  Created by YSKJ on 2017/10/20.
//  Copyright © 2017年 fcy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TransformUtil : NSObject
+ (CGFloat)widthScaleForTransfrom: (CGAffineTransform)transform;
+ (CGFloat)heightScaleForTransfrom: (CGAffineTransform)transform;
@end

@interface UIColor (Util)
+ (UIColor *)colorWithHex:(NSUInteger)hex;
@end

@interface UIView (X)

// Coordinate utilities
- (CGPoint) offsetPointToParentCoordinates: (CGPoint) aPoint;

- (CGPoint) pointInViewCenterTerms: (CGPoint) aPoint;

- (CGPoint) pointInTransformedView: (CGPoint) aPoint;

- (CGRect) originalFrame;
// These four methods return the positions of view elements
// with respect to the current transform

- (CGPoint) transformedTopLeft;

- (CGPoint) transformedTopRight;

- (CGPoint) transformedBottomRight;

- (CGPoint) transformedBottomLeft;

- (CGPoint) transformedCenter;

- (CGFloat) xscale;

- (CGFloat) yscale;

- (CGFloat) rotation;

- (CGFloat) tx;

- (CGFloat) ty;
+(__kindof UIView *) viewWithNib:(NSString*)nib owner:(id)owner;

-(void) offset:(CGPoint)point;

-(void) setOrigin:(CGPoint)origin;

-(void) setSize:(CGSize)size;

-(CGPoint) origin;

-(CGSize) size;

-(CGPoint) boundsCenter;

-(CGFloat) left;

-(CGFloat) top;

-(CGFloat) right;

-(CGFloat) bottom;

-(CGFloat) width;

-(CGFloat) height;

-(void)sizeZoomToScale:(CGFloat)scale;

-(void)frameZoomToScale:(CGFloat)scale;

-(void) setWidth:(CGFloat)width;

-(void) setHeight:(CGFloat)height;

-(void) setLeft:(CGFloat)lef;

-(void) setRight:(CGFloat)right;

-(void) setTop:(CGFloat)top;

-(void) setBottom:(CGFloat)bottom;

-(void) clearSubviews;

-(void) replaceView:(UIView*)view atIndex:(int)index;

-(UIView*) viewAtIndex:(int)index;

-(void) removeViewAtIndex:(int)index;

-(void) transitionToAddSubview:(UIView*)view duration:(NSTimeInterval)duration;

-(void) transitionToRemoveFromSuperview:(NSTimeInterval)duration;

-(BOOL) pointInsideFrame:(CGPoint)location;

-(NSUInteger) indexOfView:(UIView*)view;

@end

@interface UIViewTransformUtil : NSObject

@end
