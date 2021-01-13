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


@interface ViewController (){
    cv::Mat cvImage;
    cv::Mat image_canny;
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
        [self changeImageBg2:image];
    };
    [self.navigationController pushViewController:scVC animated:YES];
}

- (void)changeImageBg2:(UIImage *)image{
    
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
    self.ImageView.image = newImage;
            
}

- (void)changeImageBg:(UIImage *)image{

    UIImageToMat(image, cvImage);
    //1:先灰度处理
    /*
     参数解释：
     InputArray src –-输入图像即要进行颜色空间变换的原图像，可以是Mat类
     OutputArray dst –-输出图像即进行颜色空间变换后存储图像，也可以Mat类
     int code –-转换的代码或标识
     int dstCn = 0 –-目标图像通道数，如果取值为0，则由src和code决定
     */
    cv::cvtColor(cvImage, cvImage, CV_RGB2GRAY);
    //2:二值化
    /*
     参数：

     　　_src  　　　　要二值化的灰度图
     　　_dst  　　　　二值化后的图
     　　maxValue　　二值化后要设置的那个值
     　　method　　　块计算的方法（ADAPTIVE_THRESH_MEAN_C 平均值，ADAPTIVE_THRESH_GAUSSIAN_C 高斯分布加权和）
     　　type　　　　  二值化类型（CV_THRESH_BINARY 大于为最大值，CV_THRESH_BINARY_INV 小于为最大值）
     　　blockSize　　块大小（奇数，大于1）
     　　delta 　　　　差值（负值也可以）
     */
    cv::adaptiveThreshold(cvImage, cvImage, 255, CV_ADAPTIVE_THRESH_GAUSSIAN_C, CV_THRESH_BINARY, 31, 40);

    UIImage *newImage = MatToUIImage(cvImage);
    
    self.ImageView.image = newImage;
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


@end
