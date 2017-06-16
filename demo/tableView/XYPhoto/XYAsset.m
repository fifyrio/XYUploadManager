
//
//  XYAsset.m
//  tableView
//
//  Created by wuw on 16/3/24.
//  Copyright © 2016年 com.weizong. All rights reserved.
//

#import "XYAsset.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ALAsset+Additions.h"

#define Thumbnail_Size_Width            132
#define Thumbnail_Size_Height           132

@interface XYAsset()
@property (strong, nonatomic) PHAsset *phAsset;
@property (strong, nonatomic) ALAsset *alAsset;
@end

@implementation XYAsset
- (instancetype _Nonnull)initWithPHAsset:(PHAsset *_Nonnull)asset{
    if (self = [super init] ) {
        _phAsset = asset;
    }
    return self;
}

- (instancetype _Nonnull)initWithALAsset:(ALAsset *_Nonnull)asset{
    if (self = [super init] ) {
        _alAsset = asset;
    }
    return self;
}

- (void)getImageForTargetSize:(CGSize)targetSize callback:(void(^_Nonnull)(UIImage *_Nonnull))callback{
    if (([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)){
        PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.networkAccessAllowed = YES;
        imageRequestOptions.synchronous = YES;
        [[PHImageManager defaultManager] requestImageForAsset:_phAsset targetSize:CGSizeMake(600, 600) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            callback(result);
        }];
    }else{
        callback(_alAsset.aspectRatioThumbnailImage);
    }
}

- (void)getThumbnailImage:(void(^_Nonnull)(UIImage *_Nonnull))callback{
    if (([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)){
        PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        imageRequestOptions.networkAccessAllowed = YES;
        [[PHImageManager defaultManager] requestImageForAsset:_phAsset targetSize:CGSizeMake(Thumbnail_Size_Width, Thumbnail_Size_Height) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            callback(result);
        }];
    }else{
        callback(_alAsset.aspectRatioThumbnailImage);
    }
}

- (void)getOriginalImageSynchronous:(BOOL)isSynchronous callback:(void(^_Nonnull)(UIImage *_Nonnull))callback{
    if (([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)){
        PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.networkAccessAllowed = YES;
        imageRequestOptions.synchronous = isSynchronous;
        [[PHImageManager defaultManager] requestImageDataForAsset:_phAsset options:imageRequestOptions resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            UIImage *image = [UIImage imageWithData:imageData];
            callback(image);
        }];
    }else{
        callback(_alAsset.originalImage);
    }
}
@end
