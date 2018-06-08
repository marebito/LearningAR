//
//  ARHelper.h
//  LearningAR
//
//  Created by Yuri Boyka on 2018/2/25.
//  Copyright © 2018年 Godlike Studio. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SUPPORT_2D 1  // 支持2D

#define SUPPORT_3D 1  // 支持3D

#define SHOW_FPS 1  // 显示统计（例如fps和时间等信息）

#if SUPPORT_2D
#import <SpriteKit/SpriteKit.h>
#endif

#if SUPPORT_3D
#import <SceneKit/SceneKit.h>
#endif

#import <ARKit/ARKit.h>

#define ARASSETS_NAME @"art"  // AR资源库名称

#define ARASSETS_OPTIMIZE_NAME @"product-optimized"  // 从服务器端获取的模型库名称

/**
 会话配置跟踪类型

 - ARConfigurationTrackWorld: 跟踪世界
 - ARConfigurationTrackOrientation: 跟踪方向
 - ARConfigurationTrackFace: 跟踪人脸
 */
typedef NS_ENUM(NSUInteger, ARConfigurationTrack) {
    ARConfigurationTrackWorld,
    ARConfigurationTrackOrientation,
    ARConfigurationTracFace
};

/**
 设备坐标系统

 - ARCoordinateSystemDevice: 设备坐标系统（y轴垂直向上， z轴朝向观察者， x、z轴决定于设备初始状态）
 - ARCoordinateSystemCompass: 指南针坐标系统（y轴垂直向上， +Z~S， -Z~N， +X~E, -X~W）
 - ARCoordinateSystemCamera: 相机坐标系统(场景坐标系统被锁定匹配相机的朝向)
 */
typedef NS_ENUM(NSUInteger, ARCoordinateSystem) {
    ARCoordinateSystemDevice,
    ARCoordinateSystemCompass,
    ARCoordinateSystemCamera,
};

NS_ASSUME_NONNULL_BEGIN

/**
 AR类型

 - ARStyle2D: 2D类型
 - ARStyle3D: 3D类型
 */
typedef NS_ENUM(NSUInteger, ARStyle) { ARStyle2D, ARStyle3D };

/**
 手势回调
 */
typedef void (^GestureBlock)(UIGestureRecognizer *gesture);

@interface UIView (GestureHandle)

- (void)singleTapWithHandler:(GestureBlock)handler;

- (void)doubleTapWithhandler:(GestureBlock)handler;

- (void)panWithHandler:(GestureBlock)handler;

@end

/**
 锚点对应节点回调
 */
typedef id _Nullable (^NodeForAnchorCallback)(id renderer, ARAnchor *anchor);

/**
 节点改变回调
 */
typedef void (^NodeChangeCallback)(id renderer, id node, ARAnchor *anchor);

/**
 会话帧更新回调
 */
typedef void (^SessionUpdateFrameCallback)(ARSession *session, ARFrame *frame);

/**
 会话中锚点改变回调
 */
typedef void (^SessionAnchorChangeCallback)(ARSession *session, NSArray<ARAnchor *> *anchors);

/**
 会话状态回调
 */
typedef void (^SessionObserverCallback)(ARSession *session, id _Nullable object);

@interface ARHelper : NSObject

/**
 锚点对应节点回调
 实现这个方法为给定锚点提供一个自定义节点

 该节点会自动被添加到场景图中。 如果这个方法没有被实现， 一个节点将被自动创建。 如果返回是空该锚点将被忽略。

 第一个参数为将要渲染的场景。
 第二个参数为添加的锚点。
 */
@property(nonatomic, copy) NodeForAnchorCallback nodeForAnchor;

/**
 添加节点回调
 当一个新节点被映射到给定节点时调用。

 第一个参数是渲染器将要渲染的场景。
 第二个参数是渲染到锚点的节点。
 第三个参数是添加的锚点。
 */
@property(nonatomic, copy) NodeChangeCallback didAddNode;

/**
 将要更新节点回调
 当节点随着给定锚点数据将要被更新时被调用

 第一个参数是渲染器将要渲染的场景。
 第二个参数是将要被更新的节点。
 第三个参数是被更新的锚点。
 */
@property(nonatomic, copy) NodeChangeCallback willUpdateNode;

/**
 更新节点回调
 当节点随着给定锚点数据已经被更新时被调用

 第一个参数是渲染器将要渲染的场景。
 第二个参数是已经被更新的节点。
 第三个参数是被更新的锚点。
 */
@property(nonatomic, copy) NodeChangeCallback didUpdateNode;

/**
 移除节点回调
 一个被映射的节点已经被从给定锚点的场景图移除时被调用

 第一个参数是渲染器将要渲染的场景。
 第二个参数是被移除的节点。
 第三个参数是被移除的锚点。
 */
