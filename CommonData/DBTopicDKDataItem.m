//
//  DBTopicDKDataItem.m
//  HZDuban
//
//  Created by  on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBTopicDKDataItem.h"

@implementation DBTopicDKDataItem
@synthesize Id = _Id;
@synthesize BH = _BH;
@synthesize DKBH = _DKBH;
@synthesize DisscuseAffair = _DisscuseAffair;
@synthesize DKName = _DKName; 
@synthesize DKBsm = _DKBsm;
@synthesize TopicID = _TopicID;
@synthesize Notes = _Notes;
@synthesize DKApplicant = _DKApplicant;
@synthesize DKGeometry = _DKGeometry;
@synthesize DKBZXX = _DKBZXX;
@synthesize DKLX = _DKLX;

- (void)dealloc
{
    _DKLX = nil;
    _DKBZXX = nil;
    _DKApplicant = nil;
    _BH = nil;
    _DKGeometry = nil;
    _DisscuseAffair = nil;
    _Notes = nil;
    _Id = nil;
    _DKName = nil; 
    _DKBsm = nil;
    _DKBH = nil;
    _TopicID = nil;
    
    [super dealloc];
}


@end
