//
//  DBSubProjectDataItem.h
//  HZDuban
//
//  Created by  on 12-8-3.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

// 议题数据
@interface DBSubProjectDataItem : NSObject
{
}

@property (nonatomic, retain) NSString *TopicName;                  // 议题名称
@property (nonatomic, retain) NSString *OwnerUnit;
@property (nonatomic, retain) NSString *OwnerMeetringID;            // 所属会议ID

// add by niurg
@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *SectionName;
@property (nonatomic, retain) NSString *Result;                     // 领导意见
@property (nonatomic, retain) NSString *Reason;                     // 基本情况
@property (nonatomic, retain) NSString *Type;
//@property (nonatomic, retain) NSMutableArray *DKDataArr;            // 议题相关地块
//@property (nonatomic, retain) NSMutableArray *TopicAnnexArr;        // 议题附件


@end
