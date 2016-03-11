//
//  DBTopicAnnexDataItem.m
//  HZDuban
//
//  Created by  on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBTopicAnnexDataItem.h"

@implementation DBTopicAnnexDataItem
@synthesize Id = _Id;
@synthesize Name = _Name;
@synthesize Address = _Address;
@synthesize TopicID = _TopicID;
@synthesize Index = _Index;

- (void)dealloc
{
    _Id = nil;
    _Name = nil; 
    _Address = nil;
    _TopicID = nil;
    
    [super dealloc];
}

@end
