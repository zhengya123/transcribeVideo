//
//  AVPlayerView.m
//  TranscribeVideo
//
//  Created by 中商国际 on 2018/1/31.
//  Copyright © 2018年 中商国际. All rights reserved.
//

#import "AVPlayerView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "CommonMethod.h"
@implementation AVPlayerView

+ (AVPlayerView *)shareView{
    static AVPlayerView * avplayerView = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        avplayerView = [[AVPlayerView alloc]init];
    });
    return avplayerView;

}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.avSlider];
    }
    return self;
}
- (void)layoutSubviews{
    [super layoutSubviews];
    

}
- (void)showWithFrame:(CGRect)frames addV:(UIView *)view{
    self.frame = CGRectMake(0, 0, frames.size.width, frames.size.height);
    self.avSlider.frame = CGRectMake(0, self.frame.size.height - 20, self.frame.size.width, 20);
    [view addSubview:self];

}
- (void)startPlayer:(NSURL *)url{
    self.url = url;
    self.item = [AVPlayerItem playerItemWithURL:url];
    self.myPlayer = [AVPlayer playerWithPlayerItem:self.item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.myPlayer];
    self.playerLayer.frame = CGRectMake(0, 0, self.frame.size.width,self.frame.size.height);
    [self.layer addSublayer:self.playerLayer];
    [self.item addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        //取出status的新值
        AVPlayerItemStatus status = [change[NSKeyValueChangeNewKey]intValue];
        switch (status) {
            case AVPlayerItemStatusFailed:
                NSLog(@"item 有误");
                self.isReadToPlay = NO;
                break;
            case AVPlayerItemStatusReadyToPlay:
            {
                NSLog(@"准好播放了");
                self.isReadToPlay = YES;
                [self.myPlayer play];
                self.avSlider.minimumValue = 0;
                self.avSlider.maximumValue = [CommonMethod getVideoLength:self.url];
                __weak typeof(self) weakSelf = self;
                [self.myPlayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:nil usingBlock:^(CMTime time) {
                    NSLog(@"%f -- %f",CMTimeGetSeconds(time),[CommonMethod getVideoLength:weakSelf.url]);
                    CGFloat playSecond = CMTimeGetSeconds(time);
                    weakSelf.avSlider.value = playSecond;
                    if ((playSecond - [CommonMethod getVideoLength:weakSelf.url]) >= 0) {
                        NSLog(@"结束了");
                        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/*延迟执行时间*/ * NSEC_PER_SEC));
                        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                            
                            [weakSelf hides];
                            
                        });
                    
                    }
                    
                }];
            }
                break;
            case AVPlayerItemStatusUnknown:
                NSLog(@"视频资源出现未知错误");
                self.isReadToPlay = NO;
                break;
            default:
                break;
        }
    }
    //移除监听（观察者）
    [object removeObserver:self forKeyPath:@"status"];
}

- (void)hides{

    [self.myPlayer pause];
    [self removeFromSuperview];

}
- (void)avSliderAction:(UISlider *)slider{

    //slider的value值为视频的时间
    float seconds = slider.value;
    //让视频从指定的CMTime对象处播放。
    CMTime startTime = CMTimeMakeWithSeconds(seconds, 1);
    //让视频从指定处播放
    [self.myPlayer seekToTime:startTime completionHandler:^(BOOL finished) {
        if (finished) {
            __weak typeof(self) weakSelf = self;
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1/*延迟执行时间*/ * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                
                [weakSelf hides];
                
            });

            
        }
    }];
    
}
- (UISlider *)avSlider{
    if (!_avSlider) {
        _avSlider = [[UISlider alloc]init];
        [_avSlider setThumbImage:[CommonMethod imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        _avSlider.enabled = NO;
        //[_avSlider addTarget:self action:@selector(avSliderAction:) forControlEvents:
         //UIControlEventTouchUpInside|UIControlEventTouchCancel|UIControlEventTouchUpOutside];
    }return _avSlider;
}

@end
