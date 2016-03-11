//
//  DBQueue.h
//  HZDuban
//
//  Created by  on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBQueue : NSObject
{
    NSMutableArray* m_array;
}
- (void)enqueue:(id)anObject;
- (id)dequeue;
- (void)clear;
@property (nonatomic, readonly) int count;

@end
