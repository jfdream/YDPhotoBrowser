//
//  YDViewController.m
//  YDPhotoBrowser
//
//  Created by jfdream1992@126.com on 07/02/2018.
//  Copyright (c) 2018 jfdream1992@126.com. All rights reserved.
//

#import "YDViewController.h"
#import "YDPhotoBrowser.h"
#import "AAPLCustomPresentationFirstViewController.h"

@interface YDViewController ()<YDPhotoBrowserDelegate>
{
    UIImageView * _imageView;
    YDPhotoBrowser * _photoBrowser;

}
@end

@implementation YDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 110, 440/2, 547/2)];
    _imageView.image = [UIImage imageNamed:@"hello"];
    [self.view addSubview:_imageView];
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
}

-(void)btnClick{
    _photoBrowser = [[YDPhotoBrowser alloc]init];
    _photoBrowser.delegate = self;
    _photoBrowser.panToDismiss = YES;
    _photoBrowser.enableCustomDismiss = YES;
    YDPhotoBrowserPresentationController * presentationController = [[YDPhotoBrowserPresentationController alloc]initWithPresentedViewController:_photoBrowser presentingViewController:self];
    _photoBrowser.transitioningDelegate = presentationController;
    [_photoBrowser reloadData];
    
//    AAPLCustomPresentationFirstViewController * fvc = [[AAPLCustomPresentationFirstViewController alloc]init];
//    [self presentViewController:fvc animated:YES completion:nil];
    
}
-(UIViewController *)photoBrowserParentViewController{
    return self;
}
-(UIImageView *)photoBrowser:(YDPhotoBrowser *)photoBrowser showFromIndex:(NSInteger)fromIndex{
    return _imageView;
}

-(NSInteger)numberOfPagesInPhotoBrowser:(YDPhotoBrowser *)photoBrowser{
    return 3;
}
-(UIImageView *)photoBrowser:(YDPhotoBrowser *)photoBrowser hideToIndex:(NSInteger)toIndex{
    return _imageView;
}
-(YDPhoto *)photoBrowser:(YDPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index{
    YDPhoto * _photo = [[YDPhoto alloc]init];
    _photo.thumbnail = _imageView.image;
    _photo.resource = _imageView.image;
    return _photo;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
