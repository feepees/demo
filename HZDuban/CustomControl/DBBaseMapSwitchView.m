//
//  DBBaseMapSwitchView.m
//  HZDuban
//
//  Created by  on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBBaseMapSwitchView.h"
#import "Logger.h"
#import "CommHeader.h"
//#import "DBViewController.h"

//@interface DBViewController ()
//@property (nonatomic, retain) DBViewController *DBViewControl;

//@end

@implementation DBBaseMapSwitchView
//@synthesize DBViewControl = _DBViewControl;
@synthesize AddPinOnMapSwitch = _AddPinOnMapSwitch;

@synthesize MapConfDelegate = _MapConfDelegate;
@synthesize MapTypeSegCtrl = _MapTypeSegCtrl;

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        // SwitchBaseMapViewBackground
        UIImage *image = [UIImage imageNamed:@"SwitchBaseMapViewBackground.png"];
        UIImageView *imageview = [[UIImageView alloc] initWithImage:image];
        [imageview setFrame:[self frame]];
        [self addSubview:imageview];
        [imageview release];
        
        //-----------------------------
        /*
        float fXPos = 800.0f;
        float fYPos = 380;
        _AddPinOnMapSwitch  = [[UISwitch alloc] initWithFrame:CGRectMake(fXPos, fYPos, 150, 40)];    
        _AddPinOnMapSwitch.on = FALSE;
        [_AddPinOnMapSwitch addTarget:self action:@selector(pinSwitchAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_AddPinOnMapSwitch];
        [_AddPinOnMapSwitch release];
        
        fXPos += [_AddPinOnMapSwitch frame].size.width;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(fXPos, fYPos - 8, 150, 40)];
        [label setText:@"放置大头针"];
        [label setBackgroundColor:[UIColor clearColor]];
        //UIFont *font = [UIFont systemFontOfSize:15];
        [label setTextColor:[UIColor whiteColor]];
        [self addSubview:label];
        [label release];
        */
        //-----------------------------
        
        //-----------------------------
        float fXPos = 800.0f;
        float fYPos = 380;
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(fXPos, fYPos - 8, 70, 40)];
        [label setText:@"添加标注"];
        [label setBackgroundColor:[UIColor clearColor]];
        //UIFont *font = [UIFont systemFontOfSize:15];
        [label setTextColor:[UIColor whiteColor]];
        [label setFont:[UIFont systemFontOfSize:13]];
        [self addSubview:label];
        [label release];
        
        fXPos += [label frame].size.width;
        _AddPinOnMapSwitch  = [[UISwitch alloc] initWithFrame:CGRectMake(fXPos, fYPos, 150, 40)];    
        _AddPinOnMapSwitch.on = FALSE;
        [_AddPinOnMapSwitch addTarget:self action:@selector(pinSwitchAction:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_AddPinOnMapSwitch];
        [_AddPinOnMapSwitch release];
        //-----------------------------
        
        // 底图类型Segment button
        NSArray *segmentTextContent = [NSArray arrayWithObjects:
                                       NSLocalizedString(DEFAULT_MAPLAYER_NAME, @""),
                                       NSLocalizedString(SATELLITE_MAPLAYER_NAME, @""),
                                       NSLocalizedString(MIX_MAPLAYER_NAME, @""),
                                       nil];
        self.MapTypeSegCtrl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
        self.MapTypeSegCtrl.selectedSegmentIndex = 0;
        self.MapTypeSegCtrl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.MapTypeSegCtrl.segmentedControlStyle = UISegmentedControlStyleBar;
        fXPos = 800.0f;
        fYPos += 50;
        self.MapTypeSegCtrl.frame = CGRectMake(fXPos, fYPos, 150, 40);
        
//        MapTypeSegCtrl.momentary = YES; 
//        MapTypeSegCtrl.multipleTouchEnabled=NO; 
        
        [self.MapTypeSegCtrl addTarget:self
                           action:@selector(SetBaseMapType:)
                   forControlEvents:UIControlEventValueChanged];
        
        [self addSubview:self.MapTypeSegCtrl];
        
        // 系统配置
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"ConfigBtn.png"] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        button.frame = CGRectMake(800, 500, 60, 60);
        [button addTarget:self action:@selector(AllConfClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
}

- (void)dealloc {
    self.MapTypeSegCtrl = nil;
    _AddPinOnMapSwitch = nil;
    [super dealloc];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    return;
}

//////////////////////////////  系统配置 begin
- (void)AllConfClicked:(id)sender
{
    [NSThread detachNewThreadSelector:@selector(AllConfThreadFunc) toTarget:self withObject:nil];
    return;
}

-(void)AllConfThreadFunc
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        [NSThread sleepForTimeInterval:0.05];
        [self performSelectorOnMainThread:@selector(AllConfOperation) withObject:nil  waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [pool release];
    }
    
    return;
}

-(void)AllConfOperation
{
    [_MapConfDelegate AllConf];
    return;
}
///////////////////////////////系统配置 end

////////////////////////////// 添加标注 begin
-(void)pinSwitchActionThreadFunc:(id)param
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        [NSThread sleepForTimeInterval:0.05];
        [self performSelectorOnMainThread:@selector(pinSwitchOperation:) withObject:param  waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [pool release];
    }
    
}
-(void)pinSwitchOperation:(id)param
{
    [_MapConfDelegate MapPinSet:_AddPinOnMapSwitch.on];
    return;
}
-(void)pinSwitchAction:(id)sender
{
    NSString *param = @"test";
    [NSThread detachNewThreadSelector:@selector(pinSwitchActionThreadFunc:) toTarget:self withObject:param];
}
////////////////////////////// 添加标注 end

////////////////////////////// 底图切换 begin
-(void)BaseMapSwitchOperation:(id)param
{
    NSString *mapType = (NSString*)param;
    [_MapConfDelegate BaseMapLayerSet:mapType];
    return;
}
-(void)BaseMapSwitchThreadFunc:(NSString *)param
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        [NSThread sleepForTimeInterval:0.05];
        [self performSelectorOnMainThread:@selector(BaseMapSwitchOperation:) withObject:param  waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [pool release];
    }
    
    return;
}
-(void)SetBaseMapType:(id)sender
{
    UISegmentedControl *MapTypeSegCtrl = (UISegmentedControl*)sender;
    int nSelIndex = MapTypeSegCtrl.selectedSegmentIndex;
    NSString *mapName = nil;
    if (nSelIndex == 0) {
        mapName = @"地图";
    }
    else if (nSelIndex == 1) {
        mapName = SATELLITE_MAPLAYER_NAME;
    }
    else {
        mapName = MIX_MAPLAYER_NAME;
    }
    NSString *param = [NSString stringWithFormat:@"%@", mapName];
    [NSThread detachNewThreadSelector:@selector(BaseMapSwitchThreadFunc:) toTarget:self withObject:param];
    
    return;
}
////////////////////////////// 底图切换 end
@end
