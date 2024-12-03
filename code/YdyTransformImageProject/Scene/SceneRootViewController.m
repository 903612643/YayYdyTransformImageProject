//
//  StereoSpaceViewController.m
//  YdyTransformImageProject
//
//  Created by LaserPecker-iOS on 2024/11/26.
//

//#import "SceneRootViewController.h"
//#import <SceneKit/SceneKit.h>
//#import "assimpLoader.h"
//#import "testCpp.cpp"
//
//#ifdef __cplusplus
//extern "C" {
//#endif
//
//#include "testCpp.hpp"
//
//#ifdef __cplusplus
//}
//#endif
//
//@interface SceneRootViewController ()
//
//@property (nonatomic, assign) GLfloat rotationAngle;
//
//@end
//
//@implementation SceneRootViewController
//
//- (void)viewDidLoad {
//    [super viewDidLoad];
//    
//    // 创建一个 SCNView
//      SCNView *sceneView = [[SCNView alloc] initWithFrame:self.view.bounds];
//      sceneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//      [self.view addSubview:sceneView];
//      
//      // 创建一个空场景
//      SCNScene *scene = [SCNScene scene];
//      sceneView.scene = scene;
//      // 启用用户交互控制相机
//      sceneView.allowsCameraControl = YES;
//      sceneView.autoenablesDefaultLighting = YES;
//      // 设置背景颜色
//      sceneView.backgroundColor = [UIColor blackColor];
//      // 创建 assimpLoader 实例
//      assimpLoader *loader = [[assimpLoader alloc] init];
//      // 模型文件路径
//      NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Car" ofType:@"fbx"];
//      // 异步加载模型
//      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//          [loader loadOBJModelWithPath:filePath];
//          // 生成几何体
//          geometryFromLoader *geometryLoader = [[geometryFromLoader alloc] init];
//          SCNGeometry *geometry = [geometryLoader geometryFromLoader:loader vertexMaxHBlock:^(float h) {
//          }];
//          // 模型加载完成后更新场景
//          if (geometry) {
//              dispatch_async(dispatch_get_main_queue(), ^{
//                  // 创建模型节点
//                  SCNNode *modelNode = [SCNNode nodeWithGeometry:geometry];
//              // 自定义材质
//                  SCNMaterial *material = [SCNMaterial material];
//                  NSLog(@"----Mat_Robot_Base_Color_Mixed===%@",[UIImage imageNamed:@"Mat_Robot_Base_Color_Mixed"]);
//                  material.diffuse.contents = [UIImage imageNamed:@"Mat_Robot_Base_Color_Mixed"]; // 使用图片纹理
////                  material.specular.contents = [UIColor whiteColor]; // 高光颜色
////                  material.emission.contents = [UIImage imageNamed:@"Mat_Robot_Base_Color_Mixed"]; // 自发光
//                //  material.transparency = 0.5; // 半透明效果
//                  geometry.materials = @[material];
//                  // 调整模型比例（缩放至合适大小）
//                  scene.rootNode.scale = SCNVector3Make(0.7, 0.7, 0.7);
//                  // 调整模型位置（确保模型位于屏幕中央）
//                  modelNode.position = SCNVector3Make(0,-3.8, 0);
//                  [scene.rootNode addChildNode:modelNode];
//              });
//          } else {
//              NSLog(@"Failed to generate geometry from loaded model.");
//          }
//      });
//      
//      // 添加光源
//    //  [self addLightsToScene:scene];
//      // 添加相机
//     // [self addCameraToScene:scene];
//    
//}
//
//// 添加光源
//- (void)addLightsToScene:(SCNScene *)scene {
//    // 环境光
//    SCNLight *ambientLight = [SCNLight light];
//    ambientLight.type = SCNLightTypeAmbient;
//    ambientLight.color = [UIColor colorWithWhite:0.3 alpha:1.0];
//    SCNNode *ambientLightNode = [SCNNode node];
//    ambientLightNode.light = ambientLight;
//    [scene.rootNode addChildNode:ambientLightNode];
//    
//    // 主方向光
//    SCNLight *mainLight = [SCNLight light];
//    mainLight.type = SCNLightTypeDirectional;
//    mainLight.color = [UIColor whiteColor];
//    SCNNode *mainLightNode = [SCNNode node];
//    mainLightNode.light = mainLight;
//    mainLightNode.eulerAngles = SCNVector3Make(-M_PI / 3, M_PI / 4, 0); // 设置方向
//    [scene.rootNode addChildNode:mainLightNode];
//}
//
//- (void)addCameraToScene:(SCNScene *)scene {
//    SCNCamera *camera = [SCNCamera camera];
//    camera.fieldOfView = 60; // 设置视野
//    SCNNode *cameraNode = [SCNNode node];
//    cameraNode.camera = camera;
//    
//    // 设置相机位置，使其能看到模型
//    cameraNode.position = SCNVector3Make(0, 5, 15);
//
//    // 创建 LookAt 约束，确保相机始终看向场景的根节点
//    SCNLookAtConstraint *lookAtConstraint = [SCNLookAtConstraint lookAtConstraintWithTarget:scene.rootNode];
//    lookAtConstraint.gimbalLockEnabled = YES; // 避免旋转过多
//    cameraNode.constraints = @[lookAtConstraint];
//
//    [scene.rootNode addChildNode:cameraNode];
//}
//
//
//
//@end




