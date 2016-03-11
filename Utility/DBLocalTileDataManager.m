//
//  DBLocalTileDataManager.m
//  HZDuban
//
//  Created by  on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBLocalTileDataManager.h"
#import "TileImageRecord.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "Logger.h"
#import "DBSubProjectDataItem.h"
#import "DBPOIData.h"
#import "DBTopicDKDataItem.h"
#import "DB2GoverDeciServerService.h"
#import "DBMapLayerDataItem.h"
#import "DBTopicAnnexDataItem.h"
#import "Reachability.h"
#import "DBDisplayFieldDataItem.h"
#import "NSString+HTML.h"
#import "CommHeader.h"
#import "EncryptUtil.h"

static DBLocalTileDataManager *LocalTileDataManagerObj = nil;

//static NSString *DBName = @"OfflineTiles.db";
//static NSString *TableServicesName = @"MapServices";

// 数据库的名称
#define  DATABASE_FILE_NAME     @"OfflineTiles.db"
// 表的名称
#define  TABLE_SERVICE_NAME     @"MapServices"
// 加密key
#define ENCRYPT_KEY @"sunztech"
// 当前模块名称
#define CURRENT_MODULE_NAME  @"SUNZDECI"

@interface DBLocalTileDataManager ()

@property (nonatomic, assign) BOOL more;

@end

@implementation DBLocalTileDataManager
@synthesize delegate = _delegate;
@synthesize MeetingList = _MeetingList;

@synthesize TopicsOfMeeting = _TopicsOfMeeting;
@synthesize TopicsReason = _TopicsReason;
@synthesize TopicsAnnexDic = _TopicsAnnexDic;
@synthesize POIArray;
@synthesize LastQueryWord;
@synthesize FooterDelegate;
@synthesize LocalDelegate;
@synthesize TopicIDToFeatureDic = _TopicIDToFeatureDic;
@synthesize TopicDKDataQueryDelegate = _TopicDKDataQueryDelegate;
@synthesize MapLayerDelegate;
@synthesize MeetingDelegate;
@synthesize XCDKDelegate = _XCDKDelegate;
@synthesize nMeetingLoadFlg = _nMeetingLoadFlg;
@synthesize nMapLayerLoadFlg = _nMapLayerLoadFlg;
@synthesize MapLayerDataArray;
@synthesize TopicWebServiceUrl = _TopicWebServiceUrl;
@synthesize GISWebServiceUrl = _GISWebServiceUrl;
@synthesize AnnexDownloadServiceUrl = _AnnexDownloadServiceUrl;
@synthesize CurrentBaseMapUrl = _CurrentBaseMapUrl;
@synthesize MarkDic = _MarkDic;
@synthesize TopicDKReloadDelegate;
@synthesize TopicsDKDataDic = _TopicsDKDataDic;
@synthesize RoadDataMapLayerUrl = _RoadDataMapLayerUrl;
@synthesize RoadDataMapLayerName = _RoadDataMapLayerName;
@synthesize MeettingToTopicIDSeqDic = _MeettingToTopicIDSeqDic;
@synthesize nCurrentSelRadioBtnIndex = _nCurrentSelRadioBtnIndex;
@synthesize PhyLayerIdToFieldsDic = _PhyLayerIdToFieldsDic;
@synthesize DataLayerFieldReloadDe = _DataLayerFieldReloadDe;
@synthesize ApproveDocDataList = _ApproveDocDataList;
@synthesize XCDKList = _XCDKList;
@synthesize JGXCDKList = _JGXCDKList;
@synthesize more = _more;
@synthesize AuthEngine = _AuthEngine;
@synthesize XCDKGeometryDataDic = _XCDKGeometryDataDic;
@synthesize XCDKDownloadDeg = _XCDKDownloadDeg;
@synthesize XCDKDownloadingFlg = _XCDKDownloadingFlg;
@synthesize XCRecordUploadingFlg = _XCRecordUploadingFlg;
@synthesize nCurMeetingRowIndex = _nCurMeetingRowIndex;
@synthesize nCurSubjectRowIndex = _nCurSubjectRowIndex;
@synthesize DBDKInfoQueryDeg;
@synthesize topBarBtnConfDic = _topBarBtnConfDic;

#pragma mark 单例生命周期相关处理
//-----------------------------
// 初期化
-(id)init
{
    self = [super init];
    if(self)
    {
        //_TopicWebServiceUrl = @"http://172.16.200.5:8081/szmap/services/sdelayerport";
        _entries = [[NSMutableArray alloc] initWithCapacity:2]; 
        _MeetingList = [[NSMutableArray alloc] initWithCapacity:5];
        _XCDKList = [[NSMutableArray alloc] initWithCapacity:5];
        _JGXCDKList = [[NSMutableArray alloc] initWithCapacity:5];
        DownloadedCnt = 0;
        self.POIArray = [NSMutableArray arrayWithCapacity:0];
        _TopicsOfMeeting = [[NSMutableDictionary alloc] initWithCapacity:2];
        _TopicsReason = [[NSMutableDictionary alloc] initWithCapacity:5];
        _TopicsAnnexDic = [[NSMutableDictionary alloc] initWithCapacity:5];
        _TopicsDKDataDic = [[NSMutableDictionary alloc] initWithCapacity:5]; 
        self.MapLayerDataArray = [NSMutableArray arrayWithCapacity:0];
        _nMeetingLoadFlg = 0;
        _nMapLayerLoadFlg = 0;
        _TopicIdQueue = [[DBQueue alloc] init];
        _TopicDKDownloadMeetingIDQueue = [[DBQueue alloc] init];
        _TopicIDToFeatureDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        self.MarkDic = [NSMutableDictionary dictionaryWithCapacity:0];
        self.MeettingToTopicIDSeqDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        _nCurrentSelRadioBtnIndex = -1;
        self.PhyLayerIdToFieldsDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        _DataLayerUrlQueue = [[DBQueue alloc] init];
        _DataLayerUrlFlgQueue = [[DBQueue alloc] init];
        
        self.ApproveDocDataList = [[NSMutableArray alloc] initWithCapacity:5];
        _XCDKGeometryDataDic = [[NSMutableDictionary alloc] initWithCapacity:2];
        _XCDKDownloadingFlg = 0;
        _XCRecordUploadingFlg = 0;
        _nCurMeetingRowIndex = -1;
        _nCurSubjectRowIndex = -1;
        
        // add by niurg 2015.9
        // 初始为隐藏状态
//        _currSubjectViewArea = 0;
        // 默认为半屏模式设置
        _currSubjectViewAreaConf = 1;
        // 默认为当前议题模式
        _CurSubjectIsHistory = @"0";
        // end
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"DBConfigure.xml"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:path];
        if (!bRet) {
            // 本地无此文件，则将此文件拷贝到本地目录。
            NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
            NSError *err;
            [fileMgr copyItemAtPath:xmlFilePath toPath:path error:&err];
        }
        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:path];
        [self parsedDataMapLayerFromData:xmlData];
        [xmlData release];
        
        // add by niurg 2015.9
        path = [documentsDirectory stringByAppendingPathComponent:@"topMenuBarBtnConf.json"];
        bRet = [fileMgr fileExistsAtPath:path];
        NSError *err;
        // bug fix 2015.11.22 begin
//        if (bRet) {
//            // 本地有此文件，则删除重新拷贝新的
//            [fileMgr removeItemAtPath:path error:&err];
//        }
//        // 本地无此文件，则将此文件拷贝到本地目录。
//        NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:@"topMenuBarBtnConf" ofType:@"json"];
//        
//        [fileMgr copyItemAtPath:jsonFilePath toPath:path error:&err];

        if (!bRet) {
            // 本地无此文件，则将此文件拷贝到本地目录。
            NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:@"topMenuBarBtnConf" ofType:@"json"];
            [fileMgr copyItemAtPath:jsonFilePath toPath:path error:&err];
        }
        else
        {
            // 如果本地已经有，则读取本地即可
        }
        
        // end
        
        NSData *JsonData = [NSData dataWithContentsOfFile:path];
        _topBarBtnConfDic = [NSJSONSerialization JSONObjectWithData:JsonData options:NSJSONReadingAllowFragments error:nil];
        [_topBarBtnConfDic retain];
        // end
    }
    
    return self;
}

//-----------------------------
// 内存释放
-(void)dealloc
{
    [_DataLayerUrlFlgQueue release];
    [_DataLayerUrlQueue release];
    [self.PhyLayerIdToFieldsDic release];
    [self.MeettingToTopicIDSeqDic release];
    [_RoadDataMapLayerName release];
    [_RoadDataMapLayerUrl release];
    _TopicsReason = nil;
    _TopicsAnnexDic = nil;
    _TopicsDKDataDic = nil;
    _TopicWebServiceUrl = nil;
    self.GISWebServiceUrl = nil;
    _TopicIdQueue = nil;
    _TopicDKDownloadMeetingIDQueue = nil;
    _TopicIDToFeatureDic = nil;
    self.TopicsOfMeeting = nil;
    [_entries release];
    self.MeetingList = nil;
    [self.XCDKList removeAllObjects];
    [self.XCDKList release];
    self.XCDKList = nil;
    [self.JGXCDKList removeAllObjects];
    [_JGXCDKList release];
    self.POIArray = nil;
    self.LastQueryWord = nil;
    self.MapLayerDataArray = nil;
    self.MarkDic = nil;
    
    [self.ApproveDocDataList removeAllObjects];
    self.ApproveDocDataList = nil;
    [self.XCDKGeometryDataDic removeAllObjects];
    [_XCDKGeometryDataDic release];
    _XCDKGeometryDataDic = nil;
    [self.DBDKInfoQueryDeg release];
    [super dealloc];
}

//--------------------------------
// 获取单例
+ (DBLocalTileDataManager *)instance 
{	 
    @synchronized(self) 
    {
        if (LocalTileDataManagerObj == nil) 
        {
            [[self alloc] init];
        }
    }
    return LocalTileDataManagerObj;
}

//--------------------------------
// 唯一一次 alloc 单例，之后均返回 nil~
+(id) allocWithZone:(NSZone *)zone 
{
    @synchronized(self) {
        if (LocalTileDataManagerObj == nil) 
        {
            LocalTileDataManagerObj = [super allocWithZone:zone];
            return LocalTileDataManagerObj;
        }
    }
    return nil;
}

//--------------------------------
// copy 返回单例本身~
-(id) copyWithZone:(NSZone *)zone 
{
    return self;
}

//--------------------------------
// retain 返回单例本身~
-(id) retain 
{
    return self;
}

//--------------------------------
// 引用计数总是为 1~
-(NSUInteger) retainCount 
{
    return 1;
}

//--------------------------------
// release 不做任何处理~
-(oneway void) release 
{
    
}

//--------------------------------
// autorelease 返回单例本身~
-(id) autorelease {
    return self;
}

//---------------------------------
// 真 release 私有接口~
-(void) realRelease 
{
    [super release];
}

#pragma mark - 清除缓存数据
- (void)CleanLocalData
{
    [self.POIArray removeAllObjects];
    [self.MarkDic removeAllObjects];
}

#pragma mark - 清除会议、议题所有相关缓存数据
- (void)CleanAllMeetingAboutCacheData
{
    @try {
        // 所有会议描述数据
        [self.MeetingList removeAllObjects];
        // 所有巡察地块数据
        [self.XCDKList removeAllObjects];
        [_JGXCDKList removeAllObjects];
        // 所有议题描述数据
        [self.TopicsOfMeeting removeAllObjects];
        // 议题基本情况数据
        [self.TopicsReason removeAllObjects];
        // 议题地块描述数据
        [self.TopicsDKDataDic removeAllObjects];
        // 议题下相关地块坐标数据
        [self.TopicIDToFeatureDic removeAllObjects];
        // 议题附件相关数据
        [self.TopicsAnnexDic removeAllObjects];
        // 会议下议题顺序ID列表
        [self.MeettingToTopicIDSeqDic removeAllObjects];
        
        // 闲置地块数据列表
        [self.XCDKGeometryDataDic removeAllObjects];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }

}
#pragma mark - 清除指定会议下的所有议题的所有相关缓存数据
- (void)CleanAllTopicOfMeetingCacheData:(NSString*)MeetingID
{
    @try {
        
        // 所有议题描述数据
        NSArray  *allTopicID = [[self.TopicsOfMeeting objectForKey:MeetingID] allKeys];
        
        // 议题基本情况数据
        [self.TopicsReason removeObjectsForKeys:allTopicID];
        
        // 议题地块描述数据
        [self.TopicsDKDataDic removeObjectsForKeys:allTopicID];
        
        // 议题下相关地块坐标数据
        [self.TopicIDToFeatureDic removeObjectsForKeys:allTopicID];
        
        // 议题附件相关数据
        [self.TopicsAnnexDic removeObjectsForKeys:allTopicID];
        
        // 会议下议题顺序ID列表
        [self.MeettingToTopicIDSeqDic removeObjectForKey:MeetingID];
        
        [self.TopicsOfMeeting removeAllObjects];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }
}
#pragma mark - 清除专题图层缓存数据
- (void)CleanAllDataMapCacheData
{
    @try {
        // 清除缓存数据
        [self.MapLayerDataArray removeAllObjects];
        _nCurrentSelRadioBtnIndex = -1;
        //清除专题图层及配置信息文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *MapLayerDataPath = [documentsDirectory stringByAppendingPathComponent:@"DBMapLayerData.xml"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
        if (bRet) {
            // 
            NSError *err;
            [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }
}

#pragma mark - 检测网络状态
//----------------------------------------------------------
// 是否连接到Internet
-(BOOL)InternetConnectionTest
{
    Reachability *netRea = [Reachability reachabilityForInternetConnection];
    NetworkStatus  sta = [netRea currentReachabilityStatus];
    if (sta == NotReachable) {
        return NO;
    }
    else if (ReachableViaWWAN == sta) {
        return YES;
    }
    else if(ReachableViaWiFi == sta){
        return YES;
    }
    return NO;
}

// 是否连接到指定主机
-(BOOL)GetHostNetStatus:(NSString*)HostName
{
    //Reachability *hostReach = [[Reachability reachabilityWithHostName:HostName] retain];
    Reachability *hostReach = [Reachability reachabilityWithHostname:HostName];
    NetworkStatus netStatus = [hostReach currentReachabilityStatus];
    if((netStatus == ReachableViaWiFi) || (netStatus == ReachableViaWWAN))
    {
        return YES;
    }
    else {
        return NO;
    }
}


#pragma mark - 显示警告
//----------------------------------------------------------
//下载失败信息视图框
- (void)CreateFailedAlertViewWithFailedInfo:(NSString *)FailedInfo andWithMessage:(NSString *)Message
{
    
    //下载失败信息视图框
    UIAlertView *FailedAlertView= [[UIAlertView alloc] initWithTitle:FailedInfo message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [FailedAlertView show];
    [FailedAlertView release];
}

#pragma mark -  议题Web服务Commen通用处理接口
//-------------------------------------------------------
-(void)CallCommonGeoverService:(NSString*)XmlParams  action:(SEL)_action
{
    @try {
        DB2GoverDeciServerService* service = [DB2GoverDeciServerService service];
        service.logging = YES;
        [UIApplication showNetworkActivityIndicator:YES];
        [service CommonService:self action:_action arg0: XmlParams];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }
}
/*
#pragma mark -  根据BSM和层名称到数据库查询相应的地块数据
//-------------------------------------------------------
-(void)DownLoadDKDataByBsmAndLayerName:(NSString*)Bsm LayerName:(NSString*)_LayerName
{
    NSString * Param = [NSString stringWithFormat:@"<root><function>DownLoadDKDataByBsmAndLayerName</function><params><Bsm>%@</Bsm><LayerName>%@</LayerName></params></root>", Bsm, _LayerName];
    NSString * Param2 = [Param stringByEncodingHTMLEntities];
    [self CallCommonGeoverService:Param2 action:@selector(DownLoadDKDataByBsmAndLayerNameHandler:)];
}
//-------------------------------------------------------
// 接收数据
- (void) DownLoadDKDataByBsmAndLayerNameHandler: (id) value {
    [UIApplication showNetworkActivityIndicator:NO];
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
        //NSLog(@"%@", value);
        NSError *error = (NSError *)value;
        NSString *string = [error localizedDescription];
        [self CreateFailedAlertViewWithFailedInfo:@"数据下载错误" andWithMessage:string];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		//NSLog(@"%@", value);
        SoapFault *soapFault = (SoapFault *)value;
        NSString *string = [soapFault description];
        [self CreateFailedAlertViewWithFailedInfo:@"数据服务器无响应" andWithMessage:string];
		return;
	}				
    
    NSDictionary *dicData = (NSDictionary*)value;
    NSString *str = [dicData objectForKey:@"return"];
    NSData *XmlData = [str dataUsingEncoding:NSUTF8StringEncoding];
}
*/

#pragma mark -  下载指定的层显示的字段
//-------------------------------------------------------
-(void)DownloadDisplayPhyLayersFieldsByThemeID:(NSString*)ThemeID PhyLayerUrl:(NSString*)Url ViewFlg:(NSString*)Flg
{
    NSString * Param = [NSString stringWithFormat:@"<root><function>DownloadDisplayPhyLayersFieldsByThemeID</function><params><param>%@</param></params></root>", ThemeID];
    //加密处理
    NSString *encryptParam = [NSString stringWithFormat:@"<![CDATA[%@]]>", [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY]];
    [self CallCommonGeoverService:encryptParam action:@selector(DownloadDisplayPhyLayersFieldsByThemeIDHandler:)];
    [_DataLayerUrlQueue enqueue:Url];
    [_DataLayerUrlFlgQueue enqueue:Flg];
    return;
}
//
//-------------------------------------------------------
// 接收数据
- (void) DownloadDisplayPhyLayersFieldsByThemeIDHandler: (id) value {
    [UIApplication showNetworkActivityIndicator:NO];
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
        //NSLog(@"%@", value);
        NSError *error = (NSError *)value;
        NSString *string = [error localizedDescription];
        [self CreateFailedAlertViewWithFailedInfo:@"数据下载错误" andWithMessage:string];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		//NSLog(@"%@", value);
        SoapFault *soapFault = (SoapFault *)value;
        NSString *string = [soapFault description];
        [self CreateFailedAlertViewWithFailedInfo:@"数据服务器无响应" andWithMessage:string];
		return;
	}				
    
    NSString *url = [_DataLayerUrlQueue dequeue];
    NSString *flg = [_DataLayerUrlFlgQueue dequeue];
    NSDictionary *dicData = (NSDictionary*)value;
    NSString *str = [dicData objectForKey:@"return"];
    NSString *plainStr = [EncryptUtil decryptUseDES:str key:ENCRYPT_KEY];
    NSData *XmlData = [plainStr dataUsingEncoding:NSUTF8StringEncoding];
    [self ParseAllFieldData:XmlData DataMapUrl:url ViewFlg:flg];
}

// 解析所有字段数据
-(BOOL)ParseAllFieldData:(NSData*)ResXmlData DataMapUrl:(NSString*)Url ViewFlg:(NSString*)Flg
{
    BOOL bRet = NO;
    DDXMLDocument *doc = nil;
    @try {
        doc = [[DDXMLDocument alloc] initWithData:ResXmlData options:0 error:nil];
        // add by niurg 2012.11.27
        bRet = [self IsHasValue:doc];
        if (!bRet) {
            return YES;
        }
        // end
        
        NSArray *meeting = [doc nodesForXPath:@"//ThemeField/ThemeFieldJSONArray/ThemeFieldObject" error:nil];
        //DBLocalTileDataManager *Meeting = [DBLocalTileDataManager instance];
        
        NSMutableArray *FieldArray = [NSMutableArray arrayWithCapacity:1];
        for (DDXMLElement *obj in meeting) 
        {
            DBDisplayFieldDataItem *DBDisplayFieldData = [[DBDisplayFieldDataItem alloc] init];
            // ID
            DDXMLElement *eleVal = [obj elementForName:@"FIELDDEFID"];
            DBDisplayFieldData.FIELDDEFID = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"FIELDDEFALIAS"];
            DBDisplayFieldData.FIELDDEFALIAS = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"FIELDDEFNAME"];
            DBDisplayFieldData.FIELDDEFNAME = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"FIELDDEFTYPE"];
            DBDisplayFieldData.FIELDDEFTYPE = eleVal.stringValue;
            
            //
            eleVal = [obj elementForName:@"FDISNULL"];
            DBDisplayFieldData.FDISNULL = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"FDDEFAULT"];
            DBDisplayFieldData.FDDEFAULT = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"PHYLAYERID"];
            DBDisplayFieldData.PHYLAYERID = eleVal.stringValue;
            
            // 查询这个url要显示的字段
            [FieldArray addObject:DBDisplayFieldData];
            [DBDisplayFieldData release];
            bRet = YES;
        }
        id value = [self.PhyLayerIdToFieldsDic valueForKey:Url];
        if (value == nil) {
            [self.PhyLayerIdToFieldsDic setObject:FieldArray forKey:Url];
        }
        //[self.PhyLayerIdToFieldsDic setObject:FieldArray forKey:Url];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        //bRet = NO;
    }
    @finally {
        [doc release];
        if (bRet) {
            [self.DataLayerFieldReloadDe DataLayerFieldDownloadCompleted:Url ViewFlg:Flg];
        }
        return bRet;
    }
}

