 //
//  DBViewController.m
//  HZDuban2
//
//  Created by  on 12-6-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBViewController.h"
#import "OfflineableTiledMapServiceLayer.h"

#import "Logger.h"
#import "BookMarkManager.h"
#import "DBTopicDKDataItem.h"

// add by z
#import "ImageScrollView.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "DBCustomPriceViewController.h"
#import "DBMeetingDataItem.h"
#import "DBSubProjectDataItem.h"

#import "DBPOIData.h"
#import "DB2GoverDeciServerService.h"
#import "DBMapLayerDataItem.h"
#import "DBAGSGraphic.h"
#import "DBPreviewDataSource.h"
#import "DBMarkData.h"
#import "CommHeader.h"
#import "DBSingleLandInfoViewController.h"
#import "EncryptUtil.h"
#import "DBMapToolsView.h"

#define Top_Bar_Height      64.f

@interface DBViewController ()<DBMapToolsViewDelegate, UITextFieldDelegate>

//{
    // 为议题_Subject2ViewPopover的UI容器
    @property (retain, nonatomic) DBSubjectListController *Subject2ViewPopoverViewController;
    @property (retain, nonatomic) UIPopoverController *Subject2ViewPopover;
//}
    //@property (retain, nonatomic) DBTopCalculateDataView *TopCalculateDataView;
    @property (retain, nonatomic) DBBaseMapSwitchView *BaseMapSwitchView;
    //@property (nonatomic, retain) AGSDynamicMapServiceLayer *dynamicLayer_WuRanYuan;
    //@property (nonatomic, retain) AGSDynamicMapServiceLayer *dynamicLayer_WuRanQiYe;

    @property(nonatomic, retain) IBOutlet AGSQueryTask     *queryTask;
    @property(nonatomic, retain) IBOutlet AGSQuery   *query;
    @property(nonatomic, retain) IBOutlet AGSGraphicsLayer   *graphicsLayer;
    @property(nonatomic, retain) NSMutableArray *SelectedGraphics;

    @property (nonatomic, retain) AGSSketchGraphicsLayer* sketchLayer;
    @property (nonatomic,retain) AGSGraphic* activeGraphic;

    // The content filtered as a result of a search.
    @property (nonatomic,retain) NSMutableArray	*filteredListContent;	
    // CustomCallOut
    @property (nonatomic, retain) DBCustomPriceViewController *PriceViewController;
    @property (nonatomic, assign) BOOL isUpdatingLocation;

    // add by niurg 2015.9
    @property (nonatomic, retain)DBMapToolsView *mapToolsView;
    // end

@end

@implementation DBViewController

//@synthesize dynamicLayer = _dynamicLayer;
//@synthesize dynamicLayer_WuRanYuan = _dynamicLayer_WuRanYuan;
//@synthesize dynamicLayer_WuRanQiYe = _dynamicLayer_WuRanQiYe;

@synthesize nModelFlg = _nModelFlg;
@synthesize BaseMapView = _BaseMapView;
@synthesize MapContainterView = _MapContainterView;
@synthesize MapLocationBtn = _MapLocationBtn;

@synthesize BaseMapSwitchView = _BaseMapSwitchView;
@synthesize BaseMapSwitchBtn = _BaseMapSwitchBtn;
@synthesize SearchBarCtrl = _SearchBarCtrl;

@synthesize DataMapLayerViewPopover = _DataMapLayerViewPopover;
@synthesize MeetingViewPopover = _MeetingViewPopover;

@synthesize LatelySearchViewPopover = _LatelySearchViewPopover;
@synthesize GraphicAttPopoverView = _GraphicAttPopoverView;

@synthesize sketchLayer = _sketchLayer;
@synthesize activeGraphic=_activeGraphic;

@synthesize queryTask;
@synthesize query;
@synthesize graphicsLayer;
@synthesize GraphicsView = _GraphicsView;
@synthesize SelectedGraphics;
@synthesize IdentifyTask = _IdentifyTask;
@synthesize AnalyseIdentifyTask = _AnalyseIdentifyTask;

@synthesize geometryArray = _geometryArray;
@synthesize pushpins = _pushpins;
@synthesize gst = _gst;

@synthesize filteredListContent = _filteredListContent;

@synthesize PriceViewController = _PriceViewController;
@synthesize AllConfPopoverView = _AllConfPopoverView;
//@synthesize DataMapLayerNameArray = _DataMapLayerNameArray;
//@synthesize DataMapLayerUrlArray = _DataMapLayerUrlArray;
//@synthesize DataMapLayerSwitchArray = _DataMapLayerSwitchArray;
@synthesize BaseMapLayersDic = _BaseMapLayersDic;
@synthesize IndexArr, layerNameArr;
@synthesize LastBtnImageArray = _LastBtnImageArray;
@synthesize LandDataPopoverView = _LandDataPopoverView;
@synthesize beginPoint, endPoint;
@synthesize LandAttributePopoverView = _LandAttributePopoverView;
@synthesize LandAnalysePopoverView = _LandAnalysePopoverView;
@synthesize SingleManager;
@synthesize SubjectDataView;
@synthesize SubjectView;
//@synthesize DBXCDKDetailViewCtrl;
//@synthesize XCDKDataView;
@synthesize LandInfoViewContrl;
@synthesize MarkNoteViewContrl;
@synthesize MarkListPopoverView;

//@synthesize XCDKListViewPopover = _XCDKListViewPopover;
//@synthesize DBXCGeometryNameContrl = _DBXCGeometryNameContrl;
//@synthesize DBXCGeometryNamePopoverView = _DBXCGeometryNamePopoverView;
//@synthesize LandAnalyseGeometryQueue = _LandAnalyseGeometryQueue;
@synthesize MeetingView = _MeetingView;
@synthesize QueryMenuViewCtrl;
@synthesize QueryMenuPopoverView;
@synthesize locationManager = _locationManager;

@synthesize Subject2ViewPopoverViewController = _Subject2ViewPopoverViewController;
@synthesize Subject2ViewPopover = _Subject2ViewPopover;

// add by niurg 2015.9
@synthesize mapToolsView = _mapToolsView;
// end

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector 
{  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);  
    return [super respondsToSelector:aSelector];  
}  
#endif

#pragma mark - AGSQueryTaskDelegate
// for test
-(NSArray*)Get3TestPolygons
{
    // polygon one
    AGSMutablePolygon *poly = [[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:2383 WKT:nil]];
    [poly addRingToPolygon];
    [poly addPointToRing:[AGSPoint pointWithX:535000.0 y:2559000.0 spatialReference:nil]];
    [poly addPointToRing:[AGSPoint pointWithX:536000.0 y:2559000.0 spatialReference:nil]];
    [poly addPointToRing:[AGSPoint pointWithX:536000.0 y:2560500.0 spatialReference:nil]];
    [poly addPointToRing:[AGSPoint pointWithX:535000.0 y:2560500.0 spatialReference:nil]];
    [poly addPointToRing:[AGSPoint pointWithX:535000.0 y:2559000.0 spatialReference:nil]];
    
    // polygon two
    AGSMutablePolygon *poly2 = [[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:2383 WKT:nil]];
    [poly2 addRingToPolygon];
    [poly2 addPointToRing:[AGSPoint pointWithX:545000.0 y:2563000.0 spatialReference:nil]];
    [poly2 addPointToRing:[AGSPoint pointWithX:546000.0 y:2563000.0 spatialReference:nil]];
    [poly2 addPointToRing:[AGSPoint pointWithX:546000.0 y:2565000.0 spatialReference:nil]];
    [poly2 addPointToRing:[AGSPoint pointWithX:545000.0 y:2565000.0 spatialReference:nil]];
    [poly2 addPointToRing:[AGSPoint pointWithX:545000.0 y:2563000.0 spatialReference:nil]];
    
    // polygon three
    AGSMutablePolygon *poly3 = [[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:2383 WKT:nil]];
    [poly3 addRingToPolygon];
    [poly3 addPointToRing:[AGSPoint pointWithX:550000.0 y:2567000.0 spatialReference:nil]];
    [poly3 addPointToRing:[AGSPoint pointWithX:551000.0 y:2567000.0 spatialReference:nil]];
    [poly3 addPointToRing:[AGSPoint pointWithX:551000.0 y:2569000.0 spatialReference:nil]];
    [poly3 addPointToRing:[AGSPoint pointWithX:550000.0 y:2569000.0 spatialReference:nil]];
    [poly3 addPointToRing:[AGSPoint pointWithX:550000.0 y:2567000.0 spatialReference:nil]];

    NSArray *polygons = [[[NSArray alloc] initWithObjects:poly, poly2, poly3,nil] autorelease];
    return polygons;
}

//results are returned
-(void)queryTask: (AGSQueryTask*) queryTask operation:(NSOperation*)op didExecuteWithFeatureSetResult:(AGSFeatureSet*) featureSet
{
    [UIApplication showNetworkActivityIndicator:NO];
    //LandAttributeViewContrl.allFeatureSet = featureSet;
    //get feature, and load in to table
    for(int i=0; i<[featureSet.features count]; i++)
    {
        // 构造区域 
       // AGSSimpleRenderer* renderer = [AGSSimpleRenderer simpleRendererWithSymbol:composite];
        //graphicsLayer.renderer = renderer;
        
        /*
        AGSMutablePolygon *poly = [[AGSMutablePolygon alloc] initWithSpatialReference:[AGSSpatialReference spatialReferenceWithWKID:2383 WKT:nil]];
        [poly addRingToPolygon];
        [poly addPointToRing:[AGSPoint pointWithX:535000.0 y:2559000.0 spatialReference:nil]];
        [poly addPointToRing:[AGSPoint pointWithX:550000.0 y:2559000.0 spatialReference:nil]];
        [poly addPointToRing:[AGSPoint pointWithX:550000.0 y:2579000.0 spatialReference:nil]];
        [poly addPointToRing:[AGSPoint pointWithX:535000.0 y:2579000.0 spatialReference:nil]];
        [poly addPointToRing:[AGSPoint pointWithX:535000.0 y:2559000.0 spatialReference:nil]];
        */
        AGSSimpleFillSymbol *fillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        fillSymbol.style = AGSSimpleLineSymbolStyleSolid;
        fillSymbol.color = [UIColor orangeColor];
        AGSGraphic *gra = [featureSet.features objectAtIndex:i];
        gra.symbol = fillSymbol;
        [self.graphicsLayer addGraphic:gra];
        
        /* 测试用数据
        pointInfoTemplate *pointTemplate = [[pointInfoTemplate alloc] init];	
		AGSCompositeSymbol* compositeNoSel = [self GetSymbolByFlag:NO];
        
        ////////////
        AGSGraphic *gra = [featureSet.features objectAtIndex:i];
        NSArray *polys = [self Get3TestPolygons];
        //int nCnt = [polys count];
        AGSMutablePolygon *polyTmp;
        for (polyTmp in polys) 
        {
            AGSGraphic *GraphicOne = [[AGSGraphic alloc] initWithGeometry:polyTmp symbol:compositeNoSel attributes:nil infoTemplateDelegate:pointTemplate];
            [GraphicOne setAttributes:[gra attributes]];
            
            [SelectedGraphics addObject:GraphicOne];
            [self.graphicsLayer addGraphic:GraphicOne];
            [GraphicOne release];
        }
        */
        
        ///////////
        /*
        AGSGraphic *gra = [featureSet.features objectAtIndex:i];
        AGSGraphic *GraphicOne = [[AGSGraphic alloc] initWithGeometry:[gra geometry] symbol:compositeNoSel attributes:nil infoTemplateDelegate:pointTemplate];
        [GraphicOne setAttributes:[gra attributes]];

        // convert number to string operation
//        NSNumber * nVal = [[gra attributes] valueForKey:@"OBJECTID"];
//        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
//        NSString *Key = [numberFormatter stringFromNumber:nVal];
//        [numberFormatter release];
        
        [SelectedGraphics addObject:GraphicOne];
        [self.graphicsLayer addGraphic:GraphicOne];
        [poly release];
        [GraphicOne release];
         */
        /////////////////
    }
    [self.graphicsLayer dataChanged];
    
    // create  fullEnvelope
    
//    AGSEnvelope *Envelope1 = [AGSEnvelope envelopeWithXmin:530000.0 
//												 ymin:2554000.0 
//												 xmax:560500.0 
//												 ymax:2584500.0 
//									 spatialReference:nil];
    //[self.BaseMapView zoomToEnvelope:Envelope1 animated:YES];
	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"结果" 
												 message:[NSString stringWithFormat:@"搜索到%d个结果", featureSet.features.count] 
												delegate:self 
									   cancelButtonTitle:@"确定" 
									   otherButtonTitles:nil];
    //搜索结果为0个的时候不需要弹出LandAttributePopoverView
    if (featureSet.features.count == 0) {
        av.delegate = nil;
    }
	[av show];
	[av release];
    
    return;
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
//{
//    self.sketchLayer.geometry = nil;
//    [self.sketchLayer dataChanged];
//    float fWidth = 400.0f;
//    float fHeight = 500.0f;
//    float fXpos = 0.0f;
//    float fYpos = 748 / 2 - fHeight / 2;
//    CGRect frame2 = CGRectMake(fXpos, fYpos, fWidth, fHeight);
//    [_LandAttributePopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];       
//}

//if there’s an error with the query display it to the uesr 在Query失败后响应，弹出错误提示框
-(void)queryTask: (AGSQueryTask*)queryTask operation:(NSOperation*)op didFailWithError:(NSError*)error
{
    [UIApplication showNetworkActivityIndicator:NO];
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"错误" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    
    [alertView show];
    [alertView release];
}

//添加Mark
//要在图层加载之后才能执行此操作，否则Mark会不显示。
- (void)AddMarkData
{
    @try {
        for (DBMarkData *MarkData in SingleManager.MarkDic.allValues) {
            AGSSpatialReference *SpRe = nil;
            if ([MarkData.MarkSpatialReferenceWKID length] > 0) {
                SpRe = [AGSSpatialReference spatialReferenceWithWKID:MarkData.MarkSpatialReferenceWKID.intValue];
            }else {
                if ([MarkData.MarkSpatialReferenceWKT length] > 0) {
                    SpRe = [AGSSpatialReference spatialReferenceWithWKT:MarkData.MarkSpatialReferenceWKT];
                }else {
                    SpRe = nil;
                }
            }
            AGSPoint *mappoint = [AGSPoint pointWithX:MarkData.MarkCoordinateX.doubleValue y:MarkData.MarkCoordinateY.doubleValue spatialReference:SpRe];

            //AGSPoint *mappoint = MarkData.Point;
            AGSPictureMarkerSymbol *pt = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"MarkBlackPin.png"];
            pointInfoTemplate *pointTemplate = [[pointInfoTemplate alloc] init]; 
            DBAGSGraphic *pushpin = [[DBAGSGraphic alloc] initWithGeometry:mappoint symbol:pt attributes:nil infoTemplateDelegate:pointTemplate]; 
            pushpin.TypeFlg = 0; 
            pushpin.bIsHighlighted = NO;
            //设置标注ID
            pushpin.MarkID = MarkData.MarkID;
            [self.graphicsLayer addGraphic:pushpin];
            [pushpin release];
        }
        [self.graphicsLayer dataChanged];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
    return;
}

// 
- (void)layerDidFailToLoad:(NSError *) error
{
    return;
}

- (void)layerDidLoad
{
    return;
}

#pragma mark 检测是否有道路图层
//-----------------------------------
-(BOOL)GetTopDataMapLayerUrl
{
    //NSString *MapLayerUrl = nil;
    @try 
    {
        NSArray *mapLayers = [self.BaseMapView mapLayers];
        int nTotalCnt = [mapLayers count];
        for (int nCnt = nTotalCnt - 1; nCnt >= 0; nCnt--)
        {
            // 遍历所有图层
            id layerObj = [mapLayers objectAtIndex:nCnt];
            if([layerObj isKindOfClass:[AGSDynamicMapServiceLayer class]])
            {
                // 是专题图层的场合
                AGSDynamicMapServiceLayer *layer = (AGSDynamicMapServiceLayer*)layerObj;
                NSString *name = [layer name];
                NSRange range = [name rangeOfString:ROAD_MAPLAYER_NAME];
                if (range.location != NSNotFound )
                //if ([name isEqualToString:@"道路"])
                {
                    // 并且不是道理图层
                    //MapLayerUrl = [layer.URL absoluteString];
                    return YES;
                }
            }
        }
        return NO;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return NO;
    }
    @finally {
    }

}

#pragma mark -  专题图层加载
-(void)AddDataMapLayer
{
    ////////// 惠州业务图层
    @try {
        
        /*
        // 现状图层
        NSString *layerUrl = @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/ZWWZT/GTL_TDLYXZ/MapServer";
        //NSString *layerUrl2 = @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/ZWWZT/GTL_TDLYZTGH/MapServer";
        // 地价图层
        //NSString *layerUrl3 = @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/ZWWZT/GTL_CZJZDJ/MapServer/1";
        //AGSFeatureLayer *feaLayer = [[AGSFeatureLayer alloc] initWithURL:[NSURL URLWithString:layerUrl3] mode:nil];
        //NSURL* url = [NSURL URLWithString: layerUrl]; 	 
        //AGSFeatureLayer* featureLayer = [AGSFeatureLayer featureServiceLayerWithURL: url mode: AGSFeatureLayerModeOnDemand];
        AGSDynamicMapServiceLayer *MapDataLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:layerUrl]];
        //name the layer. This is the name that is displayed if there was a property page, tocs, etc...
        [self.BaseMapView addMapLayer:MapDataLayer withName:@"datalayer"];
        MapDataLayer = nil;
        //featureLayer = nil;
        
        return;
        */
        /*
        NSString *MapUrl = url.absoluteString;
        NSString *hostName = [url host];
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        bMapServerIsReachable = [DataMan GetHostNetStatus:hostName];
        */
        
        // 首先添加道路地名地址图层
        NSString *RoadMapUrl = [_BaseMapLayersDic valueForKey:ROAD_MAPLAYER_NAME];
        if ([RoadMapUrl length] > 0) 
        {
            // 
            NSURL * MapUrl = [NSURL URLWithString:[RoadMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            // 
            AGSDynamicMapServiceLayer *MapDataLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:MapUrl];
            
            //[MapDataLayer setRenderNativeResolution:YES];
            int nLayerCnt = [[self.BaseMapView mapLayers] count];
            if ([SingleManager.RoadDataMapLayerName length] <= 0) {
                SingleManager.RoadDataMapLayerName = ROAD_MAPLAYER_NAME;
            }
            
            [self.BaseMapView insertMapLayer:MapDataLayer withName:SingleManager.RoadDataMapLayerName atIndex:nLayerCnt - 2];
            [self.BaseMapView  bringSubviewToFront:self.GraphicsView];
            
            //[MapDataLayer release];
        }
//        if ([RoadMapUrl length] > 0) {
//            // 
//            NSURL* MapUrl = [NSURL URLWithString: RoadMapUrl];
//            // 
//            AGSDynamicMapServiceLayer *MapDataLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:MapUrl];
//            
//            //[MapDataLayer setRenderNativeResolution:YES];
//            int nLayerCnt = [[self.BaseMapView mapLayers] count];
//
//            [self.BaseMapView insertMapLayer:MapDataLayer withName:@"道路" atIndex:nLayerCnt - 2];
//            [self.BaseMapView  bringSubviewToFront:self.GraphicsView];
//            
//            [MapUrl release];
//        }
        
        int nTotalCnt = [SingleManager.MapLayerDataArray count];
        for (int nCnt = 0; nCnt < nTotalCnt; nCnt++) {
            NSString *nVal = [[SingleManager.MapLayerDataArray objectAtIndex:nCnt] DataLayerDisplay];
            if ([nVal isEqualToString:@"1"]) 
            {
                // 1表示当前图层打开状态
                NSString *layerUrl = [[SingleManager.MapLayerDataArray objectAtIndex:nCnt] MapUrl];
                
                //NSURL * MapUrl = [NSURL URLWithString:[layerUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                
                //AGSDynamicMapServiceLayer *layer = [[AGSDynamicMapServiceLayer alloc] initWithURL:MapUrl];
                AGSDynamicMapServiceLayer *layer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString: layerUrl]];
                
                //name the layer. This is the name that is displayed if there was a property page, tocs, etc...
                
                //AGSMapServiceInfo *info = [AGSMapServiceInfo mapServiceInfoWithURL:[NSURL URLWithString:layerUrl] error:&error];
                //AGSDynamicMapServiceLayer* layer = [[AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo: info] autorelease];
                
                NSString *layerName = [[SingleManager.MapLayerDataArray objectAtIndex:nCnt] Name];
                //[self.BaseMapView addMapLayer:layer withName:layerName];
                //[layer release];
                int nLayerCnt = [[self.BaseMapView mapLayers] count];
                [layer setRenderNativeResolution:YES];
                [self.BaseMapView insertMapLayer:layer withName:layerName atIndex:nLayerCnt - 2];
                //[layer release];
                [self.BaseMapView  bringSubviewToFront:self.GraphicsView];
            }
        }

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
    return;
}