#import "SceneRootViewController.h"
#import <SceneKit/SceneKit.h>
#import "assimpLoader.h"


@interface SceneRootViewController ()

@property (nonatomic, assign) GLfloat rotationAngle;

@end

@implementation SceneRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 创建一个SCNView，场景将显示在这个视图中
    SCNView *sceneView = [[SCNView alloc] initWithFrame:self.view.bounds];
    sceneView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:sceneView];
    
    // 创建一个空的场景
    SCNScene *scene = [SCNScene scene];
    sceneView.scene = scene;
    

    // 创建外部立方体（大的立方体）
    SCNBox *outerBox = [SCNBox boxWithWidth:2 height:2 length:2 chamferRadius:0];

    // 创建材质，并为外部立方体赋予颜色（例如蓝色）
    SCNMaterial *outerMaterial = [SCNMaterial material];
    outerMaterial.diffuse.contents = [[UIColor blueColor] colorWithAlphaComponent:0.1]; // 设置外部立方体的颜色为蓝色
    outerBox.firstMaterial = outerMaterial;  // 将材质应用到外部立方体

    // 创建一个节点，将外部立方体几何体添加到节点上
    SCNNode *outerBoxNode = [SCNNode nodeWithGeometry:outerBox];
    outerBoxNode.position = SCNVector3Make(0, 0, 0); // 将外部立方体放置在场景的中心
    // 将外部立方体节点添加到场景的根节点上
    [scene.rootNode addChildNode:outerBoxNode];
    
   //  添加每个面的数字标签
  //  [self addFaceLabelsToNode:outerBoxNode];
    
    // 创建内部立方体（红色立方体）
    SCNBox *innerBox = [SCNBox boxWithWidth:0.5 height:0.5 length:0.5 chamferRadius:0];

    // 创建材质，并为内部立方体赋予颜色（例如红色）
    SCNMaterial *innerMaterial = [SCNMaterial material];
    innerMaterial.diffuse.contents = [UIColor clearColor]; // 设置透明度为0.8，使其半透明
    innerBox.firstMaterial = innerMaterial;  // 将材质应用到内部立方体

    // 创建一个节点，将内部立方体几何体添加到节点上
    SCNNode *innerBoxNode = [SCNNode nodeWithGeometry:innerBox];
    innerBoxNode.position = SCNVector3Make(0.5, 0, 0); // 将内部立方体放置在外部立方体的中心

    // 将内部立方体节点添加到外部立方体的节点下，实现嵌套效果
 //   [outerBoxNode addChildNode:innerBoxNode];
    
    // 创建一个相机节点
    SCNCamera *camera = [SCNCamera camera];
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = camera;
    
    // 设置相机的位置，使其能够看到三个立方体
    cameraNode.position = SCNVector3Make(0, 0, 6); // 相机位置略高且稍远，能看到立方体
    [cameraNode lookAt:outerBoxNode.position]; // 使相机朝向外部立方体
    
    // 将相机节点添加到场景中
    [scene.rootNode addChildNode:cameraNode];
    
    // 启用相机控制，允许用户交互
    sceneView.allowsCameraControl = YES;
    
    // 设置背景颜色
    sceneView.backgroundColor = [UIColor blackColor];
    
    // 添加立方体的边线
    [self addLinesToBox:outerBoxNode];

    // 添加立方体的边线
    [self addLinesToBox:innerBoxNode];

      // 创建 assimpLoader 实例
      assimpLoader *loader = [[assimpLoader alloc] init];
      // 模型文件路径
      NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Car" ofType:@"fbx"];
    
          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
              [loader loadOBJModelWithPath:filePath];
              // 生成几何体
              geometryFromLoader *geometryLoader = [[geometryFromLoader alloc] init];
              __block float vertexMaxH = 0;
              SCNGeometry *geometry = [geometryLoader geometryFromLoader:loader vertexMaxHBlock:^(float h) {
                  vertexMaxH = h;
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
                      modelNode.scale = SCNVector3Make(0.1, 0.1, 0.1);
                      // 调整模型位置（确保模型位于屏幕中央）
                      modelNode.position = SCNVector3Make(0,-vertexMaxH/2,0);
                      [outerBoxNode addChildNode:modelNode];
                      
                    // 为立方体添加自转动画
                    SCNAction *rotation = [SCNAction repeatActionForever:[SCNAction rotateByX:0 y:M_PI*2 z:0 duration:10]];
                    [outerBoxNode runAction:rotation];
                  //  [innerBoxNode runAction:rotation];
  //                  //呼吸效果
  //                  SCNAction *scaleUp = [SCNAction scaleTo:2.0 duration:1.0];
  //                  SCNAction *scaleDown = [SCNAction scaleTo:0.5 duration:1.0];
  //                  SCNAction *pulse = [SCNAction repeatActionForever:[SCNAction sequence:@[scaleUp, scaleDown]]];
  //                  [innerBoxNode runAction:pulse];
  //
  //                  //移动位置
  //                  SCNAction *move = [SCNAction moveBy:SCNVector3Make(0.5, 0.5, 0) duration:2];
  //                  SCNAction *reverseMove = [move reversedAction];
  //                  SCNAction *moveSequence = [SCNAction sequence:@[move, reverseMove]];
  //                  SCNAction *moveLoop = [SCNAction repeatActionForever:moveSequence];
  //                  [innerBoxNode runAction:moveLoop];
                  });
              } else {
                  NSLog(@"Failed to generate geometry from loaded model.");
              }
          });
    
    
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


