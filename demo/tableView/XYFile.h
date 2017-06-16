//
//  XYFile.h
//  tableView
//
//  Created by wuw on 2017/6/14.
//  Copyright © 2017年 Kingnet. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, XYFileType) {
    XYFileTypeImage = 0,
    XYFileTypeVideo,
};

@interface XYFile : NSObject

@property(nonatomic )XYFileType fileType;//image or movie

@property(nonatomic, copy)NSString* filePath;//文件在app中路径

@property(nonatomic, copy)NSString* fileName;//文件名

@property(nonatomic, assign)NSInteger fileSize;//文件大小

@property (nonatomic, assign)NSInteger trunks;//总片数

@property(nonatomic, copy)NSString* fileInfo;

@property(nonatomic, strong)UIImage* fileImage;//文件缩略图

@property(nonatomic, strong) NSMutableArray* fileArr;//标记每片的上传状态

@end
