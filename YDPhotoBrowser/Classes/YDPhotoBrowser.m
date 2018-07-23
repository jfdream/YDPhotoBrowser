//
//  YDPhotoBrowser.m
//  HelloDemo
//
//  Created by 杨雨东 on 2018/6/26.
//  Copyright © 2018 杨雨东. All rights reserved.
//

#import "YDPhotoBrowser.h"
#import "Masonry.h"
#import "YDPhotoManager.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerController.h"
#import "ZFPlayerControlView.h"
#import "ZFUtilities.h"
#import "YDPhotoBrowserPresentationController.h"
#define MAX_SHOW_NUMBER          5
#define MAX_DURATION             0.3
@implementation UIDevice(JFDREAM)
+ (BOOL)isX {
    if ([UIScreen mainScreen].bounds.size.height == 812) {
        return YES;
    }
    return NO;
}
@end

@interface YDPhotoBrowser()<UIScrollViewDelegate,YDPhotoScrollViewDelegate,YDPhotoManagerDelegate>
@property (nonatomic,strong)UIScrollView * pagingScrollView;
@end
@implementation YDPhotoBrowser
{
    NSMutableArray <YDPhotoScrollView *>* _recyclePhotos;
    ;
    NSInteger _totalPage;
    NSInteger _currentIndex;
    NSInteger _lastCurrentIndex;
    CGRect _screenFrame;
    BOOL _isRotate;
    
    CGPoint _panGestureStartPoint;
    NSInteger _currentLoadMaxIndex;
    NSInteger _currentLoadMinIndex;
    
    UIPageControl * pageControl;
    UIImageView * _topImageView;

    UIActivityIndicatorView * _indicatorView;
    BOOL isPaning;
    UIViewController * _parentViewController;
    CGRect _frameOfPresentedViewInContainerView;
    CGRect _frameOfPresentedViewInContainerViewOrigin;
    BOOL _isEnlarge;
    BOOL _isEnlargeFinish;
    BOOL _isPlaying;
    CGSize _videoSize;
    
    UIView * _containerViewSupper;
    
}
-(id)init{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor blackColor];
        
        _recyclePhotos = [NSMutableArray new];
        _pagingScrollView = [[UIScrollView alloc] init];_pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _pagingScrollView.pagingEnabled = YES;
        _pagingScrollView.delegate = self;
        _pagingScrollView.hidden = YES;
        _pagingScrollView.showsHorizontalScrollIndicator = NO;
        _pagingScrollView.showsVerticalScrollIndicator = NO;
        _pagingScrollView.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_pagingScrollView];

        [_pagingScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(-PADDING));
            make.right.equalTo(self.view).offset(PADDING);
            make.height.equalTo(self.view);
            make.top.equalTo(self.view);
        }];

        pageControl = [[UIPageControl alloc]init];
        [self.view addSubview:pageControl];
        [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.view).offset(-15);
            make.centerX.mas_equalTo(self.view);
            make.width.equalTo(self.view);
            make.height.mas_equalTo(20);
        }];
        _topImageView = [[UIImageView alloc]init];
        _topImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:_topImageView];
    }
    return self;
}
-(void)view:(UIView *)view doubleTapDetected:(UITapGestureRecognizer *)touch{
    
}
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch{
    if (isPaning) {
        isPaning = NO;
        return;
    }
    if (self.enableCustomDismiss) {
        NSMutableArray * subViews = [NSMutableArray new];
        NSMutableArray <NSValue *>* rects = [NSMutableArray new];
        for (NSInteger i=0; i<4; i++) {
            CGFloat width = self.view.frame.size.width;
            CGFloat height = self.view.frame.size.height;
            UIView * aView = [self.view resizableSnapshotViewFromRect:CGRectMake(width/2*(i%2), height/2*(i/2), width/2, height/2) afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
            aView.frame = CGRectMake(width/2*(i%2), height/2*(i/2), width/2, height/2);
            if (i==0) {
                CGRect frame = CGRectMake(-width/2, -height/2, width/2, height/2);
                [rects addObject:[NSValue valueWithCGRect:frame]];
                [subViews addObject:aView];
            }
            else if (i==1){
                CGRect frame = CGRectMake(width + width/2, -height/2, width/2, height/2);
                [rects addObject:[NSValue valueWithCGRect:frame]];
                [subViews addObject:aView];
            }
            else if (i==2){
                CGRect frame = CGRectMake(-width/2, height+height/2, width/2, height/2);
                [rects addObject:[NSValue valueWithCGRect:frame]];
                [subViews addObject:aView];
            }
            else{
                CGRect frame = CGRectMake(width + width/2, height+height/2, width/2, height/2);
                [rects addObject:[NSValue valueWithCGRect:frame]];
                [subViews addObject:aView];
            }
            [[UIApplication sharedApplication].delegate.window addSubview:aView];
        }
        self.view.hidden = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
        [UIView animateWithDuration:MAX_DURATION animations:^{
            for (NSInteger i=0; i<4; i++) {
                UIView * aView = subViews[i];
                aView.frame = [rects[i] CGRectValue];
            }
        }];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(photoBrowser:hideToIndex:)]) {
        UIImageView * hiddenImageView = [self.delegate photoBrowser:self hideToIndex:_currentIndex];
        [_topImageView removeFromSuperview];
        [self.view.window addSubview:_topImageView];
        _topImageView.image = hiddenImageView.image;
        _topImageView.hidden = NO;
        self.view.hidden = YES;
        CGRect frame = [hiddenImageView.superview convertRect:hiddenImageView.frame toView:self.view];
        if ([self.delegate respondsToSelector:@selector(photoBrowser:hideToIndexFromCell:)]) {
            NSIndexPath * indexPath = [self.delegate photoBrowser:self hideToIndexFromCell:_currentIndex];
            id cell = hiddenImageView.superview;
            UITableViewCell * tableViewCell;
            if ([cell isKindOfClass:[UITableViewCell class]]) {
                // imageView In cell
                tableViewCell = (UITableViewCell *)cell;
            }
            else if ([hiddenImageView.superview.superview isKindOfClass:[UITableViewCell class]]){
                // imageView In contentView;
                tableViewCell = (UITableViewCell *)hiddenImageView.superview.superview;
            }
            if (tableViewCell) {
                UITableView * tableView = (UITableView *)tableViewCell.superview;
                // cell in window rect
                CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
                rect = [tableView convertRect:rect toView:self.view.window];
                CGPoint origin = CGPointMake(rect.origin.x + hiddenImageView.frame.origin.x, rect.origin.y + hiddenImageView.frame.origin.y);
                CGSize size = hiddenImageView.frame.size;
                frame.size = size;
                frame.origin = origin;
            }
        }
        [UIView animateWithDuration:MAX_DURATION animations:^{
            self->_topImageView.frame = frame;
            [YDPhotoManager sharedManager].containerView.frame = frame;
        } completion:^(BOOL finished) {
            [self->_topImageView removeFromSuperview];
            [[YDPhotoManager sharedManager] shutdown];
        }];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
-(void)setPanToDismiss:(BOOL)panToDismiss{
    _panToDismiss = panToDismiss;
    if (_panToDismiss) {
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureClick:)];
        [self.view addGestureRecognizer:panGesture];
    }
}
-(void)panGestureClick:(UIPanGestureRecognizer *)gestureRecognizer{
    isPaning = YES;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        _isPlaying = NO;
        if ([YDPhotoManager sharedManager].playerManager.isPlaying) {
            _containerViewSupper = [YDPhotoManager sharedManager].containerView.superview;
            [[YDPhotoManager sharedManager].containerView removeFromSuperview];
            self.view.hidden = YES;
            CGRect frame;
            _isPlaying = YES;
            _videoSize = [YDPhotoManager sharedManager].playerManager.presentationSize;
            _videoSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width * _videoSize.height / _videoSize.width);
            frame.size = _videoSize;
            [YDPhotoManager sharedManager].containerView.frame = frame;
            [YDPhotoManager sharedManager].containerView.center = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
            [self.view.window addSubview:[YDPhotoManager sharedManager].containerView];
        }
        else{
            [_topImageView removeFromSuperview];
            [self.view.window addSubview:_topImageView];
            self.view.hidden = YES;
            for (YDPhotoScrollView * _scrollView in _pagingScrollView.subviews) {
                if (_scrollView.index == _currentIndex) {
                    _topImageView.image = _scrollView.image;
                }
            }
            _topImageView.hidden = NO;
        }
        _panGestureStartPoint = [gestureRecognizer locationInView:self.view];
    }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint currentPoint = [gestureRecognizer locationInView:self.view];
        CGFloat offsetY = currentPoint.y - _panGestureStartPoint.y;
        CGFloat offsetX = currentPoint.x - _panGestureStartPoint.x;
        CGPoint centerPoint = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        centerPoint.x += offsetX;
        centerPoint.y += offsetY;
        CGSize imageSize = [UIScreen mainScreen].bounds.size;
        if ([YDPhotoManager sharedManager].playerManager.isPlaying) {
            imageSize = _videoSize;
        }
        if (offsetY > 0) {
            imageSize.height -= offsetY;
            if (_isPlaying) {
                imageSize.width -= offsetY * (_videoSize.width / _videoSize.height);
            }
            else{
                imageSize.width -= offsetY * ([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height);
            }
        }
        CGRect frame = CGRectMake(centerPoint.x - imageSize.width/2, centerPoint.y - imageSize.height/2, imageSize.width, imageSize.height);
        YDPhotoBrowserPresentationController * _presentationController = (YDPhotoBrowserPresentationController *)self.presentationController;
        [UIView animateWithDuration:0.1 animations:^{
            self->_topImageView.frame = frame;
            [YDPhotoManager sharedManager].containerView.frame = frame;
            if (offsetY<=0) {
                _presentationController.dimmingView.alpha = 1.f;
            }
            else{
                CGFloat alpha = (1 - offsetY/180.f);
                if (alpha<0) {
                    alpha = 0.f;
                }
                _presentationController.dimmingView.alpha = alpha;
            }
        }];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint currentPoint = [gestureRecognizer locationInView:self.view];
        CGFloat offsetY = currentPoint.y - _panGestureStartPoint.y;
        if (offsetY > 180) {
            [UIView animateWithDuration:0.3 animations:^{
                self->_topImageView.alpha = 0.f;
                [YDPhotoManager sharedManager].containerView.alpha = 0.f;
            } completion:^(BOOL finished) {
                [self->_topImageView removeFromSuperview];
                [[YDPhotoManager sharedManager] shutdown];
            }];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            [UIView animateWithDuration:0.3 animations:^{
                self->_topImageView.frame = [UIScreen mainScreen].bounds;
                [YDPhotoManager sharedManager].containerView.frame = [UIScreen mainScreen].bounds;
            } completion:^(BOOL finished) {
                self.view.hidden = NO;
                self->_topImageView.hidden = YES;
                [[YDPhotoManager sharedManager].containerView removeFromSuperview];
                [self->_containerViewSupper addSubview:[YDPhotoManager sharedManager].containerView];
            }];
        }
        isPaning = NO;
    }
}
-(void)setPageControlHidden:(BOOL)pageControlHidden{
    _pageControlHidden = pageControlHidden;
    pageControl.hidden = pageControlHidden;
}
-(void)videoCloseButtonClick{
    [self view:nil singleTapDetected:nil];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_isRotate)  return;
    _currentIndex = scrollView.contentOffset.x / (_screenFrame.size.width + 2*PADDING);
    pageControl.currentPage = _currentIndex;
    if (_lastCurrentIndex == _currentIndex)  return;
    [self judgeViewWillDisappear];
    _lastCurrentIndex = _currentIndex;
    [self reusePages];
}
-(void)judgeViewWillDisappear{
    for (YDPhotoScrollView * _scrollView in _recyclePhotos) {
        if (_scrollView.index == _lastCurrentIndex) {
            [_scrollView viewDidDisappear];
            break;
        }
    }
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[YDPhotoManager sharedManager] shutdown];
}
-(void)reusePages{
    if ((_currentIndex + 1) > _currentLoadMaxIndex && (_currentIndex + 1) < _totalPage) {
        _currentLoadMaxIndex = (_currentLoadMaxIndex + 1);
        YDPhoto * photo = [self.delegate photoBrowser:self photoAtIndex:_currentLoadMaxIndex];
        YDPhotoScrollView * _scrollView = _recyclePhotos.firstObject;
        [_recyclePhotos removeObjectAtIndex:0];
        [_recyclePhotos addObject:_scrollView];
        _scrollView.photo = photo;
        _scrollView.frame = [self frameForPageAtIndex:_currentLoadMaxIndex];
        _scrollView.index = _currentLoadMaxIndex;
        _currentLoadMinIndex = (_currentLoadMinIndex + 1);
    }
    
    if ((_currentIndex - 1) < _currentLoadMinIndex && (_currentIndex - 1) >= 0) {
        _currentLoadMinIndex = _currentLoadMinIndex - 1;
        YDPhoto * photo = [self.delegate photoBrowser:self photoAtIndex:_currentLoadMinIndex];
        YDPhotoScrollView * _scrollView = _recyclePhotos.lastObject;
        [_recyclePhotos removeLastObject];
        [_recyclePhotos insertObject:_scrollView atIndex:0];
        _scrollView.photo = photo;
        _scrollView.frame = [self frameForPageAtIndex:_currentLoadMinIndex];
        _scrollView.index = _currentLoadMinIndex;
        _currentLoadMaxIndex = (_currentLoadMaxIndex - 1);
    }
}
- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect bounds = _screenFrame;
    bounds.size.width += (2 * PADDING);
    CGRect pageFrame = bounds;
    pageFrame.size.width = _screenFrame.size.width;
    pageFrame.origin.x = (bounds.size.width * index) + PADDING;
    return CGRectIntegral(pageFrame);
}
-(void)view:(UIView *)view longPressTapDetected:(UILongPressGestureRecognizer *)touch{
    YDPhotoScrollView * _scrollView = (YDPhotoScrollView *)view;
    if ([self.delegate respondsToSelector:@selector(photoBrowser:longPressImage:)]) {
        [self.delegate photoBrowser:self longPressImage:_scrollView.image];
    }
}
-(BOOL)shouldAutorotate{
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}

