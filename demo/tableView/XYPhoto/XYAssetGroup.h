//
//  XYAssetGroup.h
//  tableView
//
//  Created by wuw on 16/3/24.
//  Copyright © 2016年 com.weizong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "PhotoModel.h"


@interface XYAssetGroup : NSObject
@property (copy, nonatomic, nonnull) NSString *name;//专辑名称
@property (assign, nonatomic) NSUInteger count;//专辑照片个数
@property (strong, nonatomic, nonnull) UIImage *thumbnail;

@property (strong, nonatomic, nonnull) PHAssetCollection *assetCollection;
@property (strong, nonatomic, nonnull) ALAssetsGroup *alAssetGroup;
/**
 *  初始化
 */
- (instancetype _Nonnull)initWithPHAssetCollection:(PHAssetCollection *_Nonnull)assetCollection name:(NSString *_Nonnull)name count:(NSUInteger)count thumbnail:(UIImage *_Nonnull)thumbnail;
- (instancetype _Nonnull)initWithALAssetsGroup:(ALAssetsGroup *_Nonnull)alAssetGroup name:(NSString *_Nonnull)name count:(NSUInteger)count thumbnail:(UIImage *_Nonnull)thumbnail;

/**
 *  Public methods
 */
- (NSArray *_Nonnull)getXYAssets;
@end

/**
 *  衍生
 */
@interface PhotoAssetGroup : XYAssetGroup
@property (copy, nonatomic, nonnull) NSArray *photoModels;
- (NSArray *_Nonnull)getPhotoModels;
@end
