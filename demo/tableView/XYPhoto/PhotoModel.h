//
//  PhotoModel.h
//  XYHiRepairs
//
//  Created by wuw on 16/3/25.
//  Copyright © 2016年 Kingnet. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XYAsset.h"

@interface PhotoModel : NSObject
@property (strong, nonatomic) XYAsset *asset;
@property (assign, nonatomic) BOOL isSelected;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;
@end
