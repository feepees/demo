//
//  DBPOIData.h
//  HZDuban
//
//  Created by mac on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface DBPOIData : NSObject

@property (nonatomic, retain) NSString *OID;
@property (nonatomic, retain) NSString *YSDM;
@property (nonatomic, retain) NSString *BSM;
@property (nonatomic, retain) NSString *area;
@property (nonatomic, retain) NSString *length;
//@property (nonatomic, retain) NSString *POIx;
//@property (nonatomic, retain) NSString *POIy;
@property (nonatomic, retain) NSString *POIName;
@property (nonatomic, retain) NSString *POIAddress;
@property (nonatomic, retain) NSString *POITelNum;
@property (nonatomic, retain) NSString *POIXXDZ;
@property (nonatomic, retain) NSString *LXDH;
@property (nonatomic, retain) AGSPoint *Point;
@property (nonatomic, assign) NSInteger nIndex;
@end
