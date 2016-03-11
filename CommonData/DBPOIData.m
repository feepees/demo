//
//  DBPOIData.m
//  HZDuban
//
//  Created by mac on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBPOIData.h"

@implementation DBPOIData

@synthesize OID, YSDM, BSM, area, length, POIName, POIAddress, POITelNum, POIXXDZ, LXDH;
@synthesize Point;
@synthesize nIndex;

- (void)dealloc
{
    self.Point = nil;
    self.OID = nil;
    self.YSDM = nil;
    self.BSM = nil;
    self.area = nil;
    self.length = nil;
//    self.POIx = nil;
//    self.POIy = nil;
    self.POIName = nil;
    self.POIAddress = nil;
    self.POITelNum = nil;
    self.POIXXDZ = nil;
    self.LXDH = nil;
    
    [super dealloc];
}

@end
