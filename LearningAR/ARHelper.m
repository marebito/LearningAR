//
//  ARHelper.m
//  LearningAR
//
//  Created by Yuri Boyka on 2018/2/25.
//  Copyright © 2018年 Godlike Studio. All rights reserved.
//

#import "ARHelper.h"
#import <objc/message.h>
#import <objc/runtime.h>

#define __FILENAME__(filePath) [filePath lastPathComponent]
#define __FILEEXT__(filePath) [filePath pathExtension]
#define __FILENAMEWITHOUTEXT__(filePath) [filePath stringByDeletingPathExtension]
#define __VALIDSUFFIX__(filePath, suffix) [__FILENAME__(filePath) hasSuffix:suffix]

/**
 手势类型

 - GestureTypeSingleTap: 单击手势
 - GestureTypeDoubleTap: 双击手势
 - GestureTypePan: 拖拽手势
 - GestureTypePinch: 缩放收拾
 */
typedef NS_ENUM(NSUInteger, GestureType) {
    GestureTypeSingleTap,
    GestureTypeDoubleTap,
    GestureTypePan,
    GestureTypePinch
};

/**
 手势目标Key
 */
static const int gesture_target_key;

@interface UIGestureRecognizer (ActionBlock)

+ (instancetype)gestureRecongnizerWithActionBlock:(GestureBlock)block;

- (instancetype)initWithActionBlock:(GestureBlock)block;

- (void)addActionBlock:(GestureBlock)block;

- (GestureBlock)gestureBlock;

@end

@implementation UIGestureRecognizer (ActionBlock)

+ (instancetype)gestureRecongnizerWithActionBlock:(GestureBlock)block
{
    return [[self alloc] initWithActionBlock:block];
}

- (instancetype)initWithActionBlock:(GestureBlock)block
{
    self = [self init];
    [self addActionBlock:block];
    [self addTarget:self action:@selector(invoke:)];
    return self;
}

- (void)addActionBlock:(GestureBlock)block
{
    if (block)
    {
        objc_setAssociatedObject(self, &gesture_target_key, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
}

- (GestureBlock)gestureBlock { return objc_getAssociatedObject(self, &gesture_target_key); }
- (void)invoke:(id)sender
{
    GestureBlock block = [self gestureBlock];
    if (block)
    {
        block(sender);
    }
}

@end

@implementation UIView (GestureHandle)

- (UIGestureRecognizer *)findGesture:(GestureType)type
{
    UIGestureRecognizer *gesture = nil;
    for (UIGestureRecognizer *tmpGesture in self.gestureRecognizers)
    {
        switch (type)
        {
            case GestureTypeSingleTap:
            {
                if ([tmpGesture isKindOfClass:[UITapGestureRecognizer class]])
                {
                    if (tmpGesture.numberOfTouches == 1)
                    {
                        gesture = tmpGesture;
                        break;
                    }
                }
            }
            break;
            case GestureTypeDoubleTap:
            {
                if ([tmpGesture isKindOfClass:[UITapGestureRecognizer class]])
                {
                    if (tmpGesture.numberOfTouches == 2)
                    {
                        gesture = tmpGesture;
                        break;
                    }
                }
            }
            break;
            case GestureTypePan:
            {
                if ([tmpGesture isKindOfClass:[UIPanGestureRecognizer class]])
                {
                    gesture = tmpGesture;
                    break;
                }
            }
            break;
            case GestureTypePinch:
            {
                if ([tmpGesture isKindOfClass:[UIPinchGestureRecognizer class]])
                {
                    gesture = tmpGesture;
                    break;
                }
            }
            break;
            default:
                break;
        }
    }
    return gesture;
}

- (void)singleTapWithHandler:(GestureBlock)handler;
{
    UITapGestureRecognizer *singleTapGesture = (UITapGestureRecognizer *)[self findGesture:GestureTypeSingleTap];
    if (singleTapGesture)
    {
        handler = [singleTapGesture gestureBlock];
    }
    else
    {
        singleTapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:handler];
        [self addGestureRecognizer:singleTapGesture];
    }
}

- (void)doubleTapWithhandler:(GestureBlock)handler;
{
    UITapGestureRecognizer *doubleTapGesture = (UITapGestureRecognizer *)[self findGesture:GestureTypeDoubleTap];
    if (doubleTapGesture)
    {
        handler = [doubleTapGesture gestureBlock];
    }
    else
    {
        doubleTapGesture = [[UITapGestureRecognizer alloc] initWithActionBlock:handler];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTapGesture];
    }
}

