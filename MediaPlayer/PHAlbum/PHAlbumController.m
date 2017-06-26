//
//  PHAlbumController.m
//  MediaPlayer
//
//  Created by YLCHUN on 2017/6/26.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "PHAlbumController.h"

#import "PHAlbumCell.h"
#import "ViewController.h"
#import "FlowNavigationViewController.h"
#import "PHVideo.h"

@interface PHAlbumController ()
@property (nonatomic, strong) PHVideo* phVideo;
@end

@implementation PHAlbumController

- (instancetype)init {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.itemSize = PHAlbumCellSize();
    layout.minimumInteritemSpacing = 8;
    layout.minimumLineSpacing = 8;
    return [super initWithCollectionViewLayout:layout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.phVideo = [[PHVideo alloc] init];

    // Uncomment the following line to preserve selection between presentations
     self.clearsSelectionOnViewWillAppear = NO;
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[PHAlbumCell class] forCellWithReuseIdentifier:PHAlbumCellId];
    [self.collectionView reloadData];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

//- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.phVideo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PHAlbumCellId forIndexPath:indexPath];
    
    [self.phVideo videoWithIndex:indexPath.row options:PHVideoOptionsImageData res:^(NSData *imageData, NSURL *originURL, NSURL *mapURL) {
        cell.image = [UIImage imageWithData:imageData];
    }];
    return cell;
}

#pragma mark <UICollectionViewDelegate>

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ViewController *vc = (ViewController*)self.navigationController.presentingViewController;
    __weak typeof(self) wself = self;
    [self.phVideo videoWithIndex:indexPath.row options:PHVideoOptionsMapURL res:^(NSData *imageData, NSURL *originURL, NSURL *mapURL) {
        [wself dismisFlowViewControllerWithAnimated:YES completion:^{
            [vc playWithURL:mapURL];
        }];
    }];
}

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
/*
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
