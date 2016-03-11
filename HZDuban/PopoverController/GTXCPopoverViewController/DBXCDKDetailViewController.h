//
//  DBXCDKDetailViewController.h
//  HZDuban
//
//  Created by mac  on 13-6-24.
//
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "DBSubProjectDataItem.h"
#import "DBLocalTileDataManager.h"
#import "DBXCDKDataItem.h"
#import "ELCImagePickerController.h"
#import "DBChoosePicViewController.h"
#import "DBChooseDateViewController.h"


@protocol DBXCDKDataViewDelegate <NSObject>

- (void)XCDKGeometryLocation:(NSString*)XCDKId;
- (void)ClosedBtnTouchedWithFlag:(BOOL)flag;
- (void)LandDataViewAppear:(NSString*)TopicId  DKBsm:(NSString*)DKbsm newCenterPoint:(AGSPoint*)centerPoint;

-(void)DisplayGeometryOnMap:(AGSGeometry*)Geometry;
-(void)OpenPolygonDrawing;
//
//-(void)DisplayDownLoadWaittingView:(NSString*)LabelMsg;
//-(void)HidDownLoadWaittingView:(NSString*)DelayMsg;
//- (void)QueryIllegalBuildings;
-(void)DisplayGeometryNameView:(NSString*)GeometryName GeometryMemo:(NSString*)Memo;

-(void)DisplayLoadingXCDKView:(NSString*)Msg;

@end

@interface DBXCDKDetailViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ELCImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, DBChoosePicViewControllerDelegate, UITextViewDelegate, DBChooseDateViewControllerDelegate,DownloadXCDKRecordsDelegate, DBXCDKUploadDelegate>
{
    UITableView *TaskTableView;
    UIView *TaskView;
    //标记CloseBtn的图片状态
    BOOL bCloseBtnFlg;
}

@property (nonatomic, retain) NSDictionary *DBXCDKDataDic;

// 保存当前巡察记录的图片文件的地址及备注
@property (nonatomic, retain) NSMutableArray *XCRecordImagesArr;
// 保存当前巡察记录的视频文件地址及备注
@property (nonatomic, retain) NSMutableArray *XCRecordVideosArr;
// 保存当前巡察登记表基本信息
@property (nonatomic, retain) NSMutableDictionary *XCRecordDataDic;
// 保存当前巡察记录的采集界限数据列表
@property (nonatomic, retain) NSMutableArray *CurrXCRecordGeometryArr;

@property (nonatomic, retain) NSMutableDictionary *SourceDic;
@property (nonatomic, retain) UIPopoverController *ChoosePicViewPopover;
@property (nonatomic, retain) UIPopoverController *ChooseDateViewPopover;

@property (nonatomic, retain) IBOutlet UITableView *LandInfoTableView;
@property (nonatomic, retain) IBOutlet UIButton *GPRSBtn;
@property (nonatomic, retain) IBOutlet UIButton *ClosedBtn;
@property (nonatomic, retain) IBOutlet UIButton *PatrolBtn;

@property (nonatomic, assign) id<DBXCDKDataViewDelegate>delegate;
@property (nonatomic, assign) id<DBDataManagerTopicDKDataQueryDelegate>DKDataDelegate;

@property (nonatomic, assign) BOOL bCloseBtnFlg;

@property (nonatomic, assign) NSInteger nTaskRunningFlg;      // 是不是在巡察任务画面  0:未巡察中  1:巡察中

// 当前地块的巡察记录文件名称(包含扩展名)
@property (nonatomic, retain) NSString *CurrentXCRecordFileName;
// 当前地块的巡察记录文件信息列表
@property (nonatomic, retain) NSMutableArray *LocalXCRecordFileArr;

@property (nonatomic, retain) NSMutableArray *netXCRecordFileArr;

@property (nonatomic, retain) UIImagePickerController *imgPicker;


- (IBAction)GPRSBtnTouched:(id)sender;
- (IBAction)ClosedBtnTouched:(id)sender;
- (IBAction)PatrolBtnTouched:(id)sender;

// 添加采集界限
-(void)AddGeometryItem:(NSString*)Name Memo:(NSString*)Memo;

// 存储当前巡察记录的地块采集数据
-(void)AddGeometryData:(AGSGeometry*)Geometry;

//reloadView
- (void)SubjectViewReloadData;
@end
