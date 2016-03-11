//
//  DBMySegue.m
//  HZDuban2
//
//  Created by  on 12-7-2.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBMySegue.h"

@implementation DBMySegue

@synthesize lastAnimation;

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

- (void)perform
{
    // add your own animation code here
    
   // NSArray * arr = [[self.sourceViewController view].layer animationKeys];
    
     //[[self sourceViewController] presentModalViewController:[self destinationViewController] animated:NO];
//    
    //return;
    
    /*
    __block UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    __block UIViewController *destinationController = (UIViewController*)[self destinationViewController];                    
    
    CATransition* transition = [CATransition animation];
    transition.duration = 1;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom  
    
    [sourceViewController.view.layer addAnimation:animation forKey:@"animation"];
    
    //[[self sourceViewController] presentModalViewController:[self destinationViewController] animated:YES];
    [sourceViewController presentModalViewController:destinationController animated:YES];
    //[sourceViewController.navigationController pushViewController:destinationController animated:NO];
    */
    
    
//    CATransition *animation = [CATransition animation];
//    animation.delegate = self;
//    animation.duration = 0.5f * 1;        // 持续时间
//    animation.timingFunction = UIViewAnimationCurveEaseInOut;
//	animation.fillMode = kCAFillModeForwards;
//	animation.endProgress = 0.3;
//	animation.removedOnCompletion = NO;
//	
//    animation.type = @"pageCurl";//101
//    [animation setSubtype:kCATransitionFromRight];
	
        [[self.sourceViewController view].layer removeAllAnimations];
	//[[self.sourceViewController view].layer addAnimation:animation forKey:@"animation"];
    

     [[self sourceViewController] presentModalViewController:[self destinationViewController] animated:YES];
    
	//self.lastAnimation = animation;
//	if(1 == 1)
		//[[self.sourceViewController view] exchangeSubviewAtIndex:1 withSubviewAtIndex:0];//Just remove, not release or dealloc
//	else
//    {
//		for (int i = 0; i < [[self.sourceViewController view ].subviews count]; i++) 
//        {
//			[[[self.sourceViewController view ].subviews objectAtIndex:i] setUserInteractionEnabled:NO];
//		}
//		isHalfAnimation = YES;
//	}

   // - (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
    //[[self sourceViewController] presentViewController:[self destinationViewController] animated:NO completion:NULL];
    
    //[[self sourceViewController] presentModalViewController:[self destinationViewController] animated:NO];

    //UIViewController *current = self.sourceViewController;
    //UIViewController *next = self.destinationViewController;
    //[current.navigationController pushViewController:next animated:YES];
}


//- (void)doPrivateCATransition:(id)sender
//{
//	//http://www.iphonedevwiki.net/index.php?title=UIViewAnimationState
//	/*
//     Don't be surprised if Apple rejects your app for including those effects,
//     and especially don't be surprised if your app starts behaving strangely after an OS update.
//     */
//	CATransition *animation = [CATransition animation];
//    animation.delegate = self;
//    animation.duration = 0.5f * 0.3;
//    animation.timingFunction = UIViewAnimationCurveEaseInOut;
//	animation.fillMode = kCAFillModeForwards;
//	animation.endProgress = 0.3;
//	animation.removedOnCompletion = NO;
//	
//    animation.type = @"pageCurl";//101
//	
//	[self.view.layer addAnimation:animation forKey:@"animation"];
//	self.lastAnimation = animation;
//	if(0.3 == 1)
//		[self.view exchangeSubviewAtIndex:1 withSubviewAtIndex:0];//Just remove, not release or dealloc
//	else
//    {
//		for (int i = 0; i < [self.view.subviews count]; i++) 
//        {
//			[[self.view.subviews objectAtIndex:i] setUserInteractionEnabled:NO];
//		}
//		isHalfAnimation = YES;
//	}
//}


@end