// 添加每个面的数字标签，确保文本放在每个面的中心
- (void)addFaceLabelsToNode:(SCNNode *)node {
    NSArray *positions = @[
        [NSValue valueWithSCNVector3:SCNVector3Make(1, -1, 0)], // 右面
        [NSValue valueWithSCNVector3:SCNVector3Make(-1, -1, 0)], // 左面
        [NSValue valueWithSCNVector3:SCNVector3Make(0, 1, 1)], // 上面
        [NSValue valueWithSCNVector3:SCNVector3Make(0, -1, -1)], // 下面
        [NSValue valueWithSCNVector3:SCNVector3Make(0, -1, 1)], // 前面
        [NSValue valueWithSCNVector3:SCNVector3Make(0, 1, -1)] // 后面
    ];
    
    NSArray *labels = @[@"1", @"2", @"3", @"4", @"5", @"6"];
    
    for (int i = 0; i < 6; i++) {
        SCNText *text = [SCNText textWithString:labels[i] extrusionDepth:0.1];
        text.font = [UIFont systemFontOfSize:0.3]; // 设置字体大小
        text.flatness = 0.1;
        
        // 创建一个节点来显示文本
        SCNNode *textNode = [SCNNode nodeWithGeometry:text];
        
        // 设置文本节点的位置，使文本放置在面中心
        textNode.position = [positions[i] SCNVector3Value];
        
        // 确保文本朝向正确，文字朝外
        if (i == 0) {
            textNode.eulerAngles = SCNVector3Make(0, M_PI_2, 0);  // 右面
        } else if (i == 1) {
            textNode.eulerAngles = SCNVector3Make(0, -M_PI_2, 0); // 左面
        } else if (i == 2) {
            textNode.eulerAngles = SCNVector3Make(-M_PI_2, 0, 0); // 上面
        } else if (i == 3) {
            textNode.eulerAngles = SCNVector3Make(M_PI_2, 0, 0);  // 下面
        } else if (i == 4) {
            textNode.eulerAngles = SCNVector3Make(0, 0, 0);       // 前面
        } else if (i == 5) {
            textNode.eulerAngles = SCNVector3Make(M_PI, 0, 0);    // 后面
        }
        
        // 将文本节点添加到立方体节点
        [node addChildNode:textNode];
    }
}

