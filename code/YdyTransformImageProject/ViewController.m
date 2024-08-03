//
//  ViewController.m
//  YdyTransformImageProject
//
//  Created by yangdeyuan on 2024/8/2.
//

#import "ViewController.h"
#import "UIImage+Util.h"
#import "YSKJ_drawModel.h"
#import "MJExtension.h"
#import "H_TZImagePickerHelper.h"

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

#define FONT_Medium_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Medium" size:_size_]
#define FONT_Semibold_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Semibold" size:_size_]
#define FONT_Regular_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Regular" size:_size_]

// 16进制颜色值，如：#000000 , 注意：在使用的时候hexValue写成：0x000000
#define HexColor(hexValue) [UIColor colorWithRed:((float)(((hexValue) & 0xFF0000) >> 16))/255.0 green:((float)(((hexValue) & 0xFF00) >> 8))/255.0 blue:((float)((hexValue) & 0xFF))/255.0 alpha:1.0]

@interface ViewController ()

//@property (nonatomic, strong)YSKJ_CanvasIssueProView *titleView;
//@property (nonatomic, strong)YSKJ_CanvasIssueLikeView *likeView;

@property (nonatomic, strong)UIButton *addressbtn;

@property (nonatomic, strong)NSMutableArray *imageArr; //图片数组

@property (nonatomic, strong)NSData *imageData;

@property (nonatomic, copy)NSString *sendPro_type;

@property (nonatomic,strong)NSMutableArray *dataArr;

@property (nonatomic,strong)YSKJ_NaviView *naviView;
@property (nonatomic,strong)UILabel *canvasTip;

@property (nonatomic, strong)NSMutableArray *productDataArr;
@property (nonatomic, strong)NSMutableArray *historiesArr;

@end

@implementation ViewController

-(NSMutableArray*)productDataArr
{
    if (!_productDataArr) {
        _productDataArr = [[NSMutableArray alloc] init];
    }
    return _productDataArr;
}

-(NSMutableArray*)historiesArr
{
    if (!_historiesArr) {
        _historiesArr = [[NSMutableArray alloc] init];
    }
    return _historiesArr;
}

