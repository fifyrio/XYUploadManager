
//
//  XYPhotoTool.m
//  tableView
//
//  Created by wuw on 16/3/25.
//  Copyright © 2016年 com.weizong. All rights reserved.
//

#import "XYPhotoTool.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "XYAsset.h"
#import "XYAssetGroup.h"
#define TARGET_SIZE_WIDTH           200
#define TARGET_SIZE_HEIGHT          200

@implementation XYPhotoTool
/**
 *  返回相机胶卷里所有照片
 *
 *  @param callback 由XYAsset组成的数组
 */
+ (void)getLocalAssets:(void(^)(NSArray *))callback{
    if (([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)){
        //ios8以后
        PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
        allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
        NSMutableArray *arr = [NSMutableArray array];
        [allPhotos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                PHAsset *asset = (PHAsset*)obj;
                XYAsset *xyAsset = [[XYAsset alloc] initWithPHAsset:asset];
                [arr addObject:xyAsset];
            }
        }];
        callback([arr copy]);
    }else{
        NSMutableArray *assetPhotos = [NSMutableArray array];
        [self.sharedAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                [group setAssetsFilter:[ALAssetsFilter allPhotos]];
                [group enumerateAssetsWithOptions:NSEnumerationReverse/*遍历方式*/ usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                    if (result) {
                        XYAsset *xyAsset = [[XYAsset alloc] initWithALAsset:result];
                        [assetPhotos addObject:xyAsset];
                    }
                }];
                callback(assetPhotos);
            }
        } failureBlock:^(NSError *error) {
        }];
    }
}

/**
 *  获取所有的专辑数据
 *
 *  @return callback 由PhotoAssetGroup组成的数组
 */
+ (void)getAllAlbums:(void(^)(NSArray *))callback{
    if (([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)){
        //ios8以后
        NSMutableArray *array = [NSMutableArray array];
        
        //获取SmartAlbum的数据
        PHFetchResult *albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        [albums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                PHFetchResult *phResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if (phResult.count) {
                    PHAsset *firstAsset = (PHAsset *)[phResult firstObject];
                    PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
                    imageRequestOptions.synchronous = YES;
                    [[PHImageManager defaultManager] requestImageForAsset:firstAsset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//                        XYAssetGroup *assetGroup = [[XYAssetGroup alloc] initWithPHAssetCollection:assetCollection name:assetCollection.localizedTitle count:phResult.count thumbnail:result];
                        PhotoAssetGroup *photoAssetGroup = [[PhotoAssetGroup alloc] initWithPHAssetCollection:assetCollection name:assetCollection.localizedTitle count:phResult.count thumbnail:result];
                        photoAssetGroup.photoModels = [photoAssetGroup getPhotoModels];
                        [array addObject:photoAssetGroup];
                    }];
                }
            }
        }];
        
        //获取所有的相册数据（因为这里面不包括所有照片）
        albums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
        [albums enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                PHAssetCollection *assetCollection = (PHAssetCollection *)obj;
                PHFetchOptions *options = [[PHFetchOptions alloc] init];
                options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %d", PHAssetMediaTypeImage];
                options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
                PHFetchResult *phResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:options];
                if (phResult.count) {
                    PHAsset *firstAsset = (PHAsset *)[phResult firstObject];
                    PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
                    imageRequestOptions.synchronous = YES;
                    [[PHImageManager defaultManager] requestImageForAsset:firstAsset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:imageRequestOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        PhotoAssetGroup *photoAssetGroup = [[PhotoAssetGroup alloc] initWithPHAssetCollection:assetCollection name:assetCollection.localizedTitle count:phResult.count thumbnail:result];
                        photoAssetGroup.photoModels = [photoAssetGroup getPhotoModels];
                        [array addObject:photoAssetGroup];
                    }];
                }
            }
        }];
        //将相机胶卷置为第一个
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            PhotoAssetGroup *photoAssetGroup = (PhotoAssetGroup *)obj;
            NSLog(@"name:%@",photoAssetGroup.name);
        }];
        callback([array copy]);
        
    }else{
        NSMutableArray *array = [NSMutableArray array];
        [self.sharedAssetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            if (group) {
                if (group.numberOfAssets > 0) {
                    PhotoAssetGroup *photoAssetGroup = [[PhotoAssetGroup alloc] initWithALAssetsGroup:group name:[group valueForProperty:ALAssetsGroupPropertyName] count:group.numberOfAssets thumbnail:[UIImage imageWithCGImage:group.posterImage]];
                    photoAssetGroup.photoModels = [photoAssetGroup getPhotoModels];
                    [array addObject:photoAssetGroup];
                }
            }else{
                callback([array copy]);
            }
        } failureBlock:^(NSError *error) {
        }];
    }
}

/**
 *  根据专辑获取专辑里所有的照片
 *
 *  @return callback 由XYAsset组成的数组
 */
+ (void)getAssetsByAssetGroup:(XYAssetGroup *)assetGroup callback:(void(^)(NSArray *))callback{
    if (([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)){
        //ios8以后
        NSMutableArray *array = [NSMutableArray array];
        PHAssetCollection *assetCollection = assetGroup.assetCollection;
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                PHAsset *asset = (PHAsset*)obj;
                XYAsset *xyAsset = [[XYAsset alloc] initWithPHAsset:asset];
                [array addObject:xyAsset];
            }
        }];
        callback(array);
    }else{
        NSMutableArray *array = [NSMutableArray array];
        ALAssetsGroup *group = assetGroup.alAssetGroup;
        [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                XYAsset *asset = [[XYAsset alloc] initWithALAsset:result];
                [array addObject:asset];
            }else{
                callback([array copy]);
            }
        }];
    }
}

+ (ALAssetsLibrary *)sharedAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *assetsLibrary = nil;
    dispatch_once(&pred, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    return assetsLibrary;
}
@end
