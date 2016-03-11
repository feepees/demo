//
//  ImageScrollView.h
//  HZDuban
//
//  Created by  on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>


@interface ImageScrollView : UIScrollView <UIScrollViewDelegate>
{
	UIImage *image;
	UIImageView *imageView;
}

@property (nonatomic, retain) UIImage *image;

@end