-(NSMutableArray*)dataArr
{
    if (!_dataArr) {
        _dataArr = [[NSMutableArray alloc] init];
    }
    return _dataArr;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    
    self.view.backgroundColor = HexColor(0x222A36);
    
    YSKJ_NaviView *navi = [[YSKJ_NaviView alloc] initWithFrame:CGRectMake(0,44, self.view.frame.size.width, 70)];
    self.naviView = navi;
    [self.view addSubview:navi];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 70 + 44, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, self.issueLike?SCREEN_HEIGHT+300:SCREEN_HEIGHT+500);
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH,SCREEN_HEIGHT);
    [self.view addSubview:scrollView];
    
    //画布手势事件
    _canvas = [[YSKJ_CanvasView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width)];
    _canvas.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [scrollView addSubview:_canvas];
    UITapGestureRecognizer *tapRecognize = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tapRecognize.numberOfTapsRequired = 1;
    [_canvas addGestureRecognizer:tapRecognize];
    
    UILabel *canvasTip = [[UILabel alloc] initWithFrame:CGRectMake(80, SCREEN_WIDTH/2-50, (SCREEN_WIDTH-160), 80)];
    canvasTip.font = FONT_Regular_SIZE(22);
    canvasTip.textColor = HexColor(0xB8BCC2);
    canvasTip.textAlignment = NSTextAlignmentCenter;
    canvasTip.numberOfLines = 2;
    canvasTip.text = @"拖动或选择照片与视频到画布并进行编辑";
    self.canvasTip = canvasTip;
    [scrollView addSubview:canvasTip];

    
    [self.historiesArr addObject:@[]];
    
    for (UIButton *subView in navi.subviews) {
        if (subView.tag==1000){
            [subView addTarget:self action:@selector(dissAction) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag==1001){
            _recallBut = subView;
            _recallBut.enabled = NO;
            [subView addTarget:self action:@selector(recallAction) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag==1002){
            _nextBut = subView;
            _nextBut.enabled = NO;
            [subView addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag==1003){
            [subView addTarget:self action:@selector(mirrorAction) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag==1004){
            [subView addTarget:self action:@selector(copyAction) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag == 1005){
            [subView addTarget:self action:@selector(deleteAction) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag == 1006){
            [subView addTarget:self action:@selector(addFromPhotosAction) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag == 1007){
            [subView addTarget:self action:@selector(moveAllAction) forControlEvents:UIControlEventTouchUpInside];
        }else if (subView.tag == 1008){
            [subView addTarget:self action:@selector(showProduct:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    
    [self addViewTransformConfigurationFromOptionView];
    

    _myLoad = [[YSKJ_MyLoadProduct alloc] initWithFrame:CGRectMake(0, 0,self.view.frame.size.width/2, self.view.frame.size.width)];
    _myLoad.hidden = YES;
    [scrollView addSubview:_myLoad];
    
    //拖动菜单手势事件通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(beganPanAction:) name:@"beganPanNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(panAction:) name:@"panNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endAction:) name:@"endPanNotification" object:nil];
   
    
    _shaLayer = [CAShapeLayer layer];
    _shaLayer.lineWidth = 1;
    _shaLayer.lineCap = @"square";
    _shaLayer.lineDashPattern = @[@4,@4];
    
    shapelayer = [CAShapeLayer layer];

    
    
}

#pragma mark 添加ViewTransformConfiguration框架，一个是操作视图，一个是proImag

-(void)addViewTransformConfigurationFromOptionView
{
    cnf = [[ViewTransformConfiguration alloc]init];
    cnf.controlPointSideLen = 6;
    cnf.controlPointTargetViewInset = 2;
    cnf.expandInsetGestureRecognition = CGPointMake(15, 15);
    cnf.minWidth = 0.1;
    cnf.minHeight = 0.1;
    [cnf configBackgroundImage:[UIImage imageNamed:@"RotaryGripper"] forControlPointType:CtrlViewType_out];
    [cnf configBackgroundImage:[UIImage imageNamed:@"SelectedPoints"] forControlPointType:CtrlViewType_lt];
    [cnf configBackgroundImage:[UIImage imageNamed:@"SelectedPoints"] forControlPointType:CtrlViewType_lb];
    [cnf configBackgroundImage:[UIImage imageNamed:@"SelectedPoints"] forControlPointType:CtrlViewType_rb];
    [cnf configBackgroundImage:[UIImage imageNamed:@"SelectedPoints"] forControlPointType:CtrlViewType_rt];
    [cnf configBackgroundImage:[UIImage imageNamed:@"SelectedPoints"] forControlPointType:CtrlViewType_ls];
    [cnf configBackgroundImage:[UIImage imageNamed:@"SelectedPoints"] forControlPointType:CtrlViewType_ts];
    [cnf configBackgroundImage:[UIImage imageNamed:@"SelectedPoints"] forControlPointType:CtrlViewType_rs];
    [cnf configBackgroundImage:[UIImage imageNamed:@"SelectedPoints"] forControlPointType:CtrlViewType_bs];
    [cnf configCtrlPointCapacity:(CtrlViewCapacity_scale) forControlPointType:CtrlViewType_rt];
}

#pragma mark 画布单击手势
-(void)handleTap:(UITapGestureRecognizer *)recognizer
{
    [self dissmissCheck];
}

#pragma mark 画布元素单击手势
-(void)proImgTapGestureChanged:(UIPanGestureRecognizer*)recognizer
{
    if (_targetView!=recognizer.view) {
        //1.取消选中
        [self dissmissCheck];
        _targetView = (UIImageView*)recognizer.view;
        YSKJ_drawModel *model = self.productDataArr[recognizer.view.tag-1];
        [self addDrawOptionViewWithModel:model];
        
        [self.naviView checkAction];
    }
}

#pragma mark 取消画布选中
-(void)dissmissCheck
{
    //设置虚线框为透明
    _shaLayer.strokeColor = [UIColor clearColor].CGColor;
    shapelayer.strokeColor = [UIColor clearColor].CGColor;
    UIView *view = [_canvas viewWithTag:2024];
    [view tf_hideTransformOperation]; //移除编辑视图的9点控制
    [view removeFromSuperview];  //移除编辑视图
    _targetView = nil; //设置当前选中空
    //取消画布所有控制点，只保留画布的编辑image
    for (UIView *subView in _canvas.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            [subView removeFromSuperview];
        }
    }
    
    [self.naviView unCheckAction];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark 添加一个元素到画布并选中
-(void)addProToDrawBoard:(YSKJ_drawModel*)model
{
    //元素的位置实质是由变形控制点决定，得到拖动按钮的中心点位置，进行对元素变形
    UIImageView *proImg = [[UIImageView alloc] init];
    if (_panButton) {
        proImg.frame = CGRectMake(_panButton.center.x - 100,_panButton.center.y - 100,200,200);
    }else{
        proImg.frame = CGRectMake(CGRectGetWidth(_canvas.frame)/2 - 100,CGRectGetHeight(_canvas.frame)/2 - 100,200,200);
    }
    //得到_panButton.center后移除
    [_corssView removeFromSuperview];
    proImg.tag = self.productDataArr.count+1;
    proImg.userInteractionEnabled = YES;
    UIImage *image = [UIImage imageWithData:model.src];
    proImg.image =  image;
   // [proImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",model.src]] placeholderImage:nil];
    _targetView = proImg;
    //是否镜像
    if ([model.mirror integerValue] == 1) {
        proImg.image = [proImg.image rotate:UIImageOrientationUpMirrored];
    }
    UITapGestureRecognizer *panRecognizer = [[UITapGestureRecognizer alloc] init];
    [panRecognizer addTarget:self action:@selector(proImgTapGestureChanged:)];
    [proImg addGestureRecognizer:panRecognizer];
    [_canvas addSubview:proImg];
    
    //默认选中
    [self addDrawOptionViewWithModel:model];
    
    [self.productDataArr addObjectsFromArray:@[model]];
    
    [self addHistroy];
    
}

#pragma mark 当前画布数据添加到历史记录

-(void)addHistroy
{
    if (_hisIndex<self.historiesArr.count) {
        NSMutableArray *tempArray=[[NSMutableArray alloc] init];
        for (int i=0; i<_hisIndex; i++) {
            [tempArray addObject:self.historiesArr[i]];
        }
        if (tempArray.count>0) {
            [self.historiesArr removeAllObjects];
            self.historiesArr=tempArray;
        }
    }
    
    NSMutableArray *tempArr = [[NSMutableArray alloc] initWithArray:self.productDataArr];
    [self.historiesArr addObject:tempArr];
    _hisIndex=(int)self.historiesArr.count;
    _recallBut.enabled = YES;
    _nextBut.enabled = NO;
    
    //是否显示清空按钮
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (UIView *subView in _canvas.subviews) {
        [arr addObject:subView];
    }
    if (arr.count == 0) {
        self.naviView.btn4.enabled = NO;
    }else{
        self.naviView.btn4.enabled = YES;
    }
    
    if (self.naviView.btn4.enabled == NO) {
        _canvasTip.hidden = NO;
    }else{
        _canvasTip.hidden = YES;
    }
    
}



#pragma  mark 添加操作视图，全局只拥有一个操作视图
-(void)addDrawOptionViewWithModel:(YSKJ_drawModel*)model
{
    CanvasViewOptionHelper *helper = [[CanvasViewOptionHelper alloc] init];
    [helper addContorlPointViewWithFromSupView:_canvas drawModel:model block:^(UIImageView * _Nonnull target, UIButton * _Nonnull _tempTLbutton, UIButton * _Nonnull _tempTRbutton, UIButton * _Nonnull _tempBLbutton, UIButton * _Nonnull _tempBRbutton) {
        self->tempTLbutton = _tempTLbutton;
        self->tempTRbutton = _tempTRbutton;
        self->tempBLbutton = _tempBLbutton;
        self->tempBRbutton = _tempBRbutton;
        UIPanGestureRecognizer *panRecognizer1 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer1 addTarget:self action:@selector(topLeftChanged:)];
        [ self->tempTLbutton addGestureRecognizer:panRecognizer1];
        UIPanGestureRecognizer *panRecognizer2 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer2 addTarget:self action:@selector(topRightChanged:)];
        [self->tempBRbutton addGestureRecognizer:panRecognizer2];
        UIPanGestureRecognizer *panRecognizer3 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer3 addTarget:self action:@selector(bottomLeftChanged:)];
        [self->tempBLbutton addGestureRecognizer:panRecognizer3];
        UIPanGestureRecognizer *panRecognizer4 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer4 addTarget:self action:@selector(bottomRightChanged:)];
        [self->tempBRbutton addGestureRecognizer:panRecognizer4];
        
        //添加9点缩放控制点并加矩形虚线
        [target tf_showTransformOperationWithConfiguration:self->cnf delegate:self];
         [target tf_showAllControlPoint];
         [self addBorderWithView:target];
        
        [self->_targetView.layer ensureAnchorPointIsSetToZero];
        self->_targetView.layer.quadrilateral = AGKQuadMake(self->tempTLbutton.center,self->tempTRbutton.center,self->tempBRbutton.center,self->tempBLbutton.center);
        
        [self addBorderWithTLView:self->tempTLbutton TRView:self->tempTRbutton BLView:self->tempBLbutton BRView:self->tempBRbutton panBool:NO];
    }];
}




-(void)topLeftChanged:(UIPanGestureRecognizer *)recognizer
{
    [self panGestureChanged:recognizer propertyName:kPOPLayerAGKQuadTopLeft];
}
-(void)topRightChanged:(UIPanGestureRecognizer *)recognizer
{
    [self panGestureChanged:recognizer propertyName:kPOPLayerAGKQuadTopRight];
}
-(void)bottomLeftChanged:(UIPanGestureRecognizer *)recognizer
{
    [self panGestureChanged:recognizer propertyName:kPOPLayerAGKQuadBottomLeft];
}
-(void)bottomRightChanged:(UIPanGestureRecognizer *)recognizer
{
    [self panGestureChanged:recognizer propertyName:kPOPLayerAGKQuadBottomRight];
}

#pragma mark 拖动某一个变形控制点进行变形操作
- (void)panGestureChanged:(UIPanGestureRecognizer *)recognizer propertyName:(NSString *)propertyName
{
    CGPoint translation = [recognizer translationInView:_canvas];
    // Move control point
    recognizer.view.centerX += translation.x;
    recognizer.view.centerY += translation.y;
    [recognizer setTranslation:CGPointZero inView:_canvas];
    
    [self addBorderWithTLView:tempTLbutton TRView:tempTRbutton BLView:tempBLbutton BRView:tempBRbutton panBool:NO];
    
    // Animate
    POPSpringAnimation *anim = [_targetView.layer pop_animationForKey:propertyName];
    
    if(anim == nil)
    {
        anim = [POPSpringAnimation animation];
        anim.property = [POPAnimatableProperty AGKPropertyWithName:propertyName];
        [_targetView.layer pop_addAnimation:anim forKey:propertyName];
    }
    anim.velocity = [NSValue valueWithCGPoint:[recognizer velocityInView:_canvas]];
    anim.toValue = [NSValue valueWithCGPoint:recognizer.view.center];
    anim.springBounciness = 7;
    anim.springSpeed =0.001;
    anim.dynamicsFriction = 7;
    
    
    NSMutableArray *centerPointArr = [[NSMutableArray alloc] init];
    [centerPointArr addObject:@{@"centerX":[NSString stringWithFormat:@"%f",tempTLbutton.center.x],@"centerY":[NSString stringWithFormat:@"%f",tempTLbutton.center.y]}];
    [centerPointArr addObject:@{@"centerX":[NSString stringWithFormat:@"%f",tempTRbutton.center.x],@"centerY":[NSString stringWithFormat:@"%f",tempTRbutton.center.y]}];
    [centerPointArr addObject:@{@"centerX":[NSString stringWithFormat:@"%f",tempBLbutton.center.x],@"centerY":[NSString stringWithFormat:@"%f",tempBLbutton.center.y]}];
    [centerPointArr addObject:@{@"centerX":[NSString stringWithFormat:@"%f",tempBRbutton.center.x],@"centerY":[NSString stringWithFormat:@"%f",tempBRbutton.center.y]}];
    
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
        
        UIView *theView = [_canvas viewWithTag:2024];
        [theView removeFromSuperview];
        
        [theView tf_hideTransformOperation];
        UIImageView *view = [[UIImageView alloc] initWithFrame:CGRectMake(minX, minY, maxX - minX, maxY-minY)];
        view.userInteractionEnabled = YES;
        view.tag = 2024;
        [_canvas addSubview:view];

        CGPoint point = [tempTRbutton convertPoint:CGPointMake(30.0, 30.0) toView:view];
        UIView *view1= [[UIView alloc] initWithFrame:CGRectMake(point.x - 30, point.y - 30, 30, 30)];
        view1.tag = 1000;
        [view addSubview:view1];
        
        CGPoint point1 = [tempTLbutton convertPoint:CGPointMake(30.0, 30.0) toView:view];
        UIView *view2= [[UIView alloc] initWithFrame:CGRectMake(point1.x - 30, point1.y - 30, 30, 30)];
        view2.tag = 1001;
        [view addSubview:view2];
        
        CGPoint point2 = [tempBLbutton convertPoint:CGPointMake(30.0, 30.0) toView:view];
        UIView *view3 = [[UIView alloc] initWithFrame:CGRectMake(point2.x - 30, point2.y - 30, 30, 30)];
        view3.tag = 1002;
        [view addSubview:view3];
        
        CGPoint point3 = [tempBRbutton convertPoint:CGPointMake(30.0, 30.0) toView:view];
        UIView *view4 = [[UIView alloc] initWithFrame:CGRectMake(point3.x - 30, point3.y - 30, 30, 30)];
        view4.tag = 1003;
        [view addSubview:view4];
        
        
        [view tf_showTransformOperationWithConfiguration:cnf delegate:self];
        [view tf_showAllControlPoint];
        [self addBorderWithView:view];
      
    }
    
    //把选中的controlPoint置前
    [tempTLbutton.superview bringSubviewToFront:tempTLbutton];
    [tempTRbutton.superview bringSubviewToFront:tempTRbutton];
    [tempBLbutton.superview bringSubviewToFront:tempBLbutton];
    [tempBRbutton.superview bringSubviewToFront:tempBRbutton];
    

    if (recognizer.state==UIGestureRecognizerStateEnded||recognizer.state==UIGestureRecognizerStateCancelled) {
        
        YSKJ_drawModel *model = self.productDataArr[_targetView.tag-1];
        YSKJ_drawModel *copyModel = [model copy];
        copyModel.contorlPointArr = centerPointArr;
        [self.productDataArr replaceObjectAtIndex:_targetView.tag-1 withObject:copyModel];
        [self addHistroy];
    }
    
}





#pragma mark ViewTransformeDelegate

- (void) onScaleTotal:(CGPoint)totalScale panDurationScale:(CGPoint)panDurationScale targetView:(UIView*)targetView ges:(UIPanGestureRecognizer*)ges
{
    [self setUpViewTransformeWithTargetView:targetView ges:ges];
}

- (void)onRotateTotal:(CGFloat)totalAngle panDurationAngle:(CGFloat)panDurationAngle targetView:(UIView *)targetView ges:(UIPanGestureRecognizer *)ges{
    
    [self setUpViewTransformeWithTargetView:targetView ges:ges];
    
}

- (void)onDragPanDurationOffset:(CGPoint)panDurationOffset targetView:(UIView *)targetView ges:(UIPanGestureRecognizer *)ges{
    
    [self setUpViewTransformeWithTargetView:targetView ges:ges];
}

- (void)tapGWihttargetView:(UIView*)targetView ges:(UITapGestureRecognizer *)ges
{
  //  [self dissmissCheck];
}


#pragma mark 拖动操作视图变形，同时4个控制的变形

-(void)setUpViewTransformeWithTargetView:(UIView*)targetView ges:(UIPanGestureRecognizer *)ges
{
    UIView *view1 = [targetView viewWithTag:1000];
    CGPoint point1 = [view1 convertPoint:CGPointMake(30.0, 30.0) toView:_canvas];
    tempTRbutton.frame = CGRectMake(point1.x - 30, point1.y - 30, 30, 30);
    [self popAnimatablePropertyWithName:kPOPLayerAGKQuadTopRight view:tempTRbutton];
    
    UIView *view2 = [targetView viewWithTag:1001];
    CGPoint point2 = [view2 convertPoint:CGPointMake(30.0, 30.0) toView:_canvas];
    tempTLbutton.frame = CGRectMake(point2.x - 30, point2.y - 30, 30, 30);
    [self popAnimatablePropertyWithName:kPOPLayerAGKQuadTopLeft view:tempTLbutton];
    
    UIView *view3 = [targetView viewWithTag:1002];
    CGPoint point3 = [view3 convertPoint:CGPointMake(30.0, 30.0) toView:_canvas];
    tempBLbutton.frame = CGRectMake(point3.x - 30, point3.y - 30, 30, 30);
    [self popAnimatablePropertyWithName:kPOPLayerAGKQuadBottomLeft view:tempBLbutton];
    
    UIView *view4 = [targetView viewWithTag:1003];
    CGPoint point4 = [view4 convertPoint:CGPointMake(30.0, 30.0) toView:_canvas];
    tempBRbutton.frame = CGRectMake(point4.x - 30, point4.y - 30, 30, 30);
    [self popAnimatablePropertyWithName:kPOPLayerAGKQuadBottomRight view:tempBRbutton];

    [targetView tf_showTransformOperationWithConfiguration:cnf delegate:self];
    [targetView tf_showAllControlPoint];
    [self addBorderWithView:targetView];
    
    [self addBorderWithTLView:tempTLbutton TRView:tempTRbutton BLView:tempBLbutton BRView:tempBRbutton panBool:NO];
    
    //把选中的controlPoint置前
    [tempTLbutton.superview bringSubviewToFront:tempTLbutton];
    [tempTRbutton.superview bringSubviewToFront:tempTRbutton];
    [tempBLbutton.superview bringSubviewToFront:tempBLbutton];
    [tempBRbutton.superview bringSubviewToFront:tempBRbutton];
    
    NSMutableArray *centerPointArr = [[NSMutableArray alloc] init];
    [centerPointArr addObject:@{@"centerX":[NSString stringWithFormat:@"%f",tempTLbutton.center.x],@"centerY":[NSString stringWithFormat:@"%f",tempTLbutton.center.y]}];
    [centerPointArr addObject:@{@"centerX":[NSString stringWithFormat:@"%f",tempTRbutton.center.x],@"centerY":[NSString stringWithFormat:@"%f",tempTRbutton.center.y]}];
    [centerPointArr addObject:@{@"centerX":[NSString stringWithFormat:@"%f",tempBLbutton.center.x],@"centerY":[NSString stringWithFormat:@"%f",tempBLbutton.center.y]}];
    [centerPointArr addObject:@{@"centerX":[NSString stringWithFormat:@"%f",tempBRbutton.center.x],@"centerY":[NSString stringWithFormat:@"%f",tempBRbutton.center.y]}];
    [tempTLbutton removeFromSuperview];
    [tempTRbutton removeFromSuperview];
    [tempBLbutton removeFromSuperview];
    [tempBRbutton removeFromSuperview];
    for (int i=0;i<centerPointArr.count;i++) {
        NSDictionary *contorlPointDict=centerPointArr[i];
        float ctx=[[contorlPointDict objectForKey:@"centerX"] floatValue];
        float cty=[[contorlPointDict objectForKey:@"centerY"] floatValue];
        UIButton *controlpoint=[[UIButton alloc] initWithFrame:CGRectMake(ctx-15, cty-15, 30, 30)];
        controlpoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
        [controlpoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
        controlpoint.backgroundColor = [UIColor clearColor];
        [_canvas addSubview:controlpoint];
        if (i==0) { tempTLbutton=controlpoint;}else if (i==1){tempTRbutton=controlpoint;}else if (i==2){ tempBLbutton=controlpoint;}else if (i==3){tempBRbutton=controlpoint;}
        UIPanGestureRecognizer *panRecognizer1 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer1 addTarget:self action:@selector(topLeftChanged:)];
        [tempTLbutton addGestureRecognizer:panRecognizer1];
        UIPanGestureRecognizer *panRecognizer2 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer2 addTarget:self action:@selector(topRightChanged:)];
        [tempTRbutton addGestureRecognizer:panRecognizer2];
        UIPanGestureRecognizer *panRecognizer3 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer3 addTarget:self action:@selector(bottomLeftChanged:)];
        [tempBLbutton addGestureRecognizer:panRecognizer3];
        UIPanGestureRecognizer *panRecognizer4 = [[UIPanGestureRecognizer alloc] init];
        [panRecognizer4 addTarget:self action:@selector(bottomRightChanged:)];
        [tempBRbutton addGestureRecognizer:panRecognizer4];
    }
    
    if (ges.state == UIGestureRecognizerStateEnded) {
        YSKJ_drawModel *model = self.productDataArr[_targetView.tag-1];
        YSKJ_drawModel *copyModel = [model copy];
        copyModel.contorlPointArr = centerPointArr;
        [self.productDataArr replaceObjectAtIndex:_targetView.tag-1 withObject:copyModel];
        [self addHistroy];
    }
}

-(void)popAnimatablePropertyWithName:(NSString *)propertyName view:(UIView*)view
{
    POPSpringAnimation *anim = [_targetView.layer pop_animationForKey:propertyName];
    if(anim == nil)
    {
        anim = [POPSpringAnimation animation];
        anim.property = [POPAnimatableProperty AGKPropertyWithName:propertyName];
        [_targetView.layer pop_addAnimation:anim forKey:propertyName];
    }
    anim.toValue = [NSValue valueWithCGPoint:view.center];
    anim.springBounciness = 7;
    anim.springSpeed =0.001;
    anim.dynamicsFriction = 10.0;
}

#pragma mark 返回
-(void)dissAction
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark 后退

-(void)recallAction
{
    if (self.historiesArr.count>1) {
        //1.索引减减
        _hisIndex--;
        [self recallAndNext];
    }
    if (_hisIndex==1) {
        _recallBut.enabled = NO;
    }
    _nextBut.enabled = YES;
    
    [self.naviView unCheckAction];

}

#pragma mark 前进
-(void)nextAction
{
    if (_hisIndex<self.historiesArr.count) {
        //1.索引加加
        _hisIndex++;
        [self recallAndNext];
    }
    if (_hisIndex==self.historiesArr.count) {
        _nextBut.enabled = NO;
    }
    _recallBut.enabled = YES;
    
    [self.naviView unCheckAction];
}

-(void)recallAndNext
{
    //2.取消选中
    [self dissmissCheck];
    //3.获取当前历史的画布数据
    NSArray *historyArr =  self.historiesArr[_hisIndex-1];
    self.productDataArr = [[NSMutableArray alloc] initWithArray:historyArr];
    //4.移除画布全部元素
    for (UIView *subViews in _canvas.subviews) {
        [subViews removeFromSuperview];
    }
    //5.根据当前画布数据加载元素
    [historyArr enumerateObjectsUsingBlock:^(YSKJ_drawModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addMoreProToDrawBoardWith:obj idx:idx];  //按个添加
    }];
    //6.移除变形控制点，只保留画布元素
    for (UIView *view in _canvas.subviews) {
        if (!view.tag) {
            [view removeFromSuperview];
        }
    }
    
    //是否显示清空按钮
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (UIView *subView in _canvas.subviews) {
        [arr addObject:subView];
    }
    if (arr.count == 0) {
        self.naviView.btn4.enabled = NO;
    }else{
        self.naviView.btn4.enabled = YES;
    }
    
    if (self.naviView.btn4.enabled == NO) {
        _canvasTip.hidden = NO;
    }else{
        _canvasTip.hidden = YES;
    }
    
}

#pragma mark 镜像
-(void)mirrorAction
{
    YSKJ_drawModel *model = self.productDataArr[_targetView.tag-1];
    YSKJ_drawModel *copyModel = [model copy];
    if ([copyModel.mirror integerValue] == 0) {
        copyModel.mirror = @"1";
    }else{
        copyModel.mirror = @"0";
    }
    [self.productDataArr replaceObjectAtIndex:_targetView.tag-1 withObject:copyModel];
    [self addHistroy];
    UIImageView *imageView = (UIImageView *)_targetView;
    imageView.image = [imageView.image rotate:UIImageOrientationUpMirrored];
}

#pragma mark 复制
-(void)copyAction
{
    //限制画布数量
    NSMutableArray *imageArr = [[NSMutableArray alloc] init];
    [self.productDataArr enumerateObjectsUsingBlock:^(YSKJ_drawModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.localUrl.length == 0) {
            [imageArr addObject:obj];
        }
    }];
    NSMutableArray *videoArr = [[NSMutableArray alloc] init];
    [self.productDataArr enumerateObjectsUsingBlock:^(YSKJ_drawModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.localUrl.length > 0) {
            [videoArr addObject:obj];
        }
    }];
    if (imageArr.count>8) {
      //  [self showToast:@"画布最多添加9个图片"];
    }
    if (videoArr.count>2) {
       // [self showToast:@"画布最多添加3个视频"];
    }
    
    
    //1.整理数据
    YSKJ_drawModel *model = self.productDataArr[_targetView.tag-1];
    YSKJ_drawModel *copyModel = [model copy];
    NSArray *centerPointArr = copyModel.contorlPointArr;
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    [centerPointArr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x= [obj[@"centerX"] floatValue] + 30;
        CGFloat y= [obj[@"centerY"] floatValue] + 30;
        [arr addObject:@{@"centerX":@(x),@"centerY":@(y)}];
    }];
    copyModel.contorlPointArr = arr;
    [self.productDataArr addObject:copyModel];
    [self addHistroy];
    
    //2.取消选中
    [self dissmissCheck];
    
    //3.添加视图
    [self addMoreProToDrawBoardWith:copyModel idx:self.productDataArr.count-1];
    
    //4.移除变形控制点，只保留画布元素
    for (UIView *view in _canvas.subviews) {
        if (!view.tag) {
            [view removeFromSuperview];
        }
    }
    
    //4.默认选中
    [self addDrawOptionViewWithModel:copyModel];
    for (UIView *subView in _canvas.subviews) {
        if (subView.tag == self.productDataArr.count) {
            _targetView = (UIImageView*)subView;
        }
    }
    
    [self.naviView checkAction];
    
}