// SCNVector3相减的帮助方法
SCNVector3 SCNVector3Subtract(SCNVector3 vector1, SCNVector3 vector2) {
    return SCNVector3Make(vector1.x - vector2.x, vector1.y - vector2.y, vector1.z - vector2.z);
}


// 计算立方体的边线并添加到场景中
- (void)addLinesToBox:(SCNNode *)boxNode {
    // 获取立方体的几何体
    SCNBox *boxGeometry = (SCNBox *)boxNode.geometry;
    
    // 计算立方体的8个顶点
    float width = boxGeometry.width;
    float height = boxGeometry.height;
    float length = boxGeometry.length;
    
    NSLog(@"-------height==%f",height);
    
    // 顶点相对坐标（中心点为原点）
    SCNVector3 vertices[8] = {
        SCNVector3Make(-width / 2, -height / 2, -length / 2),  // 0
        SCNVector3Make(width / 2, -height / 2, -length / 2),   // 1
        SCNVector3Make(width / 2, -height / 2, length / 2),    // 2
        SCNVector3Make(-width / 2, -height / 2, length / 2),   // 3
        SCNVector3Make(-width / 2, height / 2, -length / 2),   // 4
        SCNVector3Make(width / 2, height / 2, -length / 2),    // 5
        SCNVector3Make(width / 2, height / 2, length / 2),     // 6
        SCNVector3Make(-width / 2, height / 2, length / 2)     // 7
    };
    
    // 定义连接顶点的线段
    int edges[12][2] = {
        {0, 1}, {1, 2}, {2, 3}, {3, 0},   // 底面
        {4, 5}, {5, 6}, {6, 7}, {7, 4},   // 顶面
        {0, 4}, {1, 5}, {2, 6}, {3, 7}    // 连接底面和顶面的边
    };
    
    // 为每条边创建一条黑色线
    for (int i = 0; i < 12; i++) {
        int startIndex = edges[i][0];
        int endIndex = edges[i][1];
        
        SCNVector3 startVertex = vertices[startIndex];
        SCNVector3 endVertex = vertices[endIndex];
        
        [self drawLineFrom:startVertex to:endVertex inNode:boxNode];
    }
}

// 画一条从 start 到 end 的线
- (void)drawLineFrom:(SCNVector3)start to:(SCNVector3)end inNode:(SCNNode *)parentNode {
    // 计算两点之间的距离
    float distance = sqrtf(powf(end.x - start.x, 2) + powf(end.y - start.y, 2) + powf(end.z - start.z, 2));
    
    NSLog(@"----------distance====%f",distance);
    
    // 创建一条圆柱体作为线段
    SCNCylinder *line = [SCNCylinder cylinderWithRadius:0.005 height:distance];
    line.firstMaterial.diffuse.contents = [[UIColor blueColor] colorWithAlphaComponent:1.0];  // 设置线段颜色为黑色
    
    // 创建一个节点，将线段几何体添加到节点上
    SCNNode *lineNode = [SCNNode nodeWithGeometry:line];
    
    // 设置线段的位置为两点的中点
    SCNVector3 midPoint = SCNVector3Make((start.x + end.x) / 2, (start.y + end.y) / 2, (start.z + end.z) / 2);
    lineNode.position = midPoint;
    
    // 计算旋转角度，使线段指向正确的方向
    SCNVector3 direction = SCNVector3Make(end.x - start.x, end.y - start.y, end.z - start.z);
    SCNVector3 up = SCNVector3Make(0, 1, 0);  // 假设Z轴是线的方向
    SCNVector3 axis = SCNVector3Cross(up, direction);
    float angle = acosf(SCNVector3Dot(up, direction) / (SCNVector3Length(up) * SCNVector3Length(direction)));
    
    lineNode.rotation = SCNVector4Make(axis.x, axis.y, axis.z, angle);  // 设置旋转
    
    // 将线段节点添加到父节点（即立方体节点）下
    [parentNode addChildNode:lineNode];
}

// 叉积计算
SCNVector3 SCNVector3Cross(SCNVector3 v1, SCNVector3 v2) {
    return SCNVector3Make(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x
    );
}

// 计算向量的点积
float SCNVector3Dot(SCNVector3 v1, SCNVector3 v2) {
    return v1.x * v2.x + v1.y * v2.y + v1.z * v2.z;
}

// 计算向量的长度
float SCNVector3Length(SCNVector3 v) {
    return sqrtf(v.x * v.x + v.y * v.y + v.z * v.z);
}



@end
