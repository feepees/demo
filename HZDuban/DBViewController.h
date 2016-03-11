//
//  DBViewController.h
//  HZDuban2
//
//  Created by  on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import <CoreLocation/CoreLocation.h>
#import "pointInfoTemplate.h"
//#import "DBLatelySearchViewController.h"
#import "DBLatelySearchOrPOIViewController.h"
#import "DBAttributeViewController.h"
#import "DBMeetingViewController.h"
#import "DBDataMapLayerViewController.h"
#import "DBBaseMapSwitchView.h"
#import "DBDataMapLayerViewController.h"
#import "DBOfflineConfViewController.h"
#import "DBAllConfViewController.h"
#import "DBLandDataViewController.h"
#import "DBLandAttributeViewController.h"
#import "DBLandAnalyseViewController.h"
#import "DBLocalTileDataManager.h"
#import "DBSubjectDataViewController.h"
#import "MBProgressHUD.h"
#import <QuickLook/QuickLook.h>
#import "DBLandInfoViewController.h"
#import "DBMarkNoteViewController.h"
#import "DBMarkListViewController.h"
#import "DBSingleLandInfoViewController.h"
#import "DBQueryMenuViewController.h"

//contants for data layers
#define kTiledMapServiceURL_3 @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_StreetMap_World_2D/MapServer"
//#define kTiledMapServiceURL_1 @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_Imagery_World_2D/MapServer"
#define kTiledMapServiceURL_0 @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/basemp114/GGBFWDT114/MapServer"
#define kTiledMapServiceURL_1 @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/basemp114/BMYX0811/MapServer"

//#define kTiledMapServiceURL_0 @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/basemp114/YX0811114/MapServer"
#define kTiledMapServiceURL_2 @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/basemp114/YX20112000/MapServer"
//#define kTiledMapServiceURL_1 @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/basemp114/GGGL114/MapServer"
//#define kDynamicMapServiceURL @"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Specialty/ESRI_StateCityHighway_USA/MapServer"
#define kDynamicMapServiceURL_JanCeZhan @"http://172.16.200.5:8399/arcgis/rest/services/hzhuanbao/jancezhan/MapServer"
#define kDynamicMapServiceURL_WuRanYuan @"http://172.16.200.5:8399/arcgis/rest/services/hzhuanbao/wuranyuan/MapServer"
#define kDynamicMapServiceURL_WuRanQiYe @"http://172.16.200.5:8399/arcgis/rest/services/hzhuanbao/wuranqiye/MapServer"

// 检测站查询
#define kQueryMapServiceLayerURL @"http://172.16.200.5:8399/arcgis/rest/services/hzhuanbao/jancezhan/MapServer/1"
// 
#define kQueryMapServiceLayerURL2 @"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Demographics/ESRI_Census_USA/MapServer/5"

#define kQueryMapServiceLayerURL3 @"http://sampleserver1.arcgisonline.com/ArcGIS/rest/services/Demographics/ESRI_Census_USA/MapServer/3"

#define kQueryMapServiceLayerURL4 @"http://172.16.200.5:8399/arcgis/rest/services/hzhuanbao/wuranqiye/MapServer/0"

// 惠州运动会项目查询URL
#define kQueryHuiZhouSportsMeetingUrl @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/goldland/ZTDB_SYH/MapServer/6"
//惠州地块信息查询URL
#define kQueryHuiZhouLandUrl @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/ZWWZT/GTL_TDLYZTGH/MapServer/0"

#define kQueryHuiZhouLandXianZhuang @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/ZWWZT/GTL_TDLYXZ/MapServer/3"
//#define kTiledMapServiceURL @"http://services.arcgisonline.com/ArcGIS/rest/services/NatGeo_World_Map/MapServer"
//#define kTiledMapServiceURL @"http://server.arcgisonline.com/ArcGIS/rest/services/ESRI_Imagery_World_2D/MapServer"

//Set up constant for predefined where clause for search
#define kLayerDefinitionFormat @"STATE_NAME = '%@'"
//////////
#define kGeometryBufferService	@"http://172.16.200.5:8399/arcgis/rest/services/Geometry/GeometryServer/buffer"

#define kesriSRUnit_SurveyMile	9035
#define kesriSRUnit_Meter		9001

#define kWebMercator			102100
/////////

//


