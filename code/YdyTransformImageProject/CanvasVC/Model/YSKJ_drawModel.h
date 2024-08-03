//
//  YSKJ_drawModel.h
//  GestureRecognizerTest
//
//  Created by YSKJ on 17/10/13.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSKJ_drawModel : NSObject

//angle = 0;
//centerX = "512.000000";
//centerY = "384.000000";
//contorlPoint = "[\n  {\n    \"centerX\" : \"392.000000\",\n    \"centerY\" : \"334.799988\"\n  },\n  {\n    \"centerX\" : \"632.000000\",\n    \"centerY\" : \"334.799988\"\n  },\n  {\n    \"centerX\" : \"392.000000\",\n    \"centerY\" : \"433.199988\"\n  },\n  {\n    \"centerX\" : \"632.000000\",\n    \"centerY\" : \"433.199988\"\n  }\n]";
//h = "98.400000";
//id = 1000;
//lockState = 0;
//mirror = 0;
//url = "http://odso4rdyy.qnssl.com/store/x20006/1.png";
//w = "240.000000";
//x = "392.000000";
//y = "334.799988";

@property (nonatomic ,copy) NSString *x;
@property (nonatomic ,copy) NSString *y;
@property (nonatomic ,copy) NSString *scaleX;
@property (nonatomic ,copy) NSString *scaleY;
@property (nonatomic ,copy) NSString *rotation;
@property (nonatomic ,copy) NSString *objtype;
@property (nonatomic ,copy) NSString *mirror;
@property (nonatomic ,copy) NSData *src;
@property (nonatomic ,copy) NSString *lock;
@property (nonatomic ,copy) NSString *pid;
@property (nonatomic ,copy) NSString *naturew;
@property (nonatomic ,copy) NSString *natureh;
@property (nonatomic, copy) NSString *originX;
@property (nonatomic, copy) NSString *originY;
@property (nonatomic, copy) NSString *w;
@property (nonatomic, copy) NSString *h;
@property (nonatomic, copy) NSString *imageId;
@property (nonatomic, copy) NSArray *contorlPointArr;
@property (nonatomic, copy) NSString *localUrl;


@end
