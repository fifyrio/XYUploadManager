//
//  XYAsset.h
//  tableView
//
//  Created by wuw on 16/3/24.
//  Copyright © 2016年 com.weizong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PHAsset;
@class ALAsset;

@interface XYAsset : NSObject
@property (strong, nonatomic, readonly, nonnull)UIImage *image;

/**
 *  初始化
 */
- (instancetype _Nonnull)initWithPHAsset:(PHAsset *_Nonnull)asset;
- (instancetype _Nonnull)initWithALAsset:(ALAsset *_Nonnull)asset;

/**
 *  获取图像
 */
- (void)getImageForTargetSize:(CGSize)targetSize callback:(void(^_Nonnull)(UIImage *_Nonnull))callback;

/**
 *  获取缩略图
 *
 *  @param callback 图像
 */
- (void)getThumbnailImage:(void(^_Nonnull)(UIImage *_Nonnull))callback;

/**
 *  获取原始图片
 *
 *  @param callback 图像
 */
- (void)getOriginalImageSynchronous:(BOOL)isSynchronous callback:(void(^_Nonnull)(UIImage *_Nonnull))callback;
@end
