//
//  EasyImagePreviewer.m
//  TestImgPreview
//
//  Created by achen on 2017/8/23.
//  Copyright © 2017年 waiqin365. All rights reserved.
//
//  TODO:bundle内部的国际化。
//  TODO:性能优化方面：1.复用页面控件; 2.改进Url缓存方式; 3.scroll相关处理的逻辑优化。
//
//

#import "EasyImagePreviewer.h"
#import "EasyImagePreviewHelper.h"
#import "UIImageView+WebCache.h"

#if (!defined(DEBUG))
#define NSLog(...)
#endif

#define kImgZoomScaleMin 1.0f
#define kImgZoomScaleMax 2.0f

#define kIsHaveStatusBar NO  // 目前用宏控制，后面有可能改为对外开放的配置项。

@interface EasyImagePreviewer () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *imageViews;
@property (nonatomic, strong) NSMutableArray *subScrolls;

@property (nonatomic, strong) UIView *titleView;

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, assign) BOOL isTitleAnimating;

@property (nonatomic, assign) CGFloat statusHeight;

@end

@implementation EasyImagePreviewer

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.statusHeight = kIsHaveStatusBar ? 20.0f:0.0f;
    
    self.imageViews = [NSMutableArray array];
    self.subScrolls = [NSMutableArray array];
    
    [self setupScrollView];
    
    [self setupSubViews];
    
    [self setupGestures];
    
    [self setupTitleView];
    
    [self autoHideTitleBar];
}

- (void)autoHideTitleBar
{
    [self performSelector:@selector(singleTapped:) withObject:nil afterDelay:2.0f];
}

- (void)setupScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;

    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    
    self.scrollView.contentSize = CGSizeMake(screenWidth * [self.imageInfos count], screenHeight);
    self.scrollView.contentOffset = CGPointMake(screenWidth * self.index, 0);
    
    [self.view addSubview:self.scrollView];
}

- (void)setupSubViews
{
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    
    NSUInteger imageCount = [self.imageInfos count];
    
    for (int i = 0; i < imageCount; i++)
    {
        // 因为图片允许缩放，所以需要用scrollview包裹imageview,否则缩放时图片的frame不好处理，效果不能接受。
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(screenWidth*i, 0, screenWidth, screenHeight)];
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.delegate = self;
        scrollView.maximumZoomScale = kImgZoomScaleMax;
        scrollView.minimumZoomScale = kImgZoomScaleMin;
        [self.subScrolls addObject:scrollView];
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
        id image = [EasyImagePreviewHelper imageFromInfo:self.imageInfos[i]];
        if ([image isKindOfClass:[UIImage class]])
        {
            imgView.image = image;
        }
        else if ([image isKindOfClass:[NSURL class]])
        {
            [imgView sd_setImageWithURL:image];
        }
        else
        {
            NSLog(@"error! image nil or invalid!");
        }
        
        [self.imageViews addObject:imgView];
        
        // 添加双击手势
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapped:)];
        doubleTap.numberOfTapsRequired = 2;
        [scrollView addGestureRecognizer:doubleTap];
        
        // 添加单击手势
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapped:)];
        singleTap.numberOfTapsRequired = 1;
        [scrollView addGestureRecognizer:singleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap]; // 解决单击和双击手势冲突问题（否则双击也会触发单击）
        
        [scrollView addSubview:imgView];
        [self.scrollView addSubview:scrollView];
    }
}

- (void)setupGestures
{
    //长按事件
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    longPress.minimumPressDuration = 0.5;
    [self.view addGestureRecognizer:longPress];
}

#pragma mark -Tap手势处理

- (void)singleTapped:(UITapGestureRecognizer *)tap
{
    if (self.isTitleAnimating)
    {
        return;
    }
    
    self.isTitleAnimating = YES;

    // NSLog(@"singleTapped");
    
    if (self.titleView.frame.origin.y < 0)
    {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             self.titleView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 44.0f+self.statusHeight);
                         }
                         completion:^(BOOL finished) {
                             self.isTitleAnimating = NO;
                         }];
    }
    else
    {
        [UIView animateWithDuration:0.3f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations: ^{
                             self.titleView.frame = CGRectMake(0, -(44.0f+self.statusHeight), self.view.bounds.size.width, 44.0f+self.statusHeight);
                         }
                         completion:^(BOOL finished) {
                             self.isTitleAnimating = NO;
                         }];
    }
}