#pragma mark 删除选中元素
-(void)deleteAction
{
    //1.移除数据
    YSKJ_drawModel *model = self.productDataArr[_targetView.tag-1];
    [self.productDataArr removeObject:model];
    [self addHistroy];
    
    //2.移除当前选中元素
    [_targetView removeFromSuperview];
    
   // 3.取消选中
    [self dissmissCheck];
    
    //4.元素重新排序
    [self canvasImageViewWithTagSort];
    
    //5.是否显示清空按钮
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (UIView *subView in _canvas.subviews) {
        [arr addObject:subView];
    }
    if (arr.count == 0) {
        self.naviView.btn4.enabled = NO;
    }else{
        self.naviView.btn4.enabled = YES;
    }
    
    if (self.naviView.btn4.enabled == NO) {
        _canvasTip.hidden = NO;
    }else{
        _canvasTip.hidden = YES;
    }
    
}


#pragma mark 预设
-(void)showProduct:(UIButton*)btn
{
    if (btn.selected == NO) {
        btn.selected = YES;
        _myLoad.hidden = NO;
    }else{
        btn.selected = NO;
        _myLoad.hidden = YES;
    }
   
}


#pragma mark 清空画布
-(void)moveAllAction
{
    //1.取消选中
    [self dissmissCheck];
    //2.清空画布视图
    for (UIView *view in _canvas.subviews) {
        [view removeFromSuperview];
    }
    //3.清空画布数据
    [self.productDataArr removeAllObjects];
    //4.加入历史记录
    [self addHistroy];
    
}

