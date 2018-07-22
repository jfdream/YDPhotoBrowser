//
//  YDPhotoManager.m
//  YDPhotoBrowser
//
//  Created by 杨雨东 on 2018/7/21.
//

#import "YDPhotoManager.h"
#import "ZFPlayer.h"
#import "ZFAVPlayerManager.h"
#import "ZFPlayerController.h"
#import "ZFPlayerControlView.h"
#import "ZFUtilities.h"
@implementation YDPhotoManager

+(YDPhotoManager *)sharedManager{
    static YDPhotoManager * _manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc]init];
    });
    return _manager;
}
-(void)launch{
    _playerManager = [[ZFAVPlayerManager alloc]init];
    _player = [[ZFPlayerController alloc]initWithPlayerManager:_playerManager containerView:self.containerView];
    _player.controlView = self.controlView;
    _player.disableGestureTypes = ZFPlayerDisableGestureTypesDoubleTap | ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
}
-(void)shutdown{
    [self.containerView removeFromSuperview];
    [self.controlView removeFromSuperview];
    [_player stop];
    _playerManager = nil;
    _player = nil;
    self.containerView = nil;
    self.controlView = nil;
}
-(UIView *)containerView{
    if (!_containerView) {
        _containerView = [UIView new];
        _containerView.backgroundColor = [UIColor blackColor];
    }
    return _containerView;
}
- (ZFPlayerControlView *)controlView {
    if (!_controlView) {
        _controlView = [ZFPlayerControlView new];
    }
    return _controlView;
}
@end
