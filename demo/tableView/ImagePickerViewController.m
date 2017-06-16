//
//  ImagePickerViewController.m
//  tableView
//
//  Created by wuw on 16/3/22.
//  Copyright © 2015年 Kingnet. All rights reserved.
//

#import "ImagePickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
//#import "AlbumViewController.h"
#import "XYPhotoTool.h"
#import "XYAsset.h"
#import <AFNetworking.h>
#import "KGStatusBar.h"
#import "XYFile.h"

@import AVFoundation;

static NSString * const kcameraAuthToast = @"请在iPhone的\"设置\"-\"隐私\"-\"相机\"选项中，允许Hi维修访问您的相机";

#define IMAGE_SCALE_SIZE_WIDTH      800

@interface ImagePickerViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate, NSURLSessionDelegate>
- (IBAction)cancelAction:(id)sender;
- (IBAction)takePhotoAction:(id)sender;
- (IBAction)changeCameraAction:(id)sender;
- (IBAction)flashAction:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *myAlbumView;
@property (weak, nonatomic) IBOutlet UIImageView *flashBtnIcon;
@property (weak, nonatomic) IBOutlet UIButton *flashBtn;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@end

@implementation ImagePickerViewController
#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sourceType = UIImagePickerControllerSourceTypeCamera;
    self.showsCameraControls = NO;
    self.allowsEditing = YES;
    self.delegate = self;
    //设定图像缩放比例
    self.cameraViewTransform = CGAffineTransformScale(self.cameraViewTransform, 1.3, 1.3);
    
    //自定义拍照界面
    NSArray* viewArray = [[UINib nibWithNibName:@"cameraView" bundle:nil] instantiateWithOwner:self options:nil];
    UIView *cameraView = [viewArray firstObject];
    cameraView.frame = self.cameraOverlayView.frame;
    self.cameraOverlayView = cameraView;
    [self.view layoutIfNeeded];
    self.myAlbumView.layer.cornerRadius = 2;
    self.myAlbumView.layer.masksToBounds = YES;
    self.myAlbumView.userInteractionEnabled = YES;
    [self setUpAlbumThumbImage];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapMyAlbumViewAction)];
    [self.myAlbumView addGestureRecognizer:tap];
    
    //此处获取摄像头授权
    switch ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo])
    {
        case AVAuthorizationStatusAuthorized:
        {
            break;
        }
        case AVAuthorizationStatusDenied:
        {
            NSLog(@"不允许状态，可以弹出一个alertview提示用户在隐私设置中开启权限");
            [self showCameraAuthToast];
            return;
        }
        case AVAuthorizationStatusNotDetermined:
        {
            NSLog(@"系统还未知是否访问，第一次开启相机时");
            break;
        }
        default:                                    //用户拒绝授权/未授权
        {
            NSLog(@"用户拒绝授权/未授权");
            [self showCameraAuthToast];
            return;
        }
    }  
}

#pragma mark - Action

- (void)showCameraAuthToast{
    if (!IS_IOS_8_LATER) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:kcameraAuthToast delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"" message:kcameraAuthToast preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *gotItAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [alertController addAction:gotItAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)takePhotoAction:(id)sender {
    [self takePicture];
}

- (IBAction)changeCameraAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.selected == NO) {
        //前置摄像头没有闪光灯
        self.flashBtn.hidden = YES;
        self.flashBtnIcon.hidden = YES;
        self.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        btn.selected = YES;
    }else{
        self.flashBtn.hidden = NO;
        self.flashBtnIcon.hidden = NO;
        [self.flashBtnIcon setBackgroundColor:[UIColor clearColor]];
        self.cameraDevice = UIImagePickerControllerCameraDeviceRear;
        btn.selected = NO;
    }
}
- (IBAction)flashAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (self.cameraFlashMode == UIImagePickerControllerCameraFlashModeAuto) {
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
        [btn setTitle:@"打开" forState:UIControlStateNormal];
        self.flashBtnIcon.image = [UIImage imageNamed:@"tjpj_sgd"];
    }else if (self.cameraFlashMode == UIImagePickerControllerCameraFlashModeOn){
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
        [btn setTitle:@"关闭" forState:UIControlStateNormal];
        self.flashBtnIcon.image = [UIImage imageNamed:@"tjpj_sgd_gb"];
    }else if (self.cameraFlashMode == UIImagePickerControllerCameraFlashModeOff){
        self.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        [btn setTitle:@"自动" forState:UIControlStateNormal];
        self.flashBtnIcon.image = [UIImage imageNamed:@"tjpj_sgd"];
    }
}

- (void)tapMyAlbumViewAction{
    /*
    AlbumViewController *albumVC = [[AlbumViewController alloc] init];
    albumVC.availableImageSum = self.availableImageSum;
    [self pushViewController:albumVC animated:YES];
     */
}

/**
 *  获取手机相册的第一张照片并设置为按钮背景图片
 */
- (void)setUpAlbumThumbImage{
    [XYPhotoTool getLocalAssets:^(NSArray *images) {
        XYAsset *asset = [images firstObject];
        [asset getThumbnailImage:^(UIImage * _Nonnull image) {
            [self.myAlbumView setImage:image];
        }];
    }];
}

#pragma mark - Asset Library
- (ALAssetsLibrary *)sharedAssetsLibrary {
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *assetsLibrary = nil;
    dispatch_once(&pred, ^{
        assetsLibrary = [[ALAssetsLibrary alloc] init];
    });
    return assetsLibrary;
}



