//
//  DBXCDKDataItem.m
//  HZDuban
//
//  Created by sunz on 13-7-4.
//
//

#import "DBXCDKDataItem.h"

@implementation DBXCDKDataItem
@synthesize Id = _Id;
@synthesize ProjectName = _ProjectName;
@synthesize QLR = _QLR;
@synthesize ZDH = _ZDH;
@synthesize Area = _Area;
@synthesize Address = _Address;
@synthesize UsePurpose = _UsePurpose;
@synthesize ProjectStartDate = _ProjectStartDate;
@synthesize ProjectEndDate = _ProjectEndDate;
@synthesize ProjectStatus = _ProjectStatus;



- (void)dealloc
{
    _Id = nil;
    _ProjectName = nil;
    _QLR = nil;
    _ZDH = nil;
    _Area = nil;
    _Address = nil;
    _UsePurpose = nil;
    _ProjectStartDate = nil;
    _ProjectEndDate= nil;
    _ProjectStatus = nil;
    
    [super dealloc];
}
@end
