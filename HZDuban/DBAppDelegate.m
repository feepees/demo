//
//  DBAppDelegate.m
//  HZDuban2
//
//  Created by  on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBAppDelegate.h"
#import "Reachability.h"

@implementation DBAppDelegate

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  \n", [NSStringFromSelector(aSelector) UTF8String]);
    return [super respondsToSelector:aSelector];  
}  
#endif

@synthesize window = _window;

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (void)reachabilityChanged:(NSNotification *)note 
{
    Reachability* curReach = [note object];
    NSParameterAssert([curReach isKindOfClass: [Reachability class]]);
    NetworkStatus status = [curReach currentReachabilityStatus];
    
    if (status == NotReachable) 
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"领导决策系统"
                                                        message:@"网络为断开状态"
                                                       delegate:nil
                                              cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    else {
        static int nCount = 0;
        if (nCount++ > 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"领导决策系统"
                                                            message:@"网络已连通状态"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alert show];
            [alert release];
        }

    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    NSString *documentsDirectory= [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSLog(@"====\n%@\n", documentsDirectory);
    
    // 监测网络情况
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged:)
                                                 name: kReachabilityChangedNotification
                                               object: nil];
    //hostReach = [[Reachability reachabilityWithHostName:@"www.baidu.com"] retain];
    hostReach = [Reachability reachabilityWithHostname:@"www.baidu.com"];
    [hostReach startNotifier];
    
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
   //当应用在前台运行时, 收到本地通知
    application.applicationIconBadgeNumber = 0;
    //重新设置applicationIconBadgeNumber
    int count = [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
    if (count > 0) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < count; i++) {
            UILocalNotification *notif = [[[UIApplication sharedApplication] scheduledLocalNotifications] objectAtIndex:i];
            notif.applicationIconBadgeNumber = i + 1;
            [array addObject:notif];
        }
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        if (array.count > 0) {
            for (int i = 0; i < array.count; i++) {
                UILocalNotification *notif = [array objectAtIndex:i];
                [[UIApplication sharedApplication] scheduleLocalNotification:notif];
            }
        }
    }
    
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    application.applicationIconBadgeNumber = 0;
    int count = [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
    if (count > 0) {
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        for (int i = 0; i < count; i++) {
            UILocalNotification *notif = [[[UIApplication sharedApplication] scheduledLocalNotifications] objectAtIndex:i];
            notif.applicationIconBadgeNumber = i + 1;
            [array addObject:notif];
        }
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
        if (array.count > 0) {
            for (int i = 0; i < array.count; i++) {
                UILocalNotification *notif = [array objectAtIndex:i];
                [[UIApplication sharedApplication] scheduleLocalNotification:notif];
            }
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
