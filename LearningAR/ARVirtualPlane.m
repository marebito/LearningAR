//
//  ARVirtualPlane.m
//  LearningAR
//
//  Created by zll on 2018/6/12.
//  Copyright © 2018年 zll. All rights reserved.
//

#import "ARVirtualPlane.h"

@interface ARVirtualPlane ()
@property(nonatomic, strong) ARPlaneAnchor *anchor;
@property(nonatomic, strong) SCNPlane *planeGeometry;
@end

@implementation ARVirtualPlane

- (instancetype)initWithAnchor:(ARPlaneAnchor *)anchor
{
    if (self = [super init])
    {
        self.anchor = anchor;
        self.identifier = self.anchor.identifier;
        self.planeGeometry = [SCNPlane planeWithWidth:anchor.extent.x height:anchor.extent.z];
        SCNMaterial *material = [self initializePlaneMaterial];
        self.planeGeometry.materials = @[ material ];

        SCNNode *planeNode = [SCNNode nodeWithGeometry:self.planeGeometry];
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(-M_PI / 2.0, 1.0, 0.0, 0.0);

        [self updatePlaneMaterialDimensions];

        [self addChildNode:planeNode];
    }
    return self;
}

- (SCNMaterial *)initializePlaneMaterial
{
    SCNMaterial *material = [[SCNMaterial alloc] init];
//    material.diffuse.contents = [UIColor colorWithWhite:1.0 alpha:0.10];
    material.diffuse.contents = [UIColor yellowColor];
    return material;
}

- (void)updateWithNewAnchor:(ARPlaneAnchor *)anchor
{
    self.planeGeometry.width = anchor.extent.x;
    self.planeGeometry.height = anchor.extent.z;

    self.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);

    [self updatePlaneMaterialDimensions];
}

- (void)updatePlaneMaterialDimensions
{
    SCNMaterial *material = self.planeGeometry.materials.firstObject;

    CGFloat width = self.planeGeometry.width;
    CGFloat height = self.planeGeometry.height;
    material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0);
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder])
    {
    }
    return self;
}

@end
