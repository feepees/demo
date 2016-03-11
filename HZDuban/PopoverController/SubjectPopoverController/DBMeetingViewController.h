//
//  DBMeetingViewController.h
//  HZDuban
//
//  Created by mac on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBSubjectListController.h"
#import "DBQueue.h"
#import "DBLocalTileDataManager.h"
#import "EGORefreshTableHeaderView.h"

@interface DBMeetingViewController : UITableViewController
    <UIPopoverControllerDelegate, UISearchBarDelegate, 
    UIScrollViewDelegate, DBMeetingViewReloadDelegate,
    EGORefreshTableHeaderDelegate>
{
    UIView *mainView;
    UIViewController * _superViewCtrl;
    
    // 为议题_Subject2ViewPopover的UI容器
    DBSubjectListController *SubContentView;
    
//    //searching Meeting
//    UISearchBar *_searchBar;
//    int _nDataSourceFlg;
    
    //DBQueue *MeetingIdQueue;
    
    //下拉刷新
    EGORefreshTableHeaderView *_refreshHeaderView;
	BOOL _reloading;
}

@property (nonatomic, retain) UIPopoverController *Subject2ViewPopover;
@property (nonatomic, retain) UIView *mainView;
@property (nonatomic, retain) UIViewController *superViewCtrl;
//@property (nonatomic, retain) NSMutableArray *MeetingResultArray;

-(void)SetSubPopoverHiden;

// 下拉刷新
- (void)reloadTableViewDataSource;
- (void)doneLoadingTableViewData;

@end
