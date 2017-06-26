//
//  PHVideo.h
//  MediaPlayer
//
//  Created by YLCHUN on 2017/5/15.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSInteger, PHVideoOptions) {
    PHVideoOptionsImageData     = 1<<1,
    PHVideoOptionsOriginURL     = 1<<2,
    PHVideoOptionsMapURL        = 1<<3
};

typedef void(^PHVideoResult)(NSData *imageData, NSURL* originURL, NSURL *mapURL);

@interface PHVideo : NSObject

@property (readonly) NSUInteger count;

-(void)videoWithIndex:(NSUInteger)index options:(PHVideoOptions)options res:(PHVideoResult)res;

+(void)convertMovWithSourceURL:(NSURL *)sourceUrl fileName:(NSString *)fileName saveExportFilePath:(NSString *)path;
@end





