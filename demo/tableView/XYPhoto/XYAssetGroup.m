

//
//  XYAssetGroup.m
//  tableView
//
//  Created by wuw on 16/3/24.
//  Copyright © 2016年 com.weizong. All rights reserved.
//

#import "XYAssetGroup.h"
#import "XYAsset.h"
@interface XYAssetGroup()

@end

@implementation XYAssetGroup
#pragma mark - Init
- (instancetype _Nonnull)initWithPHAssetCollection:(PHAssetCollection *_Nonnull)assetCollection name:(NSString *_Nonnull)name count:(NSUInteger)count thumbnail:(UIImage *_Nonnull)thumbnail;{
    if (self = [super init] ) {
        _assetCollection = assetCollection;
        _name = name;
        _count = count;
        _thumbnail = thumbnail;
    }
    return self;
}
- (instancetype _Nonnull)initWithALAssetsGroup:(ALAssetsGroup *_Nonnull)alAssetGroup name:(NSString *_Nonnull)name count:(NSUInteger)count thumbnail:(UIImage *_Nonnull)thumbnail{
    if (self = [super init] ) {
        _alAssetGroup = alAssetGroup;
        _name = name;
        _count = count;
        _thumbnail = thumbnail;
    }
    return self;
}

#pragma mark - Public methods
- (NSArray *_Nonnull)getXYAssets{
    NSMutableArray *assets = [NSMutableArray array];
    if (([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)){
        PHFetchOptions *option = [[PHFetchOptions alloc] init];
        option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:_assetCollection options:option];
        [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj) {
                XYAsset *asset = [[XYAsset alloc] initWithPHAsset:obj];
                [assets addObject:asset];
            }
        }];
        return [assets copy];
    }else{
        [_alAssetGroup enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                XYAsset *asset = [[XYAsset alloc] initWithALAsset:result];
                [assets addObject:asset];
            }
        }];
        return [assets copy];
    }
}
@end

@implementation PhotoAssetGroup
- (void)setPhotoModels:(NSArray *)photoModels{
    _photoModels = photoModels;
}
- (NSArray *_Nonnull)getPhotoModels{
    NSArray *assetArray = [self getXYAssets];
    NSMutableArray *photoModels = [NSMutableArray array];
    [assetArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        XYAsset *asset = (XYAsset *)obj;
        PhotoModel *model = [[PhotoModel alloc] init];
        model.asset = asset;
        model.isSelected = NO;
        [photoModels addObject:model];
    }];
    return [photoModels copy];
}
@end
