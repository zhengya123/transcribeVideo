//
//  ViewController.m
//  TranscribeVideo
//
//  Created by 中商国际 on 2018/1/30.
//  Copyright © 2018年 中商国际. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "CommonMethod.h"
#import "AVPlayerView.h"
@interface ViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIButton * recordBtn;
@property (nonatomic, strong) UIButton * transcribeBtn;
@property (nonatomic, strong) UIImageView * imageV;
@property (nonatomic, strong) UIButton * playBtn;
@property (nonatomic, strong) UILabel  * SizeLabel;

@end

@implementation ViewController
{
    NSURL * imgUrl;

}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self createUI];
}
- (void)createUI{

    self.imageV.frame = CGRectMake(10, 20, [UIScreen mainScreen].bounds.size.width - 20, ([UIScreen mainScreen].bounds.size.width - 20)*16/9 - 60);
    [self.view addSubview:self.imageV];
    
    self.playBtn.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width - 20)/2 - 25, (([UIScreen mainScreen].bounds.size.width - 20)*16/9 - 60)/2 - 25, 50, 50);
    [self.imageV addSubview:self.playBtn];
    
    self.SizeLabel.frame = CGRectMake(self.imageV.frame.size.width - 120, self.imageV.frame.size.height - 55, 110, 50);
    [self.imageV addSubview:self.SizeLabel];
    
    
    self.recordBtn.frame = CGRectMake(30, [UIScreen mainScreen].bounds.size.height - 60, ([UIScreen mainScreen].bounds.size.width - 60)/2 - 20, 30);
    [self.view addSubview:self.recordBtn];

    self.transcribeBtn.frame = CGRectMake(CGRectGetMaxX(self.recordBtn.frame) + 40, [UIScreen mainScreen].bounds.size.height - 60, ([UIScreen mainScreen].bounds.size.width - 60)/2 - 20, 30);
    [self.view addSubview:self.transcribeBtn];
    
    
    
}
- (void)recordClick:(UIButton *)btn{
    NSLog(@"本地相册");
    [[AVPlayerView shareView] hides];
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;//sourcetype有三种分别是camera，photoLibrary和photoAlbum
    NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
    ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
    [self presentViewController:ipc animated:YES completion:nil];
    ipc.delegate = self;//设置委托
}
- (void)transcribeClick:(UIButton *)btn{
    NSLog(@"去录制");
    [[AVPlayerView shareView] hides];
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.sourceType = UIImagePickerControllerSourceTypeCamera;//sourcetype有三种分别是camera，photoLibrary和photoAlbum
    NSArray *availableMedia = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];//Camera所支持的Media格式都有哪些,共有两个分别是@"public.image",@"public.movie"
    ipc.mediaTypes = [NSArray arrayWithObject:availableMedia[1]];//设置媒体类型为public.movie
    [self presentViewController:ipc animated:YES completion:nil];
    ipc.videoMaximumDuration = 20.0f;//30秒
    ipc.delegate = self;//设置委托

}
- (void)playBtn:(UIButton *)btn{
    if (imgUrl != nil) {
        [[AVPlayerView shareView] showWithFrame:CGRectMake(0, 0, self.imageV.frame.size.width, self.imageV.frame.size.height) addV:self.imageV];
        [[AVPlayerView shareView] startPlayer:imgUrl];
    }

}
//完成视频录制，并压缩后显示大小、时长
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.SizeLabel.text = @"正在\n压缩";
    NSURL *sourceURL = [info objectForKey:UIImagePickerControllerMediaURL];
    //NSLog(@"%@",[NSString stringWithFormat:@"%f s", [CommonMethod getVideoLength:sourceURL]]);
    //NSLog(@"%@", [NSString stringWithFormat:@"%.2f kb", [CommonMethod getFileSize:[sourceURL path]]]);
    NSURL *newVideoUrl ; //一般.mp4
    NSDateFormatter *formater = [[NSDateFormatter alloc] init];//用时间给文件全名，以免重复，在测试的时候其实可以判断文件是否存在若存在，则删除，重新生成文件即可
    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    newVideoUrl = [NSURL fileURLWithPath:[NSHomeDirectory() stringByAppendingFormat:@"/Documents/output-%@.mp4", [formater stringFromDate:[NSDate date]]]] ;//这个是保存在app自己的沙盒路径里，后面可以选择是否在上传后删除掉。我建议删除掉，免得占空间。
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self convertVideoQuailtyWithInputURL:sourceURL outputURL:newVideoUrl completeHandler:nil];
}
- (void) convertVideoQuailtyWithInputURL:(NSURL*)inputURL
                               outputURL:(NSURL*)outputURL
                         completeHandler:(void (^)(AVAssetExportSession*))handler
{
    
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:inputURL options:nil];
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    //  NSLog(resultPath);
    exportSession.outputURL = outputURL;
    exportSession.outputFileType = AVFileTypeMPEG4;
    exportSession.shouldOptimizeForNetworkUse= YES;
    [exportSession exportAsynchronouslyWithCompletionHandler:^(void)
     {
        
         switch (exportSession.status) {
             case AVAssetExportSessionStatusCancelled:
                 NSLog(@"AVAssetExportSessionStatusCancelled");
                 break;
             case AVAssetExportSessionStatusUnknown:
                 NSLog(@"AVAssetExportSessionStatusUnknown");
                 break;
             case AVAssetExportSessionStatusWaiting:
                 NSLog(@"AVAssetExportSessionStatusWaiting");
                 break;
             case AVAssetExportSessionStatusExporting:
                 NSLog(@"AVAssetExportSessionStatusExporting");
                 break;
             case AVAssetExportSessionStatusCompleted:
                 NSLog(@"AVAssetExportSessionStatusCompleted");
                 
                 //UISaveVideoAtPathToSavedPhotosAlbum([outputURL path], self, nil, NULL);//这个是保存到手机相册
                 
                 [self alertUploadVideo:outputURL];
                 break;
             case AVAssetExportSessionStatusFailed:
                 NSLog(@"AVAssetExportSessionStatusFailed");
                 break;
         }
         
     }];
    
}
-(void)alertUploadVideo:(NSURL*)URL{
    CGFloat size = [CommonMethod getFileSize:[URL path]];
    NSString *message;
    NSString *sizeString;
    CGFloat sizemb= size/1024;
    if(size<=1024){
        sizeString = [NSString stringWithFormat:@"%.2fKB",size];
    }else{
        sizeString = [NSString stringWithFormat:@"%.2fMB",sizemb];
    }
    
    if(sizemb<2){
        [self uploadVideo:URL];
    }
    
    else if(sizemb<=5){
        message = [NSString stringWithFormat:@"视频%@，大于2MB会有点慢，确定上传吗？", sizeString];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                                  message: message
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshwebpages" object:nil userInfo:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[URL path] error:nil];//取消之后就删除，以免占用手机硬盘空间（沙盒）
            
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            
            [self uploadVideo:URL];
            
            
            
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
    }else if(sizemb>5){
        message = [NSString stringWithFormat:@"视频%@，超过5MB，不能上传，抱歉。", sizeString];
        UIAlertController * alertController = [UIAlertController alertControllerWithTitle: nil
                                                                                  message: message
                                                                           preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshwebpages" object:nil userInfo:nil];
            [[NSFileManager defaultManager] removeItemAtPath:[URL path] error:nil];//取消之后就删除，以免占用手机硬盘空间
            
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
}
-(void)uploadVideo:(NSURL*)URL{

    imgUrl = URL;
    self.imageV.image = [CommonMethod getThumbnailImage:URL];
    self.SizeLabel.text = [NSString stringWithFormat:@"%.02f s\n%.2f kb",[CommonMethod getVideoLength:URL],[CommonMethod getFileSize:[URL path]]];
    
    self.imageV.contentMode = UIViewContentModeScaleAspectFit;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - lan
- (UIButton *)recordBtn{
    if (_recordBtn == nil) {
        _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_recordBtn setTitle:@"本地" forState:UIControlStateNormal];
        [_recordBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_recordBtn addTarget:self action:@selector(recordClick:) forControlEvents:UIControlEventTouchUpInside];
        _recordBtn.layer.masksToBounds = YES;
        _recordBtn.layer.cornerRadius  = 4;
        _recordBtn.layer.borderWidth   = 1.0;
        _recordBtn.layer.borderColor   = [UIColor blackColor].CGColor;
    }
    return _recordBtn;
}
- (UIButton *)transcribeBtn{
    if (_transcribeBtn == nil) {
        _transcribeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_transcribeBtn setTitle:@"录制" forState:UIControlStateNormal];
        [_transcribeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_transcribeBtn addTarget:self action:@selector(transcribeClick:) forControlEvents:UIControlEventTouchUpInside];
        _transcribeBtn.layer.masksToBounds = YES;
        _transcribeBtn.layer.cornerRadius  = 4;
        _transcribeBtn.layer.borderWidth   = 1.0;
        _transcribeBtn.layer.borderColor   = [UIColor blackColor].CGColor;
    }
    return _transcribeBtn;
}
- (UIButton *)playBtn{
    if (_playBtn == nil) {
        _playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playBtn setImage:[UIImage imageNamed:@"play_small"] forState:UIControlStateNormal];
        [_playBtn addTarget:self action:@selector(playBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}
- (UIImageView *)imageV{
    if (_imageV == nil) {
        _imageV = [UIImageView new];
        _imageV.backgroundColor = [UIColor whiteColor];
        _imageV.userInteractionEnabled = YES;
    }
    return _imageV;
}
- (UILabel *)SizeLabel{
    if (_SizeLabel == nil) {
        _SizeLabel = [UILabel new];
        _SizeLabel.textColor = [UIColor redColor];
        _SizeLabel.textAlignment = NSTextAlignmentRight;
        _SizeLabel.numberOfLines = 0;
        [_SizeLabel addObserver:self forKeyPath:@"SizeLabel" options:NSKeyValueObservingOptionNew context:nil];
    }
    return _SizeLabel;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:
(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"SizeLabel"]) {
        NSLog(@"%@ -- %@",change,context);
    }
};

#pragma mark - 私有方法
//获取本地路径

-(NSURL *)getFileUrl{
    
    NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"xxx.mp4" ofType:nil];
    
    NSURL *url=[NSURL fileURLWithPath:urlStr];
    
    return url;
    
}
@end
