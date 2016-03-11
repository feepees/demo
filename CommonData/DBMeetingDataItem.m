//
//  DBMeetingDataItem.m
//  HZDuban
//
//  Created by  on 12-8-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBMeetingDataItem.h"

@implementation DBMeetingDataItem

@synthesize StartTime = _StartTime;
@synthesize EndTime = _EndTime;
@synthesize Id = _Id;
@synthesize Type = _Type;
@synthesize MeetingName = _MeetingName;
@synthesize Address = _Address;
@synthesize OwnerUnit = _OwnerUnit;
@synthesize Time = _Time;

- (void)dealloc
{
    self.Id = nil;
    self.Type = nil;
    self.StartTime = nil;
    self.EndTime = nil;
    self.MeetingName = nil;
    self.Time = nil;
    self.Address = nil;
    self.OwnerUnit = nil;
    
    [super dealloc];
}

@end