@interface DBViewController : UIViewController<UIScrollViewDelegate,AGSMapViewLayerDelegate, AGSMapViewTouchDelegate, AGSMapViewCalloutDelegate, AGSQueryTaskDelegate,AGSTiledLayerTileDelegate, UIPopoverControllerDelegate, UISearchBarDelegate,AGSGeometryServiceTaskDelegate,DBLatelySearchOrPOIViewDelegate, DBAttributeViewDelegate,DBDataMapLayerSwitchProtocol,DBSubjectDataViewAppearProtocol,MapLayerConfDelegate,DBAllConfDelegate, DBLandDataViewDelegate, DBLandAttributeViewDelegate,AGSIdentifyTaskDelegate,DBLandAnalyseViewControllerDelegate, DBLocalTileDataManagerDelegate, DBSubjectDataViewDelegate,MBProgressHUDDelegate, DBMarkNoteViewDelegate,
    QLPreviewControllerDataSource,                  // 预览文件代理
    QLPreviewControllerDelegate,                    // 预览文件代理
    UIDocumentInteractionControllerDelegate,        // 预览文件代理
    DataLayerFieldReloadDelegate,
    DBMarkListViewDelegate,
    DBXCDKDownloadDelegate,
    DBDKInfoQueryDelegate,
    DBMapLayerQueryDelegate,
    DBSingleLandInfoViewControllerDelegate,
    CLLocationManagerDelegate,
    DBSubjectViewMoveDelegate>

{
    // 1:会议主题模块   2:巡察监管模块
    NSInteger _nModelFlg;
    BOOL isCurl;
    UIView *_GraphicsView;

    NSMutableArray *SelectedGraphics;
    
    /// for buffer
    NSMutableArray		*_geometryArray;	/* holds on to the buffered geometries until "clear" clicked		*/
	NSInteger			 _numPoints;		/* keeps track of the number of points the user has clicked			*/
	NSMutableArray		*_pushpins;			/* holds on to the pushpins that mark where the user clicks			*/
	
	AGSGeometryServiceTask *_gst;			/* The Geometry Service Task we will use to execute operations		*/
    DBDataMapLayerViewController *DataMapLayerViewContrl;
    //DBLatelySearchViewController *DBLatelySearchViewContrl;
    DBLatelySearchOrPOIViewController *DBLatelySearchViewContrl;
    DBAttributeViewController *DBAttributeViewContrl;
    DBAllConfViewController *AllConfViewContrl;
    DBLandDataViewController *LandDataViewContrl;
    DBLandAttributeViewController *LandAttributeViewContrl;
    DBLandAnalyseViewController *DBLandAnalyseViewContrl;
    //所有标注View
    DBMarkListViewController *MarkListViewContrl;
    
    IBOutlet UIView *TopToolBarView;
    IBOutlet UIImageView *TopDataDisplayImageView;
    IBOutlet UILabel *TopDataDisplayLabel;
    IBOutlet UIButton *TopAddMesureBtn;
    
    DBMeetingViewController *MeetingView;
    
    // 当前测量flag: 0-无测量   1-测量长度  2-测量面积
    int nMeasureFlag;
    
//    // 业务图层名称
//    NSMutableArray *_DataMapLayerNameArray;
//    // 业务图层是否显示标记
//    NSMutableArray *_DataMapLayerSwitchArray;
//    NSMutableArray *_DataMapLayerUrlArray;
    
    //
    NSMutableDictionary *_BaseMapLayersDic;
    NSMutableArray *layerNameArr;
    NSMutableArray *IndexArr;
    
    // for image view
    UIView *PictureView;
    UIScrollView *_scrollView;
    UIPageControl * pageCtl;
    NSInteger lastPage;
    BOOL bIsXianZhuangBtnTouched;
    BOOL bIsPlanBtnTouched;
    BOOL bIsPriceBtnTouched;
    BOOL bIsInfoBtnTouched;
    
    BOOL bIsLengthBtnTouched;
    BOOL bIsAreaBtnTouched;
    BOOL bIsMeasureDataCalcuate;
    IBOutlet UIButton *LengthBtn;
    IBOutlet UIButton *AreaBtn;
    UIView *PictureRootView;
    
    UIButton *LastClickButton;
    NSArray *_LastBtnImageArray;
    //拉框查询
    AGSPoint *beginPoint;
    AGSPoint *endPoint;
    
    NSString *_CurrentDataLayerUrl;
    AGSIdentifyTask *_IdentifyTask;
    // 现状分析 
    AGSIdentifyTask *_AnalyseIdentifyTask;
    //议题信息视图
    UIView *SubjectDataView;
    //-----------------------------------
    //等待试图框
    UIAlertView *_waitingDialog;
    
    MBProgressHUD *HUD;
	long long expectedLength;
	long long currentLength;
    //-----------------------------------
    // 用于地块分析的几何数据
    DBQueue *_LandAnalyseGeometryQueue;
    
    CLLocationManager *localManager;
    
}
@property (assign, nonatomic) NSInteger nModelFlg;
//@property (nonatomic, assign) AGSDynamicMapServiceLayer *dynamicLayer;
@property (retain, nonatomic) IBOutlet AGSMapView *BaseMapView;
@property (retain, nonatomic) IBOutlet UIButton *SubjectBtn;
@property (retain, nonatomic) IBOutlet UIButton *ViewInfoBtn;
@property (retain, nonatomic) IBOutlet UIButton *ViewPriceBtn;
@property (retain, nonatomic) IBOutlet UIButton *PlanBtn;
@property (retain, nonatomic) IBOutlet UIButton *XianZhuangBtn;
@property (retain, nonatomic) IBOutlet UIButton *PolygonBtn;
@property (retain, nonatomic) IBOutlet UIButton *PolygonLineBtn;

