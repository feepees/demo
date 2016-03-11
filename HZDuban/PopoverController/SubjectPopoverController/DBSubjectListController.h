//
//  DBSubjectListController.h
//  HZDuban
//
//  Created by mac on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBSubProjectDataItem.h"
#import "DBLocalTileDataManager.h"

@protocol DBSubjectDataViewAppearProtocol <NSObject>

@optional
- (void)SubjectDataViewAppearWithSubProjectDataItem:(DBSubProjectDataItem *)SubProjectData index:(NSInteger)nIndex;
// 重新加载地块数据
-(void)ReloadDKData:(NSString*)TopicId;
// 重新加载基本情况数据
-(void)ReloadTopicReasonData:(NSString*)TopicId;
// 清除议题详细数据
-(void)CleanDetailData:(NSString*)TopicID;
// 显示加载议题数据等待View
-(void)DisPlayLoadTopicDataWaittingView:(NSString*)Msg;
// 消失加载议题数据等待View
-(void)HidLoadTopicDataWaittingView:(NSString*)Msg;
// 设置显示文字
-(void)SetWaittingViewText:(NSString*)Msg;

// add by niurg 2015.9
// 刷新议题列表数据
-(void)refreshSubjectListData;

@end

@interface DBSubjectListController : UIViewController
    <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,DBDataManagerTopicDKDataQueryDelegate>
{
    UITableView *_ContentTableView;
//    NSArray * _ContentDataArray;
    id <DBSubjectDataViewAppearProtocol> delegate;
    BOOL bDownloadFlg;
    //_nDataSourceFlg = 0时是所有议题，_nDataSourceFlg = 1时候搜索得到的议题。
    int _nDataSourceFlg;
    UISearchBar *_searchBar;
    
    // 用于存放刷新议题按钮和搜索栏的容器
    UIView *_titleContainerView;
    UIButton *_refreshBtn;
}

@property (weak, nonatomic) id <DBSubjectDataViewAppearProtocol> delegate;
//@property (nonatomic, retain) NSArray *ContentDataArray;
@property (nonatomic, retain) DBSubProjectDataItem *SubProjectDataItem;
@property (nonatomic, assign) int nLoadFlg;
@property (nonatomic, retain) NSString *MeettingId;
//用来存放搜索结果（议题）
@property (nonatomic, retain) NSMutableArray *TopicResultArray;

//- (void)reloadContentDataArray:(NSArray *)array;
- (void)reloadContentDataArray:(NSString *)MeetingID;
// 显示等待View
- (void)DisPlayLoadingView:(NSString*)Msg;
// 消失等待View
- (void)HideLoadingView:(NSString*)Msg;
- (void)waitDownload;
@end
