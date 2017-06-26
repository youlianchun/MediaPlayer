//
//  VLCPlayer.m
//  MediaPlayer
//
//  Created by YLCHUN on 2017/5/15.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "VLCPlayer.h"
#import <MobileVLCKit/MobileVLCKit.h>

@interface VLCPlayer()<VLCMediaPlayerDelegate>
{
    id<PlayerTransferDelegate> _delegate;
}
@property (nonatomic, retain) VLCMediaPlayer *player;

@end

@implementation VLCPlayer

-(instancetype)init {
    self = [super init];
    if (self) {
        self.player.delegate = self;
    }
    return self;
}

- (VLCMediaPlayer *)player {
    if (!_player) {
        _player = [[VLCMediaPlayer alloc] init];
    }
    return _player;
}

- (void)mediaPlayerStateChanged:(NSNotification *)aNotification {
    MediaPlayerState state = MediaPlayerStateStopped;
    if (self.player.media.state == VLCMediaStateBuffering) {
//        state = MediaPlayerStateBuffering;
    }else if (self.player.media.state == VLCMediaStatePlaying) {
        state = MediaPlayerStatePlaying;
    }else if (self.player.state == VLCMediaPlayerStateStopped) {
        state = MediaPlayerStateStopped;
    }else {
        state = MediaPlayerStatePaused;
    }

    [self.delegate mediaPlayerStateChanged:state];
}

- (void)mediaPlayerTimeChanged:(NSNotification *)aNotification {
    float progressValue = ([self.player.time.numberValue floatValue]) / ([self.player.media.length.numberValue floatValue]);
    [self.delegate mediaPlayerTimeChanged:self.player.time.stringValue allTime:@"" progress:progressValue];
}




- (void)setDisplayView:(UIView*)view {
    self.player.drawable = view;
}

-(id<PlayerTransferDelegate>)delegate {
    return _delegate;
}

-(void)setDelegate:(id<PlayerTransferDelegate>)delegate {
    _delegate = delegate;
}

-(void)setMediaURL:(NSURL *)mediaURL {
    if ([mediaURL.absoluteString isEqualToString:self.player.media.url.absoluteString]) {
        return;
    }
    [self stop];
    self.player.media = [VLCMedia mediaWithURL:mediaURL];
    [self.delegate mediaPlayerMediaChange];
}

-(BOOL)playing {
    return self.player.playing;
}

- (void)play {
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)stop {
    [self.player stop];
}

@end