- (void)panWithHandler:(GestureBlock)handler;
{
    UIPanGestureRecognizer *panGesture = (UIPanGestureRecognizer *)[self findGesture:GestureTypeDoubleTap];
    if (panGesture)
    {
        handler = [panGesture gestureBlock];
    }
    else
    {
        panGesture = [[UIPanGestureRecognizer alloc] initWithActionBlock:handler];
        [self addGestureRecognizer:panGesture];
    }
}

- (void)pinchWithHandler:(GestureBlock)handler
{
    UIPinchGestureRecognizer *pinchGesture = (UIPinchGestureRecognizer *)[self findGesture:GestureTypePinch];
    if (pinchGesture)
    {
        handler = [pinchGesture gestureBlock];
    }
    else
    {
        pinchGesture = [[UIPinchGestureRecognizer alloc] initWithActionBlock:handler];
        [self addGestureRecognizer:pinchGesture];
    }
}

@end

@interface ARHelper ()<ARSCNViewDelegate, ARSKViewDelegate, ARSessionDelegate>
{
    ARConfiguration *_configuration;
    ARSession *_arSession;
    dispatch_queue_t _arSessionQueue;
}
@end

@implementation ARHelper

static ARHelper *arHelper;

+ (instancetype)helper
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        arHelper = [[ARHelper alloc] init];
    });
    return arHelper;
}

