//
//  DBMeetingDataItem.h
//  HZDuban
//
//  Created by  on 12-8-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBMeetingDataItem : NSObject
{
    
}

@property (nonatomic, retain) NSString *MeetingName;        // 会议名称
@property (nonatomic, retain) NSString *Time;
@property (nonatomic, retain) NSString *Address;
@property (nonatomic, retain) NSString *OwnerUnit;

@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *Type;
@property (nonatomic, retain) NSString *StartTime;
@property (nonatomic, retain) NSString *EndTime;

@end
