//
//  DBSubjectDataViewController.h
//  HZDuban
//
//  Created by mac on 12-8-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "DBSubProjectDataItem.h"
#import "DBLocalTileDataManager.h"

@protocol DBSubjectDataViewDelegate <NSObject>

- (void)LandsLocation:(AGSPoint*)LocationPoint;

// flag【YES:显示     NO:隐藏】
- (void)ClosedBtnTouchedWithFlag:(BOOL)flag;
- (void)LandDataViewAppear:(NSString*)TopicId  DKBsm:(NSString*)DKbsm newCenterPoint:(AGSPoint*)centerPoint :(AGSMutableEnvelope*)DKsEnv;

// 预览附件内容(支持iWork documents、Microsoft Office documents (Office ‘97 and newer)、Rich Text Format (RTF) documents、PDF files、Images、Text files whose uniform type identifier (UTI) conforms to the public.text typ、Comma-separated value (csv) files)
- (void)PreviewAnnex:(NSString*)AnnexFullPath;

-(void)DisplayDownLoadWaittingView:(NSString*)LabelMsg;
-(void)HidDownLoadWaittingView:(NSString*)DelayMsg;

-(void)RemoveAllGraphics;
@end

@protocol DBSubjectViewMoveDelegate <NSObject>

-(void)ViewDragMove:(double)dx;

@end

@interface DBSubjectDataViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, DBDataManagerTopicDKDataQueryDelegate,DBTopicDKReloadDelegate>

@property (nonatomic, retain) IBOutlet UIView *RootView;
@property (nonatomic, retain) IBOutlet UIView *SubDataView;
@property (nonatomic, retain) IBOutlet UIView *SubView;
@property (nonatomic, retain) IBOutlet UIButton *GPRSBtn;
@property (nonatomic, retain) IBOutlet UIButton *ClosedBtn;
@property (nonatomic, retain) IBOutlet UIButton *UpdateBtn;
@property (nonatomic, retain) IBOutlet UISegmentedControl *segmentedContl;
@property (nonatomic, retain) IBOutlet UITableView *SubDataTableView;
@property (nonatomic, retain) UIWebView *BaseDataWebView;
//@property (nonatomic, retain) UITableView *LandDataTabView;
//@property (nonatomic, retain) UILabel *LandIDLabel;
//@property (nonatomic, retain) UITableView *AccessoryDataTabView;
@property (retain, nonatomic) IBOutlet UIView *BaseDataFullScreenView;
@property (retain, nonatomic) IBOutlet UIWebView *BaseDataFullScreenWebView;

@property (nonatomic, retain) NSArray *AccessoryDataArray;
@property (nonatomic, retain) DBSubProjectDataItem *SubjectDataItem;
@property (nonatomic, assign) id<DBSubjectDataViewDelegate>delegate;
@property (nonatomic, assign) id<DBDataManagerTopicDKDataQueryDelegate>DKDataDelegate;
@property (nonatomic, assign) id<DBSubjectViewMoveDelegate> DragViewDelegate;

@property (nonatomic, assign) BOOL bCloseBtnFlg;
@property (nonatomic, assign) NSInteger nCurrIndex;

// add by niurg 2015.9 for screen
@property (retain, nonatomic) IBOutlet UITableView *AccessoryTabView;
@property (retain, nonatomic) IBOutlet UISegmentedControl *fullScreenSegBtn;
- (IBAction)fullScreenSegClick:(id)sender;
// end

- (IBAction)GPRSBtnTouched:(id)sender;
- (IBAction)ClosedBtnTouched:(id)sender;
- (IBAction)UpdateBtnTouched:(id)sender;
- (IBAction)SegmentedContlTouched:(id)sender;
//- (IBAction)UpdateBtnTouched:(id)sender;
- (void)SubjectViewReloadData;
//重新加载地块数据
- (void)ReloadLandData:(NSString*)TopicId;
// 重新加载基本情况数据
- (void)ReloadReasonData:(NSString*)TopicId;
// 清除议题详细数据
- (void)CleanTopicDetailData:(NSString*)TopicID;

// nFlg- 1:调整所有控件为半屏    2:调整所有控件为全屏
-(void)adjustSubjectView:(NSInteger)nFlg;

@end
