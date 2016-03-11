//
//  DBDisplayFieldDataItem.m
//  HZDuban
//
//  Created by  on 12-9-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBDisplayFieldDataItem.h"

@implementation DBDisplayFieldDataItem

@synthesize FIELDDEFID = _FIELDDEFID;
@synthesize PHYLAYERID = _PHYLAYERID;
@synthesize FIELDDEFNAME = _FIELDDEFNAME;
@synthesize FIELDDEFALIAS = _FIELDDEFALIAS;
@synthesize FIELDDEFTYPE = _FIELDDEFTYPE;
@synthesize FDISNULL = _FDISNULL;
@synthesize FDDEFAULT = _FDDEFAULT;

-(void)dealloc
{
    [self.FIELDDEFID release];
    [self.PHYLAYERID release];
    [self.FIELDDEFNAME release];
    [self.FIELDDEFALIAS release];
    [self.FIELDDEFTYPE release];
    [self.FDISNULL release];
    [self.FDDEFAULT release];
    
    [super dealloc];
}
@end
