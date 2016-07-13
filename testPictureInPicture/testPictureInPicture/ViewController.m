//
//  ViewController.m
//  testPictureInPicture
//
//  Created by lan on 16/6/7.
//  Copyright © 2016年 lan. All rights reserved.
//

#import "ViewController.h"
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController () <AVPlayerViewControllerDelegate>

@property (strong, nonatomic) AVPlayerViewController *playVC;
@property (strong, nonatomic) AVPlayer *player;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)playButtonClick:(id)sender {
    NSString * path = [[NSBundle mainBundle]pathForResource:@"phone" ofType:@"mp4"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVPlayer *player = [[AVPlayer alloc]initWithURL:url];
    AVPlayerViewController * playVC = [[AVPlayerViewController alloc]init];
    playVC.player = player;
    playVC.allowsPictureInPicturePlayback = YES;
    playVC.modalPresentationStyle = UIModalPresentationFullScreen;
    playVC.delegate = self;
    [self setAudio2SupportBackgroundPlay];
    self.playVC = playVC;
    self.player = player;
    [self presentViewController:self.playVC animated:YES completion:nil];
//    [self.view addSubview:playVC.view];
    [self.player play];
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

- (void)setAudio2SupportBackgroundPlay
{
    UIDevice *device = [UIDevice currentDevice];
    
    if (![device respondsToSelector:@selector(isMultitaskingSupported)]) {
        NSLog(@"Unsupported device!");
        return;
    }
    if (!device.multitaskingSupported) {
        NSLog(@"Unsupported multiTasking!");
        return;
    }
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *error;
    //    此为必须项，如果不写，会造成无法使用画中画功能，（画中画按钮将被禁用）。
    [session setCategory:AVAudioSessionCategoryPlayback error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
    [session setActive:YES error:&error];
    if (error) {
        NSLog(@"%@", error);
        return;
    }
}

//以下是AVPlayerViewController的代理方法，用于进出画中画不同时机写自定义方法。
#pragma mark - AVPlayerViewControllerDelegate
- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController
{
    NSLog(@"%s",__func__);
}
- (void)playerViewControllerDidStartPictureInPicture:(AVPlayerViewController *)playerViewController
{
    NSLog(@"%s",__func__);
}
- (void)playerViewController:(AVPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error
{
    NSLog(@"%s",__func__);
}
- (void)playerViewControllerWillStopPictureInPicture:(AVPlayerViewController *)playerViewController
{
    NSLog(@"%s",__func__);
}
- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController
{
    NSLog(@"%s",__func__);
}
- (BOOL)playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart:(AVPlayerViewController *)playerViewController
{
    NSLog(@"%s",__func__);
    return YES;
}
- (void)playerViewController:(AVPlayerViewController *)playerViewController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL restored))completionHandler
{
    NSLog(@"%s",__func__);
}
@end