// 创建popover
-(void)CreatePopoverViewControl
{
    @try {
//        _DataMapLayerNameArray = [[NSMutableArray alloc] initWithCapacity:0];
//        _DataMapLayerUrlArray = [[NSMutableArray alloc] initWithCapacity:0];
//        _DataMapLayerSwitchArray = [[NSMutableArray alloc] initWithCapacity:0];
        
        // 检测本地缓存中是否有配置文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        // 本地本地配置信息文件
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
        
        //需要在解析WebService之后，才能执行此操作。配置附件WebService。
        // 配置中不能获取下载地址时
        DBSeLayerPort* service = [DBSeLayerPort service];
        NSString *AnnexDownloadUrl = service.serviceUrl;
        if ([AnnexDownloadUrl length] <= 0) 
        {
            // 下载服务地址不对，请重新配置。
            [SingleManager CreateFailedAlertViewWithFailedInfo:@"下载错误" andWithMessage:@"下载服务地址不正确，请重新配置"];
        }
        else
        {
            if ([SingleManager.AnnexDownloadServiceUrl length] <= 0) {
                NSURL *webSerURL = [[NSURL alloc] initWithString:[AnnexDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                NSString *hostName = [webSerURL host];
                NSNumber *port = [webSerURL port];
                NSString *strPort = [port stringValue];
                NSString *preUrl = [NSString stringWithFormat:@"http://%@:%@/SunzDeci/convention/annexInfoAction_getDownloadFile.action?", hostName, strPort];
                SingleManager.AnnexDownloadServiceUrl = preUrl;
                [webSerURL release];
                [self UpdateWebServiceUrl];
            }

        }
//        NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
//        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:xmlFilePath];
//        [self parsedDataMapLayerFromData:xmlData];
//        [xmlData release];
        
        DataMapLayerViewContrl = [[DBDataMapLayerViewController alloc] init];	
        [DataMapLayerViewContrl setSwitchDelgate:self];
        _DataMapLayerViewPopover = [[UIPopoverController alloc] initWithContentViewController:DataMapLayerViewContrl];
        _DataMapLayerViewPopover.delegate = self;
        //passthroughViews
        NSArray *InteractionViews = [NSArray arrayWithObjects:[self view], nil];
        [_DataMapLayerViewPopover setPassthroughViews:InteractionViews];
        
        // 根据当前模块类型分别处理
        if ([self nModelFlg] == 1)
        {// 会议议题模块
            //设置会议popover view
            MeetingView = [[DBMeetingViewController alloc] init];
            [MeetingView setMainView:self.view];
            [MeetingView setSuperViewCtrl:self];
            _MeetingViewPopover = [[UIPopoverController alloc] initWithContentViewController:MeetingView];
            [MeetingView release];
            _MeetingViewPopover.delegate = self;
            [_MeetingViewPopover setPassthroughViews:InteractionViews];
        }

        self.QueryMenuViewCtrl = [[DBQueryMenuViewController alloc] init];
        [self.QueryMenuViewCtrl setMapLayerQueryDeg:self];
        self.QueryMenuPopoverView = [[UIPopoverController alloc] initWithContentViewController:self.QueryMenuViewCtrl];
        [self.QueryMenuPopoverView setDelegate:self];
        [self.QueryMenuPopoverView setPassthroughViews:InteractionViews];
        
        //最近搜索
        // init bookmark 
        [BookMarkManager InitBookMarksDataSet];
        
        //DBLatelySearchViewContrl = [[DBLatelySearchViewController alloc] init];
        DBLatelySearchViewContrl = [[DBLatelySearchOrPOIViewController alloc] init];
        [DBLatelySearchViewContrl setNDataSourceFlg:0];
        [DBLatelySearchViewContrl setDelegate:self];
        UINavigationController * nav2= [[UINavigationController alloc] initWithRootViewController:DBLatelySearchViewContrl];
        [DBLatelySearchViewContrl release];
        // 最近搜索popover view
        _LatelySearchViewPopover = [[UIPopoverController alloc] initWithContentViewController:nav2];
        [nav2 release];
        _LatelySearchViewPopover.delegate = self;
        //passthroughViews
        [_LatelySearchViewPopover setPassthroughViews:InteractionViews];
        _filteredListContent = [[NSMutableArray alloc] initWithCapacity:5];
        [DBLatelySearchViewContrl setSearchedDataArray:_filteredListContent];
        
        // 根据当前模块类型分别处理
        //if ([self nModelFlg] == 1)
        {// 会议议题模块
            // graphic attribute popover view
            DBAttributeViewContrl = [[DBAttributeViewController alloc] init];
            [DBAttributeViewContrl setDelegate:self];
            _GraphicAttPopoverView = [[UIPopoverController alloc] initWithContentViewController:DBAttributeViewContrl];
            _GraphicAttPopoverView.popoverContentSize = CGSizeMake(260, 360);
            _GraphicAttPopoverView.delegate = self;
            //[_GraphicAttPopoverView setPassthroughViews:InteractionViews];
        }

              
        //AllConf popover view
        AllConfViewContrl = [[DBAllConfViewController alloc] init];
        AllConfViewContrl.delegate = self;
        AllConfViewContrl.BaseMapLayersDic = _BaseMapLayersDic;
        UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:AllConfViewContrl];  
        [AllConfViewContrl release];
        _AllConfPopoverView = [[UIPopoverController alloc] initWithContentViewController:nav3];
        [nav3 release];
        [_AllConfPopoverView setPassthroughViews:InteractionViews];
        _AllConfPopoverView.popoverContentSize = CGSizeMake(300, 390);
        _AllConfPopoverView.delegate = self;
        
        // 根据当前模块类型分别处理
        //if ([self nModelFlg] == 1)
        {// 会议议题模块
            //LandData popover view
            LandDataViewContrl = [[DBLandDataViewController alloc] init];
            LandDataViewContrl.delegate = self;
            UINavigationController *nav4 = [[UINavigationController alloc] initWithRootViewController:LandDataViewContrl];
            [LandDataViewContrl release];
            _LandDataPopoverView = [[UIPopoverController alloc] initWithContentViewController:nav4];
            [nav4 release];
            _LandDataPopoverView.popoverContentSize = CGSizeMake(240, 450);
            _LandDataPopoverView.delegate = self;
            [_LandDataPopoverView setPassthroughViews:InteractionViews];
            
            //LandAttribute PopoverView
            LandAttributeViewContrl = [[DBLandAttributeViewController alloc] init];
            LandAttributeViewContrl.delegate = self;
            UINavigationController *nav5 = [[UINavigationController alloc] initWithRootViewController:LandAttributeViewContrl];
            [LandAttributeViewContrl release];
            _LandAttributePopoverView = [[UIPopoverController alloc] initWithContentViewController:nav5];
            [nav5 release];
            _LandAttributePopoverView.popoverContentSize = CGSizeMake(365, 280);
            _LandAttributePopoverView.delegate = self;
            [_LandAttributePopoverView setPassthroughViews:InteractionViews];
        }
        
//        if (self.nModelFlg == 2)
//        {
//            // 设置巡察地块Popover view
//            DBXCDKListViewCtrl = [[DBXCDKListViewController alloc] init];
//            [DBXCDKListViewCtrl setDelegate:self];
//            UINavigationController *nav6 = [[UINavigationController alloc] initWithRootViewController:DBXCDKListViewCtrl];
//            _XCDKListViewPopover = [[UIPopoverController alloc] initWithContentViewController:nav6];
//            _XCDKListViewPopover.delegate = self;
//            [_XCDKListViewPopover setPassthroughViews:InteractionViews];
//        }
        
        
        //我的标注
        MarkListViewContrl = [[DBMarkListViewController alloc] init];
        MarkListViewContrl.delegate = self;
        MarkListPopoverView = [[UIPopoverController alloc] initWithContentViewController:MarkListViewContrl];
        [MarkListViewContrl release];
        MarkListPopoverView.delegate = self;
        [MarkListPopoverView setPassthroughViews:InteractionViews];
        
        /*
        //LandAnalysePopoverView PopoverView
        DBLandAnalyseViewContrl = [[DBLandAnalyseViewController alloc] init];
        DBLandAnalyseViewContrl.delegate = self;
        UINavigationController *nav6 = [[UINavigationController alloc] initWithRootViewController:DBLandAnalyseViewContrl];
        [DBLandAnalyseViewContrl release];
        _LandAnalysePopoverView = [[UIPopoverController alloc] initWithContentViewController:nav6];
        [nav6 release];
        _LandAnalysePopoverView.popoverContentSize = CGSizeMake(650, 400);
        _LandAnalysePopoverView.delegate = self;
        [_LandAnalysePopoverView setPassthroughViews:InteractionViews];
        */
        
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
    return;
}

//-------------------------------------------------------
// 分析结果显示视图创建
-(void)CreateLandAnalyseViewContrl
{
    // 创建视图控制器
    DBLandAnalyseViewContrl = nil;
    DBLandAnalyseViewContrl = [[DBLandAnalyseViewController alloc] init];
    DBLandAnalyseViewContrl.delegate = self;
    
    // 创建导航栏
    UINavigationController *nav6 = [[UINavigationController alloc] initWithRootViewController:DBLandAnalyseViewContrl];
    [DBLandAnalyseViewContrl release];
    
    // 创建内容显示Popover视图
    _LandAnalysePopoverView = nil;
    _LandAnalysePopoverView = [[UIPopoverController alloc] initWithContentViewController:nav6];
    [nav6 release];
    _LandAnalysePopoverView.popoverContentSize = CGSizeMake(650, 400);
    _LandAnalysePopoverView.delegate = self;
    
    // 设置可交互视图s
    NSArray *InteractionViews = [NSArray arrayWithObjects:[self view], nil];
    [_LandAnalysePopoverView setPassthroughViews:InteractionViews];
}
//-------------------------------------------------------
// 分析结果显示视图销毁
-(void)DestroyLandAnalyseViewContrl
{
    [_LandAnalysePopoverView dismissPopoverAnimated:NO];
    [_LandAnalysePopoverView release];
    _LandAnalysePopoverView = nil;
}

#pragma mark -  viewDidLoad
//-------------------------------------------------------
- (void)viewDidLoad
{
    @try {
        [super viewDidLoad];
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        
        [self setNModelFlg:1];
        
        // 根据配置决定是否显示此按钮
        SingleManager = [DBLocalTileDataManager instance];
        SingleManager.delegate = self;
        
        if ([self nModelFlg] == 2) {
//            // 追加国土巡察按钮
//            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//            btn.frame = CGRectMake(221, 5, 80, 30);
//            [btn setTag:101];
//            [btn setBackgroundImage:[UIImage imageNamed:@"BlackButton.png"] forState:UIControlStateNormal];
//            //[btn setTitle:@"批后监管" forState:UIControlStateNormal];
//            btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
//            UIColor *color = [UIColor colorWithRed:189.f/255.f green:200.f/255.f blue:238.f/255.f alpha:0];
//            [btn.titleLabel setTextColor:color];
//            [btn.titleLabel setText:@"批后监管"];
//            
//            [btn addTarget:self action:@selector(GTXCBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
//            [TopToolBarView addSubview:btn];
            
            [self.SubjectBtn setTitle:@"批后监管" forState:UIControlStateNormal];
            CGRect fram2 = CGRectMake([self.SubjectBtn frame].origin.x, [self.SubjectBtn frame].origin.y, 80, 30);
            [self.SubjectBtn setFrame:fram2];
            
        }
        else{
            [self.SubjectBtn setTitle:@"议题" forState:UIControlStateNormal];
            CGRect fram2 = CGRectMake([self.SubjectBtn frame].origin.x, [self.SubjectBtn frame].origin.y, 50, 30);
            [self.SubjectBtn setFrame:fram2];
        }
        [self.XianZhuangBtn setHidden:YES];
        //[self.SearchBarCtrl setHidden:YES];
        
        
        
        [TopDataDisplayImageView setHidden:YES];
        // Do any additional setup after loading the view, typically from a nib.
        //init SingleManager

        //[self CreateWaitingView];
        //init LastClickbutton and LastBtnImageArray
        LastClickButton = nil;
        UIImage *image0 = [UIImage imageNamed:@"PlanTopBtn.png"];
        UIImage *image1 = [UIImage imageNamed:@"NowStatusTopBtn.png"];
        UIImage *image2 = [UIImage imageNamed:@"PriceTopBtn.png"];
        UIImage *image3 = [UIImage imageNamed:@"InformationTopBtn.png"];
        UIImage *image4 = [UIImage imageNamed:@"MeasureLength.png"];
        UIImage *image5 = [UIImage imageNamed:@"measureArea.png"];
        self.LastBtnImageArray = [NSArray arrayWithObjects:image0, image1, image2, image3, image4, image5, nil];
        
        
        // set the delegate for the map view
        // data init
        _BaseMapView.touchDelegate = self;
        nMeasureFlag = 0;
        bIsXianZhuangBtnTouched = NO;
        bIsPlanBtnTouched = NO;
        bIsPriceBtnTouched = NO;
        bIsInfoBtnTouched = NO;
        bIsMeasureDataCalcuate= NO;
        //// parase basemap begin
        _BaseMapLayersDic = [[NSMutableDictionary alloc] initWithCapacity:3];
        
        // 检测本地缓存中是否有配置文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        // 本地本地配置信息文件
        NSString *path = [documentsDirectory stringByAppendingPathComponent:@"DBConfigure.xml"];
        //本地标注信息文件
        NSString *MarkInfoPath = [documentsDirectory stringByAppendingPathComponent:@"DBMarkInfo.xml"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:path];
        if (!bRet) {
            // 本地无此文件，则将此文件拷贝到本地目录。
            NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
            NSError *err;
            [fileMgr copyItemAtPath:xmlFilePath toPath:path error:&err];
        }
        BOOL bRet2 = [fileMgr fileExistsAtPath:MarkInfoPath];
        if (!bRet2) {
            // 本地无此文件，则将此文件拷贝到本地目录。
            NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBMarkInfo" ofType:@"xml"];
            NSError *err;
            [fileMgr copyItemAtPath:xmlFilePath toPath:MarkInfoPath error:&err];
        }
        
        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:path];
        [self parsedBaseMapLayerFromData:xmlData];
        [xmlData release];
        //解析标注信息
        NSData *xmlData2 = [[NSData alloc] initWithContentsOfFile:MarkInfoPath];
        [self parsedMarkInfoFromData:xmlData2];
        [xmlData2 release];
//        NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
//        NSData *xmlData = [[NSData alloc] initWithContentsOfFile:xmlFilePath];
//        [self parsedBaseMapLayerFromData:xmlData];
//        [xmlData release];
        //// parase basemap end
        
        CGRect frame = CGRectMake(0, 0, 220.0, 200.0);
        self.PriceViewController = [[[DBCustomPriceViewController alloc] initWithFrame:frame] autorelease];
        frame = CGRectMake(0, 0, 260.0, 300.0);
        self.LandInfoViewContrl = [[[DBLandInfoViewController alloc] initWithFrame:frame] autorelease];
        //标注信息显示
        frame = CGRectMake(0, 0, 300.0, 180.0);
        self.MarkNoteViewContrl = [[[DBMarkNoteViewController alloc] initWithFrame:frame] autorelease];
        self.MarkNoteViewContrl.delegate = self;
        /* 坐标转换测试
         AGSGeometryEngine *geoEngine = [AGSGeometryEngine defaultGeometryEngine];
         AGSSpatialReference *SpaRef = [AGSSpatialReference spatialReferenceWithWKID:4326];
         AGSSpatialReference *SpaRef2 = [AGSSpatialReference spatialReferenceWithWKID:2383];
         AGSPoint *pt1 = [AGSPoint pointWithX:2519917.108807 y:538708.643663 spatialReference:SpaRef2];
         AGSPoint *prjPt = [geoEngine projectGeometry:pt1 toSpatialReference:SpaRef];
         */
        
        // data init
        SelectedGraphics = [[NSMutableArray alloc] initWithCapacity:3];
        
//        //////////////////// popover view create begin
//        [Logger OutputTimeLog];
//        [self CreatePopoverViewControl];
//        [Logger OutputTimeLog];
        
//        [_SearchBarCtrl setBackgroundColor:[UIColor clearColor]];
//        UIImage * image = [UIImage imageNamed:@"TopBarBackground.png"];
//        [_SearchBarCtrl setBackgroundImage:image];
//        image = nil;
        [_SearchBarCtrl setPlaceholder:@"关键字查询"];
        _SearchBarCtrl.delegate = self;
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self; // send loc updates to myself
        self.locationManager.distanceFilter = 1;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        
        _BaseMapView.layerDelegate = self;
        self.BaseMapView.touchDelegate = self;
        self.BaseMapView.calloutDelegate = self;
/* move to ViewDidApper
        // add base map layer begin
        NSEnumerator *enumerator = [_BaseMapLayersDic keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) 
        {
            NSString * layerName = (NSString*)key;
            NSString *layerUrl = [_BaseMapLayersDic objectForKey:layerName];
            //AGSTiledMapServiceLayer *tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:layerUrl]];
            //OfflineableTiledMapServiceLayer *tiledLayer = [[OfflineableTiledMapServiceLayer alloc] CustomInitWithURL:[NSURL URLWithString:layerUrl]];
            
            //OfflineableTiledMapServiceLayer* tiledLayer = [[[OfflineableTiledMapServiceLayer alloc] initWithDataFramePath:[NSURL URLWithString:layerUrl] error:nil] autorelease];
            
            OfflineableTiledMapServiceLayer *tiledLayer = [[OfflineableTiledMapServiceLayer alloc] initWithDataFramePath:[NSURL URLWithString:layerUrl] error:nil];
            
            
            UIView<AGSLayerView>* lyr = [self.BaseMapView addMapLayer:tiledLayer withName:BASEMAPLAYER_NAME];
            [tiledLayer release];
            lyr.drawDuringPanning = YES;
            lyr.drawDuringZooming = YES;
            //[tiledLayer setTileDelegate:self];
            
            break;
        }
*/
        
        /*
         AGSTiledMapServiceLayer *tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:kTiledMapServiceURL_0]];
         [tiledLayer setTileDelegate:self];
         UIView<AGSLayerView>* lyr = [self.BaseMapView addMapLayer:tiledLayer withName:BASEMAPLAYER_NAME];
         tiledLayer = nil;
         //NSArray *layersarr = [self.BaseMapView mapLayers];
         // Setting these two properties lets the map draw while still performing a zoom/pan
         lyr.drawDuringPanning = YES;
         lyr.drawDuringZooming = YES;
         */
        // add base map layer end
/* move to viewDidApper function        
        // 添加业务图层
        [self AddDataMapLayer];
        
        // base map switch view
        CGFloat fWidth = 1024.0f;
        CGFloat fHeight = 700.0f;
        CGFloat xPos = 0.0f;
        CGFloat yPos = 100.0f;
        _BaseMapSwitchView = [[DBBaseMapSwitchView alloc] initWithFrame:CGRectMake(xPos, yPos, fWidth, fHeight)];
        [_BaseMapSwitchView setMapConfDelegate:self];
        [self.MapContainterView insertSubview:_BaseMapSwitchView belowSubview:_BaseMapView];
        isCurl=NO;
        
        // 查询显示图层
        self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
        self.GraphicsView = [self.BaseMapView addMapLayer:self.graphicsLayer withName:@"graphicsLayer"];
        [self.GraphicsView setHidden:NO];
        
        ////
        //NSString *countiesLayerURL = kQueryMapServiceLayerURL4;
        
        //set up query task against layer, specify the delegate
        self.queryTask = [AGSQueryTask queryTaskWithURL:[NSURL URLWithString:kQueryMapServiceLayerURL4]];
        self.queryTask.delegate = self;
        
        //return all fields in query 
        self.query = [AGSQuery query];
        self.query.outFields = [NSArray arrayWithObjects:@"*", nil];
        self.query.returnGeometry = YES;
        
        //////
        _sketchLayer = [[[AGSSketchGraphicsLayer alloc] initWithGeometry:nil] autorelease];
        [self.BaseMapView addMapLayer:_sketchLayer withName:@"Sketch layer"]; 
        [self.BaseMapView setWrapAround:YES];
*/
        [self InitResoure];
        
        // add by niurg 2015.9
        // 根据配置决定是否显示此按钮
        SingleManager = [DBLocalTileDataManager instance];
        SingleManager.delegate = self;
        if([[SingleManager HistoryMeetingBtnShowConf] isEqualToString:@"0"])
        {
            // show
            [_historySubjectMenuBtn setHidden:YES];
        }
        else{
            // hide
            [_historySubjectMenuBtn setHidden:NO];
        }
        
        // 根据配置文件里的配置设置专题按钮的名称和url地址
        NSDictionary *confDic = [SingleManager topBarBtnConfDic];
        
        // 土规按钮名称设置
        NSDictionary *btnConfDic = [confDic objectForKey:top_Bar_Btn_tuGui];
        NSString *menuBtnName = [btnConfDic valueForKey:top_Bar_Btn_menuBtnName];
        [self.tuGuiMenuBtn setTitle:menuBtnName forState:UIControlStateNormal];
        [self.tuGuiMenuBtn setTitle:menuBtnName forState:UIControlStateSelected];
        
        // 城规按钮名称设置
        btnConfDic = [confDic objectForKey:top_Bar_Btn_chengGui];
        menuBtnName = [btnConfDic valueForKey:top_Bar_Btn_menuBtnName];
        [self.chengGuiMenuBtn setTitle:menuBtnName forState:UIControlStateNormal];
        [self.chengGuiMenuBtn setTitle:menuBtnName forState:UIControlStateSelected];
        
        // 路网按钮名称设置
        btnConfDic = [confDic objectForKey:top_Bar_Btn_luWang];
        menuBtnName = [btnConfDic valueForKey:top_Bar_Btn_menuBtnName];
        [self.luWangMenuBtn setTitle:menuBtnName forState:UIControlStateNormal];
        [self.luWangMenuBtn setTitle:menuBtnName forState:UIControlStateSelected];
        
        // 发证按钮名称设置
        btnConfDic = [confDic objectForKey:top_Bar_Btn_faZheng];
        menuBtnName = [btnConfDic valueForKey:top_Bar_Btn_menuBtnName];
        [self.faZhengMenuBtn setTitle:menuBtnName forState:UIControlStateNormal];
        [self.faZhengMenuBtn setTitle:menuBtnName forState:UIControlStateSelected];
        
        // end
        
        [self TopTipViewAnimatedDissapper];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
    
    return;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self SetPopoerHiden];
}

#define marign_width 90.f
-(void)TopTipViewAnimatedApper
{
    @try {
        CGRect frame = [TopDataDisplayImageView frame];
        float orgHeight = 22.0f;
        frame.size.height = 0.0f;
        [TopDataDisplayImageView setFrame:frame];
        CGRect frame2 = [TopDataDisplayImageView frame];
        float orgHeight2 = 22.0f;
        frame2.size.height = 0.0f;
        
        frame2.size.width -= marign_width;
        frame2.origin.x += marign_width / 2;
        
        [TopDataDisplayLabel setFrame:frame2];
        CGRect frame3 = [TopAddMesureBtn frame];
        float orgHeight3 = 37.f;
        frame3.size.height = 0.0f;
        [TopAddMesureBtn setFrame:frame3];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.4];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [TopDataDisplayImageView setHidden:NO];
        [TopDataDisplayImageView setAlpha:1];
        [TopDataDisplayLabel setAlpha:1];
        //[TopAddMesureBtn setAlpha:1];
        TopAddMesureBtn.hidden = YES;
        frame.size.height = orgHeight;
        [TopDataDisplayImageView setFrame:frame];
        frame2.size.height = orgHeight2;
        [TopDataDisplayLabel setFrame:frame2];
        frame3.size.height = orgHeight3;
        [TopAddMesureBtn setFrame:frame3];
        [UIView commitAnimations];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

    return;
}

-(void)TopTipViewAnimatedDissapper
{
    @try {
        // 窗口动画消失 begin
        CGRect frame = [TopDataDisplayImageView frame];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [TopDataDisplayImageView setAlpha:0];
        [TopDataDisplayLabel setAlpha:0];
        
        //[TopAddMesureBtn setAlpha:0];
        [TopAddMesureBtn setHidden:YES];
        CGRect frame3 = [TopAddMesureBtn frame];
        frame3.size.height = 0.0f;
        [TopAddMesureBtn setFrame:frame3];
        
        frame.size.height = 0.0f;
        [TopDataDisplayImageView setFrame:frame];
        [UIView commitAnimations];
        // 窗口动画消失 end
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

    return;
}

#pragma mark -  底图加载
-(void)InitResoure
{
    // add base map layer begin
    _LandAnalyseGeometryQueue = [[DBQueue alloc] init];
    //[self WaitingViewDisAppear];
    NSEnumerator *enumerator = [_BaseMapLayersDic keyEnumerator];
    id key;
    while ((key = [enumerator nextObject])) 
    {
        NSString * layerName = (NSString*)key;
        NSString *layerUrl = [_BaseMapLayersDic objectForKey:layerName];
        //AGSTiledMapServiceLayer *tiledLayer = [[[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:layerUrl]] autorelease];
        //OfflineableTiledMapServiceLayer *tiledLayer = [[OfflineableTiledMapServiceLayer alloc] CustomInitWithURL:[NSURL URLWithString:layerUrl]];
        
        //OfflineableTiledMapServiceLayer* tiledLayer = [[OfflineableTiledMapServiceLayer alloc] initWithDataFramePath:[NSURL URLWithString:kTiledMapServiceURL_3] error:nil];
        
        NSURL *webURL = [[NSURL alloc] initWithString:[layerUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
//        OfflineableTiledMapServiceLayer *tiledLayer = [[[OfflineableTiledMapServiceLayer alloc] initWithDataFramePath:webURL error:nil] autorelease];
        AGSTiledMapServiceLayer *tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:webURL];
        [webURL release];
        
        //OfflineableTiledMapServiceLayer *tiledLayer = [[[OfflineableTiledMapServiceLayer alloc] initWithDataFramePath:[NSURL URLWithString:layerUrl] error:nil] autorelease];
        
        //NSError *error = nil; 
        //AGSMapServiceInfo *info = [AGSMapServiceInfo mapServiceInfoWithURL:[NSURL URLWithString:layerUrl] error:&error];
        
        //AGSDynamicMapServiceLayer* layer = [[AGSDynamicMapServiceLayer dynamicMapServiceLayerWithMapServiceInfo: info] autorelease];
        //AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithMapServiceInfo:info];
        [tiledLayer setRenderNativeResolution:YES];
        //[tiledLayer setDelegate:nil];
        UIView<AGSLayerView>* lyr = [self.BaseMapView addMapLayer:tiledLayer withName:BASEMAPLAYER_NAME];
        [tiledLayer release];
        lyr.drawDuringPanning = YES;
        lyr.drawDuringZooming = YES;
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        [DataMan setCurrentBaseMapUrl:layerUrl];
        break;
    }
    
    // base map switch view
    CGFloat xPos = 0.0f;
    CGFloat yPos = 100.0f;
    CGFloat fWidth = 1024.0f;
    CGFloat fHeight = 700.0f;
    _BaseMapSwitchView = [[DBBaseMapSwitchView alloc] initWithFrame:CGRectMake(xPos, yPos, fWidth, fHeight)];
    [_BaseMapSwitchView setMapConfDelegate:self];
    [self.MapContainterView insertSubview:_BaseMapSwitchView belowSubview:_BaseMapView];
    isCurl=NO;
    
    // 查询显示图层
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.graphicsLayer setRenderNativeResolution:YES];
    self.GraphicsView = [self.BaseMapView addMapLayer:self.graphicsLayer withName:@"graphicsLayer"];
    [self.GraphicsView setHidden:NO];
    
    // 根据当前模块类型分别处理
    //if ([self nModelFlg] == 1)
    {// 会议议题模块
        ////
        //NSString *countiesLayerURL = kQueryMapServiceLayerURL4;
        
        //set up query task against layer, specify the delegate
        //self.queryTask = [AGSQueryTask queryTaskWithURL:[NSURL URLWithString:kQueryHuiZhouLandXianZhuang]];
        self.queryTask = [AGSQueryTask queryTaskWithURL:[NSURL URLWithString:[kQueryHuiZhouLandXianZhuang stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        self.queryTask.delegate = self;
        
        //return all fields in query
        self.query = [AGSQuery query];
        self.query.outFields = [NSArray arrayWithObjects:@"*", nil];
        self.query.returnGeometry = YES;
    }
    
    //////
    _sketchLayer = [[AGSSketchGraphicsLayer alloc] initWithGeometry:nil];
    //AGSCompositeSymbol *comSym = [self GetSymbolByFlag:NO];
    //[_sketchLayer setMainSymbol:comSym];
    [_sketchLayer setRenderNativeResolution:YES];
    [self.BaseMapView addMapLayer:_sketchLayer withName:@"Sketch layer"]; 
    [_sketchLayer release];
    [self.BaseMapView setWrapAround:YES];
    //////////////////// popover view create begin
    [Logger OutputTimeLog];
    [self CreatePopoverViewControl];
    [Logger OutputTimeLog];
    //////////////////// popover view create end
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
     BOOL bNetConn = [DataMan InternetConnectionTest];
    // 根据当前模块类型分别处理
    if ([self nModelFlg] == 1)
    {// 会议议题模块
        [self BtnHideSet:NO];
        //从配置文件解析会议数据
        if (NO) {
            [DataMan ParseAllMeetingData:nil];
        }
        else {
            if (bNetConn)
            {
                // 网络连接状态
                //下载所有的会议
                [DataMan DownLoadMeetingData:@""];
            }
        }
    }
    else
    {// 巡察监管模块
        [self BtnHideSet:YES];
    }
    
    //===================
    // 加载专题图层处理
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DBMapLayerData.xml"];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    if (bNetConn)
    {
        //得到图层文件
        if (data == nil) {
            //下载图层数据
            [DataMan DownLoadMapLayerData:@""];
        }else {
            [DataMan ParseMapLayerData:data];
            // 添加业务图层
            [self AddDataMapLayer];
            [self AddMarkData];
        }
    }
    else
    {
        // Wifi或3G网络不可用
        if (data != nil){
            [DataMan ParseMapLayerData:data];
            // 添加业务图层
            [self AddDataMapLayer];
            [self AddMarkData];
        }
    }
    //===================
    
    // add 2015.11.22
    NSString *departmentName = [DataMan departmentNameConf];
    if (departmentName.length > 0) {
        [_departmentNameLabel setText:departmentName];
    }
    else{
        [_departmentNameLabel setText:@"国土资源局"];
    }
    // end
    
    return;
}

-(void)BtnHideSet:(BOOL)bVal
{
    return;
    [_PlanBtn setHidden:bVal];
    [_XianZhuangBtn setHidden:bVal];
    [_ViewInfoBtn setHidden:bVal];
    [_ViewPriceBtn setHidden:bVal];
}

- (void)viewDidUnload
{
    [self setSearchBarCtrl:nil];

    [self setBaseMapSwitchBtn:nil];
    [self setMapContainterView:nil];
    [self setBaseMapView:nil];
    [self setMapLocationBtn:nil];
    [TopToolBarView release];
    TopToolBarView = nil;
    [TopDataDisplayLabel release];
    TopDataDisplayLabel = nil;
    [TopDataDisplayImageView release];
    TopDataDisplayImageView = nil;
    [LengthBtn release];
    LengthBtn = nil;
    [AreaBtn release];
    AreaBtn = nil;
    [TopAddMesureBtn release];
    TopAddMesureBtn = nil;
    [self setSubjectBtn:nil];
    [self setViewInfoBtn:nil];
    [self setViewPriceBtn:nil];
    [self setPlanBtn:nil];
    [self setXianZhuangBtn:nil];
    [self setPolygonBtn:nil];
    [self setPolygonLineBtn:nil];
    self.QueryMenuPopoverView = nil;
    self.QueryMenuViewCtrl = nil;
    [super viewDidUnload];
    [self.locationManager stopUpdatingLocation];
    _isUpdatingLocation = NO;
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if((UIInterfaceOrientationLandscapeLeft == interfaceOrientation) || (UIInterfaceOrientationLandscapeRight == interfaceOrientation))
    {
        return YES;
    }
    return NO;
}

- (void)viewDidDisappear:(BOOL)animated{
    DBLocalTileDataManager *dataManager = [DBLocalTileDataManager instance];
    dataManager.delegate = nil;
    dataManager.FooterDelegate = nil;
    dataManager.LocalDelegate = nil;
    dataManager.MapLayerDelegate = nil;
    dataManager.MeetingDelegate = nil;
    dataManager.XCDKDelegate = nil;
    dataManager.XCDKRecordsDelegate = nil;
    dataManager.XCDKUploadDelegate = nil;
    dataManager.TopicDKDataQueryDelegate = nil;
    dataManager.TopicDKReloadDelegate = nil;
    dataManager.DataLayerFieldReloadDe = nil;
    dataManager.XCDKDownloadDeg = nil;
    dataManager.DBDKInfoQueryDeg = nil;

    [super viewDidDisappear:animated];
}

- (void)dealloc {
    [self.LandAnalyseGeometryQueue release];
        
    if ([self nModelFlg] == 1)
    {
        [self.MeetingView release];
    }
    [_filteredListContent release];
    //[BookMarkManager Release];
    
    [DBAttributeViewContrl release];
    [self.geometryArray release];
    [self.pushpins release];
	[self.gst release];
    
    [SelectedGraphics release];
    
    [self.GraphicsView release];
   
    [self.DataMapLayerViewPopover release];
    [self.MeetingViewPopover release];
    
    [self.LatelySearchViewPopover release];
    [self.GraphicAttPopoverView release];
    [self.AllConfPopoverView release];
    [self.BaseMapLayersDic release];
    [self.layerNameArr release];
    [self.IndexArr release];
    [self.LastBtnImageArray release];
    [self.beginPoint release];
    [self.endPoint release];
    
    [_SearchBarCtrl release];
    [_BaseMapSwitchBtn release];
    [_MapContainterView release];
    [_BaseMapView release];
    [_MapLocationBtn release];
    [TopToolBarView release];
    [TopDataDisplayLabel release];
    [TopDataDisplayImageView release];
    [LengthBtn release];
    [AreaBtn release];
    [self.LandDataPopoverView release];
    [self.LandAttributePopoverView release];
    [self.SingleManager release];
    [self.SubjectDataView release];
    [self.SubjectView release];
    [self.MarkListPopoverView release];
    
    [TopAddMesureBtn release];
    [_SubjectBtn release];
    [_ViewInfoBtn release];
    [_ViewPriceBtn release];
    [_PlanBtn release];
    [_XianZhuangBtn release];
    
//    if ([self nModelFlg] != 1)
//    {
//        [self.XCDKListViewPopover release];
//        
//        [self.DBXCDKDetailViewCtrl release];
//        
//        [self.XCDKDataView release];
//        
//        [self.DBXCGeometryNamePopoverView release];
//    }
    [self.QueryMenuViewCtrl release];
    [self.QueryMenuPopoverView release];
    [_PolygonBtn release];
    [_PolygonLineBtn release];
    [_historySubjectMenuBtn release];
    [_MapTypeSegCtrl release];
    [_MapLayerBtn release];
    [_MapToolsBtn release];
    [_MapConfBtn release];
    [_tuGuiMenuBtn release];
    [_chengGuiMenuBtn release];
    [_luWangMenuBtn release];
    [_faZhengMenuBtn release];
    [_SearchBarCtrl release];
    [_departmentNameLabel release];
    [_MapToolsBtn2 release];
    [_MapLayerBtn2 release];
    [_MapYingXiangBtn release];
    [_MapCommonBtn release];
    [_MapMixedBtn release];
    [super dealloc];
}

#pragma mark Custom methods

-(void) clearGraphicsBtnClicked:(id)sender {
	
	// remove previously buffered geometries
	[self.geometryArray removeAllObjects];
    
	// clear the graphics layer
	[self.graphicsLayer removeAllGraphics];
	
	// tell the graphics layer that we have modified graphics
	// and it needs to be redrawn
	[self.graphicsLayer dataChanged];
	
	// reset the number of clicked points
	_numPoints = 0;
	
    // clear the sketchLayer
    self.sketchLayer.geometry = nil;
    [self.sketchLayer dataChanged];
	// reset our "directions" label
	//self.statusLabel.text = @"Click points to buffer around";
}

- (IBAction)BackBtnTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
-(void) goBtnClicked:(id)sender 
{

    // Make sure the user has clicked at least 1 point
    if ([self.geometryArray count] == 0) {
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"Error" 
                                                     message:@"Please click on at least 1 point" 
                                                    delegate:self 
                                           cancelButtonTitle:@"OK" 
                                           otherButtonTitles:nil];
        [av show];
        [av release];
        return;
    }
    
    // start network activity indicator
    [UIApplication showNetworkActivityIndicator:YES];
    
    self.gst = [[[AGSGeometryServiceTask alloc] initWithURL:[NSURL URLWithString:kGeometryBufferService]] autorelease];
    
    AGSSpatialReference *sr = [[[AGSSpatialReference alloc] initWithWKID:2383 WKT:nil] autorelease];
    
    // assign the delegate so we can respond to AGSGeometryServiceTaskDelegate methods
    self.gst.delegate = self;
    
    AGSBufferParameters *bufferParams = [[AGSBufferParameters alloc] init];
    
    // set the units to buffer by to meters
    bufferParams.unit = kesriSRUnit_Meter;
    bufferParams.bufferSpatialReference = sr;
    
    // set our buffer distances to 100m and 300m respectively
    bufferParams.distances = [NSArray arrayWithObjects:
                              [NSNumber numberWithUnsignedInteger:10000],
                              nil];
    
    // assign the geometries to be buffered...
    // self.geometryArray contains the points we clicked
    bufferParams.geometries = self.geometryArray;
    bufferParams.outSpatialReference = sr;
    bufferParams.unionResults = FALSE;
    
    // execute the task 
    [self.gst bufferWithParameters:bufferParams];
    
    // IMPORTANT: since we alloc'd/init'd bufferParams and gst
    // we must explicitly release them
    [bufferParams release];
    
}
*/
// get differ style symbol
 -(AGSCompositeSymbol*)GetRandSymbol
{
    @try {
        // caculate differ color
        int nRed = rand() % 10;
        float fRed = 1.f / nRed;
        int nGreen = rand() % 10;
        float fGreen = 1.f / nGreen;
        int nBlue = rand() % 10;
        float fBlue =  1.f / nBlue;
        UIColor *colorVal = [UIColor colorWithRed:fRed green:fGreen blue:fBlue alpha:1];
        
        //A composite symbol for the graphics layer's renderer to symbolize the sketches
        AGSCompositeSymbol* composite = [AGSCompositeSymbol compositeSymbol];
        AGSSimpleLineSymbol* lineSymbol = [[AGSSimpleLineSymbol alloc] init];
        lineSymbol.width = 2;
        
        // 画边框
        lineSymbol.color = [UIColor colorWithRed:1.0 green:0.5 blue:0.0 alpha:1];
        
        [composite.symbols addObject:lineSymbol];
        [lineSymbol release];
        lineSymbol = nil;
        
        AGSSimpleFillSymbol* fillSymbol = [[AGSSimpleFillSymbol alloc] init];
        fillSymbol.color = colorVal;
        // 填充内部区域
        [composite.symbols addObject:fillSymbol];
        [fillSymbol release];
        fillSymbol = nil;
        
        return composite;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

-(AGSCompositeSymbol*)GetSymbolByFlag:(BOOL)IsSeled
{
    @try {
        UIColor *colorVal;
        if(IsSeled)
        {
            colorVal = [UIColor colorWithRed:1.0 green:1.0 blue:0.0 alpha:0.3];
        }
        else {
            colorVal = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.35];
        }
        //A composite symbol for the graphics layer's renderer to symbolize the sketches
        AGSCompositeSymbol* composite = [AGSCompositeSymbol compositeSymbol];
//        AGSSimpleMarkerSymbol* markerSymbol = [[AGSSimpleMarkerSymbol alloc] init];
//        markerSymbol.style = AGSSimpleMarkerSymbolStyleCircle;
//        markerSymbol.color = [UIColor greenColor];
//        markerSymbol.size = 7.0f;
//        // 画顶点
//      [composite.symbols addObject:markerSymbol];
//        [markerSymbol release];
//        markerSymbol = nil;
        
        AGSSimpleLineSymbol* lineSymbol = [[AGSSimpleLineSymbol alloc] init];
        lineSymbol.width = 4;
        // 画边框
        if (IsSeled) {
            lineSymbol.color = [UIColor redColor];
        }
        else {
            lineSymbol.color = [UIColor blueColor];
        }
        
        [composite.symbols addObject:lineSymbol];
        [lineSymbol release];
        lineSymbol = nil;
        
        AGSSimpleFillSymbol* fillSymbol = [[AGSSimpleFillSymbol alloc] init];
        fillSymbol.color = colorVal;
        // 填充内部区域
        [composite.symbols addObject:fillSymbol];
        [fillSymbol release];
        fillSymbol = nil;
        
        return composite;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

- (void)drawGraphic:(AGSGraphic *) graphic inContext:(CGContextRef) context forEnvelope:(AGSEnvelope *) env atResolution:(double) resolution
{
    return;
}

- (void) doCurl
{
    @try {
        //创建CATransition对象
        CATransition *animation = [CATransition animation];
        //相关参数设置
        [animation setDelegate:self];
        //[animation setDuration:0.7f];
        [animation setTimingFunction:UIViewAnimationCurveEaseInOut];
        //向上卷的参数
        if(!isCurl)
        {
            //设置动画类型为pageCurl，并只卷一半
            [animation setType:@"pageCurl"];   
            animation.endProgress=0.4;
            [animation setDuration:0.5f];
            [self.MapLocationBtn setHidden:YES];
        }
        //向下卷的参数
        else
        {
            //设置动画类型为pageUnCurl，并从一半开始向下卷
            [animation setType:@"pageUnCurl"];
            animation.startProgress=0.6;
            [animation setDuration:0.8f];
            [self.MapLocationBtn setHidden:NO];
        }
        //卷的过程完成后停止，并且不从层中移除动画
        [animation setFillMode:kCAFillModeForwards];
        [animation setSubtype:kCATransitionFromBottom];
        [animation setRemovedOnCompletion:NO];
        
        isCurl=!isCurl;
        
        [self.MapContainterView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
        [[self.MapContainterView layer] addAnimation:animation forKey:@"pageCurlAnimation"];
        
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

    // do some operation
}

// 设置底图类型
-(void)SetBaseMapType:(NSString*)strMapType
{
    @try {
        if (strMapType == nil) {
            return;
        }
        if ([strMapType length] <= 0) {
            return;
        }
        
        NSString *BaseMapUrl = nil;
        NSString *RoadMapUrl = nil;
        if ([strMapType isEqualToString:DEFAULT_MAPLAYER_NAME]) 
        {
            // 取地图图层
            BaseMapUrl = [_BaseMapLayersDic valueForKey:strMapType];
            // 取道路图层
            RoadMapUrl = [_BaseMapLayersDic valueForKey:ROAD_MAPLAYER_NAME];
        }
        else if ([strMapType isEqualToString:SATELLITE_MAPLAYER_NAME]) {
            // 取影像图层
            BaseMapUrl = [_BaseMapLayersDic valueForKey:strMapType];
        }
        else if ([strMapType isEqualToString:MIX_MAPLAYER_NAME]) {
            // 取影像图层
            BaseMapUrl = [_BaseMapLayersDic valueForKey:SATELLITE_MAPLAYER_NAME];
            // 取道路图层
            RoadMapUrl = [_BaseMapLayersDic valueForKey:ROAD_MAPLAYER_NAME];
        }
        
        [self.BaseMapView removeMapLayerWithName:BASEMAPLAYER_NAME];
        
        if([BaseMapUrl length] > 0)
        {
            //AGSTiledMapServiceLayer *tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:[NSURL URLWithString:BaseMapUrl]];
            NSURL *webURL = [[NSURL alloc] initWithString:[BaseMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//            OfflineableTiledMapServiceLayer *tiledLayer = [[OfflineableTiledMapServiceLayer alloc] initWithDataFramePath:webURL error:nil];
            AGSTiledMapServiceLayer *tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:webURL];
            [webURL release];
            
            //OfflineableTiledMapServiceLayer *tiledLayer = [[OfflineableTiledMapServiceLayer alloc] initWithDataFramePath:[NSURL URLWithString:BaseMapUrl] error:nil];
            
            [tiledLayer setTileDelegate:self];
            //Add it to the map view
            [tiledLayer setRenderNativeResolution:YES];
            UIView<AGSLayerView>* lyr = [self.BaseMapView insertMapLayer:tiledLayer withName:BASEMAPLAYER_NAME atIndex:0];
            [tiledLayer release];
            lyr.drawDuringPanning = YES;
            lyr.drawDuringZooming = YES;            
        }
        BOOL bRet = [self GetTopDataMapLayerUrl];
        if ([strMapType isEqualToString:DEFAULT_MAPLAYER_NAME] || [strMapType isEqualToString:MIX_MAPLAYER_NAME])
        {
            // 添加道路地名地址图层(如果已经有，则不用添加) /arcgis/rest/services/JCDB/DL/MapServer
            if (!bRet) 
            {
                if ([RoadMapUrl length] > 0) 
                {
                    // 
                    NSURL * MapUrl = [NSURL URLWithString:[RoadMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    // 
                    AGSDynamicMapServiceLayer *MapDataLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:MapUrl];
                    
                    //[MapDataLayer setRenderNativeResolution:YES];
                    int nLayerCnt = [[self.BaseMapView mapLayers] count];
                    if ([SingleManager.RoadDataMapLayerName length] <= 0) {
                        SingleManager.RoadDataMapLayerName = ROAD_MAPLAYER_NAME;
                    }
                    
                    [self.BaseMapView insertMapLayer:MapDataLayer withName:SingleManager.RoadDataMapLayerName atIndex:nLayerCnt - 2];
                    [self.BaseMapView  bringSubviewToFront:self.GraphicsView];
                    
                    [MapUrl release];
                }
            }
        }
        if ([strMapType isEqualToString:SATELLITE_MAPLAYER_NAME]) {
            // 删除道路地名地址图层
            if (bRet) {
                [self.BaseMapView removeMapLayerWithName:ROAD_MAPLAYER_NAME];
            }
        }
        
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

    return;
}

- (IBAction)TopAddMesureClick:(id)sender {
    NSString *disText = [TopDataDisplayLabel text];
    AGSCompositeSymbol *csVal = [self GetSymbolWithNumber:1231 UnitText:disText TypeFlg:2];
    AGSGeometryEngine *GeoEng = [AGSGeometryEngine defaultGeometryEngine];
    // 测量完成
    if ([_sketchLayer.geometry  isMemberOfClass:[AGSMutablePolygon class]] )
    {
        // 测量面的场合
        AGSPolygon *poly = (AGSPolygon*)_sketchLayer.geometry;
        AGSPoint *LabelPoint = [GeoEng labelPointForPolygon:poly];
        if (LabelPoint != nil) {
            // 在此位置显示面积文字
            AGSGraphic *Graphic2 = [AGSGraphic graphicWithGeometry:LabelPoint symbol:csVal attributes:nil infoTemplateDelegate:nil]; 
            [self.graphicsLayer addGraphic:Graphic2]; 
        }
        
    }
    else if ([_sketchLayer.geometry  isMemberOfClass:[AGSMutablePolyline class]] ) 
    {
        // 测量线的场合
        AGSPolyline *poLine = (AGSPolyline*)_sketchLayer.geometry;
        int nPathCnt = [poLine numPaths];
        if (nPathCnt > 0) 
        {
            // 有测量线数据的场合
            int nTotalCnt = [poLine numPointsInPath:0];
            for (int nCnt = 1; nCnt < nTotalCnt; nCnt++) 
            {
                // 从第一个点开始追加
                AGSPoint *Point1 = [poLine pointOnPath:0 atIndex:nCnt - 1];
                AGSPoint *Point2 = [poLine pointOnPath:0 atIndex:nCnt];
                double dLength = [GeoEng distanceFromGeometry:Point1 toGeometry:Point2];
                NSString *LenString = nil;
                if (dLength > 0.01) {
                    dLength = dLength / 1000;
                    //double length = [engine shapePreservingLengthOfGeometry: poLine inUnit:AGSSRUnitKilometer];
                    if ((nCnt + 1) == nTotalCnt) {
                        double length = [GeoEng lengthOfGeometry:poLine];
                        if (length > 0.01) {
                            length = length / 1000;
                        }
                        else {
                            length = 0.0;
                        }
                        LenString = [NSString stringWithFormat:@"  总长度:%1.3f 千米", length];
                    }
                    else {
                        LenString = [NSString stringWithFormat:@"  %d:长度为%1.3f 千米", nCnt, dLength];
                    }
                    
                }
                AGSCompositeSymbol *lineVal = [self GetSymbolWithNumber:1231 UnitText:LenString TypeFlg:1];
                AGSPoint *Pos = [AGSPoint pointWithX:Point2.x + 20 y:Point2.y spatialReference:Point2.spatialReference];
                AGSGraphic *Graphic2 = [AGSGraphic graphicWithGeometry:Pos symbol:lineVal attributes:nil infoTemplateDelegate:nil]; 
                [self.graphicsLayer addGraphic:Graphic2]; 
            }
            /*  old src end add by niurg 2012-09-19
            if (nCnt > 0) 
            {
                // 测量线的长度>0的场合,计算长度文字显示位置.
                // 取第一个点开始点
                AGSPoint *BeginPos = [poLine pointOnPath:0 atIndex:0];
                // 取第二个点为结束点(也存储计算结果值)
                AGSPoint *EndPos = [poLine pointOnPath:0 atIndex:1];       
                // 计算两点的中点
                if (BeginPos != nil) 
                {
                    if (EndPos != nil) {
                        // 取得两点的中点
                        double dMidPosX = fabs(BeginPos.x - EndPos.x) / 2;
                        if (BeginPos.x < EndPos.x) {
                            dMidPosX = BeginPos.x + dMidPosX;
                        }
                        else {
                            dMidPosX = EndPos.x + dMidPosX;
                        }
                        double dMidPosY = fabs(BeginPos.y - EndPos.y) / 2;
                        if (BeginPos.y < EndPos.y) {
                            dMidPosY = BeginPos.y + dMidPosY;
                        }
                        else {
                            dMidPosY = EndPos.y + dMidPosY;
                        }
                        AGSSpatialReference *sRef = poLine.spatialReference;
                        EndPos = [AGSPoint pointWithX:dMidPosX y:dMidPosY spatialReference:sRef];
                    }
                    else {
                        EndPos = BeginPos;
                    }
                }
                // EndPos 为计算出来的位置点
                AGSGraphic *Graphic2 = [AGSGraphic graphicWithGeometry:EndPos symbol:csVal attributes:nil infoTemplateDelegate:nil]; 
                [self.graphicsLayer addGraphic:Graphic2]; 
            }
            */ // old src end add by niurg 2012-09-19
        }
        
    }
    
    AGSGraphic *Graphic = [AGSGraphic graphicWithGeometry:_sketchLayer.geometry symbol:_sketchLayer.mainSymbol attributes:nil infoTemplateDelegate:nil];  
    
    // add pushpin to graphics layer
    [self.graphicsLayer addGraphic:Graphic];  
    
//    AGSGeometry *GeoBak = [_sketchLayer.geometry copy];
    _sketchLayer.geometry = nil;
    [self.graphicsLayer dataChanged];
    if (nMeasureFlag == 1) {
        _sketchLayer.geometry = [[[AGSMutablePolyline alloc] initWithSpatialReference:_BaseMapView.spatialReference] autorelease];
    }
    else if (nMeasureFlag == 2) {
        _sketchLayer.geometry = [[[AGSMutablePolygon alloc] initWithSpatialReference:_BaseMapView.spatialReference] autorelease];
    }else {
        return;
    }
    bIsMeasureDataCalcuate = YES;
    [self DisplayCaluData:@"点击地图以添加点"];
    
//    // 巡察监管模块
//    if (self.nModelFlg == 2) {
//        // 将当前地块数据存储到巡察监管模块
//        [self.DBXCDKDetailViewCtrl AddGeometryData:GeoBak];
//    }
}

#pragma mark 解析标注信息
- (void)parsedMarkInfoFromData:(NSData *)data
{
    @try {
        DDXMLDocument *MarkInfoDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
        NSArray *MarkArray = [MarkInfoDocument nodesForXPath:@"//XML/MarkList/Mark" error:nil];
        for (DDXMLElement *obj in MarkArray) 
        {
            //标注ID
            DBMarkData *MarkData = [[DBMarkData alloc] init];
            DDXMLElement *eleVal = [obj elementForName:@"MarkID"];
            MarkData.MarkID = eleVal.stringValue;
            
            // 标注名称
            eleVal = [obj elementForName:@"MarkName"];
            MarkData.MarkName = eleVal.stringValue;
            
            // 标注备注
            eleVal = [obj elementForName:@"MarkNote"];
            MarkData.MarkNote = eleVal.stringValue;
            
            // 标注所在坐标系
            eleVal = [obj elementForName:@"MarkSpatialReferenceWKID"];
            MarkData.MarkSpatialReferenceWKID = eleVal.stringValue;
            eleVal = [obj elementForName:@"MarkSpatialReferenceWKT"];
            MarkData.MarkSpatialReferenceWKT = eleVal.stringValue;
            
            // 标注所在坐标x,y
            eleVal = [obj elementForName:@"MarkCoordinateX"];
            MarkData.MarkCoordinateX = eleVal.stringValue;
            eleVal = [obj elementForName:@"MarkCoordinateY"];
            MarkData.MarkCoordinateY = eleVal.stringValue;
            
//            AGSSpatialReference * Spref = [AGSSpatialReference spatialReferenceWithWKID:MarkData.MarkSpatialReference.intValue];            
//            // 标注所在坐标点
//            NSString *xVal = [obj elementForName:@"MarkCoordinateX"].stringValue;
//            double dXPos = [xVal doubleValue];
//            NSString *yVal = [obj elementForName:@"MarkCoordinateY"].stringValue;
//            double dYPos = [yVal doubleValue];           
//            MarkData.Point = [AGSPoint pointWithX:dXPos y:dYPos spatialReference:Spref];
            
            //[SingleManager.MarkArray addObject:MarkData];
            [SingleManager.MarkDic setValue:MarkData forKey:MarkData.MarkID];
            [MarkData release];
        }
        [MarkInfoDocument release];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
}

-(void)parsedBaseMapLayerFromData:(NSData *)data
{
    @try {
        [_BaseMapLayersDic removeAllObjects];
        NSString *strNameKey = nil;
        NSString *strUrl = nil;
        DDXMLDocument *_LayerDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
        NSArray *BaseLayers = [_LayerDocument nodesForXPath:@"//XML/BaseMapLayList/BaseMapLay" error:nil];
        for (DDXMLElement *obj in BaseLayers) 
        {
            // 层的名称
            DDXMLElement *name = [obj elementForName:@"LayerName"];
            if (name) 
            {
                strNameKey = name.stringValue;
            }
            
            // 层的URL地址
            DDXMLElement *layerUrl = [obj elementForName:@"LayerUrl"];
            if (layerUrl) 
            {
                strUrl = layerUrl.stringValue;
            }
            [_BaseMapLayersDic setValue:strUrl forKey:strNameKey];
        }
        
        [_LayerDocument release];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
}

// 解析业务图层和WebService服务数据
-(void)parsedDataMapLayerFromData:(NSData *)data
{
    @try {
//        [_DataMapLayerNameArray removeAllObjects];
//        [_DataMapLayerUrlArray removeAllObjects];
//        [_DataMapLayerSwitchArray removeAllObjects];
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        [DataMan parsedMeetingShowConf:data];

        // add by niurg 2015.9
        [DataMan parasedHistoryMeetingBtnShowConf:data];
        // end
        
        DDXMLDocument *_LayerDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
        /*
        NSArray *subject = [_LayerDocument nodesForXPath:@"//XML/DataLayerList/DataLayer" error:nil];
        for (DDXMLElement *obj in subject) 
        {
            // 层的名称
            DDXMLElement *name = [obj elementForName:@"DataLayerName"];
            if (name) 
            {
                [_DataMapLayerNameArray addObject:name.stringValue];
            }
            
            // 层的URL地址
            DDXMLElement *layerUrl = [obj elementForName:@"DataLayerUrl"];
            if (layerUrl) {
                [_DataMapLayerUrlArray addObject:layerUrl.stringValue];
            }
            
            // 层是否显示
            DDXMLElement *value = [obj elementForName:@"DataLayerDisplay"];
            if (value) {
                [_DataMapLayerSwitchArray addObject:value.stringValue];
            }
        }
         */
        //解析WebServiceUrl
        NSArray *WebServerUrlArray = [_LayerDocument nodesForXPath:@"//XML/WebServerUrl" error:nil];
        for (DDXMLElement *obj in WebServerUrlArray) {
            DDXMLElement *TopicsWebServerUrl = [obj elementForName:@"TopicsWebServerUrl"];
            if (TopicsWebServerUrl) {
                SingleManager.TopicWebServiceUrl = TopicsWebServerUrl.stringValue;
            }
            
            DDXMLElement *LandWebServerUrl = [obj elementForName:@"GISWebServerUrl"];
            if (LandWebServerUrl) {
                SingleManager.GISWebServiceUrl = LandWebServerUrl.stringValue;
            }
            
            DDXMLElement *AnnexServerUrl = [obj elementForName:@"AnnexServerUrl"];
            if (AnnexServerUrl) {
                SingleManager.AnnexDownloadServiceUrl = AnnexServerUrl.stringValue;
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

// 显示测量结果数据
-(void)DisplayCaluData:(NSString*)strText
{
    @try {
        _BaseMapView.touchDelegate = _sketchLayer;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respondToGeomChanged:) name:@"GeometryChanged" object:nil];
        
        [self TopTipViewAnimatedApper];
        
        TopAddMesureBtn.hidden = NO;
        BOOL bRet = [_BaseMapSwitchBtn isSelected];
        [_BaseMapSwitchBtn setSelected:!bRet];
        
        if([strText length] <= 0)
        {
            strText = @"计算数据出错";
        }
        TopDataDisplayLabel.text = strText;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

- (void)myTransitionDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIView * view = (UIView*)context;
    [view setHidden:YES];
    
    return;
}

-(void)StopMeasureOperation
{
    nMeasureFlag = 0;
    _BaseMapView.touchDelegate = self;
    _sketchLayer.geometry = nil;
    
    [self TopTipViewAnimatedDissapper];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
    return;
}

#pragma mark 编辑测量元素响应事件
- (void)respondToGeomChanged: (NSNotification*) notification 
{
    if (bIsMeasureDataCalcuate) {
        [self MeasureDataCalcuate];
    }
    return;
}

#pragma mark - LastClickButtonCancel
- (void)LastClickButtonCancel:(UIButton *)button ClearGraphicFlg:(BOOL)bFlg
{
    [_SearchBarCtrl resignFirstResponder];
    //如果callout显示在界面上，则让其隐藏
    if (![self.BaseMapView.callout isHidden]) {
        self.BaseMapView.callout.hidden = YES;
    }
    if ([self.LatelySearchViewPopover isPopoverVisible]) {
        [self.LatelySearchViewPopover dismissPopoverAnimated:NO];
        //_SearchBarCtrl.text = nil;
    }

    if ((button.tag < 102) && (button.tag > 107)) {
        [self clearGraphicsBtnClicked:nil];
    }
    if ((button.tag == 104) ||(button.tag == 105)) {
        bIsMeasureDataCalcuate = NO;
        nMeasureFlag = 0;
        _BaseMapView.touchDelegate = self;
        _sketchLayer.geometry = nil;
    }
    if (LastClickButton != button && LastClickButton != nil) 
    {
        int tag = LastClickButton.tag - 100;
        switch (tag) {
            case 0:
                [self.DataMapLayerViewPopover dismissPopoverAnimated:NO];
                break;
            case 1:
                if (self.nModelFlg == 1) {
                    if([self.MeetingViewPopover isPopoverVisible])
                    {
                        DBMeetingViewController * MeetingContrl = (DBMeetingViewController *)[self.MeetingViewPopover contentViewController];
                        [MeetingContrl SetSubPopoverHiden];
                        
                        [self.MeetingViewPopover dismissPopoverAnimated:NO];
                    }
                }
                else
                {
//                    if([self.XCDKListViewPopover isPopoverVisible])
//                    {
//                        [self.XCDKListViewPopover dismissPopoverAnimated:NO];
//                    }
                }

                break;
            case 2:
                bIsPlanBtnTouched = NO;
                [self TopTipViewAnimatedDissapper];
                [self.QueryMenuPopoverView dismissPopoverAnimated:NO];
                [self ResetPlayBtn];
                break;
            case 3:
                bIsXianZhuangBtnTouched = NO;
                [self TopTipViewAnimatedDissapper];
                break;
            case 4:
                bIsPriceBtnTouched = NO;
                [self TopTipViewAnimatedDissapper];
                break;
            case 5:
                bIsInfoBtnTouched = NO;
                [self TopTipViewAnimatedDissapper];
                break;
            case 6:
            case 7:
                if ((button.tag != 102) && (button.tag != 103)){
                    bIsMeasureDataCalcuate = NO;
                    nMeasureFlag = 0;
                    _BaseMapView.touchDelegate = self;
                    _sketchLayer.geometry = nil;
                    
                    [self TopTipViewAnimatedDissapper];
                    break;
                }
            case 8:
                break;
                //标注
            case 9:
                [self.MarkListPopoverView dismissPopoverAnimated:NO];
                break;
            default:
                break;
        }
    }
    //if ((button.tag == 102) && 
//    if (
//        ((LastClickButton.tag == 106) || (LastClickButton.tag == 107))){
//        //
//    }
//    else 
    {
        // 规划按钮不需要更换背景图片
        [self setLastClickButtonImage];
        LastClickButton = button;
    }
}

- (void)setLastClickButtonImage
{
    if (LastClickButton.tag >= 102 && LastClickButton.tag < 108) {
        [LastClickButton setBackgroundImage:[_LastBtnImageArray objectAtIndex:LastClickButton.tag - 102] forState:UIControlStateNormal];
    }
}

#pragma mark - 工具栏按钮响应事件

- (IBAction)MapLayerTouched:(id)sender {
    UIButton *tappedButton = (UIButton *)sender;
    [self LastClickButtonCancel:tappedButton ClearGraphicFlg:YES];
    //init popoverContentSize
    int nCnt = [[SingleManager MapLayerDataArray] count];
    if (nCnt == 0) {
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        BOOL bNetConn = [DataMan InternetConnectionTest];
        if (!bNetConn) {
            //[DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
            NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DBMapLayerData.xml"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            if (data != nil){
                [DataMan ParseMapLayerData:data];
                // 添加业务图层
                [self AddDataMapLayer];
                [self AddMarkData];
            }
            else {
                [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接,并且本地无图层数据." andWithMessage:nil];
            }
            if ([_DataMapLayerViewPopover isPopoverVisible]) 
            {
                [self SetPopoerHiden];
            }else 
            {
                UIButton *tappedButton = (UIButton *)sender;
                // Present the popover from the button that was tapped in the detail view.
                [_DataMapLayerViewPopover presentPopoverFromRect:tappedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
            return;
        }
        
        _DataMapLayerViewPopover.popoverContentSize = CGSizeMake(270, 37);
        //下载图层数据
        [SingleManager DownLoadMapLayerData:@""];
    }
    if ([_DataMapLayerViewPopover isPopoverVisible]) 
    {
        [self SetPopoerHiden];
    }else 
    {
        UIButton *tappedButton = (UIButton *)sender;
        // Present the popover from the button that was tapped in the detail view.
        [_DataMapLayerViewPopover presentPopoverFromRect:tappedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

// add by niurg 2015.9

// 显示历史会议-议题（原议题按钮的功能）
- (IBAction)HistorySubjectMenuTouched:(id)sender {
    [self SubjectMenuTouched2:sender];
    
    return;
}

- (IBAction)SubjectMenuTouched2:(id)sender {
    if (self.nModelFlg == 2) {
        [self GTXCBtnTouch:sender];
        return;
    }
    [SingleManager setCurSubjectIsHistory:@"1"];
    UIButton *tappedButton = (UIButton *)sender;
    [self LastClickButtonCancel:tappedButton ClearGraphicFlg:YES];
    //init popoverContentSize
    int nCnt = [[SingleManager MeetingList] count];
    if (nCnt == 0) {
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        BOOL bNetConn = [DataMan InternetConnectionTest];
        if (!bNetConn) {
            [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
            return;
        }
        
        _MeetingViewPopover.popoverContentSize = CGSizeMake(320.0, 35);
        //下载所有的会议
        [SingleManager DownLoadMeetingData:@""];
    }    

    ////
    if ([_MeetingViewPopover isPopoverVisible]) {
        [self SetPopoerHiden];
    }else {
        // Present the popover from the button that was tapped in the detail view.
        [_MeetingViewPopover presentPopoverFromRect:tappedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}


#pragma mark 议题点击事件
- (IBAction)SubjectMenuTouched:(id)sender {
{
        //
        if ([_MeetingViewPopover isPopoverVisible]) {
            [self SetPopoerHiden];
            return;
        }
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        @try
        {
            [DataMan setCurSubjectIsHistory:@"0"];
            // 取得会议ID
            NSString *MeetingID = nil;
            int nRow = 0;
            
            if ([_Subject2ViewPopover isPopoverVisible]) {
                [_Subject2ViewPopover dismissPopoverAnimated:NO];
            }
            
            _Subject2ViewPopover = nil;
            _Subject2ViewPopoverViewController = nil;
            _Subject2ViewPopoverViewController = [[DBSubjectListController alloc] init];
            UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:_Subject2ViewPopoverViewController];
            [_Subject2ViewPopoverViewController release];
            _Subject2ViewPopoverViewController.delegate = self;
            
            // Setup the popover for use in the detail view.
            _Subject2ViewPopover = nil;
            _Subject2ViewPopover = [[UIPopoverController alloc] initWithContentViewController:nav1];
            [nav1 release];
            _Subject2ViewPopover.delegate = self;
//            NSArray *InteractionViews = [NSArray arrayWithObjects:self.view,self.BaseMapView, nil];
//            [_Subject2ViewPopover setPassthroughViews:InteractionViews];
            //---
            nRow = [DataMan.MeetingList count] - nRow - 1;
            MeetingID = [[DataMan.MeetingList objectAtIndex:nRow] Id];
            NSLog(@"*******:%@",MeetingID);
            // 查找本地是否有议题数据，如果没有则从网络服务器下载。
            int nFlg = 0;
            NSArray *DataArray = nil;
            id ResObj = [DataMan.TopicsOfMeeting objectForKey:MeetingID];
            if (ResObj != nil) {
                // 从本地取得数据
                //[_searchBar resignFirstResponder];
                nFlg = 0;
                DataArray = [[DataMan.TopicsOfMeeting objectForKey:MeetingID] allValues];
            }
            else {
                //判断网络是否连通
                BOOL bNetConn = [DataMan InternetConnectionTest];
                if (!bNetConn) {
                    [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
                    return;
                }
                [_Subject2ViewPopoverViewController DisPlayLoadingView:@"正在下载议题数据,请稍后..."];
                // 从网络获取此会议下的所有议题数据
                [UIApplication showNetworkActivityIndicator:YES];
                nFlg = 1;
                DB2GoverDeciServerService* service = [DB2GoverDeciServerService service];
                service.logging = YES;
                
                NSString * Param = [NSString stringWithFormat:@"<root><function>DownloadPortalTopicsByConvention</function><params><param>%@</param></params></root>", MeetingID];
                //加密处理
                NSString *encryptParam = [NSString stringWithFormat:@"<![CDATA[%@]]>", [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY]];
                
                SoapRequest * SoapReq = [service CommonService:self action:@selector(DownloadPortalTopicsCallBack:userInfo:) arg0: encryptParam];
                [SoapReq setUserInfo:MeetingID];
                //[service DownloadPortalTopicsByConvention:self action:@selector(DownloadPortalTopicsCallBack:) arg0: MeetingID];
                [_Subject2ViewPopoverViewController waitDownload];
                // 压入下载队列
                //[MeetingIdQueue enqueue:MeetingID];
            }
            
            // 动态设置议题popoverView高度
            NSInteger nCnt = 1;
            if ([DataArray count] > 0)
            {
                nCnt = [DataArray count];
            }
            [_Subject2ViewPopoverViewController setMeettingId:MeetingID];
            if (DataArray.count >= 8 ) {
                //[_Subject2ViewPopover setPopoverContentSize:CGSizeMake(320.0, 320.0) animated:NO];
                [_Subject2ViewPopover setPopoverContentSize:CGSizeMake(450, 360.0) animated:NO];
            }
            else {
                [_Subject2ViewPopover setPopoverContentSize:CGSizeMake(450, 55.0 * nCnt + 37) animated:NO];
            }
            
            // 从本地获取数据
            [_Subject2ViewPopoverViewController setNLoadFlg:nFlg];
            //[SubContentView reloadContentDataArray:DataArray];
            [_Subject2ViewPopoverViewController reloadContentDataArray:MeetingID];
            
            //显示议题popoverView
            UIButton *tappedButton = (UIButton *)sender;
            [_Subject2ViewPopover presentPopoverFromRect:tappedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            
            [DataMan setNCurMeetingRowIndex:nRow];
        }
        @catch (NSException *exception) {
            [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
            [DataMan setNCurMeetingRowIndex:-1];
        }
        @finally {
            
        }
    }
}

// 隐藏议题列表
-(void)SetSubPopoverHiden
{
    if ([_Subject2ViewPopover isPopoverVisible]) {
        [_Subject2ViewPopover dismissPopoverAnimated:NO];
        _Subject2ViewPopover = nil;
        _Subject2ViewPopoverViewController = nil;
    }
}

// 接收议题数据
- (void) DownloadPortalTopicsCallBack: (id) value  userInfo:(NSString *)_userInfo;
{
    // 从队列取得会议ID
    //NSString *MeetingID = [MeetingIdQueue dequeue];
    // Handle errors
    if([value isKindOfClass:[NSError class]]) {
        //NSLog(@"%@", value);
        NSError *error = (NSError *)value;
        NSString *string = [error localizedDescription];
        [_Subject2ViewPopoverViewController HideLoadingView:string];
        //DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        //[DataMan CreateFailedAlertViewWithFailedInfo:@"下载错误!" andWithMessage:string];
        [UIApplication showNetworkActivityIndicator:NO];
        [_Subject2ViewPopover dismissPopoverAnimated:NO];
        _Subject2ViewPopover = nil;
        _Subject2ViewPopoverViewController = nil;
        return;
    }
    
    // Handle faults
    if([value isKindOfClass:[SoapFault class]]) {
        //NSLog(@"%@", value);
        SoapFault *soapFault = (SoapFault *)value;
        NSString *string = [soapFault description];
        [_Subject2ViewPopoverViewController HideLoadingView:string];
        //DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        //[DataMan CreateFailedAlertViewWithFailedInfo:@"下载失败!" andWithMessage:string];
        [UIApplication showNetworkActivityIndicator:NO];
        [_Subject2ViewPopover dismissPopoverAnimated:NO];
        _Subject2ViewPopover = nil;
        _Subject2ViewPopoverViewController = nil;
        return;
    }
    //
    NSString *MeetingID = [_userInfo copy];
    NSDictionary *dicData = (NSDictionary*)value;
    NSString *str = [dicData objectForKey:@"return"];
    NSString *plainStr = [EncryptUtil decryptUseDES:str key:ENCRYPT_KEY];
    NSData *XmlData = [plainStr dataUsingEncoding:NSUTF8StringEncoding];
    //    NSData *XmlData = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    [DataMan ParseAllTopicData:XmlData ConventionId:MeetingID];
    [UIApplication showNetworkActivityIndicator:NO];
    [_Subject2ViewPopoverViewController HideLoadingView:@"议题数据下载完成"];
    // 重新加载 议题数据
    //数组里存放的是所有议题信息
    NSArray *DataArray = [[DataMan.TopicsOfMeeting objectForKey:MeetingID] allValues];
    // 动态设置议题popoverView高度
    NSInteger nCnt = 1;
    if ([DataArray count] > 0)
    {
        nCnt = [DataArray count];
    }
    [_Subject2ViewPopoverViewController setMeettingId:MeetingID];
    if (DataArray.count >= 8 ) {
        [_Subject2ViewPopover setPopoverContentSize:CGSizeMake(450, 360.0) animated:NO];
    }
    else {
        [_Subject2ViewPopover setPopoverContentSize:CGSizeMake(450, 55.0 * nCnt + 37) animated:NO];
    }
    [_Subject2ViewPopoverViewController setNLoadFlg:0];
    //[SubContentView reloadContentDataArray:DataArray];
    [_Subject2ViewPopoverViewController reloadContentDataArray:MeetingID];
    
    return;
}
// end
#pragma mark 区域地块分析（各地块在所画区域内的面积）
//  地块信息查询正常结束
// get intersection geo
-(AGSGeometry*)CalculateInnerArea:(AGSGeometry*) orgGeometry
{
    AGSGeometryEngine *engine = [[[AGSGeometryEngine alloc] init] autorelease];
    AGSGeometry *clipGeometry = orgGeometry;
    if (_sketchLayer.geometry != nil) {
        clipGeometry = [engine intersectionOfGeometry:orgGeometry andGeometry:_sketchLayer.geometry];
    }
    if (clipGeometry != nil)
    {
        AGSGeometry *tmpGeo = [engine simplifyGeometry:clipGeometry];
        return tmpGeo;
    }
    return nil;
}

- (void)DKInfoQueryFinish:(NSDictionary*)DKInfoDic Geometrys:(NSMutableArray*)GeometryArr
{
    if ([DKInfoDic allKeys].count == 1) {
        
        NSDictionary *DKInfo = [[DKInfoDic allValues] objectAtIndex:0];
        [self drawGeometry:[DKInfo objectForKey:@"Geometry"]];
        //初始化
        DBSingleLandInfoViewController *singleLandInfoViewController = [[DBSingleLandInfoViewController alloc] initWithResult:DKInfo];
        singleLandInfoViewController.geometry = _sketchLayer.geometry;
        singleLandInfoViewController.delegate = self;
        singleLandInfoViewController.view.frame = CGRectMake(0, 0, 240, 450);
        [self popoverWithViewController:singleLandInfoViewController];
    }else{
        // 查询出多个结果的场合
        [self CreateLandAnalyseViewContrl];
        [DBLandAnalyseViewContrl setNType:2];
        [DBLandAnalyseViewContrl setDKInfoDic:DKInfoDic];
        [DBLandAnalyseViewContrl setGeometry:_sketchLayer.geometry];
        float fWidth = 400.0f;
        float fHeight = 500.0f;
        float fXpos = 0.0f;
        float fYpos = 748 - fHeight + 45.0f;
        CGRect frame = CGRectMake(fXpos, fYpos, fWidth, fHeight);
        // 直接显示
        [_LandAnalysePopoverView presentPopoverFromRect:frame inView:self.view permittedArrowDirections:0 animated:YES];
    }

    for (NSDictionary *DKInfo in  [DKInfoDic allValues]) {
        // 标记宗地编号
        NSString *temp = [DKInfo objectForKey:@"ZDBH"];
        temp = temp.length <= 0 ? @"无宗地编号" : temp;
        NSString *ZDBH = [temp isEqualToString:@"null"] ? @"无宗地编号" : temp;
        
        NSString *text = [NSString stringWithFormat:@"%@",ZDBH];
        AGSGeometry *geo = [DKInfo objectForKey:@"Geometry"];
        [self drawGeometry:geo];
        [self addText:text forGeometry:geo];
    }

    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
    _sketchLayer.geometry = nil;
    [self.graphicsLayer dataChanged];
//    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
//    NSString *DataLayerId = @"153";
//    
//    id FidldData = [[DataMan PhyLayerIdToFieldsDic] objectForKey:DataLayerId];
//    if (FidldData == nil) {
//        // 没有Field信息，去库中查询.
//        [DataMan DownloadDisplayPhyLayersFieldsByThemeID:DataLayerId PhyLayerUrl:MapUrl ViewFlg:@"0"];
//    }
//    else {
//        // 直接显示
//        [_LandDataPopoverView presentPopoverFromRect:frame inView:self.view permittedArrowDirections:0 animated:YES];
//    }
    
    
    return;
}
//  地块信息查询出错
- (void)DKInfoQueryError:(NSString*)Msg
{
    return;
}
- (IBAction)PlanBtnTouched:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    [self LastClickButtonCancel:btn ClearGraphicFlg:YES];
    
    UIImage *image;
    if (bIsPlanBtnTouched) {
        image = [UIImage imageNamed:@"PlanTopBtn.png"];
        if ([[self QueryMenuPopoverView] isPopoverVisible]) {
            [self.QueryMenuPopoverView dismissPopoverAnimated:NO];
        }
        bIsPlanBtnTouched = !bIsPlanBtnTouched;
        return;
    }
    else {
        image = [UIImage imageNamed:@"PlanTopBtn2.png"];
    }
    bIsPlanBtnTouched = !bIsPlanBtnTouched;
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    
    self.QueryMenuPopoverView.popoverContentSize = CGSizeMake(160.0, 105);
    [self.QueryMenuPopoverView presentPopoverFromRect:btn.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    return;
    DBAGSGraphic *SelectedLandGraphic = [self LastSelectedLandGraphic];
    if (_sketchLayer.geometry != nil || SelectedLandGraphic != nil) 
    { 
        BOOL bRet = [self IsRightPoly];
        if (!bRet) {
            //[self StopMeasureOperation];
            [TopDataDisplayLabel setText:@"现状分析: 请您指定某一地块或画测量面确定分析区域"];
            return;
        }
        
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        BOOL bNetConn = [DataMan InternetConnectionTest];
        if (!bNetConn) {
            [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
            nMeasureFlag = 0;
            _BaseMapView.touchDelegate = self;
            _sketchLayer.geometry = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
            [self.graphicsLayer dataChanged];
            return;
        }
        [DataMan setDBDKInfoQueryDeg:self];
        [DataMan QuaryRelationLandByGeometry:self.sketchLayer.geometry];
        /*//---------   del by niurg 2013.07.23 start
        int nTotalCnt = [SingleManager.MapLayerDataArray count];
        for (int nCnt = 0; nCnt < nTotalCnt; nCnt++) 
        {
            DBMapLayerDataItem *MapLayerData = [SingleManager.MapLayerDataArray objectAtIndex:nCnt];
            if ([MapLayerData.ENNAME isEqualToString:@"GTL_TDLYXZ"])
            {
                NSString *url = MapLayerData.MapUrl;
                self.AnalyseIdentifyTask = [AGSIdentifyTask identifyTaskWithURL: [NSURL URLWithString:url]];
                self.AnalyseIdentifyTask.delegate = self;
                AGSIdentifyParameters* identifyParams = [[AGSIdentifyParameters alloc] init];
                //the layer we want is layer ‘5’ (from the map service doc)
                identifyParams.layerIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2],[NSNumber numberWithInt:3],nil];
                identifyParams.tolerance = 0;
                AGSGeometryEngine *engine = [[[AGSGeometryEngine alloc] init] autorelease];
                AGSGeometry *analyseGeo;
                if (SelectedLandGraphic != nil) {
                    analyseGeo = SelectedLandGraphic.geometry;
                }else {
                    analyseGeo = [engine simplifyGeometry:_sketchLayer.geometry];
                }
                identifyParams.geometry = analyseGeo;
                [_LandAnalyseGeometryQueue enqueue:analyseGeo];
                identifyParams.size = self.BaseMapView.bounds.size;
                identifyParams.mapEnvelope = self.BaseMapView.fullEnvelope;
                identifyParams.returnGeometry = YES;
                identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
                //identifyParams.spatialReference = self.BaseMapView.spatialReference;
                AGSSpatialReference *sPrf = [AGSSpatialReference spatialReferenceWithWKID:2383];
                identifyParams.spatialReference = sPrf;
                [self.AnalyseIdentifyTask executeWithParameters:identifyParams];
                [self DisplayLoadingView:self.view TipText:@"正在现状分析,请稍后..."];
                break;
            }
        }
        *///---------   del by niurg 2013.07.23 end
        
//        AGSCompositeSymbol* compositeSel = [self GetSymbolByFlag:NO];
//        AGSGraphic *Graphic = [AGSGraphic graphicWithGeometry:_sketchLayer.geometry symbol:compositeSel attributes:nil infoTemplateDelegate:nil];  
//        
//        // add pushpin to graphics layer
//        [self.graphicsLayer addGraphic:Graphic];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
//        [self.graphicsLayer dataChanged];
//        _sketchLayer.geometry = nil;
        nMeasureFlag = 0;
        _BaseMapView.touchDelegate = self;
        

    }
    
    /*
    AGSGeometryEngine *engine = [[[AGSGeometryEngine alloc] init] autorelease];
    NSArray * array = self.graphicsLayer.graphics;
    for (AGSGraphic *graphic in array) 
    {
        AGSGeometry * originalGeometry = graphic.geometry;
        AGSGeometry *clipGeometry = [engine clipGeometry:originalGeometry withEnvelope:_sketchLayer.geometry.envelope];
        if (clipGeometry != nil) {
            float area = [engine areaOfGeometry:clipGeometry];
            if(area < -0.1)
            {
                area = -area;
                area = area / (1000 * 1000);
            }
            else if(area > 0.1)
            {
                area = area / (1000 * 1000);
            }
            [self setLandDataViewContrlData:area];
        }
    }
    
    self.query.geometry = _sketchLayer.geometry;
    self.query.spatialRelationship = AGSSpatialRelationshipContains;
    //self.query.spatialRelationship = AGSSpatialRelationshipOverlaps | AGSSpatialRelationshipWithin | AGSSpatialRelationshipContains;
    [UIApplication showNetworkActivityIndicator:YES];
    [self.graphicsLayer removeAllGraphics];
	[self.graphicsLayer dataChanged];
    [self.queryTask executeWithQuery:query];
    */
    
    /*
    UIButton *btn = (UIButton*)sender;
    UIImage *image;
    [self LastClickButtonCancel:btn];
    if (bIsPlanBtnTouched) {
        image = [UIImage imageNamed:@"PlanTopBtn.png"];
    }
    else {
        image = [UIImage imageNamed:@"PlanTopBtn2.png"];
    }
    bIsPlanBtnTouched = !bIsPlanBtnTouched;
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    */
    
//    float fWidth = 400.0f;
//    float fHeight = 500.0f;
//    float fXpos = 0.0f; //1024 / 2 - fWidth / 2;
//    float fYpos = 748 / 2 - fHeight / 2;
//    CGRect frame2 = CGRectMake(fXpos, fYpos, fWidth, fHeight);
//    [_LandDataPopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
    
}

//返回最后点击的LandGraphic
- (DBAGSGraphic *)LastSelectedLandGraphic
{
    NSMutableArray *graphicArray = self.graphicsLayer.graphics;
    for (AGSGraphic *graphic in graphicArray) 
    {
        if ([graphic isKindOfClass:[DBAGSGraphic class]])
        {
            DBAGSGraphic *RealGraphic = (DBAGSGraphic *)graphic;
            if (RealGraphic.TypeFlg == 2 && RealGraphic.bIsHighlighted)
            {
                return [[RealGraphic retain] autorelease];
            } 
        }
    }
    return nil;
}

// 检查是不是多边形
-(BOOL)IsRightPoly
{
    // 是不是多边形
    if ([_sketchLayer.geometry isKindOfClass:[AGSMutablePolygon class]]) {
        // 是不是多于2个点
        AGSMutablePolygon *Poly = (AGSMutablePolygon*)_sketchLayer.geometry;
        NSInteger PosCnt = [Poly numPointsInRing:0];
        if ((PosCnt < 3) || (PosCnt > 100000)) {
            return NO;
        }
        return YES;
    }
    else if ([_sketchLayer.geometry isKindOfClass:[AGSEnvelope class]]) {
        return YES;
    }
    else {
        DBAGSGraphic *SelectedLandGraphic = [self LastSelectedLandGraphic];
        if (SelectedLandGraphic != nil)
        {
            if ([SelectedLandGraphic.geometry isKindOfClass:[AGSMutablePolygon class]]){
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark 地籍权属查询
-(void)DJQuery
{
    DBAGSGraphic *SelectedLandGraphic = [self LastSelectedLandGraphic];
    if (_sketchLayer.geometry != nil || SelectedLandGraphic != nil)
    {
        BOOL bRet = [self IsRightPoly];
        if (!bRet) {
            //[self StopMeasureOperation];
            [TopDataDisplayLabel setText:@"现状分析: 请您指定某一地块或画测量面确定分析区域"];
            return;
        }
        
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        BOOL bNetConn = [DataMan InternetConnectionTest];
        if (!bNetConn) {
            [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
            nMeasureFlag = 0;
            _BaseMapView.touchDelegate = self;
            _sketchLayer.geometry = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
            [self.graphicsLayer dataChanged];
            return;
        }
        [DataMan setDBDKInfoQueryDeg:self];
        [DataMan QuaryRelationLandByGeometry:self.sketchLayer.geometry];

        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
        nMeasureFlag = 0;
        _BaseMapView.touchDelegate = self;
    }
}

#pragma mark 现状/规划/地价通用查询
-(DBMapLayerDataItem*)GetMapLayerDataItemByEnname:(NSString*)LayerEnname
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    for (DBMapLayerDataItem *Obj in [DataMan MapLayerDataArray])
    {
        NSRange Range = [Obj.ENNAME rangeOfString:LayerEnname];
        if (Range.location != NSNotFound)
        {
            return Obj;
        }
    }
    return nil;
}
-(DBMapLayerDataItem*)GetMapLayerDataItemByUrl:(NSString*)MapUrl
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    for (DBMapLayerDataItem *Obj in [DataMan MapLayerDataArray])
    {
        NSRange Range = [Obj.MapUrl rangeOfString:MapUrl];
        if (Range.location != NSNotFound)
        {
            return Obj;
        }
    }
    return nil;
}
-(void)CommonQuery:(NSString*)LayerEnname
{
    //---------
    // 查询
    DBAGSGraphic *SelectedLandGraphic = [self LastSelectedLandGraphic];
    if (_sketchLayer.geometry != nil || SelectedLandGraphic != nil)
    {
        BOOL bRet = [self IsRightPoly];
        if (!bRet) {
            //[self StopMeasureOperation];
            [TopDataDisplayLabel setText:@"查询: 请您指定某一地块或画测量面确定分析区域"];
            return;
        }
        
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        BOOL bNetConn = [DataMan InternetConnectionTest];
        if (!bNetConn) {
            [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
            nMeasureFlag = 0;
            _BaseMapView.touchDelegate = self;
            _sketchLayer.geometry = nil;
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
            [self.graphicsLayer dataChanged];
            return;
        }

        //DBMapLayerDataItem *MapLayerData = [[DataMan MapLayerDataArray] objectAtIndex:[DataMan nCurrentSelRadioBtnIndex]];
        DBMapLayerDataItem *MapLayerData = [self GetMapLayerDataItemByEnname:LayerEnname];
        if (MapLayerData == nil) {
            [DataMan CreateFailedAlertViewWithFailedInfo:@"未找到指定的专题图层" andWithMessage:nil];
            return;
        }
        
        NSString *url = [MapLayerData MapUrl];
        if ([url length] > 0)
        {
            //
            NSURL *MapUrl = [[NSURL alloc] initWithString:url];
            // 检测主机是否可到达
            bNetConn = [DataMan GetHostNetStatus:[MapUrl host]];
            if (!bNetConn) {
                [DataMan CreateFailedAlertViewWithFailedInfo:@"GIS服务器不可到达" andWithMessage:nil];
                return;
            }
            NSError *err = nil;
            AGSMapServiceInfo *serviceInfo = [AGSMapServiceInfo mapServiceInfoWithURL:MapUrl error:&err];
            if (!serviceInfo) {
                [DataMan CreateFailedAlertViewWithFailedInfo:@"当前图层查询服务不可用" andWithMessage:nil];
                return;
            }
            
            self.IdentifyTask = [AGSIdentifyTask identifyTaskWithURL:MapUrl];
            [MapUrl release];
            //self.IdentifyTask = [AGSIdentifyTask identifyTaskWithURL: [NSURL URLWithString:url]];
            self.IdentifyTask.delegate = self;
            AGSIdentifyParameters* identifyParams = [[AGSIdentifyParameters alloc] init];
            //the layer we want is layer ‘5’ (from the map service doc)
            if ([LayerEnname isEqualToString:@"GTL_TDLYXZ"])
            {
                // 土地利用现状图层
                // 目前只查一个图层
                identifyParams.layerIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],nil];
            }
            else if ([LayerEnname isEqualToString:@"jzdjtheme"])
            {
                // 城镇基准地价
                identifyParams.layerIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2],[NSNumber numberWithInt:3],nil];
            }
            else if ([LayerEnname isEqualToString:@"GTL_HZTDLYZTGH"])
            {
                // 土地利用总体规划
                identifyParams.layerIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:1],nil];
            }
            
            
            identifyParams.tolerance = 0;
            AGSGeometryEngine *engine = [[[AGSGeometryEngine alloc] init] autorelease];
            if (SelectedLandGraphic != nil) {
                identifyParams.geometry = SelectedLandGraphic.geometry;
            }else {
                identifyParams.geometry = [engine simplifyGeometry:_sketchLayer.geometry];
            }
            [_LandAnalyseGeometryQueue enqueue:identifyParams.geometry];
            identifyParams.size = self.BaseMapView.bounds.size;
            identifyParams.mapEnvelope = self.BaseMapView.fullEnvelope;
            identifyParams.returnGeometry = YES;
            identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
            identifyParams.spatialReference = [serviceInfo spatialReference];
            [self.SingleManager setDataLayerFieldReloadDe:self];
            [self.IdentifyTask executeWithParameters:identifyParams];
            [self DisplayLoadingView:self.view TipText:@"正在查询图层信息,请稍后..."];
        }
        else {
            [DataMan CreateFailedAlertViewWithFailedInfo:@"专题图层地址不正确" andWithMessage:nil];
            return;
        }
        
        /*commented by niurg 2012-09-17
         int nTotalCnt = [SingleManager.MapLayerDataArray count];
         for (int nCnt = 0; nCnt < nTotalCnt; nCnt++)
         {
         DBMapLayerDataItem *MapLayerData = [SingleManager.MapLayerDataArray objectAtIndex:nCnt];
         // 对现状图层进行查询
         if ([MapLayerData.Name isEqualToString:@"惠州市土地利用现状"])
         {
         NSString *url = MapLayerData.MapUrl;
         NSURL *MapUrl = [[NSURL alloc] initWithString:url];
         // 检测主机是否可到达
         bNetConn = [DataMan GetHostNetStatus:[MapUrl host]];
         if (!bNetConn) {
         [DataMan CreateFailedAlertViewWithFailedInfo:@"GIS服务器不可到达" andWithMessage:nil];
         return;
         }
         NSError *err = nil;
         AGSMapServiceInfo *serviceInfo = [AGSMapServiceInfo mapServiceInfoWithURL:MapUrl error:&err];
         
         if (!serviceInfo) {
         [DataMan CreateFailedAlertViewWithFailedInfo:@"当前图层查询服务不可用" andWithMessage:nil];
         return;
         }
         
         // 首先检测有无字段显示数据
         NSString *DataLayerId = [MapLayerData Id];
         id value = [[DataMan PhyLayerIdToFieldsDic] objectForKey:DataLayerId];
         if (value == nil) {
         // no data,to download
         [DataMan CallCommonGeoverService:DataLayerId PhyLayerUrl:MapLayerData.MapUrl];
         }
         
         self.IdentifyTask = [AGSIdentifyTask identifyTaskWithURL:MapUrl];
         [MapUrl release];
         //self.IdentifyTask = [AGSIdentifyTask identifyTaskWithURL: [NSURL URLWithString:url]];
         self.IdentifyTask.delegate = self;
         AGSIdentifyParameters* identifyParams = [[AGSIdentifyParameters alloc] init];
         //the layer we want is layer ‘5’ (from the map service doc)
         identifyParams.layerIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2],[NSNumber numberWithInt:3],nil];
         identifyParams.tolerance = 0;
         AGSGeometryEngine *engine = [[[AGSGeometryEngine alloc] init] autorelease];
         if (SelectedLandGraphic != nil) {
         identifyParams.geometry = SelectedLandGraphic.geometry;
         }else {
         identifyParams.geometry = [engine simplifyGeometry:_sketchLayer.geometry];
         }
         identifyParams.size = self.BaseMapView.bounds.size;
         identifyParams.mapEnvelope = self.BaseMapView.fullEnvelope;
         identifyParams.returnGeometry = YES;
         identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
         identifyParams.spatialReference = [serviceInfo spatialReference];
         
         [self.IdentifyTask executeWithParameters:identifyParams];
         [self DisplayLoadingView:self.view TipText:@"正在查询图层信息,请稍后..."];
         break;
         }
         }
         */ //end commented by niurg 2012-09-17
        ////
        AGSCompositeSymbol* compositeSel = [self GetSymbolByFlag:NO];
        AGSGraphic *Graphic = [AGSGraphic graphicWithGeometry:_sketchLayer.geometry symbol:compositeSel attributes:nil infoTemplateDelegate:nil];
        
        // add pushpin to graphics layer
        [self.graphicsLayer addGraphic:Graphic];
        
        nMeasureFlag = 0;
        _BaseMapView.touchDelegate = self;
        //_sketchLayer.geometry = nil;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
        //[self StopMeasureOperation];
        [self.graphicsLayer dataChanged];
    }
    //-------
}

#pragma mark 区域地块属性通用查询（查询选中的专题图层）
- (IBAction)XianZhuangBtnTouched:(id)sender {
    UIButton *btn = (UIButton*)sender;
    UIImage *image;
    [self LastClickButtonCancel:btn ClearGraphicFlg:YES];
    if (bIsXianZhuangBtnTouched) {
        image = [UIImage imageNamed:@"NowStatusTopBtn.png"];
    }
    else {
        image = [UIImage imageNamed:@"NowStatusTopBtn2.png"];
    }
    bIsXianZhuangBtnTouched = !bIsXianZhuangBtnTouched;
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    
    if (bIsXianZhuangBtnTouched) {
        // 提示框显示
        [self TopTipViewAnimatedApper];
        [TopDataDisplayLabel setText:@"查询: 请您指定某一地块或画测量面确定查询区域"];
        [TopAddMesureBtn setHidden:YES];
    }
    else {
        [self TopTipViewAnimatedDissapper];
        [TopDataDisplayLabel setText:@""];
        return;
    }
}

// 地价查询
- (IBAction)ViewPriceBtnTouched:(id)sender {
    UIButton *btn = (UIButton*)sender;
    UIImage *image;
    [self LastClickButtonCancel:btn ClearGraphicFlg:YES];
    if (bIsPriceBtnTouched) {
        image = [UIImage imageNamed:@"PriceTopBtn.png"];
    }
    else {
        image = [UIImage imageNamed:@"PriceTopBtn2.png"];
    }
    bIsPriceBtnTouched = !bIsPriceBtnTouched;
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    
    if (bIsPriceBtnTouched) {
        // 提示框显示
        [self TopTipViewAnimatedApper];
        [TopDataDisplayLabel setText:@"地价查询:点击屏幕一点查询此位置的地价信息"];
    }
    else {
        [self TopTipViewAnimatedDissapper];
        [TopDataDisplayLabel setText:@""];
    }

}

// stopNumber 参数暂时未使用
- (AGSCompositeSymbol*)GetSymbolWithNumber:(NSInteger)stopNumber UnitText:(NSString*)UnitTextVal TypeFlg:(NSInteger)Flg
{
    AGSCompositeSymbol *cs = [AGSCompositeSymbol compositeSymbol];
    // create outline
    AGSSimpleLineSymbol *sls = [AGSSimpleLineSymbol simpleLineSymbol];
    sls.color = [UIColor whiteColor];
    sls.width = 2;
    sls.style = AGSSimpleLineSymbolStyleSolid;
    
    // create main circle
    AGSSimpleMarkerSymbol *sms = [AGSSimpleMarkerSymbol simpleMarkerSymbol];
    sms.color = [UIColor greenColor];
    sms.outline = sls;
    sms.size = 20;
    
    AGSTextSymbol *ts = [[[AGSTextSymbol alloc] initWithTextTemplate:[NSString stringWithFormat:@"%@",UnitTextVal]
                                                               color:[UIColor blueColor]] autorelease];
    ts.vAlignment = AGSTextSymbolVAlignmentMiddle;
    if (Flg == 1) {
        // 测量线的场合
        ts.hAlignment = AGSTextSymbolHAlignmentLeft;
    }
    else if(Flg == 2){
        // 测量面的场合
        ts.hAlignment = AGSTextSymbolHAlignmentCenter;
    }
    
    if (stopNumber >1000) {
        sms.size = 60;
        sms.color = [UIColor redColor];
        ts.fontSize = 13;
        
    }else if(stopNumber>500 && stopNumber >100 && stopNumber > 50 && stopNumber > 10 && stopNumber) {
        sms.size = 24;
        sms.color = [UIColor blueColor];
        ts.fontSize = 13;
    }else
    {
        sms.size = 20;
        sms.color = [UIColor blackColor];
        ts.fontSize = 12;
    }
    sms.style = AGSSimpleMarkerSymbolStyleCircle;
    //[cs.symbols addObject:sms];
    // add number as a text symbol
    
    ts.fontWeight = AGSTextSymbolFontWeightBold;
    [cs.symbols addObject:ts];
    
    return cs;
}

// 查询属性信息
- (IBAction)ViewInfoBtnTouched:(id)sender {
    UIButton *btn = (UIButton*)sender;
    UIImage *image;
    [self LastClickButtonCancel:btn ClearGraphicFlg:NO];
    if (bIsInfoBtnTouched) {
        image = [UIImage imageNamed:@"InformationTopBtn.png"];
    }
    else {
        image = [UIImage imageNamed:@"InformationTopBtn2.png"];
    }
    bIsInfoBtnTouched = !bIsInfoBtnTouched;
    [btn setBackgroundImage:image forState:UIControlStateNormal];
    
    if (bIsInfoBtnTouched) {
        // 提示框显示
        [self TopTipViewAnimatedApper];
        [TopDataDisplayLabel setText:@"取点查询:点击屏幕一点查询此位置的地块属性信息"];
    }
    else {
        [self TopTipViewAnimatedDissapper];
        [TopDataDisplayLabel setText:@""];
    }

}

#pragma mark  测量计算相关处理
// 测量距离
- (IBAction)polylineTouched:(id)sender 
{
    @try {
        UIButton *btn = (UIButton*)sender;
        UIImage *image;
        [self LastClickButtonCancel:btn ClearGraphicFlg:NO];
        if((nMeasureFlag == 0) || (nMeasureFlag == 2))
        {
            _sketchLayer.geometry = nil;
            _sketchLayer.geometry = [[[AGSMutablePolyline alloc] initWithSpatialReference:_BaseMapView.spatialReference] autorelease];
            bIsMeasureDataCalcuate = YES;
            [self DisplayCaluData:@"点击地图以添加点"];
            image = [UIImage imageNamed:@"MeasureLength2.png"];
            if (nMeasureFlag == 2) 
            {
                UIImage *image2 = [UIImage imageNamed:@"measureArea.png"];
                [AreaBtn setBackgroundImage:image2 forState:UIControlStateNormal];
            }
            nMeasureFlag = 1;
        }
        else {
            [self StopMeasureOperation];
            image = [UIImage imageNamed:@"MeasureLength.png"];
        }
        [btn setBackgroundImage:image forState:UIControlStateNormal];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

// 测量面积
- (IBAction)polygonTouched:(id)sender 
{
    @try {
        UIButton *btn = (UIButton*)sender;
        UIImage *image;
        [self LastClickButtonCancel:btn ClearGraphicFlg:NO];
        if((nMeasureFlag == 0) || (nMeasureFlag == 1))
        {
            _sketchLayer.geometry = nil;
            _sketchLayer.geometry = [[[AGSMutablePolygon alloc] initWithSpatialReference:_BaseMapView.spatialReference] autorelease];
            bIsMeasureDataCalcuate = YES;
            [self DisplayCaluData:@"点击地图以添加点"];
            
            image = [UIImage imageNamed:@"measureArea2.png"];
            if (nMeasureFlag == 1) 
            {
                UIImage *image2 = [UIImage imageNamed:@"MeasureLength.png"];
                [LengthBtn setBackgroundImage:image2 forState:UIControlStateNormal];
            }
            nMeasureFlag = 2;
        }
        else {
            [self StopMeasureOperation];
            image = [UIImage imageNamed:@"measureArea.png"];
        }
        [btn setBackgroundImage:image forState:UIControlStateNormal];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

// 测量距离或面积计算
- (void)MeasureDataCalcuate
{
    @try {
        //Get the sketch geometry
        AGSGeometryEngine *engine = [[[AGSGeometryEngine alloc] init] autorelease];
        AGSGeometry* sketchGeometry = [[_sketchLayer.geometry copy] autorelease]; 
        //AGSGeometry* sketchGeometry = [engine simplifyGeometry:_sketchLayer.geometry];
        if ([sketchGeometry isMemberOfClass:[AGSPolygon class]] ) 
        {
            NSString *string = nil;
            AGSPolygon *poly = (AGSPolygon*)sketchGeometry;
            int nRingCnt = [poly numRings];
            int nCnt = [poly numPointsInRing:0];
            if((nCnt <= 0 ) || (nCnt > 100000) || 
               (nRingCnt <= 0) || (nRingCnt > 100000))
            {
                string = @"点击地图以添加点";
            }
            else if(nCnt == 1){
                string = @"再次点击地图以添加其他点";
            }
            else if(nCnt == 2){
                string = @"再次点击地图以添加其他点";
            }
            else {
                double area = [engine areaOfGeometry:sketchGeometry];
                //double area = [engine shapePreservingAreaOfGeometry:sketchGeometry inUnit:AGSSRUnitKilometer];
                if(area < -0.1)
                {
                    area = -area;
                    area = area / (1000 * 1000);
                    //int nLenth = area / 10;
                    //area = nLenth / 100.0f;
                    string = [NSString stringWithFormat:@"面积:%1.3f 平方公里", area];
                }
                else if(area > 0.1)
                {
                    area = area / (1000 * 1000);
                    
                    string = [NSString stringWithFormat:@"面积:%1.3f 平方公里", area];
                }
            }
            TopDataDisplayLabel.text = string;
        }else if([sketchGeometry isMemberOfClass:[AGSPolyline class]])
        {
            NSString *string = nil;
            AGSPolyline *poLine = (AGSPolyline*)sketchGeometry;
            int nPathCnt = [poLine numPaths];
            int nCnt = [poLine numPointsInPath:0];
            if((nCnt <= 0 ) || (nPathCnt <= 0))
            {
                string = @"点击地图以添加点";
            }
            else if(nCnt == 1){
                string = @"再次点击地图以添加其他点";
            }
            else {
                double length = [engine lengthOfGeometry:sketchGeometry];
                if (length > 0.01) {
                    length = length / 1000;
                    //double length = [engine shapePreservingLengthOfGeometry: poLine inUnit:AGSSRUnitKilometer];
                    string = [NSString stringWithFormat:@"长度:%1.3f 千米", length];
                }
            }
            
            TopDataDisplayLabel.text = string;
        }
        else {
            TopDataDisplayLabel.text = @"无测量数据";
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
}

//重新调整MarkListViewSize
- (void)resetMarkListPopoverViewSize
{
    int nCnt = [[SingleManager MarkDic] count];
    
    if (nCnt == 0) {
        MarkListPopoverView.popoverContentSize = CGSizeMake(240.0, 45);
    }else if (nCnt <= 8) {
        MarkListPopoverView.popoverContentSize = CGSizeMake(240.0, 45 * nCnt);
    }else {
        MarkListPopoverView.popoverContentSize = CGSizeMake(240.0, 360);
    }
    
}

// 标注 MarkBtn.tag = 109
- (void)MarkBtnTouched:(id)sender
{
    UIButton *tappedButton = (UIButton *)sender;
    [self LastClickButtonCancel:tappedButton ClearGraphicFlg:YES];
    //init popoverContentSize
    int nCnt = [[SingleManager MarkDic] count];
    if (nCnt == 0) {
        MarkListPopoverView.popoverContentSize = CGSizeMake(240.0, 45);
    }else if (nCnt <= 8) {
        MarkListPopoverView.popoverContentSize = CGSizeMake(240.0, 45 * nCnt);
    }else {
        MarkListPopoverView.popoverContentSize = CGSizeMake(240.0, 360);
    }
    
    [MarkListPopoverView presentPopoverFromRect:tappedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

// 书签管理
- (IBAction)BookMarkBtnTouched:(id)sender 
{
    @try {
        //UIButton *tappedButton = (UIButton *)sender;
        //[self LastClickButtonCancel:tappedButton];
        NSString *searchText = _SearchBarCtrl.text;
        if([searchText length] > 0)
        {
            if ([BookMarkManager IsBookMarkExist:searchText]) 
            {
                // delete operation
                [BookMarkManager DelBookMarkByObj:searchText];
                [_filteredListContent removeObject:searchText];
                [self DisplayLoadingView:self.view TipText:@"删除书签成功"];
            }
            else {
                // append operation
                [BookMarkManager AddBookMark:searchText];
                [_filteredListContent addObject:searchText];
                [self DisplayLoadingView:self.view TipText:@"添加书签成功"];
            }
            [DBLatelySearchViewContrl ReloadBookMarkData];
        }
        else {
            // 显示标注列表
            [self MarkBtnTouched:sender];
        }
        
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
    return;
}


- (void)SubjectViewDisappearThreadFunc
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        //如果议题界面显示在图层上，则让其隐藏
         if (self.BaseMapView.frame.origin.x == 400)
        {
            CGFloat fHeight = [UIScreen mainScreen].bounds.size.width - Top_Bar_Height - 20;
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.999)
            {
                fHeight = [UIScreen mainScreen].bounds.size.width - Top_Bar_Height;
            }
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            SubjectDataView.frame = CGRectMake(-405, Top_Bar_Height, 433, fHeight);
            self.BaseMapView.frame = CGRectMake(0, 0, SCREEN_WIDTH, fHeight);
            [UIView commitAnimations];
            [self.SubjectView.ClosedBtn setImage:[UIImage imageNamed:@"OpenViewBtn.png"] forState:UIControlStateNormal]; 
            self.SubjectView.bCloseBtnFlg = NO;
            [NSThread sleepForTimeInterval:0.5];
        }
        [self performSelectorOnMainThread:@selector(doCurl) withObject:nil  waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [pool release];
    }
    
    return;
}


- (IBAction)BaseMapBtnTouched:(id)sender 
{
    //需要开线程来做此操作。
    //[NSThread detachNewThreadSelector:@selector(SubjectViewDisappearThreadFunc) toTarget:self withObject:nil];
    //如果议题界面显示在图层上，则让其隐藏
    [self doCurl];
}
#pragma mark 定位到当前位置
- (IBAction)MapLocationBtnTouched:(id)sender 
{
    /*
   if(!self.BaseMapView.gps.enabled)
    {
        //self.BaseMapView.gps.autoPanMode = AGSGPSAutoPanModeOff;
        self.BaseMapView.gps.autoPanMode = AGSGPSAutoPanModeDefault;
        [self.BaseMapView.gps start];
        self.BaseMapView.gps.navigationPointHeightFactor = 0.5;
    }
    else {
        [self.BaseMapView.gps stop]; 
        self.BaseMapView.rotationAngle = 0.0f;
    }*/
    if ([CLLocationManager locationServicesEnabled]) {
        [self.locationManager startUpdatingLocation];
//        if (_isUpdatingLocation) {
//            [self.locationManager stopUpdatingLocation];
//            [self RemoveOrgGpsGraphic];
//            _isUpdatingLocation = NO;
//        }else{
//            [self.locationManager startUpdatingLocation];
//            _isUpdatingLocation = YES;
//        }
        [self.graphicsLayer dataChanged];
    }
}

//清除
- (IBAction)ClearGraphicBtnTouched:(id)sender
{
    UIButton *tappedButton = (UIButton *)sender;
    [self LastClickButtonCancel:tappedButton ClearGraphicFlg:YES];
    [self clearGraphicsBtnClicked:nil];
}

-(void)pinSwitchActionThreadFunc:(id)param
{
    @try {
        NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        NSString * layerName = DEFAULT_MAPLAYER_NAME;
        NSString *layerUrl = [_BaseMapLayersDic objectForKey:layerName];
        
        NSURL *MapUrl = [[NSURL alloc] initWithString:[layerUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        [SingleManager DownloadAllTilesByMapUrl:MapUrl];
        [MapUrl release];
        
        while (YES) {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
        [pool release];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

#pragma mark AGSMapViewLayerDelegate methods
- (void)mapView:(AGSMapView *) mapView failedLoadingLayerForLayerView:(UIView *) layerView baseLayer:(BOOL) baseLayer withError:(NSError *) error
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSString *errMsg = [error localizedDescription];
    if (baseLayer) {
        [DataMan CreateFailedAlertViewWithFailedInfo:@"底图加载失败" andWithMessage:errMsg];

    }
    else {
        [DataMan CreateFailedAlertViewWithFailedInfo:@"专题图层加载失败" andWithMessage:errMsg];

    }
        return;
}
- (void)mapView:(AGSMapView *) mapView failedLoadingWithError:(NSError *)error
{
    return;
}
- (void)mapView:(AGSMapView *) mapView failedLoadingLayerForLayerView:(UIView *) layerView withError:(NSError *)error
{

    return;
}
-(void) mapViewDidLoad:(AGSMapView*)mapView {
    
    return;
}

- (void)mapView:(AGSMapView *) mapView didLoadLayerForLayerView:(UIView *) layerView
{
    //[[[mapView mapLayers] objectAtIndex:0] dataChanged];
    
    return;
}

#pragma mark - AGSTiledLayerTileDelegate
- (void)tiledLayer:(AGSTiledLayer *) layer operationDidGetTile:(NSOperation *) op
{
    return;
}

- (void)tiledLayer:(AGSTiledLayer *) layer operationDidFailToGetTile:(NSOperation *) op
{
    return;
}

// 使所有popover菜单消失
-(void)SetPopoerHiden
{
    if([self.DataMapLayerViewPopover isPopoverVisible])
    {
        [self.DataMapLayerViewPopover dismissPopoverAnimated:NO];
    }
    if ([self.QueryMenuPopoverView isPopoverVisible]) {
        [self.QueryMenuPopoverView dismissPopoverAnimated:NO];
        [self ResetPlayBtn];
    }
    if ([self nModelFlg] == 1) {
        if([self.MeetingViewPopover isPopoverVisible])
        {
            DBMeetingViewController * MeetingContrl = (DBMeetingViewController *)[self.MeetingViewPopover contentViewController];
            [MeetingContrl SetSubPopoverHiden];
            
            [self.MeetingViewPopover dismissPopoverAnimated:NO];
        }
    }
//    else{
//        if ([self.XCDKListViewPopover isPopoverVisible]) {
//            [self.XCDKListViewPopover dismissPopoverAnimated:NO];
//        }
//        if ([self.DBXCGeometryNamePopoverView isPopoverVisible]) {
//            [self.DBXCGeometryNamePopoverView dismissPopoverAnimated:YES];
//        }
//    }
    if ([self.LandAnalysePopoverView isPopoverVisible])
    {
        [self DestroyLandAnalyseViewContrl];
        [self.LandAnalysePopoverView dismissPopoverAnimated:NO];
    }
    if ([self.LandAttributePopoverView isPopoverVisible])
    {
        [self.LandAttributePopoverView dismissPopoverAnimated:NO];
    }
    if ([self.LandDataPopoverView isPopoverVisible])
    {
        [self.LandDataPopoverView dismissPopoverAnimated:NO];
    }
    if ([self.GraphicAttPopoverView isPopoverVisible]) {
        [self.GraphicAttPopoverView dismissPopoverAnimated:NO];
    }
    if ([self.LatelySearchViewPopover isPopoverVisible]) {
        [self.LatelySearchViewPopover dismissPopoverAnimated:NO];
    }
    if ([self.singleDataPopover isPopoverVisible]) {
        [self.singleDataPopover dismissPopoverAnimated:NO];
    }
    if ([self.AllConfPopoverView isPopoverVisible]) {
        [self.AllConfPopoverView dismissPopoverAnimated:NO];
    }
    if ([self.LatelySearchViewPopover isPopoverVisible]) {
        [self.LatelySearchViewPopover dismissPopoverAnimated:NO];
    }
    if ([self.AllConfPopoverView isPopoverVisible]) {
        [self.AllConfPopoverView dismissPopoverAnimated:NO];
    }
    /* chg by niurg 2012.08.21
    if ([self.LatelySearchViewPopover isPopoverVisible])
    {
        [self.LatelySearchViewPopover dismissPopoverAnimated:NO];
        _SearchBarCtrl.text = nil;
        if (DBLatelySearchViewContrl.nDataSourceFlg != 0 ) 
        {
            DBLatelySearchViewContrl.nDataSourceFlg = 0;
            [DBLatelySearchViewContrl ReloadBookMarkData];
        }
    }
    */
    if ([self.MarkListPopoverView isPopoverVisible]) {
        [self.MarkListPopoverView dismissPopoverAnimated:NO];
    }
    

    // add by niurg 2015.9
    if (!_mapToolsView.isHidden) {
        [_mapToolsView setHidden:YES];
    }
    // end
    
    return;
}
#pragma mark - AGSIdentify 查询结果代理
- (void)identifyTask:(AGSIdentifyTask *) identifyTask operation: (NSOperation *) op didExecuteWithIdentifyResults:(NSArray *) results 
{
    //BOOL bHas = NO;
    AGSGeometry *geometry = nil;
    if ([identifyTask isEqual:self.IdentifyTask ]) {
        geometry = [_LandAnalyseGeometryQueue dequeue];
    }
    @try {
        // 使所有popover菜单消失(搜索popover不关闭)
        [self SetPopoerHiden];
        //clear previous results
        //[self.graphicsLayer removeAllGraphics];
        
        //    AGSSimpleFillSymbol *fillSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        //    fillSymbol.style = AGSSimpleLineSymbolStyleSolid;
        //    fillSymbol.color = [UIColor orangeColor];
        //    AGSGraphic *gra = [featureSet.features objectAtIndex:i];
        //    gra.symbol = fillSymbol;
        
        //add new results
        //    AGSSymbol* symbol = [AGSSimpleFillSymbol simpleFillSymbol];
        //    symbol.color = [UIColor orangeColor];
        //    for (AGSIdentifyResult* result in results) 
        //    {
        //        result.feature.symbol = symbol;
        //        [self.graphicsLayer addGraphic:result.feature];
        //    }
        //    //call dataChanged on the graphics layer to redraw the graphics
        //    [self.graphicsLayer dataChanged];
        float fWidth = 400.0f;
        float fHeight = 500.0f;
        float fXpos = 0.0f;
        float fYpos = 748 - fHeight + 45.0f;
        CGRect frame2 = CGRectMake(fXpos, fYpos, fWidth, fHeight);
        
        if (bIsPriceBtnTouched || bIsInfoBtnTouched) {
            /// 高亮显示当前查询的graphic的颜色
            //int nTotalCnt = [results count];
            AGSIdentifyResult* result;
            for (result in results) 
            {
                //AGSSymbol* symbol = [AGSSimpleFillSymbol simpleFillSymbol];
                //AGSSymbol *symbol = [AGSSimpleLineSymbol simpleLineSymbolWithColor:[UIColor redColor] width:2];
                //symbol.color = [UIColor orangeColor];
                //result.feature.symbol = symbol;
                AGSCompositeSymbol* compositeSel = [self GetSymbolByFlag:YES];
                [result.feature setSymbol:compositeSel];
                //[self.graphicsLayer addGraphic:result.feature];
                // 追加到最底层
                [self.graphicsLayer.graphics insertObject:result.feature atIndex:0];
                [self.graphicsLayer dataChanged];
            }
        }
        
        if ([results count] <= 0) {
            // 无信息
            return;
        }

        NSString *url = [[identifyTask URL] absoluteString];
        // 通用查询
        if ((bIsPlanBtnTouched) || (bIsInfoBtnTouched))
        {
            DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
            //DBMapLayerDataItem *MapLayerData = [[DataMan MapLayerDataArray] objectAtIndex:[DataMan nCurrentSelRadioBtnIndex]];
            DBMapLayerDataItem *MapLayerData = [self GetMapLayerDataItemByUrl:url];
            if (MapLayerData == nil) {
                return;
            }
          //  NSString *DataLayerId = [MapLayerData Id];
           // id FidldData = [[DataMan PhyLayerIdToFieldsDic] objectForKey:DataLayerId];
            
            [DataMan setDataLayerFieldReloadDe:self];
            // draw Geometry
            if (bIsPlanBtnTouched) {
                for (AGSIdentifyResult *result in results) {
                    AGSGeometry *geo = result.feature.geometry;
                    [self drawGeometry:geo];
                    if ([MapLayerData.ENNAME isEqualToString:@"GTL_HZTDLYZTGH "]) {
                        NSString *temp = [result.feature.attributes objectForKey:@"TBH"];
                        temp = temp.length <= 0 ? @"无图斑号" : temp;
                        NSString *TBH = [temp isEqualToString:@"null"] ? @"无图斑号" : temp;
                        NSString *text = [NSString stringWithFormat:@"%@",TBH];
                        [self addText:text forGeometry:geo];
                    }else if([MapLayerData.ENNAME isEqualToString:@"GTL_TDLYXZ"]){
                        NSString *temp = [result.feature.attributes objectForKey:@"图斑编号"];
                        temp = temp.length <= 0 ? @"无图斑编号" : temp;
                        NSString *TBH = [temp isEqualToString:@"null"] ? @"无图斑编号" : temp;
                        NSString *text = [NSString stringWithFormat:@"%@",TBH];
                        [self addText:text forGeometry:geo];
                    }
                    
                }
                [self.graphicsLayer dataChanged];
            }
            
            if ([results count] == 1) 
            {
                // 查询出1个结果的场合
                [LandDataViewContrl setResultSets:results];
                [LandDataViewContrl setNTypeFlg:0];
                // 根据此URL获取对应的要显示的字段
                [LandDataViewContrl setDataMapUrl:url];
                frame2.size.width -= 160;
        
                    DBSingleLandInfoViewController *singleLandInfo = [[DBSingleLandInfoViewController alloc] initWithResult:[results objectAtIndex:0] andENNAME:MapLayerData.ENNAME];
                    singleLandInfo.geometry = _sketchLayer.geometry;
                    singleLandInfo.delegate = self;
                    [self popoverWithViewController:singleLandInfo];
    
            }
            else {
                // 查询出多个结果的场合
                [self CreateLandAnalyseViewContrl];
                [DBLandAnalyseViewContrl setDataMapUrl:url];
                [DBLandAnalyseViewContrl setENNAME:MapLayerData.ENNAME];
                
                [DBLandAnalyseViewContrl setNType:0];
                [DBLandAnalyseViewContrl setResultSets:results];
                [DBLandAnalyseViewContrl setGeometry:geometry];
                [_LandAnalysePopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
//                // 首先检测有无字段显示数据
//                if (FidldData == nil) {
//                    // 没有Field信息，去库中查询.
//                    [DataMan DownloadDisplayPhyLayersFieldsByThemeID:DataLayerId PhyLayerUrl:MapLayerData.MapUrl ViewFlg:@"1"];
//                }
//                else
//                {
//                    [_LandAnalysePopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
//                }

            }
        }
        //else if (!bIsXianZhuangBtnTouched && !bIsPriceBtnTouched)
//        else if (bIsPlanBtnTouched)
//        {
//            // 现状分析
//            [self CreateLandAnalyseViewContrl];
//            [DBLandAnalyseViewContrl setNType:1];
//            [DBLandAnalyseViewContrl setGeometry:geometry];
//            [DBLandAnalyseViewContrl setResultSets:results];
//            [_LandAnalysePopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
//        }
        else if (bIsPriceBtnTouched)
        {
            // 显示地价信息
            [LandAttributeViewContrl setPriceResults:results]; 
            frame2.size.width = 365.0f;
            frame2.size.height = 280.0f;
            frame2.origin.y = 768.0f - frame2.size.height;
            [_LandAttributePopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];  
        }
        
        //////
         _sketchLayer.geometry = nil;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        if ([results count] > 0) {
            [HUD setLabelText:@"正在分析服务器返回数据，请等待"];
            [HUD hide:YES afterDelay:1];
        }
        else {
            [HUD setLabelText:@"此位置暂无查询数据"];
            [HUD hide:YES afterDelay:1.2];
        }
    }

    
    return;
}

- (void)identifyTask:(AGSIdentifyTask *) identifyTask	operation: (NSOperation *) op didFailWithError:(NSError *) error 
{
    [self HidLoadingView:self.view afterDelay:0];
    AGSGeometry *geometry = nil;
    if ([identifyTask isEqual:self.IdentifyTask ]) {
        geometry = [_LandAnalyseGeometryQueue dequeue];
    }
    
    NSString *errMsg = nil;
    if ([error code]  == 500) {
        errMsg = @"不能运行查询，无效的查询参数";
    }
    else if([error code] == -1001){
        errMsg = @"请求超时，请确认地图服务处于正常运行状态";
    }
    else {
        //errMsg = [error localizedDescription];
        errMsg = @"GIS查询服务处理错误";
    }
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    [DataMan CreateFailedAlertViewWithFailedInfo:errMsg andWithMessage:nil];
    
    return;
}
#pragma mark - AGSMapViewTouchDelegate
#pragma mark 地图点击响应事件
-(void)mapView:(AGSMapView *) mapView didClickAtPoint:(CGPoint) screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *) graphics
{
    @try {
        // 使所有popover菜单消失(搜索popover不关闭)
        [self SetPopoerHiden];
        [_SearchBarCtrl resignFirstResponder];
        if (bIsPriceBtnTouched) 
        {
            DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
            BOOL bNetConn = [DataMan InternetConnectionTest];
            if (!bNetConn) {
                [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
                return;
            }
            // 地价查询
            if (mappoint) 
            {
                int nTotalCnt = [SingleManager.MapLayerDataArray count];
                for (int nCnt = 0; nCnt < nTotalCnt; nCnt++) 
                {
                    DBMapLayerDataItem *MapLayerData = [SingleManager.MapLayerDataArray objectAtIndex:nCnt];
                    //不是真正的地价服务，需要讨论。
                    if ([MapLayerData.ENNAME isEqualToString:@"jzdjtheme"])
                    {
                        NSString *url = MapLayerData.MapUrl;
                        NSURL *MapUrl = [[NSURL alloc] initWithString:url];
                        // 检测主机是否可到达
                        bNetConn = [DataMan GetHostNetStatus:[MapUrl host]];
                        if (!bNetConn) {
                            [DataMan CreateFailedAlertViewWithFailedInfo:@"GIS服务器不可到达" andWithMessage:nil];
                            return;
                        }
                        NSError *err = nil;
                        AGSMapServiceInfo *serviceInfo = [AGSMapServiceInfo mapServiceInfoWithURL:MapUrl error:&err];
                        
                        if (!serviceInfo) {
                            [DataMan CreateFailedAlertViewWithFailedInfo:@"地价查询服务不可用" andWithMessage:nil];
                            return;
                        }
                        
                        self.IdentifyTask = [AGSIdentifyTask identifyTaskWithURL: MapUrl];
                        [MapUrl release];
                        
                        //self.IdentifyTask = [AGSIdentifyTask identifyTaskWithURL: [NSURL URLWithString:url]];
                        self.IdentifyTask.delegate = self;
                        AGSIdentifyParameters* identifyParams = [[AGSIdentifyParameters alloc] init];
                        //the layer we want is layer ‘5’ (from the map service doc)
                        identifyParams.layerIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2],[NSNumber numberWithInt:3],nil];
                        identifyParams.tolerance = 0;
                        identifyParams.geometry = mappoint;
                        identifyParams.size = self.BaseMapView.bounds.size;
                        identifyParams.mapEnvelope = self.BaseMapView.fullEnvelope;
                        identifyParams.returnGeometry = YES;
                        identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
                        identifyParams.spatialReference = [serviceInfo spatialReference];
                        
                        [self.IdentifyTask executeWithParameters:identifyParams];
                        [self DisplayLoadingView:self.view TipText:@"地价查询中,请稍后..."];
                        break;
                    }
                }

            }
        }
        //else if(bIsXianZhuangBtnTouched)
        else if(bIsInfoBtnTouched)
        {
            DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
            [DataMan setDBDKInfoQueryDeg:self];
            [DataMan QuaryRelationLandByGeometry:mappoint];
            return;
            
            BOOL bNetConn = [DataMan InternetConnectionTest];
            if (!bNetConn) {
                [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:@"网络未连接状态"];
                return;
            }
            // 查询图层的信息
            if (mappoint) 
            {
                _sketchLayer.geometry = nil;
                
                // 得到最顶层专题图层的URL  del by niurg 2012-09-17
                if ([DataMan nCurrentSelRadioBtnIndex] < 0) {
                    [DataMan CreateFailedAlertViewWithFailedInfo:@"请指定一个要查询的专题图层" andWithMessage:nil];
                    return;
                }
                DBMapLayerDataItem *MapLayerData = [[DataMan MapLayerDataArray] objectAtIndex:[DataMan nCurrentSelRadioBtnIndex]];
                NSString *url = [MapLayerData MapUrl];
                if ([url length] > 0) 
                {
                    NSURL *MapUrl = [[NSURL alloc] initWithString:url];
                    // 检测主机是否可到达
                    bNetConn = [DataMan GetHostNetStatus:[MapUrl host]];
                    if (!bNetConn) {
                        [DataMan CreateFailedAlertViewWithFailedInfo:@"GIS服务器不可到达" andWithMessage:nil];
                        return;
                    }
                    NSError *err = nil;
                    AGSMapServiceInfo *serviceInfo = [AGSMapServiceInfo mapServiceInfoWithURL:MapUrl error:&err];
                    
                    if (!serviceInfo) {
                        [DataMan CreateFailedAlertViewWithFailedInfo:@"当前图层查询服务不可用" andWithMessage:nil];
                        return;
                    }
                    
//                     // 首先检测有无字段显示数据
//                     NSString *DataLayerId = [MapLayerData Id];
//                     id value = [[DataMan PhyLayerIdToFieldsDic] objectForKey:DataLayerId];
//                     if (value == nil) {
//                         // no data,to download
//                         [DataMan CallCommonGeoverService:DataLayerId PhyLayerUrl:url ViewFlg:@"2"];
//                     }
                     
                    self.IdentifyTask = [AGSIdentifyTask identifyTaskWithURL: MapUrl];
                    [MapUrl release];
                    self.IdentifyTask.delegate = self;
                    AGSIdentifyParameters* identifyParams = [[AGSIdentifyParameters alloc] init];
                    //the layer we want is layer ‘5’ (from the map service doc)
                    identifyParams.layerIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:0],nil];
                    identifyParams.tolerance = 0;
                    identifyParams.geometry = mappoint;
                    identifyParams.size = self.BaseMapView.bounds.size;
                    identifyParams.mapEnvelope = self.BaseMapView.fullEnvelope;
                    identifyParams.returnGeometry = YES;
                    identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
                    identifyParams.spatialReference = [serviceInfo spatialReference];
                    
                    [self.IdentifyTask executeWithParameters:identifyParams];
                    [self DisplayLoadingView:self.view TipText:@"正在查询图层信息，请稍后..."];
                }
                else {
                    [DataMan CreateFailedAlertViewWithFailedInfo:@"无可用查询图层" andWithMessage:nil];
                }
                
                /* begin 
                int nTotalCnt = [SingleManager.MapLayerDataArray count];
                for (int nCnt = 0; nCnt < nTotalCnt; nCnt++) 
                {
                    DBMapLayerDataItem *MapLayerData = [SingleManager.MapLayerDataArray objectAtIndex:nCnt];
                    if ([MapLayerData.Caption isEqualToString:@"土地利用现状"]) 
                    {
                        NSString *url = MapLayerData.MapUrl;
                        //NSString *url = @"http://172.16.200.5:8399/arcgis/rest/services/ZWWZT/GTL_TDLYXZ/MapServer";
                        NSURL *MapUrl = [[NSURL alloc] initWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                        self.IdentifyTask = [AGSIdentifyTask identifyTaskWithURL: MapUrl];
                        [MapUrl release];
                        //self.IdentifyTask = [AGSIdentifyTask identifyTaskWithURL: [NSURL URLWithString:url]];
                        self.IdentifyTask.delegate = self;
                        AGSIdentifyParameters* identifyParams = [[AGSIdentifyParameters alloc] init];
                        //the layer we want is layer ‘5’ (from the map service doc)
                        identifyParams.layerIds = [NSArray arrayWithObjects:[NSNumber numberWithInt:1], [NSNumber numberWithInt:2],[NSNumber numberWithInt:3],nil];
                        identifyParams.tolerance = 0;
                        identifyParams.geometry = mappoint;
                        identifyParams.size = self.BaseMapView.bounds.size;
                        identifyParams.mapEnvelope = self.BaseMapView.fullEnvelope;
                        identifyParams.returnGeometry = YES;
                        identifyParams.layerOption = AGSIdentifyParametersLayerOptionAll;
                        identifyParams.spatialReference = self.BaseMapView.spatialReference;
                        
                        [self.IdentifyTask executeWithParameters:identifyParams];
                        [self DisplayLoadingView:self.view TipText:@"正在查询图层信息，请稍后..."];
                        break;
                    }
                }
                */ //end
            }
        }
        
//        // 设置点击的graphic状态
//        if ([graphics count] > 0) {
//            id graLayer = [graphics objectForKey:@"graphicsLayer"];
//            if (graLayer != nil) 
//            {
//                NSArray *geoArr = (NSArray*)graLayer;
//                AGSGraphic *gra = [geoArr objectAtIndex:0];
//                // 查询现状图层的信息
//                float fWidth = 400.0f;
//                float fHeight = 500.0f;
//                float fXpos = 0.0f;
//                float fYpos = 748 / 2 - fHeight / 2;
//                CGRect frame2 = CGRectMake(fXpos, fYpos, fWidth, fHeight);
//                
//                [LandDataViewContrl setNTypeFlg:1];
//                [LandDataViewContrl setGraphic:gra];
//                [_LandDataPopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
//                
//            }
//            
//        }

        /////////// 设置graphic颜色状态
        for (AGSGraphic *graphic in self.graphicsLayer.graphics) 
        {
            if ([graphic isKindOfClass:[DBAGSGraphic class]])
            {
                DBAGSGraphic *RealGraphic = (DBAGSGraphic *)graphic;
                if (RealGraphic.TypeFlg == 2) {
                    /* code to act on each element as it is returned */
                    BOOL bHasValue = NO;
                    NSEnumerator *enumerator = [graphics keyEnumerator];
                    id key;
                    while ((key = [enumerator nextObject])) 
                    {
                        // code that uses the returned key 
                        NSArray *GraphicArr = [graphics valueForKey:key];
                        
                        for(AGSGraphic * Graphic in GraphicArr)
                        {
                            if([Graphic isEqual:RealGraphic])
                            {
                                bHasValue = YES;
                            }
                        }
                    }
                    
                    // 如果存在则设置选中
                    if(bHasValue)
                    {
                        RealGraphic.bIsHighlighted = YES;
                        // chg by niurg 2016.02.16 begin
                        //                        RealGraphic.symbol.color = [[UIColor redColor] colorWithAlphaComponent:0.40];
                        AGSSimpleFillSymbol *outerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
                        outerSymbol.color = [UIColor clearColor];
                        outerSymbol.outline.color = [UIColor redColor];
                        [outerSymbol.outline setWidth:5.0f];
                        RealGraphic.symbol = RealGraphic.outerSelectedSymbol;
                        // end
                    }
                    else {
                        RealGraphic.bIsHighlighted = NO;
                        // chg by niurg 2016.02.16 begin
                        //                        RealGraphic.symbol.color = [[UIColor yellowColor] colorWithAlphaComponent:0.25];
                        AGSSimpleFillSymbol *outerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
                        //    outerSymbol.color = [[UIColor yellowColor] colorWithAlphaComponent:0.25];
                        outerSymbol.color = [UIColor clearColor];
                        outerSymbol.outline.color = [UIColor purpleColor];
                        [outerSymbol.outline setWidth:5.0f];
                        RealGraphic.symbol = RealGraphic.outerNoSelectedSymbol;
                        // end
                    }
                }
            }
        }

        // 在选中的列表中查找，没有的从中移除并改变状态。
        NSEnumerator *enumerator1 = [SelectedGraphics objectEnumerator];
        AGSGraphic * anObject;
        
        AGSCompositeSymbol* compositeSel = [self GetSymbolByFlag:YES];
        AGSCompositeSymbol* compositeNoSel = [self GetSymbolByFlag:NO]; 
        
        while (anObject = [enumerator1 nextObject]) 
        {
            /* code to act on each element as it is returned */
            bool bHasValue = false;
            NSEnumerator *enumerator = [graphics keyEnumerator];
            id key;
            while ((key = [enumerator nextObject])) 
            {
                // code that uses the returned key 
                NSArray *GraphicArr = [graphics valueForKey:key];
                
                for(AGSGraphic * Graphic in GraphicArr)
                {
                    if([Graphic isEqual:anObject])
                    {
                        bHasValue = YES;
                    }
                }
            }
            
            // 如果存在则设置选中
            if(bHasValue)
            {
                [anObject setSymbol:compositeSel];
            }
            else {
                [anObject setSymbol:compositeNoSel];
            }
        }
        ////////// 追加大头针 begin
//        BOOL bRet = [[_BaseMapSwitchView AddPinOnMapSwitch] isOn];
        BOOL bRet = [_mapToolsView bIsAddMarkEditing];
        if (bRet)
        {
            //判断上次点击的标注是否保存，如果没保存就不能继续添加标注。
            for (int i = 0; i < SingleManager.MarkDic.count; i++) {
                DBMarkData *mark = [SingleManager.MarkDic.allValues objectAtIndex:i];
                if (mark.MarkName.length == 0) {
                    self.BaseMapView.callout.hidden = NO;
                    [SingleManager CreateFailedAlertViewWithFailedInfo:@"标注名称不能为空，请添加标注名称并保存或者取消此标注！" andWithMessage:nil];
                    return;
                }
            }
            //让所有的标注恢复原来的状态（未选中）。
            [self IsGraphicHighlighted];
            // create our geometry array if needed
            if (self.geometryArray == nil) {
                self.geometryArray = [NSMutableArray array];
            }
            
            // add user-clicked point to the geometry array
            [self.geometryArray addObject:mappoint];
            
            // create pushpins array if needed
            if (self.pushpins == nil) {
                self.pushpins = [NSMutableArray array];
            }
            
            // create a PictureMarkerSymbol (pushpin)
            //新添加的标注默认为选中状态（为红色）
            AGSPictureMarkerSymbol *pt = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"MarkPin.png.png"];
            
            
            // this offset is to line the symbol up with the map was actually clicked
//            pt.xoffset = 8;
//            pt.yoffset = -16;
            
            pointInfoTemplate *pointTemplate = [[pointInfoTemplate alloc] init];            
            DBAGSGraphic *pushpin = [DBAGSGraphic graphicWithGeometry:mappoint symbol:pt attributes:nil infoTemplateDelegate:pointTemplate]; 
            pushpin.TypeFlg = 0; 
            pushpin.bIsHighlighted = YES;
            //设置唯一的ID
            pushpin.MarkID = [NSString stringWithFormat:@"%lf", mappoint.x + mappoint.y];
            //设置MarkInfo
            DBMarkData *Mark = [[DBMarkData alloc] init];
            Mark.MarkID = pushpin.MarkID;
            Mark.MarkName = @"";
            Mark.MarkNote = @"";
            Mark.MarkCoordinateX = [NSString stringWithFormat:@"%lf", mappoint.x];
            Mark.MarkCoordinateY = [NSString stringWithFormat:@"%lf", mappoint.y];
            //存储标注的时候，优先检测参考系的WKID(NSUInteger类型，要用%u)；如果WKID等于0，那正常情况下肯定是有WKT的；如果两者都没有就直接为nil。同样读取的时候(- (void)AddMarkData)，也要这样做。
            AGSSpatialReference *SpRe = self.BaseMapView.spatialReference;
            if (SpRe.wkid != 0) {
                Mark.MarkSpatialReferenceWKID = [NSString stringWithFormat:@"%u", SpRe.wkid];
                Mark.MarkSpatialReferenceWKT = nil;
            }else{
                if (SpRe.wkt != nil){
                    Mark.MarkSpatialReferenceWKID = @"";
                    Mark.MarkSpatialReferenceWKT = SpRe.wkt;
                }else {
                    Mark.MarkSpatialReferenceWKID = @"";
                    Mark.MarkSpatialReferenceWKT = nil;
                }
            }
            //Mark.Point = mappoint;
            [SingleManager.MarkDic setValue:Mark forKey:Mark.MarkID];
            //DBAGSGraphic *pushpin = [[AGSGraphic alloc] initWithGeometry:mappoint symbol:pt attributes:nil infoTemplateDelegate:nil];
            
            // add pushpin to our array
            [self.pushpins addObject:pushpin];
            
            //插入大头针的同时显示callout。
            CGPoint point;
            point.x = 0;
            point.y = 0;
            self.BaseMapView.callout.customView = nil;
            [self.MarkNoteViewContrl MarkNoteViewWillAppearByGraphicID:pushpin.MarkID andWithCancelFalg:101];
            self.BaseMapView.callout.customView = MarkNoteViewContrl.view;
            [self.BaseMapView.callout showCalloutAt:mappoint pixelOffset:point animated:YES];
            
            // add pushpin to graphics layer
            [self.graphicsLayer addGraphic:pushpin];
            
            // let the graphics layer know it needs to redraw
            [self.graphicsLayer dataChanged];
            //重新调整MarkListViewSize
            [self resetMarkListPopoverViewSize];
            // increment the number of points the user has clicked
            _numPoints++;
        }
        ////////// 追加大头针end
        [self.graphicsLayer dataChanged];
        ///////画线
        /*
         //find which graphic to modify
         NSEnumerator *enumerator = [graphics objectEnumerator];
         NSArray* graphicArray = (NSArray*) [enumerator nextObject];
         if(graphicArray!=nil && [graphicArray count]>0){
         //Get the graphic's geometry to the sketch layer so that it can be modified
         self.activeGraphic = (AGSGraphic*)[graphicArray objectAtIndex:0];
         AGSGeometry* geom = [[self.activeGraphic.geometry mutableCopy] autorelease];
         
         //Feed the graphic's geometry to the sketch layer so that user can modify it
         _sketchLayer.geometry = geom;
         
         //sketch layer should begin tracking touch events to modify the sketch
         _BaseMapView.touchDelegate = _sketchLayer;
         }*/
        ///////
        
        // project
        //    AGSGeometryEngine *geoEngine = [AGSGeometryEngine defaultGeometryEngine];
        //    AGSSpatialReference *SpaRef = [AGSSpatialReference spatialReferenceWithWKID:4326];
        //    AGSPoint *prjPt = [geoEngine projectGeometry:mappoint toSpatialReference:SpaRef];
        
        ////////// 画大头针
        /*
         AGSPictureMarkerSymbol *Symbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"pushpin.png"];
         
         // this offset is to line the symbol up with the map was actually clicked
         pointInfoTemplate *pointTemplate = [[pointInfoTemplate alloc] init];		
         // init pushpin with the AGSPictureMarkerSymbol we just created
         AGSGraphic *pushpin = [[AGSGraphic alloc] initWithGeometry:mappoint symbol:Symbol attributes:nil infoTemplateDelegate:pointTemplate];
         
         // add pushpin to graphics layer
         [self.graphicsLayer addGraphic:pushpin];		
         // let the graphics layer know it needs to redraw		
         [pushpin release];		
         [self.graphicsLayer dataChanged];
         */
        //////////////
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

    return;
}


- (void)mapView:(AGSMapView *)mapView didTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    if (![self.BaseMapView loaded]) {
        return;
    }
    self.beginPoint = mappoint;
    float Differ = 0.5;
    AGSSpatialReference *spRf = mappoint.spatialReference;
    AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:beginPoint.x ymin:beginPoint.y xmax:beginPoint.x + Differ ymax:beginPoint.y + Differ spatialReference:spRf];
    [_sketchLayer setGeometry:env];
    [self.sketchLayer dataChanged]; 
}

- (void)mapView:(AGSMapView *)mapView didMoveTapAndHoldAtPoint:(CGPoint)screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *)graphics
{
    @try {
        AGSSpatialReference *spRf = mappoint.spatialReference;
        AGSEnvelope *env = [AGSEnvelope envelopeWithXmin:beginPoint.x ymin:beginPoint.y xmax:mappoint.x ymax:mappoint.y spatialReference:spRf];
        [_sketchLayer setGeometry:env];
        [self.sketchLayer dataChanged];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}



- (void)setLandDataViewContrlData:(float)area
{
    if (area != 0 ) {
        NSString *string = [NSString stringWithFormat:@"%1.3f 平方公里", area];
        NSMutableArray *array = [NSMutableArray arrayWithObjects:@"惠州市惠阳区", string, @"5000元每平方米", @"山地", nil];
        LandDataViewContrl.areaOfLandArray = array; 
    }
}
#pragma mark - AGSMapViewLayerDelegate
- (BOOL)mapView:(AGSMapView *) mapView shouldFindGraphicsInLayer:(AGSGraphicsLayer *) graphicsLayer atPoint:(CGPoint) screen mapPoint:(AGSPoint *) mappoint
{
//    BOOL bRet = [[_BaseMapSwitchView AddPinOnMapSwitch] isOn];
    BOOL bRet = [_mapToolsView bIsAddMarkEditing];
    if (bRet) {
        return NO;
    }
    return YES;
}


#pragma mark AGSMapViewCalloutDelegate
- (void)mapView:(AGSMapView *) mapView didClickCalloutAccessoryButtonAtPoint:(AGSPoint *) point
{
//    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
//    for (DBPOIData *POIData in DataMan.POIArray) {
////        if((fabs((float)point.x - POIData.POIx.floatValue) < 0.000001) && (fabs((float)point.y - POIData.POIy.floatValue) < 0.000001)) 
////        {
////            [DBAttributeViewContrl POIInfoViewWillAppearByPOIData:POIData];
////            break;
////        }
//        float xPos = POIData.Point.x;
//        float yPos = POIData.Point.y;
//        
//        float xPos2 = (float)point.x;
//        float yPos2 = (float)point.y;
//        if((fabs(xPos2 - xPos) < 0.000001) && (fabs(yPos2 - yPos) < 0.000001)) 
//        {
//            [DBAttributeViewContrl POIInfoViewWillAppearByPOIData:POIData];
//            break;
//        }
//    }
//    float fWidth = 260.0f;
//    float fHeight = 300.0f;
//    float fXpos = 1024 / 2 - fWidth / 2;
//    float fYpos = 748 / 2 - fHeight / 2;
//    CGRect frame2 = CGRectMake(fXpos, fYpos, fWidth, fHeight);
//    [_GraphicAttPopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
//    return;
}
- (BOOL)mapView:(AGSMapView *) mapView shouldShowCalloutForGraphic:(AGSGraphic *) graphic
{
    //自定义self.BaseMapView.callout.customView，但要记得无论走哪个分支，都需要先让其置为nil.
    DBAGSGraphic *CustomGraphic = (DBAGSGraphic *)graphic;
    if (CustomGraphic.TypeFlg == 0) {
        //标注
        self.BaseMapView.callout.customView = nil;
        CGPoint point;
        point.x = -8;
        point.y = -8;
        [self.MarkNoteViewContrl MarkNoteViewWillAppearByGraphicID:CustomGraphic.MarkID andWithCancelFalg:100];
        //self.BaseMapView.callout.margin = CGSizeMake(0, 10);
        self.BaseMapView.callout.customView = MarkNoteViewContrl.view;
    }else if (CustomGraphic.TypeFlg == 1) {
        //POI
        self.BaseMapView.callout.customView = nil;
    }else if (CustomGraphic.TypeFlg == 2) {
        //地块
        self.BaseMapView.callout.customView = nil;
        [self.LandInfoViewContrl LandInfoViewWillAppearByGraphic:CustomGraphic];
        self.BaseMapView.callout.customView = LandInfoViewContrl.view;
    }
    else if (bIsPriceBtnTouched) {
        self.BaseMapView.callout.customView = nil;
        self.BaseMapView.callout.customView = self.PriceViewController.view;
    }else{
        //将self.BaseMapView.callout.customView设置为空
        self.BaseMapView.callout.customView = nil; 
    }
    
    return YES;
}

- (void)mapViewDidDismissCallout:(AGSMapView *) mapView
{
    return;
}

- (BOOL)mapView:(AGSMapView *) mapView shouldShowCalloutForGPS:(AGSGPS *) gps
{
    return YES;
}
- (void)mapView:(AGSMapView *) mapView didShowCalloutForGraphic:(AGSGraphic *) graphic
{
    NSArray *graphicArray = [self.graphicsLayer graphics];
    DBAGSGraphic *gra = (DBAGSGraphic*)graphic;
    //判断是否为POIGraphic
    for (int i = 0; i < graphicArray.count; i++) 
    {
        AGSGraphic *graphic2 = [graphicArray objectAtIndex:i];
        if ([graphic2 isKindOfClass:[DBAGSGraphic class]])
        {
            DBAGSGraphic *RealGraphic = (DBAGSGraphic *)graphic2;
            if (RealGraphic.TypeFlg == 1 && [gra.ObjectID isEqualToString:RealGraphic.ObjectID]) 
            {
                //判断其他POI是否为高亮状态。
                [self IsGraphicHighlighted];
                RealGraphic.symbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"POIRedPin_small.png"];
                RealGraphic.bIsHighlighted = YES;
                [self.graphicsLayer.graphics exchangeObjectAtIndex:i withObjectAtIndex:graphicArray.count - 1];
                
                // 设置相应的Cell图标为红色选中状态
                NSInteger nIndex = [RealGraphic POIIndex];
                [DBLatelySearchViewContrl SetSelectedCellImage:nIndex];
                break;
            }else if (RealGraphic.TypeFlg == 2 && [RealGraphic.DKBH isEqualToString:gra.DKBsm]) {
                [self IsGraphicHighlighted];
                RealGraphic.symbol.color = [[UIColor redColor] colorWithAlphaComponent:0.40];
                RealGraphic.bIsHighlighted = YES;
                [self.graphicsLayer dataChanged];
                break;
            }else if (RealGraphic.TypeFlg == 0 && [RealGraphic.MarkID isEqualToString:gra.MarkID]) {
                [self IsGraphicHighlighted];
                RealGraphic.symbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"MarkPin.png"];
                RealGraphic.bIsHighlighted = YES;
                [self.graphicsLayer dataChanged];
                break;
            }
        }
    }
    
    return;
}
- (void)mapView:(AGSMapView *) mapView didClickCalloutAccessoryButtonForGraphic:(AGSGraphic *) graphic
{
    float fWidth = 260.0f;
    float fHeight = 300.0f;
    float fXpos = SCREEN_WIDTH / 2 - fWidth / 2;
    float fYpos = 748 / 2 - fHeight / 2;
    CGRect frame2 = CGRectMake(fXpos, fYpos, fWidth, fHeight);
    DBAGSGraphic *gra = (DBAGSGraphic*)graphic;
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    //    int nIndex = [gra POIIndex];
    //    if ((nIndex >= 0)  && (nIndex < [[DataMan POIArray] count])) 
    //    {
    //        DBPOIData *poIData = [[DataMan POIArray] objectAtIndex:nIndex];
    //        [DBAttributeViewContrl POIInfoViewWillAppearByPOIData:poIData];
    //    }
    for (DBPOIData *POIData in DataMan.POIArray) {
        if ([POIData.OID isEqualToString:gra.ObjectID]) {
            [DBAttributeViewContrl POIInfoViewWillAppearByPOIData:POIData];
        }
    }
   
    //[DBAttributeViewContrl SetAttributeData:[graphic attributes]];
    [_GraphicAttPopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
    return;
}
#pragma mark - 等待视图
//创建等待试图框
- (void)CreateWaitingView
{
    _waitingDialog = [[[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"加载中, 请等待.", @"等待窗体标题") delegate:self cancelButtonTitle:nil otherButtonTitles:nil] autorelease];

    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator setCenter:CGPointMake (132.0f, 60.0f)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [activityIndicator startAnimating];
    [_waitingDialog addSubview:activityIndicator];
    [activityIndicator release];
    [_waitingDialog show];
}

- (void)WaitingViewDisAppear
{
    [_waitingDialog dismissWithClickedButtonIndex:0 animated:NO];
}

#pragma mark - DBLocalTileDataManagerDelegate
- (void)POIDidQuery:(NSInteger)nStartIndex EndIndex:(NSInteger)nEndIndex ResponseCode:(NSInteger)nReCode ErrorMessage:(NSString*)ErrMsg;
{
    if (nReCode != 0) {
        // 数据下载失败
        [self DisplayLoadingView:self.view TipText:ErrMsg];
        //[HUD setLabelText:ErrMsg];
        [HUD hide:YES afterDelay:3];
        return;
    }
    @try {
        [DBLatelySearchViewContrl setNDataSourceFlg:2];
        DBLatelySearchViewContrl.QueryWord = _SearchBarCtrl.text;
        [DBLatelySearchViewContrl ReloadBookMarkData];
        [_SearchBarCtrl resignFirstResponder];
        
        // 在地图上定位显示POI数据,删除地图上原有的POI数据
        int count = self.graphicsLayer.graphics.count;
        for (int i = count - 1; i >= 0; i--) 
        {
            AGSGraphic *graphic = [self.graphicsLayer.graphics objectAtIndex:i];
            if ([graphic isKindOfClass:[DBAGSGraphic class]])
            {
                DBAGSGraphic *CustomGraphic = (DBAGSGraphic *)graphic;
                if (CustomGraphic.TypeFlg == 1) 
                {
                    [self.graphicsLayer removeGraphic:graphic];
                }
            }
        }
        
        //[self.graphicsLayer removeAllGraphics];
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        
        // 构造一个poly
        AGSSpatialReference *sRef = self.BaseMapView.spatialReference;
        AGSMutablePolygon *poly = [[AGSMutablePolygon alloc] initWithSpatialReference:sRef];
        [poly addRingToPolygon];
        
        for (int nCnt = nStartIndex; nCnt < nEndIndex; nCnt++) 
        {
            DBPOIData *POIData = [[DataMan POIArray] objectAtIndex:nCnt];
            //double dPosX = [POIData.POIx doubleValue];
            //double dPosY = [POIData.POIy doubleValue];
            //AGSPoint *newPoint = [AGSPoint pointWithX:[POIData.POIx doubleValue] y:[POIData.POIy doubleValue] spatialReference:sRef];
            AGSPoint *newPoint = [POIData Point];
            [poly addPointToRing:[AGSPoint pointWithX:newPoint.x y:newPoint.y spatialReference:sRef]];
            
            //AGSPictureMarkerSymbol *pt = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"PushPin.png"];
            AGSPictureMarkerSymbol *pt = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"POIBluePin_small.png"];
            // this offset is to line the symbol up with the map was actually clicked
            //pt.xoffset = 8;
            //pt.yoffset = -18;
            pointInfoTemplate *pointTemplate = [[pointInfoTemplate alloc] init];
            
            [pointTemplate setTitle:[POIData POIName]];
            NSMutableString *Phone = [NSMutableString string];
            if ([[POIData LXDH] length] > 0) {
                [Phone appendFormat:@"电话:%@", [POIData LXDH]];
            }
            else {
                [Phone appendString:@"电话:"];
            }
            [pointTemplate setDetail:Phone];
            //AGSGraphic *pushpin = [[AGSGraphic alloc] initWithGeometry:newPoint symbol:pt attributes:nil infoTemplateDelegate:pointTemplate];
            //DBAGSGraphic *pushpin = [[DBAGSGraphic alloc] initWithGeometry:newPoint symbol:pt attributes:nil infoTemplateDelegate:pointTemplate];
            DBAGSGraphic *pushpin = [DBAGSGraphic graphicWithGeometry:newPoint symbol:pt attributes:nil infoTemplateDelegate:pointTemplate];  
            
            [pushpin setTypeFlg:1];
            //[pushpin setPOIIndex:nCnt];
            // 设置为POI的索引值
            [pushpin setPOIIndex:[POIData nIndex]];
            [pushpin setObjectID:POIData.OID];
            [pushpin setBIsHighlighted:NO];
            // add pushpin to graphics layer
            [self.graphicsLayer addGraphic:pushpin];      
            //[pushpin release];
        }
        
        // 重新定位地图中心位置
        AGSPoint *CentrPoint = nil;
        NSUInteger PtNum = [poly numPointsInRing:0];
        AGSGeometryEngine *geoEng = [AGSGeometryEngine defaultGeometryEngine];
        if ((PtNum >= 3) && (PtNum < 100000)) {
            // 取得新的label point
            CentrPoint = [geoEng labelPointForPolygon:poly];
        }
        else if(PtNum > 0){
            // 取得第一个点
            CentrPoint = [poly pointOnRing:0 atIndex:0];
        }
        [poly release];
        if (CentrPoint != nil) {
            // 定位
            [self.BaseMapView zoomToScale:80 withCenterPoint:CentrPoint animated:YES];
        }
        
        [self.graphicsLayer dataChanged];
        [self HidLoadingView:self.view afterDelay:0];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        // 返回数据处理失败
        [HUD setLabelText:@"查询数据处理出错"];
        [HUD hide:YES afterDelay:1];
    }
    @finally {
        
    }
}


- (void)ResizeMapLayerPopoverViewSize
{
    int nCnt = [[SingleManager MapLayerDataArray] count];
    CGFloat pHeight = 0;
    if (nCnt == 0) {
        pHeight = 37;
    }else if(nCnt < 10){
        pHeight = 37 *nCnt;
    }else if(nCnt >= 10){
        pHeight = 370.0;
    }
    _DataMapLayerViewPopover.popoverContentSize = CGSizeMake(270, pHeight);
}

- (void)ResizeMeetingPopoverViewSize
{
    int nCnt = [[SingleManager MeetingList] count];
    CGFloat pHeight = 0.0f;
    if (nCnt == 0) {
        pHeight = 35;
    }else if(nCnt < 6){
        pHeight = 70 * nCnt + 40;
    }else if(nCnt >= 6){
        pHeight = 460; 
    }
    _MeetingViewPopover.popoverContentSize = CGSizeMake(320.0, pHeight);
}

- (void)MapLayerPopoverViewDisAppear
{
    if([self.DataMapLayerViewPopover isPopoverVisible])
    {
        [self.DataMapLayerViewPopover dismissPopoverAnimated:NO];
    }
}

- (void)MeetingPopoverViewDisAppear
{
    if([self.MeetingViewPopover isPopoverVisible])
    {
        DBMeetingViewController * MeetingContrl = (DBMeetingViewController *)[self.MeetingViewPopover contentViewController];
        [MeetingContrl SetSubPopoverHiden];
        
        [self.MeetingViewPopover dismissPopoverAnimated:NO];
    }
}

#pragma mark 搜索框代理
// for text field search

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    //如果callout显示在界面上，则让其隐藏
    if (![self.BaseMapView.callout isHidden]) {
        self.BaseMapView.callout.hidden = YES;
    }
    //让tableView显示书签里的内容。
    if (DBLatelySearchViewContrl.nDataSourceFlg != 0 ) {
        DBLatelySearchViewContrl.nDataSourceFlg = 0;
        [DBLatelySearchViewContrl ReloadBookMarkData];
    }
    [_LatelySearchViewPopover presentPopoverFromRect:textField.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    return YES;
}
// became first responder
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    @try {
        //让button恢复到初始化状态
        bIsXianZhuangBtnTouched = NO;
        bIsPlanBtnTouched = NO;
        bIsPriceBtnTouched = NO;
        bIsInfoBtnTouched = NO;
        bIsMeasureDataCalcuate= NO;
        [self setLastClickButtonImage];
        //清除Graphic
        //[self clearGraphicsBtnClicked:nil];
        //DataMapLayerViewPopover Disappeared
        if ([self.DataMapLayerViewPopover isPopoverVisible]) {
            [self.DataMapLayerViewPopover dismissPopoverAnimated:NO];
        }
        //MeetingViewPopover Disappeared
        if([self.MeetingViewPopover isPopoverVisible])
        {
            DBMeetingViewController * MeetingContrl = (DBMeetingViewController *)[self.MeetingViewPopover contentViewController];
            [MeetingContrl SetSubPopoverHiden];
            
            [self.MeetingViewPopover dismissPopoverAnimated:NO];
        }
        if ([self.QueryMenuPopoverView isPopoverVisible]) {
            [self.QueryMenuPopoverView dismissPopoverAnimated:NO];
            [self ResetPlayBtn];
        }
        if([self.MarkListPopoverView isPopoverVisible])
        {
            [self.MarkListPopoverView dismissPopoverAnimated:NO];
        }
        //lengthBtn or areaBtn
        nMeasureFlag = 0;
        _BaseMapView.touchDelegate = self;
        _sketchLayer.geometry = nil;
        [self TopTipViewAnimatedDissapper];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return;
}

// return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    //    [self filterContentForSearchText:textField.text];
    return;
}

// return NO to not change text
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self filterContentForSearchText:textField.text];
    return YES;
}

//- (BOOL)textFieldShouldClear:(UITextField *)textField;               // called when clear button pressed. return NO to ignore (no notifications)
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    //[UIApplication showNetworkActivityIndicator:YES];
    [textField resignFirstResponder];
    _BaseMapView.touchDelegate = self;
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    BOOL bNetConn = [DataMan InternetConnectionTest];
    if (!bNetConn) {
        [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:@"网络未连接状态"];
        return YES;
    }
    
    [self DisplayLoadingView:self.view TipText:@"正在搜索,请稍后..."];
    // query POI
    SingleManager.delegate = self;
    [SingleManager DownLoadPOI:self.SearchBarCtrl.text downLoadFlg:0];
    return YES;
}// called when 'return' key pressed. return NO to ignore.



#pragma mark 旧的查询控件事件处理方法

#pragma mark - 兴趣点查询
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    //[UIApplication showNetworkActivityIndicator:YES];
//    [searchBar resignFirstResponder];
//    _BaseMapView.touchDelegate = self;
//    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
//    BOOL bNetConn = [DataMan InternetConnectionTest];
//    if (!bNetConn) {
//        [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:@"网络未连接状态"];
//        return;
//    }
//    
//    [self DisplayLoadingView:self.view TipText:@"正在搜索,请稍后..."];
//    // query POI
//    SingleManager.delegate = self;
//    [SingleManager DownLoadPOI:self.SearchBarCtrl.text downLoadFlg:0];
//}
//
//- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
//{
//    @try {
//        //让button恢复到初始化状态
//        bIsXianZhuangBtnTouched = NO;
//        bIsPlanBtnTouched = NO;
//        bIsPriceBtnTouched = NO;
//        bIsInfoBtnTouched = NO;
//        bIsMeasureDataCalcuate= NO;
//        [self setLastClickButtonImage];
//        //清除Graphic
//        //[self clearGraphicsBtnClicked:nil];
//        //DataMapLayerViewPopover Disappeared
//        if ([self.DataMapLayerViewPopover isPopoverVisible]) {
//            [self.DataMapLayerViewPopover dismissPopoverAnimated:NO];
//        }
//        //MeetingViewPopover Disappeared
//        if([self.MeetingViewPopover isPopoverVisible])
//        {
//            DBMeetingViewController * MeetingContrl = (DBMeetingViewController *)[self.MeetingViewPopover contentViewController];
//            [MeetingContrl SetSubPopoverHiden];
//            
//            [self.MeetingViewPopover dismissPopoverAnimated:NO];
//        }
//        if ([self.QueryMenuPopoverView isPopoverVisible]) {
//            [self.QueryMenuPopoverView dismissPopoverAnimated:NO];
//            [self ResetPlayBtn];
//        }
//        if([self.MarkListPopoverView isPopoverVisible])
//        {
//            [self.MarkListPopoverView dismissPopoverAnimated:NO];
//        }
//        //lengthBtn or areaBtn
//        nMeasureFlag = 0;
//        _BaseMapView.touchDelegate = self;
//        _sketchLayer.geometry = nil;
//        [self TopTipViewAnimatedDissapper];
//    }
//    @catch (NSException *exception) {
//        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
//    }
//    @finally {
//        
//    }
//
//}
//
//- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
//{
//    [self filterContentForSearchText:searchText];
//    
//    // Return YES to cause the search result table view to be reloaded.
//    return;
//    
//}
//
//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
//{
//    if([text isEqualToString:@"\n"])
//    {
//        [searchBar resignFirstResponder];
//        return  NO;
//    }
//    return YES;
//}
//
//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
//{
//    //如果callout显示在界面上，则让其隐藏
//    if (![self.BaseMapView.callout isHidden]) {
//        self.BaseMapView.callout.hidden = YES;
//    }
//    //让tableView显示书签里的内容。
//    if (DBLatelySearchViewContrl.nDataSourceFlg != 0 ) {
//        DBLatelySearchViewContrl.nDataSourceFlg = 0;
//        [DBLatelySearchViewContrl ReloadBookMarkData];
//    }
//    [_LatelySearchViewPopover presentPopoverFromRect:searchBar.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    
//    return YES;
//}
//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
//{
//    //[_LatelySearchViewPopover dismissPopoverAnimated:NO];
//    
//    return YES;
//}

// 自定义搜索方法
- (void)filterContentForSearchText:(NSString*)searchText
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	
	[_filteredListContent removeAllObjects]; // First clear the filtered array.
	
	/*
	 Search the main list for products whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
	 */
    NSMutableArray *bookMarks = [BookMarkManager GetBookMarks];
    int n = 0;
	for (NSString *bookMark in bookMarks)
	{
        // 进行比较大小
        NSComparisonResult result = [bookMark compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        
        NSRange range = [bookMark rangeOfString:searchText];
        
        
        if((result == NSOrderedSame) || (range.location != NSNotFound))
        {
            [_filteredListContent addObject:bookMark];
            n = 1;
            
        }
	}
    
    [DBLatelySearchViewContrl setNDataSourceFlg:1];
    [DBLatelySearchViewContrl ReloadBookMarkData];
    
}


#pragma mark -
#pragma mark AGSGeometryServiceTaskDelegate Methods

- (void)geometryServiceTask:(AGSGeometryServiceTask *)geometryServiceTask operation:(NSOperation*)op didReturnBufferedGeometries:(NSArray *)bufferedGeometries 
{
	@try {
        [UIApplication showNetworkActivityIndicator:NO];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"结果" message:[NSString stringWithFormat:@"返回 %d 缓存要素", [bufferedGeometries count]] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];

        [av show];
        [av release];
        
        [self.graphicsLayer removeAllGraphics];
        [self.graphicsLayer dataChanged];
        
        // Create a SFS for the inner buffer zone
        AGSSimpleFillSymbol *innerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        innerSymbol.color = [[UIColor redColor] colorWithAlphaComponent:0.40];
        innerSymbol.outline.color = [UIColor darkGrayColor];
        
        // Create a SFS for the outer buffer zone
        AGSSimpleFillSymbol *outerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
        outerSymbol.color = [[UIColor yellowColor] colorWithAlphaComponent:0.25];
        outerSymbol.outline.color = [UIColor darkGrayColor];
        
        // counter to help us determine if the geometry returned is inner/outer
        NSUInteger i = 0;
        
        // NOTE: the bufferedGeometries returned are in order based on buffer distance...
        //
        // so if you clicked 3 points, the order would be:
        // 
        // objectAtIndex		bufferedGeometry
        //
        //		0				pt1 buffered at 100m
        //		1				pt2 buffered at 100m
        //		2				pt3 buffered at 100m
        //		3				pt1 buffered at 300m
        //		4				pt2 buffered at 300m
        //		5				pt3 buffered at 300m
        
        for (AGSGeometry* g	in bufferedGeometries) {
            
            // initialize the graphic for geometry
            AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:g symbol:nil attributes:nil infoTemplateDelegate:nil];
            
            // since we have 2 buffer distances, we know that 0-2 will be 100m buffer and 3-5 will be 300m buffer
            if (i < [bufferedGeometries count]/2) {
                graphic.symbol = innerSymbol;
            }
            else {
                graphic.symbol = outerSymbol;
            }
            
            //AGSGraphic *grcTest = [[AGSGraphic alloc] initWithJSON:DicTest];
            //[grcTest decodeWithJSON:DicTest];
            //
            // add graphic to the graphic layer
            [self.graphicsLayer addGraphic:graphic];
            
            // release our alloc'd graphic
            [graphic release];
            
            // increment counter so we know which index we are at
            i++;
        }
        
        // get rid of the pushpins that were marking our points
        for (AGSGraphic *pushpin in self.pushpins) {
            [self.graphicsLayer removeGraphic:pushpin];
        }
        self.pushpins = nil;
        
        // let the graphics layer know it has new graphics to draw
        [self.graphicsLayer dataChanged];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

// Handle the case where the buffer task fails
- (void)geometryServiceTask:(AGSGeometryServiceTask *)geometryServiceTask operation:(NSOperation*)op didFailBufferWithError:(NSError *)error {
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"错误" message:@"缓存查询任务错误" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];

	[av show];
	[av release];
}


#pragma mark -
#pragma mark DBLatelySearchOrPOIViewDelegate Methods
-(void)POISearchPopoverViewOkeyBtnClicked
{
    //如果callout显示在界面上，则让其隐藏
    if (![self.BaseMapView.callout isHidden]) {
        self.BaseMapView.callout.hidden = YES;
    }
    
    //如果键盘还显示在界面上，则让其消失。
    if (_SearchBarCtrl.isFirstResponder) {
        [_SearchBarCtrl resignFirstResponder];
    }
    //让tableView显示书签里的内容。
    if (DBLatelySearchViewContrl.nDataSourceFlg != 0 ) 
    {
        DBLatelySearchViewContrl.nDataSourceFlg = 0;
        [DBLatelySearchViewContrl ReloadBookMarkData];
    }
    _SearchBarCtrl.text = nil;
    [_LatelySearchViewPopover dismissPopoverAnimated:NO];
}
//判断POIGraphic是否为高亮状态
- (void)IsGraphicHighlighted
{
    NSMutableArray *graphicArray = self.graphicsLayer.graphics;
    for (AGSGraphic *graphic in graphicArray) {
        if ([graphic isKindOfClass:[DBAGSGraphic class]]) {
            DBAGSGraphic *RealGraphic = (DBAGSGraphic *)graphic;
            if (RealGraphic.TypeFlg == 1 && RealGraphic.bIsHighlighted) {
                //POI
                RealGraphic.symbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"POIBluePin_small.png"];
                RealGraphic.bIsHighlighted = NO;
            }else if (RealGraphic.TypeFlg == 2)
            {
                //LandGraphic
                RealGraphic.symbol.color = [[UIColor yellowColor] colorWithAlphaComponent:0.25];
                RealGraphic.bIsHighlighted = NO;
            }else if (RealGraphic.TypeFlg == 0 && RealGraphic.bIsHighlighted) {
                //Mark
                RealGraphic.symbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"MarkBlackPin.png"];
                RealGraphic.bIsHighlighted = NO;
            }
        }
    }
}

//判断graphic是否还存在graphicLayer之上，否则则添加一个graphic
- (void)bIsExistOnGraphicLayer:(DBPOIData *)POI Type:(NSInteger)nType
{
    int i = 0;
    NSMutableArray *graphicArray = self.graphicsLayer.graphics;
    [self IsGraphicHighlighted];    
    for (int j = 0; j < graphicArray.count; j++) {
        AGSGraphic *graphic = [graphicArray objectAtIndex:j];
        if ([graphic isKindOfClass:[DBAGSGraphic class]]) {
            DBAGSGraphic *RealGraphic = (DBAGSGraphic *)graphic;
            if (RealGraphic.TypeFlg == 1 && [POI.OID isEqualToString:RealGraphic.ObjectID]) {
                i++;
                RealGraphic.symbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"POIRedPin_small.png"];
                RealGraphic.bIsHighlighted = YES;
                [self.graphicsLayer.graphics exchangeObjectAtIndex:j withObjectAtIndex:graphicArray.count - 1];
                break;
            }
        }
    }
    
    if (i != 0) {
        return;
    }else {
        //double dPosX = [POI.POIx doubleValue];
        //double dPosY = [POI.POIy doubleValue];
        double dPosX = [[POI Point] x];
        double dPosY = [[POI Point] y];
        AGSSpatialReference *sRef = self.BaseMapView.spatialReference;
        AGSPoint *newPoint = [AGSPoint pointWithX:dPosX y:dPosY spatialReference:sRef];
        NSString *ImageName = nil;
        if (nType == 0) {
            ImageName = @"POIBluePin_small.png";
        }
        else {
            ImageName = @"POIRedPin_small.png";
        }
        AGSPictureMarkerSymbol *pt = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:ImageName];
//        pt.xoffset = 8;
//        pt.yoffset = -18;
        pointInfoTemplate *pointTemplate = [[pointInfoTemplate alloc] init];
        [pointTemplate setTitle:[POI POIName]];
        NSMutableString *Phone = [NSMutableString string];
        if ([[POI LXDH] length] > 0) {
            [Phone appendFormat:@"电话:%@", [POI LXDH]];
        }
        else {
            [Phone appendString:@"电话:"];
        }
        [pointTemplate setDetail:Phone];
        DBAGSGraphic *pushpin = [[DBAGSGraphic alloc] initWithGeometry:newPoint symbol:pt attributes:nil infoTemplateDelegate:pointTemplate];
        [pushpin setTypeFlg:1];
        [pushpin setObjectID:POI.OID];
        [pushpin setBIsHighlighted:YES];
        [self.graphicsLayer addGraphic:pushpin];      
        [pushpin release];
        [self.graphicsLayer dataChanged];
    }
}

- (void)POIAppear:(NSString *)ObjectID Type:(NSInteger)nType
{
    //如果callout显示在界面上，则让其隐藏
    if (![self.BaseMapView.callout isHidden]) {
        self.BaseMapView.callout.hidden = YES;
    }
    AGSPoint *newPoint = nil;
    for (DBPOIData *POI in SingleManager.POIArray) {
        if ([ObjectID isEqualToString:POI.OID]) {
//            self.BaseMapView.callout.title = [POI POIName];
//            NSMutableString *Phone = [NSMutableString string];
//            if ([[POI LXDH] length] > 0) {
//                [Phone appendFormat:@"电话:%@", [POI LXDH]];
//            }
//            else {
//                [Phone appendString:@"电话:"];
//            }
//            self.BaseMapView.callout.detail = Phone;
//            UIImage *LeftImage = [UIImage imageNamed:@"PriceTopBtn.png"];
//            self.BaseMapView.callout.image = LeftImage;
            //newPoint = [AGSPoint pointWithX:[[POI POIx] doubleValue] y:[[POI POIy] doubleValue] spatialReference:self.BaseMapView.spatialReference];
            newPoint = [POI Point];
            [self bIsExistOnGraphicLayer:POI Type:nType];
            break;
        }
    }
    //坐标
    //AGSPoint *newPoint = [AGSPoint pointWithX:pnt.x y:pnt.y spatialReference:self.BaseMapView.spatialReference];
    /*
    [self.graphicsLayer removeAllGraphics];
    AGSPictureMarkerSymbol *pt;
    pt = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"PushPin.png"];
    // this offset is to line the symbol up with the map was actually clicked
    pt.xoffset = 8;
    pt.yoffset = -18;
    pointInfoTemplate *pointTemplate = [[pointInfoTemplate alloc] init];
    AGSGraphic *pushpin = [[AGSGraphic alloc] initWithGeometry:newPoint symbol:pt attributes:nil infoTemplateDelegate:pointTemplate];
    // add pushpin to graphics layer
    [self.graphicsLayer addGraphic:pushpin];      
    [pushpin release];
    [self.graphicsLayer dataChanged];
    */
    //-(void)showCalloutAt:(AGSPoint*)mapLocation pixelOffset:(CGPoint)pixelOffset animated:(BOOL)animated;
    CGPoint point;
    point.x = 0.0;
    point.y = 0.0;
    //self.BaseMapView.callout.customView = nil;
    if (newPoint != nil) {
        //[self.BaseMapView.callout showCalloutAt:newPoint pixelOffset:point animated:YES];
        [self.BaseMapView centerAtPoint:newPoint animated:YES]; 
        [self.BaseMapView zoomToScale:50 withCenterPoint:newPoint animated:YES];
    }
    else {
        // 定位点计算错误
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"结果" 
                                                     message:[NSString stringWithFormat:@"兴趣点定位点计算错误"] 
                                                    delegate:nil 
                                                 cancelButtonTitle:@"确定" 
                                                 otherButtonTitles:nil];

        [av show];
        [av release];
    }
}     

- (void)SearchTextSet:(NSString *)SearchText
{
    [_SearchBarCtrl setText:SearchText];
}
-(void)MoreSearchDisplayLoadingView
{
    //如果callout显示在界面上，则让其隐藏
    if (![self.BaseMapView.callout isHidden]) {
        self.BaseMapView.callout.hidden = YES;
    }
    [self DisplayLoadingView:self.view TipText:@"正在搜索,请稍后..."];
}

-(void)ExecSearchFunc
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    //如果没有输入关键字，则提示用户输入关键字。
    if (self.SearchBarCtrl.text.length == 0) {
        [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:@"请输入关键字"];
    }else {
        [self.SearchBarCtrl resignFirstResponder];
        _BaseMapView.touchDelegate = self;
        BOOL bNetConn = [DataMan InternetConnectionTest];
        if (!bNetConn) {
            [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:@"网络未连接状态"];
            return;
        }
        [self DisplayLoadingView:self.view TipText:@"正在搜索,请稍后..."];
        // query POI
        SingleManager.delegate = self;
        [SingleManager DownLoadPOI:self.SearchBarCtrl.text downLoadFlg:0];
    }
}
#pragma mark - DBLandDataVeiwDelegate
- (void)LandDataViewPopoverDone
{
    [_LandDataPopoverView dismissPopoverAnimated:NO];
}

#pragma mark - DBSingLandInfoViewController
- (void)singleLandInfoViewPopoverDone{
    if ([self.singleDataPopover isPopoverVisible]) {
        [self.singleDataPopover dismissPopoverAnimated:NO];
    }
}

#pragma mark - DBLandAnalyseViewControllerDelegate
- (void)DBLandAnalyseViewControllerPopoverDone
{
    [self DestroyLandAnalyseViewContrl];
    [_LandAnalysePopoverView dismissPopoverAnimated:NO];
}
#pragma mark - DBLandArrtibuteViewDelegate
- (void)LandAttributeViewPopoverDone
{
    [_LandAttributePopoverView dismissPopoverAnimated:NO];
}
#pragma mark -

#pragma mark - DBAllConfDelegate Methods
-(void)ClearCacheCompleted:(NSString*)TipMsg
{
    // 
    // 检测本地缓存中是否有配置文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // 本地本地配置信息文件
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
    
    
    //需要在解析WebService之后，才能执行此操作。配置附件WebService。
    // 配置中不能获取下载地址时
    DBSeLayerPort* service = [DBSeLayerPort service];
    NSString *AnnexDownloadUrl = service.serviceUrl;
    if ([AnnexDownloadUrl length] <= 0) 
    {
        // 下载服务地址不对，请重新配置。
        [SingleManager CreateFailedAlertViewWithFailedInfo:@"下载错误" andWithMessage:@"下载服务地址不正确，请重新配置"];
    }
    else
    {
        if ([SingleManager.AnnexDownloadServiceUrl length] <= 0) {
            NSURL *webSerURL = [[NSURL alloc] initWithString:[AnnexDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSString *hostName = [webSerURL host];
            NSNumber *port = [webSerURL port];
            NSString *strPort = [port stringValue];
            NSString *preUrl = [NSString stringWithFormat:@"http://%@:%@/SunzDeci/convention/annexInfoAction_getDownloadFile.action?", hostName, strPort];
            SingleManager.AnnexDownloadServiceUrl = preUrl;
            [webSerURL release];
            [self UpdateWebServiceUrl];
        }
        
    }
    
    [self DisplayLoadingView:self.view TipText:TipMsg];
    [self HidLoadingView:self.view afterDelay:1];
}
- (void)AllConfPopoverDone
{
    [_AllConfPopoverView dismissPopoverAnimated:NO];
}

- (void)ReloadMapViewWithNameArray:(NSArray *)layerName andWithIndexArray:(NSArray *)index andWithType:(NSInteger)type
{
    self.layerNameArr = (NSMutableArray *) layerName;
    self.IndexArr = (NSMutableArray *)index;
    if (type == 0) {
        // 更新底图图层配置数据
        [self UpdateBaseMapLayers];
    }
    else if(type == 1){
        // 更新Web服务地址配置数据
        [self UpdateWebServiceUrl];
        return;
    }
}

// 更新Web服务地址配置数据
-(void)UpdateWebServiceUrl
{
    @try {
        // 写入到配置文件中
        // 检测本地是否有配置文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        // 本地本地配置信息文件
        NSString *FilePath = [documentsDirectory stringByAppendingPathComponent:@"DBConfigure.xml"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:FilePath];
        if (!bRet) {
            // 本地无此文件，则将此文件拷贝到本地目录。
            NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
            NSError *err;
            [fileMgr copyItemAtPath:xmlFilePath toPath:FilePath error:&err];
        }
        //NSString *FilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:FilePath];
        DDXMLDocument *LayerDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
        NSArray *WebServerUrlArray = [LayerDocument nodesForXPath:@"//XML/WebServerUrl" error:nil];
        for (DDXMLElement *obj in WebServerUrlArray) 
        {
            DDXMLElement *TopicsWebServerUrl = [obj elementForName:@"TopicsWebServerUrl"];
            TopicsWebServerUrl.stringValue = SingleManager.TopicWebServiceUrl;
            
            DDXMLElement *GISWebServerUrl = [obj elementForName:@"GISWebServerUrl"];
            GISWebServerUrl.stringValue = SingleManager.GISWebServiceUrl;
            
            DDXMLElement *AnnexServerUrl = [obj elementForName:@"AnnexServerUrl"];
            AnnexServerUrl.stringValue = SingleManager.AnnexDownloadServiceUrl;
        }
        
        NSData *data2 = [LayerDocument XMLData];
        [LayerDocument release];
        [data2 writeToFile:FilePath atomically:NO];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

/*
// 更新业务图层配置数据
-(void)UpdateMapLayers
{
    @try 
    {
        int nTotalCnt = [IndexArr count];
        for (int nCnt = 0; nCnt < nTotalCnt; nCnt++) 
        {
            NSString *layerName = [layerNameArr objectAtIndex:nCnt];
            NSNumber *nsIndex = [IndexArr objectAtIndex:nCnt];
            // 查找层layerName,并删除。
            BOOL bIsHas = [self FindLayerByName:layerName];
            if(bIsHas)
            {
                [self.BaseMapView removeMapLayerWithName:layerName];
                
                // open/display current data layer
                int nIndex = [nsIndex intValue];
                NSString *LayerUrl = [_DataMapLayerUrlArray objectAtIndex:nIndex];
                AGSDynamicMapServiceLayer *DyLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:LayerUrl]];
                //name the layer. This is the name that is displayed if there was a property page, tocs, etc...
                NSString *newLayerName = [_DataMapLayerNameArray objectAtIndex:nIndex];
                //[self.BaseMapView addMapLayer:DyLayer withName:newLayerName];
                int nLayerCnt = [[self.BaseMapView mapLayers] count];
                [self.BaseMapView insertMapLayer:DyLayer withName:newLayerName atIndex:nLayerCnt - 2];
                [DyLayer release];
            }
        }
        
        // 写入到配置文件中
        if (nTotalCnt > 0) 
        {
            // 检测本地是否有配置文件
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            // 本地本地配置信息文件
            NSString *FilePath = [documentsDirectory stringByAppendingPathComponent:@"DBConfigure.xml"];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:FilePath];
            if (!bRet) {
                // 本地无此文件，则将此文件拷贝到本地目录。
                NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
                NSError *err;
                [fileMgr copyItemAtPath:xmlFilePath toPath:FilePath error:&err];
            }
            NSData *xmlData = [[NSData alloc] initWithContentsOfFile:FilePath];
            //NSString *FilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
            //NSData *data = [[NSData alloc] initWithContentsOfFile:FilePath];
            DDXMLDocument *LayerDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:nil];
            [xmlData release];
            for(int nCnt = 0; nCnt < nTotalCnt; nCnt++)
            {
                NSNumber *nsIndex = [IndexArr objectAtIndex:nCnt];
                int nIndex = [nsIndex intValue];
                
                NSArray *subject = [LayerDocument nodesForXPath:@"//XML/DataLayerList/DataLayer" error:nil];
                int nCnt2 = 0;
                for (DDXMLElement *obj in subject) 
                {
                    if(nIndex == nCnt2)
                    {
                        DDXMLElement *name = [obj elementForName:@"DataLayerName"];
                        NSString *newLayerName = [_DataMapLayerNameArray objectAtIndex:nIndex];
                        name.stringValue = newLayerName;
                        
                        DDXMLElement *layerUrl = [obj elementForName:@"DataLayerUrl"];
                        NSString *newLayerUrl = [_DataMapLayerUrlArray objectAtIndex:nIndex];
                        layerUrl.stringValue = newLayerUrl;
                    }
                    nCnt2++;
                }
            }
            NSData *data2 = [LayerDocument XMLData];
            [LayerDocument release];
            [data2 writeToFile:FilePath atomically:NO];  
            
            // reload data from xml file in budle
            //NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
            //NSData *xmlData = [[NSData alloc] initWithContentsOfFile:xmlFilePath];
            NSData *xmlData2 = [[NSData alloc] initWithContentsOfFile:FilePath];
            [self parsedDataMapLayerFromData:xmlData2];
            [xmlData2 release];
            
            [[DataMapLayerViewContrl DataMapLayerTableView] reloadData];
        }
        [layerNameArr removeAllObjects];
        [IndexArr removeAllObjects];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return;
}
*/

// 更新底图图层配置数据
-(void)UpdateBaseMapLayers
{
    @try 
    {
        int nTotalCnt = [IndexArr count];
        for (int nCnt = 0; nCnt < nTotalCnt; nCnt++) 
        {
            NSInteger nMapType = [[_BaseMapSwitchView MapTypeSegCtrl] selectedSegmentIndex];
            
            if (nMapType == 0) {
                // 当前为地图
            }
            else if(nMapType == 1){
                // 当前为影像
            }
            
            NSString *layerName = [layerNameArr objectAtIndex:nCnt];
            
            if (((nMapType == 0) && ([layerName isEqualToString:DEFAULT_MAPLAYER_NAME])) ||
                ((nMapType == 1) && ([layerName isEqualToString:SATELLITE_MAPLAYER_NAME])))
            {
                // 查找层layerName,并删除。
                BOOL bIsHas = [self FindLayerByName:BASEMAPLAYER_NAME];
                if(bIsHas)
                {
                    [self.BaseMapView removeMapLayerWithName:BASEMAPLAYER_NAME];
                    
                    // open/display current layer
                    NSString *LayerUrl = [_BaseMapLayersDic valueForKey:layerName];
                    
                    NSURL *MapUrl = [[NSURL alloc] initWithString:[LayerUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    AGSTiledMapServiceLayer *tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:MapUrl];
                    [MapUrl release];
                    
                    [tiledLayer setTileDelegate:self];
                    [tiledLayer setRenderNativeResolution:YES];
                    UIView<AGSLayerView>* lyr = [self.BaseMapView insertMapLayer:tiledLayer withName:BASEMAPLAYER_NAME atIndex:0];
                    [tiledLayer release];
                    tiledLayer = nil;
                    lyr.drawDuringPanning = YES;
                    lyr.drawDuringZooming = YES;
                    break;
                }
            }
        }
        
        // 写入到配置文件中
        if (nTotalCnt > 0) 
        {
            // 检测本地是否有配置文件
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            // 本地本地配置信息文件
            NSString *FilePath = [documentsDirectory stringByAppendingPathComponent:@"DBConfigure.xml"];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:FilePath];
            if (!bRet) {
                // 本地无此文件，则将此文件拷贝到本地目录。
                NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
                NSError *err;
                [fileMgr copyItemAtPath:xmlFilePath toPath:FilePath error:&err];
            }
            
            //NSString *FilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
            NSData *data = [[NSData alloc] initWithContentsOfFile:FilePath];
            DDXMLDocument *LayerDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
            
            for(int nCnt = 0; nCnt < nTotalCnt; nCnt++)
            {
                NSString *layerName = [layerNameArr objectAtIndex:nCnt];
                NSArray *subject = [LayerDocument nodesForXPath:@"//XML/BaseMapLayList/BaseMapLay" error:nil];
                for (DDXMLElement *obj in subject) 
                {
                    DDXMLElement *name = [obj elementForName:@"LayerName"];
                    if ([name.stringValue isEqual:layerName]) 
                    {
                        DDXMLElement *layerUrl = [obj elementForName:@"LayerUrl"];
                        NSString *newLayerUrl = [_BaseMapLayersDic valueForKey:layerName];
                        layerUrl.stringValue = newLayerUrl;
                    }
                }
            }
            NSData *data2 = [LayerDocument XMLData];
            [LayerDocument release];
            [data2 writeToFile:FilePath atomically:NO];  
            
            //NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
            NSData *xmlData = [[NSData alloc] initWithContentsOfFile:FilePath];
            [self parsedBaseMapLayerFromData:xmlData];
            [xmlData release];
            
            [[DataMapLayerViewContrl DataMapLayerTableView] reloadData];
        }
        [layerNameArr removeAllObjects];
        [IndexArr removeAllObjects];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return;
}


#pragma mark -
#pragma mark DBDataMapLayerSwitchProtocol Methods
- (void)MapLayerSwitch:(int)nIndex SwitchValue:(BOOL)bValue
{
    @try {
        
        NSString *layerName = [[SingleManager.MapLayerDataArray objectAtIndex:nIndex] Name];
        //NSString *layerName = @"datalayer";
        if(bValue)
        {
            // open/display current data layer
            NSString *LayerUrl = [[SingleManager.MapLayerDataArray objectAtIndex:nIndex] MapUrl];
            
            //NSURL *webURL = [[NSURL alloc] initWithString:[LayerUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            AGSDynamicMapServiceLayer *DyLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:LayerUrl]];
            //AGSDynamicMapServiceLayer *DyLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:webURL];
            //name the layer. This is the name that is displayed if there was a property page, tocs, etc...
            //[self.BaseMapView addMapLayer:DyLayer withName:layerName];
            int nLayerCnt = [[self.BaseMapView mapLayers] count];
            [DyLayer setRenderNativeResolution:YES];
            [self.BaseMapView insertMapLayer:DyLayer withName:layerName atIndex:nLayerCnt - 2];
            //[DyLayer release];
            [self.BaseMapView  bringSubviewToFront:self.GraphicsView];
        }
        else {
            // close current data layer
            [self.BaseMapView removeMapLayerWithName:layerName];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

    return;
}

#pragma mark - DBAttributeViewDelegate Method

- (void)ScrollViewAppearWithPictureArray:(NSArray *)pictureArray
{
    @try {
        //Custom image View
        PictureRootView = [[UIView alloc] initWithFrame:CGRectMake(200, 140, 634, 460)];
        PictureRootView.backgroundColor = [UIColor clearColor];
        PictureView = [[UIView alloc] initWithFrame: CGRectMake(0.0, 10.0, 624.0, 450.0)];
        PictureView.backgroundColor = [UIColor blackColor];
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(5, 5, 614.0, 424)];
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.contentSize = CGSizeMake(614 * 6, 424);
        for (int i=0; i<6; i++)
        {
            ImageScrollView *ascrView = [[ImageScrollView alloc] initWithFrame:CGRectMake(614*i, 0, 614, 424)];
            //NSString *imgPath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d", i+1] ofType:@"jpg"];
            //ascrView.image = [UIImage imageWithContentsOfFile:imgPath];
            ascrView.image = [pictureArray objectAtIndex:i];
            ascrView.tag = 100+i;		
            [_scrollView addSubview:ascrView];
            [ascrView release];
        }
        lastPage = 0;
        [PictureView addSubview:_scrollView];
        [_scrollView release];
        pageCtl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 420, 600, 36)];
        pageCtl.numberOfPages = 6;
        pageCtl.currentPage = 0;
        [pageCtl addTarget:self action:@selector(imageChange:) forControlEvents:UIControlEventValueChanged];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"ImageViewClose.png"] forState:UIControlStateNormal];
        button.backgroundColor = [UIColor clearColor];
        button.frame = CGRectMake(608, 5, 20, 20);
        [button addTarget:self action:@selector(CustomViewdisAppear) forControlEvents:UIControlEventTouchUpInside];
        
        //显示圆角
        PictureView.layer.cornerRadius = 8;
        PictureView.layer.masksToBounds = YES;
        [PictureView addSubview:pageCtl];
        
        [PictureRootView addSubview:PictureView];
        [PictureRootView addSubview:button];
        [self.view addSubview:PictureRootView];
        [PictureView release];
        [PictureRootView release];
        //    [self.view bringSubviewToFront:_scrollView];
        [_GraphicAttPopoverView dismissPopoverAnimated:NO];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

- (void)CustomViewdisAppear
{
    [PictureRootView removeFromSuperview];
}

- (void)imageChange:(id)sender
{
    UIPageControl * tmpPageCtl = (UIPageControl *)sender;
    //得到UIPageControl对象的当前页数
    NSInteger page = tmpPageCtl.currentPage;
    [_scrollView scrollRectToVisible:CGRectMake(614 * page, 0, 614, 320) animated:YES];
}

//实现协议里的方法，以达到滑动scrollView来改变pageControl的值
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index;
    index = _scrollView.contentOffset.x / 614 + 0.5;
    pageCtl.currentPage = index;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	CGFloat pageWidth = scrollView.frame.size.width;
	NSInteger page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	if (lastPage != page) 
	{
		ImageScrollView *aView = (ImageScrollView *)[_scrollView viewWithTag:100+lastPage];
		aView.zoomScale = 1.0;
		
		lastPage = page;
	}
}

#pragma mark -
#pragma mark DBLocationLandProjectProtocol Methods
// 重新加载地块数据
-(void)ReloadDKData:(NSString*)TopicId
{
    [self.SubjectView ReloadLandData:TopicId];
    return;
}
// 重新加载基本情况数据
-(void)ReloadTopicReasonData:(NSString*)TopicId
{
    // 重新加载基本情况数据
    [self.SubjectView ReloadReasonData:TopicId];
    return;
}
// 清除议题详细数据
-(void)CleanDetailData:(NSString*)TopicID
{
    [self.SubjectView CleanTopicDetailData:TopicID];
    return;
}
// 显示加载议题数据等待View
-(void)DisPlayLoadTopicDataWaittingView:(NSString*)Msg
{
    [self DisplayLoadingView:self.view TipText:Msg];
}
// 消失加载议题数据等待View
-(void)HidLoadTopicDataWaittingView:(NSString*)Msg;
{
    if (Msg != nil) {
        HUD.labelText = Msg;
        [self HidLoadingView:self.view afterDelay:2];
    }
    else {
        [self HidLoadingView:self.view afterDelay:0];
    }

}
// 设置显示文字
-(void)SetWaittingViewText:(NSString*)Msg
{
    HUD.labelText = Msg;
}

- (void)SubjectDataViewAppearWithSubProjectDataItem:(DBSubProjectDataItem *)SubProjectData index:(NSInteger)nIndex
{
    // chg by niurg 2015.9
//    if([self.MeetingViewPopover isPopoverVisible])
//    {
//        DBMeetingViewController * MeetingContrl = (DBMeetingViewController *)[self.MeetingViewPopover contentViewController];
//        [MeetingContrl SetSubPopoverHiden];
//        
//        [self.MeetingViewPopover dismissPopoverAnimated:NO];
//    }
    if([self.Subject2ViewPopover isPopoverVisible])
    {
        DBSubjectListController * subjectViewControl = (DBSubjectListController *)[self.Subject2ViewPopover contentViewController];
        [self SetSubPopoverHiden];

        [self.Subject2ViewPopover dismissPopoverAnimated:NO];
    }
    // end
    
    CGFloat fHeight = [UIScreen mainScreen].bounds.size.width - Top_Bar_Height - 20;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.999)
    {
        fHeight = [UIScreen mainScreen].bounds.size.width - Top_Bar_Height;
    }
    
    if (SubjectView == nil) {
        self.SubjectView = [[DBSubjectDataViewController alloc] init];
        //[SubjectView.view setBackgroundColor:[UIColor redColor]];
        SubjectView.delegate = self;
        [self.SubjectView setDragViewDelegate:self];
        self.SubjectDataView = SubjectView.view;
        CGFloat fWidth = SCREEN_WIDTH * 0.6 + 28;
        CGFloat fOrgx = 0 - fWidth + 28;
        SubjectDataView.frame = CGRectMake(fOrgx, Top_Bar_Height, fWidth, fHeight);
        SubjectView.SubjectDataItem = SubProjectData;
        [self.view addSubview:SubjectDataView];
    }else {
        SubjectView.SubjectDataItem = SubProjectData;
        [SubjectView SubjectViewReloadData];
    }
    [SubjectView setNCurrIndex:nIndex];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    CGFloat fWidth = SCREEN_WIDTH * 0.6;
    SubjectDataView.frame = CGRectMake(0, Top_Bar_Height, fWidth + 28, fHeight);
    CGFloat fOrgx = fWidth - 28;
    CGFloat fWidth2 = SCREEN_WIDTH - fOrgx;
    self.BaseMapView.frame = CGRectMake(fOrgx, 0, fWidth2, fHeight);
    [UIView commitAnimations];
    
    [self setTipLabelFontAlign:2];
    
    return;
}

#pragma mark 刷新议题列表数据
-(void)refreshSubjectListData
{
    // 1.清除旧的议题数据
    DBLocalTileDataManager *dataMan = [DBLocalTileDataManager instance];
    NSInteger nRow = 0;
    nRow = [dataMan.MeetingList count] - nRow - 1;
    NSString *MeetingID = [[dataMan.MeetingList objectAtIndex:nRow] Id];
    NSLog(@"*******:%@",MeetingID);
    [dataMan CleanAllTopicOfMeetingCacheData:MeetingID];
    
    // 2.下载新的议题数据
    //判断网络是否连通
    BOOL bNetConn = [dataMan InternetConnectionTest];
    if (!bNetConn) {
        [dataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
        return;
    }
    [_Subject2ViewPopoverViewController DisPlayLoadingView:@"正在下载议题数据,请稍后..."];
    // 从网络获取此会议下的所有议题数据
    [UIApplication showNetworkActivityIndicator:YES];
    DB2GoverDeciServerService* service = [DB2GoverDeciServerService service];
    service.logging = YES;
    
    NSString * Param = [NSString stringWithFormat:@"<root><function>DownloadPortalTopicsByConvention</function><params><param>%@</param></params></root>", MeetingID];
    //加密处理
    NSString *encryptParam = [NSString stringWithFormat:@"<![CDATA[%@]]>", [EncryptUtil encryptUseDES:Param key:ENCRYPT_KEY]];
    
    SoapRequest * SoapReq = [service CommonService:self action:@selector(DownloadPortalTopicsCallBack:userInfo:) arg0: encryptParam];
    [SoapReq setUserInfo:MeetingID];
    [_Subject2ViewPopoverViewController waitDownload];
    
    // flg为1表示当前缓存中无数据，需要从网络下载，在议题列表中显示“正在加载”的提示
    NSInteger nFlg = 1;
    [_Subject2ViewPopoverViewController setNLoadFlg:nFlg];
    
    NSArray *DataArray = [[dataMan.TopicsOfMeeting objectForKey:MeetingID] allValues];
    // 动态设置议题popoverView高度
    NSInteger nCnt = 1;
    if ([DataArray count] > 0)
    {
        nCnt = [DataArray count];
    }
    if (DataArray.count >= 8 ) {
        //[_Subject2ViewPopover setPopoverContentSize:CGSizeMake(320.0, 320.0) animated:NO];
        [_Subject2ViewPopover setPopoverContentSize:CGSizeMake(450, 360.0) animated:NO];
    }
    else {
        [_Subject2ViewPopover setPopoverContentSize:CGSizeMake(450, 55.0 * nCnt + 37) animated:NO];
    }
    
    [_Subject2ViewPopoverViewController reloadContentDataArray:MeetingID];
    
    return;
}

#pragma mark - DBSubjectDataViewDelegate Method
// 定位议题的地块
- (void)LandsLocation:(AGSPoint *)LocationPoint
{
    [self.BaseMapView zoomToScale:80 withCenterPoint:LocationPoint animated:YES];
}

#pragma mark 关闭议题窗口
- (void)ClosedBtnTouchedWithFlag2:(BOOL)flag
{
    CGFloat fWidth = SCREEN_WIDTH * 0.6 + 28;
    
    if ([self nModelFlg] == 1)
    {// 会议议题模块
        CGFloat fHeight = [UIScreen mainScreen].bounds.size.width - Top_Bar_Height - 20;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.999)
        {
            fHeight = [UIScreen mainScreen].bounds.size.width - Top_Bar_Height;
        }
        if (!flag) {
            //隐藏议题界面
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            CGFloat fOrgx = 0 - fWidth + 28;
            SubjectDataView.frame = CGRectMake(fOrgx, Top_Bar_Height, fWidth, fHeight);
            self.BaseMapView.frame = CGRectMake(0, 0, SCREEN_WIDTH, fHeight);
            [UIView commitAnimations];
        }else if (flag) {
            //显示议题界面
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.4];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            SubjectDataView.frame = CGRectMake(0, Top_Bar_Height, fWidth, fHeight);
            self.BaseMapView.frame = CGRectMake(SCREEN_WIDTH * 0.6, 0, SCREEN_WIDTH - SCREEN_WIDTH * 0.6, fHeight);
            [UIView commitAnimations];
        }
    }
}


#pragma mark 设置地图操作提示框文本位置
-(void)setTipLabelFontAlign:(NSInteger)nFlg
{
    if (nFlg == 1)
    {
        // 左对齐
        [TopDataDisplayLabel setTextAlignment:NSTextAlignmentLeft];
    }
    else if (nFlg == 2)
    {
        // 右对齐
        [TopDataDisplayLabel setTextAlignment:NSTextAlignmentRight];
    }
    else{
        // 居中
        [TopDataDisplayLabel setTextAlignment:NSTextAlignmentCenter];
    }
    
    return;
}
- (void)ClosedBtnTouchedWithFlag:(BOOL)flag
{
    CGFloat fMapXOffset = 0.0;
    CGFloat fMapWidth = 0.0f;
    CGFloat fSubjectViewXOffset = 0.0;
    CGFloat fSubjectViewWidth = 0.0f;
    
    // 固定不变的几个参数----
    CGFloat fMapYOffset = 0.0f;
    CGFloat fHeight = [UIScreen mainScreen].bounds.size.width - Top_Bar_Height - 20;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.999)
    {
        fHeight = [UIScreen mainScreen].bounds.size.width - Top_Bar_Height;
    }
    //----

    // 当前配置的模式
    NSInteger viewAreaConf = [SingleManager currSubjectViewAreaConf];
    
    if (!flag) {
        //隐藏议题界面
        // 设置提示框文本居中
        [self setTipLabelFontAlign:0];
        if (viewAreaConf == 1) {
            // 当前议题页面为半屏状态
            fMapXOffset = 0.f;
            fMapWidth = SCREEN_WIDTH;
            
            fSubjectViewWidth = Half_Subject_Width_Big;
            fSubjectViewXOffset = 0 - Half_Subject_Width_Small;
        }
        else{
            // 当前议题页面为全屏状态
            // 地图位置和大小不变
            fMapXOffset = 0.f;
            fMapWidth = SCREEN_WIDTH;
            
            // 议题的宽度
            fSubjectViewWidth = Full_Subject_Width_Big;
            fSubjectViewXOffset = 0 - Full_Subject_Width_Small;
        }
    }
    else{
        //显示议题界面
        if (viewAreaConf == 1) {
            // 设置提示框文本居右
            [self setTipLabelFontAlign:2];
            // 显示为半屏状态
            fMapWidth = SCREEN_WIDTH - Half_Subject_Width_Small;
            fMapXOffset = Half_Subject_Width_Small;
            
            fSubjectViewWidth = Half_Subject_Width_Big;
            fSubjectViewXOffset = 0.f;
            [self.SubjectView adjustSubjectView:1];
        }
        else{
            // 显示为全屏状态
            fMapWidth = SCREEN_WIDTH - Full_Subject_Width_Small;
            fMapXOffset = Full_Subject_Width_Small;
            
            fSubjectViewWidth = Full_Subject_Width_Big;
            fSubjectViewXOffset = 0.f;
            [self.SubjectView adjustSubjectView:2];
        }
    }
    
    if ([self nModelFlg] == 1)
    {// 会议议题模块

        if (!flag) {
            //隐藏议题界面
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.4];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            SubjectDataView.frame = CGRectMake(fSubjectViewXOffset, Top_Bar_Height, fSubjectViewWidth, fHeight);
            self.BaseMapView.frame = CGRectMake(fMapXOffset, fMapYOffset, fMapWidth, fHeight);
//            [UIView commitAnimations];
        }else if (flag) {
            //显示议题界面
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.4];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            SubjectDataView.frame = CGRectMake(fSubjectViewXOffset, Top_Bar_Height, fSubjectViewWidth, fHeight);
            self.BaseMapView.frame = CGRectMake(fMapXOffset, fMapYOffset, fMapWidth, fHeight);
//            [UIView commitAnimations]; 
        }
    }
    
//    if (flag) {
//        //显示议题界面
//        if (viewAreaConf == 1) {
//            // 显示为半屏状态
//            [self.SubjectView adjustSubjectView:1];
//        }
//        else{
//            // 显示为全屏状态
//            [self.SubjectView adjustSubjectView:2];
//        }
//    }
//    else
//    {// 土地监管模块
//        if (flag) {
//            //隐藏议题界面
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.4];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//            self.XCDKDataView.frame = CGRectMake(-405, 44, 433, 704);
//            self.BaseMapView.frame = CGRectMake(0, 0, 1024, 704);
//            [UIView commitAnimations];
//        } else {
//            //显示议题界面
//            [UIView beginAnimations:nil context:nil];
//            [UIView setAnimationDuration:0.4];
//            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//            self.XCDKDataView.frame = CGRectMake(0, 44, 433, 704);
//            self.BaseMapView.frame = CGRectMake(400, 0, 1024 - 400, 704);
//            [UIView commitAnimations];
//        }
//        
//    }

}

// add by niurg 2016.02.16 begin
-(UIColor*)getOutlineColor:(BOOL)isInit
{
    static int nIndex = 0;
    if (isInit) {
        nIndex = 0;
        return nil;
    }
    
    UIColor *color = nil;
    if (nIndex >= 9) {
        nIndex = 0;
    }
    
    if (nIndex == 0) {
        // number one
        color = [UIColor purpleColor];
    }
    else if (nIndex == 1)
    {
        color = [UIColor orangeColor];
    }
    else if (nIndex == 2)
    {
        color = [UIColor brownColor];
    }
    else if (nIndex == 3)
    {
        color = [UIColor blueColor];
    }
    else if (nIndex == 4)
    {
        color = [UIColor greenColor];
    }
    else if (nIndex == 5)
    {
        color = [UIColor cyanColor];
    }
    else if (nIndex == 6)
    {
        color = [UIColor blackColor];
    }
    else if (nIndex == 7)
    {
        color = [UIColor orangeColor];
    }
    else if (nIndex == 8)
    {
        color = [UIColor darkGrayColor];
    }
    nIndex++;
    
    return [color autorelease];
}
// end

-(void)DisplayLandGraphic:(DBTopicDKDataItem*)DBTopicDKData andWithIsAllSelectedFlag:(BOOL)flag
{
    // Create a SFS for the inner buffer zone
    // chg by niurg 2016.02.16 begin
//    AGSSimpleFillSymbol *innerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
//    innerSymbol.color = [[UIColor redColor] colorWithAlphaComponent:0.40];
//    innerSymbol.outline.color = [UIColor darkGrayColor];
    AGSSimpleFillSymbol *innerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
    innerSymbol.color = [UIColor clearColor];
    innerSymbol.outline.color = [UIColor redColor];
    [innerSymbol.outline setWidth:5.0f];
    // end
    
    // Create a SFS for the outer buffer zone
    // chg by niurg 2016.02.16 begin
//    AGSSimpleFillSymbol *outerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
//    outerSymbol.color = [[UIColor yellowColor] colorWithAlphaComponent:0.25];
//    outerSymbol.outline.color = [UIColor darkGrayColor];
    AGSSimpleFillSymbol *outerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
    outerSymbol.color = [UIColor clearColor];
    outerSymbol.outline.color = [self getOutlineColor:NO];
    [outerSymbol.outline setWidth:5.0f];
    // end
    
    pointInfoTemplate *pointTemplate = [[pointInfoTemplate alloc] init];
    //用原生的Graphic
//    AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:DBTopicDKData.DKGeometry symbol:innerSymbol attributes:nil infoTemplateDelegate:pointTemplate];
//    [self.graphicsLayer addGraphic:graphic];				
//    [graphic release];		
//    [self.graphicsLayer dataChanged];
    
    //用自定义的Graphic
    DBAGSGraphic *graphic = [[DBAGSGraphic alloc] initWithGeometry:DBTopicDKData.DKGeometry symbol:outerSymbol attributes:nil infoTemplateDelegate:pointTemplate];
    
    // add by niurg 2016.02.16 begin
    [graphic setOuterSelectedSymbol:innerSymbol];
    [graphic setOuterNoSelectedSymbol:outerSymbol];
    // end
    
    graphic.bIsHighlighted = NO;
    graphic.TypeFlg = 2;
    //设置地块相关信息
    graphic.DKBH = DBTopicDKData.DKBH;
    graphic.DKName = DBTopicDKData.DKName;
    graphic.DKBsm = DBTopicDKData.DKBsm;
    graphic.Notes = DBTopicDKData.Notes;
    graphic.DKApplicant = DBTopicDKData.DKApplicant;
    graphic.DKBZXX = DBTopicDKData.DKBZXX;
    graphic.DKLX = DBTopicDKData.DKLX;
    if (!flag) {
        graphic.symbol = innerSymbol;
        graphic.bIsHighlighted = YES;
    }
    [self.graphicsLayer addGraphic:graphic];      
    [graphic release];
}

// 议题ID，议题中的地块索引
- (void)LandDataViewAppear:(NSString*)TopicId  DKBsm:(NSString*)DKbsm newCenterPoint:(AGSPoint *)centerPoint  :(AGSMutableEnvelope*)DKsEnv
{
    @try {
        //如果callout显示在界面上，则让其隐藏
        if (![self.BaseMapView.callout isHidden]) {
            self.BaseMapView.callout.hidden = YES;
        } 
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        [self.graphicsLayer removeAllGraphics];
        // add by niurg 2016.02.16 begin
        [self getOutlineColor:YES];
        // end
        NSArray * DKDatas = [[[DataMan TopicIDToFeatureDic] objectForKey:TopicId] allValues];
        if ([DKbsm isEqualToString:@"All"]) {
            // 定位显示所有地块
            for (DBTopicDKDataItem *DBTopicDKData in DKDatas) {
                [self DisplayLandGraphic:DBTopicDKData andWithIsAllSelectedFlag:YES];
            }
            if (centerPoint == nil) {
                [self DisplayLoadingView:self.view TipText:@"此地块未关联图形"];
                [HUD hide:YES afterDelay:1];
            }
            else {
                // chg by niurg begin
                if (DKsEnv) {
                    [DKsEnv normalize];
                    [DKsEnv expandByFactor:2.f];
                    [self.BaseMapView zoomToEnvelope:DKsEnv animated:YES];
                }
                else{
                    [self.BaseMapView zoomToScale:50 withCenterPoint:centerPoint animated:YES];
                }
                // end
                [self.graphicsLayer dataChanged];
            }
        }
        else {
            // 只定位显示指定地块
            NSDictionary *DKDic = [[DataMan TopicIDToFeatureDic] objectForKey:TopicId];
            
            DBTopicDKDataItem *DBTopicDKData = [DKDic objectForKey:DKbsm];
            if (DBTopicDKData != nil) 
            {
                [self DisplayLandGraphic:DBTopicDKData andWithIsAllSelectedFlag:NO];
                if ([DBTopicDKData.DKGeometry isKindOfClass:[AGSPolygon class]]) 
                {
                    AGSPolygon *Poly = (AGSPolygon*)DBTopicDKData.DKGeometry;
                    AGSEnvelope *envTmp2 = [[Poly envelope] copy];
                    AGSMutableEnvelope *DKsMinEnv = [AGSMutableEnvelope envelopeWithXmin:envTmp2.xmin ymin:envTmp2.ymin xmax:envTmp2.xmax ymax:envTmp2.ymax spatialReference:envTmp2.spatialReference];
                    if (DKsMinEnv) {
                        // 新的处理方法
                        [DKsMinEnv normalize];
                        [DKsMinEnv expandByFactor:2.f];
                        [self.BaseMapView zoomToEnvelope:DKsMinEnv animated:YES];
                        [self.graphicsLayer dataChanged];
                        return;
                    }
                    else{
                        // 用旧的处理方法
                        AGSGeometryEngine *geoEng = [AGSGeometryEngine defaultGeometryEngine];
                        AGSMutablePoint *newCenterPoint = [geoEng labelPointForPolygon:Poly];
                        if (newCenterPoint != nil) {
                            [self.BaseMapView zoomToScale:50 withCenterPoint:newCenterPoint animated:YES];
                            [self.graphicsLayer dataChanged];
                            return;
                        }
                    }

                }
            }
            [self DisplayLoadingView:self.view TipText:@"此地块未关联图形"];
            [HUD hide:YES afterDelay:1];
        }
        
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }


}

//===========================================================================
// 预览指定的附件文件
//  (支持iWork documents、Microsoft Office documents (Office ‘97 and newer)、Rich Text Format 
//  (RTF) documents、PDF files、Images、Text files whose uniform type identifier (UTI) conforms 
//   to the public.text typ、Comma-separated value (csv) files)
//===========================================================================
- (void)PreviewAnnex:(NSString*)AnnexFullPath
{
    @try {
        QLPreviewController *previewoCntroller = [[[QLPreviewController alloc] init] autorelease];  
        DBPreviewDataSource *dataSource = [[[DBPreviewDataSource alloc]init] autorelease];  
        dataSource.path=[[NSString alloc] initWithString:AnnexFullPath];  
        previewoCntroller.dataSource = dataSource;  
//        [previewoCntroller setTitle:@"附件查阅"];
        previewoCntroller.navigationItem.rightBarButtonItem=nil;

        //zhenglei 2014.12.27 修改显示方式，原有显示在ios7以下正常，在ios8中会crash
        UINavigationController *nc = [[UINavigationController alloc] init];
        nc.view.backgroundColor = [UIColor whiteColor];
        nc.navigationBarHidden = YES;

        [self presentViewController:nc animated:YES completion:nil];
        [nc pushViewController:previewoCntroller animated:NO];
        
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}
// 显示正在下载的消息
-(void)DisplayDownLoadWaittingView:(NSString*)LabelMsg
{
    [self DisplayLoadingView:self.view TipText:LabelMsg];
}
-(void)RemoveAllGraphics
{
    [self.graphicsLayer removeAllGraphics];
    [self.graphicsLayer dataChanged];
}
// 显示下载完成或出错的消息
-(void)HidDownLoadWaittingView:(NSString*)DelayMsg
{
    @try {
        if ([DelayMsg length] <= 0) {
            [HUD hide:YES];
            return;
        }
        [HUD setLabelText:DelayMsg];
        [HUD hide:YES afterDelay:1];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }

}
#pragma mark MapLayerConfDelegate Methods
- (void)AllConf
{
//    [self doCurl];
    float fWidth = 400.0f;
    float fHeight = 500.0f;
    float fXpos = SCREEN_WIDTH - fWidth - 30;
    float fYpos = 748 / 2 - fHeight / 2;
    CGRect frame2 = CGRectMake(fXpos, fYpos, fWidth, fHeight);
    [_AllConfPopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
}

// 放置大头针
- (void)MapPinSet:(BOOL)bType
{
    [self doCurl];
    return;
}

// 底图设置
- (void)BaseMapLayerSet:(NSString*)Type
{
//    [self doCurl];
    [self SetBaseMapType:Type];
    
    return;
}

#pragma  mark 检查是否有指定的图层
-(BOOL)FindLayerByName:(NSString*)LayerName
{
    BOOL bRet = FALSE;
    
    NSArray *mapLayers = [self.BaseMapView mapLayers];
    int nTotalCnt = [mapLayers count];
    for (int nCnt = 0; nCnt < nTotalCnt; nCnt++)
    {
        id layerObj = [mapLayers objectAtIndex:nCnt];
        if ([LayerName isEqualToString:BASEMAPLAYER_NAME]) 
        {
            if([layerObj isKindOfClass:[AGSTiledMapServiceLayer class]])
            {
                AGSTiledMapServiceLayer *layer = (AGSTiledMapServiceLayer*)layerObj;
                NSString *name = [layer name];
                if ([name isEqualToString:LayerName]) 
                {
                    bRet = TRUE;
                    break;
                }
            }
        }
        else {
            if([layerObj isKindOfClass:[AGSDynamicMapServiceLayer class]])
            {
                AGSDynamicMapServiceLayer *layer = (AGSDynamicMapServiceLayer*)layerObj;
                NSString *name = [layer name];
                if ([name isEqualToString:LayerName]) 
                {
                    bRet = TRUE;
                    break;
                }
            }
        }

    }
    return bRet;
}

#pragma mark UIPopoverControllerDelegate Methods
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{    
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

#pragma mark - 标注列表显示代理方法 
- (void)MarkAppearWithDBMarkDataID:(NSString *)markID
{
    @try {
        //如果callout显示在界面上，则让其隐藏
        if (![self.BaseMapView.callout isHidden]) {
            self.BaseMapView.callout.hidden = YES;
        } 
        AGSPoint *newPoint = nil;
        for (DBMarkData *Mark in [SingleManager.MarkDic allValues]) {
            if ([markID isEqualToString:Mark.MarkID]) {
                newPoint = [AGSPoint pointWithX:Mark.MarkCoordinateX.doubleValue y:Mark.MarkCoordinateY.doubleValue spatialReference:nil];
                NSMutableArray *graphicArray = self.graphicsLayer.graphics;
                //取消高亮状态。
                [self IsGraphicHighlighted]; 
                //判断标注是否还存在图层上，如果存在则只改变其图片；如果不存在的话（点击清除button后，就不存在了。），需要在图层上添加一个标注。
                int i = 0;
                for (int j = 0; j < graphicArray.count; j++) {
                    AGSGraphic *graphic = [graphicArray objectAtIndex:j];
                    if ([graphic isKindOfClass:[DBAGSGraphic class]]) {
                        DBAGSGraphic *RealGraphic = (DBAGSGraphic *)graphic;
                        if (RealGraphic.TypeFlg == 0 && [Mark.MarkID isEqualToString:RealGraphic.MarkID]) {
                            i++;
                            RealGraphic.symbol = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"MarkPin.png"];
                            RealGraphic.bIsHighlighted = YES;
                            break;
                        }
                    }
                }
                if (i == 0){
                    AGSPictureMarkerSymbol *pt = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"MarkPin.png"];
                    pointInfoTemplate *pointTemplate = [[pointInfoTemplate alloc] init];
                    [pointTemplate setTitle:[Mark MarkName]];
                    DBAGSGraphic *pushpin = [[DBAGSGraphic alloc] initWithGeometry:newPoint symbol:pt attributes:nil infoTemplateDelegate:pointTemplate];
                    [pushpin setTypeFlg:0];
                    [pushpin setMarkID:markID];
                    [pushpin setBIsHighlighted:YES];
                    [self.graphicsLayer addGraphic:pushpin];      
                    [pushpin release];
                    [self.graphicsLayer dataChanged];
                }
                break;
            }
        }
        CGPoint point;
        point.x = 0.0;
        point.y = 0.0;
        if (newPoint != nil) {
            [self.BaseMapView centerAtPoint:newPoint animated:YES]; 
            [self.BaseMapView zoomToScale:50 withCenterPoint:newPoint animated:YES];
        }
        //显示标注的同时显示callout。
        self.BaseMapView.callout.customView = nil;
        [self.MarkNoteViewContrl MarkNoteViewWillAppearByGraphicID:markID andWithCancelFalg:100];
        self.BaseMapView.callout.customView = MarkNoteViewContrl.view;
        [self.BaseMapView.callout showCalloutAt:newPoint pixelOffset:point animated:YES];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

#pragma mark - DBMarkNoteViewDelegate Methods
- (void)SaveMark
{
    //如果callout显示在界面上，则让其隐藏
    if (![self.BaseMapView.callout isHidden]) {
        self.BaseMapView.callout.hidden = YES;
    } 
}

- (void)DeleteMark:(NSString *)MarkID
{
    //如果callout显示在界面上，则让其隐藏
    if (![self.BaseMapView.callout isHidden]) {
        self.BaseMapView.callout.hidden = YES;
    } 
    
    NSMutableArray *graphicArray = self.graphicsLayer.graphics;
    for (int i = 0; i < graphicArray.count; i++) {
        AGSGraphic *graphic = [graphicArray objectAtIndex:i];
        if ([graphic isKindOfClass:[DBAGSGraphic class]]) {
            DBAGSGraphic *RealGraphic = (DBAGSGraphic *)graphic;
            if (RealGraphic.TypeFlg == 0 && [MarkID isEqualToString:RealGraphic.MarkID]) {
                [self.graphicsLayer removeGraphic:RealGraphic];
                [self.graphicsLayer dataChanged];
                break;
            }
        }
    }
}

- (void)CancelMarkWithFlag:(NSInteger)CancelFlag andWithMarkID:(NSString *)MarkID
{
    //如果callout显示在界面上，则让其隐藏
    if (![self.BaseMapView.callout isHidden]) {
        self.BaseMapView.callout.hidden = YES;
    } 
    if (CancelFlag == 100) {
        
    }else if (CancelFlag == 101) {
        //将添加到字典里的标注数据删除。
        [SingleManager.MarkDic removeObjectForKey:MarkID];
        NSMutableArray *graphicArray = self.graphicsLayer.graphics;
        for (int i = 0; i < graphicArray.count; i++) {
            AGSGraphic *graphic = [graphicArray objectAtIndex:i];
            if ([graphic isKindOfClass:[DBAGSGraphic class]]) {
                DBAGSGraphic *RealGraphic = (DBAGSGraphic *)graphic;
                if (RealGraphic.TypeFlg == 0 && [MarkID isEqualToString:RealGraphic.MarkID]) {
                    [self.graphicsLayer removeGraphic:RealGraphic];
                    [self.graphicsLayer dataChanged];
                    break;
                }
            }
        }
    }
}

#pragma mark
//-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
//{ 
//    // We are starting to draw 
//    // Get the current touch. 
//    UITouch *touch = [touches anyObject];
//
//    CGPoint *startingPoint = [touch locationInView:self]; 
//}
#pragma mark -
#pragma mark 等待试图框 code
//-----------------------------------
- (void)DisplayLoadingView:(UIView*)ForView TipText:(NSString*)TipString
{
    @try {
        if (ForView == nil) {
            ForView = self.view;
        }
        [MBProgressHUD hideAllHUDsForView:ForView animated:YES];
        HUD = nil;
        HUD = [[MBProgressHUD alloc] initWithView:ForView];
        if ([TipString isEqualToString:@"添加书签成功"] || [TipString isEqualToString:@"删除书签成功"]) {
            HUD.yOffset = -100;
            HUD.mode = MBProgressHUDModeText;
        }
        [ForView addSubview:HUD];
        [HUD release];
        [ForView bringSubviewToFront:HUD];
        HUD.delegate = self;
        HUD.labelText = TipString;
        [HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}
- (void)HidLoadingView:(UIView*)ForView afterDelay:(NSTimeInterval)delay 
{
    @try {
        if (ForView == nil) {
            ForView = self.view;
        }
        if (delay != 0) {
            [HUD hide:YES afterDelay:delay];
        }
        else {
            [MBProgressHUD hideAllHUDsForView:ForView animated:YES];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

   
}

- (void)myTask {
	// Do something usefull in here instead of sleeping ...
	sleep(1);
}

- (void)myProgressTask {
	// This just increases the progress indicator in a loop
	float progress = 0.0f;
	while (progress < 1.0f) {
		progress += 0.01f;
		HUD.progress = progress;
		usleep(50000);
	}
}

- (void)myMixedTask {
	// Indeterminate mode
	sleep(2);
	// Switch to determinate mode
	HUD.mode = MBProgressHUDModeDeterminate;
	HUD.labelText = @"Progress";
	float progress = 0.0f;
	while (progress < 1.0f)
	{
		progress += 0.01f;
		HUD.progress = progress;
		usleep(50000);
	}
	// Back to indeterminate mode
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = @"Cleaning up";
	sleep(2);
	// The sample image is based on the work by www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Completed";
	sleep(2);
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	HUD = nil;
}

#pragma mark DataLayerFieldReloadDelegate methods
//-----------------------------------
- (void)DataLayerFieldDownloadCompleted:(NSString*)DataMapUrl  ViewFlg:(NSString*)Flg
{
    float fWidth = 400.0f;
    float fHeight = 500.0f;
    float fXpos = 0.0f;
    float fYpos = 748 - fHeight + 45.0f;
    CGRect frame2 = CGRectMake(fXpos, fYpos, fWidth, fHeight);
    // 多个地块(查询、分析)用.
    if ([Flg isEqualToString:@"0"]) 
    {
        frame2.size.width -= 160;
        [_LandDataPopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
    }
    // 单个地块信息.
    else if ([Flg isEqualToString:@"1"]) 
    {
        [_LandAnalysePopoverView presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
    }
   
}

//=================================
#pragma mark 国土巡察
-(void)GTXCBtnTouch:(id)sender
{
//    UIButton *tappedButton = (UIButton *)sender;
//    [self LastClickButtonCancel:tappedButton ClearGraphicFlg:YES];
//    // default to load not completely
//    int nCnt = [[SingleManager XCDKList] count];
//    if (nCnt == 0) {
//        BOOL bNetConn = [SingleManager InternetConnectionTest];
//        if (!bNetConn) {
//            [SingleManager CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
//            return;
//        }
//        
//        self.XCDKListViewPopover.popoverContentSize = CGSizeMake(320.0, 35);
//        // 先去从服务器下载巡察地块数据
//        [DBXCDKListViewCtrl DownLoadXCDK];
//    }
//
//    [self ResizeXCDKListViewPopoverSize:0];
//    
//    ////
//    if ([self.XCDKListViewPopover isPopoverVisible]) {
//        [self SetPopoerHiden];
//    }else {
//        // Present the popover from the button that was tapped in the detail view.
//        [self.XCDKListViewPopover presentPopoverFromRect:tappedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
//    }
    

}

- (void)ViewAppearWithJGDKDataItem:(NSDictionary *)DBJGDKDataDic
{
//    @try {
//        if([self.XCDKListViewPopover isPopoverVisible])
//        {
//            //[DBXCDKListViewCtrl SetSubPopoverHiden];
//            [self.XCDKListViewPopover dismissPopoverAnimated:NO];
//        }
//        // 如果是第一次，则创建
//        if (DBXCDKDetailViewCtrl == nil) {
//            self.DBXCDKDetailViewCtrl = [[DBXCDKDetailViewController alloc] init];
//            [self.DBXCDKDetailViewCtrl setDBXCDKDataDic:DBJGDKDataDic];
//            DBXCDKDetailViewCtrl.delegate = self;
//            [self setXCDKDataView:DBXCDKDetailViewCtrl.view];
//            
//            self.XCDKDataView.frame = CGRectMake(-405, 44, 433, 704);
//            [self.view addSubview:self.XCDKDataView];
//        }else {
//            if (self.DBXCDKDetailViewCtrl.nTaskRunningFlg == 1) {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                                message:@"当前在任务巡查中，请先保存退出当前任务."
//                                                               delegate:self
//                                                      cancelButtonTitle:@"确定"
//                                                      otherButtonTitles: nil];
//                [alert show];
//            }else{
//                [self.DBXCDKDetailViewCtrl setDBXCDKDataDic:DBJGDKDataDic];
//                [self.DBXCDKDetailViewCtrl SubjectViewReloadData];
//            }
//        }
//        
//        // 根据巡查的闲置地块BSM下载地块几何数据
//        NSString *dkId = [DBJGDKDataDic valueForKey:@"Id"];
//        
//        NSString *Bsm = [DBJGDKDataDic valueForKey:@"DKBSM"];
//        [self.SingleManager setXCDKDownloadDeg:self];
//        [self.SingleManager DownLoadXZDKFeatureByBsm:Bsm XCDKDataId:dkId];
//        
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.4];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//        self.XCDKDataView.frame = CGRectMake(0, 44, 433, 704);
//        self.BaseMapView.frame = CGRectMake(400, 0, 1024 - 400, 704);
//        [self.DBXCDKDetailViewCtrl setBCloseBtnFlg:NO];
//        [UIView commitAnimations];
//    }
//    @catch (NSException *exception) {
//        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
//    }
//    @finally {
//        
//    }

}

- (void)XCDKGeometryLocation:(NSString*)XCDKId
{
//    [self XCDKGeometryDownloadFinish:XCDKId];
}
#pragma mark DBXCDKDataViewDelegate
-(void)DisplayGeometryNameView:(NSString*)GeometryName GeometryMemo:(NSString*)Memo
{
//    //AllConf popover view
//    if (_DBXCGeometryNameContrl == nil) {
//        _DBXCGeometryNameContrl = [[[DBXCGeometryNameViewController alloc] init] autorelease];
//        _DBXCGeometryNameContrl.delegate = self;
//        UINavigationController *nav3 = [[UINavigationController alloc] initWithRootViewController:_DBXCGeometryNameContrl];
//        
//        _DBXCGeometryNamePopoverView = [[UIPopoverController alloc] initWithContentViewController:nav3];
//        [nav3 release];
//        //[self.DBXCGeometryNamePopoverView setPassthroughViews:InteractionViews];
//        _DBXCGeometryNamePopoverView.popoverContentSize = CGSizeMake(300, 220);
//        _DBXCGeometryNamePopoverView.delegate = self;
//    }
//    
//    [_DBXCGeometryNameContrl DBXCGeometryNameViewAppear:GeometryName GeometryMemo:Memo];
//    
//    float fWidth = 400.0f;
//    float fHeight = 500.0f;
//    float fXpos = 1024 / 2 - fWidth / 2;
//    float fYpos = 748 / 2 - fHeight / 2;
//    CGRect frame = CGRectMake(fXpos, fYpos, fWidth, fHeight);
//    [_DBXCGeometryNamePopoverView presentPopoverFromRect:frame inView:self.view permittedArrowDirections:0 animated:YES];
//    
}

#pragma mark DBXCGeometryNameViewDelegate
- (void)AddGeometry:(NSString*)Name Memo:(NSString*)Memo
{
    [self SetPopoerHiden];
//    [self.DBXCDKDetailViewCtrl AddGeometryItem:Name Memo:Memo];
}
-(void)AddGeometryCancel
{
    [self SetPopoerHiden];
}

-(void)OpenPolygonDrawing
{
    [self StopMeasureOperation];
    [self.graphicsLayer removeAllGraphics];
    [self.graphicsLayer dataChanged];
    
    [self polygonTouched:self.PolygonBtn];
}
-(void)DisplayGeometryOnMap:(AGSGeometry*)Geometry
{
    if (Geometry == nil) {
        return;
    }
    [self.graphicsLayer removeAllGraphics];
    // Create a SFS for the inner buffer zone
    AGSSimpleFillSymbol *innerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
    innerSymbol.color = [[UIColor redColor] colorWithAlphaComponent:0.40];
    innerSymbol.outline.color = [UIColor darkGrayColor];
    
    // Create a SFS for the outer buffer zone
    AGSSimpleFillSymbol *outerSymbol = [AGSSimpleFillSymbol simpleFillSymbol];
    outerSymbol.color = [[UIColor yellowColor] colorWithAlphaComponent:0.25];
    outerSymbol.outline.color = [UIColor darkGrayColor];
    
    pointInfoTemplate *pointTemplate = [[pointInfoTemplate alloc] init];
    //用原生的Graphic
//    AGSGraphic *graphic = [[AGSGraphic alloc] initWithGeometry:Geometry symbol:innerSymbol attributes:nil infoTemplateDelegate:pointTemplate];
//    [self.graphicsLayer addGraphic:graphic];
//    [graphic release];
    //用自定义的Graphic
    DBAGSGraphic *graphic = [[DBAGSGraphic alloc] initWithGeometry:Geometry symbol:outerSymbol attributes:nil infoTemplateDelegate:pointTemplate];
    graphic.bIsHighlighted = NO;
    graphic.TypeFlg = 2;
    //设置地块相关信息
    graphic.symbol = innerSymbol;
    graphic.bIsHighlighted = YES;
    [self.graphicsLayer addGraphic:graphic];
    [graphic release];
    
    if ([Geometry isKindOfClass:[AGSPolygon class]])
    {
        AGSPolygon *Poly = (AGSPolygon*)Geometry;
        AGSGeometryEngine *geoEng = [AGSGeometryEngine defaultGeometryEngine];
        AGSMutablePoint *newCenterPoint = [geoEng labelPointForPolygon:Poly];
        if (newCenterPoint != nil) {
            [self.BaseMapView zoomToScale:50 withCenterPoint:newCenterPoint animated:YES];
        }
    }
    [self.graphicsLayer dataChanged];
}

- (void)ResizeXCDKListViewPopoverSize:(NSInteger)nJGState
{
//    int nCnt = 0;
//    if (nJGState == 0) {
//        nCnt = [[SingleManager XCDKList] count];
//    }
//    else{
//        nCnt = [[SingleManager JGXCDKList] count];
//    }
//    CGFloat pHeight = 0.0f;
//    if (nCnt == 0) {
//        pHeight = 105;
//    }else if(nCnt < 6){
//        pHeight = 70 * nCnt + 105;
//    }else if(nCnt >= 6){
//        pHeight = 500;
//    }
//    _XCDKListViewPopover.popoverContentSize = CGSizeMake(320.0, pHeight);
}

#pragma mark 闲置地巡查地块数据查询代理
// 闲置地巡查地块数据查询结束
- (void)XCDKGeometryDownloadFinish:(NSString*)XCDKID
{
    NSDictionary *DataDic = [SingleManager.XCDKGeometryDataDic objectForKey:XCDKID];
    DBTopicDKDataItem *DKDataItem;
    for (DKDataItem in [DataDic allValues]) {
        AGSGeometry * geo = [DKDataItem DKGeometry];
        [self DisplayGeometryOnMap:geo];
    }
}
// 闲置地巡查地块数据查询结束
- (void)XCDKGeometryDownloadError:(NSString*)XCDKID
{
    
}
-(void)DisplayLoadingXCDKView:(NSString*)Msg
{
    [self DisplayLoadingView:nil TipText:Msg];
}
//  巡查记录上传完成
- (void)XCRecordUploadFinish:(NSString*)XCDKID
{
    [self HidLoadingView:nil afterDelay:0];
}
//  巡查记录上传出错
- (void)XCRecordUploadError:(NSString*)XCDKID
{
    [self HidLoadingView:nil afterDelay:0];
}
#pragma mark 图层查询菜单点击响应处理代理
- (void)MapLayerQuery:(NSString*)Layer
{
    [self.QueryMenuPopoverView dismissPopoverAnimated:NO];

    if (_sketchLayer.geometry != nil) {
        if ([Layer isEqualToString:@"GISDJZD"]) {
            [self DJQuery];
        }
        else{
            [self CommonQuery:Layer];
        }
    }
    else{
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        [DataMan CreateFailedAlertViewWithFailedInfo:@"请指定一个查询区域" andWithMessage:nil];
    }
    
    return;
}
-(void)ResetPlayBtn
{
    UIImage *image;
    image = [UIImage imageNamed:@"PlanTopBtn.png"];
    bIsPlanBtnTouched = NO;
    [self.PlanBtn setBackgroundImage:image forState:UIControlStateNormal];
}

- (void)drawGeometry:(AGSGeometry *)geometry{
   
    AGSGeometry *ClipedGeo = [self CalculateInnerArea:geometry];
    AGSCompositeSymbol* compositeSel = [self GetRandSymbol];
    AGSGraphic *Graphic = [AGSGraphic graphicWithGeometry:ClipedGeo symbol:compositeSel attributes:nil infoTemplateDelegate:nil];
        
    // add pushpin to graphics layer
    [self.graphicsLayer addGraphic:Graphic];
}

- (void)addText:(NSString *)text forGeometry:(AGSGeometry *)geometry{
    
    AGSCompositeSymbol *csVal = [self GetSymbolWithNumber:1231 UnitText:text TypeFlg:2];
    AGSGeometryEngine *GeoEng = [AGSGeometryEngine defaultGeometryEngine];
    geometry = [self CalculateInnerArea:geometry];
    
    // 测量完成
    if ([geometry  isKindOfClass:[AGSPolygon class]] )
    {
        // 测量面的场合
        AGSPolygon *poly = (AGSPolygon*)geometry;
        AGSPoint *LabelPoint = [GeoEng labelPointForPolygon:poly];
        if (LabelPoint != nil) {
            // 在此位置显示面积文字
            AGSGraphic *Graphic2 = [AGSGraphic graphicWithGeometry:LabelPoint symbol:csVal attributes:nil infoTemplateDelegate:nil];
            [self.graphicsLayer addGraphic:Graphic2];
        }
        
    }
}

- (void)popoverWithViewController:(UIViewController *) controller{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:controller];
    _singleDataPopover = [[UIPopoverController alloc] initWithContentViewController:nav];
    _singleDataPopover.popoverContentSize = CGSizeMake(240, 450);
    _singleDataPopover.delegate = self;
    
    CGRect frame = CGRectMake(0.0f, 293.0f, 240.0f, 500.0f);
    [_singleDataPopover presentPopoverFromRect:frame inView:self.view permittedArrowDirections:0 animated:YES];
}

#pragma mark - locationManagerDelegate Method
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    // if the location is older than 30s ignore
    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30 )
    {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) return;
    CGPoint pnt;
    //获取位置信息
    pnt.x = newLocation.coordinate.longitude;
    pnt.y = newLocation.coordinate.latitude;
    
    CGPoint mecPoint = [self lonLat2HZXian80:pnt];
    AGSPoint *mappoint =[[AGSPoint alloc] initWithX:mecPoint.x y:mecPoint.y spatialReference:nil ];
    [self RemoveOrgGpsGraphic];
    
    AGSPictureMarkerSymbol *pt;
    pt = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"GpsDisplay.png"];

    DBAGSGraphic *pushpin = [[DBAGSGraphic alloc] initWithGeometry:mappoint symbol:pt attributes:nil infoTemplateDelegate:nil];
    [pushpin setTypeFlg:3];
    [self.graphicsLayer addGraphic:pushpin];
    [pushpin release];
    [self.graphicsLayer dataChanged];
    
    [self.BaseMapView centerAtPoint:mappoint animated:YES];
    [mappoint release];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        if ([CLLocationManager locationServicesEnabled]) {
            [manager stopUpdatingLocation];
        }
    }
    else{
        if (manager.locationServicesEnabled) {
            [manager stopUpdatingLocation];
        }
    }

}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations objectAtIndex:[locations count] - 1];
    
    if (fabs([newLocation.timestamp timeIntervalSinceDate:[NSDate date]]) > 30 )
    {
        return;
    }
    
    if (newLocation.horizontalAccuracy < 0) return;
    CGPoint pnt;
    //获取位置信息
    pnt.x = newLocation.coordinate.longitude;
    pnt.y = newLocation.coordinate.latitude;
    
    CGPoint mecPoint = [self lonLat2HZXian80:pnt];
    AGSPoint *mappoint =[[AGSPoint alloc] initWithX:mecPoint.x y:mecPoint.y spatialReference:nil ];
    [self RemoveOrgGpsGraphic];
    
    AGSPictureMarkerSymbol *pt;
    pt = [AGSPictureMarkerSymbol pictureMarkerSymbolWithImageNamed:@"GpsDisplay.png"];
    
    DBAGSGraphic *pushpin = [[DBAGSGraphic alloc] initWithGeometry:mappoint symbol:pt attributes:nil infoTemplateDelegate:nil];
    [pushpin setTypeFlg:3];
    [self.graphicsLayer addGraphic:pushpin];
    [pushpin release];
    [self.graphicsLayer dataChanged];
    
    [self.BaseMapView centerAtPoint:mappoint animated:YES];
    [mappoint release];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0)
    {
        if ([CLLocationManager locationServicesEnabled]) {
            [manager stopUpdatingLocation];
        }
    }
    else{
        if (manager.locationServicesEnabled) {
            [manager stopUpdatingLocation];
        }
    }
    return;
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    return;
}
-(CGPoint )lonLat2HZXian80:(CGPoint ) lonLat
{
    
    //---------------------------------------------------------------------------
    CGPoint mercator;
    double lat = lonLat.y;
    double lon = lonLat.x;
    double h=0;
    double x1, y1, z1, x2, y2, z2, val1, val2;
    EarthToSpace(lat, lon, h, &x1, &y1, &z1);
    SpaceToSpace(&x1, &y1, &z1);
    x2 = x1;
    y2 = y1;
    z2 = z1;
    SpaceToEarth(&x2, &y2, &z2);
    double a=6378140,b=298.25722101;//西安80的长轴和偏心率
    BL_xy(x2, y2, &val1, &val2,a,b);//调用算法
    mercator = CGPointMake(val2, val1);
    return mercator;
}


-(void)RemoveOrgGpsGraphic
{
    NSArray *graphics = [[self.graphicsLayer graphics] mutableCopy];
    for (AGSGraphic *gra in graphics) {
        if ([gra isKindOfClass:[DBAGSGraphic class]]) {
            DBAGSGraphic *gra2 = (DBAGSGraphic*)gra;
            if ([gra2 TypeFlg] == 3) {
                [self.graphicsLayer removeGraphic:gra];
            }
        }
    }
    
}

#pragma mark - coordinate transfer method

#define PI 3.1415926535898
void SpaceToSpace(double *x, double *y, double *z)
{
    double dx = -58.856730;
    double dy = 128.775110;
    double dz = 60.154780;
    //单位是秒
    double rx = -0.990792996807925;
    double ry = -1.25796780033979;
    double rz = 2.5622833026433;
    
    //转换成弧度
    double m = -0.000023677927;
    
    rx = SecondToRadian(rx);
    ry = SecondToRadian(ry);
    rz = SecondToRadian(rz);

    double X = *x;
    double Y = *y;
    double Z = *z;
    *x = (1 + m) * (X + rz * Y - ry * Z) + dx;
    *y = (1 + m) * (-rz * X + Y + rx * Z) + dy;
    *z = (1 + m) * (ry * X - rx * Y + Z) + dz;
}

void EarthToSpace(double lat, double lon, double h, double *X, double *Y, double *Z)
{
    double WGS84_A = 6378137;
    //WGS-84椭球体短半轴b
    double WGS84_B = 6356752.3142;
    //WGS-84椭球偏心率e的平方
    double WGS84_E2 = 0.0066943799013;
    
    double a = WGS84_A;
    double b = WGS84_B;
    double e2 = WGS84_E2;
    
    double B = DMSToRadian(lat);
    double L = DMSToRadian(lon);
    double H = h;
    double W = sqrt(1 - e2 * sin(B) * sin(B));
    double N = a / W;
    *X = (N + H) * cos(B) * cos(L);
    *Y = (N + H) * cos(B) * sin(L);
    *Z = (N * (1 - e2) + H) * sin(B);
}


void SpaceToEarth(double *val1, double *val2, double *val3)
{
    //全国1980西安坐标系(1975国际椭球体)参数
    double C80_A = 6378140.0000000000;
    double C80_B = 6356755.2882;
    double C80_E2 = 0.006694384999588;
    //迭代允许的误差0.0001秒
    double LIMIT = tan(0.0001 * PI / (3600 * 180));
    
    double e2 = C80_E2;
    double a = C80_A;
    
    double W = sqrt(1 - e2 * sin(*val1) * sin(*val1));
    double N = a / W;
    double X = *val1;
    double Y = *val2;
    double Z = *val3;
    double m ;
    m = sqrt(pow(X,2)+pow(Y,2));
    *val2 = atan(Y/X);
    if(*val2<0)
        *val2 +=PI;
    double e2_ = e2/(1-e2);
    double c = a*sqrt(1+e2_);
    double ce2 = c*e2;
    double k = 1+e2_;
    double front = Z/m;
    double temp = front;
    int count = 0;
    do
    {
        front = temp;
        m = sqrt(pow(X,2)+pow(Y,2));
        temp = Z/m + ce2*front/(m*sqrt(k+pow(front,2)));
        count ++;
    }
    while(fabs(temp - front)>LIMIT&&count<100000);//是否在允许误差内
    *val1 = atan(temp);
    if(*val1<0)
        *val1 += PI;
    W = sqrt(1 - e2 * sin(*val1) * sin(*val1));
    N = a / W;
    *val3 = m/cos(*val1) - N;
    
    *val1 = RadianToDMS(*val1);
    *val2 = RadianToDMS(*val2);
}

void BL_xy(double B, double L, double *x, double *y, double a, double f)
{
    BL_xy1(B, L, x, y, a, f, 3, true);
}

void BL_xy1(double B, double L, double *x, double *y, double a, double f, int beltWidth, bool assumedCoord)
{
    int beltNum;                           //投影分带的带号
    beltNum = (int)ceil((L - (beltWidth == 3 ? 1.5 : 0)) / beltWidth);
    if (beltWidth == 3 && beltNum * 3 == L - 1.5) beltNum += 1;
    L -= beltNum * beltWidth - (beltWidth == 6 ? 3 : 0);
    Bl_xy(B, L, x, y, a, f, beltWidth);
    //换算成假定坐标，平移500km，前面加带号
    if (assumedCoord) *y += 500000;// +beltNum * 1000000;
}

void Bl_xy(double B, double dL, double *x, double *y, double a, double f, int beltWidth)
{
    double ee = (2 * f - 1) / f / f;       //第一偏心率的平方
    double ee2 = ee / (1 - ee);            //第二偏心率的平方
    double rB, tB, m;
    rB = B * PI / 180;
    tB = tan(rB);
    m = cos(rB) * dL * PI / 180;
    double N = a / sqrt(1 - ee * sin(rB) * sin(rB));
    double it2 = ee2 * pow(cos(rB), 2);
    *x = m * m / 2 + (5 - tB * tB + 9 * it2 + 4 * it2 * it2) * pow(m, 4) / 24 + (61 - 58 * tB * tB + pow(tB, 4)) * pow(m, 6) / 720;
    *x = MeridianLength(B, a, f) + N * tB * *x;
    *y = N * (m + (1 - tB * tB + it2) * pow(m, 3) / 6 + (5 - 18 * tB * tB + pow(tB, 4) + 14 * it2 - 58 * tB * tB * it2) * pow(m, 5) / 120);
}

double MeridianLength(double B, double a, double f)
{
    double ee = (2 * f - 1) / f / f; //第一偏心率的平方
    double rB = B * PI / 180; //将度转化为弧度
    //子午线弧长公式的系数
    double cA, cB, cC, cD, cE;
    cA = 1 + 3 * ee / 4 + 45 * pow(ee, 2) / 64 + 175 * pow(ee, 3) / 256 + 11025 * pow(ee, 4) / 16384;
    cB = 3 * ee / 4 + 15 * pow(ee, 2) / 16 + 525 * pow(ee, 3) / 512 + 2205 * pow(ee, 4) / 2048;
    cC = 15 * pow(ee, 2) / 64 + 105 * pow(ee, 3) / 256 + 2205 * pow(ee, 4) / 4096;
    cD = 35 * pow(ee, 3) / 512 + 315 * pow(ee, 4) / 2048;
    cE = 315 * pow(ee, 4) / 131072;
    //子午线弧长
    return a * (1 - ee) * (cA * rB - cB * sin(2 * rB) / 2 + cC * sin(4 * rB) / 4 - cD * sin(6 * rB) / 6 + cE *sin(8 * rB) / 8);
}

double SecondToRadian(double s)
{
    return s / 3600.0 /180 * PI;
}


double RadianToDMS(double radian)
{
    return radian * 180 / PI;
}

double DMSToRadian(double angle)
{
    return PI * angle / 180;
}



#pragma mark 议题视图拖动代理
-(void)ViewDragMove:(double)dx
{
    CGRect rec2 = [self.BaseMapView frame];
    rec2.origin.x = rec2.origin.x + dx * 2;
    rec2.size.width = rec2.size.width - dx * 2;
    self.BaseMapView.frame = rec2;

}

#pragma mark add 2016.02.21
- (IBAction)MapYingXiangBtnClick:(id)sender {
    [self hideDataMapLayer];
    
    [NSThread detachNewThreadSelector:@selector(BaseMapSwitchThreadFunc:) toTarget:self withObject:SATELLITE_MAPLAYER_NAME];
    
    return;
}
- (IBAction)MapCommonBtnClick:(id)sender {
    [self hideDataMapLayer];
    
    [NSThread detachNewThreadSelector:@selector(BaseMapSwitchThreadFunc:) toTarget:self withObject:DEFAULT_MAPLAYER_NAME];
    return;
}
- (IBAction)MapMixedBtnClick:(id)sender
{
    [self hideDataMapLayer];
    [NSThread detachNewThreadSelector:@selector(BaseMapSwitchThreadFunc:) toTarget:self withObject:MIX_MAPLAYER_NAME];
    
    return;
}

-(void)hideDataMapLayer
{
    [self hideLayerComm:_chengGuiMenuBtn key:top_Bar_Btn_chengGui];
    [self hideLayerComm:_tuGuiMenuBtn key:top_Bar_Btn_tuGui];
    
    [_chengGuiMenuBtn setSelected:NO];
    [_tuGuiMenuBtn setSelected:NO];
    
    return;
}
// end


// add by niurg 2015.9
////////////////////////////// 底图切换 begin

- (IBAction)MapTypeSegCtrlClick:(id)sender {
    
    UISegmentedControl *MapTypeSegCtrl = (UISegmentedControl*)sender;
    int nSelIndex = MapTypeSegCtrl.selectedSegmentIndex;
    NSString *mapName = nil;
    if (nSelIndex == 0) {
        mapName = DEFAULT_MAPLAYER_NAME;
    }
    else if (nSelIndex == 1) {
        mapName = SATELLITE_MAPLAYER_NAME;
    }
    else {
        mapName = MIX_MAPLAYER_NAME;
    }
    NSString *param = [NSString stringWithFormat:@"%@", mapName];
    [NSThread detachNewThreadSelector:@selector(BaseMapSwitchThreadFunc:) toTarget:self withObject:param];
}

-(void)BaseMapSwitchThreadFunc:(NSString *)param
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        [NSThread sleepForTimeInterval:0.05];
        [self performSelectorOnMainThread:@selector(BaseMapSwitchOperation:) withObject:param  waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [pool release];
    }
    
    return;
}

-(void)BaseMapSwitchOperation:(id)param
{
    NSString *mapType = (NSString*)param;
    [self BaseMapLayerSet:mapType];
    return;
}
////////////////////////////// 底图切换 end

//////////////////////////////  系统配置 begin
- (IBAction)MapToolsBtnClick:(id)sender {
    if (!_mapToolsView) {
        // 5边距，58为按钮宽度
        CGFloat fWidth = (5 + 58) * 4;
        CGFloat fYPos = _MapToolsBtn.frame.origin.y + _MapToolsBtn.frame.size.height + 3;
        
        // 状态栏+工具栏+测量提示栏+间隔
        fYPos = 22 + 64 + 37 + 10;
        _mapToolsView = [[DBMapToolsView alloc] initWithFrame:CGRectMake(680, fYPos, fWidth, 45)];
        UIColor *color = [UIColor colorWithPatternImage:[UIImage imageNamed:@"TopBarBackground.png"]];
        [_mapToolsView setBackgroundColor:color];
        [_mapToolsView setDelegate:self];
        [self.view addSubview:_mapToolsView];
        [_mapToolsView release];
    }
    else{
        [_mapToolsView setHidden:!_mapToolsView.hidden];
    }

    
    return;
}

- (IBAction)MapToolsBtnClick2:(id)sender {
    [self MapToolsBtnClick:sender];
    
    return;
}

- (IBAction)MapConfBtnClick:(id)sender {
    [NSThread detachNewThreadSelector:@selector(AllConfThreadFunc) toTarget:self withObject:nil];
    return;
}

-(void)AllConfThreadFunc
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        [NSThread sleepForTimeInterval:0.05];
        [self performSelectorOnMainThread:@selector(AllConfOperation) withObject:nil  waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [pool release];
    }
    
    return;
}

-(void)AllConfOperation
{
    [self AllConf];
    return;
}
///////////////////////////////系统配置 end

// end

- (IBAction)MapLayerBtnClick:(id)sender {
    UIButton *tappedButton = (UIButton *)sender;
    [self LastClickButtonCancel:tappedButton ClearGraphicFlg:YES];
    //init popoverContentSize
    int nCnt = [[SingleManager MapLayerDataArray] count];
    if (nCnt == 0) {
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        BOOL bNetConn = [DataMan InternetConnectionTest];
        if (!bNetConn) {
            //[DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
            NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DBMapLayerData.xml"];
            NSData *data = [NSData dataWithContentsOfFile:filePath];
            if (data != nil){
                [DataMan ParseMapLayerData:data];
                // 添加业务图层
                [self AddDataMapLayer];
                [self AddMarkData];
            }
            else {
                [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接,并且本地无图层数据." andWithMessage:nil];
            }
            if ([_DataMapLayerViewPopover isPopoverVisible])
            {
                [self SetPopoerHiden];
            }else
            {
                UIButton *tappedButton = (UIButton *)sender;
                // Present the popover from the button that was tapped in the detail view.
                [_DataMapLayerViewPopover presentPopoverFromRect:tappedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
            }
            return;
        }
        
        _DataMapLayerViewPopover.popoverContentSize = CGSizeMake(270, 37);
        //下载图层数据
        [SingleManager DownLoadMapLayerData:@""];
    }
    if ([_DataMapLayerViewPopover isPopoverVisible])
    {
        [self SetPopoerHiden];
    }else
    {
        UIButton *tappedButton = (UIButton *)sender;
        // Present the popover from the button that was tapped in the detail view.
        [_DataMapLayerViewPopover presentPopoverFromRect:tappedButton.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    
    return;
}

- (IBAction)MapLayerBtnClick2:(id)sender {
    [self MapLayerBtnClick:sender];
    
    return;
}

// add by niurg 2015.9
#pragma mark 工具操作代理 （DBMapToolsViewDelegate）

// 第N个按钮被按下
// 0:长度计算       1：面积计算      2:添加标注      3:清除
- (void)btnClickedAtIndex:(UIButton*)sender
{
    NSInteger nIndex = [sender tag] - 100;
    if (nIndex == 0) {
        // length
        if(sender.isSelected)
        {
            _sketchLayer.geometry = nil;
            _sketchLayer.geometry = [[[AGSMutablePolyline alloc] initWithSpatialReference:_BaseMapView.spatialReference] autorelease];
            bIsMeasureDataCalcuate = YES;
            [self DisplayCaluData:@"点击地图以添加点"];
        }
        else {
            [self StopMeasureOperation];
        }
    }
    else if (nIndex == 1)
    {
        // area mesure
        if(sender.isSelected)
        {
            _sketchLayer.geometry = nil;
            _sketchLayer.geometry = [[[AGSMutablePolygon alloc] initWithSpatialReference:_BaseMapView.spatialReference] autorelease];
            bIsMeasureDataCalcuate = YES;
            [self DisplayCaluData:@"点击地图以添加点"];
        }
        else {
            [self StopMeasureOperation];
        }
    }
    else if (nIndex == 2)
    {
        
    }
    else if (nIndex == 3)
    {
        // clean map
        [self clearGraphicsBtnClicked:nil];
        [self StopMeasureOperation];
    }
    return;
}

-(void)hideLayerComm:(id)sender  key:(NSString*)key
{
    UIButton *btn = (UIButton*)sender;
    [btn setSelected:!btn.isSelected];
    
    NSDictionary *confDic = [SingleManager topBarBtnConfDic];
    NSDictionary *btnConfDic = [confDic objectForKey:key];
    
    NSString *layerName = [btnConfDic valueForKey:top_Bar_Btn_mapLayerName];
    NSString *layerUrl = [btnConfDic valueForKey:top_Bar_Btn_mapLayerUrl];
    NSString *isTiledLayer = [btnConfDic valueForKey:top_Bar_Btn_mapLayerIsTile];
    
    BOOL bShow = NO;
    if (layerName && layerUrl)
    {
        
        if ([isTiledLayer isEqualToString:@"1"]) {
            // 加载切换图层
            [self MapLayerShow2:layerName layerUrl:layerUrl isShow:bShow];
        }
        else
        {
            // 加载动态图层
            [self MapLayerShow:layerName layerUrl:layerUrl isShow:bShow];
        }
        
    }
    
}
-(void)showLayerComm:(id)sender  key:(NSString*)key
{
    UIButton *btn = (UIButton*)sender;
    [btn setSelected:!btn.isSelected];
    
    NSDictionary *confDic = [SingleManager topBarBtnConfDic];
    NSDictionary *btnConfDic = [confDic objectForKey:key];
    
    NSString *layerName = [btnConfDic valueForKey:top_Bar_Btn_mapLayerName];
    NSString *layerUrl = [btnConfDic valueForKey:top_Bar_Btn_mapLayerUrl];
    NSString *isTiledLayer = [btnConfDic valueForKey:top_Bar_Btn_mapLayerIsTile];
    
    BOOL bShow = btn.isSelected;
    if (layerName && layerUrl)
    {
        
        if ([isTiledLayer isEqualToString:@"1"]) {
            // 加载切换图层
            [self MapLayerShow2:layerName layerUrl:layerUrl isShow:bShow];
        }
        else
        {
            // 加载动态图层
            [self MapLayerShow:layerName layerUrl:layerUrl isShow:bShow];
        }
        
    }
    
    return;
}
// 土地规划按钮点击事件
- (IBAction)tuGuiMenuBtnClick:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (!btn.selected) {
        // 当前为非选中状态，则这次会设置为选中状态，则需要将城规按钮设置为非选中状态
        [_chengGuiMenuBtn setSelected:YES];
        [self hideLayerComm:_chengGuiMenuBtn key:top_Bar_Btn_chengGui];
    }
    else{
        [_chengGuiMenuBtn setSelected:NO];
    }
    
    [self showLayerComm:sender key:top_Bar_Btn_tuGui];
    return;
}

- (IBAction)chengGuiMenuBtnClick:(id)sender {
    UIButton *btn = (UIButton*)sender;
    if (!btn.selected) {
        // 当前为非选中状态，则这次会设置为选中状态，则需要将土地规划按钮设置为非选中状态
        [_tuGuiMenuBtn setSelected:YES];
        [self hideLayerComm:_tuGuiMenuBtn key:top_Bar_Btn_tuGui];
    }
    else{
        [_tuGuiMenuBtn setSelected:NO];
    }
    
    [self showLayerComm:sender key:top_Bar_Btn_chengGui];
    return;
}

- (IBAction)luWangMenuBtnClick:(id)sender {
    [self showLayerComm:sender key:top_Bar_Btn_luWang];
    return;
}

- (IBAction)faZhengMenuBtnClick:(id)sender {
    [self showLayerComm:sender key:top_Bar_Btn_faZheng];
    return;
}



-(void)MapLayerShow:(NSString*)layerName layerUrl:(NSString*)layerUrl isShow:(BOOL)bValue
{
    @try {
        if(bValue)
        {
            // open/display current data layer
            //NSURL *webURL = [[NSURL alloc] initWithString:[LayerUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            AGSDynamicMapServiceLayer *DyLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:[NSURL URLWithString:layerUrl]];
            //AGSDynamicMapServiceLayer *DyLayer = [[AGSDynamicMapServiceLayer alloc] initWithURL:webURL];
            //name the layer. This is the name that is displayed if there was a property page, tocs, etc...
            //[self.BaseMapView addMapLayer:DyLayer withName:layerName];
            int nLayerCnt = [[self.BaseMapView mapLayers] count];
            [DyLayer setRenderNativeResolution:YES];
            [self.BaseMapView insertMapLayer:DyLayer withName:layerName atIndex:nLayerCnt - 2];
            //[DyLayer release];
            [self.BaseMapView  bringSubviewToFront:self.GraphicsView];
        }
        else {
            // close current data layer
            [self.BaseMapView removeMapLayerWithName:layerName];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return;
}

-(void)MapLayerShow2:(NSString*)layerName layerUrl:(NSString*)layerUrl isShow:(BOOL)bValue
{
    @try {
        if(bValue)
        {
            NSURL *MapUrl = [[NSURL alloc] initWithString:[layerUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            AGSTiledMapServiceLayer *tiledLayer = [[AGSTiledMapServiceLayer alloc] initWithURL:MapUrl];
            [MapUrl release];
            
            [tiledLayer setTileDelegate:self];
            [tiledLayer setRenderNativeResolution:YES];
            int nLayerCnt = [[self.BaseMapView mapLayers] count];
            
            UIView<AGSLayerView>* lyr = [self.BaseMapView insertMapLayer:tiledLayer withName:BASEMAPLAYER_NAME atIndex:nLayerCnt - 2];
            [tiledLayer release];
            tiledLayer = nil;
            lyr.drawDuringPanning = YES;
            lyr.drawDuringZooming = YES;
            [self.BaseMapView  bringSubviewToFront:self.GraphicsView];
        }
        else {
            // close current data layer
            [self.BaseMapView removeMapLayerWithName:layerName];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return;
}

// end

@end