#pragma mark - UIImagePickerControllerDelegate
-(UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    //获得编辑过的图片
    UIImage *originalImage = [info objectForKey: UIImagePickerControllerOriginalImage];
//    UIImage *scaleImage = [self getScaledImageByImage:originalImage];
    
    
    
    
    
    NSData *data = [self getImageDataByImage:originalImage];
    NSString *fileName = [self getFileNameByImage:originalImage];
    NSString *mineType = [self getMineTypeByImage:originalImage];
    
    NSString *localPath = [self saveImage:originalImage withImageName:fileName];
    
    XYFile *file = [[XYFile alloc] init];
    file.fileType = XYFileTypeImage;
    file.filePath = localPath;
    file.fileName = fileName;
    file.fileSize = [self getFileSizeByPath:localPath];
    file.trunks = (file.fileSize%1024==0)?((int)(file.fileSize/1024*1024)):((int)(file.fileSize/(1024*1024) +1));
    
    NSData *chunkData = [self readDataWithChunk:0 file:file];
    
    [self af_uploadImage:data fileName:fileName mineType:mineType];
//    [self xy_uploadImage:data fileName:fileName mineType:mineType];
}

- (NSData *)readDataWithChunk:(NSInteger)chunk file:(XYFile*)file{
    int offset = 1024*1024;//（每一片的大小是1M）
    
    NSData* data;
    
    NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:file.filePath];//打开一个文件准备读取
    
    [readHandle seekToFileOffset:offset * chunk];
    
    data = [readHandle readDataOfLength:offset];//从当前节点开始读取指定的长度数据
    
    return data;
    
    //    NSInputStream *fileStream = [NSInputStream inputStreamWithData:[readHandle readDataOfLength:1024*8]];
}

- (unsigned long long)getFileSizeByPath:(NSString *)path{
    // 总大小
    unsigned long long size = 0;
    NSString *sizeText = nil;
    NSFileManager *manager = [NSFileManager defaultManager];
    
    BOOL isDir = NO;
    BOOL exist = [manager fileExistsAtPath:path isDirectory:&isDir];
    
    // 判断路径是否存在
    if (!exist) return size;
    if (isDir) { // 是文件夹
        NSDirectoryEnumerator *enumerator = [manager enumeratorAtPath:path];
        for (NSString *subPath in enumerator) {
            NSString *fullPath = [path stringByAppendingPathComponent:subPath];
            size += [manager attributesOfItemAtPath:fullPath error:nil].fileSize;
            
        }
    }else{ // 是文件
        size += [manager attributesOfItemAtPath:path error:nil].fileSize;
    }
    return size;
}

/**
   保存图片到本地

 @return 图片的路径
 */
- (NSString *)saveImage:(UIImage *)image withImageName:(NSString *)imageName{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
     NSString *imageFilePath = [path stringByAppendingPathComponent:imageName];
    [UIImagePNGRepresentation(image) writeToFile:imageFilePath  atomically:YES];
    
    return imageFilePath;
}

- (void)xy_uploadImage:(NSData *)data fileName:(NSString *)fileName mineType:(NSString *)mineType{
    NSString *urlStr = @"http://www.alielieapp.com/api/upload/upload_img.php";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    [request setHTTPMethod:@"POST"];
    [request setValue:fileName forHTTPHeaderField:@"fileName"];
    [request setValue:mineType forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionUploadTask *task = [[self defaultSession] uploadTaskWithRequest:request fromData:data completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"success");
    }];
    
    [task resume];
}

- (NSURLSession *)defaultSession{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    return session;
}

- (NSURLSession *)backgroundSession{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *identifier = @"com.yourcompany.appId.BackgroundSession";
        NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:identifier];
        session = [NSURLSession sessionWithConfiguration:sessionConfig
                                                delegate:self
                                           delegateQueue:[NSOperationQueue mainQueue]];
    });
    
    return session;
}

- (void)af_uploadImage:(NSData *)data fileName:(NSString *)fileName mineType:(NSString *)mineType{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html",nil];
    NSString *urlStr = @"http://www.alielieapp.com/api/upload/upload_img.php";
    
    WS(weakSelf);
    [manager POST:urlStr parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data name:@"uploadfile" fileName:fileName mimeType:mineType];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        weakSelf.progressView.progress = uploadProgress.fractionCompleted;
        NSLog(@"finish:%f", uploadProgress.fractionCompleted);
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSLog(@"upload success");
        [KGStatusBar showSuccessWithStatus:@"Successfully synced"];
        weakSelf.progressView.progress = 0;
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"");
    }];
}

- (NSData *)getImageDataByImage:(UIImage *)image{
    NSData *data;
    if (UIImagePNGRepresentation(image) == nil) {
        data = UIImageJPEGRepresentation(image, 1);
    } else {
        data = UIImagePNGRepresentation(image);
    }
    return data;
}

- (UIImage *)getScaledImageByImage:(UIImage *)image{
    CGFloat scaleHeight = IMAGE_SCALE_SIZE_WIDTH * image.size.height / image.size.width;
    UIGraphicsBeginImageContext(CGSizeMake(IMAGE_SCALE_SIZE_WIDTH, scaleHeight));
    [image drawInRect:CGRectMake(0, 0, IMAGE_SCALE_SIZE_WIDTH, scaleHeight)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSString *)getMineTypeByImage:(UIImage *)image{
    return UIImagePNGRepresentation(image) ? @"image/png" : @"image/jpg";
}

- (NSString *)getFileNameByImage:(UIImage *)image{
    NSString *ext = UIImagePNGRepresentation(image)?@"png":@"jpg";
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置时间格式
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%@.%@", str, ext];
}

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
