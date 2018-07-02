//
//  YDPhotoBrowser.h
//  HelloDemo
//
//  Created by 杨雨东 on 2018/6/26.
//  Copyright © 2018 杨雨东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDPhotoScrollView.h"

@class YDPhotoBrowser;
@protocol YDPhotoBrowserDelegate <NSObject>
- (YDPhoto *)photoBrowser:(YDPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
- (NSInteger)numberOfPagesInPhotoBrowser:(YDPhotoBrowser *)photoBrowser;

@optional
- (UIImageView *)photoBrowser:(YDPhotoBrowser *)photoBrowser showFromIndex:(NSInteger)fromIndex;
- (UIImageView *)photoBrowser:(YDPhotoBrowser *)photoBrowser hideToIndex:(NSInteger)toIndex;
- (void)photoBrowser:(YDPhotoBrowser *)photoBrowser longPressImage:(UIImage *)pressImage;
@end

@interface YDPhotoBrowser : UIView
@property (nonatomic,weak)id <YDPhotoBrowserDelegate> delegate;

/**
 是否显示 pageControl
 */
@property (nonatomic)BOOL pageControlHidden;

/**
 滑动消失
 */
@property (nonatomic)BOOL panToDismiss;


/**
 个性化消失效果
 */
@property (nonatomic)BOOL enableCustomDismiss;

/**
 刷新界面，必须调该方法才能把界面显示出来
 */
- (void)reloadData;

/**
 控制器选择时需要调用该方法

 @param toInterfaceOrientation 选择到的方向
 @param duration 时间
 */
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
@end
