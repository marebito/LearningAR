//
//  ViewController.m
//  LearningAR
//
//  Created by Yuri Boyka on 2018/2/25.
//  Copyright © 2018年 Godlike Studio. All rights reserved.
//

#import "ViewController.h"
#import "ARHelper.h"
#import "ARVirtualPlane.h"

#define WeakObj(o) \
    try            \
    {              \
    }              \
    @finally       \
    {              \
    }              \
    __weak typeof(o) o##Weak = o;
#define StrongObj(o)   \
    autoreleasepool {} \
    __strong typeof(o) o = o##Weak;

//#define AR_2D

@interface ViewController ()
{
#ifndef AR_2D
    NSString *_selectNodeName;
#endif

    // 相机相关坐标
    float _camera_postionX;   // 相机位置X
    float _camera_postionY;   // 相机位置Y
    float _camera_postionZ;   // 相机位置Z
    float _camera_rotationX;  // 相机旋转角度X
    float _camera_rotationY;  // 相机旋转角度Y
    float _camera_rotationZ;  // 相机旋转角度Z
    float _camera_rotationW;  // 相机旋转角度W
    float _lastMovePointX;    // 最后移动坐标X
    float _lastMovePointY;    // 最后移动坐标Y
    float _currentAngle;      // 当前角度
    float _nowScaleDegree;    // 当前缩放比例
}
@property(nonatomic, strong) ARVirtualPlane *selectedPlane;  // 虚拟平面
@property(nonatomic, strong) SCNNode *selectedObject;        // 选中对象
@property(nonatomic, strong) NSMutableDictionary *planes;    // 所有虚拟平面
@property(nonatomic, strong) SKCameraNode *sceneCamera;      // 场景相机
@property(nonatomic, assign) ARStyle style;                  // AR风格
@property(nonatomic, strong) SCNNode *shipNode;           // 飞机
@property(nonatomic, strong) UILabel *sessionInfoLabel;      // 会话信息标签
#ifndef AR_2D
@property(nonatomic, strong) ARSCNView *sceneView;
#else
@property(nonatomic, strong) ARSKView *sceneView;
#endif
@property(nonatomic, strong) ARHelper *helper;
@end

@implementation ViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [_helper startARSession:_sceneView style:_style];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [_helper pauseARSession:_sceneView style:_style];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    _planes = [[NSMutableDictionary alloc] init];

    _selectedPlane = [[ARVirtualPlane alloc] init];

    _helper = [ARHelper helper];

    id scene = nil;

