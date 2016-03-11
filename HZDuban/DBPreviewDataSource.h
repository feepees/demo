//
//  DBPreviewDataSource.h
//  HZDuban
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuickLook/QuickLook.h>

@interface DBPreviewDataSource : NSObject<QLPreviewControllerDataSource>{
    NSString *path;
}

@property (nonatomic, copy) NSString *path;
@end
