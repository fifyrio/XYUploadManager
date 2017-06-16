//
//  XYPhotoTool.h
//  tableView
//
//  Created by wuw on 16/3/25.
//  Copyright © 2016年 com.weizong. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XYAssetGroup;
@class XYAsset;

@interface XYPhotoTool : NSObject
/**
 *  返回相机胶卷里所有照片
 *
 *  @param callback 由XYAsset组成的数组
 */
+ (void)getLocalAssets:(void(^)(NSArray *))callback;

/**
 *  获取所有的专辑数据
 *
 *  @return callback 由XYAssetGroup组成的数组
 */
+ (void)getAllAlbums:(void(^)(NSArray *))callback;

/**
 *  根据专辑获取专辑里所有的照片
 *
 *  @return callback 由XYAsset组成的数组
 */
+ (void)getAssetsByAssetGroup:(XYAssetGroup *)assetGroup callback:(void(^)(NSArray *))callback;
@end
