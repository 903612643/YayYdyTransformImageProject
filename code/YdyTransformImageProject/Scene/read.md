#  <#Title#>

//
//  assimpLoader.m
//  YdyTransformImageProject
//
//  Created by LaserPecker-iOS on 2024/11/27.
//

#import "assimpLoader.h"
#include "Importer.hpp"
#include "scene.h"
#include "postprocess.h"
#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>


@implementation geometryFromLoader

- (SCNGeometry *)geometryFromLoader:(assimpLoader *)loader  vertexMaxHBlock:(void(^)(float h))vertexMaxHBlock{
    RootNode *rootNode = loader.rootNode; // 获取加载后的根节点
    if (!rootNode) {
        NSLog(@"No model data available in loader.");
        return nil;
    }
    
    // 提取顶点和索引数据
    NSMutableArray *vertexArray = [NSMutableArray array];
    NSMutableArray *indexArray = [NSMutableArray array];
    
    [self extractGeometryFromNode:rootNode intoVertices:vertexArray indices:indexArray];
    
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
    
    vertexMaxHBlock((minY+maxY)/10);
    


    
    // 转换索引数据
    int indexCount = (int)indexArray.count;
    int *indices = (int *)malloc(sizeof(int) * indexCount);
    for (int i = 0; i < indexCount; i++) {
        indices[i] = [indexArray[i] intValue];
    }
    
    // 创建 SceneKit 的几何源和几何元素
    SCNGeometrySource *vertexSource = [SCNGeometrySource geometrySourceWithVertices:vertices count:vertexCount];
    NSData *indexData = [NSData dataWithBytes:indices length:sizeof(int) * indexCount];
    SCNGeometryElement *geometryElement = [SCNGeometryElement geometryElementWithData:indexData
                                                                        primitiveType:SCNGeometryPrimitiveTypeTriangles
                                                                       primitiveCount:indexCount / 3
                                                                        bytesPerIndex:sizeof(int)];
    
    // 创建几何体
    SCNGeometry *geometry = [SCNGeometry geometryWithSources:@[vertexSource] elements:@[geometryElement]];
    

    // 释放内存
    free(vertices);
    free(indices);
    
    return geometry;
}

// 遍历 RootNode 提取顶点和索引数据
- (void)extractGeometryFromNode:(RootNode *)node
                   intoVertices:(NSMutableArray *)vertexArray
                        indices:(NSMutableArray *)indexArray {
    // 添加当前节点的顶点和索引数据
    [vertexArray addObjectsFromArray:node.vertices];
    [indexArray addObjectsFromArray:node.indices];
    
    // 遍历子节点
    for (RootNode *child in node.children) {
        [self extractGeometryFromNode:child intoVertices:vertexArray indices:indexArray];
    }
}

@end




@implementation assimpLoader

- (void)loadOBJModelWithPath:(NSString *)filePath filePathBlock:(void(^)(NSString *filePath))filePathBlock {
    const char *path = [filePath UTF8String];
    Assimp::Importer importer;
    
    NSLog(@"---loadOBJModelWithPath====%@",filePath);
    
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
                       parentNode:self.rootNode filePathBlock:^(NSString *filePath1) {
    }];
    
    
}

- (void)buildSceneGraphFromNode:(aiNode *)node
                        inScene:(const aiScene *)scene
                     parentNode:(RootNode *)parentNode filePathBlock:(void(^)(NSString *filePath1))filePathBlock  {

    // 创建当前节点
    RootNode *currentNode = [[RootNode alloc] init];
    currentNode.name = [NSString stringWithUTF8String:node->mName.C_Str()];

    // 遍历所有 Mesh，提取数据
    NSMutableArray *vertices = [NSMutableArray array];
    NSMutableArray *indices = [NSMutableArray array];

    for (unsigned int i = 0; i < node->mNumMeshes; i++) {
        aiMesh *mesh = scene->mMeshes[node->mMeshes[i]];

        // 提取顶点数据
        for (unsigned int j = 0; j < mesh->mNumVertices; j++) {
            float x = mesh->mVertices[j].x;
            float y = mesh->mVertices[j].y;
            float z = mesh->mVertices[j].z;
            [vertices addObject:@[@(x), @(y), @(z)]];
            
//            // 检查 UV 数据
//            if (mesh->mTextureCoords[0]) { // 检查是否有第一个纹理坐标集
//                float u = mesh->mTextureCoords[0][j].x;
//                float v = mesh->mTextureCoords[0][j].y;
//                NSLog(@"Vertex %u has UV: (%f, %f)", j, u, v);
//            } else {
//                NSLog(@"Vertex %u has no UV data", j);
//            }
            
        }
        
        // 提取面索引数据
        for (unsigned int j = 0; j < mesh->mNumFaces; j++) {
            aiFace face = mesh->mFaces[j];
            for (unsigned int k = 0; k < face.mNumIndices; k++) {
                [indices addObject:@(face.mIndices[k])];
            }
        }
        
        // **添加提取纹理的代码**
       if (mesh->mMaterialIndex >= 0) {
           aiMaterial* material = scene->mMaterials[mesh->mMaterialIndex];
           aiString path;
           if (material->GetTexture(aiTextureType_DIFFUSE, 0, &path) == AI_SUCCESS) {
               NSString *texturePath = [NSString stringWithUTF8String:path.C_Str()];
               NSLog(@"Diffuse texture path: %@",texturePath);
             //  filePathBlock(texturePath);
           } else {
               NSLog(@"No diffuse texture found for this material.");
           }
       }
    }
    

    currentNode.vertices = [vertices copy];
    currentNode.indices = [indices copy];

    // 将当前节点添加到父节点
    [parentNode.children addObject:currentNode];

    // 递归处理子节点
    for (unsigned int i = 0; i < node->mNumChildren; i++) {
        [self buildSceneGraphFromNode:node->mChildren[i]
                            inScene:scene
                           parentNode:currentNode filePathBlock:^(NSString *filePath1) {
            
        }];
    }
}



