//
//  MediaPlayer.m
//  MediaPlayer
//
//  Created by YLCHUN on 2017/5/11.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "MediaPlayerControl.h"
#import <MobileVLCKit/MobileVLCKit.h>
#import "NSVolume.h"

typedef enum :NSInteger {
    PanActionOptionVolume,
    PanActionOptionLight,
    PanActionOptionProgress,
    PanActionOptionNone
} PanActionOption;

@interface MediaPlayerControl ()<PlayerTransferDelegate>
@property (weak, nonatomic) IBOutlet UIView *displayView;

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *tap_setting;//点击操作，显示隐藏工具栏
@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *pan_setting;//滑动设置，垂直（左半屏亮度，又半屏声音），水平（进退）
@property (weak, nonatomic) IBOutlet UIView *controlPanel;//操作面板

@property (nonatomic, retain) NSObject<PlayerTransferProtocol> *player;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lCons_barTop_T;//顶部工具栏顶部约束 0显示，-40隐藏
@property (weak, nonatomic) IBOutlet UIView *bar_top;//顶部工具栏
@property (weak, nonatomic) IBOutlet UILabel *lab_title;//标题
@property (weak, nonatomic) IBOutlet UIButton *but_screenshot;//截屏
@property (weak, nonatomic) IBOutlet UIButton *but_setting;//设置

@property (weak, nonatomic) IBOutlet UILabel *lab_subtitle;//字幕

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lCons_barBottom_B;//底部工具栏底部约束  0显示，-40隐藏
@property (weak, nonatomic) IBOutlet UIView *bar_bottom;//底部工具栏
@property (weak, nonatomic) IBOutlet UIButton *but_play;//播放／暂停
@property (weak, nonatomic) IBOutlet UILabel *lab_timePlayed;//播放时间
@property (weak, nonatomic) IBOutlet UIProgressView *pro_progress;//播放进度
@property (weak, nonatomic) IBOutlet UILabel *lab_timeAll;//总时间
@property (weak, nonatomic) IBOutlet UIButton *but_full;//全屏

@property (nonatomic, assign) CGPoint translation_last;
@property (nonatomic, assign)BOOL hiddenBar;

@property (nonatomic,assign) BOOL fullscreen;

@property (nonatomic, assign)PanActionOption panActionOption;
@property (nonatomic, assign)CGRect originFrame;
@end

@implementation MediaPlayerControl

