//
//  YDPhotoBrowser.h
//  HelloDemo
//
//  Created by 杨雨东 on 2018/6/26.
//  Copyright © 2018 杨雨东. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YDPhotoScrollView.h"
#import "YDPhotoBrowserPresentationController.h"


// 请不要以全局变量的方式持有本类对象，由于该对象是一个 UIViewController，直接全局持有会导致对象的释放（内存泄露），也会导致内部视频无法播放

@class YDPhotoBrowser;
@protocol YDPhotoBrowserDelegate <NSObject>
- (YDPhoto *)photoBrowser:(YDPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index;
- (NSInteger)numberOfPagesInPhotoBrowser:(YDPhotoBrowser *)photoBrowser;
- (UIViewController *)photoBrowserParentViewController;
- (NSInteger)startIndexOfPagesInPhotoBrowser:(YDPhotoBrowser *)photoBrowser;
@optional
- (UIImageView *)photoBrowser:(YDPhotoBrowser *)photoBrowser showFromIndex:(NSInteger)fromIndex;
- (UIImageView *)photoBrowser:(YDPhotoBrowser *)photoBrowser hideToIndex:(NSInteger)toIndex;

/**
 如果从 cell 点击图片的话需要实现下面方法，否则默认从普通视图展示

 @param photoBrowser 本类实例
 @param fromIndex 从第几张照片开始显示
 @return 返回当前 cell 所处的 index Path
 */
- (NSIndexPath *)photoBrowser:(YDPhotoBrowser *)photoBrowser showFromIndexFromCell:(NSInteger)fromIndex;

/**
 如果需要消失到对应的 cell 中需要实现下面代理方法

 @param photoBrowser 本类实例
 @param toIndex 从第几张照片消失
 @return 返回消失的 cell 所处的 indexPath
 */
- (NSIndexPath *)photoBrowser:(YDPhotoBrowser *)photoBrowser hideToIndexFromCell:(NSInteger)toIndex;
- (void)photoBrowser:(YDPhotoBrowser *)photoBrowser longPressImage:(UIImage *)pressImage;
@end

@interface YDPhotoBrowser : UIViewController
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
@end