@end




@implementation RootNode

- (instancetype)init {
    self = [super init];
    if (self) {
        self.children = [NSMutableArray array];
    }
    return self;
}

@end







@interface SceneRootViewController ()

@property (nonatomic, assign) GLfloat rotationAngle;

@end

@implementation SceneRootViewController

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
      sceneView.backgroundColor = [UIColor blackColor];
    
      
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
                  
                  // 获取模型的几何体
                 // SCNGeometry *geometry = modelNode.geometry;

//                  // 获取几何体的边界框
//                  SCNVector3 min, max;
//                  [geometry getBoundingBoxMin:&min max:&max];
//
//                  // 打印模型的边界框尺寸
//                  float width = max.x - min.x;
//                  float height = max.y - min.y;
//                  float depth = max.z - min.z;
//                  NSLog(@"Model BoundingBox: Min: (%f, %f, %f), Max: (%f, %f, %f)", min.x, min.y, min.z, max.x, max.y, max.z);
//                  NSLog(@"Model Size: Width: %f, Height: %f, Depth: %f", width, height, depth);


    
              // 自定义材质
                  SCNMaterial *material = [SCNMaterial material];
                  NSLog(@"----Mat_Robot_Base_Color_Mixed===%@",[UIImage imageNamed:@"Mat_Robot_Base_Color_Mixed"]);
                  material.diffuse.contents = [UIImage imageNamed:@"Mat_Robot_Base_Color_Mixed"]; // 使用图片纹理
//                  material.specular.contents = [UIColor whiteColor]; // 高光颜色
//                  material.emission.contents = [UIImage imageNamed:@"Mat_Robot_Base_Color_Mixed"]; // 自发光
                //  material.transparency = 0.5; // 半透明效果
                  geometry.materials = @[material];

                  
                  // 调整模型比例（缩放至合适大小）
                  scene.rootNode.scale = SCNVector3Make(0.7, 0.7, 0.7);
                  // 调整模型位置（确保模型位于屏幕中央）
                  modelNode.position = SCNVector3Make(0,-3.8, 0);

                  
//                  // 获取几何体的边界框
//                  SCNVector3 min1, max1;
//                  [geometry getBoundingBoxMin:&min1 max:&max1];
//
//                  // 打印模型的边界框尺寸
//                  float width1 = max1.x - min1.x;
//                  float height1 = max1.y - min1.y;
//                  float depth1 = max1.z - min1.z;
//                  NSLog(@"1Model BoundingBox: Min: (%f, %f, %f), Max: (%f, %f, %f)", min1.x, min1.y, min1.z, max1.x, max1.y, max1.z);
//                  NSLog(@"1Model Size: Width: %f, Height: %f, Depth: %f", width1, height1, depth1);
                  
                  [scene.rootNode addChildNode:modelNode];
                  
              });
          } else {
              NSLog(@"Failed to generate geometry from loaded model.");
          }
      });
      
      // 添加光源
    //  [self addLightsToScene:scene];
      
      // 添加相机
     // [self addCameraToScene:scene];
    
}

// 添加光源
- (void)addLightsToScene:(SCNScene *)scene {
    // 环境光
    SCNLight *ambientLight = [SCNLight light];
    ambientLight.type = SCNLightTypeAmbient;
    ambientLight.color = [UIColor colorWithWhite:0.3 alpha:1.0];
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = ambientLight;
    [scene.rootNode addChildNode:ambientLightNode];
    
    // 主方向光
    SCNLight *mainLight = [SCNLight light];
    mainLight.type = SCNLightTypeDirectional;
    mainLight.color = [UIColor whiteColor];
    SCNNode *mainLightNode = [SCNNode node];
    mainLightNode.light = mainLight;
    mainLightNode.eulerAngles = SCNVector3Make(-M_PI / 3, M_PI / 4, 0); // 设置方向
    [scene.rootNode addChildNode:mainLightNode];
}

- (void)addCameraToScene:(SCNScene *)scene {
    SCNCamera *camera = [SCNCamera camera];
    camera.fieldOfView = 60; // 设置视野
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = camera;
    
    // 设置相机位置，使其能看到模型
    cameraNode.position = SCNVector3Make(0, 5, 15);

    // 创建 LookAt 约束，确保相机始终看向场景的根节点
    SCNLookAtConstraint *lookAtConstraint = [SCNLookAtConstraint lookAtConstraintWithTarget:scene.rootNode];
    lookAtConstraint.gimbalLockEnabled = YES; // 避免旋转过多
    cameraNode.constraints = @[lookAtConstraint];

    [scene.rootNode addChildNode:cameraNode];
}



@end
