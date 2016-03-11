//
//  DBAGSGraphic.m
//  HZDuban
//
//  Created by  on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBAGSGraphic.h"

@implementation DBAGSGraphic
@synthesize MarkID;
@synthesize TypeFlg = _TypeFlg;
@synthesize POIIndex = _POIIndex;
@synthesize ObjectID = _ObjectID;
@synthesize bIsHighlighted;
@synthesize Id = _Id;
@synthesize BH = _BH;
@synthesize DKBH = _DKBH;
@synthesize DisscuseAffair = _DisscuseAffair;
@synthesize DKName = _DKName; 
@synthesize DKBsm = _DKBsm;
@synthesize TopicID = _TopicID;
@synthesize Notes = _Notes;
@synthesize DKApplicant = _DKApplicant;
@synthesize DKGeometry = _DKGeometry;
@synthesize DKBZXX = _DKBZXX;
@synthesize DKLX = _DKLX;

- (void)dealloc
{
    self.MarkID = nil;
    self.Id = nil;
    self.BH = nil;
    self.ObjectID = nil;
    self.DKBH = nil;
    self.DisscuseAffair = nil;
    self.DKName = nil; 
    self.DKBsm = nil;
    self.TopicID = nil;
    self.Notes = nil;
    self.DKApplicant = nil;
    self.DKGeometry = nil;
    self.DKBZXX = nil;
    self.DKLX = nil;
    
    // add by niurg 2016.02.16
    self.outerNoSelectedSymbol = nil;
    self.outerSelectedSymbol = nil;
    // end

    [super dealloc];
}

@end