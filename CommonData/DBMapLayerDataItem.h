//
//  DBMapLayerDataItem.h
//  HZDuban
//
//  Created by  on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DBMapLayerDataItem : NSObject


@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *MapUrl;
@property (nonatomic, retain) NSString *Name;   
@property (nonatomic, retain) NSString *Type;
//@property (nonatomic, retain) NSString *Caption;
@property (nonatomic, retain) NSString *DataLayerDisplay;
//2012-09-16 add by niurg
@property (nonatomic, retain) NSString *GROUPID;
@property (nonatomic, retain) NSString *ENNAME;
@property (nonatomic, retain) NSString *XMIN;   
@property (nonatomic, retain) NSString *XMAX;
@property (nonatomic, retain) NSString *YMIN;
@property (nonatomic, retain) NSString *YMAX;
@property (nonatomic, retain) NSString *WEBTYPE;
@property (nonatomic, retain) NSString *ISBASEMAP;

@property (nonatomic, retain) NSString *DEPTNAME;
@property (nonatomic, retain) NSString *METAID;
@property (nonatomic, retain) NSString *PICPATH;
@property (nonatomic, retain) NSString *MEMO;

@end