- (instancetype)init
{
    if (arHelper) return arHelper;
    if (nil != (self = [super init]))
    {
        _arSessionQueue = dispatch_queue_create("com.godlike.arsession", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

#pragma mark - 创建AR视图
- (UIView *)createARSViewWithFrame:(CGRect)frame style:(ARStyle)style
{
    UIView *view = nil;
    switch (style)
    {
        case ARStyle2D:
        {
            ARSKView *skView = [[ARSKView alloc] initWithFrame:frame];
            skView.delegate = self;
            skView.session = [self createARSession];
            skView.showsFPS = SHOW_FPS;
            view = skView;
        }
        break;
        case ARStyle3D:
        {
            ARSCNView *scnView = [[ARSCNView alloc] initWithFrame:frame];
            scnView.delegate = self;
            scnView.session = [self createARSession];
            scnView.showsStatistics = SHOW_FPS;
            view = scnView;
        }
        break;
        default:
            break;
    }
    return view;
}

- (void)bindAction:(GestureBlock)singleTap
         doubleTap:(GestureBlock)doubleTap
               pan:(GestureBlock)pan
             pinch:(GestureBlock)pinch
            target:(UIView *)target
{
    if (singleTap)
    {
        [target singleTapWithHandler:singleTap];
    }
    if (doubleTap)
    {
        [target doubleTapWithhandler:doubleTap];
    }
    if (pan)
    {
        [target panWithHandler:pan];
    }
    if (pinch)
    {
        [target pinchWithHandler:pinch];
    }
}

- (ARSession *)createARSession
{
    if (!_arSession)
    {
        ARSession *arSession = [[ARSession alloc] init];
        arSession.delegate = self;
        arSession.delegateQueue = _arSessionQueue;
        _arSession = arSession;
    }
    return _arSession;
}

#pragma mark - 启动AR

- (void)launchARSession:(id)arView configuration:(ARConfiguration *)configuration style:(ARStyle)style
{
    switch (style)
    {
        case ARStyle2D:
            [((ARSKView *)arView)
                    .session
                runWithConfiguration:configuration
                             options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
            break;
        case ARStyle3D:
            [((ARSCNView *)arView)
                    .session
                runWithConfiguration:configuration
                             options:ARSessionRunOptionResetTracking | ARSessionRunOptionRemoveExistingAnchors];
        default:
            break;
    }
}

- (void)launchARSession:(id)arView
          configuration:(ARConfiguration *)configuration
                options:(ARSessionRunOptions)options
                  style:(ARStyle)style
{
    switch (style)
    {
        case ARStyle2D:
            [((ARSKView *)arView).session runWithConfiguration:configuration options:options];
            break;
        case ARStyle3D:
            [((ARSCNView *)arView).session runWithConfiguration:configuration options:options];
        default:
            break;
    }
}

- (void)startARSession:(id)arView style:(ARStyle)style
{
    [self startARSession:arView
        configurationTrack:ARConfigurationTrackWorld
            planeDetection:ARPlaneDetectionHorizontal
          coordinateSystem:ARCoordinateSystemDevice
         providesAudioData:NO
                     style:style];
}

- (void)startARSession:(id)arView
    configurationTrack:(ARConfigurationTrack)configurationTrack
        planeDetection:(ARPlaneDetection)planeDetection
      coordinateSystem:(ARCoordinateSystem)coordinateSystem
     providesAudioData:(BOOL)providesAudioData
                 style:(ARStyle)style
{
    if (!ARConfiguration.isSupported)
    {
        NSLog(@"设备不支持AR，请确保设备(iPhone[SE/6s]以上)使用A9及以上才可以使用");
        return;
    }
    if (!_configuration)
    {
        switch (configurationTrack)
        {
            case ARConfigurationTrackWorld:
            {
                // 创建设备追踪设置（设备处理器A9以上）
                ARWorldTrackingConfiguration *arSessionConfiguration = [[ARWorldTrackingConfiguration alloc] init];
                // 设置自适应灯光
                arSessionConfiguration.lightEstimationEnabled = YES;
                switch (coordinateSystem)
                {
                    case ARCoordinateSystemDevice:
                        arSessionConfiguration.worldAlignment = ARWorldAlignmentGravity;
                        break;
                    case ARCoordinateSystemCamera:
                        arSessionConfiguration.worldAlignment = ARWorldAlignmentGravityAndHeading;
                        break;
                    case ARCoordinateSystemCompass:
                        arSessionConfiguration.worldAlignment = ARWorldAlignmentCamera;
                        break;
                    default:
                        break;
                }
                arSessionConfiguration.planeDetection = planeDetection;
                _configuration = arSessionConfiguration;
            }
            break;
            case ARConfigurationTrackOrientation:
            {
                AROrientationTrackingConfiguration *arSessionConfiguration =
                    [[AROrientationTrackingConfiguration alloc] init];
                _configuration = arSessionConfiguration;
            }
            break;
            case ARConfigurationTracFace:
            {
                ARFaceTrackingConfiguration *arSessionConfiguration = [[ARFaceTrackingConfiguration alloc] init];
                _configuration = arSessionConfiguration;
            }
            break;
            default:
                break;
        }
    }
    _configuration.providesAudioData = providesAudioData;
    // 启动AR
    [self launchARSession:arView configuration:_configuration style:style];
}

- (void)pauseARSession:(id)arView style:(ARStyle)style
{
    ARSession *session = nil;
    switch (style)
    {
        case ARStyle2D:
        {
            session = ((ARSKView *)arView).session;
        }
        break;
        case ARStyle3D:
        {
            session = ((ARSCNView *)arView).session;
        }
        break;
        default:
            break;
    }
}

#pragma mark - 添加子节点

- (void)addChildNode:(id)node target:(id)view style:(ARStyle)style
{
    switch (style)
    {
        case ARStyle2D:
        {
            [((ARSKView *)view).session addAnchor:(ARAnchor *)node];
        }
        break;
        case ARStyle3D:
        {
            [((ARSCNView *)view).scene.rootNode addChildNode:(SCNNode *)node];
        }
        break;
        default:
            break;
    }
}

#pragma mark - AR视图呈现场景

- (void)presentScene:(id)scene target:(id)arView style:(ARStyle)style
{
    switch (style)
    {
        case ARStyle2D:
            [(ARSKView *)arView presentScene:scene];
            break;
        case ARStyle3D:
            ((ARSCNView *)arView).scene = scene;
            break;
        default:
            break;
    }
}

#pragma mark - 变换视角

- (ARAnchor *)anchorWithTransform:(matrix_float4x4)transform view:(id)view style:(ARStyle)style
{
    matrix_float4x4 cameraTransform;
    switch (style)
    {
        case ARStyle2D:
            cameraTransform = ((ARSKView *)view).session.currentFrame.camera.transform;
            break;
        case ARStyle3D:
            cameraTransform = ((ARSCNView *)view).session.currentFrame.camera.transform;
            break;
        default:
            break;
    }
    return [[ARAnchor alloc] initWithTransform:(simd_mul(cameraTransform, transform))];
}

#pragma mark - 3D生成SCNScene, 2D生成SKScene
- (id)sceneWithFile:(NSString *)file
{
    id scene = nil;
    if (__VALIDSUFFIX__(file, @"sks"))
    {
        scene = [self sceneWithFile:file style:ARStyle2D];
    }
    else if (__VALIDSUFFIX__(file, @"scn") || __VALIDSUFFIX__(file, @"dae"))
    {
        scene = [self sceneWithFile:file style:ARStyle3D];
    }
    else
    {
        NSLog(@"[请检查模型文件类型, 3D支持格式为scn, dae， 2D支持格式为sks]");
    }
    return scene;
}

- (id)sceneWithFile:(NSString *)file style:(ARStyle)style
{
    return [self sceneWithFile:file
                         style:style
                    fromServer:NO
                     cameraPos:SCNVector3Make(0, 0, 15)
                      lightPos:SCNVector3Make(0, 0, 10)];
}

- (id)sceneWithFile:(NSString *)file
              style:(ARStyle)style
         fromServer:(BOOL)fromServer
          cameraPos:(SCNVector3)cameraPos
           lightPos:(SCNVector3)lightPos
{
    id scene = nil;
    switch (style)
    {
        case ARStyle2D:
        {
            NSLog(@"[2D模型文件]: %@.sks", __FILENAMEWITHOUTEXT__(file));
            scene = [SKScene nodeWithFileNamed:__FILENAMEWITHOUTEXT__(file)];
        }
        break;
        case ARStyle3D:
        {
            if (fromServer)
            {
                // 加载下载的场景
                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory
                                                                                      inDomain:NSUserDomainMask
                                                                             appropriateForURL:nil
                                                                                        create:NO
                                                                                         error:nil];
                documentsDirectoryURL = [documentsDirectoryURL
                    URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.scnassets/%@", ARASSETS_OPTIMIZE_NAME,
                                                                           __FILENAME__(file)]];

                SCNSceneSource *sceneSource = [SCNSceneSource sceneSourceWithURL:documentsDirectoryURL options:nil];

                // 获取三维模型节点
                SCNNode *theNode =
                    [sceneSource entryWithIdentifier:__FILENAMEWITHOUTEXT__(file) withClass:[SCNNode class]];

                // 创建一个新场景
                SCNScene *scene = [SCNScene scene];

                // 创建并添加一个相机到场景中
                SCNNode *cameraNode = [SCNNode node];
                cameraNode.camera = [SCNCamera camera];
                [scene.rootNode addChildNode:cameraNode];

                // 设置相机的位置
                cameraNode.position = cameraPos;

                // 创建并添加一个光照到场景
                SCNNode *lightNode = [SCNNode node];
                lightNode.light = [SCNLight light];
                lightNode.light.type = SCNLightTypeOmni;
                lightNode.position = lightPos;
                [scene.rootNode addChildNode:lightNode];

                // 创建并添加一个环境光到场景
                SCNNode *ambientLightNode = [SCNNode node];
                ambientLightNode.light = [SCNLight light];
                ambientLightNode.light.type = SCNLightTypeAmbient;
                ambientLightNode.light.color = [UIColor darkGrayColor];
                [scene.rootNode addChildNode:ambientLightNode];

                // 添加3D节点到场景
                [scene.rootNode addChildNode:theNode];
            }
            else
            {
                //                art.scnassets/ship.scn
                NSLog(@"[3D模型文件]: %@",
                      [NSString stringWithFormat:@"%@.scnassets/%@", ARASSETS_NAME, __FILENAME__(file)]);
                scene = [SCNScene
                    sceneNamed:[NSString stringWithFormat:@"%@.scnassets/%@", ARASSETS_NAME, __FILENAME__(file)]];
            }
        }
        break;
        default:
        {
            NSLog(@"[模型文件出错]:%@", file);
        }
        break;
    }
    return scene;
}

#pragma mark - 获取场景摄像机
- (id)getSceneCamera:(id)scene style:(ARStyle)style
{
    id camera = nil;
    switch (style)
    {
        case ARStyle2D:
            camera = ((SKScene *)scene).camera;
            break;
        case ARStyle3D:
            camera = (SKCameraNode *)[((SCNScene *)scene).rootNode childNodeWithName:@"origin_camera" recursively:YES];
            break;
        default:
            break;
    }
    return camera;
}

#pragma mark - 当前帧摄像机
- (ARCamera *)getCurrentFrameCamera:(id)view style:(ARStyle)style
{
    ARCamera *camera = nil;
    switch (style)
    {
        case ARStyle2D:
        {
            camera = ((ARSKView *)view).session.currentFrame.camera;
        }
        break;
        case ARStyle3D:
        {
            camera = ((ARSCNView *)view).session.currentFrame.camera;
        }
        break;
        default:
            break;
    }
    return camera;
}

#pragma mark - 根据贝塞尔曲线生成3D模型
- (SCNNode *)nodeWithBezierPath:(UIBezierPath *)bezierPath
{
    return [self nodeWithBezierPath:bezierPath
                     extrusionDepth:0.0
                        chamferMode:SCNChamferModeBoth
                      chamferRadius:0.0
                     chamferProfile:nil
                          materials:nil];
}

- (SCNNode *)nodeWithBezierPath:(UIBezierPath *)bezierPath
                 extrusionDepth:(CGFloat)extrusionDepth
                    chamferMode:(SCNChamferMode)chamferMode
                  chamferRadius:(CGFloat)chamferRadius
                 chamferProfile:(UIBezierPath *)chamferProfile
                      materials:(NSArray<SCNMaterial *> *)materials
{
    SCNShape *nodeShape = [SCNShape shapeWithPath:bezierPath extrusionDepth:extrusionDepth];
    nodeShape.chamferRadius = chamferRadius;
    nodeShape.chamferMode = chamferMode;
    nodeShape.chamferRadius = chamferRadius;
    nodeShape.chamferProfile = chamferProfile;
    nodeShape.materials = materials;
    return [SCNNode nodeWithGeometry:nodeShape];
}

- (SCNMaterial *)materialWithColor:(UIColor *)color
{
    return [self materialWithAmbient:[UIColor blackColor]
                        diffuseColor:[UIColor blackColor]
                       specularColor:[UIColor blackColor]
                       emissionColor:color];
}

- (SCNMaterial *)materialWithAmbient:(UIColor *)ambientColor
                        diffuseColor:(UIColor *)diffuseColor
                       specularColor:(UIColor *)specularColor
                       emissionColor:(UIColor *)emissionColor
{
    SCNMaterial *material = [SCNMaterial material];
    material.ambient.contents = ambientColor;
    material.diffuse.contents = diffuseColor;
    material.specular.contents = specularColor;
    material.emission.contents = emissionColor;
    return material;
}

- (SCNBox *)planeBoxWithWidth:(CGFloat)width height:(CGFloat)height length:(CGFloat)length chamferRadius:(CGFloat)radius
{
    return [SCNBox boxWithWidth:width height:height length:length chamferRadius:radius];
}

- (SCNPlane *)planeWithWidth:(CGFloat)width height:(CGFloat)height
{
    return [SCNPlane planeWithWidth:width height:height];
}

#pragma mark - 添加节点时候调用（当开启平面捕捉模式之后，如果捕捉到平面，ARKit会自动添加一个平面节点）
- (void)didAddNode:(ARAnchor *_Nonnull)anchor node:(id _Nonnull)node renderer:(id _Nonnull)renderer
{
    NSLog(@"[一个新的节点被映射到指定锚点上]");
    if ([anchor isKindOfClass:[ARPlaneAnchor class]])
    {
        NSLog(@"捕捉到平面");
        if (self.didAddNode)
        {
            self.didAddNode(renderer, node, anchor);
        }
    }
}

#pragma mark - ARSCNViewDelegate
- (nullable SCNNode *)renderer:(id<SCNSceneRenderer>)renderer nodeForAnchor:(ARAnchor *)anchor
{
    NSLog(@"[为指定锚点添加自定义视图]");
    // SKLabelNode
    if (self.nodeForAnchor)
    {
        return self.nodeForAnchor(renderer, anchor);
    }
    return nil;
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    [self didAddNode:anchor node:node renderer:renderer];
}

- (void)renderer:(id<SCNSceneRenderer>)renderer willUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"[2D节点已经被给定锚点的数据更新]");
    if (self.willUpdateNode)
    {
        self.willUpdateNode(renderer, node, anchor);
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"[2D节点将要用给定锚点的数据更新]");
    if (self.didUpdateNode)
    {
        self.didUpdateNode(renderer, node, anchor);
    }
}

