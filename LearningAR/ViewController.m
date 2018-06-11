//
//  ViewController.m
//  LearningAR
//
//  Created by Yuri Boyka on 2018/2/25.
//  Copyright © 2018年 Godlike Studio. All rights reserved.
//

#import "ViewController.h"
#import "ARHelper.h"

#define AR_2D

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

@property(nonatomic, strong) SKCameraNode *sceneCamera;  // 场景相机
@property(nonatomic, assign) ARStyle style;              // AR风格
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

    _helper = [ARHelper helper];

    id scene = nil;

#ifndef AR_2D
    _style = ARStyle3D;

    // 从ship.scn文件加载3D场景
    scene = [_helper sceneWithFile:@"ship.scn" style:_style];

    self.sceneCamera = [_helper getSceneCamera:scene style:_style];

    _sceneView = (ARSCNView *)[_helper createARSViewWithFrame:self.view.bounds
        singleTap:^(UIGestureRecognizer *gesture) {
            //查找出点击的节点
            CGPoint hitPoint = [gesture locationInView:gesture.view];
            NSArray *hitResults = [(ARSCNView *)gesture.view hitTest:hitPoint options:nil];

            // check that we clicked on at least one object
            if ([hitResults count] > 0)
            {
                // retrieved the first clicked object
                SCNHitTestResult *result = [hitResults objectAtIndex:0];
                //获取点击的material（贴图）
                SCNMaterial *material = result.node.geometry.firstMaterial;
                //打印出点击的material名字
                NSString *materialName = [NSString stringWithFormat:@"%@", material.name];
                NSLog(@"current model:%@", materialName);

                //获取模型名字
                SCNNode *clickNode = result.node;
                _selectNodeName = clickNode.name;
                if ([_selectNodeName hasPrefix:@"T"])
                {
                    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"model_info" ofType:@"plist"];
                    NSArray *originArr = [NSArray arrayWithContentsOfFile:filePath];
                    NSDictionary *resultDic;
                    for (NSDictionary *originDic in originArr)
                    {
                        NSString *localName = originDic[@"model_dds"];
                        if ([localName isEqualToString:_selectNodeName])
                        {
                            resultDic = originDic[@"model_origin"];
                            continue;
                        }
                    }
                    _camera_postionX = [resultDic[@"pointX"] floatValue];
                    _camera_postionY = [resultDic[@"pointY"] floatValue];
                    _camera_postionZ = [resultDic[@"pointZ"] floatValue];
                    _camera_rotationX = [resultDic[@"rotationX"] floatValue];
                    _camera_rotationY = [resultDic[@"rotationY"] floatValue];
                    _camera_rotationZ = [resultDic[@"rotationZ"] floatValue];
                    _camera_rotationW = [resultDic[@"rotationW"] floatValue];

                    _sceneCamera.position = CGPointMake(_camera_postionX, _camera_postionY);
                    _sceneCamera.zPosition = _camera_postionZ;
                    _sceneCamera.zRotation = _camera_rotationW;
                    /*
                     _sceneCamera.position = SCNVector3Make(_camera_postionX, _camera_postionY, _camera_postionZ);
                     _sceneCamera.rotation = SCNVector4Make(_camera_rotationX, _camera_rotationY, _camera_rotationZ,
                     _camera_rotationW);
                     */
                }
                else if ([_selectNodeName hasPrefix:@"J"])
                {
                    /*
                     [self requestSeatDetailInfoWithSeatId:_selectNodeName];
                     [self.baseImage addSubview:self.infoView];
                     */
                }
            }
        }
        doubleTap:^(UIGestureRecognizer *gesture) {
            //恢复至原值
            _lastMovePointY = 0;
            _currentAngle = 0;
            _nowScaleDegree = 1.0;
            //获取转动屏幕后的角度
            SCNNode *rootNode = [((SCNScene *)scene).rootNode childNodeWithName:@"Box006" recursively:YES];
            rootNode.transform = SCNMatrix4MakeRotation(_currentAngle, 0, 0, 1);
            //相机先切回到初始状态
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"model_info" ofType:@"plist"];
            NSArray *originArr = [NSArray arrayWithContentsOfFile:filePath];
            NSDictionary *resultDic;
            for (NSDictionary *originDic in originArr)
            {
                NSString *localName = originDic[@"model_dds"];
                if ([localName isEqualToString:@"origin_camera"])
                {
                    resultDic = originDic[@"model_origin"];
                    continue;
                }
            }
            _camera_postionX = [resultDic[@"pointX"] floatValue];
            _camera_postionY = [resultDic[@"pointY"] floatValue];
            _camera_postionZ = [resultDic[@"pointZ"] floatValue];
            _camera_rotationX = [resultDic[@"rotationX"] floatValue];
            _camera_rotationY = [resultDic[@"rotationY"] floatValue];
            _camera_rotationZ = [resultDic[@"rotationZ"] floatValue];
            _camera_rotationW = [resultDic[@"rotationW"] floatValue];

            _sceneCamera.position = CGPointMake(_camera_postionX, _camera_postionY);
            _sceneCamera.zPosition = _camera_postionZ;
            _sceneCamera.zRotation = _camera_rotationW;
            /*
             _sceneCamera.position = SCNVector3Make(_camera_postionX, _camera_postionY, _camera_postionZ);
             _sceneCamera.rotation = SCNVector4Make(_camera_rotationX, _camera_rotationY, _camera_rotationZ,
             _camera_rotationW);
             */
        }
        pan:^(UIGestureRecognizer *gesture) {
            //刚接触界面的时候从本地文件取出位置，如果已经挪动过，则需要在当前基础上挪动
            if (gesture.state == UIGestureRecognizerStateBegan && _camera_postionY == 0)
            {
                //获取相机
                NSString *filePath = [[NSBundle mainBundle] pathForResource:@"model_info" ofType:@"plist"];
                NSArray *originArr = [NSArray arrayWithContentsOfFile:filePath];
                NSDictionary *resultDic;
                for (NSDictionary *originDic in originArr)
                {
                    NSString *localName = originDic[@"model_dds"];
                    if ([localName isEqualToString:@"origin_camera"])
                    {
                        resultDic = originDic[@"model_origin"];
                        continue;
                    }
                }
                _camera_postionX = [resultDic[@"pointX"] floatValue];
                _camera_postionY = [resultDic[@"pointY"] floatValue];
                _camera_postionZ = [resultDic[@"pointZ"] floatValue];
                _camera_rotationX = [resultDic[@"rotationX"] floatValue];
                _camera_rotationY = [resultDic[@"rotationY"] floatValue];
                _camera_rotationZ = [resultDic[@"rotationZ"] floatValue];
                _camera_rotationW = [resultDic[@"rotationW"] floatValue];
            }
            //获取拖拽的位置
            CGPoint transformPoint = [(UIPanGestureRecognizer *)gesture velocityInView:gesture.view];
            _lastMovePointX += transformPoint.x;
            CGFloat onceMoveY = transformPoint.y;
            _lastMovePointY += onceMoveY;
            //修改相机位置
            _camera_postionZ += onceMoveY;
            _sceneCamera.position = CGPointMake(_camera_postionX, _camera_postionY);
            _sceneCamera.zPosition = _camera_postionZ;
            _sceneCamera.zRotation = _camera_rotationW;
            /*
             _sceneCamera.position = SCNVector3Make(_camera_postionX, _camera_postionY, _camera_postionZ);
             _sceneCamera.rotation = SCNVector4Make(_camera_rotationX, _camera_rotationY, _camera_rotationZ,
             _camera_rotationW);

             //获取转动屏幕后的角度
             SCNNode *rootNode = [_scenePlace.rootNode childNodeWithName:@"Box006" recursively:YES];
             CGFloat newAngle = (transformPoint.x * (CGFloat)(M_PI / 180.0) )/50;
             newAngle += _currentAngle;
             rootNode.transform = SCNMatrix4MakeRotation(newAngle, 0, 0, 1);
             //转动过程中设置变化的角度
             if (panGestureRecognizer.state == UIGestureRecognizerStateEnded || panGestureRecognizer.state ==
             UIGestureRecognizerStateChanged) {
             _currentAngle = newAngle;
             }
             */
        }
        pinch:^(id _Nonnull gesture) {

        }
        style:_style];
    _sceneView.allowsCameraControl = NO;
    _sceneView.debugOptions = ARSCNDebugOptionShowWorldOrigin | ARSCNDebugOptionShowFeaturePoints;
