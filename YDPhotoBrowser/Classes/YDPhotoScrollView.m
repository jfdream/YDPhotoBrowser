//
//  YDPhotoScrollView.m
//  HelloDemo
//
//  Created by 杨雨东 on 2018/6/26.
//  Copyright © 2018 杨雨东. All rights reserved.
//

#import "YDPhotoScrollView.h"
#import "UIImageView+WebCache.h"
#import "Masonry.h"
#import "SVProgressHUD.h"

@implementation YDPhoto

@end


static NSString * MWPHOTO_PROGRESS_NOTIFICATION = @"MWPHOTO_PROGRESS_NOTIFICATION";

@interface YDPhotoScrollView()<UIScrollViewDelegate,UIGestureRecognizerDelegate>
{
    CGRect _lastScreenBounds;
}
@property (nonatomic,strong)UIActivityIndicatorView * indicatorView;
@property (nonatomic,strong)UIImageView * imageView;
@end

@implementation YDPhotoScrollView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _lastScreenBounds = [UIScreen mainScreen].bounds;
        [self addSubview:self.imageView];

        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView.userInteractionEnabled = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setProgressFromNotification:)
                                                     name:MWPHOTO_PROGRESS_NOTIFICATION
                                                   object:nil];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.maximumZoomScale = 2;
        _indicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        [self.imageView addSubview:_indicatorView];
        _indicatorView.hidesWhenStopped = YES;
        
        UILongPressGestureRecognizer * longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressGestureClick:)];
        [self.imageView addGestureRecognizer:longPressGesture];
        
        
        UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureClick:)];
        tapGesture.numberOfTapsRequired = 1;
        [self.imageView addGestureRecognizer:tapGesture];
        
        UITapGestureRecognizer * doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureClick:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        [self.imageView addGestureRecognizer:doubleTapGesture];
        
        [tapGesture requireGestureRecognizerToFail:doubleTapGesture];
        
    }
    return self;
}
-(void)longPressGestureClick:(UILongPressGestureRecognizer *)longPress{
    if ([_tapDelegate respondsToSelector:@selector(view:longPressTapDetected:)]) {
        [_tapDelegate view:self longPressTapDetected:longPress];
    }
}
-(void)tapGestureClick:(UITapGestureRecognizer *)tapGesture{
    if (tapGesture.numberOfTapsRequired == 1) {
        if ([_tapDelegate respondsToSelector:@selector(view:singleTapDetected:)])
            [_tapDelegate view:self singleTapDetected:tapGesture];
    }
    else{
        if ([_tapDelegate respondsToSelector:@selector(view:doubleTapDetected:)])
            [_tapDelegate view:self doubleTapDetected:tapGesture];
        if (self.zoomScale >= 2) {
            [self setZoomScale:1.f animated:YES];
        }
        else{
            [self setZoomScale:(self.zoomScale + 1.f) animated:YES];
        }
    }
}
-(void)setProgressFromNotification:(NSNotification *)notification{
    
}
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
-(void)setPhoto:(YDPhoto *)photo{
    _photo = photo;
    if (photo.resource) {
        self.imageView.image = photo.resource;
        return;
    }
    UIImage * placeholderImage;
    UIImage * resource;
    if (photo.thumbnail) {
        placeholderImage = photo.thumbnail;
        resource = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:photo.resourceURL.absoluteString];
    }
    else{
        placeholderImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:photo.thumbnailURL.absoluteString];
        resource = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:photo.resourceURL.absoluteString];
    }
    if (resource) {
        self.imageView.image = resource;
    }
    else{
        if (photo.resourceURL) {
            if ([photo.resourceURL.scheme containsString:@"file"]) {
                self.imageView.image = [UIImage imageWithContentsOfFile:photo.resourceURL.absoluteString];
            }
            else{
                _indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                [_indicatorView startAnimating];
                [self.imageView sd_setImageWithURL:photo.resourceURL placeholderImage:placeholderImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    if (error) {
                        [SVProgressHUD showErrorWithStatus:@"加载失败"];
                        [SVProgressHUD dismissWithDelay:2];
                    }
                    [self->_indicatorView stopAnimating];
                }];
            }
        }
        else{
            self.imageView.image = placeholderImage;
        }
    }
}
-(UIImageView *)imageView{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    }
    return _imageView;
}
- (void)layoutSubviews {
    // Position indicators (centre does not seem to work!)
    [super layoutSubviews];
    CGSize boundsSize = self.bounds.size;
    if (_lastScreenBounds.size.width != [UIScreen mainScreen].bounds.size.width) {
        // 旋转
        _imageView.frame = [UIScreen mainScreen].bounds;
        _lastScreenBounds = _imageView.frame;
        self.contentSize = self.imageView.frame.size;
        _indicatorView.center = CGPointMake(_imageView.frame.size.width/2, _imageView.frame.size.height/2);
        return;
    }
    CGRect frameToCenter = _imageView.frame;
    // Horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    // Vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    if (!CGRectEqualToRect(_imageView.frame, frameToCenter))
    {
        _imageView.frame = frameToCenter;
    }
}
-(UIImage *)image{
    return self.imageView.image;
}
@end
