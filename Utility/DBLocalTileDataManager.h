//
//  DBLocalTileDataManager.h
//  HZDuban
//
//  Created by  on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>
#import "IconDownloader.h"
#import <sqlite3.h>
#import "DBMeetingDataItem.h"
#import "DBSeLayerPort.h"
#import "DBQueue.h"
#import "AuthHttpEngine.h"
#import "MKNetworkKit.h"

//#define SCREEN_WIDTH        1024
//#define SCREEN_HEIGTH       768

@protocol DBLocalTileDataManagerDelegate <NSObject>
// ResponseCode参数为服务返回数据处理结果,成功:0,错误:-1，失败:-2,处理异常:-3
- (void)POIDidQuery:(NSInteger)nStartIndex EndIndex:(NSInteger)nEndIndex ResponseCode:(NSInteger)nReCode ErrorMessage:(NSString*)ErrMsg;
//调整popoverViewSize
- (void)ResizeMapLayerPopoverViewSize;
- (void)ResizeMeetingPopoverViewSize;
- (void)ResizeXCDKListViewPopoverSize:(NSInteger)nJGState;
//让popoverView消失
- (void)MapLayerPopoverViewDisAppear;
- (void)MeetingPopoverViewDisAppear;

@end

@protocol DBDataManagerTopicDKDataQueryDelegate <NSObject>
// 议题地块数据查询结束
- (void)TopicDKDidQuery:(NSString*)TopicID;
// 议题基本情况数据查询结束
- (void)TopicReasonDidQuery:(NSString*)TopicID;
@end

@protocol DBFooterViewHiddenDelegate <NSObject>

- (void)TableFooterViewHidden;

@end

@protocol DBLocalTileDataDownloadDelegate <NSObject>

- (void)DidDownloadProgress:(float) value;

@end

//下载完毕后重新加载图层界面
@protocol DBDataMapLayerViewReloadDelegate <NSObject>

- (void)DataMapLayerViewReload;

@end

//下载完毕后重新加载会议界面
@protocol DBMeetingViewReloadDelegate <NSObject>

- (void)MeetingViewReload;

@end

// 巡查地块数据下载完毕后重新加载画面
@protocol DBXCDKViewReloadDelegate <NSObject>

- (void)XCDKViewReload:(NSInteger)nHasNewData State:(NSInteger)nDKState;

@end

// 重新加载指定议题的地块数据
@protocol DBTopicDKReloadDelegate <NSObject>

// 指定议题的地块数据下载完成
- (void)TopicDKDownloadCompleted:(NSString*)Msg;

@end

// 图层字段下载完成
@protocol DataLayerFieldReloadDelegate <NSObject>
// 数据下载完成
- (void)DataLayerFieldDownloadCompleted:(NSString*)DataMapUrl ViewFlg:(NSString*)Flg;
@end

@protocol DownloadXCDKRecordsDelegate <NSObject>

- (void)DownloadXCDKRecordsDidFinish:(NSDictionary *)result;
- (void)DownloadXCDKRecordsError:(id)result;

@end

@protocol DBXCDKUploadDelegate <NSObject>

- (void)XCDKRecordUploadFinish:(NSDictionary *)result;
- (void)XCDKRecordUploadError:(NSDictionary *)result;

@end

@protocol AuthenticateDelegate <NSObject>

- (void)authenticateDidFinish:(NSDictionary *)result;
- (void)authenticateDidError:(NSDictionary *)result;
@end

#pragma mark 闲置地块巡查
@protocol DBXCDKDownloadDelegate <NSObject>
//  闲置地块数据查询正常结束
- (void)XCDKGeometryDownloadFinish:(NSString*)XCDKID;
//  闲置数据查询出错
- (void)XCDKGeometryDownloadError:(NSString*)XCDKID;
//  巡查记录上传完成
- (void)XCRecordUploadFinish:(NSString*)XCDKID;
//  巡查记录上传出错
- (void)XCRecordUploadError:(NSString*)XCDKID;
@end
#pragma mark 地块属性查询分析
@protocol DBDKInfoQueryDelegate <NSObject>
//  地块信息查询正常结束
- (void)DKInfoQueryFinish:(NSDictionary*)DKInfoDic Geometrys:(NSMutableArray*)GeometryArr;
//  地块信息查询出错
- (void)DKInfoQueryError:(NSString*)Msg;
@end

@interface DBLocalTileDataManager : NSObject<IconDownloaderDelegate>
{

@private    
    // the main data model for our UITableView
    NSMutableArray *_entries; 

    // the set of IconDownloader objects for each app
    NSMutableDictionary *_imageDownloadsInProgress;  
    
    // database pointer
    sqlite3 *database;
    // all download count
    NSInteger SumDownloadCnt;
    // did downloaded count
    NSInteger DownloadedCnt;
    
    // 
    DBQueue *_TopicIdQueue;
    
