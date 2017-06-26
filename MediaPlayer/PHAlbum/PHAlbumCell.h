//
//  PHAlbumCell.h
//  MediaPlayer
//
//  Created by YLCHUN on 2017/6/26.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString * const PHAlbumCellId = @"PHAlbumCell";
CGSize PHAlbumCellSize();
@interface PHAlbumCell : UICollectionViewCell

@property (nonatomic, copy) UIImage *image;
@end
