//
//  MJPhotoBrowser.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <QuartzCore/QuartzCore.h>
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "SDWebImageManager+MJ.h"
#import "MJPhotoView.h"
#import "MJPhotoToolbar.h"

#define kPadding 10
#define kPhotoViewTagOffset 1000
#define kPhotoViewIndex(photoView) ([photoView tag] - kPhotoViewTagOffset)

@interface MJPhotoBrowser () <MJPhotoViewDelegate>
{
    // 滚动的view
	UIScrollView *_photoScrollView;
    // 所有的图片view
	NSMutableSet *_visiblePhotoViews;
    NSMutableSet *_reusablePhotoViews;
    // 工具条
    MJPhotoToolbar *_toolbar;
    
    // 一开始的状态栏
    BOOL _statusBarHiddenInited;
}
@end

@implementation MJPhotoBrowser

#pragma mark - Lifecycle
- (void)loadView
{
    _statusBarHiddenInited = [UIApplication sharedApplication].isStatusBarHidden;
    // 隐藏状态栏
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.view = [[UIView alloc] init];
    self.view.frame = [UIScreen mainScreen].bounds;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
    {
        CGRect frame = self.view.frame;
        if (frame.size.width < frame.size.height) {
            CGFloat fWidth = frame.size.width;
            frame.size.width = frame.size.height;
            frame.size.height = fWidth;
            
        }
        frame.origin.x = 0;
        frame.origin.y = 0;
        
        self.view.frame = frame;
        CGAffineTransform at =CGAffineTransformMakeRotation(-M_PI/2);
        [self.view setTransform:at];
        frame = self.view.frame;
        frame.origin.x = 0;
        frame.origin.y = 0;
        [self.view setFrame:frame];
    }

	self.view.backgroundColor = [UIColor blackColor];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _bShowProgress = YES;
    // 1.创建UIScrollView
    [self createScrollView];
    
    // 2.创建工具条
    [self createToolbar];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self show];
}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
//{
//    if((UIInterfaceOrientationLandscapeLeft == interfaceOrientation) || (UIInterfaceOrientationLandscapeRight == interfaceOrientation))
//    {
//        return YES;
//    }
//    return NO;
//}
//- (BOOL)shouldAutorotate NS_AVAILABLE_IOS(6_0)
//{
//    return NO;
//}
////
//- (NSUInteger)supportedInterfaceOrientations NS_AVAILABLE_IOS(6_0)
//{
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//// Returns interface orientation masks.
////- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation NS_AVAILABLE_IOS(6_0);
//
//// The rotating header and footer views will slide out during the rotation and back in once it has completed.
////- (UIView *)rotatingHeaderView;     // Must be in the view hierarchy. Default returns nil.
////- (UIView *)rotatingFooterView;     // Must be in the view hierarchy. Default returns nil.
//
//
//// Notifies when rotation begins, reaches halfway point and ends.
//- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
//{
//    return;
//}
//
//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    return;
//}

- (void)show
{
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeLeft];
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self.view];
    [window.rootViewController addChildViewController:self];
    if (_currentPhotoIndex == 0) {
        [self showPhotos];
    }
}

#pragma mark - 私有方法
#pragma mark 创建工具条
- (void)createToolbar
{
    if (self.view.frame.size.width < self.view.frame.size.height)
    {
        CGFloat barHeight = 44;
        CGFloat barY = self.view.frame.size.width - barHeight;
        _toolbar = [[MJPhotoToolbar alloc] init];
        _toolbar.frame = CGRectMake(0, barY, self.view.frame.size.height, barHeight);
    }
    else{
        CGFloat barHeight = 44;
        CGFloat barY = self.view.frame.size.height - barHeight;
        _toolbar = [[MJPhotoToolbar alloc] init];
        _toolbar.frame = CGRectMake(0, barY, self.view.frame.size.width, barHeight);
    }

    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _toolbar.photos = _photos;
    [self.view addSubview:_toolbar];
    
    [self updateTollbarState];
}

#pragma mark 创建UIScrollView
- (void)createScrollView
{
    CGRect frame = self.view.bounds;
    frame.origin.x -= kPadding;
    frame.size.width += (2 * kPadding);
	_photoScrollView = [[UIScrollView alloc] initWithFrame:frame];
	_photoScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_photoScrollView.pagingEnabled = YES;
	_photoScrollView.delegate = self;
	_photoScrollView.showsHorizontalScrollIndicator = NO;
	_photoScrollView.showsVerticalScrollIndicator = NO;
	_photoScrollView.backgroundColor = [UIColor clearColor];
    _photoScrollView.contentSize = CGSizeMake(frame.size.width * _photos.count, 0);
	[self.view addSubview:_photoScrollView];
    _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * frame.size.width, 0);
}

- (void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    
    if (photos.count > 1) {
        _visiblePhotoViews = [NSMutableSet set];
        _reusablePhotoViews = [NSMutableSet set];
    }
    
    for (int i = 0; i<_photos.count; i++) {
        MJPhoto *photo = _photos[i];
        photo.index = i;
        photo.firstShow = i == _currentPhotoIndex;
    }
}

