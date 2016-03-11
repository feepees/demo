//
//  ImageScrollView.m
//  HZDuban
//
//  Created by  on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ImageScrollView.h"


@implementation ImageScrollView


@synthesize image;

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

#pragma mark -
#pragma mark === Intilization ===
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
	{
		self.delegate = self;
		self.minimumZoomScale = 0.5;
		self.maximumZoomScale = 2.5;
		self.showsVerticalScrollIndicator = NO;
		self.showsHorizontalScrollIndicator = NO;
		
		imageView  = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
		imageView.contentMode = UIViewContentModeCenter;
		[self addSubview:imageView];
    }
    return self;
}

- (void)setImage:(UIImage *)img
{
	imageView.image = img;
}

#pragma mark -
#pragma mark === UIScrollView Delegate ===
#pragma mark -
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{	
	return imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
	//NSLog(@"%s", _cmd);
	
	CGFloat zs = scrollView.zoomScale;
	zs = MAX(zs, 1.0);
	zs = MIN(zs, 2.0);	
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.3];		
	scrollView.zoomScale = zs;	
	[UIView commitAnimations];
}

#pragma mark -
#pragma mark === UITouch Delegate ===
#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	//NSLog(@"%s", _cmd);
	
	UITouch *touch = [touches anyObject];
	
	if ([touch tapCount] == 2) 
	{
		//NSLog(@"double click");
		
		CGFloat zs = self.zoomScale;
		zs = (zs == 1.0) ? 2.0 : 1.0;
		
		[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.3];			
		self.zoomScale = zs;	
		[UIView commitAnimations];
	}
}

#pragma mark -
#pragma mark === dealloc ===
#pragma mark -
- (void)dealloc
{
	[image release];
	[imageView release];
	
    [super dealloc];
}


@end
