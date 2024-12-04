//
//  AppDelegate.m
//  YdyTransformImageProject
//
//  Created by yangdeyuan on 2024/8/2.
//

#import "AppDelegate.h"
#import "RootVC.h"
#import "SceneRootViewController.h"
#import "assimpLoader.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];

    SceneRootViewController *rootVC = [[SceneRootViewController alloc] init];
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:rootVC];
  
    self.window.rootViewController = navi;

    [self.window makeKeyAndVisible];

    return YES;
}




@end
