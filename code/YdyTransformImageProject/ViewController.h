//
//  ViewController.h
//  YdyTransformImageProject
//
//  Created by yangdeyuan on 2024/8/2.
//

#import <UIKit/UIKit.h>

#import "UIView+Transform.h"
#import "YSKJ_HistoryModel.h"
#import "YSKJ_NaviView.h"
#import "YSKJ_MyLoadProduct.h"
#import <AGGeometryKit/AGGeometryKit.h>
#import <POPAnimatableProperty+AGGeometryKit.h>
#import <pop/POP.h>
#import "CtrlPointCtnView.h"
#import "CanvasViewOptionHelper.h"
#import "YSKJ_CanvasView.h"

#import <AVKit/AVKit.h>

@interface ViewController : UIViewController<ViewTransformeDelegate>
{

    ViewTransformConfiguration *cnf;
    UIImageView *_targetView;  //当前选中元素
    
    UIButton *_panButton;     //覆盖层上的拖动按钮
    UIView *_corssView;       //拖动元素到画布覆盖层
     
    CAShapeLayer *_shaLayer;   //9点虚线

    UIButton *tempTLbutton,*tempTRbutton,*tempBLbutton,*tempBRbutton; //选中当前视图的变形控制按钮
    CAShapeLayer  *shapelayer;  //变形虚线
    
    UIButton *_recallBut,*_nextBut;//撤回与前进按钮
    
    int  _hisIndex;//
    
    NSInteger  _sendInNdex;//
}

@property (nonatomic, strong) YSKJ_CanvasView *canvas;
@property (nonatomic, strong) YSKJ_MyLoadProduct *myLoad;
@property (nonatomic, assign) BOOL issueLike;


@end