- (void)renderer:(id<SCNSceneRenderer>)renderer didRemoveNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"[一个映射3D节点已经从给定锚点的场景图移除]");
    if (self.didRemoveNode)
    {
        self.didRemoveNode(renderer, node, anchor);
    }
}

#pragma mark - ARSKViewDelegate
- (nullable SKNode *)view:(ARSKView *)view nodeForAnchor:(ARAnchor *)anchor
{
    NSLog(@"[为指定锚点添加自定义视图]");
    // SKLabelNode
    if (self.nodeForAnchor)
    {
        return self.nodeForAnchor(view, anchor);
    }
    return nil;
}

- (void)view:(ARSKView *)view didAddNode:(SKNode *)node forAnchor:(ARAnchor *)anchor
{
    [self didAddNode:anchor node:node renderer:view];
}

- (void)view:(ARSKView *)view willUpdateNode:(SKNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"[2D节点已经被给定锚点的数据更新]");
    if (self.willUpdateNode)
    {
        self.willUpdateNode(view, node, anchor);
    }
}

- (void)view:(ARSKView *)view didUpdateNode:(SKNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"[2D节点将要用给定锚点的数据更新]");
    if (self.didUpdateNode)
    {
        self.didUpdateNode(view, node, anchor);
    }
}

- (void)view:(ARSKView *)view didRemoveNode:(SKNode *)node forAnchor:(ARAnchor *)anchor
{
    NSLog(@"[一个映射2D节点已经从给定锚点的场景图移除]");
    if (self.didRemoveNode)
    {
        self.didRemoveNode(view, node, anchor);
    }
}