#pragma mark 下载会议数据处理
//----------------------------------------------------------
// 下载所有的会议
-(BOOL)DownLoadMeetingData:(NSString*)MeetingId
{
    BOOL bRet = NO;
    @try {
        // 从网络获取数据
        _nMeetingLoadFlg = 1;
        NSString * Param = [NSString stringWithFormat:@"<root><function>DownloadPortalWorkPlan</function><params><param>%@</param></params></root>", MeetingId];
        //加密处理
        NSString *encryptParam = [NSString stringWithFormat:@"<![CDATA[%@]]>", [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY]];
        
        [self CallCommonGeoverService:encryptParam action:@selector(DownloadPortalWorkPlanHandler:)];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        bRet = NO;
    }
    @finally {
        return bRet;
    }
}
#pragma mark -  接收会议数据处理
//-------------------------------------------------------
// 接收会议数据
- (void) DownloadPortalWorkPlanHandler: (id) value {
    [UIApplication showNetworkActivityIndicator:NO];
	// Handle errors
	if([value isKindOfClass:[NSError class]]) {
        //NSLog(@"%@", value);
        _nMeetingLoadFlg = 0;
        [MeetingDelegate MeetingViewReload];
        [_delegate MeetingPopoverViewDisAppear];
        NSError *error = (NSError *)value;
        NSString *string = [error localizedDescription];
        [self CreateFailedAlertViewWithFailedInfo:@"会议数据下载错误" andWithMessage:string];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		//NSLog(@"%@", value);
        _nMeetingLoadFlg = 0;
        [_delegate MeetingPopoverViewDisAppear];
        SoapFault *soapFault = (SoapFault *)value;
        NSString *string = [soapFault description];
        [self CreateFailedAlertViewWithFailedInfo:@"会议数据服务器无响应" andWithMessage:string];
		return;
	}				
    
    NSDictionary *dicData = (NSDictionary*)value;
    NSString *str = [dicData objectForKey:@"return"];
    NSString *plainStr = [EncryptUtil decryptUseDES:str key:ENCRYPT_KEY];
    NSData *XmlData = [plainStr dataUsingEncoding:NSUTF8StringEncoding];
    [self ParseAllMeetingData:XmlData];
}

//----------------------------------------------------------
-(void)parsedMeetingShowConf:(NSData *)data
{
    @try {
        DDXMLDocument *_LayerDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
        //解析MeetingShowConf
        NSArray *WebServerUrlArray = [_LayerDocument nodesForXPath:@"//XML" error:nil];
        for (DDXMLElement *obj in WebServerUrlArray)
        {
            // 会议配置
            DDXMLElement *MeetingShowConf = [obj elementForName:@"MeetingShowConf"];
            if (MeetingShowConf) {
                _meetingShowConf = [MeetingShowConf.stringValue copy];
            }
            
            // 分局名称配置
            DDXMLElement *DepartmentNameConf = [obj elementForName:@"DepartmentNameConf"];
            if (DepartmentNameConf) {
                _departmentNameConf = [DepartmentNameConf.stringValue copy];
            }
        }
        [_LayerDocument release];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
}

#pragma mark 解决是否显示历史会议配置按钮
-(void)parasedHistoryMeetingBtnShowConf:(NSData*)data
{
    @try {
        DDXMLDocument *_LayerDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
        //解析MeetingShowConf
        NSArray *WebServerUrlArray = [_LayerDocument nodesForXPath:@"//XML" error:nil];
        for (DDXMLElement *obj in WebServerUrlArray) {
            DDXMLElement *MeetingShowConf = [obj elementForName:@"HistoryMeetingBtnShowConf"];
            if (MeetingShowConf) {
                _HistoryMeetingBtnShowConf = [MeetingShowConf.stringValue copy];
            }
            
        }
        [_LayerDocument release];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return;
}
// 解析所有会议数据
#pragma mark bs端保证只有一个当前会议    add by niurg 2015.9
-(BOOL)ParseAllMeetingData:(NSData*)ResXmlData
{
    BOOL bRet = NO;
    DDXMLDocument *doc = nil;
    @try {
        if (ResXmlData == nil) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"SubjectMenuData" ofType:@"xml"];
            NSData *data = [[NSData alloc] initWithContentsOfFile:path];
            doc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
            [data release];
        }
        else {
            doc = [[DDXMLDocument alloc] initWithData:ResXmlData options:0 error:nil];
        }

        NSArray *meeting = [doc nodesForXPath:@"//WorkPlan/WorkPlanJSONArray/WorkPlanObject" error:nil];
       //DBLocalTileDataManager *Meeting = [DBLocalTileDataManager instance];
        
        //NSMutableArray *meetingArray = [NSMutableArray arrayWithCapacity:0];
        for (DDXMLElement *obj in meeting) 
        {
            if ([self.meetingShowConf isEqualToString:@"1"]) {
                // 0:显示所有会议     1:只显示当前会议
                DDXMLElement *eleVal1 = [obj elementForName:@"ISHISTORY"];
                NSString *history = eleVal1.stringValue;
                if ([history isEqualToString:@"历史会议"]) {
                    // 当前会议为历史会议，则不显示
                    continue;
                }
            }

            
            DBMeetingDataItem *ProjectDataItem = [[DBMeetingDataItem alloc] init];
            // 会议ID
            DDXMLElement *eleVal = [obj elementForName:@"ID"];
            ProjectDataItem.Id = eleVal.stringValue;
            
            // 会议名称
            eleVal = [obj elementForName:@"THEME"];
            ProjectDataItem.MeetingName = eleVal.stringValue;
            
            // 开始时间
            eleVal = [obj elementForName:@"START_TIME"];
            ProjectDataItem.StartTime = eleVal.stringValue;
            
            // 结束时间
            eleVal = [obj elementForName:@"END_TIME"];
            ProjectDataItem.EndTime = eleVal.stringValue;
            
            // 地址
            eleVal = [obj elementForName:@"LOCATION"];
            ProjectDataItem.Address = eleVal.stringValue;
            
            // 类型
            eleVal = [obj elementForName:@"TYPE"];
            ProjectDataItem.Type = eleVal.stringValue;
            
            /*
            NSArray *subjectItem = [obj elementsForName:@"SubjectList"];
            NSMutableArray *subjectArray = [NSMutableArray arrayWithCapacity:0];
            for (DDXMLElement *obj in subjectItem) 
            {
                NSArray *array = [obj elementsForName:@"Subject"];
                for (DDXMLElement *subjectData in array) 
                {
                    DBSubProjectDataItem *SubProjectDataItem = [[DBSubProjectDataItem alloc] init];
                    DDXMLElement *subjectName = [subjectData elementForName:@"SubjectName"];
                    SubProjectDataItem.Name = subjectName.stringValue;
                    DDXMLElement *subjectOwner = [subjectData elementForName:@"SubjectOwnerUnit"];
                    SubProjectDataItem.OwnerUnit = subjectOwner.stringValue;
                    [subjectArray addObject:SubProjectDataItem];
                }
            }
            ProjectDataItem.SubProjectList = subjectArray;
            */
            
            [_MeetingList addObject:ProjectDataItem];
            [ProjectDataItem release];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        bRet = NO;
    }
    @finally {
        [doc release];
        _nMeetingLoadFlg = 0;
        [_delegate ResizeMeetingPopoverViewSize];
        [MeetingDelegate MeetingViewReload];
        return bRet;
    }
}


-(BOOL)IsHasValue:(DDXMLDocument *)doc
{
    BOOL bRet = NO;
    @try {
        
        NSArray *StatusArr = [doc nodesForXPath:@"//result/status" error:nil];
        if ([StatusArr count] > 0) {
            DDXMLElement *statusVal = [StatusArr objectAtIndex:0];
            NSString *Status = [statusVal stringValue];
            
            NSArray *responseText = [doc nodesForXPath:@"//result/response" error:nil];
            DDXMLElement *responseVal = [responseText objectAtIndex:0];
            
            NSString *ResText = [responseVal stringValue];
            NSString *logMsg = [NSString stringWithFormat:@"Status:%@ \n Response:%@", Status, ResText];
            const char *logMsgC = [logMsg cStringUsingEncoding:NSUTF8StringEncoding];
            if ([ResText length] > 0) {
                [self CreateFailedAlertViewWithFailedInfo:ResText andWithMessage:nil];
            }
            
            [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:nil textInf:logMsgC];
            bRet = NO;
        }
        else {
            bRet = YES;
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        bRet = NO;
    }
    @finally {
        return bRet;
    }
}

#pragma mark -  解析所有议题数据处理
//----------------------------------------------------------
// 解析所有议题数据
-(BOOL)ParseAllTopicData:(NSData*)ResXmlData ConventionId:(NSString*)ConvenId
{
    BOOL bRet = NO;
    DDXMLDocument *doc = nil;
    @try {
        if (ResXmlData == nil) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"TopicsData" ofType:@"xml"];
            NSData *data = [[NSData alloc] initWithContentsOfFile:path];
            doc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
            [data release];
        }
        else {
            doc = [[DDXMLDocument alloc] initWithData:ResXmlData options:0 error:nil];
        }
        BOOL bRet = [self IsHasValue:doc];
        if (!bRet) {
            return YES;
        }
        
        NSArray *topicArr = [doc nodesForXPath:@"//Topics/TopicsJSONArray/TopicsObject" error:nil];
        NSMutableDictionary *TopicItems = [NSMutableDictionary dictionaryWithCapacity:0];
        NSString *TopicID = nil;
        NSMutableArray *TopicIdArr = [NSMutableArray arrayWithCapacity:3];
        int nIndex = 0;
        for (DDXMLElement *obj in topicArr) 
        {
            nIndex++;
            DBSubProjectDataItem *DBSubProjectData = [[DBSubProjectDataItem alloc] init];
            // 议题ID
            DDXMLElement *eleVal = [obj elementForName:@"ID"];
            DBSubProjectData.Id = eleVal.stringValue;
            TopicID = [eleVal.stringValue copy];
            [TopicIdArr addObject:[TopicID copy]];
            // 名称
            eleVal = [obj elementForName:@"APPLICANT"];
//            NSString *newName = [NSString stringWithFormat:@"%d.%@", nIndex, eleVal.stringValue];
//            DBSubProjectData.TopicName = newName;
            DBSubProjectData.TopicName = eleVal.stringValue;
            
            // 所属单位
            eleVal = [obj elementForName:@"SectionName"];
            DBSubProjectData.SectionName = eleVal.stringValue;
            
            // 领导人意见
            eleVal = [obj elementForName:@"Result"];
            DBSubProjectData.Result = eleVal.stringValue;
            if ([DBSubProjectData.Result length] > 0) {
                //NSLog(@"\n-----------Result");
            }
            
            // 基本情况
            eleVal = [obj elementForName:@"Reason"];
            DBSubProjectData.Reason = eleVal.stringValue;
            if ([DBSubProjectData.Reason length] > 0) {
                //NSLog(@"\n-----------Reason");
            }
            
            // 类型
            eleVal = [obj elementForName:@"TYPE"];
            DBSubProjectData.Type = eleVal.stringValue;
            
            // 其下所有地块
            DDXMLElement *TopicDK = [obj elementForName:@"TopicDK"];
            NSString *strValue = TopicDK.stringValue;
            if ([strValue length] > 0) {
                NSMutableArray *DKDataArr = [NSMutableArray arrayWithCapacity:3];
                NSArray *topicDKArr = [TopicDK children];
                for (DDXMLElement *Dkobj in topicDKArr) 
                {
                    DBTopicDKDataItem *DBTopicDKData = [[DBTopicDKDataItem alloc] init];
                    // 
                    DDXMLElement *eleVal2 = [Dkobj elementForName:@"DKBH"];
                    DBTopicDKData.DKBH = eleVal2.stringValue;
                    
                    // 
                    eleVal2 = [Dkobj elementForName:@"DKBSM"];
                    DBTopicDKData.DKBsm = eleVal2.stringValue;
                    
                    // 
                    eleVal2 = [Dkobj elementForName:@"DKBZXX"];
                    DBTopicDKData.DKBZXX = eleVal2.stringValue;
                    
                    // 
                    eleVal2 = [Dkobj elementForName:@"DKLX"];
                    DBTopicDKData.DKLX = eleVal2.stringValue;
                    
                    // 
                    eleVal2 = [Dkobj elementForName:@"ID"];
                    DBTopicDKData.Id = eleVal2.stringValue;
                    
                    // 
                    eleVal2 = [Dkobj elementForName:@"TopicID"];
                    DBTopicDKData.TopicID = eleVal2.stringValue;
                    [DKDataArr addObject:DBTopicDKData];
                    [DBTopicDKData release];
                }
                [[self TopicsDKDataDic] setValue:DKDataArr forKey:TopicID];
            }
            
            // 会议ID
            eleVal = [obj elementForName:@"ConventionID"];
            DBSubProjectData.OwnerMeetringID = eleVal.stringValue;
            
            
            if (eleVal.stringValue == nil) {
                DBSubProjectData.OwnerMeetringID = ConvenId;
            }
            if (DBSubProjectData.OwnerMeetringID == nil) {
                [DBSubProjectData release];
                continue;
            }
            [TopicItems setValue:DBSubProjectData forKey:DBSubProjectData.Id];
            [DBSubProjectData release];
        }
        if ((TopicItems != nil) && ([TopicItems count] > 0)) {
            [_TopicsOfMeeting setValue:TopicItems forKey:ConvenId];
            [_MeettingToTopicIDSeqDic setValue:TopicIdArr forKey:ConvenId];
        }
        
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [doc release];
        return bRet;
    }
}