-(instancetype)initWithPlayer:(NSObject<PlayerTransferProtocol>*)player {
    self = [[NSBundle mainBundle] loadNibNamed:@"MediaPlayerControl" owner:self options:nil].firstObject;
    if (self) {
        self.clipsToBounds = YES;
        self.player = player;
        [self.player setDisplayView:self.displayView];
        self.player.delegate = self;
        [self relatedAction];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

-(void)relatedAction {
    [self.tap_setting addTarget:self action:@selector(action_tap:)];
    [self.pan_setting addTarget:self action:@selector(action_pan:)];
    
    [self.but_screenshot addTarget:self action:@selector(action_screenshot) forControlEvents:UIControlEventTouchUpInside];
    [self.but_setting addTarget:self action:@selector(action_setting) forControlEvents:UIControlEventTouchUpInside];

    [self.but_play addTarget:self action:@selector(action_play) forControlEvents:UIControlEventTouchUpInside];
    [self.but_full addTarget:self action:@selector(action_full) forControlEvents:UIControlEventTouchUpInside];
    
    [self.but_full setImage:[UIImage imageNamed:@"Full"] forState:UIControlStateNormal];
    [self.but_play setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    
    [self.but_full setTitle:nil forState:UIControlStateNormal];
    [self.but_play setTitle:nil forState:UIControlStateNormal];
    
}

- (void)orientChange:(NSNotification *)noti {
    UIDeviceOrientation  orient = [UIDevice currentDevice].orientation;
    /*
     UIDeviceOrientationUnknown,
     UIDeviceOrientationPortrait,            // Device oriented vertically, home button on the bottom
     UIDeviceOrientationPortraitUpsideDown,  // Device oriented vertically, home button on the top
     UIDeviceOrientationLandscapeLeft,       // Device oriented horizontally, home button on the right
     UIDeviceOrientationLandscapeRight,      // Device oriented horizontally, home button on the left
     UIDeviceOrientationFaceUp,              // Device oriented flat, face up
     UIDeviceOrientationFaceDown             // Device oriented flat, face down   */
    switch (orient) {
        case UIDeviceOrientationPortrait:
            break;
        case UIDeviceOrientationLandscapeLeft:
            if (self.fullscreen) {
                [UIView animateWithDuration:0.5 animations:^{
                    self.transform = CGAffineTransformMakeRotation(M_PI_2);
                    [self layoutIfNeeded];
                } completion:^(BOOL finished) {
                }];
            }
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            break;
        case UIDeviceOrientationLandscapeRight:
            if (self.fullscreen) {
                [UIView animateWithDuration:0.5 animations:^{
                    self.transform = CGAffineTransformMakeRotation(-M_PI_2);
                    [self layoutIfNeeded];
                } completion:^(BOOL finished) {
                }];
            }
            break;
        default:
            break;
    }
}


-(void)setPanActionOption:(PanActionOption)panActionOption {
    if (_panActionOption == PanActionOptionNone || panActionOption == PanActionOptionNone) {
        _panActionOption = panActionOption;
    }
}

-(BOOL)playing {
    return self.player.playing;
}

-(void)setHiddenBarAfter {
    [self cancelHiddenBarAfter];
    [self performSelector:@selector(_setHiddenBar) withObject:nil afterDelay:1];
}

-(void)cancelHiddenBarAfter{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(_setHiddenBar) object:nil];
}

-(void)_setHiddenBar {
    self.hiddenBar = YES;
}

-(void)setHiddenBar:(BOOL)hiddenBar {
    if (_hiddenBar == hiddenBar) {
        return;
    }
    CGFloat constant = 0;
    if (_hiddenBar) {
        constant = 0;
    }else{
        constant = -40;
        [self cancelHiddenBarAfter];
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.lCons_barTop_T.constant = constant;
        self.lCons_barBottom_B.constant = constant;
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        _hiddenBar = hiddenBar;
        if (!_hiddenBar) {
            [self setHiddenBarAfter];
        }
    }];
}

-(void)setFullscreen:(BOOL)fullscreen {
    if (_fullscreen == fullscreen) {
        return;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:fullscreen withAnimation:UIStatusBarAnimationNone];
    if (fullscreen) {
        self.originFrame = self.frame;
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        [UIView animateWithDuration:0.5 animations:^{
            if (!UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
                self.frame = CGRectMake(0, 0, height, width);
                self.center = CGPointMake(width/2, height/2);
                self.transform = CGAffineTransformMakeRotation(M_PI_2);
            }else {
                self.frame = [UIScreen mainScreen].bounds;
            }
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            _fullscreen = YES;
            [self.but_full setImage:[UIImage imageNamed:@"Min"] forState:UIControlStateNormal];
        }];
    }else {
        [UIView animateWithDuration:0.5 animations:^{
            self.transform = CGAffineTransformIdentity;
            self.frame = self.originFrame;
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            _fullscreen = NO;
            [self.but_full setImage:[UIImage imageNamed:@"Full"] forState:UIControlStateNormal];

        }];
    }
}

-(void)action_tap:(UITapGestureRecognizer*)sender {
    CGPoint location = [sender locationInView:self.controlPanel];
    CGFloat h = self.controlPanel.bounds.size.height;
    if (location.y<h/4.0 || location.y>h/4.0*3.0) {
        self.hiddenBar = !self.hiddenBar;
    }else{
        if (self.playing) {
            [self.player pause];
        }else{
            [self.player play];
        }
    }
}

-(void)action_pan:(UIPanGestureRecognizer*)sender {
    switch (sender.state) {
        case UIGestureRecognizerStateBegan: {
            self.panActionOption = PanActionOptionNone;
            self.translation_last = [sender translationInView:self.controlPanel];
            [self cancelHiddenBarAfter];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (self.panActionOption == PanActionOptionNone) {
                CGPoint velocity = [sender velocityInView:self.controlPanel];
                if (ABS(velocity.x) > ABS(velocity.y)) {
                    self.panActionOption = PanActionOptionProgress;
                }else {
                    CGPoint location = [sender locationInView:self.controlPanel];
                    if (location.x > self.controlPanel.bounds.size.width / 2) {
                        self.panActionOption = PanActionOptionVolume;
                    }else {
                        self.panActionOption = PanActionOptionLight;
                    }
                }
            }
            CGPoint translation = [sender translationInView:self.controlPanel];
            switch (self.panActionOption) {
                case PanActionOptionProgress:{
                    [self setHiddenBarAfter];
                    if (translation.x > self.translation_last.x) {
                        NSLog(@">>");
//                        [self.player shortJumpForward];
                        self.pro_progress.progress += 0.01;
                    }
                    if (translation.x < self.translation_last.x) {
                        NSLog(@"<<");
//                        [self.player shortJumpBackward];
                        self.pro_progress.progress -= 0.01;
                    }
                } break;
                case PanActionOptionVolume:{
                    if (translation.y < self.translation_last.y) {
                        [NSVolume sharedVolume].value += 0.01;
                    }
                    if (translation.y > self.translation_last.y) {
                        [NSVolume sharedVolume].value -= 0.01;
                    }
                } break;
                case PanActionOptionLight:{
                    if (translation.y < self.translation_last.y) {
                        [UIScreen mainScreen].brightness += 0.01;
                    }
                    if (translation.y > self.translation_last.y) {
                        [UIScreen mainScreen].brightness -= 0.01;
                    }
                }break;
                default:
                    break;
            }
            self.translation_last = translation;

        }
            break;
        case UIGestureRecognizerStateEnded: {
            self.panActionOption = PanActionOptionNone;
            [self setHiddenBarAfter];
        }
            break;
        default:{
            self.panActionOption = PanActionOptionNone;
        } break;
    }
}

-(void)action_play {
//    UIButton *sender = self.but_play;
    if (self.playing) {
        [self.player pause];
    }else{
        [self.player play];
        [self setHiddenBarAfter];
    }
}

-(void)action_full {
//    UIButton *sender = self.but_full;
    self.fullscreen = !self.fullscreen;
    [self setHiddenBarAfter];
}
-(void)action_screenshot {
//    UIButton *sender = self.but_screenshot;
//    [self.thumbnailer fetchThumbnail];
    [self setHiddenBarAfter];
}
-(void)action_setting {
//    UIButton *sender = self.but_setting;
    [self setHiddenBarAfter];
}



#pragma mark VLC
- (void)mediaPlayerMediaChange {
    self.pro_progress.progress = 0.0;
}

- (void)mediaPlayerStateChanged:(MediaPlayerState)state {
    switch (state) {
        case MediaPlayerStateStopped:{
            [self playUIWithPlaying:NO];
            self.pro_progress.progress = 0.0;
            [self.player stop];
        }break;
        case MediaPlayerStatePlaying:{
            [self playUIWithPlaying:YES];
            [self setHiddenBarAfter];
        }break;
        case MediaPlayerStatePaused:{
            [self playUIWithPlaying:NO];
        }break;
        default:
            [self.player stop];
            break;
    }
}

- (void)mediaPlayerTimeChanged:(NSString*)playedTime allTime:(NSString*)allTime progress:(double)progress {
    [self.pro_progress setProgress:progress animated:YES];
    self.lab_timePlayed.text = playedTime;
}


#pragma mark Player Logic
-(void)playUIWithPlaying:(BOOL) isPlaying {
    if (isPlaying) {
        [self.but_play setImage:[UIImage imageNamed:@"Pause"] forState:UIControlStateNormal];
    }else{
        [self.but_play setImage:[UIImage imageNamed:@"Play"] forState:UIControlStateNormal];
    }
}


@end
