//
//  ViewController.m
//  TestImgPreview
//
//  Created by achen on 2017/8/23.
//  Copyright © 2017年 waiqin365. All rights reserved.
//

#import "ViewController.h"
#import "EasyImagePreviewer.h"

@interface ViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    [self setupScrollView];
//    
//    [self setupSubViews];
}

- (IBAction)preview:(id)sender
{
//    EasyImagePreviewer *previewVC = [[EasyImagePreviewer alloc] init];
//    previewVC.imageInfos = @[@"testhome0.jpeg", @"testhome1.jpeg", @"testhome2.jpeg"];
//    previewVC.index = 2;
//    [self presentViewController:previewVC animated:YES completion:nil];
    
    
    EasyImagePreviewer *previewVC = [[EasyImagePreviewer alloc] init];
    previewVC.imageInfos = @[@"testhome0.jpeg", @"http://mpic.tiankong.com/2b8/624/2b86240e7413f0db5015817656d559c6/640.jpg?x-oss-process=image/resize,m_lfit,h_600,w_600", @"testhome2.jpeg"];
    previewVC.index = 2;
    [self presentViewController:previewVC animated:YES completion:nil];
}

- (void)setupScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    
    self.scrollView.contentSize = CGSizeMake(screenWidth * 3, screenHeight);
    
    [self.view addSubview:self.scrollView];
    
}

- (void)setupSubViews
{
    CGFloat screenWidth = self.view.bounds.size.width;
    CGFloat screenHeight = self.view.bounds.size.height;
    
    for (int i = 0; i < 3; i++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(screenWidth*i, 0, screenWidth, screenHeight)];
        NSString *imageName = [NSString stringWithFormat:@"testhome%@.jpeg", @(i)];
        imgView.image = [UIImage imageNamed:imageName];
        [self.scrollView addSubview:imgView];
    }
}

//- (void)reloadImage
//{
//    
//}
//
//#pragma mark - UIScrollViewDelegate
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    NSLog(@"scrollViewDidEndDecelerating");
//    [self reloadImage];
//    
//    //self.scrollView.contentOffset = CGPointMake(self.view.bounds.size.width, 0.0);
//
//}

@end