//----------------------------------------------------------
//下载指定议题的基本情况数据
- (void)DownLoadTopicReasonData:(NSString*)TopicID
{
    @try {
        NSString * Param = [NSString stringWithFormat:@"<root><function>DownloadPortalTopics</function><params><param>%@</param></params></root>",TopicID];
        //加密处理
        NSString *encryptParam = [NSString stringWithFormat:@"<![CDATA[%@]]>", [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY]];
        
        [self CallCommonGeoverService:encryptParam action:@selector(DownLoadTopicReasonDataHandle:)];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }
}
//-------------------------------------------------------
// 接收议题的基本情况数据
- (void)DownLoadTopicReasonDataHandle:(id)value
{
    @try {
        //
        [UIApplication showNetworkActivityIndicator:NO];
        // Handle errors
        if([value isKindOfClass:[NSError class]]) {
            //NSLog(@"%@", value);
            NSError *error = (NSError *)value;
            NSString *string = [error localizedDescription];
            [self CreateFailedAlertViewWithFailedInfo:@"议题基本情况数据下载错误" andWithMessage:string];
            return;
        }
        
        // Handle faults
        if([value isKindOfClass:[SoapFault class]]) {
            //NSLog(@"%@", value);
            SoapFault *soapFault = (SoapFault *)value;
            NSString *string = [soapFault description];
            [self CreateFailedAlertViewWithFailedInfo:@"议题基本情况数据下载失败" andWithMessage:string];
            return;
        }				
        
        NSDictionary *dicData = (NSDictionary*)value;
        NSString *str = [dicData objectForKey:@"return"];
        NSString *plainStr = [EncryptUtil decryptUseDES:str key:ENCRYPT_KEY];
        NSData *XmlData = [plainStr dataUsingEncoding:NSUTF8StringEncoding];
        [self ParseTopicReasonData:XmlData];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }
}
//----------------------------------------------------------
// 解析议题所有数据
-(BOOL)ParseTopicReasonData:(NSData*)ResXmlData
{
    BOOL bRet = NO;
    DDXMLDocument *doc = nil;
    @try {
        if (ResXmlData == nil) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"TopicsData" ofType:@"xml"];
            NSData *data = [[NSData alloc] initWithContentsOfFile:path];
            doc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
            [data release];
        }
        else {
            doc = [[DDXMLDocument alloc] initWithData:ResXmlData options:0 error:nil];
        }
        BOOL bRet = [self IsHasValue:doc];
        if (!bRet) {
            return YES;
        }
        
        //DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        // 解析详细数据
        NSArray *topicArr = [doc nodesForXPath:@"//TopicsDetail/TopicsTopJSON/TopicsTopObject/TopicsObject" error:nil];
        NSString *TopicIdValue = nil;
        DBSubProjectDataItem *DBSubProjectData = [[DBSubProjectDataItem alloc] init];
        for (DDXMLElement *obj in topicArr) 
        {
            // ID
            DDXMLElement *eleVal = [obj elementForName:@"ID"];
            NSString *Id = eleVal.stringValue;
            TopicIdValue = Id;
            DBSubProjectData.Id = eleVal.stringValue;
            
            // 名称
            eleVal = [obj elementForName:@"APPLICANT"];
//            NSString *newName = [NSString stringWithFormat:@"%d.%@", nIndex, eleVal.stringValue];
//            DBSubProjectData.TopicName = newName;
            DBSubProjectData.TopicName = eleVal.stringValue;
            
            // 领导人意见
            eleVal = [obj elementForName:@"Result"];
            DBSubProjectData.Result = eleVal.stringValue;
            if ([DBSubProjectData.Result length] > 0) {
                //NSLog(@"\n-----------Result");
            }
            // 类型
            eleVal = [obj elementForName:@"TYPE"];
            DBSubProjectData.Type = eleVal.stringValue;
            
            // 会议ID
            eleVal = [obj elementForName:@"ConventionID"];
            DBSubProjectData.OwnerMeetringID = eleVal.stringValue;
            
            // 基本情况
            eleVal = [obj elementForName:@"Reason"];
            NSString *Reason = eleVal.stringValue;
            // 存储到缓存
            [_TopicsReason setValue:Reason forKey:Id];
        }
        //把TopicsOfMeeting字典里的DBSubProject替换成最新的数据。
        NSMutableDictionary *TopicDic = [self.TopicsOfMeeting objectForKey:DBSubProjectData.OwnerMeetringID];
        DBSubProjectData.SectionName = [[[self.TopicsOfMeeting objectForKey:DBSubProjectData.OwnerMeetringID] objectForKey:DBSubProjectData.Id] SectionName];
        [TopicDic setValue:DBSubProjectData forKey:DBSubProjectData.Id];
        [DBSubProjectData release];
        
        // 解析附件数据
        NSArray *topicAnnexArr = [doc nodesForXPath:@"//TopicsDetail/TopicsTopJSON/TopicAnnex/TopicAnnexObject" error:nil];
        NSMutableArray *AnnexArr = [[NSMutableArray alloc] initWithCapacity:2];
        for (DDXMLElement *obj in topicAnnexArr) 
        {
            DBTopicAnnexDataItem *DBTopicAnnexData = [[DBTopicAnnexDataItem alloc] init];
            // ID
            DDXMLElement *eleVal = [obj elementForName:@"ID"];
            NSString *Id = eleVal.stringValue;
            [DBTopicAnnexData setId:Id];
            
            // address
            eleVal = [obj elementForName:@"address"];
            NSString *address = eleVal.stringValue;
            [DBTopicAnnexData setAddress:address];
            
            // name
            eleVal = [obj elementForName:@"name"];
            NSString *name = eleVal.stringValue;
            [DBTopicAnnexData setName:name];
            
            [AnnexArr addObject:DBTopicAnnexData];
            [DBTopicAnnexData release];
        }
        // 存储到缓存
        [_TopicsAnnexDic setValue:AnnexArr forKey:TopicIdValue];
        [AnnexArr release];
        
        [_TopicDKDataQueryDelegate TopicReasonDidQuery:TopicIdValue];
        
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [doc release];
        return bRet;
    }
}

#pragma mark 指定议题的地块数据下载相关处理
//-------------------------------------------------------
// 下载指定议题的地块数据
- (void)DownLoadTopicLandData:(NSString*)TopicID MeetingId:(NSString*)MeetingID
{
    @try {
        [_TopicDKDownloadMeetingIDQueue enqueue:MeetingID];
        
        NSString * Param = [NSString stringWithFormat:@"<root><function>DownloadDKBSMofTopic</function><params><param>%@</param></params></root>", TopicID];
        NSString *encryptParam = [NSString stringWithFormat:@"<![CDATA[%@]]>", [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY]];
        
        [self CallCommonGeoverService:encryptParam action:@selector(DownLoadTopicLandDataHandle:)];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }
}

//-------------------------------------------------------
// 接收议题的地块数据
- (void)DownLoadTopicLandDataHandle:(id)value
{
    @try {
        //
        [UIApplication showNetworkActivityIndicator:NO];
        
        // Handle errors
        if([value isKindOfClass:[NSError class]]) {
            //NSLog(@"%@", value);
            NSError *error = (NSError *)value;
            NSString *string = [error localizedDescription];
            [self CreateFailedAlertViewWithFailedInfo:@"议题地块数据下载错误" andWithMessage:string];
            
            return;
        }
        
        // Handle faults
        if([value isKindOfClass:[SoapFault class]]) {
            //NSLog(@"%@", value);
            SoapFault *soapFault = (SoapFault *)value;
            NSString *string = [soapFault description];
            [self CreateFailedAlertViewWithFailedInfo:@"议题地块数据下载失败" andWithMessage:string];
            return;
        }				
        //[TopicDKReloadDelegate TopicDKDownloadCompleted:@"开始解析地块更新数据..."];
        NSString *MeetingID = [_TopicDKDownloadMeetingIDQueue dequeue];
        NSDictionary *dicData = (NSDictionary*)value;
        NSString *str = [dicData objectForKey:@"return"];
        NSString *plainStr = [EncryptUtil decryptUseDES:str key:ENCRYPT_KEY];
        NSData *XmlData = [plainStr dataUsingEncoding:NSUTF8StringEncoding];
        [self ParseTopicLandData:XmlData MeetingId:MeetingID];
        

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }
}

//----------------------------------------------------------
// 解析议题地块数据
-(BOOL)ParseTopicLandData:(NSData*)ResXmlData MeetingId:(NSString*)MeetingID
{
    BOOL bRet = NO;
    DDXMLDocument *doc = nil;
    @try { 
        if (ResXmlData == nil) {
            NSString *path = [[NSBundle mainBundle] pathForResource:@"TopicsLandData" ofType:@"xml"];
            NSData *data = [[NSData alloc] initWithContentsOfFile:path];
            doc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
            [data release];
        }
        else {
            doc = [[DDXMLDocument alloc] initWithData:ResXmlData options:0 error:nil];
        }
        BOOL bRet = [self IsHasValue:doc];
        if (!bRet) {
            return YES;
        }
        
        // 解析地块数据
        NSArray *topicArr = [doc nodesForXPath:@"//TopicDK/TopicDKJSONArray/TopicDKObject" error:nil];
        NSMutableArray *DKDataArr = [NSMutableArray arrayWithCapacity:3];
        NSMutableArray *BsmArr = [NSMutableArray arrayWithCapacity:3];
        NSString *TopicId = nil;
        for (DDXMLElement *obj in topicArr) 
        {
            DBTopicDKDataItem *DBTopicDKData = [[DBTopicDKDataItem alloc] init];
            // ID
            DDXMLElement *eleVal = [obj elementForName:@"ID"];
            NSString *strVal = eleVal.stringValue;
            [DBTopicDKData setId:strVal];
            
            // 议题ID
            eleVal = [obj elementForName:@"TopicID"];
            strVal = eleVal.stringValue;
            [DBTopicDKData setTopicID:strVal];
            TopicId = [strVal copy];
            
            // 地块编号
            eleVal = [obj elementForName:@"DKBH"];
            strVal = eleVal.stringValue;
            //strVal = @"测试";
            [DBTopicDKData setDKBH:strVal];
            
            // 
            eleVal = [obj elementForName:@"DKBZXX"];
            strVal = eleVal.stringValue;
            [DBTopicDKData setDKBZXX:strVal];
            
            // 地块标识码
            eleVal = [obj elementForName:@"DKBSM"];
            strVal = eleVal.stringValue;
            [DBTopicDKData setDKBsm:strVal];
            
            int nLen = [strVal length];
            if (nLen > 0) {
                [BsmArr addObject:strVal];
            }
            
            // 地块LX
            eleVal = [obj elementForName:@"DKLX"];
            strVal = eleVal.stringValue;
            [DBTopicDKData setDKLX:strVal];
            
            [DKDataArr addObject:DBTopicDKData];
            [DBTopicDKData release];
        }
        if ([DKDataArr count] > 0) {
            [_TopicsDKDataDic setValue:DKDataArr forKey:TopicId];
        }
        
        if ([BsmArr count] > 0 ) {
            /*
            // 更新缓存地块数据
            DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
            // 取得缓存中的议题数据
            DBSubProjectDataItem *DBSubProjectData = [[[DataMan TopicsOfMeeting] objectForKey:MeetingID] objectForKey:TopicId];
            if (DBSubProjectData == nil) {
                //
            }
            
            // 清除原来旧数据
            [[DBSubProjectData DKDataArr] removeAllObjects];
            // 添加新数据
            [[DBSubProjectData DKDataArr] addObjectsFromArray:DKDataArr];
            */
            
            // 开始下载地块数据
            [TopicDKReloadDelegate TopicDKDownloadCompleted:@"开始下载地块坐标数据..."];
            
            if ([BsmArr count] > 0) 
            {
                DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
                [DataMan DownLoadFeatureByBsm:BsmArr KeyWord:TopicId];
            }
        }

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [doc release];
        return bRet;
    }
}

#pragma mark 专题图层数据下载相关处理
//----------------------------------------------------------
//下载所有图层数据
- (void)DownLoadMapLayerData:(NSString*)ThemeID
{
    @try {
        [MapLayerDelegate DataMapLayerViewReload];
        _nMapLayerLoadFlg = 1;

        NSString * Param = [NSString stringWithFormat:@"<root><function>DownloadPortalThemeManage</function><params><param>%@</param></params></root>", CURRENT_MODULE_NAME];
        NSString *encryptParam = [NSString stringWithFormat:@"<![CDATA[%@]]>", [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY]];
        [self CallCommonGeoverService:encryptParam action:@selector(DownloadPortalThemeManageHandle:)];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }
}

//-------------------------------------------------------
// 接收图层数据
- (void)DownloadPortalThemeManageHandle:(id)value
{
    [UIApplication showNetworkActivityIndicator:NO];
    // Handle errors
	if([value isKindOfClass:[NSError class]]) {
        //NSLog(@"%@", value);
        _nMapLayerLoadFlg = 0;
        [MapLayerDelegate DataMapLayerViewReload];
        [_delegate MapLayerPopoverViewDisAppear];
        NSError *error = (NSError *)value;
        NSString *string = [error localizedDescription];
        [self CreateFailedAlertViewWithFailedInfo:@"业务图层数据下载错误" andWithMessage:string];
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		//NSLog(@"%@", value);
        _nMapLayerLoadFlg = 0;
        [_delegate MapLayerPopoverViewDisAppear];
        SoapFault *soapFault = (SoapFault *)value;
        NSString *string = [soapFault description];
        [self CreateFailedAlertViewWithFailedInfo:@"业务图层数据服务器无响应" andWithMessage:string];
		return;
	}				
    
    NSDictionary *dicData = (NSDictionary*)value;
    NSString *str = [dicData objectForKey:@"return"];
    NSString *plainStr = [EncryptUtil decryptUseDES:str key:ENCRYPT_KEY];
    NSData *XmlData = [plainStr dataUsingEncoding:NSUTF8StringEncoding];
    //把下载的数据写到沙盒里面。
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DBMapLayerData.xml"];
    [XmlData writeToFile:filePath atomically:NO];
    //解析数据
    [self ParseMapLayerData:XmlData];
}

