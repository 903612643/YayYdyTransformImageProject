//
//  A_Util.h
//  AMICO
//
//  Created by 羊德元 on 2019/1/26.
//  Copyright © 2019 amico. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface H_Util : NSObject

+ (UIViewController *)getCurrentVC ;
//mov转MP4
+ (void)jjMovConvert2Mp4:(NSURL *)movUrl outUrl:(void(^)(NSURL *url))outPathBlock fail:(void(^)(void))fail;

@end

NS_ASSUME_NONNULL_END