#ifndef AR_2D
    _style = ARStyle3D;

    // 从ship.scn文件加载3D场景
    scene = [_helper sceneWithFile:@"ship.scn" style:_style];

    self.sceneCamera = [_helper getSceneCamera:scene style:_style];
    _sceneView = (ARSCNView *)[_helper createARSViewWithFrame:self.view.bounds style:_style];
    //    [_helper bindAction:^(UIGestureRecognizer *_Nonnull gesture) {
    //        NSLog(@"单击");
    //        //查找出点击的节点
    //        CGPoint hitPoint = [gesture locationInView:gesture.view];
    //        NSArray *hitResults = [(ARSCNView *)gesture.view hitTest:hitPoint options:nil];
    //
    //        // check that we clicked on at least one object
    //        if ([hitResults count] > 0)
    //        {
    //            // retrieved the first clicked object
    //            SCNHitTestResult *result = [hitResults objectAtIndex:0];
    //            //获取点击的material（贴图）
    //            SCNMaterial *material = result.node.geometry.firstMaterial;
    //            //打印出点击的material名字
    //            NSString *materialName = [NSString stringWithFormat:@"%@", material.name];
    //            NSLog(@"current model:%@", materialName);
    //
    //            //获取模型名字
    //            SCNNode *clickNode = result.node;
    //            _selectNodeName = clickNode.name;
    //            if ([_selectNodeName hasPrefix:@"T"])
    //            {
    //                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"model_info" ofType:@"plist"];
    //                NSArray *originArr = [NSArray arrayWithContentsOfFile:filePath];
    //                NSDictionary *resultDic;
    //                for (NSDictionary *originDic in originArr)
    //                {
    //                    NSString *localName = originDic[@"model_dds"];
    //                    if ([localName isEqualToString:_selectNodeName])
    //                    {
    //                        resultDic = originDic[@"model_origin"];
    //                        continue;
    //                    }
    //                }
    //                _camera_postionX = [resultDic[@"pointX"] floatValue];
    //                _camera_postionY = [resultDic[@"pointY"] floatValue];
    //                _camera_postionZ = [resultDic[@"pointZ"] floatValue];
    //                _camera_rotationX = [resultDic[@"rotationX"] floatValue];
    //                _camera_rotationY = [resultDic[@"rotationY"] floatValue];
    //                _camera_rotationZ = [resultDic[@"rotationZ"] floatValue];
    //                _camera_rotationW = [resultDic[@"rotationW"] floatValue];
    //
    //                _sceneCamera.position = CGPointMake(_camera_postionX, _camera_postionY);
    //                _sceneCamera.zPosition = _camera_postionZ;
    //                _sceneCamera.zRotation = _camera_rotationW;
    //                /*
    //                 _sceneCamera.position = SCNVector3Make(_camera_postionX, _camera_postionY, _camera_postionZ);
    //                 _sceneCamera.rotation = SCNVector4Make(_camera_rotationX, _camera_rotationY, _camera_rotationZ,
    //                 _camera_rotationW);
    //                 */
    //            }
    //            else if ([_selectNodeName hasPrefix:@"J"])
    //            {
    //                /*
    //                 [self requestSeatDetailInfoWithSeatId:_selectNodeName];
    //                 [self.baseImage addSubview:self.infoView];
    //                 */
    //            }
    //        }
    //    }
    //        doubleTap:^(UIGestureRecognizer *_Nonnull gesture) {
    //            NSLog(@"双击");
    //            //恢复至原值
    //            _lastMovePointY = 0;
    //            _currentAngle = 0;
    //            _nowScaleDegree = 1.0;
    //            //获取转动屏幕后的角度
    //            SCNNode *rootNode = [((SCNScene *)scene).rootNode childNodeWithName:@"Box006" recursively:YES];
    //            rootNode.transform = SCNMatrix4MakeRotation(_currentAngle, 0, 0, 1);
    //            //相机先切回到初始状态
    //            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"model_info" ofType:@"plist"];
    //            NSArray *originArr = [NSArray arrayWithContentsOfFile:filePath];
    //            NSDictionary *resultDic;
    //            for (NSDictionary *originDic in originArr)
    //            {
    //                NSString *localName = originDic[@"model_dds"];
    //                if ([localName isEqualToString:@"origin_camera"])
    //                {
    //                    resultDic = originDic[@"model_origin"];
    //                    continue;
    //                }
    //            }
    //            _camera_postionX = [resultDic[@"pointX"] floatValue];
    //            _camera_postionY = [resultDic[@"pointY"] floatValue];
    //            _camera_postionZ = [resultDic[@"pointZ"] floatValue];
    //            _camera_rotationX = [resultDic[@"rotationX"] floatValue];
    //            _camera_rotationY = [resultDic[@"rotationY"] floatValue];
    //            _camera_rotationZ = [resultDic[@"rotationZ"] floatValue];
    //            _camera_rotationW = [resultDic[@"rotationW"] floatValue];
    //
    //            _sceneCamera.position = CGPointMake(_camera_postionX, _camera_postionY);
    //            _sceneCamera.zPosition = _camera_postionZ;
    //            _sceneCamera.zRotation = _camera_rotationW;
    //            /*
    //             _sceneCamera.position = SCNVector3Make(_camera_postionX, _camera_postionY, _camera_postionZ);
    //             _sceneCamera.rotation = SCNVector4Make(_camera_rotationX, _camera_rotationY, _camera_rotationZ,
    //             _camera_rotationW);
    //             */
    //        }
    //        pan:^(UIGestureRecognizer *_Nonnull gesture) {
    //            NSLog(@"拖拽");
    //
    //            //            NSLog(@"Move object");
    //            //            if (recognizer.state == UIGestureRecognizerStateBegan)
    //            //            {
    //            //                NSLog(@"Pan state began");
    //            //                CGPoint tapPoint = [recognizer locationInView:_sceneView];
    //            //                NSArray *result = [self.sceneView hitTest:tapPoint options:nil];
    //            //
    //            //                if ([result count] == 0)
    //            //                {
    //            //                    return;
    //            //                }
    //            //                SCNHitTestResult *hitResult = [result firstObject];
    //            //                movedObject = [[[hitResult node] parentNode] parentNode] parentNode]; //This aspect
    //            varies
    //            //                based on the type of .SCN file that you have
    //            //            }
    //            //            if (selectedObject)
    //            //            {
    //            //                NSLog(@"Holding an Object");
    //            //            }
    //            //            if (recognizer.state == UIGestureRecognizerStateChanged)
    //            //            {
    //            //                NSLog(@"Pan State Changed");
    //            //                if (selectedObject)
    //            //                {
    //            //                    CGPoint tapPoint = [recognizer locationInView:_sceneView];
    //            //                    NSArray *hitResults = [_sceneView hitTest:tapPoint
    //            //                    types:ARHitTestResultTypeFeaturePoint];
    //            //                    ARHitTestResult *result = [hitResults lastObject];
    //            //
    //            //                    SCNMatrix4 matrix = SCNMatrix4FromMat4(result.worldTransform);
    //            //                    SCNVector3 vector = SCNVector3Make(matrix.m41, matrix.m42, matrix.m43);
    //            //
    //            //                    [movedObject setPosition:vector];
    //            //                    NSLog(@"Moving object position");
    //            //                }
    //            //            }
    //            //            if (recognizer.state == UIGestureRecognizerStateEnded)
    //            //            {
    //            //                NSLog(@"Done moving object homeie");
    //            //                selectedObject = nil;
    //            //            }
    //
    //            //刚接触界面的时候从本地文件取出位置，如果已经挪动过，则需要在当前基础上挪动
    //            if (gesture.state == UIGestureRecognizerStateBegan && _camera_postionY == 0)
    //            {
    //                //获取相机
    //                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"model_info" ofType:@"plist"];
    //                NSArray *originArr = [NSArray arrayWithContentsOfFile:filePath];
    //                NSDictionary *resultDic;
    //                for (NSDictionary *originDic in originArr)
    //                {
    //                    NSString *localName = originDic[@"model_dds"];
    //                    if ([localName isEqualToString:@"origin_camera"])
    //                    {
    //                        resultDic = originDic[@"model_origin"];
    //                        continue;
    //                    }
    //                }
    //                _camera_postionX = [resultDic[@"pointX"] floatValue];
    //                _camera_postionY = [resultDic[@"pointY"] floatValue];
    //                _camera_postionZ = [resultDic[@"pointZ"] floatValue];
    //                _camera_rotationX = [resultDic[@"rotationX"] floatValue];
    //                _camera_rotationY = [resultDic[@"rotationY"] floatValue];
    //                _camera_rotationZ = [resultDic[@"rotationZ"] floatValue];
    //                _camera_rotationW = [resultDic[@"rotationW"] floatValue];
    //            }
    //            //获取拖拽的位置
    //            CGPoint transformPoint = [(UIPanGestureRecognizer *)gesture velocityInView:gesture.view];
    //            _lastMovePointX += transformPoint.x;
    //            CGFloat onceMoveY = transformPoint.y;
    //            _lastMovePointY += onceMoveY;
    //            //修改相机位置
    //            _camera_postionZ += onceMoveY;
    //            _sceneCamera.position = CGPointMake(_camera_postionX, _camera_postionY);
    //            _sceneCamera.zPosition = _camera_postionZ;
    //            _sceneCamera.zRotation = _camera_rotationW;
    //            /*
    //             _sceneCamera.position = SCNVector3Make(_camera_postionX, _camera_postionY, _camera_postionZ);
    //             _sceneCamera.rotation = SCNVector4Make(_camera_rotationX, _camera_rotationY, _camera_rotationZ,
    //             _camera_rotationW);
    //
    //             //获取转动屏幕后的角度
    //             SCNNode *rootNode = [_scenePlace.rootNode childNodeWithName:@"Box006" recursively:YES];
    //             CGFloat newAngle = (transformPoint.x * (CGFloat)(M_PI / 180.0) )/50;
    //             newAngle += _currentAngle;
    //             rootNode.transform = SCNMatrix4MakeRotation(newAngle, 0, 0, 1);
    //             //转动过程中设置变化的角度
    //             if (panGestureRecognizer.state == UIGestureRecognizerStateEnded || panGestureRecognizer.state ==
    //             UIGestureRecognizerStateChanged) {
    //             _currentAngle = newAngle;
    //             }
    //             */
    //        }
    //        pinch:^(UIGestureRecognizer *_Nonnull gesture) {
    //            NSLog(@"捏合scale-->%f, velocity-->%f", ((UIPinchGestureRecognizer *)gesture).scale,
    //                  ((UIPinchGestureRecognizer *)gesture).velocity);
    //        }
    //        target:self.view];

    @WeakObj(self);
    [_helper bindAction:^(UIGestureRecognizer * _Nonnull gesture) {
        @StrongObj(self);
        CGPoint touchPoint = [gesture locationInView:self.sceneView];
        NSArray<SCNHitTestResult *> *results = [self.sceneView hitTest:touchPoint options:nil];
        if (results.count > 0)
        {
            if(self.selectedPlane)
            {
                NSArray<ARHitTestResult *> *hitResults = [self.sceneView hitTest:touchPoint types:ARHitTestResultTypeExistingPlane];
                if (hitResults.count > 0) {
                    for (ARHitTestResult *result in hitResults) {
                        SCNNode *node = [self.sceneView nodeForAnchor:result.anchor];
                        NSLog(@"node name:%@", node.name);
                    }
                }
            }
        }

        NSLog(@"单击");
    } doubleTap:^(UIGestureRecognizer * _Nonnull gesture) {
        NSLog(@"双击");
    } pan:^(UIGestureRecognizer * _Nonnull gesture) {
        NSLog(@"拖拽");
    } pinch:^(UIGestureRecognizer * _Nonnull gesture) {
        NSLog(@"捏合");
    } swipeLeft:^(UIGestureRecognizer * _Nonnull gesture) {
        NSLog(@"左转");
    } swipeRight:^(UIGestureRecognizer * _Nonnull gesture) {
        NSLog(@"右转");
    } swipeUp:nil swipeDown:nil target:_sceneView];
    _sceneView.allowsCameraControl = NO;
    _sceneView.automaticallyUpdatesLighting = YES;
    //    | SCNDebugOptions.showConstraints | SCNDebugOptions.showLightExtents
    _sceneView.debugOptions = ARSCNDebugOptionShowFeaturePoints | ARSCNDebugOptionShowWorldOrigin;