@property (retain, nonatomic) IBOutlet UIView *MapContainterView;

@property (retain, nonatomic) IBOutlet UIButton *MapLocationBtn;
@property (retain, nonatomic) IBOutlet UIButton *BaseMapSwitchBtn;

//@property (retain, nonatomic) IBOutlet UISearchBar *SearchBarCtrl;
@property (retain, nonatomic) IBOutlet UILabel *departmentNameLabel;

//@property (retain, nonatomic) IBOutlet UILabel *DepartmentNameLabel;
@property (retain, nonatomic) IBOutlet UITextField *SearchBarCtrl;
@property (nonatomic, retain) UIView *GraphicsView;

/// add by z
@property (nonatomic, retain) UIPopoverController *DataMapLayerViewPopover;
@property (nonatomic, retain) UIPopoverController *MeetingViewPopover;

@property (nonatomic, retain) UIPopoverController *LatelySearchViewPopover;
@property (nonatomic, retain) UIPopoverController *singleDataPopover;
@property (nonatomic, retain) UIPopoverController *GraphicAttPopoverView;
@property (nonatomic, retain) UIPopoverController *AllConfPopoverView;

@property (nonatomic, retain) UIPopoverController *LandDataPopoverView;
@property (nonatomic, retain) UIPopoverController *LandAttributePopoverView;
@property (nonatomic, retain) UIPopoverController *LandAnalysePopoverView;
//所有标注PopoverView
@property (nonatomic, retain) UIPopoverController *MarkListPopoverView;

/////////////////////////////// for buffer
@property (nonatomic, retain) NSMutableArray *geometryArray;
@property (nonatomic, retain) NSMutableArray *pushpins;

@property (nonatomic, retain) AGSGeometryServiceTask *gst;

//@property (nonatomic, retain) NSMutableArray *DataMapLayerNameArray;
//@property (nonatomic, retain) NSMutableArray *DataMapLayerUrlArray;
//@property (nonatomic, retain) NSMutableArray *DataMapLayerSwitchArray;
@property (nonatomic, retain) NSMutableDictionary *BaseMapLayersDic;
@property (nonatomic, retain) NSMutableArray *layerNameArr;
@property (nonatomic, retain) NSMutableArray *IndexArr;
@property (nonatomic, retain) NSArray *LastBtnImageArray;
//拉框查询
@property (retain, nonatomic) AGSPoint *beginPoint;
@property (retain, nonatomic) AGSPoint *endPoint;
// 地价查询
@property (retain, nonatomic) AGSIdentifyTask *IdentifyTask;
// 现状分析
@property (retain, nonatomic) AGSIdentifyTask *AnalyseIdentifyTask;
//单例对象
@property (nonatomic, retain) DBLocalTileDataManager *SingleManager;
@property (nonatomic, retain) UIView *SubjectDataView;
@property (nonatomic, retain) DBSubjectDataViewController *SubjectView;

//地块详细信息
@property (nonatomic, retain) DBLandInfoViewController *LandInfoViewContrl;
//我的标注
@property (nonatomic, retain) DBMarkNoteViewController *MarkNoteViewContrl;

// bug fix
@property (nonatomic, retain) DBQueue *LandAnalyseGeometryQueue;
@property (nonatomic, retain) DBMeetingViewController *MeetingView;

