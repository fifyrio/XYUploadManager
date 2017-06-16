//
//  XYUploadManager.m
//  tableView
//
//  Created by wuw on 2017/6/16.
//  Copyright © 2017年 Kingnet. All rights reserved.
//

#import "XYUploadManager.h"

@interface XYUploadManager ()

@end

@implementation XYUploadManager

#pragma mark - init methods

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    static XYUploadManager *sharedManager = nil;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}



@end
