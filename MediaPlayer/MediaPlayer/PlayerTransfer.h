//
//  PlayerTransfer.h
//  MediaPlayer
//
//  Created by YLCHUN on 2017/5/15.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MediaPlayerState) {
    MediaPlayerStateStopped,
    MediaPlayerStatePlaying,
    MediaPlayerStatePaused
};

typedef NS_ENUM(NSInteger, MediaPlayerBufferState) {
    MediaPlayerBufferStateOpening,        ///< Stream is opening
    MediaPlayerBufferStateBuffering,      ///< Stream is buffering
    MediaPlayerBufferStateEnded,          ///< Stream has ended
    MediaPlayerBufferStateError,          ///< Player has generated an error
    MediaPlayerBufferStatePaused,         ///< Stream is paused
};

@protocol PlayerTransferDelegate <NSObject>

- (void)mediaPlayerBufferStateChanged:(MediaPlayerBufferState)state;

- (void)mediaPlayerStateChanged:(MediaPlayerState)state;
- (void)mediaPlayerTimeChanged:(NSString*)playedTime allTime:(NSString*)allTime progress:(double)progress;
- (void)mediaPlayerMediaChange;

@end

@protocol PlayerTransferProtocol <NSObject>

@property (weak, nonatomic) id<PlayerTransferDelegate> delegate;

-(void)setMediaURL:(NSURL *)mediaURL;

@property (nonatomic, readonly) BOOL playing;

- (void)setDisplayView:(UIView*)view;

- (void)play;

- (void)pause;

- (void)stop;



@end
