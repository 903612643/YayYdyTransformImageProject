//
//  H_TZImagePickerHelper.h
//  HTIME
//
//  Created by yangdeyuan on 2021/7/23.
//  Copyright © 2021 yangdeyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TZImagePickerController.h"

#define TZImagePickerInstance [H_TZImagePickerHelper instance]

//获取视频url
typedef void(^H_TZImagePickerHelperVideosBlock)(NSURL * _Nullable url);

//获取一个视频和封面
typedef void(^H_TZImagePickerHelperVideoAndCoverimageBlock)(NSURL * _Nullable url,UIImage * _Nullable coverImage);

//获取图片NSData
typedef void(^H_TZImagePickerHelperPhotosBlock)(NSData * _Nullable photoData);

//获取一张图片并裁剪
typedef void(^H_TZImagePickerHelperProcessPhotosBlock)(NSArray * _Nullable photos);

//获取多个视频和封面
typedef void(^H_TZImagePickerHelperVideosAndCoverimageBlock)(NSURL * _Nullable url,UIImage * _Nullable coverImage);

//获取图片NSData
typedef void(^H_TZImagePickerHelperPhotosAndCountBlock)(NSData * _Nullable photoData,NSInteger count);
//获取多个视频和封面
typedef void(^H_TZImagePickerHelperVideosAndCoverimageAndCountBlock)(NSURL * _Nullable url,UIImage * _Nullable coverImage,NSInteger count);

//获取多个视频和封面
typedef void(^H_TZImagePickerDidFinishPickingPhotostBlock)(void);

NS_ASSUME_NONNULL_BEGIN

@interface H_TZImagePickerHelper : NSObject<TZImagePickerControllerDelegate>

+(instancetype)instance;

/*
 maxCount 选择数量
 option 1选择视频
 option 2选择视频并且选择图片
 */
-(void)initTZImagePickerVCWithMaxCount:(int)maxCount option:(int)option;


@property (nonatomic,copy)H_TZImagePickerHelperVideosBlock videosBlock;
@property (nonatomic,copy)H_TZImagePickerHelperVideoAndCoverimageBlock videoAndCoverimageBlock;
@property (nonatomic,copy)H_TZImagePickerHelperPhotosBlock photosBlock;
@property (nonatomic,copy)H_TZImagePickerHelperProcessPhotosBlock processPhotosBlock;
@property (nonatomic,copy)H_TZImagePickerHelperVideosAndCoverimageBlock videosAndCoverimageBlock;
@property (nonatomic,copy)H_TZImagePickerHelperPhotosAndCountBlock photosAndCountBlock;
@property (nonatomic,copy)H_TZImagePickerHelperVideosAndCoverimageAndCountBlock videosAndCoverimageAndCountBlock;
@property (nonatomic,copy)H_TZImagePickerDidFinishPickingPhotostBlock imagePickerDidFinishPickingPhotostBlock;

@property (nonatomic,assign)int optionTag;

@end

NS_ASSUME_NONNULL_END
