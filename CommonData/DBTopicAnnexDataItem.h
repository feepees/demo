//
//  DBTopicAnnexDataItem.h
//  HZDuban
//
//  Created by  on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBTopicAnnexDataItem : NSObject

@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *Name;          // 名称
@property (nonatomic, retain) NSString *Address;       // 下载地址
@property (nonatomic, retain) NSString *TopicID; 
@property (nonatomic, assign) NSInteger Index;

@end