//----------------------------------------------------------
// 解析图层数据

- (void)ParseMapLayerData:(NSData*)ResXmlData
{
    DDXMLDocument *doc = nil;
    @try {
        [MapLayerDataArray removeAllObjects];
        doc = [[DDXMLDocument alloc] initWithData:ResXmlData options:0 error:nil];
        //单独解析DataLayerSelected，用_nCurrentSelRadioBtnIndex来记录解析到的结果
        NSArray *JSONArray = [doc nodesForXPath:@"//ThemeManage/ThemeManageJSONArray" error:nil];
        //取出DDXMLElement，因为只有一项所以index为0.
        DDXMLElement *obj = [JSONArray objectAtIndex:0];
        DDXMLElement *eleVal = [obj elementForName:@"DataLayerSelected"];
        //更新_nCurrentSelRadioBtnIndex的值
        NSInteger index = eleVal.stringValue.intValue;
        if (eleVal != nil && index != -1) {
            _nCurrentSelRadioBtnIndex = index;
        }  
        
        //解析MapLayerData
        NSArray *MapLayer = [doc nodesForXPath:@"//ThemeManage/ThemeManageJSONArray/ThemeManageObject" error:nil];
        
        for (DDXMLElement *obj in MapLayer) 
        {
            // 图层名称
            DDXMLElement *eleVal = [obj elementForName:@"CHNNAME"];
            NSString *LayerName = eleVal.stringValue;
            //if ([LayerName isEqualToString:@"道路地名地址"])
            NSRange range = [LayerName rangeOfString:ROAD_MAPLAYER_NAME];
            if (range.location != NSNotFound )
            {
                //self.RoadDataMapLayerName = [LayerName copy];
                self.RoadDataMapLayerName = ROAD_MAPLAYER_NAME;
                // 图层网址
                eleVal = [obj elementForName:@"WEBURL"];
                self.RoadDataMapLayerUrl = [eleVal.stringValue copy];
                continue;
            }
            
            DBMapLayerDataItem *MapLayerDataItem = [[DBMapLayerDataItem alloc] init];
            // 图层ID
            eleVal = [obj elementForName:@"THEMEID"];
            MapLayerDataItem.Id = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"GROUPID"];
            MapLayerDataItem.GROUPID = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"ENNAME"];
            MapLayerDataItem.ENNAME = eleVal.stringValue;
            
            // 图层名称
            eleVal = [obj elementForName:@"CHNNAME"];
            MapLayerDataItem.Name = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"XMIN"];
            MapLayerDataItem.XMIN = eleVal.stringValue;
            
            //
            eleVal = [obj elementForName:@"XMAX"];
            MapLayerDataItem.XMAX = eleVal.stringValue;
            //--
            // 
            eleVal = [obj elementForName:@"YMIN"];
            MapLayerDataItem.YMIN = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"YMAX"];
            MapLayerDataItem.YMAX = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"WEBTYPE"];
            MapLayerDataItem.WEBTYPE = eleVal.stringValue;
            
            //
            eleVal = [obj elementForName:@"ISBASEMAP"];
            MapLayerDataItem.ISBASEMAP = eleVal.stringValue;

            // 图层网址
            eleVal = [obj elementForName:@"WEBURL"];
            MapLayerDataItem.MapUrl = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"DEPTNAME"];
            MapLayerDataItem.DEPTNAME = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"METAID"];
            MapLayerDataItem.METAID = eleVal.stringValue;
            
            // 
            eleVal = [obj elementForName:@"PICPATH"];
            MapLayerDataItem.PICPATH = eleVal.stringValue;
            
            //
            eleVal = [obj elementForName:@"MEMO"];
            MapLayerDataItem.MEMO = eleVal.stringValue; 
            
            //
            eleVal = [obj elementForName:@"DataLayerDisplay"];
            if (eleVal == nil) {
                MapLayerDataItem.DataLayerDisplay = [NSString stringWithFormat:@"%d", 0];
            }else {
                MapLayerDataItem.DataLayerDisplay = eleVal.stringValue;
            }
            
            [MapLayerDataArray addObject:MapLayerDataItem];
            [MapLayerDataItem release];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [doc release];
        _nMapLayerLoadFlg = 0;
        [_delegate ResizeMapLayerPopoverViewSize];
        [MapLayerDelegate DataMapLayerViewReload];
    }
}
/* 2012-09-16以前用代码
- (void)ParseMapLayerData:(NSData*)ResXmlData
{
    DDXMLDocument *doc = nil;
    @try {
        doc = [[DDXMLDocument alloc] initWithData:ResXmlData options:0 error:nil];
        NSArray *MapLayer = [doc nodesForXPath:@"//ThemeManage/ThemeManageJSONArray/ThemeManageObject" error:nil];
        
        for (DDXMLElement *obj in MapLayer) 
        {
            // 图层名称
            DDXMLElement *eleVal = [obj elementForName:@"CAPTION"];
            NSString *LayerName = eleVal.stringValue;
            if ([LayerName isEqualToString:@"道路图层"]) 
            {
                self.RoadDataMapLayerName = [LayerName copy];
                // 图层网址
                eleVal = [obj elementForName:@"URL"];
                self.RoadDataMapLayerUrl = [eleVal.stringValue copy];
                continue;
            }
            
            DBMapLayerDataItem *MapLayerDataItem = [[DBMapLayerDataItem alloc] init];
            // 图层ID
            eleVal = [obj elementForName:@"ID"];
            MapLayerDataItem.Id = eleVal.stringValue;
            
            // 图层网址
            eleVal = [obj elementForName:@"URL"];
            MapLayerDataItem.MapUrl = eleVal.stringValue;
            
            // 图层名称
            eleVal = [obj elementForName:@"NAME"];
            MapLayerDataItem.Name = eleVal.stringValue;
            
            // 图层类型
            eleVal = [obj elementForName:@"TYPE"];
            MapLayerDataItem.Type = eleVal.stringValue;
            
            //Caption
            eleVal = [obj elementForName:@"CAPTION"];
            MapLayerDataItem.Caption = eleVal.stringValue;
            
            //DataLayerDisplay
            eleVal = [obj elementForName:@"DataLayerDisplay"];
            if (eleVal == nil) {
                MapLayerDataItem.DataLayerDisplay = [NSString stringWithFormat:@"%d", 0];
            }else {
                MapLayerDataItem.DataLayerDisplay = eleVal.stringValue;
            }
            [MapLayerDataArray addObject:MapLayerDataItem];
            [MapLayerDataItem release];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [doc release];
        _nMapLayerLoadFlg = 0;
        [_delegate ResizeMapLayerPopoverViewSize];
        [MapLayerDelegate DataMapLayerViewReload];
    }
}
*/
#pragma mark 根据BSM下载地块数据相关处理
//----------------------------------------------------------
// 根据区域查询相关地块地籍权属属性
-(BOOL)QuaryRelationLandByGeometry:(AGSGeometry*)Geomery
{
     DBSeLayerPort* service = [DBSeLayerPort service];
     service.logging = YES;
     //构建查询对象
     DBqueryObject *queryObj = [[DBqueryObject alloc] init];
     //查询图层名为地籍宗地
     [queryObj setTableName:@"GISDJZD"];
     
     //是否返回图形坐标
     [queryObj setReturnShape:YES];
     
     [queryObj setBeginRecord:0];
     //返回最大记录数
     [queryObj setLimitRecord:100];
     
     DBwebGeometry *Geo = [[DBwebGeometry alloc] init];
    if ([Geomery isKindOfClass:[AGSPolygon class]])
    {
        [Geo setType:@"esriGeometryPolygon"];
    }
    else if ([Geomery isKindOfClass:[AGSPolyline class]])
    {
        [Geo setType:@"esriGeometryPolyline"];
    }
    else if ([Geomery isKindOfClass:[AGSPoint class]])
    {
        [Geo setType:@"esriGeometryPoint"];
    }
    else if ([Geomery isKindOfClass:[AGSEnvelope class]])
    {
        [Geo setType:@"esriGeometryEnvelope"];
    }
    
    else{
        return NO;
    }
     
     NSDictionary *GeoDic = [Geomery encodeToJSON];
     
     NSData *GeoData = [NSJSONSerialization dataWithJSONObject:GeoDic options:NSJSONWritingPrettyPrinted error:nil];
     NSString *GeoJson2 = [[NSString alloc] initWithData:GeoData encoding:NSUTF8StringEncoding];
     NSString *GeoJson3 = [NSString stringWithFormat:@"<![CDATA[%@]]>", GeoJson2];
     
     [Geo setContent:GeoJson3];
     [queryObj setSpatialFeature:Geo];

     // 异步调用
     [UIApplication showNetworkActivityIndicator:YES];
     SoapRequest *req = [service getFeature:self action:@selector(QuaryRelationLandByGeometryHandler:) arg0: queryObj];
     [req setLogging:YES];
     [queryObj release];
     return YES;
}
// 接收数据
- (void) QuaryRelationLandByGeometryHandler: (id) value {
    BOOL bErrFlg = NO;
    @try {
        [UIApplication showNetworkActivityIndicator:NO];
        // Handle errors
        if([value isKindOfClass:[NSError class]]) {
            //NSLog(@"%@", value);
            NSError *error = (NSError *)value;
            NSString *string = [error localizedDescription];
            [self CreateFailedAlertViewWithFailedInfo:@"地块坐标数据下载错误" andWithMessage:string];
            bErrFlg = YES;
            return;
        }
        
        // Handle faults
        if([value isKindOfClass:[SoapFault class]]) {
            //NSLog(@"%@", value);
            SoapFault *soapFault = (SoapFault *)value;
            NSString *string = [soapFault description];
            NSRange range = [string rangeOfString:@"SPECIFIED LAYER DOES NOT EXIST"];
            if (range.location != NSNotFound )
            {
                [self CreateFailedAlertViewWithFailedInfo:@"地块数据下载失败" andWithMessage:@"指定的层不存在"];
            }
            else {
                [self CreateFailedAlertViewWithFailedInfo:@"地块数据下载失败" andWithMessage:@""];
            }
            bErrFlg = YES;
            return;
        }
        
        // Do something with the DBqueryResponse* result
        DBqueryResponse* result = (DBqueryResponse*)value;
        NSDictionary *dicRes = (NSDictionary*)result;
        //NSLog(@"getFeature returned the value: %@", result);
        
        NSDictionary *returnDic = [dicRes objectForKey:@"return"];
        NSDictionary *featuresetMap = [returnDic objectForKey:@"featuresetMap"];
        NSDictionary *entry = [featuresetMap objectForKey:@"entry"];
        NSDictionary *valueDic = [entry objectForKey:@"value"];
        NSInteger count = valueDic.count;
        if (count <= 3) {
            // 没有地块数据
            return;
        }
        
        NSMutableDictionary *DKBSM2DataDic = [NSMutableDictionary dictionaryWithCapacity:3];
        NSMutableArray *GeometryArray = [NSMutableArray arrayWithCapacity:3];
        for (int i = 0; i < count - 4; i++)
        {
            // 地块数据体
            NSString *Bsm = nil;
            NSMutableDictionary *DKDJInfoDic = [NSMutableDictionary dictionaryWithCapacity:10];
            NSString *POIKey = [NSString stringWithFormat:@"NodeName%d", i];
            NSDictionary *DKFeatureValue = [valueDic objectForKey:POIKey];
            NSDictionary *fieldsDic = [DKFeatureValue objectForKey:@"fields"];
            
            // 解析第n个属性field
            for (int i = 0; i < fieldsDic.count - 1; i++)
            {
                NSString *Nodekey = [NSString stringWithFormat:@"NodeName%d", i];
                NSDictionary *NodeValue = [fieldsDic objectForKey:Nodekey];
                NSString *RetBsm = [self ParseDJAllField:NodeValue DKDJInfoDic:DKDJInfoDic];
                if (RetBsm != nil) {
                    Bsm = [RetBsm copy];
                }
            }
            
            // 解析第1个属性field
            NSDictionary *FieldValue = [fieldsDic objectForKey:@"field"];
            NSString *RetBsm = [self ParseDJAllField:FieldValue DKDJInfoDic:DKDJInfoDic];
            if (RetBsm != nil) {
                Bsm = [RetBsm copy];
            }
            
            NSDictionary *geometry =[DKFeatureValue objectForKey:@"geometry"];
            NSString *area = [geometry objectForKey:@"area"];
            [DKDJInfoDic setObject:area == nil ? @"" : area forKey:@"ZDMJ"];

            
            // 解析地块坐标数据
            AGSGeometry * geoData = [self ParaseDKGeoData:DKFeatureValue GeoType:2];
            [DKDJInfoDic setObject:geoData forKey:@"Geometry"];
            [GeometryArray addObject:geoData];
            if ([DKDJInfoDic count] > 0) {
                if ([Bsm length] > 0) {
                    [DKBSM2DataDic setValue:DKDJInfoDic forKey:Bsm];
                }
            }
        }
        
        // 解析第一个地块数据
        NSString *Bsm = nil;
        NSDictionary *DKFeatureValue = [valueDic objectForKey:@"features"];
        NSMutableDictionary *DKDJInfoDic2 = [NSMutableDictionary dictionaryWithCapacity:10];
        NSDictionary *fieldsDic = [DKFeatureValue objectForKey:@"fields"];
        for (int i = 0; i < fieldsDic.count - 1; i++)
        {
            NSString *NodeKey = [NSString stringWithFormat:@"NodeName%d", i];
            NSDictionary *NodeValue = [fieldsDic objectForKey:NodeKey];
            NSString *RetBsm = [self ParseDJAllField:NodeValue DKDJInfoDic:DKDJInfoDic2];
            if (RetBsm != nil) {
                Bsm = [RetBsm copy];
            }
            
        }
        NSDictionary *FieldValue = [fieldsDic objectForKey:@"field"];
        NSString *RetBsm = [self ParseDJAllField:FieldValue DKDJInfoDic:DKDJInfoDic2];
        if (RetBsm != nil) {
            Bsm = [RetBsm copy];
        }
        
        NSDictionary *geometry =[DKFeatureValue objectForKey:@"geometry"];
        NSString *area = [geometry objectForKey:@"area"];
        [DKDJInfoDic2 setObject:area == nil ? @"" : area forKey:@"ZDMJ"];
        
        // 解析几何图形坐标数据
        AGSGeometry * geoData = [self ParaseDKGeoData:DKFeatureValue GeoType:2];
        [DKDJInfoDic2 setObject:geoData forKey:@"Geometry"];
        [GeometryArray addObject:geoData];
        // 追加到地块Arr里
        if ([DKDJInfoDic2 count] > 0) {
            if([Bsm length] > 0) {
                [DKBSM2DataDic setValue:DKDJInfoDic2 forKey:Bsm];
            }
        }
        // 显示数据表格
        if ([self.DBDKInfoQueryDeg respondsToSelector:@selector(DKInfoQueryFinish:Geometrys:)]) {
            [self.DBDKInfoQueryDeg DKInfoQueryFinish:DKBSM2DataDic Geometrys:GeometryArray];
        }
        
        // 绘制地块
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        bErrFlg = YES;
    }
    @finally {
        if (bErrFlg) {
            [self.DBDKInfoQueryDeg DKInfoQueryError:@"查询失败"];
        }
        return;
    }
}


