//
//  RootNode.h
//  YdyTransformImageProject
//
//  Created by LaserPecker-iOS on 2024/11/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RootNode : NSObject

@property (nonatomic, strong) NSString *name;                  // 节点名称
@property (nonatomic, strong) NSArray<NSArray *> *vertices;    // 顶点数据
@property (nonatomic, strong) NSArray<NSNumber *> *indices;    // 索引数据
@property (nonatomic, strong) NSMutableArray<RootNode *> *children; // 子节点

@end

NS_ASSUME_NONNULL_END
