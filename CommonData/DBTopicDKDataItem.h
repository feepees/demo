//
//  DBTopicDKDataItem.h
//  HZDuban
//
//  Created by  on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>


@interface DBTopicDKDataItem : NSObject

@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *BH;         // 编号
@property (nonatomic, retain) NSString *DKBH;       // 地块编号
@property (nonatomic, retain) NSString *DisscuseAffair;           // 讨论事项

@property (nonatomic, retain) NSString *DKName;      // 名称

@property (nonatomic, retain) NSString *DKBsm;
@property (nonatomic, retain) NSString *TopicID;      // 
@property (nonatomic, retain) NSString *Notes;        // 备注
@property (nonatomic, retain) NSString *DKApplicant; // 申请单位

@property (nonatomic, retain) AGSGeometry * DKGeometry;     // 地块位置坐标

@property (nonatomic, retain) NSString * DKBZXX;
@property (nonatomic, retain) NSString * DKLX;
@end