//----------------------------------------------------------
// 根据BSM查询下载地块数据
// 返回最多地块为100块
-(BOOL)DownLoadFeatureByBsm:(NSArray *)Bsms KeyWord:(NSString*)TopicId
{
    DBSeLayerPort* service = [DBSeLayerPort service];
	service.logging = YES;
    //构建查询对象
    DBqueryObject *queryObj = [[DBqueryObject alloc] init];
    //查询图层名
    //[queryObj setTableName:@"GISJHS1_T_114"];
    [queryObj setTableName:@"GISJHS1_T_114"];
    
    //
//    DBfield *field = [[DBfield alloc] init];
//    [field setName:@"BH"];  // 编号
//    [[queryObj fields] removeAllObjects];
//    [[queryObj fields] addObject:field];
//    [field release];
    
//    field = [[DBfield alloc] init];
//    [field setName:@"DKBH"];
//    [[queryObj fields] addObject:field];
//    [field release];
    
    //讨论事项
    DBfield *field = [[DBfield alloc] init];
    [field setName:@"TLSX"];
    [[queryObj fields] addObject:field];
    [field release];
    
//    field = [[DBfield alloc] init];
//    [field setName:@"DK"];
//    [[queryObj fields] addObject:field];
//    [field release];
    
    field = [[DBfield alloc] init];
    [field setName:@"BSM"];
    [[queryObj fields] addObject:field];
    [field release];
    
    //要素代码
    field = [[DBfield alloc] init];
    [field setName:@"YSDM"];
    [[queryObj fields] addObject:field];
    [field release];
    
    field = [[DBfield alloc] init];
    [field setName:@"TOPIC"];
    [[queryObj fields] addObject:field];
    [field release];
    
    field = [[DBfield alloc] init];
    [field setName:@"NOTES"];
    [[queryObj fields] addObject:field];
    [field release];
    
    // 申请单位
    field = [[DBfield alloc] init];
    [field setName:@"APPLICANT"];
    [[queryObj fields] addObject:field];
    [field release];

    //查询条件
    NSMutableString* QueryWord = [NSMutableString string];
    [QueryWord appendString: @"where BSM = '"];
    int nCnt = 0;
    for (NSString *Bsm in Bsms) {
        if (nCnt++ == 0) {
            [QueryWord appendString:Bsm];
            [QueryWord appendString:@"'"];
        }
        else {
            [QueryWord appendFormat:@" or BSM = '%@'", Bsm];
        }
    }
    [queryObj setWhereCaluse:QueryWord];
    //是否返回图形坐标
    [queryObj setReturnShape:YES];
    
    [queryObj setBeginRecord:0];
    //返回最大记录数
    [queryObj setLimitRecord:100];
    
    //[queryObj setOutSR:2383];
    
    // 异步调用
    [UIApplication showNetworkActivityIndicator:YES];
    SoapRequest *req = [service getFeature:self action:@selector(getDKFeatureByBsmHandler:) arg0: queryObj];
    [_TopicIdQueue enqueue:TopicId];
    [req setLogging:YES];
    [queryObj release];
    return YES;
}

// 解析地籍属性
-(NSString*)ParseDJAllField:(NSDictionary *)NodeValue DKDJInfoDic:(NSMutableDictionary*)DJInfoDic
{
    @try {
        NSString *BSM = nil;
        NSString *FieldName = [NodeValue objectForKey:@"name"];
        NSString *val = [NodeValue objectForKey:@"value"];
        //判断取出来的数据是否为NSNull类型
        if ([val isKindOfClass:[NSNull class]]) {
            val = @"";
        }
        [DJInfoDic setObject:val forKey:FieldName];
        if([FieldName isEqualToString:@"BSM"])
        {
            //
            [DJInfoDic setObject:val forKey:@"BSM"];
            BSM = [val copy];
        }
        return BSM;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return nil;
    }
    @finally {
    }
}
//----------------------------------------------------------
// 解析各个属性字段
-(NSString*)ParseAllField:(NSDictionary *)NodeValue TopicDKDataItem:(DBTopicDKDataItem*)TopicDKData
{
    @try {
        NSString *BSM = nil;
        NSString *FieldName = [NodeValue objectForKey:@"name"];
        NSString *val = [NodeValue objectForKey:@"value"];
        //判断取出来的数据是否为NSNull类型
        if ([val isKindOfClass:[NSNull class]]) {
            val = @"";
        }        
        else if([FieldName isEqualToString:@"TLSX"])
        {
            //讨论事项
            TopicDKData.DisscuseAffair = val;
        }
        else if([FieldName isEqualToString:@"BSM"])
        {
            // 
            TopicDKData.DKBsm = val;
            BSM = [val copy];
        }
        else if([FieldName isEqualToString:@"TOPIC"])
        {
            // 议题ID
            //TopicDKData.TopicID = val;
        }
        else if([FieldName isEqualToString:@"NOTES"])
        {
            // 备注
            TopicDKData.Notes = val;
        }
        else if([FieldName isEqualToString:@"APPLICANT"])
        {
            // 申请单位
            TopicDKData.DKApplicant = val;
        }

        return BSM;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return nil;
    }
    @finally {
    }
}

//----------------------------------------------------------
// 解析地块坐标数据
// nType -- 0:点    1：线    2：面
-(AGSGeometry*)ParaseDKGeoData:(NSDictionary *)DKFeatureValue GeoType:(NSInteger)nType
{
    @try {
        NSDictionary *GeoField = [DKFeatureValue objectForKey:@"geometry"];
        NSNumber *numWkid = [GeoField objectForKey:@"wkid"];
        int nWkid = [numWkid intValue];
        if (nWkid <= 0 || nWkid > 100000) {
            nWkid = 2383;
        }
        
        AGSMutablePolygon *poly = [[[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:nWkid WKT:nil]] autorelease];
        
        NSString *jsonString = [GeoField objectForKey:@"content"];
        NSError *err;
        NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData: [jsonString dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &err];
        if (nType == 0) {
            // 点
            NSString *xVal = [JSON objectForKey:@"x"];
            double dXPos = [xVal doubleValue];
            NSString *yVal = [JSON objectForKey:@"y"];
            double dYPos = [yVal doubleValue];
            AGSSpatialReference * Spref = [AGSSpatialReference spatialReferenceWithWKID:nWkid];
            AGSPoint * Point = [AGSPoint pointWithX:dXPos y:dYPos spatialReference:Spref];
            return Point;
        }
        else if(nType == 1){
            // 线
        }
        else {
            // 面
            NSArray *RingArr = [JSON objectForKey:@"rings"];
            for (NSArray *Ring in RingArr) 
            {
                [poly addRingToPolygon];
                for (NSArray *Points in Ring) 
                {
                    NSNumber *xPos = [Points objectAtIndex:0];
                    double dXpos = [xPos doubleValue];
                    NSNumber *yPos = [Points objectAtIndex:1];
                    double dYpos = [yPos doubleValue];
                    [poly addPointToRing:[AGSPoint pointWithX:dXpos y:dYpos spatialReference:nil]];
                }
                
            }
            return poly;
        }

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return nil;
    }
    @finally {
    }

}
// 根据议题ID和BSM查询地块数据
-(DBTopicDKDataItem*)GetDKDataItemByTopicAndBsm:(NSString*)TopicID  DKBsm:(NSString*)Bsm
{
    NSArray *DKDatas = [[self TopicsDKDataDic] objectForKey:TopicID];
    for (DBTopicDKDataItem *Item in DKDatas) {
        if ([[Item DKBsm] isEqualToString:Bsm]) {
            return Item;
        }
    }
    return nil;
}
//----------------------------------------------------------
// Handle the response from DownLoadFeatureByBsm.
// 接收数据
- (void) getDKFeatureByBsmHandler: (id) value {
    BOOL bFlg = YES;
    BOOL bErrFlg = NO;
    @try {
        [UIApplication showNetworkActivityIndicator:NO];
        // Handle errors
        if([value isKindOfClass:[NSError class]]) {
            //NSLog(@"%@", value);
            NSError *error = (NSError *)value;
            NSString *string = [error localizedDescription];
            [self CreateFailedAlertViewWithFailedInfo:@"地块坐标数据下载错误" andWithMessage:string];
            bErrFlg = YES;
            return;
        }
        
        // Handle faults
        if([value isKindOfClass:[SoapFault class]]) {
            //NSLog(@"%@", value);
            SoapFault *soapFault = (SoapFault *)value;
            NSString *string = [soapFault description];
            NSRange range = [string rangeOfString:@"SPECIFIED LAYER DOES NOT EXIST"];
            if (range.location != NSNotFound ) 
            {
                [self CreateFailedAlertViewWithFailedInfo:@"地块数据下载失败" andWithMessage:@"指定的层不存在"];
            }
            else {
                //[self CreateFailedAlertViewWithFailedInfo:@"地块数据下载失败!" andWithMessage:string];
                [self CreateFailedAlertViewWithFailedInfo:@"地块数据下载失败" andWithMessage:@""];
            }
            bErrFlg = YES;
            return;
        }				
        
        // 从队列取得议题ID，同时检查是会审，还是闲置地块巡查
        NSString *TopicId = [_TopicIdQueue dequeue];
        
        NSArray *parts = [TopicId componentsSeparatedByString:@"_"];
        if ([parts count] == 2) {
            NSString *compon = [parts objectAtIndex:1];
            if ([compon isEqualToString:@"XZDKGeometry"])
            {
                // 闲置地块巡查的场合
                bFlg = NO;
            }
        }
        
        [TopicDKReloadDelegate TopicDKDownloadCompleted:@"开始解析地块坐标数据..."];
        // Do something with the DBqueryResponse* result
        DBqueryResponse* result = (DBqueryResponse*)value;
        NSDictionary *dicRes = (NSDictionary*)result;
        //NSLog(@"getFeature returned the value: %@", result);
        
        NSDictionary *returnDic = [dicRes objectForKey:@"return"];
        NSDictionary *featuresetMap = [returnDic objectForKey:@"featuresetMap"];
        NSDictionary *entry = [featuresetMap objectForKey:@"entry"];
        NSDictionary *valueDic = [entry objectForKey:@"value"];
        NSInteger count = valueDic.count;
        if (count <= 3) {
            // 没有地块数据
            return;
        }
        
        //NSMutableArray *DKDataItemArr = [NSMutableArray arrayWithCapacity:3];
        NSMutableDictionary *DKBSM2DataDic = [NSMutableDictionary dictionaryWithCapacity:3]; 
        for (int i = 0; i < count - 4; i++) 
        {
            // 地块数据体
            NSString *Bsm = nil;
            DBTopicDKDataItem *TopicDKData = [[DBTopicDKDataItem alloc] init]; 
            
            NSString *POIKey = [NSString stringWithFormat:@"NodeName%d", i];
            NSDictionary *DKFeatureValue = [valueDic objectForKey:POIKey];
            NSDictionary *fieldsDic = [DKFeatureValue objectForKey:@"fields"];
            
            // 解析第n个属性field
            for (int i = 0; i < fieldsDic.count - 1; i++) 
            {
                NSString *Nodekey = [NSString stringWithFormat:@"NodeName%d", i];
                NSDictionary *NodeValue = [fieldsDic objectForKey:Nodekey];
                NSString *RetBsm = [self ParseAllField:NodeValue TopicDKDataItem:TopicDKData];
                if (RetBsm != nil) {
                    Bsm = [RetBsm copy];
                }
            }
            
            // 解析第1个属性field
            NSDictionary *FieldValue = [fieldsDic objectForKey:@"field"];
            NSString *RetBsm = [self ParseAllField:FieldValue TopicDKDataItem:TopicDKData];
            if (RetBsm != nil) {
                Bsm = [RetBsm copy];
            }
            
            // 解析地块坐标数据
            AGSGeometry * geoData = [self ParaseDKGeoData:DKFeatureValue GeoType:2];
            [TopicDKData setDKGeometry:geoData];
            
            if (TopicDKData != nil) {
                if ([Bsm length] > 0) {
                    if (!bFlg) {
                        // 用于闲置地巡查的地块
                        [DKBSM2DataDic setObject:TopicDKData forKey:Bsm];
                    }
                    else{
                        DBTopicDKDataItem *DKData = [self GetDKDataItemByTopicAndBsm:TopicId DKBsm:Bsm];
                        [TopicDKData setDKBH:[DKData.DKBH copy]];
                        [DKBSM2DataDic setValue:TopicDKData forKey:Bsm];
                    }

                }
            }
            [TopicDKData release];
        }
        
        // 解析第一个地块数据
         NSString *Bsm = nil;
        NSDictionary *DKFeatureValue = [valueDic objectForKey:@"features"];
        DBTopicDKDataItem *TopicDKData2 = [[DBTopicDKDataItem alloc] init];
        NSDictionary *fieldsDic = [DKFeatureValue objectForKey:@"fields"];
        for (int i = 0; i < fieldsDic.count - 1; i++)
        {
            NSString *NodeKey = [NSString stringWithFormat:@"NodeName%d", i];
            NSDictionary *NodeValue = [fieldsDic objectForKey:NodeKey];
            NSString *RetBsm = [self ParseAllField:NodeValue TopicDKDataItem:TopicDKData2];
            if (RetBsm != nil) {
                Bsm = [RetBsm copy];
            }

        }
        NSDictionary *FieldValue = [fieldsDic objectForKey:@"field"];
        NSString *RetBsm = [self ParseAllField:FieldValue TopicDKDataItem:TopicDKData2];
        if (RetBsm != nil) {
            Bsm = [RetBsm copy];
        }
        
        // 解析几何图形坐标数据
        AGSGeometry * geoData = [self ParaseDKGeoData:DKFeatureValue GeoType:2];
        [TopicDKData2 setDKGeometry:geoData];
        
        // 追加到地块Arr里
        if (TopicDKData2 != nil) {
            //[DKDataItemArr addObject:TopicDKData2];
             if([Bsm length] > 0) {
                 if (!bFlg) {
                     // 用于闲置地巡查的地块
                     [DKBSM2DataDic setObject:TopicDKData2 forKey:Bsm];
                 }
                 else{
                     DBTopicDKDataItem *DKData = [self GetDKDataItemByTopicAndBsm:TopicId DKBsm:Bsm];
                     [TopicDKData2 setDKBH:[DKData.DKBH copy]];
                     [DKBSM2DataDic setValue:TopicDKData2 forKey:Bsm];
                 }
             }
        }
        [TopicDKData2 release];
        
        if (!bFlg) {
            // 用于闲置地巡查的地块
            NSString *dkId = [parts objectAtIndex:0];
            [self.XCDKGeometryDataDic setObject:DKBSM2DataDic forKey:dkId];
            [self.XCDKDownloadDeg XCDKGeometryDownloadFinish:dkId];
        }
        else{
            //[_TopicIDToFeatureDic setValue:DKDataItemArr forKey:TopicId];
            [_TopicIDToFeatureDic setValue:DKBSM2DataDic forKey:TopicId];
            [_TopicDKDataQueryDelegate TopicDKDidQuery:TopicId];
        }

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        bErrFlg = YES;
    }
    @finally {
        if (bErrFlg) {
            // error
            if (!bFlg) {
                [self.XCDKDownloadDeg XCDKGeometryDownloadError:@"巡查地块数据查询失败"];
            }
            else{
                // 议题地块查询失败
            }
        }
        return;
    }
}

#pragma mark POI数据下载相关处理
//----------------------------------------------------------
// 查询下载POI数据
-(BOOL)DownLoadPOI:(NSString *)QueryString downLoadFlg:(NSInteger)nFlg
{
    NSString *QueryString2 = nil;
    if (nFlg == 0) {
        [POIArray removeAllObjects];
        QueryString2 = [QueryString copy];
        LastQueryWord = [QueryString2 copy];
    }
    else {
        QueryString2 = [LastQueryWord copy];
    }

    DBSeLayerPort* service = [DBSeLayerPort service];
	service.logging = YES;
	// service.username = @"username";
	// service.password = @"password";
    
    //构建查询对象
    DBqueryObject *queryObj = [[DBqueryObject alloc] init];
    //查询图层名
    [queryObj setTableName:@"poi_new_county"];
    //
    DBfield *field = [[DBfield alloc] init];
    [field setName:@"mc"];
    //[[queryObj fields] addObject:field];
    [[queryObj fields] removeAllObjects];
    [[queryObj fields] addObject:field];
    [field release];
    field = [[DBfield alloc] init];
    [field setName:@"YSLX"];
    [[queryObj fields] addObject:field];
    [field release];
    field = [[DBfield alloc] init];
    [field setName:@"MC_1"];
    [[queryObj fields] addObject:field];
    [field release];
    field = [[DBfield alloc] init];
    [field setName:@"CX"];
    [[queryObj fields] addObject:field];
    [field release];
    field = [[DBfield alloc] init];
    [field setName:@"CY"];
    [[queryObj fields] addObject:field];
    [field release];
    // 详细地址
    field = [[DBfield alloc] init];
    [field setName:@"XXDZ"];
    [[queryObj fields] addObject:field];
    [field release];
    // 联系电话
    field = [[DBfield alloc] init];
    [field setName:@"LXDH"];
    [[queryObj fields] addObject:field];
    [field release];
    // 标识码
    field = [[DBfield alloc] init];
    [field setName:@"BSM"];
    [[queryObj fields] addObject:field];
    [field release];
    // OBJECTID:POI唯一标识符
    field = [[DBfield alloc] init];
    [field setName:@"OBJECTID"];
    [[queryObj fields] addObject:field];
    [field release];
    
    //查询条件
    //[queryObj setWhereCaluse:@"where mc like  '%酒店%'"];
    NSString *QueryWord = @"where mc like '%";
    NSArray	* array = [QueryString2 componentsSeparatedByString:@" "];
    for (int i = 0; i < array.count; i++) {
        NSString *string = [array objectAtIndex:i];
        if (i == 0) {
            QueryWord = [QueryWord stringByAppendingFormat:@"%@", string];
            QueryWord = [QueryWord stringByAppendingString:@"%'"];
        }else if(i < array.count){
            QueryWord = [QueryWord stringByAppendingString:@" or mc like '%"];
            QueryWord = [QueryWord stringByAppendingFormat:@"%@", string];
            QueryWord = [QueryWord stringByAppendingString:@"%'"]; 
        }
    }
	
    // 排序 center
    QueryWord = [QueryWord stringByAppendingFormat:@" ORDER BY DISTANCETOCENTER ASC"];
    [queryObj setWhereCaluse:QueryWord];
    
    //是否返回图形坐标
    [queryObj setReturnShape:YES];
    
    [queryObj setBeginRecord:[POIArray count] + 1];
    //返回最大记录数(下载8条记录)
    [queryObj setLimitRecord:9];
    //[queryObj setOutSR:2383];
    // 异步调用
    [UIApplication showNetworkActivityIndicator:YES];
    SoapRequest *req = [service getFeature:self action:@selector(getFeatureHandler:) arg0: queryObj];
    [req setLogging:YES];
    //[service getFeature:self arg0:queryObj];
    [queryObj release];
    
    return YES;
}

