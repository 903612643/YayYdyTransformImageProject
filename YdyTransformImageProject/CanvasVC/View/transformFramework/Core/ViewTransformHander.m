//
//  ImageTransform.m
//  01GestureTest
//
//  Created by YSKJ on 2017/10/19.
//  Copyright © 2017年 fcy. All rights reserved.
//

#import "ViewTransformHander.h"
#import "UIView+Transform.h"
#import "UIViewTransformUtil.h"
#import "CoordinateUtil.h"
#import "ViewTransformConfiguration.h"
#import "CtrlPointCtnView.h"

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

#define FONT_Medium_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Medium" size:_size_]
#define FONT_Semibold_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Semibold" size:_size_]
#define FONT_Regular_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Regular" size:_size_]

// 16进制颜色值，如：#000000 , 注意：在使用的时候hexValue写成：0x000000
#define HexColor(hexValue) [UIColor colorWithRed:((float)(((hexValue) & 0xFF0000) >> 16))/255.0 green:((float)(((hexValue) & 0xFF00) >> 8))/255.0 blue:((float)((hexValue) & 0xFF))/255.0 alpha:1.0]


#define DEBUG_SHOW_VIEW_COLOR 0

typedef struct _TransformInfo {
    CGPoint center;
    CGFloat angle;
    CGAffineTransform transform;
}TransformInfo;

@implementation ViewTransformHander
{
    __weak UIView * _targetView;
    __weak UIView * _targetSuperView;
    
    NSMutableArray * _contrlPointGestureRegs;
    NSMutableArray * _sideCtrlViews;
    
    CGRect _targetViewRawFrame;
    UIView * _ctrlCtnView;
    CGSize _rawCtrlCtnViewSize;
    ViewTransformConfiguration * _cnf;

    CGPoint _panBeginLocation;

    TransformInfo _transformInfoOfRaw;
    TransformInfo _transformInfoOfPanBegin;
    BOOL _isShowingTransformOperation;
    
    CGFloat _lastTotalScaleX;
    CGFloat _lastTotalScaleY;
    CGFloat _lastTotalAngle;
    
    CGFloat _targetViewRawZIndex;
    
    UIView * _rectLineView;
    UIView * _outLineView;
    NSMutableDictionary * _controlPointToEnable;
    __weak id<ViewTransformeDelegate> _delegate;
    
    UIPanGestureRecognizer * _panForDrag;
}
- (instancetype) initWith:(UIView * )targetView
            configuration:(ViewTransformConfiguration *)configuration
                 delegate:(id<ViewTransformeDelegate>)delegate;{
    self = [super init];
    if(self){
        _delegate = delegate;
        _cnf = configuration ? configuration : [[ViewTransformConfiguration alloc]init];
        _targetView = targetView;
        _contrlPointGestureRegs = @[].mutableCopy;
 
        _isShowingTransformOperation = NO;
        _controlPointToEnable = @{}.mutableCopy;
    }
    return self;
}
- (void) showTransformOperation{
    NSAssert(_targetView, @"目标view不可为nil");
    NSAssert(_targetView.superview, @"目标view必须拥有一个父视图");
    if(_isShowingTransformOperation){
        return;
    }
    _isShowingTransformOperation = YES;
    
    CGRect targetViewOriginFrame = _targetView.originalFrame;
    _targetViewRawFrame = _targetView.originalFrame;

    _transformInfoOfRaw.center = CGPointMake(targetViewOriginFrame.size.width/2 + targetViewOriginFrame.origin.x,
                                             targetViewOriginFrame.size.height/2 + targetViewOriginFrame.origin.y);
    _transformInfoOfRaw.angle = 0;
    
    _ctrlCtnView = [self createsCtrlPointsViewCtn];
    _targetViewRawZIndex = [_targetView.superview.subviews indexOfObject:_targetView];
    [_targetView.superview insertSubview:_ctrlCtnView aboveSubview:_targetView];

    
    _panForDrag = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onDrag:)];
    _ctrlCtnView.userInteractionEnabled = YES;
    [_ctrlCtnView addGestureRecognizer:_panForDrag];
    
    UITapGestureRecognizer *tag1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapGes:)];
    tag1.numberOfTapsRequired = 1;
    [_ctrlCtnView addGestureRecognizer:tag1];
    
    
    [_ctrlCtnView layoutIfNeeded];
    //控制点 -> 背景色
    _controlPointToEnable = @{}.mutableCopy;
    for (id ctrlTypeObj in [self getAllControlPointType]){
        _controlPointToEnable[ctrlTypeObj] = @(YES);
    }
    
    [self hideAllControlPoint];
}