-(void)reloadData{
    if (![self.delegate respondsToSelector:@selector(photoBrowserParentViewController)]) {
        @throw @"You must initialize parentViewController method!";
    }
    _parentViewController = [self.delegate photoBrowserParentViewController];
    [YDPhotoManager sharedManager].delegate = self;
    YDPhotoBrowserPresentationController * presentationController = [[YDPhotoBrowserPresentationController alloc]initWithPresentedViewController:self presentingViewController:_parentViewController];
    self.transitioningDelegate = presentationController;
    [_parentViewController presentViewController:self animated:YES completion:nil];

    _totalPage = [self.delegate numberOfPagesInPhotoBrowser:self];
    _screenFrame = [UIScreen mainScreen].bounds;
    _pagingScrollView.contentSize = CGSizeMake((_screenFrame.size.width + 2*PADDING) * _totalPage, _screenFrame.size.height);
    NSInteger showNumber = _totalPage;
    pageControl.numberOfPages = _totalPage;
    if (_totalPage>5) {
        showNumber = 5;
    }
    if ([self.delegate respondsToSelector:@selector(startIndexOfPagesInPhotoBrowser:)]) {
        _currentIndex = [self.delegate startIndexOfPagesInPhotoBrowser:self];
    }
    else{
        _currentIndex = 0;
    }
    _currentLoadMinIndex = 0;
    _currentLoadMaxIndex = (showNumber - 1);
    for (NSInteger i=0; i<showNumber; i++) {
        YDPhoto * photo = [self.delegate photoBrowser:self photoAtIndex:i];
        CGRect frame = [self frameForPageAtIndex:i];
        YDPhotoScrollView * _photoScrollView = [[YDPhotoScrollView alloc]initWithFrame:frame];
        _photoScrollView.photo = photo;
        _photoScrollView.index = i;
        _photoScrollView.tapDelegate = self;

        [_pagingScrollView addSubview:_photoScrollView];
        [_recyclePhotos addObject:_photoScrollView];
    }
    if (_currentIndex != 0) {
        CGFloat xOffset = (_screenFrame.size.width + 2*PADDING) * _currentIndex;
        _pagingScrollView.contentOffset = CGPointMake(xOffset, 0);
        [self reusePages];
    }
    if([self.delegate respondsToSelector:@selector(photoBrowser:showFromIndex:)]){
        UIWindow * topWindow = [UIApplication sharedApplication].delegate.window;
        UIImageView * fromImageView = [self.delegate photoBrowser:self showFromIndex:_currentIndex];
        CGRect frame = [fromImageView.superview convertRect:fromImageView.frame toView:topWindow];

        if ([self.delegate respondsToSelector:@selector(photoBrowser:showFromIndexFromCell:)]) {
            NSIndexPath * indexPath = [self.delegate photoBrowser:self showFromIndexFromCell:_currentIndex];
            id cell = fromImageView.superview;
            UITableViewCell * tableViewCell;
            if ([cell isKindOfClass:[UITableViewCell class]]) {
                // imageView In cell
                tableViewCell = (UITableViewCell *)cell;
            }
            else if ([fromImageView.superview.superview isKindOfClass:[UITableViewCell class]]){
                // imageView In contentView;
                tableViewCell = (UITableViewCell *)fromImageView.superview.superview;
            }
            if (tableViewCell) {
                UITableView * tableView = (UITableView *)tableViewCell.superview;
                // cell in window rect
                CGRect rect = [tableView rectForRowAtIndexPath:indexPath];
                rect = [tableView convertRect:rect toView:topWindow];
                CGPoint origin = CGPointMake(rect.origin.x + fromImageView.frame.origin.x, rect.origin.y + fromImageView.frame.origin.y);
                CGSize size = fromImageView.frame.size;
                frame.size = size;
                frame.origin = origin;
            }
        }
        _topImageView.image = fromImageView.image;
        _topImageView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        _frameOfPresentedViewInContainerView = frame;
        _frameOfPresentedViewInContainerViewOrigin = frame;
        self.preferredContentSize = frame.size;
    }
}
-(CGRect)frameOfPresentedViewInContainerView{
    return _frameOfPresentedViewInContainerView;
}
-(void)enlargePrepare{
    self.preferredContentSize = [UIScreen mainScreen].bounds.size;
    _frameOfPresentedViewInContainerView = [UIScreen mainScreen].bounds;
    _isEnlarge = YES;
}
-(void)enlargeToFullScreen{
    if (_isEnlarge && !_isEnlargeFinish) {
        _topImageView.frame = _frameOfPresentedViewInContainerViewOrigin;
        [UIView animateWithDuration:0.3 animations:^{
            self->_topImageView.frame = [UIScreen mainScreen].bounds;
        } completion:^(BOOL finished) {
            self->_topImageView.hidden = YES;
            self->_pagingScrollView.hidden = NO;
        }];
        _isEnlargeFinish = YES;
    }
}
-(BOOL)isEnlarge{
    return _isEnlarge;
}
-(void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    CGSize size = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    _frameOfPresentedViewInContainerView = CGRectMake(0, 0, 0, 0);
    _frameOfPresentedViewInContainerView.size = size;
    self.preferredContentSize = size;
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _isRotate = YES;
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _screenFrame = [UIScreen mainScreen].bounds;
    self->_topImageView.frame = _screenFrame;
    _pagingScrollView.contentSize = CGSizeMake((_screenFrame.size.width + 2*PADDING) * _totalPage, _screenFrame.size.height);
    NSArray <YDPhotoScrollView *> * subViews = _pagingScrollView.subviews;
    for (YDPhotoScrollView * _scrollView in subViews) {
        CGRect frame = [self frameForPageAtIndex:_scrollView.index];
        _scrollView.frame = frame;
    }
    CGFloat xOffset = (_screenFrame.size.width + 2*PADDING) * _currentIndex;
    _pagingScrollView.contentOffset = CGPointMake(xOffset, 0);
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    _isRotate = NO;
}
@end
