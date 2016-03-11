//
//  DBLandDataViewController.h
//  HZDuban
//
//  Created by mac on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//取点查询后得到的数据的Controller。
#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@protocol DBLandDataViewDelegate <NSObject>
- (void)LandDataViewPopoverDone;
@end

@interface DBLandDataViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *LandDataTabView;
    id<DBLandDataViewDelegate> delegate;
    NSArray *_ResultSets;
    NSInteger indexOfNote;
}

@property (nonatomic, retain) NSMutableArray *areaOfLandArray;
@property (nonatomic, retain) NSMutableArray *HeaderTitleArray;
@property (nonatomic, assign) id<DBLandDataViewDelegate> delegate;

@property (nonatomic, retain) NSArray *ResultSets;
@property (nonatomic, retain) AGSGraphic *Graphic;
@property (nonatomic, assign) NSInteger nTypeFlg;

// 查询此URL得到的当前地块信息
@property (nonatomic, retain) NSString *DataMapUrl;
-(void)ReloadTableData:(NSString*)Url;
@end
