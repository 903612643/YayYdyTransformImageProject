#import "assimpLoader.h"
#include "Importer.hpp"
#include "scene.h"
#include "postprocess.h"
#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>


@interface SceneRootViewController1 ()
@property (nonatomic, assign) GLfloat rotationAngle;
@end

@implementation SceneRootViewController1

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建一个 SCNView
      SCNView *sceneView = [[SCNView alloc] initWithFrame:self.view.bounds];
      sceneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
      [self.view addSubview:sceneView];
      
      // 创建一个空场景
      SCNScene *scene = [SCNScene scene];
      sceneView.scene = scene;
      // 启用用户交互控制相机
      sceneView.allowsCameraControl = YES;
      sceneView.autoenablesDefaultLighting = YES;
      // 设置背景颜色
      sceneView.backgroundColor = [UIColor whiteColor];
      // 创建 assimpLoader 实例
      assimpLoader *loader = [[assimpLoader alloc] init];
      // 模型文件路径
      NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Car" ofType:@"fbx"];
      // 异步加载模型
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
          [loader loadOBJModelWithPath:filePath];
          // 生成几何体
          geometryFromLoader *geometryLoader = [[geometryFromLoader alloc] init];
          SCNGeometry *geometry = [geometryLoader geometryFromLoader:loader vertexMaxHBlock:^(float h) {
          }];
          // 模型加载完成后更新场景
          if (geometry) {
              dispatch_async(dispatch_get_main_queue(), ^{
                  // 创建模型节点
                  SCNNode *modelNode = [SCNNode nodeWithGeometry:geometry];
                  // 自定义材质
                  SCNMaterial *material = [SCNMaterial material];
                  material.diffuse.contents = [UIImage imageNamed:@"Mat_Robot_Base_Color_Mixed"]; // 使用图片纹理
                  geometry.materials = @[material];
                  // 调整模型比例（缩放至合适大小）
                  scene.rootNode.scale = SCNVector3Make(0.7, 0.7, 0.7);
                  // 调整模型位置（确保模型位于屏幕中央）
                  modelNode.position = SCNVector3Make(0,-3.8, 0);
                  NSArray *animations = modelNode.animationKeys;
                  if (animations.count > 0) {
                      NSString *animationKey = animations.firstObject;
                      [modelNode addAnimation:[modelNode animationForKey:animationKey] forKey:animationKey];
                  }
                  [scene.rootNode addChildNode:modelNode];
              });
          } else {
              NSLog(@"Failed to generate geometry from loaded model.");
          }
      });
    
}

@end




@implementation geometryFromLoader

- (SCNGeometry *)geometryFromLoader:(assimpLoader *)loader vertexMaxHBlock:(void(^)(float h))vertexMaxHBlock {
    RootNode *rootNode = loader.rootNode; // 获取加载后的根节点
    if (!rootNode) {
        NSLog(@"No model data available in loader.");
        return nil;
    }

    // 提取顶点和索引数据
    NSMutableArray *vertexArray = [NSMutableArray array];
    NSMutableArray *indexArray = [NSMutableArray array];
    NSMutableArray *uvArray = [NSMutableArray array];  // 用于存储UV坐标
        
    [self extractGeometryFromNode:rootNode intoVertices:vertexArray indices:indexArray uvs:uvArray];
    
    if (vertexArray.count == 0 || indexArray.count == 0) {
        NSLog(@"Model data is empty.");
        return nil;
    }

    // 计算原始顶点数据的中心点和缩放因子
    float minX = FLT_MAX, minY = FLT_MAX, minZ = FLT_MAX;
    float maxX = -FLT_MAX, maxY = -FLT_MAX, maxZ = -FLT_MAX;
    
    // 转换顶点数据
    int vertexCount = (int)vertexArray.count;
    SCNVector3 *vertices = (SCNVector3 *)malloc(sizeof(SCNVector3) * vertexCount);
    for (int i = 0; i < vertexCount; i++) {
        NSArray *vertex = vertexArray[i];
        float x = [vertex[0] floatValue]/100;
        float y = [vertex[1] floatValue]/100;
        float z = [vertex[2] floatValue]/100;
        vertices[i] = SCNVector3Make(x, y, z);
        minX = MIN(minX, x);
        minY = MIN(minY, y);
        minZ = MIN(minZ, z);
        maxX = MAX(maxX, x);
        maxY = MAX(maxY, y);
        maxZ = MAX(maxZ, z);
    }
    
    vertexMaxHBlock((minY + maxY) / 10);
    
    // 转换索引数据
    int indexCount = (int)indexArray.count;
    int *indices = (int *)malloc(sizeof(int) * indexCount);
    for (int i = 0; i < indexCount; i++) {
        indices[i] = [indexArray[i] intValue];
    }
    
    
    // 转换UV数据
    int uvCount = (int)uvArray.count;
    CGPoint *uvs = (CGPoint *)malloc(sizeof(CGPoint) * uvCount);
    for (int i = 0; i < uvCount; i++) {
        NSArray *uv = uvArray[i];
        uvs[i] = CGPointMake([uv[0] floatValue], [uv[1] floatValue]);
    }

    // 创建 SceneKit 的几何源和几何元素
    
    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithVertices:vertices count:vertexCount];
    NSData *indexData = [NSData dataWithBytes:indices length:sizeof(int) * indexCount];
    SCNGeometryElement *geometryElement = [SCNGeometryElement geometryElementWithData:indexData
                                                                        primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                                       primitiveCount:indexCount / 3
                                                                        bytesPerIndex:sizeof(int)];
    
    // 创建几何体
    SCNGeometrySource *uvSource = [SCNGeometrySource geometrySourceWithTextureCoordinates:uvs count:uvCount];
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vertexSource, uvSource] elements:@[geometryElement]];
//    // 自定义材质
//    SCNMaterial *material = [SCNMaterial material];
//    material.diffuse.contents = [UIImage imageNamed:@"Mat_Robot_Base_Color_Mixed"]; // 使用图片纹理
//    geometry.materials = @[material];
    // 释放内存
    free(vertices);
    free(indices);
    
    return geometry;
}