#else
    _style = ARStyle2D;

    _sceneView = (ARSKView *)[_helper createARSViewWithFrame:self.view.bounds style:_style];

    [_helper bindAction:^(UIGestureRecognizer * _Nonnull gesture) {
        CGPoint point = [(UITapGestureRecognizer *)gesture locationInView:self.view];
        [self.helper hitTestARView:self.sceneView
                             point:point
                           options:nil
                          nodeName:@"快乐的猫"
                             style:self.style
                 completionHandler:^(id _Nonnull arView, SCNNode *_Nonnull node) {
                     NSLog(@"node-->%@", node);
                 }];
        NSLog(@"单击");
    } doubleTap:^(UIGestureRecognizer * _Nonnull gesture) {
        NSLog(@"双击");
    } pan:^(UIGestureRecognizer * _Nonnull gesture) {
        NSLog(@"拖拽");
    } pinch:^(UIGestureRecognizer * _Nonnull gesture) {
        NSLog(@"捏合scale-->%f, velocity-->%f", ((UIPinchGestureRecognizer *)gesture).scale,
              ((UIPinchGestureRecognizer *)gesture).velocity);
    } target:self.view];

    _sceneView.showsNodeCount = YES;

    // 从Scene.sks文件加载2D场景
    scene = [_helper sceneWithFile:@"Scene" style:_style];
