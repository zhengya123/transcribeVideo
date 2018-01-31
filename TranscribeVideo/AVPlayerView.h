//
//  AVPlayerView.h
//  TranscribeVideo
//
//  Created by 中商国际 on 2018/1/31.
//  Copyright © 2018年 中商国际. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>


@interface AVPlayerView : UIView

@property (nonatomic, strong) NSURL * url;
@property (strong, nonatomic) AVPlayer      * myPlayer;//播放器
@property (strong, nonatomic) AVPlayerItem  * item;//播放单元
@property (strong, nonatomic) AVPlayerLayer * playerLayer;//播放界面（layer）
@property (strong, nonatomic)UISlider *avSlider;//用来现实视频的播放进度，并且通过它来控制视频的快进快退。
@property (assign, nonatomic)BOOL isReadToPlay;//用来判断当前视频是否准备好播放。


+ (AVPlayerView *)shareView;
- (void) showWithFrame:(CGRect)frames
                  addV:(UIView *)view;

- (void) startPlayer:(NSURL *)url;

- (void) hides;
@end
