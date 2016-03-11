//
//  DBDataMapLayerViewController.h
//  HZDuban
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "DBLocalTileDataManager.h"
#import "EGORefreshTableHeaderView.h"

@protocol DBDataMapLayerSwitchProtocol <NSObject>
@optional
- (void)MapLayerSwitch:(int)nIndex SwitchValue:(BOOL)bValue;
@end

@interface DBDataMapLayerViewController : UITableViewController<DBDataMapLayerViewReloadDelegate, EGORefreshTableHeaderDelegate>
{
    // 业务图层是否显示标记
    NSMutableArray *_DataMapLayerSwitchArray;
    
    NSString *_FilePath;
    
    id<DBDataMapLayerSwitchProtocol> _SwitchDelgate;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

@property (weak, nonatomic) id <DBDataMapLayerSwitchProtocol> SwitchDelgate;

@property (nonatomic, retain) NSMutableArray *DataMapLayerSwitchArray;
@property (nonatomic, retain) NSString *FilePath;
// 单例对象
@property (nonatomic, retain) DBLocalTileDataManager * SingleManager;

//-(void)parsedDataFromData:(NSData *)data;
// 下拉刷新
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewDataLayer;
@end
