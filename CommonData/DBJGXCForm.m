//
//  DBJGXCForm.m
//  HZDuban
//
//  Created by sunz on 13-7-4.
//
//

#import "DBJGXCForm.h"

@implementation DBJGXCForm

@synthesize FormId = _FormId;
@synthesize DKId = _DKId;
@synthesize QLR = _QLR;
@synthesize Area = _Area;

@synthesize BJQK = _BJQK;
@synthesize GCGHXKZBH = _GCGHXKZBH;
@synthesize BJQK_Reason = _BJQK_Reason;

@synthesize DGQK = _DGQK;
@synthesize DGQK_Reason = _DGQK_Reason;

@synthesize KFQK = _KFQK;
@synthesize KFQK_Reason = _KFQK_Reason;

@synthesize JGQK = _JGQK;
@synthesize JGYSHGZBH = _JGYSHGZBH;
@synthesize JGQK_Reason = _JGQK_Reason;

- (void)dealloc
{
    _FormId = nil;
    _DKId = nil;
    _QLR = nil;
    _Area = nil;
    
    _BJQK = nil;
    _GCGHXKZBH = nil;
    _BJQK_Reason = nil;
    
    _DGQK = nil;
    _DGQK_Reason= nil;
    
    _KFQK = nil;
    _KFQK_Reason = nil;
    
    _JGQK= nil;
    _JGYSHGZBH = nil;    
    _JGQK_Reason = nil;
    
    [super dealloc];
}

@end
