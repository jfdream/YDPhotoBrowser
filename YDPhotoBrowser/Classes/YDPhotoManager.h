//
//  YDPhotoManager.h
//  YDPhotoBrowser
//
//  Created by 杨雨东 on 2018/7/21.
//

#import <Foundation/Foundation.h>



@protocol YDPhotoManagerDelegate<NSObject>
-(void)videoOrientationWillChange;
-(void)videoCloseButtonClick;
@end

@class ZFAVPlayerManager;
@class ZFPlayerController;
@class ZFPlayerControlView;

@interface YDPhotoManager : NSObject
+(YDPhotoManager *)sharedManager;

/**
 启动播放器
 */
-(void)launch;
/**
 关闭播放器释放资源
 */
-(void)shutdown;
@property (nonatomic,weak)id <YDPhotoManagerDelegate> delegate;
@property (nonatomic,strong)ZFAVPlayerManager * playerManager;
@property (nonatomic,strong)ZFPlayerController * player;
@property (nonatomic,strong)ZFPlayerControlView * controlView;
@property (nonatomic,strong)UIView * containerView;
@end
