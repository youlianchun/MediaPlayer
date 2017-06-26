//
//  ViewController.m
//  MediaPlayer
//
//  Created by YLCHUN on 2017/5/11.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "ViewController.h"
#import "MediaPlayerControl.h"
#import "PHAlbumController.h"

#import "FlowNavigationViewController.h"
#import "VLCPlayer.h"

@interface ViewController ()
@property (nonatomic, retain) MediaPlayerControl *playerControl;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(MediaPlayerControl *)playerControl {
    if (!_playerControl) {
        VLCPlayer *p = [[VLCPlayer alloc] init];
        MediaPlayerControl *playerControl = [[MediaPlayerControl alloc] initWithPlayer:p];
        playerControl.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width/16*9);
        playerControl.center = self.view.center;
        [self.view addSubview:playerControl];
        _playerControl = playerControl;
    }
    return _playerControl;
}

- (IBAction)butAction:(id)sender {
    PHAlbumController *phACVC = [[PHAlbumController alloc] init];
    [self presentFlowViewController:phACVC animated:YES];

}

-(void)playWithURL:(NSURL*)url {
    self.playerControl.player.mediaURL = url;
    [self.playerControl.player play];
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}


@end