@property (nonatomic, retain) DBQueryMenuViewController *QueryMenuViewCtrl;
@property (nonatomic, retain) UIPopoverController *QueryMenuPopoverView;

@property (nonatomic, retain) CLLocationManager *locationManager;

@property (retain, nonatomic) IBOutlet UISegmentedControl *MapTypeSegCtrl;
@property (retain, nonatomic) IBOutlet UIButton *MapLayerBtn;
@property (retain, nonatomic) IBOutlet UIButton *MapLayerBtn2;

@property (retain, nonatomic) IBOutlet UIButton *MapToolsBtn;
@property (retain, nonatomic) IBOutlet UIButton *MapToolsBtn2;

@property (retain, nonatomic) IBOutlet UIButton *MapConfBtn;

// 影像按钮
@property (retain, nonatomic) IBOutlet UIButton *MapYingXiangBtn;
- (IBAction)MapYingXiangBtnClick:(id)sender;

// 地图按钮
@property (retain, nonatomic) IBOutlet UIButton *MapCommonBtn;
- (IBAction)MapCommonBtnClick:(id)sender;

// 混合按钮
@property (retain, nonatomic) IBOutlet UIButton *MapMixedBtn;
- (IBAction)MapMixedBtnClick:(id)sender;

- (IBAction)MapTypeSegCtrlClick:(id)sender;

- (IBAction)MapLayerBtnClick:(id)sender;
- (IBAction)MapLayerBtnClick2:(id)sender;

- (IBAction)MapToolsBtnClick:(id)sender;
- (IBAction)MapToolsBtnClick2:(id)sender;

- (IBAction)MapConfBtnClick:(id)sender;

/*  Called when the user clicks the "Go" button on the UINavigation Bar
 *  Kicks off the Geometry Service Task given the user has selected >= 1 point
 */
//- (void)goBtnClicked:(id)sender;


/*  Clears all of the graphics from the view
 */
- (void)clearGraphicsBtnClicked:(id)sender;
- (IBAction)BackBtnTouch:(id)sender;

// 翻页效果
- (void) doCurl;

///////////////////////////////
// 业务图层菜单
- (IBAction)MapLayerTouched:(id)sender;
// 议题菜单
- (IBAction)SubjectMenuTouched:(id)sender;

// add by niurg 2015.9
- (IBAction)HistorySubjectMenuTouched:(id)sender;
@property (retain, nonatomic) IBOutlet UIButton *historySubjectMenuBtn;

@property (retain, nonatomic) IBOutlet UIButton *tuGuiMenuBtn;
@property (retain, nonatomic) IBOutlet UIButton *chengGuiMenuBtn;
@property (retain, nonatomic) IBOutlet UIButton *luWangMenuBtn;
@property (retain, nonatomic) IBOutlet UIButton *faZhengMenuBtn;
- (IBAction)tuGuiMenuBtnClick:(id)sender;
- (IBAction)chengGuiMenuBtnClick:(id)sender;
- (IBAction)luWangMenuBtnClick:(id)sender;
- (IBAction)faZhengMenuBtnClick:(id)sender;


// end

// 查看价格
- (IBAction)ViewPriceBtnTouched:(id)sender;
// 现状
- (IBAction)XianZhuangBtnTouched:(id)sender;
// 规划
- (IBAction)PlanBtnTouched:(id)sender;
// 查询属性信息
- (IBAction)ViewInfoBtnTouched:(id)sender;

// 测距
- (IBAction)polylineTouched:(id)sender;
// 测面
- (IBAction)polygonTouched:(id)sender;
// 书签
- (IBAction)BookMarkBtnTouched:(id)sender;

// 地图定位
- (IBAction)MapLocationBtnTouched:(id)sender;
// 打开底图切换view
- (IBAction)BaseMapBtnTouched:(id)sender;

// 切换底图实际操作
-(void)SetBaseMapType:(NSString*)strMapType;
// 添加测量元素信息
- (IBAction)TopAddMesureClick:(id)sender;

//清除
- (IBAction)ClearGraphicBtnTouched:(id)sender;
//-----------------------------------
//等待试图框
- (void)myTask;
- (void)myProgressTask;
- (void)myMixedTask;
- (void)DisplayLoadingView:(UIView*)ForView TipText:(NSString*)TipString;
//- (void)HidLoadingView:(UIView*)ForView;
- (void)HidLoadingView:(UIView*)ForView afterDelay:(NSTimeInterval)delay;
//-----------------------------------
@end