@property(nonatomic, copy) NodeChangeCallback didRemoveNode;

/**********************************************************************************
 *                                  接收相机帧                                     *
 **********************************************************************************/

/**
 一个新帧被更新时调用

 第一个参数当前正在运行的会话
 第二个参数已经被更新的帧
 */
@property(nonatomic, copy) SessionUpdateFrameCallback sessionUpdateFrame;

/**********************************************************************************
 *                                  处理内容更新                                   *
 **********************************************************************************/

/**
 新的锚点被添加到会话时被调用

 第一个参数当前正在运行的会话
 第二个参数添加的锚点数组
 */
@property(nonatomic, copy) SessionAnchorChangeCallback sessionDidAddAnchors;

/**
 锚点更新时调用

 第一个参数当前正在运行的会话
 第二个参数更新的锚点数组
 */
@property(nonatomic, copy) SessionAnchorChangeCallback sessionDidUpdateAnchors;

/**
 锚点从会话移除时调用

 第一个参数当前正在运行的会话
 第二个参数移除的锚点数组
 */
@property(nonatomic, copy) SessionAnchorChangeCallback sessionDidRemoveAnchors;

/**
 会话失败时调用，失败时会话将被暂停

 第一个参数会话
 第二个参数ARError
 */
@property(nonatomic, copy) SessionObserverCallback didFailWithError;

/**
 摄像机的跟踪状态发生改变时调用

 第一个参数会话
 第二个参数改变跟踪状态的相机
 */
@property(nonatomic, copy) SessionObserverCallback cameraDidChangeTrackingState;

/**
 会话被中断时调用。

 当它接收必要的传感器数据失败是会话将被中断并不再能够跟踪。这些发生在视频捕捉被中断时，
 例如当应用程序进入后台或者存在多个前台程序（参见AVCaptureSessionInterruptionReason）时。
 没有额外的帧更新将被传递直到中断已经结束。

 参数被中断的会话。
 */
@property(nonatomic, copy) SessionObserverCallback wasInterrupted;

/**
 会话中断已经结束时调用。

 一旦中断结束会话将从最后一次已知状态继续运行。如果设备被移动，锚点将会不一致。
 为了避免这种情况的发生，一些应用程序可能想重置跟踪（参见ARSessionRunOptions）。

 参数被中断的会话
 */
@property(nonatomic, copy) SessionObserverCallback interruptionEnded;

/**
 会话输出一个新的音频采样缓冲时调用。

 第一个参数正在运行的会话。
 第二个参数捕捉到的音频采样缓冲。
 */
@property(nonatomic, copy) SessionObserverCallback didOutputAudioSampleBuffer;

/**
 AR工具类单例

 @return 工具
 */
+ (instancetype)helper;

/**
 创建AR场景视图

 @param frame AR视图Frame
 @param style 2D/3D
 @return 返回AR场景视图对象
 */
- (UIView *)createARSViewWithFrame:(CGRect)frame style:(ARStyle)style;

/**
 绑定事件到目标视图上

 @param singleTap 单击
 @param doubleTap 双击
 @param pan 拖拽
 @param pinch 缩放
 @param target 目标视图
 */
- (void)bindAction:(GestureBlock)singleTap
         doubleTap:(GestureBlock)doubleTap
               pan:(GestureBlock)pan
             pinch:(GestureBlock)pinch
            target:(UIView *)target;

/**
 启动AR会话

 @param arView AR视图
 @param style 2D/3D
 */
- (void)startARSession:(id)arView style:(ARStyle)style;

/**
 启动AR会话

 @param arView AR视图
 @param configurationTrack 配置跟踪
 @param planeDetection 平面检测（仅世界跟踪需要）
 @param coordinateSystem 坐标系统
 @param providesAudioData AR会话中是否采集音频数据(默认不采集音频)， 如果开启必须实现didOutputAudioSampleBuffer回调
 @param style 2D/3D
 */
- (void)startARSession:(id)arView
    configurationTrack:(ARConfigurationTrack)configurationTrack
        planeDetection:(ARPlaneDetection)planeDetection
      coordinateSystem:(ARCoordinateSystem)coordinateSystem
     providesAudioData:(BOOL)providesAudioData
                 style:(ARStyle)style;

/**
 暂停AR

 @param arView ar视图
 @param style 2D/3D
 */
- (void)pauseARSession:(id)arView style:(ARStyle)style;

/**
 呈现AR

 @param scene 场景
 @param arView AR视图
 @param style 2D/3D
 */
- (void)presentScene:(id)scene target:(id)arView style:(ARStyle)style;

/**
 创建场景(默认3D)

 @param file 3D模型文件路径
 @return 返回3D场景
 */
- (id)sceneWithFile:(NSString *)file;

