//
//  DBAllConfViewController.h
//  HZDuban
//
//  Created by mac on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBOfflineConfViewController.h"
#import "DBBaseMapConfViewController.h"

@protocol DBAllConfDelegate <NSObject>
- (void)ReloadMapViewWithNameArray:(NSArray *)layerName andWithIndexArray:(NSArray *)index andWithType:(NSInteger)type;
- (void)AllConfPopoverDone;
-(void)ClearCacheCompleted:(NSString*)TipMsg;
@end

@interface DBAllConfViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource, DBOfflinConfDelegate,DBBaseMapLayerConfViewDelegate>
{
    id<DBAllConfDelegate> delegate;
    NSArray *_ConfOptionArray;
    UITableView *_AllConfTableView;
//    // 业务图层名称
//    NSMutableArray *_DataMapLayerNameArray;
//    NSMutableArray *_DataMapLayerUrlArray;
    //基本图层
    NSMutableDictionary *_BaseMapLayersDic;

    NSArray *_FirstTypeLayerNameArray;
    NSArray *_FirstTypeIndexArray;
    NSArray *_SecondTypeLayerNameArray;
    NSArray *_SecondTypeIndexArray;
    NSMutableArray *_MapTypeArray;
}

@property (nonatomic, assign) id<DBAllConfDelegate> delegate;
@property (nonatomic, retain) NSArray *ConfOptionArray;
//@property (nonatomic, retain) NSMutableArray *DataMapLayerNameArray;
//@property (nonatomic, retain) NSMutableArray *DataMapLayerUrlArray;
@property (nonatomic, retain) NSMutableDictionary *BaseMapLayersDic;
@property (nonatomic, retain) NSArray *FirstTypeLayerNameArray;
@property (nonatomic, retain) NSArray *FirstTypeIndexArray;
@property (nonatomic, retain) NSArray *SecondTypeLayerNameArray;
@property (nonatomic, retain) NSArray *SecondTypeIndexArray;
@property (nonatomic, retain) NSMutableArray *MapTypeArray;

@end
