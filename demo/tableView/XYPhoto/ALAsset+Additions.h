//
//  ALAsset+Additions.h
//  tableView
//
//  Created by wuw on 16/3/24.
//  Copyright © 2016年 com.weizong. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface ALAsset (Additions)
- (UIImage *)thumbnailImage;
- (UIImage *)aspectRatioThumbnailImage;
- (UIImage *)originalImage;
- (NSTimeInterval)createTimeInterval;
- (NSURL *)assetURL;
@end