#else
    _style = ARStyle2D;

    _sceneView = (ARSKView *)[_helper createARSViewWithFrame:self.view.bounds style:_style];

    //    [_helper bindAction:^(UIGestureRecognizer * _Nonnull gesture) {
    //        CGPoint point = [(UITapGestureRecognizer *)gesture locationInView:self.view];
    //        [self.helper hitTestARView:self.sceneView
    //                             point:point
    //                           options:nil
    //                          nodeName:@"快乐的猫"
    //                             style:self.style
    //                 completionHandler:^(id _Nonnull arView, SCNNode *_Nonnull node) {
    //                     NSLog(@"node-->%@", node);
    //                 }];
    //        NSLog(@"单击");
    //    } doubleTap:^(UIGestureRecognizer * _Nonnull gesture) {
    //        NSLog(@"双击");
    //    } pan:^(UIGestureRecognizer * _Nonnull gesture) {
    //        NSLog(@"拖拽");
    //    } pinch:^(UIGestureRecognizer * _Nonnull gesture) {
    //        NSLog(@"捏合scale-->%f, velocity-->%f", ((UIPinchGestureRecognizer *)gesture).scale,
    //              ((UIPinchGestureRecognizer *)gesture).velocity);
    //    } target:self.view];

    _sceneView.showsNodeCount = YES;

    // 从Scene.sks文件加载2D场景
    scene = [_helper sceneWithFile:@"Scene" style:_style];
