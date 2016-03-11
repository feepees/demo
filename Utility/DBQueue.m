//
//  DBQueue.m
//  HZDuban
//
//  Created by  on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBQueue.h"

@implementation DBQueue

@synthesize count;
- (id)init
{
	if( self=[super init] )
	{
		m_array = [[NSMutableArray alloc] init];
		count = 0;
	}
	return self;
}
- (void)dealloc {
	[m_array release];
    [super dealloc];
}
- (void)enqueue:(id)anObject
{
	[m_array addObject:anObject];
	count = m_array.count;
}
- (id)dequeue
{
    id obj = nil;
    if(m_array.count > 0)
    {
        obj = [[[m_array objectAtIndex:0]retain]autorelease];
        [m_array removeObjectAtIndex:0];
        count = m_array.count;
    }
    return obj;
}
- (void)clear
{
	[m_array removeAllObjects];
    count = 0;
}

@end
