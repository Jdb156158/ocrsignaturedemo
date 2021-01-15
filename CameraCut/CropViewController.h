//
//  CropViewController.h
//  ImageScanner
//
//  Created by db J on 2021/1/15.
//

#import <UIKit/UIKit.h>
#import "UIImage+fixOrientation.h"
#import "UIImageView+ContentFrame.h"

NS_ASSUME_NONNULL_BEGIN

@class CropViewController;
@protocol MMCropDelegate <NSObject>

-(void)didFinishCropping:(UIImage *)finalCropImage from:(CropViewController *)cropObj;

@end
@interface CropViewController : UIViewController{
    CGFloat _rotateSlider;
    CGRect _initialRect,final_Rect;
}

@property (weak,nonatomic) id<MMCropDelegate> cropdelegate;
@property (strong, nonatomic) UIImageView *sourceImageView;
@property (strong, nonatomic) UIImage *adjustedImage,*cropgrayImage,*cropImage;

@end

NS_ASSUME_NONNULL_END