#endif

    _sceneView.scene = scene;

//    self.planeNode = scene.rootNode.childNode(withName: "Mug", recursively: true)!
    self.shipNode = [((SCNScene *)scene).rootNode childNodeWithName:@"shipMesh" recursively:true];
    [self.view addSubview:_sceneView];

    _sessionInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 300, 21)];
    _sessionInfoLabel.font = [UIFont systemFontOfSize:13.f];
    _sessionInfoLabel.textAlignment = NSTextAlignmentCenter;
    _sessionInfoLabel.textColor = [UIColor greenColor];
    _sessionInfoLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    _sessionInfoLabel.layer.masksToBounds = YES;
    _sessionInfoLabel.layer.cornerRadius = 5.0;
    [self.view addSubview:_sessionInfoLabel];
    // AR预览视图展现场景
    //    [_helper presentScene:scene target:_sceneView style:_style];

    [self process];
}

- (void)process
{
    [self processNode];
    [self processSession];
    [self processSessionState];
}

- (void)processNode
{
    @WeakObj(self);
#ifdef AR_2D
    _helper.nodeForAnchor = ^id _Nullable(id _Nonnull renderer, ARAnchor *_Nonnull anchor)
    {
        // 创建并配置一个节点，
        // Create and configure a node for the anchor added to the view's session.
        SKSpriteNode *ssn =
            [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:[UIImage imageNamed:@"IMG_0444.JPG"]]];
        // SKSpriteNode对象的x,y轴的位置信息
        ssn.position = CGPointZero;
        //锚点
        ssn.anchorPoint = CGPointMake(0.0, 0.0);
        // SKSpriteNode对象的宽度和高度信息的设置
        ssn.size = CGSizeMake(10, 10);
        // SKSpriteNode对象的名字,也就是SKSpriteNode对象的唯一标识符
        ssn.name = @"快乐的猫";

        return ssn;

        NSArray *emojiArray = [NSArray arrayWithObjects:@"测试", @"我了个去", nil];
        NSString *str = emojiArray[arc4random() % (emojiArray.count - 1)];
        SKLabelNode *labelNode = [SKLabelNode labelNodeWithText:str];
        labelNode.name = str;
        labelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
        labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;

        NSMutableArray *arrM = [NSMutableArray array];
        [arrM addObject:labelNode];
        [arrM addObject:ssn];

        return arrM[arc4random() % 2];
    };
