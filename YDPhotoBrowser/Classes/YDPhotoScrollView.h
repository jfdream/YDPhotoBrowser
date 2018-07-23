//
//  YDPhotoScrollView.h
//  HelloDemo
//
//  Created by 杨雨东 on 2018/6/26.
//  Copyright © 2018 杨雨东. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    YDResourceTypePhoto,
    YDResourceTypeVideo
} YDResourceType;

@interface YDPhoto : NSObject

/**
 缩略图图片，如果存在会忽视（thumbnailURL）
 */
@property (nonatomic,strong)UIImage * thumbnail;

/**
 原图图片，如果存在会忽视（resourceURL）
 */
@property (nonatomic,strong)UIImage * resource;
/**
 缩略图资源路径，支持图片，视频（支持本地文件和远程文件）
 */
@property (nonatomic,strong)NSURL * thumbnailURL;
/**
 原始图片资源路径，支持图片，视频（支持本地文件和远程文件）
 */
@property (nonatomic,strong)NSURL * resourceURL;

/**
 图片宽高
 */
@property (nonatomic)CGSize photoSize;

/**
 资源类型，是否图片或视频
 */
@property (nonatomic)YDResourceType type;

/**
 视频标题
 */
@property (nonatomic,strong)NSString * videoTitle;

@end


@protocol YDPhotoScrollViewDelegate <NSObject>
@optional
- (void)view:(UIView *)view singleTapDetected:(UITapGestureRecognizer *)tapGesture;
- (void)view:(UIView *)view doubleTapDetected:(UITapGestureRecognizer *)touch;
- (void)view:(UIView *)view longPressTapDetected:(UILongPressGestureRecognizer *)touch;
@end

#define PADDING                  10
@interface YDPhotoScrollView : UIScrollView
@property (nonatomic,strong) YDPhoto * photo;
@property (nonatomic)NSInteger index;
@property (nonatomic,weak)id <YDPhotoScrollViewDelegate> tapDelegate;
@property (nonatomic,strong,readonly) UIImage * image;
-(void)viewDidDisappear;
@end
