//
//  DBSubProjectDataItem.m
//  HZDuban
//
//  Created by  on 12-8-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBSubProjectDataItem.h"

@implementation DBSubProjectDataItem
@synthesize OwnerUnit = _OwnerUnit;
@synthesize OwnerMeetringID = _OwnerMeetringID;
@synthesize Id = _Id;
@synthesize SectionName = _SectionName;
@synthesize Result = _Result;
@synthesize Reason = _Reason;
@synthesize Type = _Type;
@synthesize TopicName = _TopicName;
//@synthesize DKDataArr = _DKDataArr;
//@synthesize TopicAnnexArr = _TopicAnnexArr;

// 初期化
-(id)init
{
    self = [super init];
    if(self)
    {
        //_DKDataArr = [[NSMutableArray alloc] initWithCapacity:2]; 
        //_TopicAnnexArr = [[NSMutableArray alloc] initWithCapacity:2]; 
    }
    
    return self;
}

- (void)dealloc
{
    //[_TopicAnnexArr removeAllObjects];
    //_TopicAnnexArr = nil;
    //[_DKDataArr removeAllObjects];
    //_DKDataArr = nil;
    
    _OwnerMeetringID = nil;
    _Id = nil;
    _SectionName = nil;
    _Reason = nil;
    _Result = nil;
    _Type = nil;
    self.TopicName = nil;
    self.OwnerUnit = nil;
    self.Id = nil;
    self.SectionName = nil;
    self.Reason = nil;
    self.Result = nil;
    
    [super dealloc];
}

@end