#endif
    _helper.didAddNode = ^(id _Nonnull renderer, id _Nonnull node, ARAnchor *_Nonnull anchor) {
        @StrongObj(self);
        if ([anchor isKindOfClass:[ARPlaneAnchor class]])
        {
            ARVirtualPlane *vPlane = [[ARVirtualPlane alloc] initWithAnchor:(ARPlaneAnchor *)anchor];
            self.planes[((ARPlaneAnchor *)anchor).identifier] = vPlane;
            [node addChildNode:vPlane];
            //            SCNPlane *plane = [SCNPlane planeWithWidth:((ARPlaneAnchor *)anchor).extent.x
            //            height:((ARPlaneAnchor *)anchor).extent.z];
            //            SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
            //            planeNode.simdPosition = simd_make_float3(((ARPlaneAnchor *)anchor).center.x, 0,
            //            ((ARPlaneAnchor *)anchor).center.z);
            //            [planeNode setEulerAngles:SCNVector3Make(-M_PI / 2.0, planeNode.eulerAngles.y,
            //            planeNode.eulerAngles.z)];
            //            planeNode.opacity = 0.25;
            //            [node addChildNode:planeNode];
        }
    };
    _helper.willUpdateNode = ^(id _Nonnull renderer, id _Nonnull node, ARAnchor *_Nonnull anchor) {

    };
    _helper.didUpdateNode = ^(id _Nonnull renderer, id _Nonnull node, ARAnchor *_Nonnull anchor) {
        @StrongObj(self);
        ARVirtualPlane *vPlane = self.planes[((ARPlaneAnchor *)anchor).identifier];
        [vPlane updateWithNewAnchor:(ARPlaneAnchor *)anchor];
    };
    _helper.didRemoveNode = ^(id _Nonnull renderer, id _Nonnull node, ARAnchor *_Nonnull anchor) {
        @StrongObj(self);
        if ([anchor isKindOfClass:[ARPlaneAnchor class]])
        {
            [self.planes removeObjectForKey:((ARPlaneAnchor *)anchor).identifier];
        }
    };
}

