//
//  NSVolume.m
//  MediaPlayer
//
//  Created by YLCHUN on 2017/5/11.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "NSVolume.h"
#import <MediaPlayer/MediaPlayer.h>
#import <UIKit/UIKit.h>

@interface NSVolume ()
@property (nonatomic, retain) MPVolumeView *volumeView;
@property (nonatomic, retain) UISlider *volumeSlider;
@end

@implementation NSVolume

static NSVolume* _kSharedVolume;

+ (instancetype)sharedVolume {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kSharedVolume = [[self alloc] init];
    });
    return _kSharedVolume;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _kSharedVolume = [super allocWithZone:zone];
    });
    return _kSharedVolume;
}

- (id)copyWithZone:(NSZone *)zone {
    return _kSharedVolume;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _kSharedVolume;
}



- (UISlider *)volumeSlider {
    if (!_volumeSlider) {
        for (UIControl *view in self.volumeView.subviews) {
            if ([view.superclass isSubclassOfClass:[UISlider class]]) {
                _volumeSlider = (UISlider *)view;
            }
        }
    }
    return _volumeSlider;
}

- (MPVolumeView *)volumeView {
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] init];
    }
    return _volumeView;
}

-(double)value {
    return self.volumeSlider.value;
}

-(void)setValue:(double)value {
    self.volumeSlider.value = value;
}

@end
