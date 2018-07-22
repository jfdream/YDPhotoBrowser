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
#import "ZFAVPlayerManager.h"
#import "ZFPlayerController.h"
#import "ZFPlayerControlView.h"

@interface YDViewController ()<YDPhotoBrowserDelegate>
{
    UIImageView * _imageView;
    YDPhotoBrowser * _photoBrowser;
    ZFAVPlayerManager *playerManager;
    ZFPlayerController * player;
}
@property (nonatomic,strong)UIView * containerView;
@property (nonatomic,strong)ZFPlayerControlView * controlView;
@end

@implementation YDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    
    _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 110, 440/2, 547/2)];
    _imageView.image = [UIImage imageNamed:@"hello"];
    [self.view addSubview:_imageView];
    
    [self.view addSubview:self.containerView];
    
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 100, 100, 100);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
//    playerManager = [[ZFAVPlayerManager alloc] init];
//    
//    player = [[ZFPlayerController alloc]initWithPlayerManager:playerManager containerView:self.containerView];
//    player.controlView = self.controlView;
//    
//    
//    __weak YDViewController * weakSelf = self;
//    player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
//        [weakSelf setNeedsStatusBarAppearanceUpdate];
//    };
//    NSString *URLString = [@"http://flv3.bn.netease.com/tvmrepo/2018/6/H/9/EDJTRBEH9/SD/EDJTRBEH9-mobile.mp4" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
//    playerManager.assetURL = [NSURL URLWithString:URLString];
//    [self.controlView showTitle:@"视频标题" coverURLString:@"https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240" fullScreenMode:ZFFullScreenModeLandscape];
}
- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor orangeColor];
    }
    return _containerView;
}

- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
}
-(void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    CGFloat x = 0;
    CGFloat y = CGRectGetMaxY(self.navigationController.navigationBar.frame);
    CGFloat w = CGRectGetWidth(self.view.frame);
    CGFloat h = w*9/16;
    self.containerView.frame = self.view.bounds;
    
//    w = 200;
//    h = 35;
//    x = (self.containerView.width - w)/2;
//    y = (self.containerView.height - h)/2;
//    self.textField.frame = CGRectMake(x, y, w, h);
//
//    w = 44;
//    h = w;
//    x = (CGRectGetWidth(self.containerView.frame)-w)/2;
//    y = (CGRectGetHeight(self.containerView.frame)-h)/2;
//    self.playBtn.frame = CGRectMake(x, y, w, h);
}
-(void)btnClick{
    YDPhotoBrowser * hello = [[YDPhotoBrowser alloc]init];
    hello.delegate = self;
    hello.panToDismiss = YES;
//    _photoBrowser.enableCustomDismiss = YES;
    [hello reloadData];
    
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
//    _photo.thumbnail = _imageView.image;
//    _photo.resource = _imageView.image;
    _photo.thumbnailURL = [NSURL URLWithString:@"https://upload-images.jianshu.io/upload_images/635942-14593722fe3f0695.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240"];
    _photo.resourceURL = [NSURL URLWithString:@"http://flv3.bn.netease.com/tvmrepo/2018/6/H/9/EDJTRBEH9/SD/EDJTRBEH9-mobile.mp4"];
    _photo.type = YDResourceTypeVideo;
    return _photo;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
