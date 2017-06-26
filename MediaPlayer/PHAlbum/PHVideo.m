//
//  PHVideo.m
//  MediaPlayer
//
//  Created by YLCHUN on 2017/5/15.
//  Copyright © 2017年 ylchun. All rights reserved.
//

#import "PHVideo.h"
#import <Photos/Photos.h>

@interface PHVideoUnit : NSObject
@property (nonatomic, copy) NSURL *originURL;
@property (nonatomic, copy) NSURL *mapURL;
@property (nonatomic, copy) NSData *imageData;
@property (nonatomic, copy) PHVideoResult result;
@property (nonatomic, assign) PHVideoOptions options;
@property (nonatomic, assign) PHVideoOptions options_unit;
@end
@implementation PHVideoUnit

-(void)setOptions_unit:(PHVideoOptions)options_unit {
    _options_unit = options_unit;
    if (_options_unit == self.options && self.options != 0 && self.result) {
        NSURL * originURL;
        NSURL * mapURL;
        NSData *imageData;
        if (self.options & PHVideoOptionsImageData) {
            imageData = self.imageData;
        }
        if (self.options & PHVideoOptionsOriginURL) {
            originURL = self.originURL;
        }
        if (self.options & PHVideoOptionsMapURL) {
            mapURL = self.mapURL;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.result(imageData, originURL, mapURL);
            self.result = nil;
            _options_unit = 0;
        });
    }
}
@end

@interface PHVideo ()
@property (nonatomic, strong) PHFetchResult<PHAsset *> *assets;
@property (nonatomic, strong) NSMutableArray<PHVideoUnit *> *videoUnitArray;
@property (nonatomic, strong) PHImageRequestOptions *requestOptions_image;
@property (nonatomic, strong) PHVideoRequestOptions *requestOptions_video;

@end
@implementation PHVideo

-(instancetype)init {
    self = [super init];
    if (self) {
        [self construction];
    }
    return self;
}

-(NSUInteger)count {
    return self.assets.count;
}

-(void)videoWithIndex:(NSUInteger)index options:(PHVideoOptions)options res:(PHVideoResult)res {
    if (res == nil || options == 0) {
        return;
    }
    PHVideoUnit *videoUnit = self.videoUnitArray[index];
    videoUnit.options = options;
    videoUnit.result = res;
    videoUnit.options_unit = 0;
    PHAsset *videoAsset = self.assets[index];
    if (options & PHVideoOptionsImageData) {
        if (!videoUnit.imageData) {
            [[PHCachingImageManager defaultManager] requestImageDataForAsset:videoAsset options:self.requestOptions_image resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                videoUnit.imageData = imageData;
                videoUnit.options_unit = videoUnit.options_unit | PHVideoOptionsImageData;
            }];
        }else{
            videoUnit.options_unit = videoUnit.options_unit | PHVideoOptionsImageData;
        }
    }

    if (options & PHVideoOptionsOriginURL) {
        if (!videoUnit.originURL) {
            [[PHImageManager defaultManager] requestAVAssetForVideo:videoAsset options:self.requestOptions_video resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                videoUnit.originURL = ((AVURLAsset*)asset).URL;
                videoUnit.options_unit = videoUnit.options_unit | PHVideoOptionsOriginURL;
            }];
        }else {
            videoUnit.options_unit = videoUnit.options_unit | PHVideoOptionsOriginURL;
        }
    }
    
    if (options & PHVideoOptionsMapURL) {
        if (!videoUnit.mapURL) {
            void(^requestMapURL)(NSString *pathExtension) = ^(NSString *pathExtension){
                [[PHImageManager defaultManager] requestExportSessionForVideo:videoAsset options:self.requestOptions_video exportPreset:AVAssetExportPresetHighestQuality resultHandler:^(AVAssetExportSession * _Nullable exportSession, NSDictionary * _Nullable info) {
                    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
                    [formater setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
                    //导出地址
                    NSString *videoPath = [NSHomeDirectory() stringByAppendingFormat:@"/Library/Caches/output-%@.%@", [formater stringFromDate:[NSDate date]],pathExtension];
                    exportSession.outputURL = [NSURL fileURLWithPath: videoPath];
                    //导出类型
                    if ([pathExtension isEqualToString:@"MOV"]) {
                        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
                    }else if ([pathExtension isEqualToString:@"MP4"]) {
                        exportSession.outputFileType = AVFileTypeMPEG4;
                    }
                    //导出
                    [exportSession exportAsynchronouslyWithCompletionHandler:^{
                        switch (exportSession.status) {
                            case AVAssetExportSessionStatusCompleted:{
//                                NSData *data = [NSData dataWithContentsOfFile:videoPath options:NSDataReadingMappedIfSafe error:nil];//NSData 数据映射
                                videoUnit.mapURL = exportSession.outputURL;
                            }
                                break;
                            default:
                                break;
                        }
                        videoUnit.options_unit = videoUnit.options_unit | PHVideoOptionsMapURL;
                    }];
                }];
            };
            if (!videoUnit.originURL) {
                [[PHImageManager defaultManager] requestAVAssetForVideo:videoAsset options:self.requestOptions_video resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    videoUnit.originURL = ((AVURLAsset*)asset).URL;
                    requestMapURL(videoUnit.originURL.pathExtension);
                }];
            }else{
                requestMapURL(videoUnit.originURL.pathExtension);
            }
        }else {
            videoUnit.options_unit = videoUnit.options_unit | PHVideoOptionsMapURL;
        }
    }
}


