//
//  DBLandAnalyseViewController.h
//  HZDuban
//
//  Created by  on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataGridComponent.h"
#import <ArcGIS/ArcGIS.h>

@protocol DBLandAnalyseViewControllerDelegate <NSObject>
- (void)DBLandAnalyseViewControllerPopoverDone;
@end

@interface DBLandAnalyseViewController : UIViewController<DataGridComponentDelegate>
{
    
}

@property (nonatomic, assign) id<DBLandAnalyseViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray *ResultSets;
@property (nonatomic, assign) NSInteger nType;
@property (nonatomic, copy) AGSGeometry *geometry;

@property (nonatomic, retain) UISegmentedControl *MapTypeSegCtrl;
// 地类图斑
@property (nonatomic, retain) UIView *AreaLandView;
// 线状地物
@property (nonatomic, retain) UIView *LineLandView;
// 点状地物
@property (nonatomic, retain) UIView *PointLandView;

// 查询此URL得到的当前地块信息
@property (nonatomic, retain) NSString *DataMapUrl;

// 查询出的地块信息
@property (nonatomic, retain) NSDictionary *DKInfoDic;
@property(nonatomic, copy) NSString *ENNAME;

-(void)ReloadTableData:(NSString*)Url;

@end
