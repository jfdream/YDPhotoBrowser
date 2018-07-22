//
//  YDPhotoBrowserPresentationController.m
//  YDPhotoBrowser
//
//  Created by 杨雨东 on 2018/7/20.
//

#import "YDPhotoBrowserPresentationController.h"
#import "YDPhotoBrowser.h"
#define CORNER_RADIUS   16.f

@interface YDPhotoBrowser(Presentation)
@property (nonatomic,readonly,assign)CGRect frameOfPresentedViewInContainerView;
@property (nonatomic,readonly,assign)BOOL isEnlarge;
-(void)enlargePrepare;
-(void)enlargeToFullScreen;
@end

@interface YDPhotoBrowserPresentationController()<UIViewControllerAnimatedTransitioning>
{
    YDPhotoBrowser * _photoBrowser;
}
@property (nonatomic, strong) UIView *presentationWrappingView;
@end

@implementation YDPhotoBrowserPresentationController
- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
        _photoBrowser = (YDPhotoBrowser *)presentedViewController;
    }
    return self;
}
- (UIView*)presentedView
{
    return self.presentationWrappingView;
}
- (void)presentationTransitionDidEnd:(BOOL)completed{
    [_photoBrowser enlargePrepare];
}
- (void)presentationTransitionWillBegin
{
    UIView *presentedViewControllerView = [super presentedView];
    {
        UIView *presentationWrapperView = [[UIView alloc] initWithFrame:self.frameOfPresentedViewInContainerView];
        presentationWrapperView.layer.shadowOpacity = 0.44f;
        presentationWrapperView.layer.shadowRadius = 13.f;
        presentationWrapperView.layer.shadowOffset = CGSizeMake(0, -6.f);
        self.presentationWrappingView = presentationWrapperView;
        
        UIView *presentationRoundedCornerView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(presentationWrapperView.bounds, UIEdgeInsetsMake(0, 0, 0, 0))];
        presentationRoundedCornerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        UIView *presentedViewControllerWrapperView = [[UIView alloc] initWithFrame:UIEdgeInsetsInsetRect(presentationRoundedCornerView.bounds, UIEdgeInsetsMake(0, 0, 0, 0))];
        presentedViewControllerWrapperView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        presentedViewControllerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        presentedViewControllerView.frame = presentedViewControllerWrapperView.bounds;
        [presentedViewControllerWrapperView addSubview:presentedViewControllerView];
        
        [presentationRoundedCornerView addSubview:presentedViewControllerWrapperView];
        
        [presentationWrapperView addSubview:presentationRoundedCornerView];
        self.presentationWrappingView.layer.masksToBounds = YES;
    }
    
    {
        UIView *dimmingView = [[UIView alloc] initWithFrame:self.containerView.bounds];
        dimmingView.backgroundColor = [UIColor blackColor];
        dimmingView.opaque = NO;
        dimmingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [dimmingView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dimmingViewTapped:)]];
        self.dimmingView = dimmingView;
        [self.containerView addSubview:dimmingView];
        
        id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
        self.dimmingView.alpha = 0.f;
        [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.dimmingView.alpha = 0.5f;
        } completion:NULL];
    }
}
- (void)dismissalTransitionWillBegin
{
    id<UIViewControllerTransitionCoordinator> transitionCoordinator = self.presentingViewController.transitionCoordinator;
    [transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        self.dimmingView.alpha = 0.f;
    } completion:NULL];
}
- (void)dismissalTransitionDidEnd:(BOOL)completed
{
    if (completed == YES)
    {
        self.presentationWrappingView = nil;
        self.dimmingView = nil;
    }
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container
{
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    if (container == self.presentedViewController)
        [self.containerView setNeedsLayout];
}
- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize
{
    if (container == self.presentedViewController)
        return ((UIViewController*)container).preferredContentSize;
    else
        return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
}
- (CGRect)frameOfPresentedViewInContainerView
{
    return _photoBrowser.frameOfPresentedViewInContainerView;
}

- (void)containerViewWillLayoutSubviews
{
    [super containerViewWillLayoutSubviews];
    self.dimmingView.frame = self.containerView.bounds;
    self.presentationWrappingView.frame = self.frameOfPresentedViewInContainerView;
    [_photoBrowser enlargeToFullScreen];
}

- (IBAction)dimmingViewTapped:(UITapGestureRecognizer*)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return _photoBrowser.isEnlarge ? 0.3f : 0.f;
}
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = transitionContext.containerView;
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    
    BOOL isPresenting = (fromViewController == self.presentingViewController);
    
    // This will be the current frame of fromViewController.view.
    CGRect __unused fromViewInitialFrame = [transitionContext initialFrameForViewController:fromViewController];
    // For a presentation which removes the presenter's view, this will be
    // CGRectZero.  Otherwise, the current frame of fromViewController.view.
    CGRect fromViewFinalFrame = [transitionContext finalFrameForViewController:fromViewController];
    // This will be CGRectZero.
    CGRect __unused toViewInitialFrame = [transitionContext initialFrameForViewController:toViewController];
    CGRect toViewFinalFrame = [transitionContext finalFrameForViewController:toViewController];
    
    [containerView addSubview:toView];
    
    if (isPresenting) {
        toView.frame = toViewFinalFrame;
    } else {
        fromViewFinalFrame = fromView.frame;
    }
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transitionDuration animations:^{
        if (isPresenting)
            toView.frame = toViewFinalFrame;
        
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
}
- (UIPresentationController*)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source
{
    NSAssert(self.presentedViewController == presented, @"You didn't initialize %@ with the correct presentedViewController.  Expected %@, got %@.",
             self, presented, self.presentedViewController);
    
    return self;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}
@end