#pragma mark 设置选中的图片
- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    _currentPhotoIndex = currentPhotoIndex;
    
    for (int i = 0; i<_photos.count; i++) {
        MJPhoto *photo = _photos[i];
        photo.firstShow = i == currentPhotoIndex;
    }
    
    if ([self isViewLoaded]) {
        _photoScrollView.contentOffset = CGPointMake(_currentPhotoIndex * _photoScrollView.frame.size.width, 0);
        
        // 显示所有的相片
        [self showPhotos];
    }
}

#pragma mark - MJPhotoView代理
- (void)photoViewSingleTap:(MJPhotoView *)photoView
{
    [UIApplication sharedApplication].statusBarHidden = _statusBarHiddenInited;
    self.view.backgroundColor = [UIColor clearColor];
    
    // 移除工具条
    [_toolbar removeFromSuperview];
}

- (void)photoViewDidEndZoom:(MJPhotoView *)photoView
{
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
//    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)photoViewImageFinishLoad:(MJPhotoView *)photoView
{
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
}

#pragma mark 显示照片
- (void)showPhotos
{
    // 只有一张图片
    if (_photos.count == 1) {
        [self showPhotoViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = _photoScrollView.bounds;
	int firstIndex = (int)floorf((CGRectGetMinX(visibleBounds)+kPadding*2) / CGRectGetWidth(visibleBounds));
	int lastIndex  = (int)floorf((CGRectGetMaxX(visibleBounds)-kPadding*2-1) / CGRectGetWidth(visibleBounds));
    if (firstIndex < 0) firstIndex = 0;
    if (firstIndex >= _photos.count) firstIndex = _photos.count - 1;
    if (lastIndex < 0) lastIndex = 0;
    if (lastIndex >= _photos.count) lastIndex = _photos.count - 1;
	
	// 回收不再显示的ImageView
    NSInteger photoViewIndex;
	for (MJPhotoView *photoView in _visiblePhotoViews) {
        photoViewIndex = kPhotoViewIndex(photoView);
		if (photoViewIndex < firstIndex || photoViewIndex > lastIndex) {
			[_reusablePhotoViews addObject:photoView];
			[photoView removeFromSuperview];
		}
	}
    
	[_visiblePhotoViews minusSet:_reusablePhotoViews];
    while (_reusablePhotoViews.count > 2) {
        [_reusablePhotoViews removeObject:[_reusablePhotoViews anyObject]];
    }
	
	for (NSUInteger index = firstIndex; index <= lastIndex; index++) {
		if (![self isShowingPhotoViewAtIndex:index]) {
			[self showPhotoViewAtIndex:index];
		}
	}
}

#pragma mark 显示一个图片view
- (void)showPhotoViewAtIndex:(int)index
{
    MJPhotoView *photoView = [self dequeueReusablePhotoView];
    if (!photoView) { // 添加新的图片view
        photoView = [[MJPhotoView alloc] init];
        photoView.photoViewDelegate = self;
    }
    
    // 调整当期页的frame
    CGRect bounds = _photoScrollView.bounds;
    CGRect photoViewFrame = bounds;
    photoViewFrame.size.width -= (2 * kPadding);
    photoViewFrame.origin.x = (bounds.size.width * index) + kPadding;
    photoView.tag = kPhotoViewTagOffset + index;
    
    MJPhoto *photo = _photos[index];
    photoView.frame = photoViewFrame;
    photoView.photo = photo;
    
//    [photoView.photoLoadingView setHidden:!_bShowProgress];
    
    [_visiblePhotoViews addObject:photoView];
    [_photoScrollView addSubview:photoView];
    
    [self loadImageNearIndex:index];
}

#pragma mark 加载index附近的图片
- (void)loadImageNearIndex:(int)index
{
    if (index > 0) {
        MJPhoto *photo = _photos[index - 1];
        [SDWebImageManager downloadWithURL:photo.url];
    }
    
    if (index < _photos.count - 1) {
        MJPhoto *photo = _photos[index + 1];
        [SDWebImageManager downloadWithURL:photo.url];
    }
}

#pragma mark index这页是否正在显示
- (BOOL)isShowingPhotoViewAtIndex:(NSUInteger)index {
	for (MJPhotoView *photoView in _visiblePhotoViews) {
		if (kPhotoViewIndex(photoView) == index) {
           return YES;
        }
    }
	return  NO;
}

#pragma mark 循环利用某个view
- (MJPhotoView *)dequeueReusablePhotoView
{
    MJPhotoView *photoView = [_reusablePhotoViews anyObject];
	if (photoView) {
		[_reusablePhotoViews removeObject:photoView];
	}
	return photoView;
}

#pragma mark 更新toolbar状态
- (void)updateTollbarState
{
    _currentPhotoIndex = _photoScrollView.contentOffset.x / _photoScrollView.frame.size.width;
    _toolbar.currentPhotoIndex = _currentPhotoIndex;
    
    if ([self.delegate respondsToSelector:@selector(photoBrowser:didChangedToPageAtIndex:)]) {
        [self.delegate photoBrowser:self didChangedToPageAtIndex:_currentPhotoIndex];
    }
}

#pragma mark - UIScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	[self showPhotos];
    [self updateTollbarState];
}
@end