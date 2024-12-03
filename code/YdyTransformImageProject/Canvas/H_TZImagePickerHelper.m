//
//  H_TZImagePickerHelper.m
//  HTIME
//
//  Created by yangdeyuan on 2021/7/23.
//  Copyright © 2021 yangdeyuan. All rights reserved.
//

#import "H_TZImagePickerHelper.h"
#import "H_Util.h"

#define SCREEN_WIDTH     [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT     [UIScreen mainScreen].bounds.size.height

#define FONT_Medium_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Medium" size:_size_]
#define FONT_Semibold_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Semibold" size:_size_]
#define FONT_Regular_SIZE(_size_) [UIFont fontWithName:@"PingFangSC-Regular" size:_size_]

// 16进制颜色值，如：#000000 , 注意：在使用的时候hexValue写成：0x000000
#define HexColor(hexValue) [UIColor colorWithRed:((float)(((hexValue) & 0xFF0000) >> 16))/255.0 green:((float)(((hexValue) & 0xFF00) >> 8))/255.0 blue:((float)((hexValue) & 0xFF))/255.0 alpha:1.0]

@implementation H_TZImagePickerHelper

+ (instancetype)instance
{
    static H_TZImagePickerHelper* tZImagePickerHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tZImagePickerHelper = [[H_TZImagePickerHelper alloc] init];
    });
    return tZImagePickerHelper;
}


/*
 maxCount 选择数量
 option 1选择视频
 option 2选择视频并且选择图片
 option 3选择一张图片并裁剪
 option 4选择多张照片
 */
-(void)initTZImagePickerVCWithMaxCount:(int)maxCount option:(int)option
{
    self.optionTag = option;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 columnNumber:4 delegate:self pushPhotoPickerVc:YES];
    imagePickerVc.pickerDelegate = self;
    // 2. 在这里设置imagePickerVc的外观
     imagePickerVc.navigationBar.barTintColor = HexColor(0x222A36);
     imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
     imagePickerVc.oKButtonTitleColorNormal = HexColor(0x2CB1F0);
     imagePickerVc.navigationBar.translucent = NO;
    if (option == 1) {
        imagePickerVc.allowTakePicture = NO; // 不能拍摄照片
        imagePickerVc.allowTakeVideo = NO; //不能拍摄视频
        // 3. 设置是否可以选择视频/图片/原图
        imagePickerVc.allowPickingVideo = YES;
        imagePickerVc.allowPickingImage = NO;
        imagePickerVc.allowPickingOriginalPhoto = NO;
        if (maxCount>1) {
            imagePickerVc.allowPickingMultipleVideo = YES;
        }else{
            imagePickerVc.allowPickingMultipleVideo = NO;
        }
        imagePickerVc.maxImagesCount = maxCount;
    }else if(option == 2){
        imagePickerVc.allowTakePicture = NO; // 不能拍摄照片
        imagePickerVc.allowTakeVideo = NO; //不能拍摄视频
        // 3. 设置是否可以选择视频/图片/原图
        imagePickerVc.allowPickingVideo = YES;
        imagePickerVc.allowPickingImage = YES;
        imagePickerVc.allowPickingOriginalPhoto = NO;
        imagePickerVc.allowPickingMultipleVideo = YES;
        imagePickerVc.maxImagesCount = maxCount;
    }else if(option == 3){
        imagePickerVc.isSelectOriginalPhoto = YES;
        imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
        //3.设置是否可以选择视频/图片/原图
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.allowPickingImage = YES;
        imagePickerVc.allowPickingOriginalPhoto = YES;
        imagePickerVc.allowPickingGif = NO;
        // 设置竖屏下的裁剪尺寸
        imagePickerVc.allowCrop = YES;
        NSInteger left = 0;
        NSInteger widthHeight = SCREEN_WIDTH - 2 * left;
        NSInteger top = (SCREEN_HEIGHT - widthHeight) / 2;
        imagePickerVc.cropRect = CGRectMake(left, top, widthHeight, widthHeight);
    }else if(option == 4){
        imagePickerVc.isSelectOriginalPhoto = YES;
        imagePickerVc.allowTakePicture = NO; // 在内部显示拍照按钮
        // 3. 设置是否可以选择视频/图片/原图
        imagePickerVc.allowPickingVideo = NO;
        imagePickerVc.allowPickingImage = YES;
        imagePickerVc.allowPickingOriginalPhoto = YES;
        imagePickerVc.allowPickingGif = NO;
        imagePickerVc.maxImagesCount = maxCount;
    }else{
        imagePickerVc.allowTakePicture = NO; // 不能拍摄照片
        imagePickerVc.allowTakeVideo = NO; //不能拍摄视频
        imagePickerVc.allowPickingMultipleVideo = NO;
        imagePickerVc.maxImagesCount = maxCount;
    }
    // 4. 照片排列按修改时间升序
    imagePickerVc.sortAscendingByModificationDate = YES;
    /// 5. Single selection mode, valid when maxImagesCount = 1
    /// 5. 单选模式,maxImagesCount为1时才生效
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.modalPresentationStyle = 0;
    [[H_Util getCurrentVC] presentViewController:imagePickerVc animated:YES completion:nil];
    
}



#pragma mark  TZImagePickerControllerDelegate

- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto infos:(NSArray<NSDictionary *> *)infos;
{
    
    if (self.imagePickerDidFinishPickingPhotostBlock) {
        self.imagePickerDidFinishPickingPhotostBlock();
    }
    if (assets.count<=0) {
        return;
    }
    
    if (self.optionTag == 3) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.processPhotosBlock) {
                self.processPhotosBlock(photos);
            }
        });
        return;
    }
    __weak typeof(self) selfWeak = self;
    for (PHAsset *asset in assets) {
     if (asset.mediaType == PHAssetMediaTypeVideo) {
         PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
         options.version = PHVideoRequestOptionsVersionOriginal;
         options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
         options.networkAccessAllowed = YES;
          [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
              AVURLAsset *urlAsset = (AVURLAsset*)asset;
              NSURL *url = urlAsset.URL;
              NSString *urlStr = [url path];
              
              AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
              gen.appliesPreferredTrackTransform = YES;
              CMTime time = CMTimeMakeWithSeconds(0.0, 600);
              NSError *error = nil;
              CMTime actualTime;
              CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
              UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
              
              
              if (![urlStr containsString:@".MP4"] && ![urlStr containsString:@".mp4"]) {
                   [H_Util jjMovConvert2Mp4:url outUrl:^(NSURL *url) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           if (selfWeak.videosBlock) {
                               selfWeak.videosBlock(url);
                           }
                           if (selfWeak.videosAndCoverimageBlock) {
                               selfWeak.videosAndCoverimageBlock(url, thumb);
                           }
                           if (selfWeak.videosAndCoverimageAndCountBlock) {
                               selfWeak.videosAndCoverimageAndCountBlock(url, thumb,assets.count);
                           }
                       });
                  } fail:^{
                  }];
              }else{
                  dispatch_async(dispatch_get_main_queue(), ^{
                      if (selfWeak.videosBlock) {
                          selfWeak.videosBlock(url);
                      }
                      if (selfWeak.videosAndCoverimageBlock) {
                          selfWeak.videosAndCoverimageBlock(url, thumb);
                      }
                      if (selfWeak.videosAndCoverimageAndCountBlock) {
                          selfWeak.videosAndCoverimageAndCountBlock(url, thumb,assets.count);
                      }
                  });
              }
          }];
     }else{
         [ [PHImageManager defaultManager] requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 if (orientation != UIImageOrientationUp) {
                     UIImage* image = [UIImage imageWithData:imageData];
                     // 尽然弯了,那就板正一下
                     image = [selfWeak fixOrientation:image];
                     if (selfWeak.photosBlock) {
                         selfWeak.photosBlock(UIImageJPEGRepresentation(image, 1.0));
                     }
                     if (selfWeak.photosAndCountBlock) {
                         selfWeak.photosAndCountBlock(UIImageJPEGRepresentation(image, 1.0),assets.count);
                     }
                 }else{
                     if (selfWeak.photosBlock) {
                         selfWeak.photosBlock(imageData);
                     }
                     if (selfWeak.photosAndCountBlock) {
                         selfWeak.photosAndCountBlock(imageData,assets.count);
                     }
                 }
                 
             });
         }];
     }

   }
}


// If allowPickingMultipleVideo is YES, will call imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
// 如果用户选择了一个视频且allowPickingMultipleVideo是NO，下面的代理方法会被执行
// 如果allowPickingMultipleVideo是YES，将会调用imagePickerController:didFinishPickingPhotos:sourceAssets:isSelectOriginalPhoto:
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(PHAsset *)asset;
{
    __weak typeof(self) selfWeak = self;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
      //  [[H_Util getCurrentVC] showHUDToWindow:@"正在获取视频..."];
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHVideoRequestOptionsVersionOriginal;
        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
        options.networkAccessAllowed = YES;
         [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
             AVURLAsset *urlAsset = (AVURLAsset*)asset;
             NSURL *url = urlAsset.URL;
             NSString *urlStr = [url path];
             if (![urlStr containsString:@".MP4"] && ![urlStr containsString:@".mp4"]) {
                 [H_Util jjMovConvert2Mp4:url outUrl:^(NSURL *url) {
                     dispatch_async(dispatch_get_main_queue(), ^{
                     //    [[H_Util getCurrentVC] hideHUD];
                         UIImage *tempImage = coverImage;
                         tempImage = [selfWeak fixOrientation:tempImage];
                         if (selfWeak.videoAndCoverimageBlock) {
                             selfWeak.videoAndCoverimageBlock(url, tempImage);
                         }
                     });
                } fail:^{
                    dispatch_async(dispatch_get_main_queue(), ^{
                    //    [[H_Util getCurrentVC] hideHUD];
                    });
                }];
             }else{
                 dispatch_async(dispatch_get_main_queue(), ^{
                 //    [[H_Util getCurrentVC] hideHUD];
                     UIImage *tempImage = coverImage;
                     tempImage = [selfWeak fixOrientation:tempImage];
                     if (selfWeak.videoAndCoverimageBlock) {
                         selfWeak.videoAndCoverimageBlock(url, tempImage);
                     }
                 });
                 
             }
         }];
        
    }
}

/** 解决旋转90度问题 */
- (UIImage *)fixOrientation:(UIImage *)aImage
{
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


@end
