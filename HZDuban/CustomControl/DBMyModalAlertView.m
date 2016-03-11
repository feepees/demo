//
//  DBMyModalAlertView.m
//  HZDuban
//
//  Created by  on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBMyModalAlertView.h"

@implementation DBMyModalAlertView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (int)showModal 
{ 
    self.delegate = self; 
    self.tag = -1; 
    [self show]; 
    CFRunLoopRun(); 
    return self.tag; 
} 

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex 
{ 
    alertView.tag = buttonIndex; 
    alertView.delegate = nil; 
    CFRunLoopStop(CFRunLoopGetCurrent()); 
} 

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