    // 根据议题下载地块用会议ID队列
    DBQueue *_TopicDKDownloadMeetingIDQueue;
    
    // 根据专题ID下载显示字段用专题URL队列
    DBQueue *_DataLayerUrlQueue;
    DBQueue *_DataLayerUrlFlgQueue;
}

@property (nonatomic, assign) id<DBLocalTileDataManagerDelegate> delegate;
@property (nonatomic, assign) id<DBFooterViewHiddenDelegate> FooterDelegate;
@property (nonatomic, assign) id<DBLocalTileDataDownloadDelegate>LocalDelegate;
@property (nonatomic, assign) id<DBDataMapLayerViewReloadDelegate>MapLayerDelegate;
@property (nonatomic, assign) id<DBMeetingViewReloadDelegate>MeetingDelegate;
@property (nonatomic, assign) id<DBXCDKViewReloadDelegate>XCDKDelegate;
@property (nonatomic, assign) id<DownloadXCDKRecordsDelegate>XCDKRecordsDelegate;
@property (nonatomic, assign) id<DBXCDKUploadDelegate>XCDKUploadDelegate;

@property (nonatomic, assign) id<DBDataManagerTopicDKDataQueryDelegate> TopicDKDataQueryDelegate;

@property (nonatomic, assign) id<DBTopicDKReloadDelegate> TopicDKReloadDelegate;
@property (nonatomic, assign) id<DataLayerFieldReloadDelegate> DataLayerFieldReloadDe;
@property (nonatomic, assign) id<DBXCDKDownloadDelegate> XCDKDownloadDeg;
@property (nonatomic, assign) id<DBDKInfoQueryDelegate> DBDKInfoQueryDeg;
@property (nonatomic, assign) id<AuthenticateDelegate> authDelegate;

// 所有会议列表
@property (nonatomic, retain) NSMutableArray *MeetingList;

// 所有议题
//@property (nonatomic, retain) NSMutableDictionary *TopicDic;
// 地块数据(议题ID-->地块Feature)
@property (nonatomic, retain) NSMutableDictionary *TopicIDToFeatureDic;

// 会议--议题对应列表
@property (nonatomic, retain) NSMutableDictionary *TopicsOfMeeting;
// 议题ID->议题基本情况
@property (nonatomic, retain) NSMutableDictionary *TopicsReason;
// 议题ID->议题附件
@property (nonatomic, retain) NSMutableDictionary *TopicsAnnexDic;
// 议题ID->议题地块数据
@property (nonatomic, retain) NSMutableDictionary *TopicsDKDataDic;
// 每个会议下的按议题SEQ排序的议题ID的数组
@property (nonatomic, retain) NSMutableDictionary *MeettingToTopicIDSeqDic;

//图层数据
@property (nonatomic, retain) NSMutableArray *MapLayerDataArray;
@property (nonatomic, retain) NSMutableArray *POIArray;

// 物理层Id -> 层字段的映射
@property (nonatomic, retain) NSMutableDictionary *PhyLayerIdToFieldsDic;
//标注信息(MarkID-->MarkInfo)
@property (nonatomic, retain) NSMutableDictionary *MarkDic;

//存放上次搜索的关键字
@property (nonatomic, copy) NSString *LastQueryWord;

@property (nonatomic, assign) int nMeetingLoadFlg;
@property (nonatomic, assign) int nMapLayerLoadFlg;

// 议题Web服务地址
@property (nonatomic, copy) NSString *TopicWebServiceUrl;
// GISWeb服务地址
@property (nonatomic, copy) NSString *GISWebServiceUrl;
// 附件下载服务地址
@property (nonatomic, copy) NSString *AnnexDownloadServiceUrl;
// 当前底图地图URL
@property (nonatomic, copy) NSString *CurrentBaseMapUrl;

// 道路地名地址URL
@property (nonatomic, copy) NSString *RoadDataMapLayerName;
@property (nonatomic, copy) NSString *RoadDataMapLayerUrl;

// 当前选中的按钮索引
@property (nonatomic, assign) NSInteger nCurrentSelRadioBtnIndex;

//
@property (nonatomic, retain) NSMutableArray *ApproveDocDataList;

// file upload
@property (strong, nonatomic) AuthHttpEngine *AuthEngine;
// 所有未竣工巡察地块列表
@property (nonatomic, retain) NSMutableArray *XCDKList;
// 所有已竣工巡察地块列表
@property (nonatomic, retain) NSMutableArray *JGXCDKList;
// 闲置地块ID->闲置地块数据
@property (nonatomic, retain) NSMutableDictionary *XCDKGeometryDataDic;
@property (nonatomic, assign) NSInteger XCDKDownloadingFlg;     // 巡查地块是不是下载中标记
@property (nonatomic, assign) NSInteger XCRecordUploadingFlg;   // 巡查记录是不是上传中标记

// 当前会议index
@property (nonatomic, assign) NSInteger nCurMeetingRowIndex;
// 当前议题index
@property (nonatomic, assign) NSInteger nCurSubjectRowIndex;

