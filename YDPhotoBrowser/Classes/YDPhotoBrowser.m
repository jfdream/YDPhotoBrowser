//
//  YDPhotoBrowser.m
//  HelloDemo
//
//  Created by 杨雨东 on 2018/6/26.
//  Copyright © 2018 杨雨东. All rights reserved.
//

#import "YDPhotoBrowser.h"
#import "Masonry.h"
#define MAX_SHOW_NUMBER          5

@implementation UIDevice(JFDREAM)
+ (BOOL)isX {
    if ([UIScreen mainScreen].bounds.size.height == 812) {
        return YES;
    }
    return NO;
}
@end

@interface YDPhotoBrowser()<UIScrollViewDelegate,YDPhotoScrollViewDelegate>
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
    UIView * _topView;
    UIActivityIndicatorView * _indicatorView;
    BOOL isPaning;
    
}
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        _recyclePhotos = [NSMutableArray new];
        _pagingScrollView = [[UIScrollView alloc] init];_pagingScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _pagingScrollView.pagingEnabled = YES;
        _pagingScrollView.delegate = self;
        _pagingScrollView.showsHorizontalScrollIndicator = NO;
        _pagingScrollView.showsVerticalScrollIndicator = NO;
        _pagingScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:_pagingScrollView];
        
        [_pagingScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(-PADDING));
            make.right.equalTo(self).offset(PADDING);
            make.height.equalTo(self);
            make.top.equalTo(self);
        }];
        
        pageControl = [[UIPageControl alloc]init];
        [self addSubview:pageControl];
        [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self).offset(-15);
            make.centerX.mas_equalTo(self);
            make.width.equalTo(self);
            make.height.mas_equalTo(20);
        }];
    }
    return self;
}
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch{
    if (isPaning) {
        isPaning = NO;
        return;
    }
    if (self.enableCustomDismiss) {
        [_topView removeFromSuperview];
        NSMutableArray * subViews = [NSMutableArray new];
        NSMutableArray <NSValue *>* rects = [NSMutableArray new];
        for (NSInteger i=0; i<4; i++) {
            CGFloat width = self.frame.size.width;
            CGFloat height = self.frame.size.height;
            UIView * aView = [self resizableSnapshotViewFromRect:CGRectMake(width/2*(i%2), height/2*(i/2), width/2, height/2) afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
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
        self.hidden = YES;
        [UIView animateWithDuration:0.5 animations:^{
            for (NSInteger i=0; i<4; i++) {
                UIView * aView = subViews[i];
                aView.frame = [rects[i] CGRectValue];
            }
        }];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(photoBrowser:hideToIndex:)]) {
        UIImageView * hiddenImageView = [self.delegate photoBrowser:self hideToIndex:_currentIndex];
        _topImageView.image = hiddenImageView.image;
        _topView.hidden = NO;
        _topImageView.hidden = NO;
        self.hidden = YES;
        CGRect frame = [hiddenImageView.superview convertRect:hiddenImageView.frame toView:[UIApplication sharedApplication].delegate.window];
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
                CGPoint origin = CGPointMake(rect.origin.x + hiddenImageView.frame.origin.x, rect.origin.y + hiddenImageView.frame.origin.y);
                CGSize size = hiddenImageView.frame.size;
                frame.size = size;
                frame.origin = origin;
                CGFloat originX = [UIDevice isX]?88:64;
                frame.origin.y += originX;
            }

        }
        [UIView animateWithDuration:0.3 animations:^{
            self->_topImageView.frame = frame;
            self->_topView.alpha = 0.f;
        } completion:^(BOOL finished) {
            [self->_topView removeFromSuperview];
            [self->_topImageView removeFromSuperview];
        }];
    }
    else{
        self.hidden = YES;
    }
}
-(void)setPanToDismiss:(BOOL)panToDismiss{
    _panToDismiss = panToDismiss;
    if (_panToDismiss) {
        UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureClick:)];
        [self addGestureRecognizer:panGesture];
    }
}
-(void)panGestureClick:(UIPanGestureRecognizer *)gestureRecognizer{
    isPaning = YES;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        self.hidden = YES;
        for (YDPhotoScrollView * _scrollView in _pagingScrollView.subviews) {
            if (_scrollView.index == _currentIndex) {
                _topImageView.image = _scrollView.image;
            }
        }
        _topView.hidden = NO;
        _topImageView.hidden = NO;
        _panGestureStartPoint = [gestureRecognizer locationInView:self];
    }else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint currentPoint = [gestureRecognizer locationInView:self];
        CGFloat offsetY = currentPoint.y - _panGestureStartPoint.y;
        CGFloat offsetX = currentPoint.x - _panGestureStartPoint.x;
        CGPoint centerPoint = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
        centerPoint.x += offsetX;
        centerPoint.y += offsetY;
        CGSize imageSize = [UIScreen mainScreen].bounds.size;
        if (offsetY > 0) {
            imageSize.height -= offsetY;
            imageSize.width -= offsetY * ([UIScreen mainScreen].bounds.size.width / [UIScreen mainScreen].bounds.size.height);
        }
        CGRect frame = CGRectMake(centerPoint.x - imageSize.width/2, centerPoint.y - imageSize.height/2, imageSize.width, imageSize.height);
        [UIView animateWithDuration:0.1 animations:^{
            self->_topImageView.frame = frame;
            if (offsetY<=0) {
                self->_topView.alpha = 1.f;
            }
            else{
                CGFloat alpha = (1 - offsetY/180.f);
                if (alpha<0) {
                    alpha = 0.f;
                }
                self->_topView.alpha = alpha;
            }
        }];
    }
    else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint currentPoint = [gestureRecognizer locationInView:self];
        CGFloat offsetY = currentPoint.y - _panGestureStartPoint.y;
        if (offsetY > 180) {
            [self removeFromSuperview];
            [UIView animateWithDuration:0.3 animations:^{
                self->_topImageView.alpha = 0.f;
            } completion:^(BOOL finished) {
                [self->_topView removeFromSuperview];
                [self->_topImageView removeFromSuperview];
            }];
        }
        else{
            [UIView animateWithDuration:0.3 animations:^{
                self->_topView.alpha = 1.f;
                self->_topImageView.frame = [UIScreen mainScreen].bounds;
            } completion:^(BOOL finished) {
                self.hidden = NO;
                self->_topView.hidden = YES;
                self->_topImageView.hidden = YES;
            }];
        }
    }
}
-(void)setPageControlHidden:(BOOL)pageControlHidden{
    _pageControlHidden = pageControlHidden;
    pageControl.hidden = pageControlHidden;
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (_isRotate) {
        return;
    }
    _currentIndex = scrollView.contentOffset.x / (_screenFrame.size.width + 2*PADDING);
    pageControl.currentPage = _currentIndex;
    if (_lastCurrentIndex == _currentIndex) {
        return;
    }
    _lastCurrentIndex = _currentIndex;
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
-(void)reloadData{
    if (!self.superview) {
        @throw @"You Must Add This View To Supper";
    }
    _totalPage = [self.delegate numberOfPagesInPhotoBrowser:self];
    _screenFrame = [UIScreen mainScreen].bounds;
    _pagingScrollView.contentSize = CGSizeMake((_screenFrame.size.width + 2*PADDING) * _totalPage, _screenFrame.size.height);
    NSInteger showNumber = _totalPage;
    pageControl.numberOfPages = _totalPage;
    if (_totalPage>5) {
        showNumber = 5;
    }
    _currentIndex = 0;
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
                CGPoint origin = CGPointMake(rect.origin.x + fromImageView.frame.origin.x, rect.origin.y + fromImageView.frame.origin.y);
                CGSize size = fromImageView.frame.size;
                frame.size = size;
                frame.origin = origin;
                CGFloat originX = [UIDevice isX] ? 88 : 64;
                frame.origin.y += originX;
            }
        }
        
        _topView = [[UIView alloc]initWithFrame:topWindow.bounds];
        _topView.backgroundColor = [UIColor blackColor];
        [topWindow addSubview:_topView];
        
        _topImageView = [[UIImageView alloc] initWithFrame:frame];
        _topImageView.image = fromImageView.image;
        _topImageView.contentMode = UIViewContentModeScaleAspectFit;
        [topWindow addSubview:_topImageView];
        
        self.hidden = YES;
        [UIView animateWithDuration:0.2 animations:^{
            self->_topImageView.frame = [UIScreen mainScreen].bounds;
        } completion:^(BOOL finished) {
            self->_topView.hidden = YES;
            self->_topImageView.hidden = YES;
            self.hidden = NO;
        }];
    }
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.superview);
        make.left.equalTo(self.superview);
        make.width.equalTo(self.superview);
        make.height.equalTo(self.superview);
    }];
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _isRotate = YES;
}
-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    _screenFrame = [UIScreen mainScreen].bounds;
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
