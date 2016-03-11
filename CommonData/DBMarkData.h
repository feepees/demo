//
//  DBMarkData.h
//  HZDuban
//
//  Created by mac on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <ArcGIS/ArcGIS.h>

@interface DBMarkData : NSObject

@property (nonatomic, retain) NSString *MarkID;
@property (nonatomic, retain) NSString *MarkName;
@property (nonatomic, retain) NSString *MarkNote;
@property (nonatomic, retain) NSString *MarkSpatialReferenceWKID;
@property (nonatomic, retain) NSString *MarkSpatialReferenceWKT;
@property (nonatomic, retain) NSString *MarkCoordinateX;
@property (nonatomic, retain) NSString *MarkCoordinateY;
//@property (nonatomic, retain) AGSPoint *Point;

@end