#pragma mark - ARSessionDelegate
- (void)session:(ARSession *)session didUpdateFrame:(ARFrame *)frame
{
    NSLog(@"[新帧已经被更新]");
    if (self.sessionUpdateFrame)
    {
        self.sessionUpdateFrame(session, frame);
    }
}

- (void)session:(ARSession *)session didAddAnchors:(NSArray<ARAnchor *> *)anchors
{
    NSLog(@"[新的锚点被添加到会话]");
    if (self.sessionDidAddAnchors)
    {
        self.sessionDidAddAnchors(session, anchors);
    }
}

- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<ARAnchor *> *)anchors
{
    NSLog(@"[锚点更新]");
    if (self.sessionDidUpdateAnchors)
    {
        self.sessionDidUpdateAnchors(session, anchors);
    }
}

- (void)session:(ARSession *)session didRemoveAnchors:(NSArray<ARAnchor *> *)anchors
{
    NSLog(@"[锚点被从会话中移除]");
    if (self.sessionDidRemoveAnchors)
    {
        self.sessionDidRemoveAnchors(session, anchors);
    }
}

#pragma mark - ARSessionObserver
- (void)session:(ARSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"[建立会话失败]");
    if (error)
    {
        switch (error.code)
        {
            case ARErrorCodeUnsupportedConfiguration:
                NSLog(@"[会话配置当前设备不支持]");
                break;
            case ARErrorCodeSensorUnavailable:
                NSLog(@"[运行会话必要的传感器不可用]");
                break;
            case ARErrorCodeSensorFailed:
                NSLog(@"[传感器无法提供必要输入]");
                break;
            case ARErrorCodeWorldTrackingFailed:
                NSLog(@"[世界跟踪发生严重错误]");
                break;
            case ARErrorCodeCameraUnauthorized:
                NSLog(@"[用户拒绝你的应用使用设备相机权限]");
                break;
            default:
                NSLog(@"[发生未知错误]");
                break;
        }
    }
    if (self.didFailWithError)
    {
        self.didFailWithError(session, error);
    }
}

- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera
{
    NSLog(@"[相机跟踪状态发生改变]");
    if (self.cameraDidChangeTrackingState)
    {
        self.cameraDidChangeTrackingState(session, camera);
    }
}

- (void)sessionWasInterrupted:(ARSession *)session
{
    NSLog(@"[会话被中断]");
    if (self.wasInterrupted)
    {
        self.wasInterrupted(session, nil);
    }
}

- (void)sessionInterruptionEnded:(ARSession *)session
{
    NSLog(@"[会话被中断]");
    if (self.interruptionEnded)
    {
        self.interruptionEnded(session, nil);
    }
}

- (void)session:(ARSession *)session didOutputAudioSampleBuffer:(CMSampleBufferRef)audioSampleBuffer
{
    NSLog(@"[会话输出一个新的音频采样缓冲]");
    if (self.didOutputAudioSampleBuffer)
    {
        self.didOutputAudioSampleBuffer(session, (__bridge id)(audioSampleBuffer));
    }
}

#pragma mark - 节点旋转
- (void)rotateNode:(id)node duration:(NSTimeInterval)interval animKey:(NSString *)animKey
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"rotation"];
    animation.duration = interval;
    animation.toValue = [NSValue valueWithSCNVector4:SCNVector4Make(0, 1, 0, M_PI * 2)];
    animation.repeatCount = FLT_MAX;
    [node addAnimation:animation forKey:animKey];
}

