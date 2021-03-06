//
//  ViewController.m
//  CameraCut
//
//  Created by libing on 2019/8/26.
//  Copyright © 2019 libing. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/core/core_c.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgcodecs/ios.h>


#import "ViewController.h"
#import "CSJIDScanView.h"
#import "CSJScanIDCardViewController.h"

#import "CameraCut-Bridging-Header.h"
#import "CameraCut-Swift.h"

@interface ViewController (){
    cv::Mat cvImage;
    cv::Mat image_canny;
}

//签名
@property (strong, nonatomic) VCImageSticker *imageSticker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.imageSticker = [[VCImageSticker alloc] initWithFrame:CGRectMake(0, kScreenHeight-100-scanBorderH, scanBorderW, scanBorderH)];
    [self.imageSticker.imageView setContentMode:UIViewContentModeScaleAspectFill];
    self.imageSticker.imageView.clipsToBounds = YES;
}

- (IBAction)takePicture:(UIButton *)sender {
    CSJScanIDCardViewController * scVC = [[CSJScanIDCardViewController alloc]init];
    scVC.imageBackBlock = ^(UIImage * _Nonnull image) {
        [self changeImageBg:image];
    };
    [self.navigationController pushViewController:scVC animated:YES];
}

- (void)changeImageBg:(UIImage *)image{
    
    //将UIImage对象转为Mat
    UIImageToMat(image, cvImage);
    //灰度
    cv::cvtColor(cvImage, cvImage, CV_RGB2GRAY);
    //二值化
    cv::adaptiveThreshold(cvImage, cvImage, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY, 31, 40);
    
    //透明化背景
    if (cvImage.channels() != 4)
    {
        cv::cvtColor(cvImage, image_canny, CV_BGR2BGRA);
    }
    else
    {
        return;
    }
    for (int y = 0; y < image_canny.rows; ++y)
    {
        for (int x = 0; x < image_canny.cols; ++x)
        {
            cv::Vec4b & pixel = image_canny.at<cv::Vec4b>(y, x);
            if (pixel[0] == 255 && pixel[1] == 255 && pixel[2] == 255)
            {
                pixel[3] = 0;
            }
        }
    }
    
    UIImage *newImage = MatToUIImage(image_canny);
    
    [self.imageSticker removeFromSuperview];
    self.imageSticker.imageView.image = newImage;
    [self.view addSubview:self.imageSticker];
            
}

//从UIImage对象转换为4通道的Mat，即是原图的Mat
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,
                                                    cols,
                                                    rows,
                                                    8,
                                                    cvMat.step[0],
                                                    colorSpace,
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault);
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

- (IBAction)jumpCropView:(id)sender {
}

@end
