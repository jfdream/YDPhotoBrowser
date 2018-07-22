/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The initial view controller for the Swipe demo.
 */

#import "AAPLSwipeFirstViewController.h"
#import "AAPLSwipeTransitionDelegate.h"
@interface AAPLSwipeFirstViewController ()
@property (nonatomic, strong) AAPLSwipeTransitionDelegate *customTransitionDelegate;
@end

@implementation AAPLSwipeFirstViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"CustomTransition"])
    {
        UIViewController *destinationViewController = segue.destinationViewController;
        AAPLSwipeTransitionDelegate *transitionDelegate = self.customTransitionDelegate;
        if ([sender isKindOfClass:UIGestureRecognizer.class])
            transitionDelegate.gestureRecognizer = sender;
        else{
            transitionDelegate.gestureRecognizer = nil;
        }
        transitionDelegate.targetEdge = UIRectEdgeRight;
        destinationViewController.transitioningDelegate = transitionDelegate;
        destinationViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
}
- (AAPLSwipeTransitionDelegate *)customTransitionDelegate
{
    if (_customTransitionDelegate == nil)
        _customTransitionDelegate = [[AAPLSwipeTransitionDelegate alloc] init];
    
    return _customTransitionDelegate;
}
- (IBAction)unwindToSwipeFirstViewController:(UIStoryboardSegue *)sender
{ }

@end
