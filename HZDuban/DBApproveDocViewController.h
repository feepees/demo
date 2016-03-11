//
//  DBApproveDocViewController.h
//  HZDuban
//
//  Created by sunz on 12-12-21.
//
//
#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>
#import "ModelTableViewController.h"
#import "SendTableViewController.h"

@interface DBApproveDocViewController  : UIViewController
<UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate, QLPreviewControllerDataSource, ModelTableViewControllerDelegate, SendTableViewControllerDelegate>
{
    UITableView *DocListView;
    UITableView *DocDetailView;
    QLPreviewController *previewCtrl;
    //Label
    UILabel *leftTitleLabel;
    UILabel *unitLabel;
    UILabel *titleLabel;
    
    //“原文”按钮的状态区分
    BOOL bIsCloseDoc;
    NSInteger DocSection;

    //键盘是否显示
    BOOL bIsKeybordShown;
    UIButton *leftTitleSearchBtn;
}

@property (nonatomic, retain) NSString *DocUnit;
@property (nonatomic, retain) NSString *DocTitle;
@property (nonatomic, retain) NSString *DocNum;
@property (nonatomic, retain) NSString *DocYearNum;
@property (nonatomic, retain) NSString *DocContent;
@property (nonatomic, retain) NSString *DocID;
@property (nonatomic, retain) NSString *searchStr;
@property (nonatomic, retain) NSMutableArray *SearchResultArr;
@property (nonatomic, retain) NSIndexPath *DocIndexPath;

//处理意见
@property (nonatomic, retain) NSString *processOpinion;
@property (nonatomic, retain) NSString *processName;
@property (nonatomic, retain) NSString *processDate;
//传阅意见
@property (nonatomic, retain) NSString *circulatedOpinion;
@property (nonatomic, retain) NSString *circulatedName;
@property (nonatomic, retain) NSString *circulatedDate;

@property (nonatomic, retain) UIPopoverController *ModelPopoverViewCtrl;
@property (nonatomic, retain) ModelTableViewController *ModelTableViewCtrl;
@property (nonatomic, retain) UIPopoverController *SendPopoverViewCtrl;
@property (nonatomic, retain) SendTableViewController *SendTableViewCtrl;

- (IBAction)BackBtnTouch:(id)sender;
/*
 view.tag说明:
        默认为0;
        搜索视图中:
            leftTitleLabel.tag = 600;
            label.tag = 400 + i;
            textField.tag = 500 + i; (i = 0; i < 6; i++)
            resetBtn.tag = 510;
            searchBtn.tag = 511;
        DocDetailView中:
            unitLabel.tag = 601;
            titleLabel.tag = 602;
 */
@end