-(void) construction {
    self.requestOptions_image = [[PHImageRequestOptions alloc] init];//请求选项设置
    self.requestOptions_image.resizeMode = PHImageRequestOptionsResizeModeExact;//自定义图片大小的加载模式
    self.requestOptions_image.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
//    self.requestOptions_image.synchronous = YES;//是否同步加载
    self.requestOptions_video = [[PHVideoRequestOptions alloc] init];
    self.requestOptions_video.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    
    self.assets = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:nil]; //得到所有视屏
    self.videoUnitArray = [NSMutableArray arrayWithCapacity:self.assets.count];
    for (int i = 0; i<self.assets.count; i++) {
        self.videoUnitArray[i] = [[PHVideoUnit alloc] init];
    }
}

+(void)convertMovWithSourceURL:(NSURL *)sourceUrl fileName:(NSString *)fileName saveExportFilePath:(NSString *)path {
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:sourceUrl options:nil];
    NSArray *compatiblePresets=[AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];//输出模式标识符的集合
    if ([compatiblePresets containsObject:AVAssetExportPresetMediumQuality]) {
        AVAssetExportSession *exportSession=[[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
        NSString *resultPath = [path stringByAppendingFormat:@"/%@.mp4",fileName];
        exportSession.outputURL=[NSURL fileURLWithPath:resultPath];
        exportSession.outputFileType = AVFileTypeMPEG4;
        exportSession.shouldOptimizeForNetworkUse = YES;
        [exportSession exportAsynchronouslyWithCompletionHandler:^(void){//转码视频
            switch (exportSession.status) {
                case AVAssetExportSessionStatusCancelled:
                    NSLog(@"转码状态：取消");
                    break;
                case AVAssetExportSessionStatusUnknown:
                    NSLog(@"转码状态：未知");
                    break;
                case AVAssetExportSessionStatusWaiting:
                    NSLog(@"转码状态：等待");
                    break;
                case AVAssetExportSessionStatusExporting:
                    NSLog(@"转码状态：转码中");
                    break;
                case AVAssetExportSessionStatusCompleted:
                {
                    NSArray *files=[[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
                    for (NSString *fn in files) {
                        if ([resultPath isEqualToString:fn]) {
                            NSLog(@"转码状态：完成");
                            return ;
                        }
                    }
                    NSLog(@"转码状态：失败");
                    break;
                }
                case AVAssetExportSessionStatusFailed:
                    NSLog(@"转码状态：失败");
                    break;
            }
        }];
    }
}
@end
