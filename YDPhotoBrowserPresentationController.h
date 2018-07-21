//
//  YDPhotoBrowserPresentationController.h
//  YDPhotoBrowser
//
//  Created by 杨雨东 on 2018/7/20.
//

#import <UIKit/UIKit.h>

@interface YDPhotoBrowserPresentationController : UIPresentationController <UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) UIView *dimmingView;

@end