- (void)doubleTapped:(UITapGestureRecognizer *)tap
{
    NSLog(@"doubleTapped");
    
    UIScrollView *currentScroll = self.subScrolls[self.index];
    //判断当前放大的比例
    if (currentScroll.zoomScale > kImgZoomScaleMin)
    {
        //缩小
        [currentScroll setZoomScale:kImgZoomScaleMin animated:YES];
    }
    else
    {
        //放大
        [currentScroll setZoomScale:kImgZoomScaleMax animated:YES];
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)longPress
{
    NSLog(@"current index = %@", @(self.index));
    // currently do nothing! 可以用来保存图片到系统相册。 扩展需求，暂不实现。 
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
//        UIActionSheet *saveActionSheet = [[UIActionSheet alloc] initWithTitle:nil
//                                                                     delegate:self
//                                                            cancelButtonTitle:@"取消"
//                                                       destructiveButtonTitle:nil
//                                                            otherButtonTitles:@"保存图片", nil];
//        saveActionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
//        [saveActionSheet showInView:self.view];
    }
}

// 在此页面不显示statusBar.
- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)setupTitleView
{
    CGFloat screenWidth = self.view.bounds.size.width;
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 44.0f+self.statusHeight)];
    self.titleView.backgroundColor = [UIColor blackColor];
    self.titleView.alpha = 0.6f;
    [self.view addSubview:self.titleView];
    
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.statusHeight, 44, 44.0f+self.statusHeight)];
    [backBtn setImage:[UIImage imageNamed:@"preview_arrow_back"] forState:UIControlStateNormal];
    [self.titleView addSubview:backBtn];
    [backBtn addTarget:self action:@selector(backToPrevious) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.statusHeight, screenWidth, 44.0f+self.statusHeight)];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    NSString *titleString = [self.titleStr length] > 0 ? self.titleStr : @"预览";
    self.titleLabel.text = [NSString stringWithFormat:@"%@ %@/%@", titleString, @(self.index+1), @([self.imageInfos count])];
    [self.titleView addSubview:self.titleLabel];
}

- (void)backToPrevious
{
    if (self.navigationController != nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

# pragma mark - UIScrollViewDelegate methods
// 返回当前scroll中的那个需要缩放的imageView
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [self imageViewFromScroll:scrollView];
}

// 让图片居中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"scrollViewDidZoom");
    UIImageView *imgView = [self imageViewFromScroll:scrollView];
    
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    imgView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view
{
    NSLog(@"WillBeginZooming");
}


- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(nullable UIView *)view
                        atScale:(CGFloat)scale
{
    NSLog(@"scrollViewDidEndZooming view is:%@,view's frame:%@",view,NSStringFromCGRect(view.frame));
}

// 滚动外围的scroll时，重置zoom过的image；此处可以优化（记录zoom操作，仅zoom时才处理）。 TODO: 逻辑优化，提升性能。
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.scrollView)
    {
        CGFloat screenWidth = self.view.bounds.size.width;
        CGFloat screenHeight = self.view.bounds.size.height;
        
        CGFloat offsetX = scrollView.contentOffset.x;
        
        self.index = llround(offsetX/screenWidth);
        NSString *titleString = [self.titleStr length] > 0 ? self.titleStr : @"预览";
        self.titleLabel.text = [NSString stringWithFormat:@"%@ %@/%@", titleString, @(self.index+1), @([self.imageInfos count])];
        
        //NSLog(@"current index = %@", @(self.index));
        
        NSUInteger count = [self.imageInfos count];
        for (NSUInteger i = 0; i < count; i++)
        {
            UIScrollView *scroll = self.subScrolls[i];
            UIImageView *imageView = self.imageViews[i];
            
            if (scroll.zoomScale != 1.0f)
            {
                NSLog(@"reset zoom");
                [scroll setZoomScale:1.0f];
                imageView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
            }
            else
            {
                //NSLog(@"do nothing");
            }
        }
    }
}

# pragma mark - helper methods
- (UIImageView *)imageViewFromScroll:(UIScrollView *)scrollView
{
    NSUInteger index = 0;
    NSUInteger count = [self.imageInfos count];
    
    for (NSUInteger i = 0; i < count; i++)
    {
        if (scrollView == self.subScrolls[i])
        {
            index = i;
            break;
        }
    }
    
    return self.imageViews[index];
}

@end