#endif

    [self.view addSubview:_sceneView];
    // AR预览视图展现场景
    [_helper presentScene:scene target:_sceneView style:_style];

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
    _helper.didAddNode = ^(id _Nonnull renderer, id _Nonnull node, ARAnchor *_Nonnull anchor) {

    };
    _helper.willUpdateNode = ^(id _Nonnull renderer, id _Nonnull node, ARAnchor *_Nonnull anchor) {

    };
    _helper.didUpdateNode = ^(id _Nonnull renderer, id _Nonnull node, ARAnchor *_Nonnull anchor) {

    };
    _helper.didRemoveNode = ^(id _Nonnull renderer, id _Nonnull node, ARAnchor *_Nonnull anchor) {

    };
}

- (void)processSession
{
    _helper.sessionUpdateFrame = ^(ARSession *_Nonnull session, ARFrame *_Nonnull frame) {

    };
    _helper.sessionDidAddAnchors = ^(ARSession *_Nonnull session, NSArray<ARAnchor *> *_Nonnull anchors) {

    };
    _helper.sessionDidUpdateAnchors = ^(ARSession *_Nonnull session, NSArray<ARAnchor *> *_Nonnull anchors) {

    };
    _helper.sessionDidRemoveAnchors = ^(ARSession *_Nonnull session, NSArray<ARAnchor *> *_Nonnull anchors) {

    };
}

- (void)processSessionState
{
    _helper.didFailWithError = ^(ARSession *_Nonnull session, id _Nullable object) {

    };
    _helper.cameraDidChangeTrackingState = ^(ARSession *_Nonnull session, id _Nullable object) {

    };
    _helper.wasInterrupted = ^(ARSession *_Nonnull session, id _Nullable object) {

    };
    _helper.interruptionEnded = ^(ARSession *_Nonnull session, id _Nullable object) {

    };
    _helper.didOutputAudioSampleBuffer = ^(ARSession *_Nonnull session, id _Nullable object) {

    };
}

- (void)didReceiveMemoryWarning { [super didReceiveMemoryWarning]; }

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSLog(@"jskld");
}
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
//    NSDictionary *hitTestOptions = [NSDictionary dictionaryWithObjectsAndKeys:@(true),SCNHitTestBoundingBoxOnlyKey,
//    nil];
//
//    [_helper hitTestARView:_sceneView point:tapPoint options:hitTestOptions nodeName:@"Virtual object root node"
//    completionHandler:^(ARSCNView *arView, SCNNode *node) {
//        [node removeFromParentNode];
//    }];
//}
#endif

@end