- (void)processSession
{
    @WeakObj(self);
    _helper.sessionUpdateFrame = ^(ARSession *_Nonnull session, ARFrame *_Nonnull frame) {
        @StrongObj(self);
    };
    _helper.sessionDidAddAnchors = ^(ARSession *_Nonnull session, NSArray<ARAnchor *> *_Nonnull anchors) {
        @StrongObj(self);
        [self updateSessionInfoLabelForFrame:session.currentFrame];
    };
    _helper.sessionDidUpdateAnchors = ^(ARSession *_Nonnull session, NSArray<ARAnchor *> *_Nonnull anchors) {
        @StrongObj(self);
    };
    _helper.sessionDidRemoveAnchors = ^(ARSession *_Nonnull session, NSArray<ARAnchor *> *_Nonnull anchors) {
        @StrongObj(self);
        [self updateSessionInfoLabelForFrame:session.currentFrame];
    };
}

- (void)processSessionState
{
    @WeakObj(self) _helper.didFailWithError = ^(ARSession *_Nonnull session, id _Nullable object) {
        @StrongObj(self);
#ifndef AR_2D
        [self.sceneView resetTracking];
        [self.sceneView cleanupARSession];
#endif
    };
    _helper.cameraDidChangeTrackingState = ^(ARSession *_Nonnull session, id _Nullable object) {
        @StrongObj(self);
        [self updateSessionInfoLabelForFrame:session.currentFrame];
    };
    _helper.wasInterrupted = ^(ARSession *_Nonnull session, id _Nullable object) {

    };
    _helper.interruptionEnded = ^(ARSession *_Nonnull session, id _Nullable object) {

    };
    _helper.didOutputAudioSampleBuffer = ^(ARSession *_Nonnull session, id _Nullable object) {

    };
}

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    if (self.selectedPlane && self.selectedObject) return;
//    NSLog(@"%s", __FUNCTION__);
//    UITouch *touch = [[touches allObjects] firstObject];
//    //    if (_helper.sessionStatus != ARSessionStatusReady)
//    //    {
//    //        NSLog(@"平面没有产生好，不能放置物体");
//    //        return;
//    //    }
//    CGPoint touchPoint = [touch locationInView:_sceneView];
//    NSLog(@"[touch]:%@\t[point]:%@", touch, [NSValue valueWithCGPoint:touchPoint]);
//    ARVirtualPlane *plane = [self virtualPlaneProperlySet:touchPoint];
//    if (plane)
//    {
//        NSLog(@"[触摸到的虚拟平面]:%@", plane);
//        [self addObjectToPlane:plane atPoint:touchPoint];
//    }
//    else
//    {
//        NSLog(@"没有平面被触碰到");
//    }
//}

- (ARVirtualPlane *)virtualPlaneProperlySet:(CGPoint)touchPoint
{
    ARHitTestResult *result = [_helper hitTest:_sceneView touchPoint:touchPoint];
    if (result)
    {
        ARVirtualPlane *plane = self.planes[result.anchor.identifier];
        self.selectedPlane = plane;
        return plane;
    }
    return nil;
}

