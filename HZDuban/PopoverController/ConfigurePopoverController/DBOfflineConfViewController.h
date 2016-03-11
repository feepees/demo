//
//  DBOfflineConfViewController.h
//  HZDuban
//
//  Created by mac on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBLocalTileDataManager.h"

@protocol DBOfflinConfDelegate <NSObject>
// 清除缓存地图数据完成
-(void)ClearOfflinCacheMapDataCompleted:(NSString*)TipMsg;
@end

@interface DBOfflineConfViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource, DBLocalTileDataDownloadDelegate>
{
    id<DBOfflinConfDelegate> NodifyDelegate;
    UITableView *_OfflineConfTableView;
    NSMutableArray *_HeaderTitleContentArray;
    NSMutableArray *_FirstSectionOptionArray;
    NSMutableArray *_FirstSectionSwitchArray;
    NSMutableArray *_SecondSectionOptionArray;
    NSMutableArray *_SecondSectionSwitchArray;
    NSMutableArray *_ThirdSectionOptionArray;
    NSString *_FilePath;
    //离线数据更新
    UIProgressView *_UpdateProgressView;
    NSThread *_UpdateLocalDataThread;
    NSArray *_ReloadIndexPathsArray;
    NSCondition * valueCondition;
    BOOL bIsUpdateLocalData;
    float ProgressValue;
}
@property (nonatomic, assign) id<DBOfflinConfDelegate> NodifyDelegate;
@property (nonatomic, retain) UITableView *OfflineConfTableView;
//每段的标题
@property (nonatomic, retain) NSMutableArray *HeaderTitleContentArray;
//第一段内容
@property (nonatomic, retain) NSMutableArray *FirstSectionOptionArray;
@property (nonatomic, retain) NSMutableArray *FirstSectionSwitchArray;
//第二段内容
@property (nonatomic, retain) NSMutableArray *SecondSectionOptionArray;
@property (nonatomic, retain) NSMutableArray *SecondSectionSwitchArray;
//第三段内容
@property (nonatomic, retain) NSMutableArray *ThirdSectionOptionArray;
@property (nonatomic, retain) NSString *FilePath;
//离线数据更新的位置
@property (nonatomic, retain) NSArray *ReloadIndexPathsArray;

@end