//解析每个POI属性
-(void)ParseAllPOI:(NSDictionary *)NodeValue POIDataItem:(DBPOIData*)POIData
{
    @try {
        
        NSString *name = [NodeValue objectForKey:@"name"];
        NSString *value = [NodeValue objectForKey:@"value"];
        //判断取出来的数据是否为NSNull类型
        if ([value isKindOfClass:[NSNull class]]) {
            value = @"";
        }    
        if ([name isEqualToString:@"MC_1"])
        {
            POIData.POIAddress = value;
        }
//        else if([name isEqualToString:@"CX"])
//        {
//            POIData.POIx = value;
//        }
//        else if([name isEqualToString:@"CY"])
//        {
//            POIData.POIy = value;
//        }
        else if([name isEqualToString:@"mc"])
        {
            POIData.POIName = value;
        }else if([name isEqualToString:@"XXDZ"])
        {
            POIData.POIXXDZ = value;
        }else if([name isEqualToString:@"LXDH"])
        {
            POIData.LXDH = value;
        }else if([name isEqualToString:@"BSM"]){
            POIData.BSM = value;
        }
        return;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return;
    }
    @finally {
    }
}
//----------------------------------------------------------
// Handle the response from getFeature.
// 接收POI数据
- (void) getFeatureHandler: (id) value 
{
    @try {
        [UIApplication showNetworkActivityIndicator:NO];
        // Handle errors
        if([value isKindOfClass:[NSError class]]) {
            //NSLog(@"%@", value);
            NSError *error = (NSError *)value;
            NSString *string = [error localizedDescription];
            //[_delegate POIDidQuery:0 EndIndex:0 ResponseCode:-1 ErrorMessage:string];
            [self CreateFailedAlertViewWithFailedInfo:@"兴趣点数据查询错误" andWithMessage:string];
            return;
        }
        
        // Handle faults
        if([value isKindOfClass:[SoapFault class]]) {
            //NSLog(@"%@", value);
            SoapFault *SoapFaultData = (SoapFault *)value;
            NSString *string = [SoapFaultData description];
            NSRange range = [string rangeOfString:@"SPECIFIED LAYER DOES NOT EXIST"];
            if (range.location != NSNotFound ) 
            {
                [self CreateFailedAlertViewWithFailedInfo:@"兴趣点数据查询失败" andWithMessage:@"指定的层不存在"];
            }
            else {
                [self CreateFailedAlertViewWithFailedInfo:@"兴趣点数据查询失败" andWithMessage:string];
            }
            return;
        }				
        
        
        // Do something with the DBqueryResponse* result
        DBqueryResponse* result = (DBqueryResponse*)value;
        NSDictionary *dicRes = (NSDictionary*)result;
        //NSLog(@"getFeature returned the value: %@", result);
        
        NSDictionary *returnDic = [dicRes objectForKey:@"return"];
        NSDictionary *featuresetMap = [returnDic objectForKey:@"featuresetMap"];
        NSDictionary *entry = [featuresetMap objectForKey:@"entry"];
        NSDictionary *valueDic = [entry objectForKey:@"value"];
        NSInteger count = valueDic.count;
        if (count <= 3) {
            [_delegate POIDidQuery:0 EndIndex:0 ResponseCode:-3 ErrorMessage:@"没有结果"];
            return;
        }
        int nStartPOIIndex = [POIArray count];
        NSInteger nIndex = nStartPOIIndex;
        for (int i = 0; i < count - 4; i++) {
            NSString *POIKey = [NSString stringWithFormat:@"NodeName%d", i];
            NSDictionary *POIValue = [valueDic objectForKey:POIKey];
            //NSString *area = [POIValue objectForKey:@"area"];
            //NSString *bsm = [POIValue objectForKey:@"bsm"];
            NSDictionary *fieldsDic = [POIValue objectForKey:@"fields"];
            DBPOIData *POIData = [[DBPOIData alloc] init];
            POIData.OID = [POIValue objectForKey:@"oid"];
            for (int i = 0; i < fieldsDic.count - 1; i++) 
            {
                NSString *Nodekey = [NSString stringWithFormat:@"NodeName%d", i];
                NSDictionary *NodeValue = [fieldsDic objectForKey:Nodekey]; 
                [self ParseAllPOI:NodeValue POIDataItem:POIData];
                
            }
            NSDictionary *FieldValue = [fieldsDic objectForKey:@"field"];
            [self ParseAllPOI:FieldValue  POIDataItem:POIData];
            
            // 解析坐标数据
            AGSPoint * geoPoint = (AGSPoint*)[self ParaseDKGeoData:POIValue GeoType:0];
            [POIData setPoint:geoPoint];
            // 设置索引值
            [POIData setNIndex:nIndex++]; 
            [POIArray addObject:POIData];
            [POIData release];
        }
        NSDictionary *POIValue = [valueDic objectForKey:@"features"];
        //NSString *area = [POIValue objectForKey:@"area"];
        //NSString *bsm = [POIValue objectForKey:@"bsm"];
        DBPOIData *POIData = [[DBPOIData alloc] init];
        POIData.OID = [POIValue objectForKey:@"oid"];
        NSDictionary *fieldsDic = [POIValue objectForKey:@"fields"];
        for (int i = 0; i < fieldsDic.count - 1; i++)
        {
            NSString *NodeKey = [NSString stringWithFormat:@"NodeName%d", i];
            NSDictionary *NodeValue = [fieldsDic objectForKey:NodeKey];
            [self ParseAllPOI:NodeValue POIDataItem:POIData];
        }
        NSDictionary *FieldValue = [fieldsDic objectForKey:@"field"];
        [self ParseAllPOI:FieldValue POIDataItem:POIData];
        
        // 解析坐标数据
        AGSPoint * geoPoint = (AGSPoint*)[self ParaseDKGeoData:POIValue GeoType:0];
        [POIData setPoint:geoPoint];
        // 设置索引值
        [POIData setNIndex:nIndex++]; 
        [POIArray addObject:POIData];
        [POIData release];
        
        int nEndPOIIndex = [POIArray count];
        // 
        [_delegate POIDidQuery:nStartPOIIndex EndIndex:nEndPOIIndex ResponseCode:0 ErrorMessage:nil];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        // 处理异常
        NSString *errMsg = @"数据处理异常";
        [_delegate POIDidQuery:0 EndIndex:0 ResponseCode:-3 ErrorMessage:errMsg];
    }
    @finally {
        return ;
    }

}

#pragma mark 切片数据相关处理
//----------------------------------------------------------
// 获取切片文件存储全路径
-(NSString*)GetTileFullPath:(int)nLevel Row:(int)nRow Column:(int)nColumn
{
    NSString *pngDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *pngImageName = [NSString stringWithFormat:@"%d.png", nColumn];
    // create [~/Documents/Tiles/row/column.png] similar directory
    NSString *pngDirectory = [NSString stringWithFormat:@"%@/Tiles/%d/%d", pngDir, nLevel, nRow];
    NSString *pngFileFullPath = [NSString stringWithFormat:@"%@/%@", pngDirectory, pngImageName];
    return pngFileFullPath;
}

//----------------------------------------------------------
// 检测指定的tile文件是否存在
-(BOOL)TileFileIsExist:(int)nLevel Row:(int)nRow Column:(int)nColumn
{
    NSString *pngFileFullPath = [self GetTileFullPath:nLevel Row:nRow Column:nColumn];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL bRet = [fileMgr fileExistsAtPath:pngFileFullPath];
    return bRet;
}

//----------------------------------------------------------
// 下载指定地图服务的所有切片到本地数据库
-(BOOL)DownloadAllTilesByMapUrl:(NSURL*)MapUrl
{
    BOOL bRet = NO;
    @try {
        NSError *err = nil;
        AGSMapServiceInfo *serviceInfo = [AGSMapServiceInfo mapServiceInfoWithURL:MapUrl error:&err];
        AGSTileInfo * _TileInfo = [serviceInfo tileInfo];
        NSString *BaseMapUrl = [MapUrl absoluteString];
        NSMutableString *BaseMapUrl2 = [[NSMutableString alloc] init];
        [BaseMapUrl2 appendString:BaseMapUrl];
        NSString *ImageFormatTmp = [_TileInfo format];
        
        NSRange range = [ImageFormatTmp rangeOfString:@"png" options:NSCaseInsensitiveSearch];
        NSString *ImageFormat = nil;
        if (range.length > 0) {
            ImageFormat = @"png";
        }
        else {
            range = [ImageFormatTmp rangeOfString:@"jpg" options:NSCaseInsensitiveSearch];
            if (range.length > 0) {
                ImageFormat = @"jpg";
            }
            else {
                range = [ImageFormatTmp rangeOfString:@"jpeg" options:NSCaseInsensitiveSearch];
                if (range.length > 0) {
                    ImageFormat = @"jpeg";
                }
            }
        }
        
        if (ImageFormat == nil) {
            ImageFormat = @"png1";
        }
        
        _imageDownloadsInProgress = [[NSMutableDictionary alloc] initWithCapacity:5];
        
        // 将下载图片URL地址加入队列
        AGSLOD *lod = nil;
        int nCount = 0;
        for (lod in [_TileInfo lods]) 
        {
            // 默认下载1、2、3、4level的切片数据
            if ((nCount == 0) || (nCount > 5)) {
                nCount++;
                continue;
            }
            NSUInteger startTileRow = lod.startTileRow;
            NSUInteger endTileRow = lod.endTileRow;
            NSUInteger startTileColumn = lod.startTileColumn;
            NSUInteger endTileColumn = lod.endTileColumn;
            for (int nRow = startTileRow; nRow <= endTileRow; nRow++)
            {
                for (int nColumn = startTileColumn; nColumn <= endTileColumn; nColumn++)
                {
                    NSMutableString *BaseMapUrlTmp = [[[NSMutableString alloc] init] autorelease];
                    [BaseMapUrlTmp appendString:BaseMapUrl2];
                    NSString *keyString = [NSString stringWithFormat:@"/tile/%d/%d/%d.%@", lod.level, nRow, nColumn, ImageFormat];
                    
                    // 检测本地是否有此tile文件
                    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
                    BOOL bRet = [DataMan TileFileIsExist:lod.level Row:nRow Column:nColumn];
                    if (bRet) {
                        // 当前切片文件已经存在
                        continue;
                    }
                    // 生成切片url地址
                    [BaseMapUrlTmp appendFormat:@"/tile/%d/%d/%d.%@", lod.level, nRow, nColumn, ImageFormat];
                    [BaseMapUrlTmp appendString:keyString];
                    
                    TileImageRecord *TileImageRecordData = [[[TileImageRecord alloc] init] autorelease];
                    TileImageRecordData.imageURLString = [BaseMapUrlTmp copy];
                    
                    [TileImageRecordData setReckey:keyString];
                    [TileImageRecordData setNLevel:lod.level];
                    [TileImageRecordData setNRow:nRow];
                    [TileImageRecordData setNColumn:nColumn];
                    
                    [_entries addObject:TileImageRecordData];
                    TileImageRecordData = nil;
                }
            }
            nCount++;
        }
        SumDownloadCnt = (float)_entries.count;
        [BaseMapUrl2 release];
        
        
        TileImageRecord *TileImageRecordData = nil;
        for (TileImageRecordData in _entries) 
        {
            [self startIconDownload:TileImageRecordData];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        return bRet;
    }

}

//----------------------------------------------------------
// 下载切片文件数据
- (void)startIconDownload:(TileImageRecord *)TileImageRecordData
{
    @try {
        NSString *recKey = [TileImageRecordData Reckey];
        IconDownloader *iconDownloader = [_imageDownloadsInProgress objectForKey:recKey];
        int nLen = 0;
        if(iconDownloader != nil)
        {
            nLen = [iconDownloader.activeDownload length];
            
        }
        
        if ((iconDownloader == nil) || (nLen <= 0))
        {
            iconDownloader = [[IconDownloader alloc] init];
            iconDownloader.TileImageRecordData = TileImageRecordData;
            //iconDownloader.indexPathInTableView = indexPath;
            iconDownloader.delegate = self;
            [_imageDownloadsInProgress setObject:iconDownloader forKey:[TileImageRecordData Reckey]];
            [iconDownloader startDownload];
            [iconDownloader release];   
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [Logger WriteLog:__FILE__ funcName:__FUNCTION__ lineNum:__LINE__ exceptionObj:nil textInf:"func end"];
    }
    
    return;
}

#pragma mark IconDownloaderDelegate Methods
- (void)appImageDidLoad:(NSString *)RecKey
{
    @try {
        IconDownloader *iconDownloader = [_imageDownloadsInProgress objectForKey:RecKey];
        if (iconDownloader != nil)
        {
            DownloadedCnt++;
            
            [LocalDelegate DidDownloadProgress:(float)DownloadedCnt / SumDownloadCnt];
            if (DownloadedCnt >= SumDownloadCnt) {
                DownloadedCnt = 0;
                [_entries removeAllObjects];
            }
           
            // save image data to sqlite database
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [Logger WriteLog:__FILE__ funcName:__FUNCTION__ lineNum:__LINE__ exceptionObj:nil textInf:"func end"];
    }
    
    return;
}

#pragma mark 数据库相关处理
//----------------------------------------------------------
// 获取Sqlite数据库全路径
- (NSString*)getDabaBasePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:DATABASE_FILE_NAME];
    return path;
}

//----------------------------------------------------------
// 查询指定的表是否存在
-(BOOL)IsTableExist:(NSString*)tableName
{
    BOOL bRet = FALSE;
    @try {
        sqlite3_stmt *statement = nil;
        char sqlBuf[1024];
        memset(sqlBuf, 0x00, sizeof(sqlBuf));
        sprintf(sqlBuf, "select name from sqlite_master where type='table' and name='%s'",[tableName UTF8String]);
        int nRet = sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL);
        if (nRet != SQLITE_OK) 
        {
            //NSLog(@"error");
        }
        
        if (sqlite3_step(statement) == SQLITE_ROW) {
            bRet = TRUE;
        }
        
        int totalRow = sqlite3_column_count(statement);
        if (totalRow <= 0) {
            //NSLog(@"the table is not exist");
        }
        sqlite3_finalize(statement);
        return bRet;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return FALSE;
    }
    @finally {
    }
 
}