#pragma mark 从相册选择到画布
-(void)addFromPhotosAction
{
    [TZImagePickerInstance initTZImagePickerVCWithMaxCount:9 option:2];
    __weak typeof(self) selfWeak = self;
    __block NSInteger tempCount = 0;
    __block CGFloat offX = 0;
    __block CGFloat offY = 0;
    TZImagePickerInstance.imagePickerDidFinishPickingPhotostBlock = ^{
     //   [selfWeak showHUDToWindow:@"正在添加..."];
    };
    TZImagePickerInstance.photosAndCountBlock = ^(NSData * _Nullable photoData, NSInteger count) {
        if (tempCount != count) {
            UIImage *image = [UIImage imageWithData:photoData];
            //1.取消选中
            [selfWeak dissmissCheck];
            //2.构造模型
            [self installModelWithDict:image offX:offX offY:offY localUrl:@"" photoData:photoData];
            offX += 20;
            offY += 20;
        }
        tempCount++;
        if (tempCount == count) {
            //3.添加到历史记录
             [selfWeak addHistroy];
            //4.加载历史记录最后一个为空，这样进行撤回操作就是当前要加载的内容
            [selfWeak.historiesArr addObject:@[]];
            self->_hisIndex += 1;
            //5.撤回还原
            [selfWeak recallAction];
            //6.移除历史记录最后一个空的记录
            [selfWeak.historiesArr removeLastObject];
            //7.前进按钮为禁用
            self->_nextBut.enabled = NO;
           // [selfWeak hideHUD];
        }
    };

    TZImagePickerInstance.videosAndCoverimageAndCountBlock = ^(NSURL * _Nullable url, UIImage * _Nullable coverImage, NSInteger count) {
        if (tempCount != count) {
            //1.取消选中
            [selfWeak dissmissCheck];
            //2.构造模型
            [selfWeak installModelWithDict:coverImage offX:offX offY:offY localUrl:[NSString stringWithFormat:@"%@",url] photoData:UIImageJPEGRepresentation(coverImage, 1.0)];
            offX += 20;
            offY += 20;
        }
        tempCount++;
        if (tempCount == count) {
            //3.添加到历史记录
             [selfWeak addHistroy];
            //4.加载历史记录最后一个为空，这样进行撤回操作就是当前要加载的内容
            [selfWeak.historiesArr addObject:@[]];
            self->_hisIndex += 1;
            //5.撤回还原
            [selfWeak recallAction];
            //6.移除历史记录最后一个空的记录
            [selfWeak.historiesArr removeLastObject];
            //7.前进按钮为禁用
            self->_nextBut.enabled = NO;
          //  [selfWeak hideHUD];
        }

    };
}

