//
//  ARDescUtil.m
//  LearningAR
//
//  Created by zll on 2018/6/13.
//  Copyright © 2018年 zll. All rights reserved.
//

#import "ARDescUtil.h"

@implementation ARDescUtil

+ (NSString *)descForFillMode:(SCNFillMode)fillMode
{
    NSString *desc = @"";
    switch (fillMode)
    {
        case SCNFillModeFill:
            desc = @"SCNFillModeFill";
            break;
        case SCNFillModeLines:
            desc = @"SCNFillModeLines";
            break;
        default:
            break;
    }
    return desc;
}

+ (NSString *)descForCullMode:(SCNCullMode)cullMode
{
    NSString *desc = @"";
    switch (cullMode)
    {
        case SCNCullModeBack:
            desc = @"SCNCullModeBack";
            break;
        case SCNCullModeFront:
            desc = @"SCNCullModeFront";
            break;
        default:
            break;
    }
    return desc;
}

+ (NSString *)descForTransparencyMode:(SCNTransparencyMode)transparencyMode
{
    NSString *desc = @"";
    switch (transparencyMode)
    {
        case SCNTransparencyModeAOne:
            desc = @"SCNTransparencyModeAOne";
            break;
        case SCNTransparencyModeRGBZero:
            desc = @"SCNTransparencyModeRGBZero";
            break;
        case SCNTransparencyModeDualLayer:
            desc = @"SCNTransparencyModeDualLayer";
            break;
        case SCNTransparencyModeSingleLayer:
            desc = @"SCNTransparencyModeSingleLayer";
            break;
        default:
            break;
    }
    return desc;
}

+ (NSString *)descForColorMask:(SCNColorMask)colorMask
{
    NSString *modeDesc = @"";
    switch (colorMask)
    {
        case SCNColorMaskNone:
            modeDesc = @"SCNColorMaskNone";
            break;
        case SCNColorMaskRed:
            modeDesc = @"SCNColorMaskRed";
            break;
        case SCNColorMaskGreen:
            modeDesc = @"SCNColorMaskGreen";
            break;
        case SCNColorMaskBlue:
            modeDesc = @"SCNColorMaskBlue";
            break;
        case SCNColorMaskAlpha:
            modeDesc = @"SCNColorMaskAlpha";
            break;
        case SCNColorMaskAll:
            modeDesc = @"SCNColorMaskAll";
            break;
        default:
            break;
    }
    return modeDesc;
}

+ (NSString *)descForBlendMode:(SCNBlendMode)blendMode
{
    NSString *desc = @"";
    switch (blendMode)
    {
        case SCNBlendModeAdd:
            desc = @"SCNBlendModeAdd";
            break;
        case SCNBlendModeMax:
            desc = @"SCNBlendModeMax";
            break;
        case SCNBlendModeAlpha:
            desc = @"SCNBlendModeAlpha";
            break;
        case SCNBlendModeScreen:
            desc = @"SCNBlendModeScreen";
            break;
        case SCNBlendModeReplace:
            desc = @"SCNBlendModeReplace";
            break;
        case SCNBlendModeMultiply:
            desc = @"SCNBlendModeMultiply";
            break;
        case SCNBlendModeSubtract:
            desc = @"SCNBlendModeSubtract";
            break;
        default:
            break;
    }
    return desc;
}

+ (NSString *)descForSCNMatrix4:(SCNMatrix4)matrix
{
    return [NSString stringWithFormat:@"\n%f\t%f\t%f\t%f\t\n%f\t%f\t%f\t%f\t\n%f\t%f\t%f\t%f\t\n%f\t%f\t%f\t%f\t",
                                      matrix.m11, matrix.m12, matrix.m13, matrix.m14, matrix.m21, matrix.m22,
                                      matrix.m23, matrix.m24, matrix.m31, matrix.m32, matrix.m33, matrix.m34,
                                      matrix.m41, matrix.m42, matrix.m43, matrix.m44];
}

+ (NSString *)descForFilterMode:(SCNFilterMode)mode
{
    NSString *modeDesc = @"";
    switch (mode)
    {
        case SCNFilterModeNone:
            modeDesc = @"SCNFilterModeNone";
            break;
        case SCNFilterModeLinear:
            modeDesc = @"SCNFilterModeLinear";
            break;
        case SCNFilterModeNearest:
            modeDesc = @"SCNFilterModeNearest";
            break;
        default:
            break;
    }
    return modeDesc;
}

+ (NSString *)descForWarpMode:(SCNWrapMode)mode
{
    NSString *modeDesc = @"";
    switch (mode)
    {
        case SCNWrapModeClamp:
            modeDesc = @"SCNWrapModeClamp";
            break;
        case SCNWrapModeRepeat:
            modeDesc = @"SCNWrapModeRepeat";
            break;
        case SCNWrapModeClampToBorder:
            modeDesc = @"SCNWrapModeClampToBorder";
            break;
        case SCNWrapModeMirror:
            modeDesc = @"SCNWrapModeMirror";
            break;
        default:
            break;
    }
    return modeDesc;
}

+ (NSString *)descForPrimitiveType:(SCNGeometryPrimitiveType)primitiveType
{
    NSString *desc = @"";
    switch (primitiveType)
    {
        case SCNGeometryPrimitiveTypeTriangles:
            desc = @"SCNGeometryPrimitiveTypeTriangles";
            break;
        case SCNGeometryPrimitiveTypeTriangleStrip:
            desc = @"SCNGeometryPrimitiveTypeTriangleStrip";
            break;
        case SCNGeometryPrimitiveTypeLine:
            desc = @"SCNGeometryPrimitiveTypeLine";
            break;
        case SCNGeometryPrimitiveTypePoint:
            desc = @"SCNGeometryPrimitiveTypePoint";
            break;
        case SCNGeometryPrimitiveTypePolygon:
            desc = @"SCNGeometryPrimitiveTypePolygon";
            break;
        default:
            break;
    }
    return desc;
}

+ (NSString *)descForTessellationPartitionMode:(MTLTessellationPartitionMode)tessellationPartitionMode
{
    NSString *desc = @"";
    switch (tessellationPartitionMode)
    {
        case MTLTessellationPartitionModePow2:
            desc = @"MTLTessellationPartitionModePow2";
            break;
        case MTLTessellationPartitionModeInteger:
            desc = @"MTLTessellationPartitionModeInteger";
            break;
        case MTLTessellationPartitionModeFractionalOdd:
            desc = @"MTLTessellationPartitionModeFractionalOdd";
            break;
        case MTLTessellationPartitionModeFractionalEven:
            desc = @"MTLTessellationPartitionModeFractionalEven";
            break;
        default:
            break;
    }
    return desc;
}

+ (NSString *)descForSmoothingMode:(SCNTessellationSmoothingMode)smoothingMode
{
    NSString *desc = @"";
    switch (smoothingMode)
    {
        case SCNTessellationSmoothingModeNone:
            desc = @"SCNTessellationSmoothingModeNone";
            break;
        case SCNTessellationSmoothingModePhong:
            desc = @"SCNTessellationSmoothingModePhong";
            break;
        case SCNTessellationSmoothingModePNTriangles:
            desc = @"SCNTessellationSmoothingModePNTriangles";
            break;
        default:
            break;
    }
    return desc;
}

@end