//----------------------------------------------------------
//【2】创建表格
//创建表格，假设有五个字段，（id，cid，title，imageData ，imageLen ） //说明一下，id为表格的主键，必须有。 //cid，和title都是字符串，imageData是二进制数据，imageLen 是该二进制数据的长度。 
- (BOOL)createTableBySql:(NSString*)sqlstr
{ 
    @try {
        sqlite3_stmt *statement; 
        const char* sqlTmp = [sqlstr UTF8String];
        int nRet = sqlite3_prepare_v2(database, sqlTmp, -1, &statement, nil);
        if(nRet != SQLITE_OK) 
        { 
            //NSLog(@"Error: failed to prepare statement:create channels table"); 
            return NO; 
        } 
        int success = sqlite3_step(statement); 
        sqlite3_finalize(statement); 
        if ( success != SQLITE_DONE) 
        { 
            //NSLog(@"Error: failed to dehydrate:CREATE TABLE channels"); 
            return NO; 
        } 
        //NSLog(@"Create table 'channels' successed."); 
        
        return YES; 
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return FALSE;
    }
    @finally {
        
    }

}  

//----------------------------------------------------------
// 存储一个切片文件到数据库
-(BOOL)SaveOneTile:(NSString*)MapUrl Level:(int)nLevel Row:(int)nRow Column:(int)nColumn TileImage:(UIImage*)Image
{
    //NSString *MapUrl = Url.absoluteString;
    
    @try {
        NSData* ImageData = UIImagePNGRepresentation(Image); 
        NSInteger Imagelen = [ImageData length]; 
        sqlite3_stmt *statement;
        //const char *test = "test1";
        
        char sqlBuf[500];
        memset(sqlBuf, 0x00, sizeof(sqlBuf));
        sprintf(sqlBuf, "INSERT INTO '%s' (level,row,column,tile)\
                VALUES(?,?,?,?)",[MapUrl UTF8String]);
        
        //问号的个数要和(cid,title,imageData,imageLen)里面字段的个数匹配，代表未知的值，将在下面将值和字段关联。 
        int success = sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL); 
        if (success != SQLITE_OK) 
        { 
            //NSLog(@"Error: failed to insert:channels"); 
            return NO; 
        } 
        //这里的数字1，2，3，4代表第几个问号 
        sqlite3_bind_int(statement, 1, nLevel); 
        sqlite3_bind_int(statement, 2, nRow); 
        sqlite3_bind_int(statement, 3, nColumn); 
        sqlite3_bind_blob(statement, 4, [ImageData bytes], Imagelen, SQLITE_TRANSIENT); 
        
        success = sqlite3_step(statement); 
        sqlite3_finalize(statement); 
        
        if (success == SQLITE_ERROR) { 
            //NSLog(@"Error: failed to insert into the database with message."); 
            return NO; 
        }  
        
        return YES; 
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return FALSE;
    }
    @finally {
        
    }

}

//----------------------------------------------------------
// 存储并且替换一个切片文件到数据库
-(BOOL)SaveOrReplaceOneTile:(NSString*)MapUrl Level:(int)nLevel Row:(int)nRow Column:(int)nColumn TileImage:(UIImage*)Image
{
    //NSString *MapUrl = Url.absoluteString;
    @try {
        NSData* ImageData = UIImagePNGRepresentation(Image); 
        NSInteger Imagelen = [ImageData length]; 
        sqlite3_stmt *statement;
        char sqlBuf[500];
        memset(sqlBuf, 0x00, sizeof(sqlBuf));
        sprintf(sqlBuf, "INSERT OR REPLACE INTO '%s' (level,row,column,tile)\
                VALUES(?,?,?,?)",[MapUrl UTF8String]);
        
        //问号的个数要和(cid,title,imageData,imageLen)里面字段的个数匹配，代表未知的值，将在下面将值和字段关联。 
        int success = sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL); 
        if (success != SQLITE_OK) 
        { 
            //NSLog(@"Error: failed to insert:channels"); 
            return NO; 
        } 
        //这里的数字1，2，3，4代表第几个问号 
        sqlite3_bind_int(statement, 1, nLevel); 
        sqlite3_bind_int(statement, 2, nRow); 
        sqlite3_bind_int(statement, 3, nColumn); 
        sqlite3_bind_blob(statement, 4, [ImageData bytes], Imagelen, SQLITE_TRANSIENT); 
        
        success = sqlite3_step(statement); 
        sqlite3_finalize(statement); 
        
        if (success == SQLITE_ERROR) { 
            //NSLog(@"Error: failed to insert into the database with message."); 
            return NO; 
        }  
        
        return YES; 
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return FALSE;
    }
    @finally {
        
    }

}

//----------------------------------------------------------
// 从数据库加载一个切片文件
-(UIImage*)LoadTile:(NSString*)MapUrl Level:(int)nLevel Row:(int)nRow Column:(int)nColumn
{
    @try {
        sqlite3_stmt *statement = nil; 
        //const char *sql = "SELECT * FROM channels2"; 
        //NSString *MapUrl = Url.absoluteString;
        
        char sqlBuf[500];
        memset(sqlBuf, 0x00, sizeof(sqlBuf));
        sprintf(sqlBuf, "SELECT tile FROM '%s' WHERE level = '%d' AND row = '%d' AND \
                column = '%d'",[MapUrl UTF8String], nLevel, nRow, nColumn);
        if (sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL) != SQLITE_OK) 
        { 
            //NSLog(@"Error: failed to prepare statement with message:get channels."); 
        } 
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。 
        while (sqlite3_step(statement) == SQLITE_ROW) 
        { 
            //char* cid       = (char*)sqlite3_column_text(statement, 1); 
            //char* title     = (char*)sqlite3_column_text(statement, 2); 
            const char* imageData = (const char*)sqlite3_column_blob(statement, 3);     
            int imageLen = strlen(imageData);
            if(imageData)
            { 
                sqlite3_finalize(statement); 
                UIImage* image = [UIImage imageWithData:[NSData dataWithBytes:imageData length:imageLen]]; 
                return image;
            } 
        } 
        sqlite3_finalize(statement); 
        return nil;

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return nil;
    }
    @finally {
        
    }
}

//----------------------------------------------------------
// 数据库和服务信息表（信息表中的每一条记录对应一个切片表）
-(BOOL)InitDataBase
{
    BOOL bRet = NO;
    @try {
        // 1.创建或打开数据库
        NSString *writableDBPath = [self getDabaBasePath];
        int nRet = sqlite3_open_v2([writableDBPath UTF8String], &database, SQLITE_OPEN_READWRITE|SQLITE_OPEN_CREATE, nil);
        if(nRet != SQLITE_OK) 
        { 
            sqlite3_close(database); 
            //NSLog(@"Error: open database file."); 
            return NO; 
        } 
        
        // 2.创建或打开MapServices表 
        bRet = [self IsTableExist:TABLE_SERVICE_NAME];
        if (!bRet) 
        {
            char sqlBuf[1024];
            memset(sqlBuf, 0x00, sizeof(sqlBuf));
            sprintf(sqlBuf, "CREATE TABLE '%s' (url text primary key not null unique, \
                    spatialreference text not null, \
                    fullextent text not null, \
                    tileinfo text not null)",[TABLE_SERVICE_NAME UTF8String]);
            //sprintf(sqlBuf, "CREATE TABLE '%s' (url text primary key not null unique, \
            spatialreference text not null, \
            fullextent text not null, \
            tileinfo blob not null)",[TABLE_SERVICE_NAME UTF8String]);
            NSString *sql = [NSString stringWithCString:sqlBuf encoding:NSUTF8StringEncoding];
            
            bRet = [self createTableBySql:sql];
        }
        
        return bRet;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return FALSE;
    }
    @finally {
        
    }

}

//----------------------------------------------------------
// 创建存储切片的表
-(BOOL)InitTileTableByMapUrl:(NSString*)MapUrl
{
    // 查询当前表是否已经存在
    BOOL bRet = NO;
    @try {
        
        bRet = [self IsTableExist:MapUrl];
        if (bRet) {
            return YES;
        }
        
        // 创建切片存储表
        char sqlBuf[1024];
        memset(sqlBuf, 0x00, sizeof(sqlBuf));
        sprintf(sqlBuf, "CREATE TABLE '%s' (level integer not null, row integer not null, column integer not null, tile blob not null)", [MapUrl UTF8String]);
        NSString *sql = [NSString stringWithCString:sqlBuf encoding:NSUTF8StringEncoding];
        bRet = [self createTableBySql:sql];
        return bRet;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return FALSE;
    }
    @finally {
        
    }
}

//----------------------------------------------------------
// 保存当前底图层元数据
-(BOOL)SaveLayerMetaData:(NSString*)url  SpatialReference:(NSString*)jsonSR FullExtent:(NSString*)jsonFullExtent TileInfo:(NSString*)jsonTileInfo
//-(BOOL)SaveLayerMetaData:(NSString*)url  SpatialReference:(NSString*)jsonSR FullExtent:(NSString*)jsonFullExtent TileInfo:(NSData*)jsonTileInfo
{
    @try {
        
        sqlite3_stmt *statement;
        
        char sqlBuf[1024];
        memset(sqlBuf, 0x00, sizeof(sqlBuf));
        sprintf(sqlBuf, "INSERT INTO '%s' (url,spatialreference,fullextent,tileinfo)\
                VALUES(?,?,?,?)",[TABLE_SERVICE_NAME UTF8String]);
        
        //问号的个数要和(cid,title,imageData,imageLen)里面字段的个数匹配，代表未知的值，将在下面将值和字段关联。 
        int success = sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL); 
        if (success != SQLITE_OK) 
        { 
            //NSLog(@"Error: failed to insert:%@", TABLE_SERVICE_NAME); 
            return NO; 
        } 
        //这里的数字1，2，3，4代表第几个问号 
        sqlite3_bind_text(statement, 1, [url UTF8String], -1, SQLITE_TRANSIENT); 
        sqlite3_bind_text(statement, 2, [jsonSR UTF8String], -1, SQLITE_TRANSIENT); 
        sqlite3_bind_text(statement, 3, [jsonFullExtent UTF8String], -1, SQLITE_TRANSIENT); 
        sqlite3_bind_text(statement, 4, [jsonTileInfo UTF8String], -1, SQLITE_TRANSIENT); 
        //NSInteger Imagelen = [jsonTileInfo length]; 
        //sqlite3_bind_blob(statement, 4, [jsonTileInfo bytes], Imagelen, SQLITE_TRANSIENT); 
        
        success = sqlite3_step(statement); 
        sqlite3_finalize(statement); 
        
        if (success == SQLITE_ERROR) { 
            //NSLog(@"Error: failed to insert into the database with message."); 
            return NO; 
        }  
        
        return YES;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return FALSE;
    }
    @finally {
        
    }
}