-(void)installModelWithDict:(UIImage*)image offX:(CGFloat)offX offY:(CGFloat)offY localUrl:(NSString*)localUrl photoData:(NSData*)photoData
{
    NSMutableDictionary *obj = [[NSMutableDictionary alloc] init];
    [obj setValue:[NSString stringWithFormat:@"%f",image.size.width*0.2] forKey:@"netW"];
    [obj setValue:[NSString stringWithFormat:@"%f",image.size.height*0.2] forKey:@"netH"];
    if (localUrl.length>0) {
        [obj setValue:localUrl forKey:@"localUrl"];
    }
    float w = [[obj objectForKey:@"netW"] floatValue];
    float h = [[obj objectForKey:@"netH"] floatValue];
    h = 200;
    CGFloat s = [[obj objectForKey:@"netH"] floatValue]/h;
    w = [[obj objectForKey:@"netW"] floatValue]/s;
    float centerX = CGRectGetWidth(self->_canvas.frame)/2 + offX;
    float centerY = CGRectGetHeight(self->_canvas.frame)/2 + offY;
    float x=centerX-w/2; float y=centerY-h/2;
    //获得变形控制点
    NSArray *arr = @[@{@"centerX":[NSString stringWithFormat:@"%f",x+7.5],@"centerY":[NSString stringWithFormat:@"%f",y+7.5]},
                     @{@"centerX":[NSString stringWithFormat:@"%f",x+w - 7.5],@"centerY":[NSString stringWithFormat:@"%f",y+7.5]},
                     @{@"centerX":[NSString stringWithFormat:@"%f",x+7.5],@"centerY":[NSString stringWithFormat:@"%f",y+h - 7.5]},
                     @{@"centerX":[NSString stringWithFormat:@"%f",x+w - 7.5],@"centerY":[NSString stringWithFormat:@"%f",y+h - 7.5]},
    ];
    NSDictionary *jsonDict = @{
                               @"rotation":@0,
                               @"mirror":@0,
                               @"src":photoData,
                               @"lock":@0,
                               @"contorlPointArr":arr,
                               @"localUrl":obj[@"localUrl"]?obj[@"localUrl"]:@""
                               };
    YSKJ_drawModel *model = [YSKJ_drawModel mj_objectWithKeyValues:jsonDict];
    model.contorlPointArr = arr;
    [self.productDataArr addObject:model];
}


