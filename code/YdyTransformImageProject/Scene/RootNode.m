//
//  RootNode.m
//  YdyTransformImageProject
//
//  Created by LaserPecker-iOS on 2024/11/27.
//

#import "RootNode.h"

@implementation RootNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.children = [NSMutableArray array];
    }
    return self;
}

@end
