//
//  main.m
//  HZDuban2
//
//  Created by  on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DBAppDelegate.h"
#import "Logger.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        [Logger InitLogger];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([DBAppDelegate class]));
        [Logger ReleaseLogger];
    }
    
}
