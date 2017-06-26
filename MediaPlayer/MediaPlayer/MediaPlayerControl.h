//
//  MediaPlayer.h
//  MediaPlayer
//
//  Created by YLCHUN on 2017/5/11.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlayerTransfer.h"

@interface MediaPlayerControl : UIView
-(instancetype)initWithPlayer:(NSObject<PlayerTransferProtocol>*)player;

@property (nonatomic, readonly) NSObject<PlayerTransferProtocol>* player;


@end