- (void) hideTransformOperation{
    
    if(!_isShowingTransformOperation){
        return;
    }
    [_ctrlCtnView removeFromSuperview];
    _isShowingTransformOperation = NO;

}
- (void) enable:(BOOL)isEnable forControlPoint:(CtrlViewType)controlPoint{
    _controlPointToEnable[@(controlPoint)] = @(isEnable);
}
- (void) enableDrag:(BOOL)isEnable{
    _panForDrag.enabled = isEnable;
}
- (void) enableAll{
    for (id ctrlType in [self getAllControlPointType]) {
        [self enable:YES forControlPoint:[ctrlType integerValue]];
    }
    [self enableDrag:YES];
}
- (void) disableAll{
    for (id ctrlType in [self getAllControlPointType]) {
        [self enable:NO forControlPoint:[ctrlType integerValue]];
    }
    [self enableDrag:NO];
}
- (UIView *) createsCtrlPointsViewCtn{
    CtrlPointCtnView * ctrlCtnView = [[CtrlPointCtnView alloc]init];
#if DEBUG_SHOW_VIEW_COLOR
    ctrlCtnView.backgroundColor = [UIColor redColor];
    ctrlCtnView.alpha = 0.8;
#endif
    ctrlCtnView.center = _targetView.center;
    if(CGAffineTransformIsIdentity(_targetView.transform)){
        CGFloat w = _targetView.bounds.size.width
        + _cnf.controlPointSideLen * 2
        + _cnf.controlPointTargetViewInset * 2
        + _cnf.expandInsetGestureRecognition.x * 2;
        CGFloat h = _targetView.bounds.size.height
        + _cnf.controlPointSideLen * 2
        + _cnf.controlPointTargetViewInset * 2
        + _cnf.expandInsetGestureRecognition.y * 2;
        ctrlCtnView.bounds = CGRectMake(0, 0,w,h);
        _rawCtrlCtnViewSize = CGSizeMake(w,h);
        
    }else{
        
        CGFloat oldW = _targetView.bounds.size.width;
        CGFloat oldH = _targetView.bounds.size.height;
        
        CGFloat newW = [CoordinateUtil distanceBetweenPointA:_targetView.transformedTopLeft andPointB:_targetView.transformedTopRight];
        CGFloat newH = [CoordinateUtil distanceBetweenPointA:_targetView.transformedTopLeft andPointB:_targetView.transformedBottomLeft];
        
        CGFloat w = _targetView.bounds.size.width
        + _cnf.controlPointSideLen * 2
        + _cnf.controlPointTargetViewInset * 2
        + _cnf.expandInsetGestureRecognition.x * 2;
        CGFloat h = _targetView.bounds.size.height
        + _cnf.controlPointSideLen * 2
        + _cnf.controlPointTargetViewInset * 2
        + _cnf.expandInsetGestureRecognition.y * 2;
        
        _rawCtrlCtnViewSize = CGSizeMake(w,h);
        
        w = _targetView.bounds.size.width * (newW/oldW) + (w-_targetView.bounds.size.width);
        h = _targetView.bounds.size.height * (newH/oldH) + (h-_targetView.bounds.size.height);
        
        ctrlCtnView.bounds = CGRectMake(0, 0,w,h);
      
    }
    _rectLineView = [[UIView alloc]init];
    
    CGFloat expW = _cnf.controlPointSideLen + 2*_cnf.expandInsetGestureRecognition.x;
    CGFloat expH = _cnf.controlPointSideLen + 2*_cnf.expandInsetGestureRecognition.y;
    _rectLineView.frame = CGRectMake(expW/2,
                                   expH/2,
                                   ctrlCtnView.width-expW,
                                   ctrlCtnView.height-expH);
    [_rectLineView setAutoresizingMask:UIViewAutoresizingFlexibleWidth
     | UIViewAutoresizingFlexibleHeight];
    [ctrlCtnView addSubview:_rectLineView];
    
    UIView * tmpOutCtrlView ;
    UIView * tmpTsView;
    for (id ctypeObj in [self getAllControlPointType]) {
        CtrlViewType ctype = [ctypeObj integerValue];
        //控制点手势识别器
        UIView * ctrlGestureRegView = [[UIView alloc]init];
        ctrlGestureRegView.tag = ctype;
        
#if DEBUG_SHOW_VIEW_COLOR
        ctrlGestureRegView.backgroundColor = [UIColor blueColor];
#endif
        ctrlGestureRegView.userInteractionEnabled = YES;
        ctrlGestureRegView.clipsToBounds = YES;
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(onScaleAndRotate:)];
        [ctrlGestureRegView addGestureRecognizer:pan];
        ctrlGestureRegView.size = CGSizeMake(_cnf.controlPointSideLen + _cnf.expandInsetGestureRecognition.x*2,
                                             _cnf.controlPointSideLen + _cnf.expandInsetGestureRecognition.y*2);
        [ctrlCtnView addSubview:ctrlGestureRegView];
        
        //控制点
        UIView * ctrlView = [[UIView alloc]init];
        ctrlView.tag = ctype;
        ctrlView.userInteractionEnabled = NO;
        ctrlView.clipsToBounds = YES;
        ctrlView.bounds = CGRectMake(0,0,_cnf.controlPointSideLen,_cnf.controlPointSideLen);
        UIImage * bgImg = _cnf.controlPointToBackgroundImage[@(ctype)];
        [ctrlCtnView addSubview:ctrlView];
        [_contrlPointGestureRegs addObject:ctrlGestureRegView];
        switch (ctype) {
            case CtrlViewType_lt:
                ctrlGestureRegView.origin = CGPointZero;
                [ctrlGestureRegView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
                break;
            case CtrlViewType_lb:
                ctrlGestureRegView.origin = CGPointMake(0, ctrlCtnView.height - ctrlGestureRegView.height);
                [ctrlGestureRegView setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
                break;
            case CtrlViewType_rb:
                ctrlGestureRegView.origin = CGPointMake(ctrlCtnView.width - ctrlGestureRegView.width, ctrlCtnView.height - ctrlGestureRegView.height);
                [ctrlGestureRegView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin];
                break;
            case CtrlViewType_rt:
                ctrlGestureRegView.origin = CGPointMake(ctrlCtnView.width - ctrlGestureRegView.width, 0);
                [ctrlGestureRegView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin];
                break;
            case CtrlViewType_ls:
                ctrlGestureRegView.origin = CGPointMake(0, (ctrlCtnView.height - ctrlGestureRegView.width)/2);
                [ctrlGestureRegView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin];
                break;
            case CtrlViewType_ts:
                tmpTsView = ctrlView;
                ctrlGestureRegView.origin = CGPointMake((ctrlCtnView.width - ctrlGestureRegView.width)/2, 0);
                [ctrlGestureRegView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin];
                break;
            case CtrlViewType_bs:
                ctrlGestureRegView.origin = CGPointMake((ctrlCtnView.width - ctrlGestureRegView.width)/2, ctrlCtnView.height - ctrlGestureRegView.height);
                [ctrlGestureRegView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin];
                
                break;
            case CtrlViewType_rs:
                
                ctrlGestureRegView.origin = CGPointMake(ctrlCtnView.width - ctrlGestureRegView.width,
                                                        (ctrlCtnView.height - ctrlGestureRegView.height)/2);
                [ctrlGestureRegView setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin];
                break;
            case CtrlViewType_out:
                tmpOutCtrlView = ctrlView;
                ctrlGestureRegView.origin = CGPointMake((ctrlCtnView.width - ctrlGestureRegView.width)/2,
                                                       -_cnf.outsideControlPointInset - ctrlGestureRegView.height);
                [ctrlGestureRegView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
                
                break;
            default:
                NSAssert(NO, @"未处理的控制点类型");
                break;
        }
        ctrlView.autoresizingMask = ctrlGestureRegView.autoresizingMask;
        ctrlView.center = ctrlGestureRegView.center;
        
        if (bgImg){
            UIImageView * imgv = [[UIImageView alloc]initWithImage:bgImg];
            imgv.center = CGPointMake(_cnf.controlPointSideLen/2, _cnf.controlPointSideLen/2);
            imgv.bounds = CGRectMake(0, 0, bgImg.size.width, bgImg.size.height);
            imgv.clipsToBounds = NO;
            ctrlView.clipsToBounds = NO;
            [ctrlView addSubview:imgv];
        }else{
            ctrlView.backgroundColor = _cnf.controlPointToBackgroundColor[@(ctype)];
        }
        
        

    }
    

    //顶边 和 out control的连线
    _outLineView = [[UIView alloc]initWithFrame:CGRectMake(tmpOutCtrlView.center.x,
                                                                tmpOutCtrlView.center.y,
                                                                2.0/[UIScreen mainScreen].scale,
                                                                ABS(tmpOutCtrlView.center.y - tmpTsView.center.y))];
 
    _outLineView.layer.borderColor = HexColor(0xbbbbbe).CGColor;
    _outLineView.layer.borderWidth = 1.0/[UIScreen mainScreen].scale;

    [_outLineView setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
    
    [ctrlCtnView insertSubview:_outLineView belowSubview:tmpTsView];
   
    ctrlCtnView.transform = CGAffineTransformMakeRotation(_targetView.rotation);
    
    return ctrlCtnView;
}

-(void)operationTargetView:(UITapGestureRecognizer*)ges
{
//    [self showAllControlPoint];
//    for (UIView *subView in _ctrlCtnView.superview.subviews) {
//        if (subView != _targetView) {
//            for (UIView *v in subView.subviews) {
//                v.hidden = YES;
//            }
//        }
//    }
//    if([_delegate respondsToSelector:@selector(tapGWihttargetView:ges:)]){
//        [_delegate tapGWihttargetView:_targetView  ges:ges];
//    }
}

//单击手势
-(void)singleTapGes:(UITapGestureRecognizer *)recognizer
{
    [self operationTargetView:recognizer];
    
}

-(void)onDrag:(UIPanGestureRecognizer*)gesture
{
    
    UIGestureRecognizerState state = gesture.state;
    
    CGPoint currentLoation = [gesture locationInView:_targetView.superview];
    
    CGPoint center = gesture.view.center;

    switch (state) {
            
        case UIGestureRecognizerStateBegan:
            
            _panBeginLocation = [gesture locationInView:_targetView.superview];

            _transformInfoOfPanBegin.center = _targetView.center;
            _transformInfoOfPanBegin.angle = _targetView.rotation;
            
            [self operationTargetView:nil];
            
            if([_delegate respondsToSelector:@selector(onDragPanDurationOffset:targetView:ges:)]){
                [_delegate onDragPanDurationOffset:CGPointMake(center.x - _transformInfoOfPanBegin.center.x,
                                                               center.y - _transformInfoOfPanBegin.center.y)
                                        targetView:_targetView ges:gesture];
            }
            
            break;
            
        case UIGestureRecognizerStateChanged:{
            
            center.x = _transformInfoOfPanBegin.center.x + (currentLoation.x - _panBeginLocation.x);
            center.y = _transformInfoOfPanBegin.center.y + (currentLoation.y - _panBeginLocation.y);
            
            _ctrlCtnView.center = center;
            _targetView.center = center;
            
            
            if([_delegate respondsToSelector:@selector(onDragPanDurationOffset:targetView:ges:)]){
                [_delegate onDragPanDurationOffset:CGPointMake(center.x - _transformInfoOfPanBegin.center.x,
                                                               center.y - _transformInfoOfPanBegin.center.y)
                            targetView:_targetView ges:gesture];
            }
        
        }
        case UIGestureRecognizerStateEnded:
            
            if([_delegate respondsToSelector:@selector(onDragPanDurationOffset:targetView:ges:)]){
                
                [_delegate onDragPanDurationOffset:CGPointMake(center.x - _transformInfoOfPanBegin.center.x,
                                                               center.y - _transformInfoOfPanBegin.center.y)
                                        targetView:_targetView ges:gesture];
            }
            
            
            
            break;
        case UIGestureRecognizerStateCancelled:
            
            if([_delegate respondsToSelector:@selector(onDragPanDurationOffset:targetView:ges:)]){
                [_delegate onDragPanDurationOffset:CGPointMake(center.x - _transformInfoOfPanBegin.center.x,
                                                               center.y - _transformInfoOfPanBegin.center.y)
                                        targetView:_targetView ges:gesture];
            }
            
            break;
        case UIGestureRecognizerStateFailed:
            break;
        default:
            break;
    }
   
}
static CGFloat tempTotalScaleX = 1.0, tempTotalScaleY = 1.0 , totalAngle=0; NSInteger capacities=0;

-(void)onScaleAndRotate:(UIPanGestureRecognizer*)gesture
{
    UIView *viewCtrl = gesture.view;
    
    BOOL isEnable = [_controlPointToEnable[@(viewCtrl.tag)] boolValue];
    if(!isEnable){
        return;
    }
    UIGestureRecognizerState state = gesture.state;
    
    switch (state) {
            
        case UIGestureRecognizerStateBegan:{
            
            _panBeginLocation = [gesture locationInView:_targetView.superview];
            
            _transformInfoOfPanBegin.transform = _targetView.transform;
            _transformInfoOfPanBegin.center = _targetView.center;
            _transformInfoOfPanBegin.angle = _targetView.rotation;
            
            [self operationTargetView:nil];

            break;
        }
        case UIGestureRecognizerStateChanged:{
            
            CtrlViewType ctrlViewType = viewCtrl.tag;
            CGPoint currentLoation = [gesture locationInView:_targetView.superview];
            capacities = [_cnf.controlPointToCapacities[@(ctrlViewType)] integerValue];
    
            CGFloat totalScaleX = [TransformUtil widthScaleForTransfrom:_transformInfoOfPanBegin.transform];
            CGFloat totalScaleY = [TransformUtil heightScaleForTransfrom:_transformInfoOfPanBegin.transform];
            
            if (capacities&CtrlViewCapacity_scale) {
                //顶角控制点 双轴缩放
                if (ctrlViewType >= 1 && ctrlViewType <= 4){
                    CGFloat distanceBeginLocToTargetViewCenter = [CoordinateUtil distanceBetweenPointA:_panBeginLocation andPointB:_targetView.center];
                    CGFloat distanceCurrentLocToTargetViewCenter = [CoordinateUtil distanceBetweenPointA:currentLoation andPointB:_targetView.center];
                    
                    CGFloat currentScale = distanceCurrentLocToTargetViewCenter/distanceBeginLocToTargetViewCenter;
                    totalScaleX *= currentScale;
                    totalScaleY *= currentScale;
                    
                    
                    totalScaleX = MAX(totalScaleX, _cnf.minWidth / _targetViewRawFrame.size.width);
                    totalScaleX = MIN(totalScaleX, _cnf.maxWidth / _targetViewRawFrame.size.width);
                    totalScaleY = MAX(totalScaleY, _cnf.minHeight / _targetViewRawFrame.size.height);
                    totalScaleY = MIN(totalScaleY, _cnf.maxHeight / _targetViewRawFrame.size.height);
                }
                //边控制点 单轴缩放
                /*
                 单轴缩放比例参考的是手势移动前后距离图形‘水平平分线/垂直平分线‘的长度的变化比例。
                 注：这里的‘水平平分线/垂直平分线‘ 指的是transform 后的‘水平平分线/垂直平分线‘
                 */
                else if (ctrlViewType >= 6 && ctrlViewType <= 9){
                    //x 轴
                    if (ctrlViewType == CtrlViewType_ls || ctrlViewType == CtrlViewType_rs){
                        CGPoint curLeftTop = _targetView.transformedTopLeft;
                        CGPoint curRightTop = _targetView.transformedTopRight;
                        CGPoint horCenter = CGPointMake((curLeftTop.x + curRightTop.x)/2, (curLeftTop.y + curRightTop.y)/2);
                        //变换后的图形的垂直平分线
                        LineGeneralFormEquationParam verLine = [CoordinateUtil lineGeneralFormEquationWithPoint1:horCenter point2:_targetView.center];
                        
                        CGFloat panBeginLocHorDistanceToVerLine = [CoordinateUtil distanceFromPoint:_panBeginLocation toLine:verLine];
                        CGFloat curLocHorDistanceToVerLine = [CoordinateUtil distanceFromPoint:currentLoation toLine:verLine];
                        CGFloat xScale = curLocHorDistanceToVerLine/panBeginLocHorDistanceToVerLine;
                        
                        totalScaleX *= xScale;
                        
                        totalScaleX = MAX(totalScaleX, _cnf.minWidth / _targetViewRawFrame.size.width);
                        totalScaleX = MIN(totalScaleX, _cnf.maxWidth / _targetViewRawFrame.size.width);
                        
                    }
                    //y 轴
                    else{
                        CGPoint curLeftTop = _targetView.transformedTopLeft;
                        CGPoint curLeftBottom = _targetView.transformedBottomLeft;
                        CGPoint vCenter = CGPointMake((curLeftTop.x + curLeftBottom.x)/2, (curLeftTop.y + curLeftBottom.y)/2);
                        //变换后的图形的水平线
                        LineGeneralFormEquationParam horLine = [CoordinateUtil lineGeneralFormEquationWithPoint1:vCenter point2:_targetView.center];
                        
                        CGFloat panBeginLocVerticalDistanceToHorLine = [CoordinateUtil distanceFromPoint:_panBeginLocation toLine:horLine];
                        CGFloat curLocVerticalDistanceToHorLine = [CoordinateUtil distanceFromPoint:currentLoation toLine:horLine];
                        CGFloat yScale = curLocVerticalDistanceToHorLine/panBeginLocVerticalDistanceToHorLine;
                        totalScaleY *= yScale;

                        totalScaleY = MAX(totalScaleY, _cnf.minHeight / _targetViewRawFrame.size.height);
                        totalScaleY = MIN(totalScaleY, _cnf.maxHeight / _targetViewRawFrame.size.height);
                    }
                }else{
                    NSAssert(NO, @"不支持的控制点类型");
                }
                
            }
            
            tempTotalScaleX = totalScaleX;tempTotalScaleY = totalScaleY;
            
            totalAngle = _transformInfoOfPanBegin.angle - _transformInfoOfRaw.angle;
            
            
            if (capacities&CtrlViewCapacity_rotate) {
                // 计算弧度
                CGFloat panbeginRadius = [CoordinateUtil radiusBetweenPointA:_targetView.center andPointB:_panBeginLocation];
                CGFloat curRadius = [CoordinateUtil radiusBetweenPointA:_targetView.center andPointB:currentLoation];
                CGFloat radius = curRadius - panbeginRadius;
                radius = - radius;
                totalAngle += radius;
 
            }
            
            CGAffineTransform scaleTf = CGAffineTransformMakeScale(totalScaleX, totalScaleY);
            CGAffineTransform rotateTf = CGAffineTransformMakeRotation(totalAngle);
            _targetView.transform = CGAffineTransformConcat(scaleTf, rotateTf);
            
            _ctrlCtnView.transform = rotateTf;
            _ctrlCtnView.bounds = CGRectMake(0, 0,
                                             _targetViewRawFrame.size.width * totalScaleX                                             + _rawCtrlCtnViewSize.width-_targetViewRawFrame.size.width,
                                             _targetViewRawFrame.size.height * totalScaleY
                                             + _rawCtrlCtnViewSize.height-_targetViewRawFrame.size.height);

            
            if (capacities&CtrlViewCapacity_scale) {
                
                if(_lastTotalScaleX != totalScaleX || _lastTotalScaleY != totalScaleY){
                    if([_delegate respondsToSelector:@selector(onScaleTotal:panDurationScale:targetView:ges:)]){
                        [_delegate onScaleTotal:CGPointMake(tempTotalScaleX, tempTotalScaleY)
                               panDurationScale:CGPointMake(
                                                            totalScaleX/[TransformUtil widthScaleForTransfrom:_transformInfoOfPanBegin.transform],
                                                            totalScaleY/[TransformUtil heightScaleForTransfrom:_transformInfoOfPanBegin.transform])
                                     targetView:_targetView ges:gesture ];
                    }
                }
            }
            if (capacities&CtrlViewCapacity_rotate) {
                
                
              
                if(_lastTotalAngle != totalAngle){
                    if([_delegate respondsToSelector:@selector(onRotateTotal:panDurationAngle:targetView:ges:)]){
                        [_delegate onRotateTotal:totalAngle panDurationAngle:totalAngle - _transformInfoOfPanBegin.angle targetView:_targetView ges:gesture];
                    }
                }
            }
            
 
            _lastTotalScaleX = totalScaleX;
            _lastTotalScaleY = totalScaleY;
            _lastTotalAngle = totalAngle;
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        
            if (capacities&CtrlViewCapacity_scale) {
                
                if([_delegate respondsToSelector:@selector(onScaleTotal:panDurationScale:targetView:ges:)]){
                    [_delegate onScaleTotal:CGPointMake(tempTotalScaleX, tempTotalScaleY)
                           panDurationScale:CGPointMake(
                                                        tempTotalScaleX/[TransformUtil widthScaleForTransfrom:_transformInfoOfPanBegin.transform],
                                                        tempTotalScaleY/[TransformUtil heightScaleForTransfrom:_transformInfoOfPanBegin.transform])
                                 targetView:_targetView ges:gesture ];
                }
                
                tempTotalScaleX = 1.0,tempTotalScaleY=1.0;
            }
            if (capacities&CtrlViewCapacity_rotate) {
                
                if([_delegate respondsToSelector:@selector(onRotateTotal:panDurationAngle:targetView:ges:)]){
                    [_delegate onRotateTotal:totalAngle panDurationAngle:totalAngle - _transformInfoOfPanBegin.angle targetView:_targetView ges:gesture];
                }
            }
            
            break;
            
        case UIGestureRecognizerStateCancelled:
            break;
        case UIGestureRecognizerStateFailed:
            break;
        default:
            break;
    }
   
    
}
- (void) hideAllControlPoint{
    for (UIView * v in [_ctrlCtnView subviews]) {
        if(v.tag >=1 && v.tag <=10){
            v.hidden = YES;
        }
    }
    _rectLineView.hidden = YES;
    _outLineView.hidden = YES;
}
- (void) showAllControlPoint{
    for (UIView * v in [_ctrlCtnView subviews]) {
        if(v.tag >=1 && v.tag <=10){
            v.hidden = NO;
        }
    }
    _rectLineView.hidden = NO;
    _outLineView.hidden = NO;
}

- (void) transformRotationToNoAngle{
    
    CGFloat totalScaleX = [TransformUtil widthScaleForTransfrom:_targetView.transform];
    CGFloat totalScaleY = [TransformUtil heightScaleForTransfrom:_targetView.transform];
    
    CGAffineTransform scaleTf = CGAffineTransformMakeScale(totalScaleX, totalScaleY);
    CGAffineTransform rotateTf = CGAffineTransformMakeRotation(0);
    
    _targetView.transform = CGAffineTransformConcat(scaleTf, rotateTf);
    
    _ctrlCtnView.transform = rotateTf;
    _ctrlCtnView.bounds = CGRectMake(0, 0,
                                     _targetViewRawFrame.size.width * totalScaleX                                             + _rawCtrlCtnViewSize.width-_targetViewRawFrame.size.width,
                                     _targetViewRawFrame.size.height * totalScaleY
                                     + _rawCtrlCtnViewSize.height-_targetViewRawFrame.size.height);
}


- (NSArray*) getAllControlPointType{
    return @[
             @(CtrlViewType_lt),
             @(CtrlViewType_lb),
             @(CtrlViewType_rb),
             @(CtrlViewType_rt),
             
             @(CtrlViewType_ls),
             @(CtrlViewType_ts),
             @(CtrlViewType_rs),
             @(CtrlViewType_bs),
             @(CtrlViewType_out)
             ];
}

@end