/**
 创建场景

 @param file 2D/3D模型文件
 @param style AR风格（2D/3D）
 @return 返回场景对象
 */
- (id)sceneWithFile:(NSString *)file style:(ARStyle)style;

/**
 创建场景

 @param file 文件路径
 @param style 2D/3D
 @param fromServer 是否是从云端下载的数据
 @param cameraPos 相机位置
 @param lightPos 光照位置
 @return 返回场景对象
 */
- (id)sceneWithFile:(NSString *)file
              style:(ARStyle)style
         fromServer:(BOOL)fromServer
          cameraPos:(SCNVector3)cameraPos
           lightPos:(SCNVector3)lightPos;

/**
 获取摄像机

 @param scene 场景(SKScene/SCNScene)
 @param style 2D/3D
 @return 返回摄像机（SKCameraNode/SCNNode）
 */
- (id)getSceneCamera:(id)scene style:(ARStyle)style;

/**
 获取当前帧的摄像机

 @param view AR视图(ARSKView/ARSKView)
 @param style 2D/3D
 @return 返回当前帧的摄像机
 */
- (ARCamera *)getCurrentFrameCamera:(id)view style:(ARStyle)style;

/**
 根据贝塞尔曲线创建3D节点

 @param bezierPath 贝塞尔曲线
 @return 返回3D节点
 */
- (SCNNode *)nodeWithBezierPath:(UIBezierPath *)bezierPath;

/**
 根据贝塞尔曲线创建3D节点

 1. chamferMode 依赖于 chamferRadius，只有当chamferRadius 大于 0 时， chamferMode才起作用。
 2. 生成的材质面个数依赖于chamferMode，当然更依赖于chamferRadius，最少3个，最多5个。

 @param bezierPath 贝塞尔曲线
 @param extrusionDepth 挤压深度
 @param chamferMode 倒角模式
 @param chamferRadius 倒角半径
 @param chamferProfile 倒角贝塞尔曲线
 @param materials 材质
 @return 返回3D节点
 */
- (SCNNode *)nodeWithBezierPath:(UIBezierPath *_Nullable)bezierPath
                 extrusionDepth:(CGFloat)extrusionDepth
                    chamferMode:(SCNChamferMode)chamferMode
                  chamferRadius:(CGFloat)chamferRadius
                 chamferProfile:(UIBezierPath *_Nullable)chamferProfile
                      materials:(NSArray<SCNMaterial *> *_Nullable)materials;

/**
 根据指定颜色生成材质

 @param color 颜色
 @return 返回指定颜色的材质
 */
- (SCNMaterial *)materialWithColor:(UIColor *)color;

/**
 根据环境光、散射光、镜面光、发射光颜色生成材质

 @param ambientColor 环境光颜色
 @param diffuseColor 散射光颜色
 @param specularColor 镜面光颜色
 @param emissionColor 发射光颜色
 @return 返回指定颜色的材质
 */
- (SCNMaterial *)materialWithAmbient:(UIColor *)ambientColor
                        diffuseColor:(UIColor *)diffuseColor
                       specularColor:(UIColor *)specularColor
                       emissionColor:(UIColor *)emissionColor;

/**
 返回一个指定宽高长的立方体

 @param width 宽
 @param height 高
 @param length 长
 @param radius 斜面半径
 @return 返回立方体
 */
- (SCNBox *)planeBoxWithWidth:(CGFloat)width
                       height:(CGFloat)height
                       length:(CGFloat)length
                chamferRadius:(CGFloat)radius;

/**
 返回指定宽高的平面

 @param width 宽
 @param height 高
 @return 返回平面
 */
- (SCNPlane *)planeWithWidth:(CGFloat)width height:(CGFloat)height;

/**
 旋转

 @param node 节点
 @param interval 动画时长
 @param animKey 动画key
 */
- (void)rotateNode:(id)node duration:(NSTimeInterval)interval animKey:(NSString *)animKey;

/**
 更新节点的位置、大小

 @param node 节点
 @param position 位置
 @param scale 大小
 */
- (void)update3DNode:(SCNNode *)node position:(SCNVector3)position scale:(SCNVector3)scale;

/**
 点击3D AR视图响应

 @param arView AR视图
 @param point 点击点
 @param options 点击选项
 @param nodeName 节点名称
 @param style 风格
 @param completion 完成回调
 */
- (void)hitTestARView:(id)arView
                point:(CGPoint)point
              options:(nullable NSDictionary<SCNHitTestOption, id> *)options
             nodeName:(NSString *)nodeName
                style:(ARStyle)style
    completionHandler:(void (^)(id arView, id node))completion;

/**
 模型初始状态

 @param plistPath model_info.plist
 @return 返回模型初始状态数据
 */
- (NSDictionary *)modelOriginInfo:(NSString *)plistPath;

@end

NS_ASSUME_NONNULL_END
