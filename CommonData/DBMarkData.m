//
//  DBMarkData.m
//  HZDuban
//
//  Created by mac on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBMarkData.h"

@implementation DBMarkData
@synthesize MarkID, MarkName, MarkNote, MarkSpatialReferenceWKID, MarkSpatialReferenceWKT, MarkCoordinateX, MarkCoordinateY;
//@synthesize Point;

- (void)dealloc
{
    self.MarkID = nil;
    self.MarkName = nil;
    self.MarkNote = nil;
    self.MarkSpatialReferenceWKID = nil;
    self.MarkSpatialReferenceWKT = nil;
    self.MarkCoordinateX = nil;
    self.MarkCoordinateY = nil;
    //self.Point = nil;
    
    [super dealloc];
}

@end
