//
//  YSKJ_drawModel.m
//  GestureRecognizerTest
//
//  Created by YSKJ on 17/10/13.
//  Copyright © 2017年 com.yskj. All rights reserved.
//

#import "YSKJ_drawModel.h"

@implementation YSKJ_drawModel

-(id)copyWithZone:(NSZone *)zone {

    YSKJ_drawModel *newClass = [[YSKJ_drawModel alloc]init];
    newClass.x = self.x;
    newClass.y = self.y;
    newClass.scaleX = self.scaleX;
    newClass.scaleY = self.scaleY;
    newClass.rotation = self.rotation;
    newClass.objtype = self.objtype;
    newClass.mirror = self.mirror;
    newClass.src = self.src;
    newClass.lock = self.lock;
    newClass.pid = self.pid;
    newClass.naturew = self.naturew;
    newClass.natureh = self.natureh;
    newClass.originX = self.originX;
    newClass.originY = self.originY;
    newClass.w = self.w;
    newClass.h = self.h;
    newClass.imageId = self.imageId;
    newClass.contorlPointArr = self.contorlPointArr;
    newClass.localUrl = self.localUrl;
    return newClass;
    
}

@end
