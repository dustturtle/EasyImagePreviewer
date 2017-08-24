//
//  EasyImagePreviewHelper.m
//  TestImgPreview
//
//  Created by achen on 2017/8/23.
//  Copyright © 2017年 waiqin365. All rights reserved.
//

#import "EasyImagePreviewHelper.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/ALAsset.h>

@implementation EasyImagePreviewHelper

+ (id)imageFromInfo:(id)imageInfo
{
    if ([imageInfo isKindOfClass:[ALAsset class]])
    {
        return [UIImage imageWithCGImage:[imageInfo aspectRatioThumbnail]];
    }
    
    if ([imageInfo isKindOfClass:[PHAsset class]])
    {
        __block UIImage *image = nil;
        
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        options.resizeMode = PHImageRequestOptionsResizeModeNone;
        
        CGSize size = CGSizeMake(((PHAsset *)imageInfo).pixelWidth, ((PHAsset *)imageInfo).pixelHeight);
        [[PHImageManager defaultManager] requestImageForAsset:imageInfo targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage *__nullable result, NSDictionary *__nullable info) {
            image = result;
        }];
        
        return image;
    }
    
    if ([imageInfo isKindOfClass:[NSString class]])
    {
        // 不使用imageName方法，避免将图片信息加载到全局缓存中。
        
        NSString *imageName = (NSString *)imageInfo;
        
        NSString *lowercaseName = [imageName lowercaseString];
        
        if ([lowercaseName hasPrefix:@"http:"] || [lowercaseName hasPrefix:@"https:"])
        {
            // 网络图片路径
            return [NSURL URLWithString:imageName];
        }
        else
        {
            // 本地文件名
            NSArray *imageStrs = [imageName componentsSeparatedByString:@"."];
            if ([imageStrs count] == 1)
            {
                return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageStrs[0] ofType:@"png"]];
            }
            else if ([imageStrs count] == 2)
            {
                return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imageStrs[0] ofType:imageStrs[1]]];
            }
            else
            {
                NSLog(@"ERROR! IMAGE NAME STRING INVALID!");
                return nil;
            }
        }
    }
    
    if ([imageInfo isKindOfClass:[NSURL class]])
    {
        if ([imageInfo isFileReferenceURL])
        {
            NSURL *imageFileUrl = (NSURL *)imageInfo;
            return [UIImage imageWithContentsOfFile:imageFileUrl.path];
        }
        else
        {
            return imageInfo;
        }
    }
    
    NSLog(@"ERROR IMAGE INFO TYPE!");
    
    return nil;
}

@end
