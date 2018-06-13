//
//  SCNGeometry+Description.m
//  LearningAR
//
//  Created by zll on 2018/6/13.
//  Copyright © 2018年 zll. All rights reserved.
//

#import "SCNGeometry+Description.h"
#import "ARDescUtil.h"

@implementation SCNGeometry (Description)

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"[几何名称]: %@\n[材质]: %@\n[第一材质]: %@\n[源]: %@\n[元素]: %@\n[元素个数]: "
                                      @"%ld\n[详细层级]: %@\n[镶嵌单元]: %@\n[分支层级]: "
                                      @"%lu\n[细分自适应]: %@\n[边缘折痕元素]: %@\n[边缘折痕源]: %@",
                                      self.name, self.materials, self.firstMaterial, self.geometrySources,
                                      self.geometryElements, (long)self.geometryElementCount, self.levelsOfDetail,
                                      self.tessellator, (unsigned long)self.subdivisionLevel,
                                      self.wantsAdaptiveSubdivision ? @"是" : @"否", self.edgeCreasesElement,
                                      self.edgeCreasesSource];
}

@end

@implementation SCNMaterial (Description)

- (NSString *)debugDescription
{
    return [NSString
        stringWithFormat:@"[材质名称]: %@\n[散射光]: %@\n[环境光]: %@\n[镜面反射光]: %@\n[发射光]: %@\n[材质透明度]: "
                         @"%@\n[表面反射]: %@\n[纹理片元乘子]: %@\n[表面朝向]: %@\n[位移]: %@\n[环境光遮蔽]: "
                         @"%@\n[自发光]: %@\n[金属光泽]: %@\n[粗糙度]: %@\n[发光]: %f\n[透明度]: %f\n[光照模型名]: "
                         @"%@\n[每个像素照亮]:%@\n[双边]: %@\n[填充模式]: %@\[剔除模式]: %@\n[透明模式]: "
                         @"%@\n[环境光自动匹配散射光]: %@\n[写入深度缓冲]: %@\n[色彩缓冲]: %@\n[从深度缓冲读取]: "
                         @"%@\n[菲涅尔指数]: %f\n[混合模式]: %@",
                         self.name, [self.diffuse debugDescription], [self.ambient debugDescription],
                         [self.specular debugDescription], [self.emission debugDescription],
                         [self.transparent debugDescription], [self.reflective debugDescription],
                         [self.multiply debugDescription], [self.normal debugDescription],
                         [self.displacement debugDescription], [self.ambientOcclusion debugDescription],
                         [self.selfIllumination debugDescription], [self.metalness debugDescription],
                         [self.roughness debugDescription], self.shininess, self.transparency, self.lightingModelName,
                         self.litPerPixel ? @"是" : @"否", self.doubleSided ? @"是" : @"否",
                         [ARDescUtil descForFillMode:self.fillMode], [ARDescUtil descForCullMode:self.cullMode],
                         [ARDescUtil descForTransparencyMode:self.transparencyMode],
                         self.locksAmbientWithDiffuse ? @"是" : @"否", self.writesToDepthBuffer ? @"是" : @"否",
                         [ARDescUtil descForColorMask:self.colorBufferWriteMask],
                         self.readsFromDepthBuffer ? @"是" : @"否", self.fresnelExponent,
                         [ARDescUtil descForBlendMode:self.blendMode]];
}

@end

@implementation SCNMaterialProperty (Description)

- (NSString *)debugDescription
{
    return [NSString
        stringWithFormat:@"[内容]: %@\n[强度]: %f\n[缩小率方式]: %@\n[放大率方式]: %@\n[纹理过滤]: %@\n[变换矩阵]: "
                         @"%@\n[横向纹理裁剪方式]: %@\n[纵向纹理裁剪方式]: %@\n[映射管道]: %ld\n[纹理组件]: "
                         @"%@\n[最大各向异性]： %f",
                         self.contents, self.intensity, [ARDescUtil descForFilterMode:self.minificationFilter],
                         [ARDescUtil descForFilterMode:self.magnificationFilter],
                         [ARDescUtil descForFilterMode:self.mipFilter],
                         [ARDescUtil descForSCNMatrix4:self.contentsTransform], [ARDescUtil descForWarpMode:self.wrapS],
                         [ARDescUtil descForWarpMode:self.wrapT], (long)self.mappingChannel,
                         [ARDescUtil descForColorMask:self.textureComponents], self.maxAnisotropy];
}

@end

@implementation SCNGeometrySource (Description)

- (NSString *)debugDescription
{
    return [NSString
        stringWithFormat:@"[材质源数据长度]: %lu\n[几何源语义]: %@\n[向量个数]: %ld\n[组件浮点值]: "
                         @"%@\n[每个向量组件数]: %ld\n[每个组件字节数]: %ld\n[数据偏移]: %ld\n[数据跨度]: %ld",
                         (unsigned long)self.data.length, self.semantic, (long)self.vectorCount,
                         self.floatComponents ? @"是" : @"否", (long)self.componentsPerVector,
                         (long)self.bytesPerComponent, (long)self.dataOffset, self.dataStride];
}

@end

@implementation SCNGeometryElement (Description)

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"[几何元素数据长度]: %lu\n[基元类型]: %@\n[基元个数]: %ld\n[基元范围]: "
                                      @"%@\n[索引字节数]: %ld\n[点大小]: %f\n[屏幕空间最小点半径]： "
                                      @"%f\n[屏幕空间最大点半径]: %f",
                                      (unsigned long)self.data.length,
                                      [ARDescUtil descForPrimitiveType:self.primitiveType], (long)self.primitiveCount,
                                      [NSString stringWithFormat:@"[起始]:%lu\t[长度]:%lu",
                                                                 (unsigned long)self.primitiveRange.location,
                                                                 (unsigned long)self.primitiveRange.length],
                                      (long)self.bytesPerIndex, self.pointSize, self.minimumPointScreenSpaceRadius,
                                      self.maximumPointScreenSpaceRadius];
}

@end

@implementation SCNLevelOfDetail (Description)

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"[几何体]:%@ \n[屏幕空间半径]： %f\n[世界空间距离]: %f", self.geometry,
                                      self.screenSpaceRadius, self.worldSpaceDistance];
}

@end

@implementation SCNGeometryTessellator (Description)

- (NSString *)debugDescription
{
    return [NSString stringWithFormat:@"[曲面细分因子]:%f \n[曲面细分模式]： %@\n[自适应]: %@\n[在屏幕空间自适应]: "
                                      @"%@\n[边界曲面细分因子]: %f\n[内部曲面细分因子]: %f\n[最大边界长度]: "
                                      @"%f\n[平滑模式]: %@",
                                      self.tessellationFactorScale,
                                      [ARDescUtil descForTessellationPartitionMode:self.tessellationPartitionMode],
                                      self.adaptive ? @"是" : @"否", self.screenSpace ? @"是" : @"否",
                                      self.edgeTessellationFactor, self.insideTessellationFactor,
                                      self.maximumEdgeLength, [ARDescUtil descForSmoothingMode:self.smoothingMode]];
}

@end
