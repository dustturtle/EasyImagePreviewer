//
//  EasyImagePreviewHelper.h
//  TestImgPreview
//
//  Created by achen on 2017/8/23.
//  Copyright © 2017年 waiqin365. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EasyImagePreviewHelper : NSObject

// 对于图片输入信息的处理；输出的值只有UIImage、图片的Url、nil 这三种情况。
+ (id)imageFromInfo:(id)imageInfo;

@end