#pragma mark 开始拖动商品到画布
-(void)beganPanAction:(NSNotification*)notification
{
    //隐藏商品图
    _myLoad.hidden = YES;
    _corssView = [[UIView alloc] initWithFrame:CGRectMake(0,0, _canvas.frame.size.width, _canvas.frame.size.height)];
    [_canvas addSubview:_corssView];
    UIPanGestureRecognizer *panGes = [notification.userInfo objectForKey:@"ges"] ;
    UIButton *button = [notification.userInfo objectForKey:@"button"];
    CGPoint location = [panGes locationInView:button];
    CGPoint point = [button convertPoint:location toView:_canvas];
    _panButton=[[UIButton alloc] initWithFrame:CGRectMake(point.x-(CGRectGetWidth(button.frame))/2, point.y-(button.frame.size.width)/2, button.frame.size.width, button.frame.size.height)];
    _panButton.alpha = 0.8;
    [_panButton setImage:button.imageView.image forState:UIControlStateNormal];
    _panButton.imageEdgeInsets=button.imageEdgeInsets;
    [_corssView addSubview:_panButton];
}

#pragma mark 正在拖动商品到画布
-(void)panAction:(NSNotification*)notification
{
    UIPanGestureRecognizer *panGes = [notification.userInfo objectForKey:@"ges"] ;
    UIButton *button = [notification.userInfo objectForKey:@"button"];
    CGPoint location = [panGes locationInView:button];
    CGPoint point = [button convertPoint:location toView:_canvas];
    if (point.x>0 && CGRectGetWidth(button.frame)>0 && point.y>0 && button.frame.size.height>0) {
        _panButton.frame=CGRectMake(point.x-(button.frame.size.width)/2, point.y-(button.frame.size.width)/2, button.frame.size.width, button.frame.size.height);
    }
}