// 修改遍历方法，提取UV坐标
- (void)extractGeometryFromNode:(RootNode *)node
                   intoVertices:(NSMutableArray *)vertexArray
                        indices:(NSMutableArray *)indexArray
                            uvs:(NSMutableArray *)uvArray {
    // 添加当前节点的顶点、索引和UV数据
    [vertexArray addObjectsFromArray:node.vertices];
    [indexArray addObjectsFromArray:node.indices];
    [uvArray addObjectsFromArray:node.uvs]; // 假设你在节点中存储了UV坐标
    
    // 遍历子节点
    for (RootNode *child in node.children) {
        [self extractGeometryFromNode:child intoVertices:vertexArray indices:indexArray uvs:uvArray];
    }
}

@end




@implementation assimpLoader

- (void)loadOBJModelWithPath:(NSString *)filePath {
    const char *path = [filePath UTF8String];
    Assimp::Importer importer;
    const aiScene *scene = importer.ReadFile(path,
                                             aiProcess_Triangulate |
                                             aiProcess_FlipUVs |
                                             aiProcess_JoinIdenticalVertices |
                                             aiProcess_PreTransformVertices |
                                             aiProcess_CalcTangentSpace
                                             );

    if (!scene || scene->mFlags & AI_SCENE_FLAGS_INCOMPLETE || !scene->mRootNode) {
        NSLog(@"Error loading model: %s", importer.GetErrorString());
        return;
    }

    // 初始化根节点
    self.rootNode = [[RootNode alloc] init];
    self.rootNode.name = @"Root";
    // 递归构建场景图
    [self buildSceneGraphFromNode:scene->mRootNode
                        inScene:scene
                       parentNode:self.rootNode];
}

- (void)buildSceneGraphFromNode:(aiNode *)node
                        inScene:(const aiScene *)scene
                     parentNode:(RootNode *)parentNode {
    // 创建当前节点
    RootNode *currentNode = [[RootNode alloc] init];
    currentNode.name = [NSString stringWithUTF8String:node->mName.C_Str()];
    // 遍历所有 Mesh，提取数据
    NSMutableArray *vertices = [NSMutableArray array];
    NSMutableArray *indices = [NSMutableArray array];
    NSMutableArray *uvs = [NSMutableArray array];
    for (unsigned int i = 0; i < node->mNumMeshes; i++) {
        aiMesh *mesh = scene->mMeshes[node->mMeshes[i]];
        // 提取顶点数据
        for (unsigned int j = 0; j < mesh->mNumVertices; j++) {
            float x = mesh->mVertices[j].x;
            float y = mesh->mVertices[j].y;
            float z = mesh->mVertices[j].z;
            [vertices addObject:@[@(x), @(y), @(z)]];
            
            // 检查 UV 数据
            if (mesh->mTextureCoords[0]) { // 检查是否有第一个纹理坐标集
                float u = mesh->mTextureCoords[0][j].x;
                float v = mesh->mTextureCoords[0][j].y;
               // NSLog(@"Vertex %u has UV: (%f, %f)", j, u, v);
                [uvs addObject:@[@(u), @(v)]];
            } else {
                NSLog(@"Vertex %u has no UV data", j);
            }
        }
        // 提取面索引数据
        for (unsigned int j = 0; j < mesh->mNumFaces; j++) {
            aiFace face = mesh->mFaces[j];
            for (unsigned int k = 0; k < face.mNumIndices; k++) {
                [indices addObject:@(face.mIndices[k])];
            }
        }
    }
    // 将当前节点的顶点和索引数据添加到节点中
    currentNode.vertices = [vertices copy];
    currentNode.indices = [indices copy];
    currentNode.uvs = [uvs copy];
    // 将当前节点添加到父节点
    [parentNode.children addObject:currentNode];
    // 递归处理子节点
    for (unsigned int i = 0; i < node->mNumChildren; i++) {
        [self buildSceneGraphFromNode:node->mChildren[i]
                            inScene:scene
                           parentNode:currentNode];
    }
}


@end



@implementation RootNode

- (instancetype)init {
    self = [super init];
    if (self) {
        _children = [NSMutableArray array];
        _vertices = [NSMutableArray array];
        _indices = [NSMutableArray array];
        _uvs = [NSMutableArray array];
    }
    return self;
}

@end