// 0:显示所有会议     1:只显示当前会议
@property (nonatomic, strong) NSString *meetingShowConf;

// add by niurg 2015.9
// --0：不显示历史会议按钮  1：显示历史会议按钮
@property (nonatomic, strong) NSString *HistoryMeetingBtnShowConf;

// add 2015.11.22
@property (nonatomic, strong) NSString *departmentNameConf;
// end

// 当前是历史议题模式，还是当前议题模式
@property (nonatomic, strong) NSString *CurSubjectIsHistory;
// 当前议题内容视图显示区域
// 0:未显示    1:半屏      2:全屏
//@property (nonatomic, assign) NSInteger currSubjectViewArea;

// 当前议题显示模式设置
//  1:半屏模式      2:全屏模式
@property (nonatomic, assign) NSInteger currSubjectViewAreaConf;

-(void)parasedHistoryMeetingBtnShowConf:(NSData*)data;
// 顶部菜单栏上按钮的配置信息
@property (nonatomic, strong) NSDictionary *topBarBtnConfDic;

// end

-(void)parsedMeetingShowConf:(NSData *)data;

// 获取唯一实例
+ (DBLocalTileDataManager *)instance;

// 释放实例内存
+(void)releaseInstance;

// 下载指定地图服务的所有切片到本地数据库
-(BOOL)DownloadAllTilesByMapUrl:(NSURL*)MapUrl;

-(BOOL)DownLoadPOI:(NSString *)QueryString downLoadFlg:(NSInteger)nFlg;

// 根据BSM查询下载地块数据
-(BOOL)DownLoadFeatureByBsm:(NSArray *)Bsms KeyWord:(NSString*)TopicId;

//下载指定议题的基本情况数据
- (void)DownLoadTopicReasonData:(NSString*)TopicID;

// 下载指定议题的地块数据
- (void)DownLoadTopicLandData:(NSString*)TopicID MeetingId:(NSString*)MeetingID;

// 下载所有的会议
-(BOOL)DownLoadMeetingData:(NSString*)MeetingId;

// 解析所有会议数据
-(BOOL)ParseAllMeetingData:(NSData*)ResXmlData;
// 解析所有议题数据
-(BOOL)ParseAllTopicData:(NSData*)ResXmlData ConventionId:(NSString*)ConvenId;
//下载所有图层数据
- (void)DownLoadMapLayerData:(NSString*)ThemeID;
// 解析所有图层数据
- (void)ParseMapLayerData:(NSData*)ResXmlData;
// 获取指定的tile文件的全路径
-(NSString*)GetTileFullPath:(int)nLevel Row:(int)nRow Column:(int)nColumn;

// 检测指定的tile文件是否存在
-(BOOL)TileFileIsExist:(int)nLevel Row:(int)nRow Column:(int)nColumn;

#pragma mark - 清除缓存数据相关处理
//清除缓存数据
- (void)CleanLocalData;
//清除会议、议题所有相关缓存数据
- (void)CleanAllMeetingAboutCacheData;
//清除指定会议下的所有议题的所有相关缓存数据
- (void)CleanAllTopicOfMeetingCacheData:(NSString*)MeetingID;
//清除专题图层缓存数据
- (void)CleanAllDataMapCacheData;

#pragma mark - 网络状态检测
// 是否连接到Internet
-(BOOL)InternetConnectionTest;
// 是否连接到指定主机
-(BOOL)GetHostNetStatus:(NSString*)HostName;
//下载失败信息视图框
- (void)CreateFailedAlertViewWithFailedInfo:(NSString *)FailedInfo andWithMessage:(NSString *)Message;

//-------------------------------------------------------
#pragma mark -  议题Web服务Commen通用处理接口
-(void)DownloadDisplayPhyLayersFieldsByThemeID:(NSString*)ThemeID PhyLayerUrl:(NSString*)Url ViewFlg:(NSString*)Flg;

-(BOOL)QuaryRelationLandByGeometry:(AGSGeometry*)Geomery;
#pragma mark - 土地巡查
-(AuthHttpEngine*)GetNetEngine;
-(void)GetXCDKDataList:(int)StartNum Count:(int)Count StateFlg:(int)Flg;
// 下载闲置地块的指定BSM的地块
-(BOOL)DownLoadXZDKFeatureByBsm:(NSString *)Bsm XCDKDataId:(NSString*)XCDKDataId;
// 上传巡察记录数据
-(void)UploadXCRecordData:(NSString*)XCRecordDataJson;
// 下载地块巡察信息
-(void)DownloadXCDKRecords:(NSString *)DKId;

#pragma mark - check device
-(void)authentcate:(NSString *)uuid;


-(CGRect)getScreenSize;

-(AuthHttpEngine*)GetNetEngineForAnn;
@end

// 以下为私有方法
//@interface DBLocalTileDataManager(private)
//
//
//@end