#pragma mark 结束拖动商品到画布
-(void)endAction:(NSNotification*)notification
{
    //限制画布数量
    NSMutableArray *imageArr = [[NSMutableArray alloc] init];
    [self.productDataArr enumerateObjectsUsingBlock:^(YSKJ_drawModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.localUrl.length == 0) {
            [imageArr addObject:obj];
        }
    }];
    NSMutableArray *videoArr = [[NSMutableArray alloc] init];
    [self.productDataArr enumerateObjectsUsingBlock:^(YSKJ_drawModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.localUrl.length > 0) {
            [videoArr addObject:obj];
        }
    }];
    
    if (imageArr.count>8) {
    //    [self showToast:@"画布最多添加9个图片"];
    }
    if (videoArr.count>2) {
     //   [self showToast:@"画布最多添加3个视频"];
    }
    
    //1.取消选中
    [self dissmissCheck];
    
    NSDictionary *obj = [notification.userInfo objectForKey:@"dict"];
    float w = [[obj objectForKey:@"netW"] floatValue]*0.2; float h = [[obj objectForKey:@"netH"] floatValue]*0.2;
    float centerX = CGRectGetWidth(_canvas.frame)/2;
    if (_panButton) {
        centerX = _panButton.center.x;
    }
    float centerY = CGRectGetHeight(_canvas.frame)/2;
    if (_panButton) {
        centerY = _panButton.center.y;
    }
    float x=centerX-w/2; float y=centerY-h/2;
    //获得变形控制点
    NSArray *arr = @[@{@"centerX":[NSString stringWithFormat:@"%f",x+7.5],@"centerY":[NSString stringWithFormat:@"%f",y+7.5]},
                     @{@"centerX":[NSString stringWithFormat:@"%f",x+w - 7.5],@"centerY":[NSString stringWithFormat:@"%f",y+7.5]},
                     @{@"centerX":[NSString stringWithFormat:@"%f",x+7.5],@"centerY":[NSString stringWithFormat:@"%f",y+h - 7.5]},
                     @{@"centerX":[NSString stringWithFormat:@"%f",x+w - 7.5],@"centerY":[NSString stringWithFormat:@"%f",y+h - 7.5]},
    ];
    NSData *data = UIImageJPEGRepresentation([obj objectForKey:@"thumb_file"], 1);
    NSDictionary *jsonDict = @{
                               @"rotation":@0,
                               @"mirror":@0,
                               @"src":data,
                               @"lock":@0,
                               @"contorlPointArr":arr,
                               @"localUrl":obj[@"localUrl"]?obj[@"localUrl"]:@""
                               };
    YSKJ_drawModel *model = [YSKJ_drawModel mj_objectWithKeyValues:jsonDict];
    model.contorlPointArr = arr;
    [self addProToDrawBoard:model];
    
    [self.naviView checkAction];
    self.naviView.btn4.enabled = YES;
}

#pragma mark 画布元素Tag重新排序
-(void)canvasImageViewWithTagSort
{
    //画板全部视图tag重新按顺序排列
    for (int i=0; i<[self imageViewArr].count; i++) {
        UIImageView *imageView = [self imageViewArr][i];
        imageView.tag = i+1;
    }
}

-(NSMutableArray*)imageViewArr     //获得画板图片数组
{
    NSMutableArray *imageArr = [[NSMutableArray alloc] init];
    for (UIView *subView in _canvas.subviews) {
        if ([subView isKindOfClass:[UIImageView class]]) {
            [imageArr addObject:subView];
        }
    }
    return imageArr;
}

