//
//  ARBaseController.m
//  LearningAR
//
//  Created by Yuri Boyka on 26/02/2018.
//  Copyright © 2018 zll. All rights reserved.
//

#import "ARBaseController.h"
#import "ARHelper.h"

#define WeakObj(o) try{}@finally{} __weak typeof(o) o##Weak = o;
#define StrongObj(o) autoreleasepool{} __strong typeof(o) o = o##Weak;

//#define AR_2D

@interface ARBaseController ()
{
#ifndef AR_2D
    ARSCNView *_sceneView;
#else
    ARSKView *_sceneView;
#endif
    ARStyle _style;
}
@property (nonatomic, strong) ARHelper *helper;
@end

@implementation ARBaseController

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

- (void)processNode
{
    _helper.nodeForAnchor = ^id(id renderer, ARAnchor *anchor) {
        return nil;
    };

    @WeakObj(self);
    _helper.didAddNode = ^(id renderer, id node, ARAnchor *anchor) {
        @StrongObj(self);
        // 创建一个SceneKit平面来可视化节点，使用其位置和范围
        SCNPlane *plane = [self.helper planeWithWidth:((ARPlaneAnchor *)anchor).extent.x height:((ARPlaneAnchor *)anchor).extent.y];
        SCNNode *planeNode = [SCNNode nodeWithGeometry:plane];
        planeNode.position = SCNVector3Make(((ARPlaneAnchor *)anchor).center.x, 0, ((ARPlaneAnchor *)anchor).center.z);
        // SCNPlanes是在他们本地坐标系是垂直的, 旋转它使其匹配ARPlaneAnchor的水平方向
        planeNode.transform = SCNMatrix4MakeRotation(-M_PI / 2, 1, 0, 0);
        // ARKit拥有对应锚点的节点， 所以让平面作为一个子节点
        [node addChildNode:planeNode];
    };
    _helper.willUpdateNode = ^(id renderer, id node, ARAnchor *anchor) {
        
    };
    _helper.didUpdateNode = ^(id renderer, id node, ARAnchor *anchor) {
        
    };
    _helper.didRemoveNode = ^(id renderer, id node, ARAnchor *anchor) {
        
    };
}

- (void)processSession
{
    _helper.sessionUpdateFrame = ^(ARSession *session, ARFrame *frame) {

    };
    _helper.sessionDidAddAnchors = ^(ARSession *session, NSArray<ARAnchor *> *anchors) {

    };
    _helper.sessionDidUpdateAnchors = ^(ARSession *session, NSArray<ARAnchor *> *anchors) {

    };
    _helper.sessionDidRemoveAnchors = ^(ARSession *session, NSArray<ARAnchor *> *anchors) {

    };
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _helper = [ARHelper helper];
    
    id scene = nil;
    
#ifndef AR_2D
    _style = ARStyle3D;
    
    _sceneView = (ARSCNView *)[_helper createARSViewWithFrame:self.view.bounds style:_style];
    // 从ship.scn文件加载3D场景
    scene = [_helper sceneWithFile:@"ship" style:_style];
#else
    _style = ARStyle2D;
    
    _sceneView = (ARSKView *)[_helper createARSViewWithFrame:self.view.bounds style:_style];
    _sceneView.showsNodeCount = YES;
    
    // 从Scene.sks文件加载2D场景
    scene = [_helper sceneWithFile:@"Scene" style:_style];
#endif
    //AR预览视图展现场景
    [_helper presentScene:scene target:_sceneView style:_style];
    
    [self processNode];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    CGPoint tapPoint  = [touch locationInView:_sceneView];//该点就是手指的点击位置

    NSDictionary *hitTestOptions = [NSDictionary dictionaryWithObjectsAndKeys:@(true),SCNHitTestBoundingBoxOnlyKey, nil];

    [_helper hitTestARView:_sceneView point:tapPoint options:hitTestOptions nodeName:@"Virtual object root node" style:_style completionHandler:^(ARSCNView *arView, SCNNode *node) {

    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
