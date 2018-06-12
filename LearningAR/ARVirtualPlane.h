//
//  ARVirtualPlane.h
//  LearningAR
//
//  Created by zll on 2018/6/12.
//  Copyright © 2018年 zll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface ARVirtualPlane : SCNNode

@property(nonatomic, copy) NSString *identifier;

- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor;

- (void)updateWithNewAnchor:(ARPlaneAnchor *)anchor;

@end
