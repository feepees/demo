//
//  DBLatelySearchOrPOIViewController.h
//  HZDuban
//
//  Created by mac on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBLocalTileDataManager.h"

@protocol DBLatelySearchOrPOIViewDelegate <NSObject>

- (void)SearchTextSet:(NSString *)SearchText;
-(void)ExecSearchFunc;
//- (void)POIAppear:(NSString *)SearchText;
- (void)POIAppear:(NSString *)ObjectID Type:(NSInteger)nType;
-(void)POISearchPopoverViewOkeyBtnClicked;
-(void)MoreSearchDisplayLoadingView;

@end

@interface DBLatelySearchOrPOIViewController : UITableViewController
    <DBFooterViewHiddenDelegate>
{
    NSMutableArray *AllBookMarkDataArray;
    NSMutableArray *SearchedDataArray;
    
    // 0:all  1:filter data 2:POIData
    NSInteger _nDataSourceFlg;
    
    id <DBLatelySearchOrPOIViewDelegate> _delegate;
    NSIndexPath *_PreIndexPath;
}

@property (nonatomic, assign) id <DBLatelySearchOrPOIViewDelegate> delegate;
@property (nonatomic, assign) NSInteger nDataSourceFlg;
@property (nonatomic, retain) NSMutableArray *AllBookMarkDataArray;
@property (nonatomic, retain) NSMutableArray *SearchedDataArray;
@property (nonatomic, retain) NSString *QueryWord;

//单例对象
@property (nonatomic, retain) DBLocalTileDataManager *SingleManager;

-(void)ReloadBookMarkData;
// 设置选中Cell的image为红色状态,原来的为蓝色状态.
-(void)SetSelectedCellImage:(NSInteger)nIndex;

@end
