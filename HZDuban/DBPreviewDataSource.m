//
//  DBPreviewDataSource.m
//  HZDuban
//
//  Created by  on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBPreviewDataSource.h"

@implementation DBPreviewDataSource

@synthesize path;

- (NSInteger) numberOfPreviewItemsInPreviewController: (QLPreviewController *) controller   
{  
    return 1;  
}  

- (id <QLPreviewItem>)previewController: (QLPreviewController *)controller previewItemAtIndex:(NSInteger)index   
{  
    
    return [NSURL fileURLWithPath:path];  
}  

- (void)dealloc {   
    [path release];
    [super dealloc];   
}   
@end
