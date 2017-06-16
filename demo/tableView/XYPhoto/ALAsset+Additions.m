
//
//  ALAsset+Additions.m
//  tableView
//
//  Created by wuw on 16/3/24.
//  Copyright © 2016年 com.weizong. All rights reserved.
//

#import "ALAsset+Additions.h"

@implementation ALAsset (Additions)
- (UIImage *)thumbnailImage {
    return [[UIImage alloc]initWithCGImage:[self aspectRatioThumbnail]];
}

- (UIImage *)aspectRatioThumbnailImage{
    CGImageRef ref = [self aspectRatioThumbnail];
    return [UIImage imageWithCGImage:ref];
}

- (UIImage *)originalImage {
    
    CGImageRef ref = [[self defaultRepresentation] fullScreenImage];
    return [[UIImage alloc]initWithCGImage:ref];
}
- (NSTimeInterval)createTimeInterval {
    return [[self valueForProperty:ALAssetPropertyDate] timeIntervalSince1970];
}

- (NSURL *)assetURL {
    return [self valueForProperty:ALAssetPropertyAssetURL];
}
@end
