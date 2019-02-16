//
//  PlayerViewController.m
//  JJException
//
//  Created by Jezz on 2018/12/12.
//  Copyright © 2018年 Jezz. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

@interface PlayerViewController ()

@property (nonatomic,readwrite,strong)AVPlayerItem* item;

@property (nonatomic,readwrite,strong)AVPlayer* player;

@property (nonatomic,readwrite,strong)AVPlayerViewController* playerView;

@end

@implementation PlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSURL *url = [[NSBundle mainBundle]URLForResource:@"IMG_2270" withExtension:@"mp4"];
//    AVAsset* set = [AVAsset assetWithURL:url];
//    self.item = [[AVPlayerItem alloc]initWithAsset:set];
//    self.player = [AVPlayer playerWithPlayerItem:self.item];
//    AVPlayerLayer* layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
//    layer.frame = CGRectMake(0, 0, self.view.frame.size.width, 600);
//    [self.view.layer addSublayer:layer];
//    
//    [self.item addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    self.playerView = [[AVPlayerViewController alloc]init];
    //通过AVPlayerItem创建AVPlayer
    self.player = [[AVPlayer alloc] initWithURL:url];
    //设置AVPlayerViewController内部的AVPlayer为刚创建的AVPlayer
    self.playerView.player = self.player;
    [self.playerView.view setFrame:self.view.bounds];
    [self.view addSubview:self.playerView.view];
    [self.playerView.player play];


    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

//- (void)observeValueForKeyPath:(NSString *)keyPath
//                      ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context {
//    
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.item removeObserver:self forKeyPath:@"status"];
//            NSLog(@"self.item.status=%ld",(long)self.item.status);
//            if (self.item.status == AVPlayerItemStatusReadyToPlay) {
//                [self.player play];
//            } else {
//                
//            }
//        });
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
