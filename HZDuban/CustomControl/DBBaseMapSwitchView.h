//
//  DBBaseMapSwitchView.h
//  HZDuban
//
//  Created by  on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MapLayerConfDelegate <NSObject>
- (void)MapPinSet:(BOOL)bType;
- (void)BaseMapLayerSet:(NSString*)Type;
- (void)AllConf;
@end

@interface DBBaseMapSwitchView : UIView
{
    UISwitch *AddPinOnMapSwitch;
    
    id <MapLayerConfDelegate> _MapConfDelegate;
}
@property (weak, nonatomic) id <MapLayerConfDelegate> MapConfDelegate;
@property (nonatomic, retain) UISwitch *AddPinOnMapSwitch;
@property (nonatomic, retain) UISegmentedControl *MapTypeSegCtrl;
@end
