//
//  DBMapLayerDataItem.m
//  HZDuban
//
//  Created by  on 12-8-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBMapLayerDataItem.h"

@implementation DBMapLayerDataItem
@synthesize Name = _Name;
@synthesize Id = _Id;
@synthesize Type = _Type;
@synthesize MapUrl = _MapUrl;
//@synthesize Caption = _Caption;
@synthesize DataLayerDisplay;

//
@synthesize GROUPID = _GROUPID;
@synthesize ENNAME = _ENNAME;
@synthesize XMIN = _XMIN;
@synthesize XMAX = _XMAX;
@synthesize YMIN = _YMIN;
@synthesize YMAX = _YMAX;
@synthesize WEBTYPE = _WEBTYPE;
@synthesize ISBASEMAP = _ISBASEMAP;
@synthesize DEPTNAME = _DEPTNAME;
@synthesize METAID = _METAID;
@synthesize PICPATH = _PICPATH;
@synthesize MEMO = _MEMO;


- (void)dealloc
{
    [self.MapUrl release];
    [self.Id release];
    [self.Type release];
    [self.Name release];
//    [self.Caption release];
    [self.DataLayerDisplay release];
    
    [self.GROUPID release];
    [self.ENNAME release];
    [self.XMIN release];
    [self.XMAX release];
    [self.YMIN release];
    [self.YMAX release];
    [self.WEBTYPE release];
    [self.ISBASEMAP release];
    [self.DEPTNAME release];
    [self.METAID release];
    [self.PICPATH release];
    [self.MEMO release];
    
    [super dealloc];
}
@end
