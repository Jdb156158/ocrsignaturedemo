//
//  ViewController.m
//  CameraCut
//
//  Created by libing on 2019/8/26.
//  Copyright © 2019 libing. All rights reserved.
//

#import "ViewController.h"
#import "CSJIDScanView.h"
#import "CSJScanIDCardViewController.h"

#import <opencv2/opencv.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>

@interface ViewController (){
    cv::Mat cvImage;
}
@property (weak, nonatomic) IBOutlet UIImageView *ImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLayoutHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewLayoutWidth;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageViewLayoutWidth.constant = scanBorderW;
    self.imageViewLayoutHeight.constant = scanBorderH;
    [self.ImageView setContentMode:UIViewContentModeScaleAspectFill];
}

- (IBAction)takePicture:(UIButton *)sender {
    CSJScanIDCardViewController * scVC = [[CSJScanIDCardViewController alloc]init];
    scVC.imageBackBlock = ^(UIImage * _Nonnull image) {
        [self changeImageBg:image];
    };
    [self.navigationController pushViewController:scVC animated:YES];
}

- (void)changeImageBg:(UIImage *)image{
    
    UIImageToMat(image, cvImage);
    //1:先灰度处理
    cv::cvtColor(cvImage, cvImage, CV_RGB2GRAY);
    //2:二值化
    cv::adaptiveThreshold(cvImage, cvImage, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 31, 40);
    UIImage *newImage = MatToUIImage(cvImage);
    
    self.ImageView.image = newImage;
}

@end
