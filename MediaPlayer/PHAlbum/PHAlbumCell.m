//
//  PHAlbumCell.m
//  MediaPlayer
//
//  Created by YLCHUN on 2017/6/26.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "PHAlbumCell.h"

//static NSString * const PHAlbumCellId = @"PHAlbumCell";
CGSize PHAlbumCellSize() {
    CGFloat n = (CGRectGetWidth([UIScreen mainScreen].bounds)-8.0)/4.0;
    return CGSizeMake(n, n);
}

@interface PHAlbumCell ()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *selectionBadgeImageView;
@property (nonatomic, strong) UIView *selectionBadgeView;
@end

@implementation PHAlbumCell


-(UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.contentView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
        [self.contentView addSubview:_imageView];
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
    }
    return _imageView;
}

-(UIView *)selectionBadgeView {
    if (!_selectionBadgeView) {
        _selectionBadgeView = [[UIView alloc] initWithFrame:self.contentView.bounds];
        [self.contentView addSubview:_selectionBadgeView];
        _selectionBadgeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;
        [_selectionBadgeView addSubview:self.selectionBadgeImageView];
        _selectionBadgeView.hidden = YES;
    }
    return _selectionBadgeView;
}

-(UIImageView *)selectionBadgeImageView {
    if (!_selectionBadgeImageView) {
        _selectionBadgeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.contentView.bounds)-31, CGRectGetHeight(self.contentView.bounds)-31, 31, 31)];
        _selectionBadgeImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        _selectionBadgeImageView.image = [UIImage imageNamed:@"selectionBadgeImage"];
    }
    return _selectionBadgeImageView;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.selectionBadgeView.hidden = !selected;
}

-(void)setImage:(UIImage *)image {
    self.imageView.image = image;
}
-(UIImage *)image {
    return self.imageView.image;
}

@end
