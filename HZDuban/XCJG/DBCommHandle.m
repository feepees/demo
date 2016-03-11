//
//  DBCommHandle.m
//  HZDuban
//
//  Created by sunz on 13-7-3.
//
//

#import "DBCommHandle.h"
#import "Logger.h"
#import <QuartzCore/QuartzCore.h>

static DBCommHandle *DBCommHandleObj = nil;

@implementation DBCommHandle

//--------------------------------
// 获取单例
+ (DBCommHandle *)instance
{
    @synchronized(self)
    {
        if (DBCommHandleObj == nil)
        {
            [[self alloc] init];
        }
    }
    return DBCommHandleObj;
}

//--------------------------------
// 唯一一次 alloc 单例，之后均返回 nil~
+(id) allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (DBCommHandleObj == nil)
        {
            DBCommHandleObj = [super allocWithZone:zone];
            return DBCommHandleObj;
        }
    }
    return nil;
}

//--------------------------------
// copy 返回单例本身~
-(id) copyWithZone:(NSZone *)zone
{
    return self;
}

//--------------------------------
// retain 返回单例本身~
-(id) retain
{
    return self;
}

//--------------------------------
// 引用计数总是为 1~
-(NSUInteger) retainCount
{
    return 1;
}

//--------------------------------
// release 不做任何处理~
-(oneway void) release
{
    
}

//--------------------------------
// autorelease 返回单例本身~
-(id) autorelease {
    return self;
}

//---------------------------------
// 真 release 私有接口~
-(void) realRelease
{
    [super release];
}


// stopNumber 参数暂时未使用
- (AGSCompositeSymbol*)GetSymbolWithNumber:(NSInteger)stopNumber UnitText:(NSString*)UnitTextVal TypeFlg:(NSInteger)Flg
{
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    // create outline
    AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbol];
    sls.color = [UIColor whiteColor];
    sls.width = 2;
    sls.style = AGSSimpleLineSymbolStyleSolid;
    
    // create main circle
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms.color = [UIColor greenColor];
    sms.outline = sls;
    sms.size = 20;
    
    AGSTextSymbol *ts = [[[AGSTextSymbol alloc] initWithTextTemplate:[NSString stringWithFormat:@"%@",UnitTextVal]
                                                               color:[UIColor blueColor]] autorelease];
    ts.vAlignment = AGSTextSymbolVAlignmentMiddle;
    if (Flg == 1) {
        // 测量线的场合
        ts.hAlignment = AGSTextSymbolHAlignmentLeft;
    }
    else if(Flg == 2){
        // 测量面的场合
        ts.hAlignment = AGSTextSymbolHAlignmentCenter;
    }
    
    if (stopNumber >1000) {
        sms.size = 60;
        sms.color = [UIColor redColor];
        ts.fontSize = 13;
        
    }else if(stopNumber>500 && stopNumber >100 && stopNumber > 50 && stopNumber > 10 && stopNumber) {
        sms.size = 24;
        sms.color = [UIColor blueColor];
        ts.fontSize = 13;
    }else
    {
        sms.size = 20;
        sms.color = [UIColor blackColor];
        ts.fontSize = 12;
    }
    sms.style = AGSSimpleMarkerSymbolStyleCircle;
    //[cs.symbols addObject:sms];
    // add number as a text symbol
    
    ts.fontWeight = AGSTextSymbolFontWeightBold;
    [cs.symbols addObject:ts];
    
    return cs;
}
@end
