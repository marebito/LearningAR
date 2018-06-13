//
//  ARDescUtil.h
//  LearningAR
//
//  Created by zll on 2018/6/13.
//  Copyright © 2018年 zll. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SCNGeometry.h>
#import <SceneKit/SCNMaterial.h>
#import <SceneKit/SCNMaterialProperty.h>

@interface ARDescUtil : NSObject

+ (NSString *)descForFillMode:(SCNFillMode)fillMode;

+ (NSString *)descForCullMode:(SCNCullMode)cullMode;

+ (NSString *)descForTransparencyMode:(SCNTransparencyMode)transparencyMode;

+ (NSString *)descForColorMask:(SCNColorMask)colorMask;

+ (NSString *)descForBlendMode:(SCNBlendMode)blendMode;

+ (NSString *)descForSCNMatrix4:(SCNMatrix4)matrix;

+ (NSString *)descForFilterMode:(SCNFilterMode)mode;

+ (NSString *)descForWarpMode:(SCNWrapMode)mode;

+ (NSString *)descForPrimitiveType:(SCNGeometryPrimitiveType)primitiveType;

+ (NSString *)descForTessellationPartitionMode:(MTLTessellationPartitionMode)tessellationPartitionMode;

+ (NSString *)descForSmoothingMode:(SCNTessellationSmoothingMode)smoothingMode;

@end