#pragma mark - 更新节点位置及大小
- (void)update3DNode:(SCNNode *)node position:(SCNVector3)position scale:(SCNVector3)scale
{
    node.scale = scale;
    node.position = position;

    // 一个3D建模不是一气呵成的，可能会有很多个子节点拼接，所以里面的子节点也要一起改，否则上面的修改会无效
    for (SCNNode *childNode in node.childNodes)
    {
        childNode.scale = scale;
        childNode.position = position;
    }
}

#pragma mark - 上溯找寻指定的node
- (BOOL)isNodePartOfVirtualObject:(id)node nodeName:(NSString *)nodeName style:(ARStyle)style
{
    NSString *node_name = nil;
    id parentNode = nil;
    switch (style)
    {
        case ARStyle2D:
        {
            node_name = ((SKNode *)node).name;
            parentNode = ((SKNode *)node).parent;
        }
        break;
        case ARStyle3D:
        {
            node_name = ((SCNNode *)node).name;
            parentNode = ((SCNNode *)node).parentNode;
        }
        break;
        default:
            break;
    }
    if ([nodeName isEqualToString:node_name]) return YES;

    if (parentNode != nil) return [self isNodePartOfVirtualObject:parentNode nodeName:nodeName style:style];

    return NO;
}

#pragma mark - 点击AR视图时， 3D模型响应
- (void)hitTestARView:(id)arView
                point:(CGPoint)point
              options:(nullable NSDictionary<SCNHitTestOption, id> *)options
             nodeName:(NSString *)nodeName
                style:(ARStyle)style
    completionHandler:(void (^)(id arsView, id node))completion
{
    switch (style)
    {
        case ARStyle2D:
        {
            // 判断当前是否有像素
            if (!((ARSKView *)arView).session.currentFrame) return;
            // 识别物体的特征点
            NSArray<ARHitTestResult *> *results =
                [arView hitTest:point types:ARHitTestResultTypeEstimatedHorizontalPlane];
            // 如果没有特征点就返回。比如说大晚上黑漆漆一片...
            if (results.count == 0) return;
            // 是否為第一個物件.防止多次点击，不知道识别哪个了
            if (!results.firstObject) return;
            //遍历所有的返回结果中的node
            for (ARHitTestResult *res in results)
            {
                SKNode *node = [(ARSKView *)arView nodeForAnchor:res.anchor];
                if ([self isNodePartOfVirtualObject:node nodeName:nodeName style:style])
                {
                    if (completion) completion(arView, node);
                    return;
                }
            }
        }
        break;
        case ARStyle3D:
        {
            NSDictionary *hitTestOptions =
                [NSDictionary dictionaryWithObjectsAndKeys:@(YES), SCNHitTestBoundingBoxOnlyKey, nil];
            NSArray<SCNHitTestResult *> *results = [arView hitTest:point options:hitTestOptions];
            //遍历所有的返回结果中的node
            for (SCNHitTestResult *res in results)
            {
                if ([self isNodePartOfVirtualObject:res.node nodeName:nodeName style:style])
                {
                    if (completion) completion(arView, res.node);
                    return;
                }
            }
        }
        break;
        default:
            break;
    }

    if (completion) completion(arView, nil);
}

- (NSDictionary *)modelOriginInfo:(NSString *)plistPath
{
    NSArray *array = [NSArray arrayWithContentsOfFile:plistPath];
    NSDictionary *resultDic;
    for (NSDictionary *originDic in array)
    {
        NSString *localName = originDic[@"model_dds"];
        if ([localName isEqualToString:@"origin_camera"])
        {
            resultDic = originDic[@"model_origin"];
            continue;
        }
    }
    return resultDic;
}

@end
