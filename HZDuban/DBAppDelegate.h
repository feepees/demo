//
//  DBAppDelegate.h
//  HZDuban2
//
//  Created by  on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Reachability;
@interface DBAppDelegate : UIResponder <UIApplicationDelegate>
{
    Reachability  *hostReach;
}
@property (strong, nonatomic) UIWindow *window;

@end
