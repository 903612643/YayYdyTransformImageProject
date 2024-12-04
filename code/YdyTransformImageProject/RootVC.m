//
//  RootVC.m
//  YdyTransformImageProject
//
//  Created by LaserPecker-iOS on 2024/11/29.
//

#import "RootVC.h"
#import "SceneRootViewController.h"
#import "CanvasRootController.h"
#import "DeviceLinkRootVC.h"

@interface RootVC ()

@end

@implementation RootVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)showSceneAction:(UIButton *)sender {
    
    SceneRootViewController *vc = [[SceneRootViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (IBAction)showCanvasAction:(UIButton *)sender {
    CanvasRootController *vc = [[CanvasRootController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)deviceLinkAction:(id)sender {
    DeviceLinkRootVC *vc = [[DeviceLinkRootVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