#pragma mark 添加变形4点控制的虚线矩形
-(void)addBorderWithTLView:(UIButton*)TLView TRView:(UIButton *)TRView BLView:(UIButton *)BLView BRView:(UIButton *)BRView panBool:(BOOL)isPan
{
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    //开始点 从上左下右的点
    [aPath moveToPoint:CGPointMake(TLView.center.x,TLView.center.y)];
    [aPath addLineToPoint:CGPointMake(TRView.center.x, TRView.center.y)];
    [aPath addLineToPoint:CGPointMake(BRView.center.x, BRView.center.y)];
    [aPath addLineToPoint:CGPointMake(BLView.center.x, BLView.center.y)];
    [aPath closePath];
    UIColor *col=HexColor(0xbbbbbe);
    shapelayer.strokeColor = col.CGColor;
    shapelayer.fillColor=nil;
    shapelayer.path = aPath.CGPath;
    
    [shapelayer setLineDashPattern:
    [NSArray arrayWithObjects:[NSNumber numberWithInt:8],
    [NSNumber numberWithInt:5],nil]];
    shapelayer.lineWidth=0.5f;
    [_canvas.layer addSublayer:shapelayer];
    
}


#pragma mark 添加9点控制的虚线矩形
-(void)addBorderWithView:(UIView*)view;
{
     UIView *_lt,*_rt,*_rb,*_lb;
    for (UIView *sub1 in view.superview.subviews) {
        if ([sub1 isKindOfClass:[CtrlPointCtnView class]]) {
                for (UIView *sub in sub1.subviews) {
                    if (sub1.gestureRecognizers) {
                        if (sub.tag==1 ) {_lt=sub;}if (sub.tag==2 ) {_lb=sub;}
                        if (sub.tag==3 ) {_rb=sub;}if (sub.tag==4 ) {_rt=sub;}
                        
                    }
                }
        }

    }
    UIBezierPath *aPath = [UIBezierPath bezierPath];
    CGPoint point1 = [_lt.superview convertPoint:_lt.center toView:_canvas];
    CGPoint point2 = [_lb.superview convertPoint:_lb.center toView:_canvas];
    CGPoint point3 = [_rb.superview convertPoint:_rb.center toView:_canvas];
    CGPoint point4 = [_rt.superview convertPoint:_rt.center toView:_canvas];
    [aPath moveToPoint:CGPointMake(point1.x,point1.y)];
    [aPath addLineToPoint:CGPointMake(point2.x,point2.y)];
    [aPath addLineToPoint:CGPointMake(point3.x,point3.y)];
    [aPath addLineToPoint:CGPointMake(point4.x,point4.y)];
    [aPath closePath];
    _shaLayer.strokeColor = HexColor(0xbbbbbe).CGColor;
    _shaLayer.fillColor = nil;
    _shaLayer.path = aPath.CGPath;
    [_canvas.layer addSublayer:_shaLayer];
}



#pragma mark 根据历史记录打开画布
-(void)addMoreProToDrawBoardWith:(YSKJ_drawModel*)obj idx:(NSInteger)idx
{
    NSArray *centerPointArr = obj.contorlPointArr;
    __block CGFloat minX = [centerPointArr[0][@"centerX"] floatValue];
    __block CGFloat maxX = 0;
    __block CGFloat minY = [centerPointArr[0][@"centerY"] floatValue];
    __block CGFloat maxY = 0;
    for (int i=0;i<centerPointArr.count;i++) {
        NSDictionary *centerPointDict = centerPointArr[i];
        if ([centerPointDict[@"centerX"] floatValue] < minX) {
            minX = [centerPointDict[@"centerX"] floatValue];
        }
        if ([centerPointDict[@"centerX"] floatValue] > maxX) {
            maxX = [centerPointDict[@"centerX"] floatValue];
        }
        if ([centerPointDict[@"centerY"] floatValue] < minY) {
            minY = [centerPointDict[@"centerY"] floatValue];
        }
        if ([centerPointDict[@"centerY"] floatValue] > maxY) {
            maxY = [centerPointDict[@"centerY"] floatValue];
        }
    }
    UIImageView *proImg = [[UIImageView alloc] initWithFrame:CGRectMake(minX, minY, maxX - minX, maxY-minY)];
  //  proImg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    proImg.userInteractionEnabled = YES;
    proImg.tag = idx+1;
    proImg.userInteractionEnabled = YES;
    UIImage *image = [UIImage imageWithData:obj.src];
    proImg.image =  image;
 //   [proImg sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",obj.src]] placeholderImage:nil];
    //是否镜像
    if ([obj.mirror integerValue] == 1) {
        proImg.image = [proImg.image rotate:UIImageOrientationUpMirrored];
    }
    [_canvas addSubview:proImg];
    UITapGestureRecognizer *panRecognizer = [[UITapGestureRecognizer alloc] init];
    [panRecognizer addTarget:self action:@selector(proImgTapGestureChanged:)];
    [proImg addGestureRecognizer:panRecognizer];
    UIButton *tempTLbutton,*tempTRbutton,*tempBLbutton,*tempBRbutton; //选中当前视图的变形控制按钮
    for (int i=0;i<centerPointArr.count;i++) {
        NSDictionary *centerPointDict = centerPointArr[i];
        UIButton *controlpoint=[[UIButton alloc] initWithFrame:CGRectMake([centerPointDict[@"centerX"] floatValue]-15, [centerPointDict[@"centerY"] floatValue]-15, 30, 30)];
        controlpoint.center = CGPointMake([centerPointDict[@"centerX"] floatValue], [centerPointDict[@"centerY"] floatValue]);
        controlpoint.imageEdgeInsets=UIEdgeInsetsMake(7.5, 7.5, 7.5, 7.5);
        [controlpoint setImage:[UIImage imageNamed:@"controlpoint"] forState:UIControlStateNormal];
        controlpoint.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.3];
        [_canvas addSubview:controlpoint];
        if (i==0) { tempTLbutton=controlpoint;}else if (i==1){tempTRbutton=controlpoint;}else if (i==2){ tempBLbutton=controlpoint;}else if (i==3){tempBRbutton=controlpoint;}
    }
    [proImg.layer ensureAnchorPointIsSetToZero];
     proImg.layer.quadrilateral = AGKQuadMake(tempTLbutton.center,tempTRbutton.center,tempBRbutton.center,tempBLbutton.center);
}




@end