//----------------------------------------------------------
// 加载图层元数据
-(void*)LoadLayerMetaData:(NSString*)MapUrl GetAGSEnvelope:(AGSEnvelope**)Envelope 
        GetAGSTileInfo:(AGSTileInfo**)TileInfo
{
    @try {
        sqlite3_stmt *statement = nil; 
        
        char sqlBuf[500];
        memset(sqlBuf, 0x00, sizeof(sqlBuf));
        sprintf(sqlBuf, "SELECT * FROM '%s' WHERE url = '%s'",[TABLE_SERVICE_NAME UTF8String], [MapUrl UTF8String]);
        if (sqlite3_prepare_v2(database, sqlBuf, -1, &statement, NULL) != SQLITE_OK) 
        { 
            //NSLog(@"Error: failed to prepare statement with message:LoadLayerMetaData."); 
            return NO;
        } 
        //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。 
        while (sqlite3_step(statement) == SQLITE_ROW) 
        { 
            //char* MapUrl = (char*)sqlite3_column_text(statement, 0); 
            //char* srJson = (char*)sqlite3_column_text(statement, 1); 
            //NSString *srJson2 = [NSString stringWithCString:srJson encoding:NSUTF8StringEncoding];
            
            char* FullEnvelopJson = (char*)sqlite3_column_text(statement, 2); 
            NSString *FullEnvelopJson2 = [NSString stringWithCString:FullEnvelopJson encoding:NSUTF8StringEncoding];
            NSDictionary* FullEnvelopDic = [FullEnvelopJson2 AGSJSONValue]; 
            *Envelope = [[AGSEnvelope alloc] initWithJSON:FullEnvelopDic];
            
            char* TileInfoJson = (char*)sqlite3_column_text(statement, 3); 
            NSString *TileInfoJson2 = [NSString stringWithCString:TileInfoJson encoding:NSUTF8StringEncoding];
            NSDictionary* TileInfoDic = [TileInfoJson2 AGSJSONValue]; 
            AGSTileInfo*tileInf = [[AGSTileInfo alloc] initWithJSON:TileInfoDic];
            
            //            const char* TileInfoData = (const char*)sqlite3_column_blob(statement, 3);        
            //            int imageLen = strlen(TileInfoData);
            //            NSError *err = nil;
            //            AGSTileInfo*tileInf = nil;
            //            NSData *tileData = [NSData dataWithBytes:TileInfoData length:imageLen];
            //            if(tileData)
            //            { 
            //                NSMutableDictionary* TileInfoDic = [NSJSONSerialization JSONObjectWithData:tileData options:NSJSONReadingMutableContainers error:&err]; 
            //                tileInf = [[AGSTileInfo alloc] initWithJSON:TileInfoDic];
            //            }     
            
            *TileInfo = [[AGSTileInfo alloc] initWithDpi: tileInf.dpi 
                                                  format:tileInf.format 
                                                    lods:[tileInf lods]
                                                  origin:[tileInf.origin copy]
                                        spatialReference:[tileInf.spatialReference copy]
                                                tileSize:tileInf.tileSize];
            [*TileInfo computeTileBounds:*Envelope];
            
            //NSString * mapUrl = [NSString stringWithCString:MapUrl encoding:NSUTF8StringEncoding];
            //NSLog(@"%@", mapUrl);
            break;
        } 
        sqlite3_finalize(statement); 
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
}


#pragma mark 收发文数据加载
/*
-(void)ApproveDocDataLoad
{
    // 检测本地是否有配置文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // 本地本地配置信息文件
    NSString *FilePath = [documentsDirectory stringByAppendingPathComponent:@"DBMarkInfo.xml"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL bRet = [fileMgr fileExistsAtPath:FilePath];
    if (!bRet) {
        return;
    }
    
    NSData *data = [[NSData alloc] initWithContentsOfFile:FilePath];
    DDXMLDocument *MarkDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    NSArray *DocInfoList = [MarkDocument nodesForXPath:@"//XML/DocInfoList/DocInfo" error:nil];
    int nCount = DocInfoList.count;
    int i = 0;
    //ApproveDocDataList
    for (DDXMLElement *obj in DocInfoList)
    {
        DDXMLElement *eleVal = [obj elementForName:@"Id"];
        NSString *LayerName = eleVal.stringValue;
    }
}
*/
#pragma mark 土地巡查
//获得议题服务器网络通讯实例
-(AuthHttpEngine*)GetNetEngine
{
    if (self.AuthEngine == nil) {
        if ([_TopicWebServiceUrl length] <= 0) {
            return nil;
        }
        NSURL *url = [NSURL URLWithString:_TopicWebServiceUrl];
        NSString *hostName = [url host];
        NSNumber *port = [url port];
        int nPort= [port intValue];
        
        self.AuthEngine = [[AuthHttpEngine alloc] initWithHostName:hostName customHeaderFields:nil];
        [self.AuthEngine setPortNumber:nPort];
//        self.AuthEngine = [[AuthHttpEngine alloc] initWithHostName:@"172.16.206.154" customHeaderFields:nil];
//        [self.AuthEngine setPortNumber:8080];
        [self.AuthEngine useCache];
    }
    return self.AuthEngine;
}

//zhenglei 2014.12.27 增加获取附件服务器通讯实例方法，原有系统配置附件也采用议题服务器统一配置，议题服务器若与附件服务器不同则无法下载附件
-(AuthHttpEngine*)GetNetEngineForAnn
{
    if (self.AuthEngine == nil) {
        if ([_TopicWebServiceUrl length] <= 0) {
            return nil;
        }
        NSURL *url = [NSURL URLWithString:_AnnexDownloadServiceUrl];
        NSString *hostName = [url host];
        NSNumber *port = [url port];
        int nPort= [port intValue];
        
        self.AuthEngine = [[AuthHttpEngine alloc] initWithHostName:hostName customHeaderFields:nil];
        [self.AuthEngine setPortNumber:nPort];
        //        self.AuthEngine = [[AuthHttpEngine alloc] initWithHostName:@"172.16.206.154" customHeaderFields:nil];
        //        [self.AuthEngine setPortNumber:8080];
        [self.AuthEngine useCache];
    }
    return self.AuthEngine;
}

#pragma mark 国土巡察处理
-(void)LoadFromLocalFile:(int)status
{
    // 本地文件
    NSString *fileName = nil;
    if (status == 1) {
        fileName = @"CompletedLandList";
    }else{ //未竣工
        fileName = @"XCLandList";
    }
    NSString *path = [DocumentDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",fileName]];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL bRet = [fileMgr fileExistsAtPath:path];
    if (!bRet) {
        // 本地无此文件，则将此文件拷贝到本地目录。
        NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
        NSError *err;
        [fileMgr copyItemAtPath:jsonFilePath toPath:path error:&err];
    }
    
    // 读取
    NSData *JsonData = [NSData dataWithContentsOfFile:path];
    NSArray *arrTmp = [NSJSONSerialization JSONObjectWithData:JsonData options:NSJSONWritingPrettyPrinted error:nil];
    
    [self.XCDKList removeAllObjects];
    [self.XCDKList addObjectsFromArray:arrTmp];
}

//----------------------------------------------------------
/*
下载巡查地块数据
参数：
1. StartNum: 请求数据的起始记录号。
2. Count:请求记录的数量。
3. JGFlg:是否是已竣工地块。
*/
-(void)GetXCDKDataList:(int)StartNum Count:(int)Count StateFlg:(int)Flg
{
    BOOL bRet = NO;
    @try {
        _XCDKDownloadingFlg = 1;
        //just for test
//        [self LoadFromLocalFile:Flg];
//        return;
        // 从网络获取数据
        
        NSString * Param = [NSString stringWithFormat:@"<root><function>GetXCDKDataList</function><params><param>%d</param><param>%d</param><param>%d</param></params></root>", StartNum, Count, Flg];
        
        // for test
//        NSString * Param = [NSString stringWithFormat:@"<root><function>DownloadVacantLandManage</function><params><param>2009-01-01</param><param>2013-07-13</param></params></root>"];
//        
//        NSString * Param2 = [Param stringByEncodingHTMLEntities];
        //对数据进行加密处理
        NSString *Param2 = [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY];
        Param = [NSString stringWithFormat:@"<![CDATA[%@]]>", Param2];
        [self CallCommonGeoverService:Param action:@selector(DownloadCXDKDataListHandler:)];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        bRet = NO;
    }
    @finally {
       // [_delegate ResizeXCDKListViewPopoverSize:Flg];
        //[_XCDKDelegate XCDKViewReload:-1 State:Flg];
        return;
    }
}

- (void)DownloadCXDKDataListHandler:(id)value{
    [UIApplication showNetworkActivityIndicator:NO];
    BOOL bRet = YES;
    // 是否有新的数据 -1:忽略参数   0:无数据  1:有新数据
    int totalCount = 0;
    NSInteger nStateFlg = 0;
    @try {
        _XCDKDownloadingFlg = 0;
        // Handle errors
        if([value isKindOfClass:[NSError class]]) {
            
            NSError *error = (NSError *)value;
            NSString *string = [error localizedDescription];
            [self CreateFailedAlertViewWithFailedInfo:@"巡察地块列表下载错误" andWithMessage:string];
            return;
        }
        
        // Handle faults
        if([value isKindOfClass:[SoapFault class]]) {
            
            SoapFault *soapFault = (SoapFault *)value;
            NSString *string = [soapFault description];
            [self CreateFailedAlertViewWithFailedInfo:@"巡察地块列表服务器无响应" andWithMessage:string];
            return;
        }
        
        NSDictionary *dicData2 = (NSDictionary*)value;
        NSString *str = [dicData2 objectForKey:@"return"];
        // 解密处理
        NSString *plainStr = [EncryptUtil decryptUseDES:str key:ENCRYPT_KEY];
        
        NSData *data = [plainStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *JsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
        
        NSString *ErrCode = [JsonDic objectForKey:@"ErrCode"];
        if ([ErrCode isEqualToString:@"201"]) {
            // hasn't data
            return;
        }
        else if ([ErrCode isEqualToString:@"200"])
        {
            // has data
            NSString *state = [JsonDic objectForKey:@"JGStateJson"];
            nStateFlg = [state integerValue];
            totalCount = [[JsonDic objectForKey:@"totalCount"] intValue];
            NSArray *dataArr = [JsonDic objectForKey:@"LandInfoJSONArray"];
            if ([dataArr count] > 0) {
                if (nStateFlg == 1) {
                    // 已竣工地块
                    [self.JGXCDKList addObjectsFromArray:dataArr];
                }else if(nStateFlg == 0){
                    [self.XCDKList addObjectsFromArray:dataArr];
                }
            }
        }
        else{
            NSString *Memo = [JsonDic objectForKey:@"Memo"];
            [self CreateFailedAlertViewWithFailedInfo:Memo andWithMessage:nil];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        bRet = NO;
    }
    @finally {
        [_delegate ResizeXCDKListViewPopoverSize:nStateFlg];
        [self.XCDKDelegate XCDKViewReload:totalCount State:nStateFlg];

    }
 
}

// 上传巡察记录数据
-(void)UploadXCRecordData:(NSString*)XCRecordDataJson
{
    _XCRecordUploadingFlg = 1;
    NSString * Param = [NSString stringWithFormat:@"<root><function>UploadXCRecordData</function><params><param>%@</param></params></root>", XCRecordDataJson];
    
    //加密处理
    Param = [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY];
    Param = [NSString stringWithFormat:@"<![CDATA[%@]]>", Param];
    [self CallCommonGeoverService:Param action:@selector(UploadXCRecordDataHandler:)];
    
    return;
    
}
// 接收数据
- (void) UploadXCRecordDataHandler: (id) value {
    [UIApplication showNetworkActivityIndicator:NO];
    BOOL bRet = YES;
    @try {
        _XCRecordUploadingFlg = 0;
        // Handle errors
        if([value isKindOfClass:[NSError class]]) {
            //NSLog(@"%@", value);
            NSError *error = (NSError *)value;
            NSString *string = [error localizedDescription];
            [self CreateFailedAlertViewWithFailedInfo:@"数据上传错误" andWithMessage:string];
            bRet = NO;
            return;
        }
        
        // Handle faults
        if([value isKindOfClass:[SoapFault class]]) {
            //NSLog(@"%@", value);
            SoapFault *soapFault = (SoapFault *)value;
            NSString *string = [soapFault description];
            [self CreateFailedAlertViewWithFailedInfo:@"数据服务器无响应" andWithMessage:string];
            bRet = NO;
            return;
        }
        NSDictionary *dicData2 = (NSDictionary*)value;
        NSString *str = [dicData2 objectForKey:@"return"];
        // 解密处理
        NSString * plainStr = [EncryptUtil decryptUseDES:str key:ENCRYPT_KEY];
        
        NSData *data = [plainStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *JsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        
        // 200 is ok
        if (![[JsonDic objectForKey:@"ErrCode"] isEqualToString:@"200"]){
            if ([self.XCDKUploadDelegate respondsToSelector:@selector(XCDKRecordUploadError:)]) {
                [self.XCDKUploadDelegate XCDKRecordUploadError:nil];
            }
            //
            NSString *Memo = [JsonDic objectForKey:@"Memo"];
            [self CreateFailedAlertViewWithFailedInfo:Memo andWithMessage:nil];
        }else{
            if ([self.XCDKUploadDelegate respondsToSelector:@selector(XCDKRecordUploadFinish:)]) {
                [self.XCDKUploadDelegate XCDKRecordUploadFinish:JsonDic];
            }
            [self CreateFailedAlertViewWithFailedInfo:@"上传成功" andWithMessage:@""];
        }

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        bRet = NO;
    }
    @finally {
        if (!bRet) {
            //
            [self.XCDKDownloadDeg XCRecordUploadError:@"上传失败"];
        }
        else{
            [self.XCDKDownloadDeg XCRecordUploadFinish:@"上传完成"];
        }
         
        return;
    }

}

// 下载指定BSM的地块
-(BOOL)DownLoadXZDKFeatureByBsm:(NSString *)Bsm XCDKDataId:(NSString*)XCDKDataId
{
    // 只有一个BSM
    NSString *XCDKDataId2 = [NSString stringWithFormat:@"%@_XZDKGeometry", XCDKDataId];
    NSArray *bsms = [NSArray arrayWithObjects:Bsm, nil];
    [self DownLoadFeatureByBsm:bsms KeyWord:XCDKDataId2];
    return YES;
}

- (void)DownloadXCDKRecords:(NSString *)DKId
{
    BOOL bRet = NO;
    @try {
        
        NSString * Param = [NSString stringWithFormat:@"<root><function>DownloadXCRecords</function><params><param>%@</param></params></root>",DKId];
        Param = [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY];
        Param = [NSString stringWithFormat:@"<![CDATA[%@]]>", Param];
        
        [self CallCommonGeoverService:Param action:@selector(DownloadXCDKRecordsFinishHandler:)];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        bRet = NO;
    }
    @finally {
        return;
    }

}

- (void)DownloadXCDKRecordsFinishHandler:(id)value
{
    [UIApplication showNetworkActivityIndicator:NO];
    @try {
        if([value isKindOfClass:[NSError class]]) {
            
            NSError *error = (NSError *)value;
            NSString *string = [error localizedDescription];
            [self CreateFailedAlertViewWithFailedInfo:@"地块巡查信息下载错误" andWithMessage:string];
            if ([self.XCDKRecordsDelegate respondsToSelector:@selector(DownloadXCDKRecordsError:)]) {
                [self.XCDKRecordsDelegate DownloadXCDKRecordsError:value];
            }
            return;
        }
        
        // Handle faults
        if([value isKindOfClass:[SoapFault class]]) {
            
            SoapFault *soapFault = (SoapFault *)value;
            NSString *string = [soapFault description];
            [self CreateFailedAlertViewWithFailedInfo:@"地块巡查信息服务器无响应" andWithMessage:string];
            if ([self.XCDKRecordsDelegate respondsToSelector:@selector(DownloadXCDKRecordsError:)]) {
                [self.XCDKRecordsDelegate DownloadXCDKRecordsError:value];
            }
            return;
        }
        
        if ([value isKindOfClass:[NSDictionary class]]) {
            
            NSString *stringResult = [(NSDictionary *)value objectForKey:@"return"];
            //解密处理
            NSString *plainStr = [EncryptUtil decryptUseDES:stringResult key:ENCRYPT_KEY];
            
            NSDictionary *result = [NSJSONSerialization JSONObjectWithData:[plainStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:nil];
            NSString *errCode = [result objectForKey:@"ErrCode"];
            
            if ([errCode isEqualToString:@"201"] || [errCode isEqualToString:@"203"]) {
                [self CreateFailedAlertViewWithFailedInfo:[result objectForKey:@"Memo"] andWithMessage:@""];
                if ([self.XCDKRecordsDelegate respondsToSelector:@selector(DownloadXCDKRecordsError:)]) {
                    [self.XCDKRecordsDelegate DownloadXCDKRecordsError:value];
                }
                return;
            }
            
            if ([errCode isEqualToString:@"200"]) {
                NSDictionary *XCRecordInfo = [result objectForKey:@"XCRecord"];
                
                if ([self.XCDKRecordsDelegate respondsToSelector:@selector(DownloadXCDKRecordsDidFinish:)]) {
                    [self.XCDKRecordsDelegate DownloadXCDKRecordsDidFinish:XCRecordInfo];
                }
            }
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        return;
    }
    
}

- (void)authentcate:(NSString *)uuid{
    @try {
        _XCDKDownloadingFlg = 1;
        
        NSString * Param = [NSString stringWithFormat:@"<root><function>Authenticate</function><params><param>%@</param></params></root>", uuid];
        //[UIApplication showNetworkActivityIndicator:YES];
        //对数据进行加密处理
        NSString *Param2 = [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY];
        Param = [NSString stringWithFormat:@"<![CDATA[%@]]>", Param2];
        [self CallCommonGeoverService:Param action:@selector(authentcateHandler:)];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }

}

- (void)authentcateHandler:(id)value{
    [UIApplication showNetworkActivityIndicator:NO];

    @try {
        if([value isKindOfClass:[NSError class]]) {
            //NSLog(@"%@", value);
            NSError *error = (NSError *)value;
            NSString *string = [error localizedDescription];
            NSDictionary *dic = [NSDictionary dictionaryWithObject:string forKey:@"Memo"];
            if ([self.authDelegate respondsToSelector:@selector(authenticateDidError:)]) {
                [self.authDelegate authenticateDidError:dic];
            }
            return;
        }
        
        // Handle faults
        if([value isKindOfClass:[SoapFault class]]) {
            //NSLog(@"%@", value);
            SoapFault *soapFault = (SoapFault *)value;
            NSString *string = [soapFault description];
            NSDictionary *dic = [NSDictionary dictionaryWithObject:string forKey:@"Memo"];
            if ([self.authDelegate respondsToSelector:@selector(authenticateDidError:)]) {
                [self.authDelegate authenticateDidError:dic];
            }
            return;
        }
        NSDictionary *dicData2 = (NSDictionary*)value;
        NSString *str = [dicData2 objectForKey:@"return"];
        // 解密处理
        NSString * plainStr = [EncryptUtil decryptUseDES:str key:ENCRYPT_KEY];
        
        NSData *data = [plainStr dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *JsonDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
        
        // 200 is ok
//        if ([self.authDelegate respondsToSelector:@selector(authenticateDidFinish:)]) {
//            [self.authDelegate authenticateDidFinish:JsonDic];
//        }
        if ([[JsonDic objectForKey:@"ErrCode"] isEqualToString:@"200"]){
            if ([self.authDelegate respondsToSelector:@selector(authenticateDidFinish:)]) {
                [self.authDelegate authenticateDidFinish:JsonDic];
            }
        } else{
            if ([self.authDelegate respondsToSelector:@selector(authenticateDidError:)]) {
               // [self.authDelegate authenticateDidError:JsonDic];
                [self.authDelegate authenticateDidFinish:JsonDic];
            }
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
       
    }
}

// 解析业务图层和WebService服务数据
-(void)parsedDataMapLayerFromData:(NSData *)data
{
    @try {
        DDXMLDocument *_LayerDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
        //解析WebServiceUrl
        NSArray *WebServerUrlArray = [_LayerDocument nodesForXPath:@"//XML/WebServerUrl" error:nil];
        for (DDXMLElement *obj in WebServerUrlArray) {
            DDXMLElement *TopicsWebServerUrl = [obj elementForName:@"TopicsWebServerUrl"];
            if (TopicsWebServerUrl) {
                self.TopicWebServiceUrl = TopicsWebServerUrl.stringValue;
            }
            
            DDXMLElement *LandWebServerUrl = [obj elementForName:@"GISWebServerUrl"];
            if (LandWebServerUrl) {
                self.GISWebServiceUrl = LandWebServerUrl.stringValue;
            }
            
            DDXMLElement *AnnexServerUrl = [obj elementForName:@"AnnexServerUrl"];
            if (AnnexServerUrl) {
                self.AnnexDownloadServiceUrl = AnnexServerUrl.stringValue;
            }
        }
        [_LayerDocument release];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
}

//for test
- (NSDictionary *)readFile:(NSString *)fileName ofType:(NSString *)type
{
    NSString *filePath = [DocumentDir stringByAppendingFormat:@"/%@.%@", fileName, type];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        NSError *error = nil;
        NSString *jsonFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:type];
        [fileManager copyItemAtPath:jsonFilePath toPath:filePath error:&error];
    }
    NSData *temp = [NSData dataWithContentsOfFile:filePath];
    NSDictionary *data = [NSJSONSerialization JSONObjectWithData:temp options:NSJSONReadingMutableContainers error:nil ];
    return data;
}

-(CGRect)getScreenSize
{
//    // app尺寸，去掉状态栏
//    CGRect rec = [ UIScreen mainScreen ].applicationFrame;
//    return rec;
    // 屏幕尺寸
    CGRect rec = [ UIScreen mainScreen ].bounds;
    return rec;
//    r=0，0，320，480
//    // 状态栏尺寸
//    CGRect rect; rect = [[UIApplication sharedApplication] statusBarFrame];
}
@end

