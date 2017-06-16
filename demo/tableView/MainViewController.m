//
//  MainViewController.m
//  tableView
//
//  Created by 吴伟 on 15/10/9.
//  Copyright © 2015年 com.weizong. All rights reserved.
//

#import "MainViewController.h"
#import "ImagePickerViewController.h"

@interface MainViewController ()
@end

@implementation MainViewController

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Initialize

#pragma mark - Actions
- (IBAction)onclickCamera:(id)sender {
    ImagePickerViewController *cameraVC = [[ImagePickerViewController alloc] init];
    if(IS_IOS_8_LATER) {
        cameraVC.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    }
    [self presentViewController:cameraVC animated:YES completion:nil];
}


#pragma mark - Getters

#pragma mark - Memory
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
