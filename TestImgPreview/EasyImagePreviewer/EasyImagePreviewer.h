//
//  EasyImagePreviewer.h
//  TestImgPreview
//  一个极简使用的独立图片预览组件（仅依赖sdwebimage）；支持多种类型的数据源传递。
//  希望可以给大家带来一个容易理解、容易使用的预览组件，大家如果有需要也可以在此基础上进行修改和二次开发。
//
//  current Features:
//  1. 支持多种格式的输入
//  2. 极简的使用方式和有限的功能扩展
//  3. 支持自定义文字的标题
//  4. 图片支持缩放
//  5. 单击隐藏标题栏，双击缩放图片
//  6. 进入时指定index
//  7. 隐藏系统的状态栏
//
//  目前不支持的特性：1. 无限循环滚动 2. 保存到系统相册  3. 预览中的删除
//  其中2、3后续可能会实现，1的意义不大，暂无支持计划。
//
//  Created by achen on 2017/8/23.
//  Copyright © 2017年 waiqin365. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EasyImagePreviewer : UIViewController

// 其中每一个元素都可以是UIImage对象、单纯的图片文件名(bundle中)、fileUrl、网络图片Url（可以是字符串）、PHAsset对象、ALAsset对象
// 中的任意一种；在previewer内部将其处理成image对象列表供展示。
// Must set.
@property (nonatomic, strong) NSArray *imageInfos;

// Optional; 默认为预览，一般情况下可以不用设置。
@property (nonatomic, strong) NSString *titleStr;

// Optional; 当前展示的index；不设置的情况下默认为0（展示第一幅图）。
@property (nonatomic, assign) NSUInteger index;

@end
