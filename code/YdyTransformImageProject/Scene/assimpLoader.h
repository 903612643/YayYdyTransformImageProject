//
//  assimpLoader.h
//  YdyTransformImageProject
//
//  Created by LaserPecker-iOS on 2024/11/27.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

@interface SceneRootViewController1 : UIViewController

@end

@class assimpLoader;
@interface geometryFromLoader : NSObject

- (SCNGeometry *)geometryFromLoader:(assimpLoader *)loader  vertexMaxHBlock:(void(^)(float h))vertexMaxHBlock;

@end

@class RootNode;
@interface assimpLoader : NSObject

@property (nonatomic, strong) RootNode *rootNode; // 根节点

- (void)loadOBJModelWithPath:(NSString *)filePath;

@end


@interface RootNode : NSObject

@property (nonatomic, strong) NSString *name;                  // 节点名称
@property (nonatomic, strong) NSArray<NSArray *> *vertices;    // 顶点数据
@property (nonatomic, strong) NSArray<NSNumber *> *indices;    // 索引数据
@property (nonatomic, strong) NSArray *uvs;       // UV坐标数组
@property (nonatomic, strong) NSMutableArray<RootNode *> *children; // 子节点

@end



