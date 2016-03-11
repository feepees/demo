//
//  DBXCJGViewController.m
//  HZDuban
//
//  Created by sunz on 13-7-3.
//
//

#import "DBXCJGViewController.h"
#import "Logger.h"
#import "DBBaseMapSwitchView.h"
#import "DBLocalTileDataManager.h"
#import "CommHeader.h"
#import "DBCommHandle.h"

@interface DBXCJGViewController ()
{
    BOOL isCurl;
    // 当前测量flag: 0-无测量   1-测量长度  2-测量面积
    int nMeasureFlag;
    BOOL bIsMeasureDataCalcuate;
    DBCommHandle *DBCommHandleObj;
    /*keeps track of the number of points the user has clicked*/
    NSInteger			 _numPoints;		
    
}
@property (retain, nonatomic) DBBaseMapSwitchView *BaseMapSwitchView;
@property (nonatomic, retain) AGSSketchGraphicsLayer* sketchLayer;
@property(nonatomic, retain) IBOutlet AGSGraphicsLayer   *graphicsLayer;
@property (nonatomic, retain) NSMutableArray *geometryArray;
@property (nonatomic, retain) UIView *GraphicsView;
@end

@implementation DBXCJGViewController
@synthesize TopDataDisplayImageView;
@synthesize TopDataDisplayLabel;
@synthesize TopAddMesureBtn;
@synthesize sketchLayer = _sketchLayer;
@synthesize graphicsLayer;
@synthesize geometryArray = _geometryArray;
@synthesize GraphicsView = _GraphicsView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [TopDataDisplayImageView setHidden:YES];
    
    _BaseMapView.touchDelegate = self;
    _BaseMapView.layerDelegate = self;
    self.BaseMapView.touchDelegate = self;
    self.BaseMapView.calloutDelegate = self;
    
    [self InitResoure];
    [self TopTipViewAnimatedDissapper];
    
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
    isCurl = NO;
    // base map switch view
    CGFloat xPos = 0.0f;
    CGFloat yPos = 100.0f;
    CGFloat fWidth = 1024.0f;
    CGFloat fHeight = 700.0f;
    _BaseMapSwitchView = [[DBBaseMapSwitchView alloc] initWithFrame:CGRectMake(xPos, yPos, fWidth, fHeight)];
    [_BaseMapSwitchView setMapConfDelegate:self];
    [self.MapContainterView insertSubview:_BaseMapSwitchView belowSubview:_BaseMapView];
    
    NSString *layerUrl = kTiledMapServiceURL_0;
    
    NSURL *webURL = [[NSURL alloc] initWithString:[layerUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    AGSTiledMapServiceLayer *tiledLayer = [[[AGSTiledMapServiceLayer alloc] initWithURL:webURL] autorelease];
    
    [webURL release];
    
    
    [tiledLayer setRenderNativeResolution:YES];
    
    UIView<AGSLayerView>* lyr = [self.BaseMapView addMapLayer:tiledLayer withName:BASEMAPLAYER_NAME];
    [tiledLayer release];
    lyr.drawDuringPanning = YES;
    lyr.drawDuringZooming = YES;
    
    // Graphics显示图层
    self.graphicsLayer = [AGSGraphicsLayer graphicsLayer];
    [self.graphicsLayer setRenderNativeResolution:YES];
    self.GraphicsView = [self.BaseMapView addMapLayer:self.graphicsLayer withName:@"graphicsLayer"];
    [self.GraphicsView setHidden:NO];
    
    bIsMeasureDataCalcuate= NO;
    
    DBCommHandleObj = [DBCommHandle instance];
    
    return;
}


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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)dealloc {
    [_MapContainterView release];
    [_BaseMapView release];
    [TopDataDisplayImageView release];
    [TopDataDisplayLabel release];
    [TopAddMesureBtn release];
    [_MapLocationBtn release];
    [_BaseMapSwitchBtn release];
    [_LengthBtn release];
    [_AreaBtn release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setMapContainterView:nil];
    [self setBaseMapView:nil];
    [self setTopDataDisplayImageView:nil];
    [self setTopDataDisplayLabel:nil];
    [self setTopAddMesureBtn:nil];
    [self setMapLocationBtn:nil];
    [self setBaseMapSwitchBtn:nil];
    [self setLengthBtn:nil];
    [self setAreaBtn:nil];
    [super viewDidUnload];
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

// 放置大头针
- (void)MapPinSet:(BOOL)bType
{
    [self doCurl];
    return;
}

// 底图设置
- (void)BaseMapLayerSet:(NSString*)Type
{
    [self doCurl];
    [self SetBaseMapType:Type];
    
    return;
}

// 设置底图类型
-(void)SetBaseMapType:(NSString*)strMapType
{
    @try {
          
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
    return;
}


#pragma mark - UIButton Responsder
- (IBAction)BackBtnTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)MapLayerTouched:(id)sender {
}

- (IBAction)XCJGBtnTouched:(id)sender {
}

- (IBAction)polylineTouched:(id)sender {
    @try {
        UIButton *btn = (UIButton*)sender;
        UIImage *image;
        [self LastClickButtonCancel:btn ClearGraphicFlg:NO];
        if((nMeasureFlag == 0) || (nMeasureFlag == 2))
        {
            self.sketchLayer.geometry = nil;
            self.sketchLayer.geometry = [[[AGSMutablePolyline alloc] initWithSpatialReference:_BaseMapView.spatialReference] autorelease];
            bIsMeasureDataCalcuate = YES;
            [self DisplayCaluData:@"点击地图以添加点"];
            image = [UIImage imageNamed:@"MeasureLength2.png"];
            if (nMeasureFlag == 2)
            {
                UIImage *image2 = [UIImage imageNamed:@"measureArea.png"];
                [_AreaBtn setBackgroundImage:image2 forState:UIControlStateNormal];
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

- (IBAction)polygonTouched:(id)sender {
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
                [_LengthBtn setBackgroundImage:image2 forState:UIControlStateNormal];
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

-(void)StopMeasureOperation
{
    nMeasureFlag = 0;
    _BaseMapView.touchDelegate = self;
    _sketchLayer.geometry = nil;
    
    [self TopTipViewAnimatedDissapper];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"GeometryChanged" object:nil];
    return;
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
        [TopDataDisplayLabel setFrame:frame2];
        CGRect frame3 = [TopAddMesureBtn frame];
        float orgHeight3 = 45.0f;
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


- (void)LastClickButtonCancel:(UIButton *)button ClearGraphicFlg:(BOOL)bFlg
{

    //如果callout显示在界面上，则让其隐藏
    if (![self.BaseMapView.callout isHidden]) {
        self.BaseMapView.callout.hidden = YES;
    }

 
}

- (IBAction)MapLocationBtnTouched:(id)sender {
    if(!self.BaseMapView.gps.enabled)
    {
        self.BaseMapView.gps.autoPanMode = AGSGPSAutoPanModeOff;
        [self.BaseMapView.gps start];
        self.BaseMapView.gps.navigationPointHeightFactor = 0.5;
    }
    else {
        [self.BaseMapView.gps stop];
        self.BaseMapView.rotationAngle = 0.0f;
    }
}

- (IBAction)BaseMapBtnTouched:(id)sender {
    [self doCurl];
}

- (IBAction)TopAddMesureClick:(id)sender {
    NSString *disText = [TopDataDisplayLabel text];
    AGSCompositeSymbol *csVal = [DBCommHandleObj GetSymbolWithNumber:1231 UnitText:disText TypeFlg:2];
    AGSGeometryEngine *GeoEng = [AGSGeometryEngine defaultGeometryEngine];
    // 测量完成
    if ([self.sketchLayer.geometry  isMemberOfClass:[AGSMutablePolygon class]] )
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
    else if ([self.sketchLayer.geometry  isMemberOfClass:[AGSMutablePolyline class]] )
    {
        // 测量线的场合
        AGSPolyline *poLine = (AGSPolyline*)self.sketchLayer.geometry;
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
                AGSCompositeSymbol *lineVal = [DBCommHandleObj GetSymbolWithNumber:1231 UnitText:LenString TypeFlg:1];
                AGSPoint *Pos = [AGSPoint pointWithX:Point2.x + 20 y:Point2.y spatialReference:Point2.spatialReference];
                AGSGraphic *Graphic2 = [AGSGraphic graphicWithGeometry:Pos symbol:lineVal attributes:nil infoTemplateDelegate:nil];
                [self.graphicsLayer addGraphic:Graphic2];
            }
  
        }
        
    }
    
    AGSGraphic *Graphic = [AGSGraphic graphicWithGeometry:_sketchLayer.geometry symbol:_sketchLayer.mainSymbol attributes:nil infoTemplateDelegate:nil];
    
    // add pushpin to graphics layer
    [self.graphicsLayer addGraphic:Graphic];
    
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
}

#pragma mark - AGSMapViewTouchDelegate
-(void)mapView:(AGSMapView *) mapView didClickAtPoint:(CGPoint) screen mapPoint:(AGSPoint *)mappoint graphics:(NSDictionary *) graphics
{
    @try {
        [self.graphicsLayer dataChanged];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
    return;
}

@end
