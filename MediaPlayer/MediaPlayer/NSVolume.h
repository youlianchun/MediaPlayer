//
//  NSVolume.h
//  MediaPlayer
//
//  Created by YLCHUN on 2017/5/11.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSVolume : NSObject

@property (nonatomic, assign) double value;

+ (instancetype)sharedVolume;

@end