- (void)addObjectToPlane:(ARVirtualPlane *)plane atPoint:(CGPoint)touchPoint
{
    ARHitTestResult *result = [_helper hitTest:_sceneView touchPoint:touchPoint];
    if (result)
    {
        SCNBox *box = [SCNBox boxWithWidth:0.1 height:0.1 length:0.1 chamferRadius:0];
        SCNNode *node = [SCNNode nodeWithGeometry:box];
        SCNMaterial *material = [[SCNMaterial alloc] init];
        material.diffuse.contents = [UIColor redColor];
        node.geometry.materials = @[material];
        float nodeX = result.worldTransform.columns[3].x;
        float nodeY = result.worldTransform.columns[3].y;
        float nodeZ = result.worldTransform.columns[3].z;
        NSLog(@"[放置节点位置]: \n[x]: %f\n[y]: %f\n[z]: %f", nodeX, nodeY, nodeZ);
        node.position = SCNVector3Make(nodeX, nodeY, nodeZ);
        self.selectedObject = node;
        [_sceneView.scene.rootNode addChildNode:node];
//        SCNNode *cloneNode = [self.shipNode clone];
//        if (cloneNode)
//        {
//            cloneNode.position = SCNVector3Make(result.worldTransform.columns[3].x, result.worldTransform.columns[3].y,
//                                                result.worldTransform.columns[3].z);
//            cloneNode.scale = SCNVector3Make(2.0, 2.0, 2.0);
//            [_sceneView.scene.rootNode addChildNode:cloneNode];
//        }
    }
}

//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { NSLog(@"%s", __FUNCTION__); }
#ifndef AR_2D
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    //通过场景来加载3D模型文件
//    //    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.scn"];
//
//    //获取场景中的飞机节点
//    SCNNode *node = _sceneView.scene.rootNode.childNodes[0];
//
//    //设置节点的位置，单位是米 长宽高
//    node.position = SCNVector3Make(0.1, 0.1*(arc4random()%10), 0.1*(arc4random()%4));
//    //缩放
//    node.scale = SCNVector3Make(0.5, 0.5, 0.5);
//
//    //添加到当前场景中
//    [_sceneView.scene.rootNode addChildNode:node];
//
//    UITouch *touch = [touches anyObject];
//
//    CGPoint tapPoint  = [touch locationInView:_sceneView];//该点就是手指的点击位置
//
//    NSDictionary *hitTestOptions = [NSDictionary
//    dictionaryWithObjectsAndKeys:@(true),SCNHitTestBoundingBoxOnlyKey,
//    nil];
//
//    [_helper hitTestARView:_sceneView point:tapPoint options:hitTestOptions nodeName:@"Virtual object root
//    node"
//    completionHandler:^(ARSCNView *arView, SCNNode *node) {
//        [node removeFromParentNode];
//    }];
//}
#endif

- (void)updateSessionInfoLabelForFrame:(ARFrame *)frame
{
    NSString *message = nil;
    switch (frame.camera.trackingState)
    {
        case ARTrackingStateNormal:
        {
            if (frame.anchors.count == 0)
            {
                message = @"Move the device around to detect horizontal surfaces.";
            }
        }
        break;
        case ARTrackingStateNotAvailable:
            message = @"Tracking unavailable.";
            break;
        case ARTrackingStateLimited:
        {
            switch (frame.camera.trackingStateReason)
            {
                case ARTrackingStateReasonExcessiveMotion:
                    message = @"Tracking limited - Move the device more slowly.";
                    break;
                case ARTrackingStateReasonInsufficientFeatures:
                    message = @"Tracking limited - Point the device at an area with visible surface detail, or improve "
                              @"lighting conditions.";
                    break;
                case ARTrackingStateReasonInitializing:
                    message = @"Initializing AR session.";
                    break;
                default:
                    break;
            }
        }
        break;
        default:
            break;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        _sessionInfoLabel.hidden = !message;
        _sessionInfoLabel.text = message;
        [_sessionInfoLabel sizeToFit];
        _sessionInfoLabel.frame =
            CGRectMake(10, 30, _sessionInfoLabel.frame.size.width + 10, _sessionInfoLabel.frame.size.height + 10);
    });
}

@end
