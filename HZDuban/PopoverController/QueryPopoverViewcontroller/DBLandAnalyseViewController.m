//
//  DBLandAnalyseViewController.m
//  HZDuban
//
//  Created by  on 12-8-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBLandAnalyseViewController.h"
#import "Logger.h"
#import "DBLocalTileDataManager.h"
#import "DBDisplayFieldDataItem.h"
#import "CommHeader.h"

//#define top_bar_heigth ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.9 ? 0.f : 44.f)

@interface DBLandAnalyseViewController ()

@property(nonatomic, retain)NSDictionary *DJFieldNameDic;           // 地籍字段名称
@property(nonatomic, retain)NSMutableArray *JZDJFieldNames;         // 基准地价字段名称
@property(nonatomic, retain)NSDictionary *TDLYZTGHFieldNameDic;         // 土地利用总体规划字段名称
@end

@implementation DBLandAnalyseViewController
@synthesize delegate = _delegate;
@synthesize ResultSets = _ResultSets;
@synthesize nType = _nType;
@synthesize geometry = _geometry;
@synthesize AreaLandView = _AreaLandView;
@synthesize LineLandView = _LineLandView;
@synthesize PointLandView = _PointLandView;
@synthesize MapTypeSegCtrl = _MapTypeSegCtrl;
@synthesize DataMapUrl = _DataMapUrl;
@synthesize DKInfoDic;
@synthesize DJFieldNameDic;
@synthesize JZDJFieldNames;
@synthesize TDLYZTGHFieldNameDic;
@synthesize ENNAME;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _nType = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(okeyClick:)] autorelease];
    
    // 底图类型Segment button
    NSArray *segmentTextContent = [NSArray arrayWithObjects:
                                   NSLocalizedString(@"地类图斑", @""),
                                   NSLocalizedString(@"地类界限", @""),
                                   NSLocalizedString(@"线状地物", @""),
                                   nil];
    
    self.DJFieldNameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                           @"权利人名称", @"QLRMC", @"土地坐落", @"TDZL",@"土地用途", @"TDYT",@"土地证号", @"TDZH",@"权属性质", @"QSXZ",@"使用权类型", @"SYQLX",@"宗地面积", @"ZDMJ",nil];

    self.JZDJFieldNames = [NSMutableArray arrayWithObjects:@"OBJECTID", @"生地价格", @"熟地价格", @"面积", @"周长", @"SHAPE.AREA", @"SHAPE", @"YSDM", @"BSM", @"当前分析区域内面积", nil];
    
    self.TDLYZTGHFieldNameDic = [NSDictionary dictionaryWithObjectsAndKeys: @"地类编码", @"DLBM", @"图斑号", @"TBH", @"规划年份", @"GHNF", @"行政区划名称",@"XZQHMC", @"期末规划分类名称", @"期末规划分类名称", @"当前分析区域内面积", @"DQFXQYMJ",nil];
    self.MapTypeSegCtrl = [[UISegmentedControl alloc] initWithItems:segmentTextContent];
    self.MapTypeSegCtrl.selectedSegmentIndex = 0;
    self.MapTypeSegCtrl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.MapTypeSegCtrl.segmentedControlStyle = UISegmentedControlStyleBar;
    float fXPos = 300.0f;
    float fYPos = 10;
    self.MapTypeSegCtrl.frame = CGRectMake(fXPos, fYPos, 350, 30);
    
    [self.MapTypeSegCtrl addTarget:self
                       action:@selector(LandTypeSwitch:)
             forControlEvents:UIControlEventValueChanged];
    // self.navigationItem.titleView = self.MapTypeSegCtrl;
    [self.MapTypeSegCtrl release];
    
    CGRect frame = [self.view frame];
    frame.origin.x = 3.0f;
    frame.origin.y = 0.0f;
    _LineLandView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:_LineLandView];
    
    _PointLandView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:_PointLandView];

    // 默认地类图斑显示
    _AreaLandView = [[UIView alloc] initWithFrame:frame];
    [self.view addSubview:_AreaLandView];
}

-(void)LandTypeSwitch:(id)sender
{
    UISegmentedControl *MapTypeSegCtrl = (UISegmentedControl*)sender;
    int nSelIndex = MapTypeSegCtrl.selectedSegmentIndex;
    if (nSelIndex == 0) {
        [self.view bringSubviewToFront:_AreaLandView];
    }
    else if (nSelIndex == 1) {
        [self.view bringSubviewToFront:_LineLandView];
    }
    else {
        [self.view bringSubviewToFront:_PointLandView];
    }
    
    return;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

#pragma mark 从业务库中查询地籍权属信息
-(void)DisplayDKInfo
{
    if (self.nType == 2) {
        // 地籍权属信息
        DataGridComponentDataSource *AreaDataSource = [[DataGridComponentDataSource alloc] init];
        NSArray *keys = [DJFieldNameDic allKeys];
        int nCount = [keys count];
        int nAreaCnt = 0;
        
        int nTotalCnt = [self.DKInfoDic count];
        for (int nDataNum = 0; nDataNum < nTotalCnt; nDataNum++)
        {
            // 始第一行追加表格头数据
            if (nAreaCnt++ == 0)
            {
                AreaDataSource.columnWidth = [NSMutableArray array];
                AreaDataSource.titles = [NSMutableArray array];
                [AreaDataSource.titles addObject:@"宗地编号"];
                [AreaDataSource.columnWidth addObject:[NSString stringWithFormat:@"%d", 90]];
                for (int nCnt2 = 0; nCnt2 < nCount; nCnt2++)
                {
                    NSString *key = [keys objectAtIndex:nCnt2];
                    if ([key length] <= 0) {
                        key = @"";
                    }
                    NSString *KeyAlias = [DJFieldNameDic valueForKey:key];
                    if ([KeyAlias length] <= 0) {
                        KeyAlias = @"";
                    }
                    [AreaDataSource.titles addObject:KeyAlias];

                    UIFont * font = [UIFont systemFontOfSize:13];
                    CGSize stringSize2 = [KeyAlias sizeWithFont:font];
                    CGFloat stringWidth2 = stringSize2.width + 15;
                    
                    // 设置最低值
                    if (stringWidth2 < 60.0f) {
                        stringWidth2 = 60.0f;
                    }
                    int nColumWidth = stringWidth2;
                    NSString * Width = [NSString stringWithFormat:@"%d", nColumWidth];
                    [AreaDataSource.columnWidth addObject:Width];
                }
                // add caculated area at the last column
                [AreaDataSource.titles addObject:@"当前分析区域内面积"];
                int nColumWidth = 180;
                NSString * Width = [NSString stringWithFormat:@"%d", nColumWidth];
                [AreaDataSource.columnWidth addObject:Width];
                
                
                AreaDataSource.data = [NSMutableArray array];
            }
            
            // 追加实际业务数据
            NSMutableArray *RowDataArr = [[NSMutableArray alloc] initWithCapacity:5];
            NSString *ZDBH = [[[self.DKInfoDic allValues] objectAtIndex:nDataNum] valueForKey:@"ZDBH"];
            [RowDataArr addObject:ZDBH==nil ? @"" : ZDBH];
            NSInteger nMaxColumWidth = 0;
            for (int nCnt = 0; nCnt < nCount; nCnt++)
            {
                NSString *key = [keys objectAtIndex:nCnt];
                NSString *DataValue = [[[self.DKInfoDic allValues] objectAtIndex:nDataNum] valueForKey:key];
                if ([DataValue length] <= 0) {
                    DataValue = @"";
                }
                UIFont * font = [UIFont systemFontOfSize:13];
                CGSize stringSize = [DataValue sizeWithFont:font];
                nMaxColumWidth = stringSize.width;
                
                // 更新当前列宽   Add by niurg 2012-09-19 Start
                NSString * CurrentWidth = [AreaDataSource.columnWidth objectAtIndex:nCnt+1];
                NSInteger nCurrentWidth = [CurrentWidth intValue];
                if (nMaxColumWidth > nCurrentWidth) {
                    NSString * newWidth = [NSString stringWithFormat:@"%d", nMaxColumWidth];
                    [AreaDataSource.columnWidth replaceObjectAtIndex:nCnt+1 withObject:newWidth];
                }
                // 更新当前列宽   Add by niurg 2012-09-19 End
                
                [RowDataArr addObject:DataValue];
            }
            
            // add caculated area value
            AGSGeometry *Geo = [[[self.DKInfoDic allValues] objectAtIndex:nDataNum] valueForKey:@"Geometry"];
            double dArea = [self CalculateInnerArea: Geo];
            NSString *strArea = [NSString stringWithFormat:@"%1.3f平方米", dArea];
            [RowDataArr addObject:strArea];
            
            [AreaDataSource.data addObject:RowDataArr];
            
        }// for loop end
        // 图斑的数据处理
        if (nAreaCnt <= 0) {
            // 追加无数据提示
            [self AddNoDataTip:AreaDataSource];
        }
        DataGridComponent *AreaDataGrid = [[DataGridComponent alloc] initWithFrame:CGRectMake(0, top_bar_heigth, 648, 356) data:AreaDataSource DoubleTitleFlg:1];
        [AreaDataSource release];
        [AreaDataGrid setDelegate:self];
        [self.AreaLandView addSubview:AreaDataGrid];
        [AreaDataGrid release];
        
        // 显示地类图斑
        [self.view bringSubviewToFront:_AreaLandView];
        self.MapTypeSegCtrl.selectedSegmentIndex = 0;
    }// nType end
    else if (self.nType == 3)
    {
        // 总体利用规划
    }
    else if (self.nType == 3)
    {
        // 地价
    }
}
/*
-(void)DisplayDKInfo
{
    if (self.nType == 2) {
        // 地籍权属信息
        DataGridComponentDataSource *AreaDataSource = [[DataGridComponentDataSource alloc] init];
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        NSArray *fieldArr = [[DataMan PhyLayerIdToFieldsDic] objectForKey:self.DataMapUrl];
        int nCount = [fieldArr count];
        int nAreaCnt = 0;

    
        // 最开始第一行追加表格头数据
        if (nAreaCnt++ == 0)
        {
            AreaDataSource.columnWidth = [NSMutableArray array];
            AreaDataSource.titles = [NSMutableArray array];
            for (int nCnt2 = 0; nCnt2 < nCount; nCnt2++)
            {
                CGFloat stringWidth = 0.0f;
                DBDisplayFieldDataItem *DBDisplayFieldData = [fieldArr objectAtIndex:nCnt2];
                NSString *key = [DBDisplayFieldData FIELDDEFALIAS];
                if ([key length] <= 0) {
                    // 没有别名则显示实际名称
                    key = [DBDisplayFieldData FIELDDEFNAME];
                    UIFont * font = [UIFont systemFontOfSize:13];
                    CGSize stringSize = [key sizeWithFont:font];
                    stringWidth = stringSize.width + 15;
                }
                else {
                    UIFont * font = [UIFont systemFontOfSize:13];
                    CGSize stringSize = [key sizeWithFont:font];
                    stringWidth = stringSize.width + 15;
                }
                [AreaDataSource.titles addObject:key];
                
                // 动态设置cell宽度
                NSDictionary *DKDJInfoDic = [[self.DKInfoDic allKeys] objectAtIndex:nCnt2];
                NSString *DataValue = [DKDJInfoDic objectForKey:key];
                if ([DataValue length] <= 0)
                {
                    key = [DBDisplayFieldData FIELDDEFNAME];
                    DataValue = [[self.DKInfoDic allKeys] objectAtIndex:nCnt2];
                }
                UIFont * font = [UIFont systemFontOfSize:13];
                CGSize stringSize2 = [DataValue sizeWithFont:font];
                CGFloat stringWidth2 = stringSize2.width + 15;
                if (stringWidth2 > stringWidth) {
                    stringWidth = stringWidth2;
                }
                // 设置最低值
                if (stringWidth < 60.0f) {
                    stringWidth = 60.0f;
                }
                int nColumWidth = stringWidth;
                NSString * Width = [NSString stringWithFormat:@"%d", nColumWidth];
                [AreaDataSource.columnWidth addObject:Width];
            }
            AreaDataSource.data = [NSMutableArray array];
        }

    }
}
*/

#pragma mark 土地利用现状图层
-(void)DisplayTDLYXZInfo
{
    @try {
        DataGridComponentDataSource *AreaDataSource = [[DataGridComponentDataSource alloc] init];
        int nAreaCnt = 0;
        
        for (AGSIdentifyResult* result in _ResultSets)
        {
            // 现状分析
            NSString *val = [[[result feature] attributes] objectForKey:@"要素代码"];
            if (![val isEqualToString:@"2001010100"]) {
                // 非图斑
                continue;
            }
            if (nAreaCnt++ == 0)
            {
                AreaDataSource.columnWidth = [NSMutableArray array];
                for (int nCnt2 = 0; nCnt2 < 7; nCnt2++)
                {
                    NSString * str = [NSString stringWithFormat:@"%d", 120];
                    [AreaDataSource.columnWidth addObject:str];
                }
                AreaDataSource.titles = [NSMutableArray arrayWithObjects: @"图斑编号", @"座落单位名称",@"地类名称",@"地类类型", @"当前分析区域内面积", @"权属单位名称",nil];
                AreaDataSource.data = [NSMutableArray array];
            }
            //
            //[ds.data addObject:[[[result feature] attributes] allValues]];
            NSMutableArray *arrTmp = [NSMutableArray array];
            id value = [[[result feature] attributes] objectForKey:@"图斑编号"];
            [arrTmp addObject:value];
            
            value = [[[result feature] attributes] objectForKey:@"座落单位名称"];
            [arrTmp addObject:value];
            
            value = [[[result feature] attributes] objectForKey:@"地类名称"];
            [arrTmp addObject:value];
            
            // 北京代码
            //value = [[[result feature] attributes] objectForKey:@"图斑预编号(地类类型)"];
            // 惠州代码
            value = [[[result feature] attributes] objectForKey:@"图斑预编号"];
            [arrTmp addObject:value];
            
            double dArea = [self CalculateInnerArea: [[result feature] geometry]];
            NSString *strArea = [NSString stringWithFormat:@"%1.3f平方米", dArea];
            [arrTmp addObject:strArea];
            
//            value = [[[result feature] attributes] objectForKey:@"图斑地类面积"];
//            [arrTmp addObject:value];
            
            value = [[[result feature] attributes] objectForKey:@"权属单位名称"];
            [arrTmp addObject:value];
            
            [AreaDataSource.data addObject:arrTmp];
        }
        
        // 图斑的数据处理
        if (nAreaCnt <= 0) {
            // 追加无数据提示
            [self AddNoDataTip:AreaDataSource];
        }
        DataGridComponent *AreaDataGrid = [[DataGridComponent alloc] initWithFrame:CGRectMake(0, top_bar_heigth, 648, 356) data:AreaDataSource DoubleTitleFlg:1];
        [AreaDataSource release];
        [AreaDataGrid setDelegate:self];
        [self.AreaLandView addSubview:AreaDataGrid];
        [AreaDataGrid release];
        
        // 显示地类图斑
        [self.view bringSubviewToFront:_AreaLandView];
        self.MapTypeSegCtrl.selectedSegmentIndex = 0;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

#pragma mark  城镇基准地价
-(void)DisplayJZDJInfo
{
    @try {
        DataGridComponentDataSource *AreaDataSource = [[DataGridComponentDataSource alloc] init];
        int nAreaCnt = 0;
        
        for (AGSIdentifyResult* result in _ResultSets)
        {
            int nCount = [JZDJFieldNames count];
            if (nAreaCnt++ == 0)
            {
                AreaDataSource.columnWidth = [NSMutableArray array];
                
                NSMutableArray *FieldTmp = [NSMutableArray arrayWithCapacity:5];
                for (int nCnt2 = 0; nCnt2 < nCount; nCnt2++)
                {
                    NSString * str = [NSString stringWithFormat:@"%d", 120];
                    [AreaDataSource.columnWidth addObject:str];
                    NSString *Key = [JZDJFieldNames objectAtIndex:nCnt2];

                    if([Key isEqualToString:@"BSM"])
                    {
                        Key = @"标识码";
                    }
                    else if ([Key isEqualToString:@"YSDM"])
                    {
                        Key = @"要素代码";
                    }
                    else if ([Key isEqualToString:@"OBJECTID"])
                    {
                        Key = @"对象代码";
                    }
                    else if([Key length] <= 0)
                    {
                        Key = @"";
                    }
                    [FieldTmp addObject:Key];
                    
                }
                AreaDataSource.titles = [NSMutableArray arrayWithArray:FieldTmp];
                AreaDataSource.data = [NSMutableArray array];
            }
            //
            NSMutableArray *Values2 = [NSMutableArray arrayWithCapacity:5];
            for (int nCnt = 0; nCnt < nCount-1; nCnt++)
            {
                //
                NSString *key = [self.JZDJFieldNames objectAtIndex:nCnt];
                NSString *val = [[[result feature] attributes] valueForKey:key];
                if ([val length] <= 0)
                {
                    [Values2 addObject:@""];
                    continue;
                }
                [Values2 addObject:val];
                UIFont * font = [UIFont systemFontOfSize:13];
                CGSize stringSize = [val sizeWithFont:font];
                int nMaxColumWidth = stringSize.width;
                
                // 更新当前列宽   Add by niurg 2012-09-19 Start
                NSString * CurrentWidth = [AreaDataSource.columnWidth objectAtIndex:nCnt];
                NSInteger nCurrentWidth = [CurrentWidth intValue];
                if (nMaxColumWidth > nCurrentWidth) {
                    NSString * newWidth = [NSString stringWithFormat:@"%d", nMaxColumWidth];
                    [AreaDataSource.columnWidth replaceObjectAtIndex:nCnt withObject:newWidth];
                }
                // 更新当前列宽   Add by niurg 2012-09-19 End
            }
            
            float area = [self CalculateInnerArea:[[result feature] geometry]];
            NSString *areaStr = [NSString stringWithFormat:@"%.3f平方米", area];
            [Values2 addObject:areaStr];
            
            [AreaDataSource.data addObject:Values2];
        }
        
        // 图斑的数据处理
        if (nAreaCnt <= 0) {
            // 追加无数据提示
            [self AddNoDataTip:AreaDataSource];
        }
        DataGridComponent *AreaDataGrid = [[DataGridComponent alloc] initWithFrame:CGRectMake(0, top_bar_heigth, 648, 356) data:AreaDataSource DoubleTitleFlg:2];
        [AreaDataSource release];
        [AreaDataGrid setDelegate:self];
        [self.AreaLandView addSubview:AreaDataGrid];
        [AreaDataGrid release];
        
        // 显示地类图斑
        [self.view bringSubviewToFront:_AreaLandView];
        self.MapTypeSegCtrl.selectedSegmentIndex = 0;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}
#pragma mark  土地利用总体规划
-(void)DisplayTDLYZTGHInfo
{
    @try {
        DataGridComponentDataSource *AreaDataSource = [[DataGridComponentDataSource alloc] init];
        int nAreaCnt = 0;
        
        for (AGSIdentifyResult* result in _ResultSets)
        {
            int nCount = [TDLYZTGHFieldNameDic count];
            if (nAreaCnt++ == 0)
            {
                AreaDataSource.columnWidth = [NSMutableArray array];
                AreaDataSource.titles = [NSMutableArray array];

                NSMutableArray *FieldTmp = [NSMutableArray arrayWithCapacity:5];
                for (int nCnt2 = 0; nCnt2 < nCount; nCnt2++)
                {
                    NSString * str = [NSString stringWithFormat:@"%d", 120];
                    [AreaDataSource.columnWidth addObject:str];
                    NSString *FieldName = [[TDLYZTGHFieldNameDic allValues] objectAtIndex:nCnt2];
                    if([FieldName length] <= 0)
                    {
                        FieldName = @"";
                    }
                    [FieldTmp addObject:FieldName];
                    
                }
                [AreaDataSource.titles addObjectsFromArray: FieldTmp];
                AreaDataSource.data = [NSMutableArray array];
            }
            //
            NSMutableArray *Values2 = [NSMutableArray arrayWithCapacity:5];
            for (int nCnt = 0; nCnt < nCount; nCnt++)
            {
                //
                NSString *relKey = [[self.TDLYZTGHFieldNameDic allKeys] objectAtIndex:nCnt];
                
                if ([relKey isEqualToString:@"DQFXQYMJ"]) {
                    float area = [self CalculateInnerArea:[[result feature] geometry]];
                    NSString *areaStr = [NSString stringWithFormat:@"%.3f平方米", area];
                    [Values2 addObject:areaStr];
                    continue;
                }
                
                NSString *val = [[[result feature] attributes] valueForKey:relKey];
                if ([val length] <= 0)
                {
                    [Values2 addObject:@""];
                    continue;
                }
                UIFont * font = [UIFont systemFontOfSize:13];
                CGSize stringSize = [val sizeWithFont:font];
                int nMaxColumWidth = stringSize.width;
                
                // 更新当前列宽   Add by niurg 2012-09-19 Start
                NSString * CurrentWidth = [AreaDataSource.columnWidth objectAtIndex:nCnt];
                NSInteger nCurrentWidth = [CurrentWidth intValue];
                if (nMaxColumWidth > nCurrentWidth) {
                    NSString * newWidth = [NSString stringWithFormat:@"%d", nMaxColumWidth];
                    [AreaDataSource.columnWidth replaceObjectAtIndex:nCnt withObject:newWidth];
                }
                // 更新当前列宽   Add by niurg 2012-09-19 End
                
                [Values2 addObject:val];
            }
           
            [AreaDataSource.data addObject:Values2];
        }
        
        // 图斑的数据处理
        if (nAreaCnt <= 0) {
            // 追加无数据提示
            [self AddNoDataTip:AreaDataSource];
        }
        DataGridComponent *AreaDataGrid = [[DataGridComponent alloc] initWithFrame:CGRectMake(0, top_bar_heigth, 648, 356) data:AreaDataSource DoubleTitleFlg:1];
        [AreaDataSource release];
        [AreaDataGrid setDelegate:self];
        [self.AreaLandView addSubview:AreaDataGrid];
        [AreaDataGrid release];
        
        // 显示地类图斑
        [self.view bringSubviewToFront:_AreaLandView];
        self.MapTypeSegCtrl.selectedSegmentIndex = 0;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    @try {
        [self.MapTypeSegCtrl setHidden:YES];
        if (self.nType > 1) {
            self.title = @"地籍权属信息";
            [self DisplayDKInfo];
            return;
        }
        
        NSRange Range = [self.ENNAME rangeOfString:@"GTL_TDLYXZ"];
        if (Range.location != NSNotFound){
            // 土地利用现状图层
            self.title = @"土地利用现状信息";
            [self DisplayTDLYXZInfo];
            return;
        }
        
        Range = [self.ENNAME rangeOfString:@"jzdjtheme"];
        if (Range.location != NSNotFound)
        {
            // 城镇基准地价
            self.title = @"城镇基准地价信息";
            [self DisplayJZDJInfo];
            return;
        }
        
        Range = [self.ENNAME rangeOfString:@"GTL_HZTDLYZTGH"];
        if (Range.location != NSNotFound)
        {
            // 土地利用总体规划
            self.title = @"土地总体规划信息";
            [self DisplayTDLYZTGHInfo];
        }
        return;
        
        /*                the belw is org source code                   */
        //================================================================
        /*
        if (_nType == 0) 
        {
            [self.MapTypeSegCtrl setHidden:NO];
        }
        else {
            [self.MapTypeSegCtrl setHidden:YES];
        }
        DataGridComponentDataSource *AreaDataSource = [[DataGridComponentDataSource alloc] init];
        DataGridComponentDataSource *LineDataSource = [[DataGridComponentDataSource alloc] init];
        DataGridComponentDataSource *PointDataSource = [[DataGridComponentDataSource alloc] init];
        
        int nAreaCnt = 0;
        int nLineCnt = 0;
        int nPointCnt = 0;
        int nColumWidth = 0;
        for (AGSIdentifyResult* result in _ResultSets) 
        {
            
            if (_nType == 0) {
                // 现状查询
                NSString *val = [[[result feature] attributes] objectForKey:@"要素代码"];
                
                if (![val isEqualToString:@"2001010100"]) {
                    if (![val isEqualToString:@"2001040000"])
                    {
                        NSLog(@"^^^^^ %@",val);
                    }
                }
                if ([val isEqualToString:@"2001010100"]) 
                {
                    // 图斑的场合
                    if (nAreaCnt++ == 0) 
                    {
                        // 最开始追加表格头数据
                        int nCount = [[[result feature] attributes] count];
                        AreaDataSource.columnWidth = [NSMutableArray array];
                        for (int nCnt2 = 0; nCnt2 < nCount; nCnt2++)
                        {
                            nColumWidth = 120;  
                            if ((nCnt2 == 3) ||         // 权属单位代码
                                (nCnt2 == 19))          // 座落单位代码
                            {
                                nColumWidth = 150;
                            }
                            NSString * str = [NSString stringWithFormat:@"%d", nColumWidth];
                            [AreaDataSource.columnWidth addObject:str];
                        }
                        AreaDataSource.titles = [NSMutableArray array];
                        [AreaDataSource.titles setArray:[[[result feature] attributes] allKeys]];
                        AreaDataSource.data = [NSMutableArray array];
                    }
                    [AreaDataSource.data addObject:[[[result feature] attributes] allValues]];
                }
                else if ([val isEqualToString:@"2001040000"]) 
                {
                    // 地类界限的场合
                    if (nLineCnt++ == 0) 
                    {
                        // 最开始追加表格头数据
                        int nCount = [[[result feature] attributes] count];
                        LineDataSource.columnWidth = [NSMutableArray array];
                        for (int nCnt2 = 0; nCnt2 < nCount; nCnt2++)
                        {
                            NSString * str = [NSString stringWithFormat:@"%d", 120];
                            [LineDataSource.columnWidth addObject:str];
                        }
                        LineDataSource.titles = [NSMutableArray array];
                        [LineDataSource.titles setArray:[[[result feature] attributes] allKeys]];
                        LineDataSource.data = [NSMutableArray array];
                    }
                    [LineDataSource.data addObject:[[[result feature] attributes] allValues]];
                }
                else  if ([val isEqualToString:@"2001020100"])
                {
                    // 线状地物的场合
                    if (nPointCnt++ == 0) 
                    {
                        // 最开始追加表格头数据
                        int nCount = [[[result feature] attributes] count];
                        PointDataSource.columnWidth = [NSMutableArray array];
                        for (int nCnt2 = 0; nCnt2 < nCount; nCnt2++)
                        {
                            nColumWidth = 120;  
                            if ((nCnt2 == 20) ||         // 扣除图斑座落单位...
                                (nCnt2 == 21) ||         // 扣除图斑座落单位...
                                (nCnt2 == 22))           // 权属单位代码1
                            {
                                nColumWidth = 150;
                            }
                            NSString * str = [NSString stringWithFormat:@"%d", nColumWidth];
                            [PointDataSource.columnWidth addObject:str];
                        }
                        PointDataSource.titles = [NSMutableArray array];
                        [PointDataSource.titles setArray:[[[result feature] attributes] allKeys]];
                        PointDataSource.data = [NSMutableArray array];
                    }
                    [PointDataSource.data addObject:[[[result feature] attributes] allValues]];
                }
                

            }
            else if(_nType == 1)
            {
                // 现状分析
                NSString *val = [[[result feature] attributes] objectForKey:@"要素代码"];
                if (![val isEqualToString:@"2001010100"]) {
                    // 非图斑
                    continue;
                }
                if (nAreaCnt++ == 0) 
                {
                    AreaDataSource.columnWidth = [NSMutableArray array];
                    for (int nCnt2 = 0; nCnt2 < 7; nCnt2++)
                    {
                        NSString * str = [NSString stringWithFormat:@"%d", 120];
                        [AreaDataSource.columnWidth addObject:str];
                    }
                    //ds.titles = [NSMutableArray array];
                    //
                    //[ds.titles setArray:[[[result feature] attributes] allKeys]];
                    
                    // 北京代码
                    //AreaDataSource.titles = [NSMutableArray arrayWithObjects: @"图斑编号", @"座落单位名称",@"地类名称",@"图斑预编号(地类类型)", @"当前分析区域内面积", @"图斑地类面积",@"权属单位名称",nil];
                    AreaDataSource.titles = [NSMutableArray arrayWithObjects: @"图斑编号", @"座落单位名称",@"地类名称",@"图斑预编号(地类类型)", @"当前分析区域内面积", @"图斑地类面积",@"权属单位名称",nil];
                    AreaDataSource.data = [NSMutableArray array];
                }
                //
                //[ds.data addObject:[[[result feature] attributes] allValues]];
                NSMutableArray *arrTmp = [NSMutableArray array];
                id value = [[[result feature] attributes] objectForKey:@"图斑编号"];
                [arrTmp addObject:value];
                
                value = [[[result feature] attributes] objectForKey:@"座落单位名称"];
                [arrTmp addObject:value];
                
                value = [[[result feature] attributes] objectForKey:@"地类名称"];
                [arrTmp addObject:value];
                
                // 北京代码
                //value = [[[result feature] attributes] objectForKey:@"图斑预编号(地类类型)"];
                // 惠州代码
                value = [[[result feature] attributes] objectForKey:@"图斑预编号"];
                [arrTmp addObject:value];
                
                double dArea = [self CalculateInnerArea: [[result feature] geometry]];
                NSString *strArea = [NSString stringWithFormat:@"%1.3f", dArea];
                [arrTmp addObject:strArea];
                
                value = [[[result feature] attributes] objectForKey:@"图斑地类面积"];
                [arrTmp addObject:value];
                
                value = [[[result feature] attributes] objectForKey:@"权属单位名称"];
                [arrTmp addObject:value];
                
                [AreaDataSource.data addObject:arrTmp];
            }
            
        }
        // 图斑的数据处理
        if (nAreaCnt <= 0) {
            // 追加无数据提示
            [self AddNoDataTip:AreaDataSource];
        }
        DataGridComponent *AreaDataGrid = [[DataGridComponent alloc] initWithFrame:CGRectMake(0, 0, 648, 356) data:AreaDataSource];
        [AreaDataSource release];
        [AreaDataGrid setDelegate:self];
        [self.AreaLandView addSubview:AreaDataGrid];
        [AreaDataGrid release];
        
        if (_nType == 0)
        {
            // 地类界限的数据处理
            if (nLineCnt <= 0) {
                // 追加无数据提示
                [self AddNoDataTip:LineDataSource];
            }
            DataGridComponent *LineDataGrid = [[DataGridComponent alloc] initWithFrame:CGRectMake(0, 0, 648, 356) data:LineDataSource];
            [LineDataSource release];
            [LineDataGrid setDelegate:self];
            [self.LineLandView addSubview:LineDataGrid];
            [LineDataGrid release];
            
            // 线状地物的数据处理
            if (nPointCnt <= 0) {
                // 追加无数据提示
                [self AddNoDataTip:PointDataSource];
            }
            DataGridComponent *PointDataGrid = [[DataGridComponent alloc] initWithFrame:CGRectMake(0, 0, 648, 356) data:PointDataSource];
            [PointDataSource release];
            [PointDataGrid setDelegate:self];
            [self.PointLandView addSubview:PointDataGrid];
            [PointDataGrid release];
        }

        // 默认显示地类图斑
        [self.view bringSubviewToFront:_AreaLandView];
        self.MapTypeSegCtrl.selectedSegmentIndex = 0;
        */
        //================================================================
        /*                      org source code end                     */
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

    return;
}


// 追加无数据提示
-(void)AddNoDataTip:(DataGridComponentDataSource *)DataSource
{
    DataSource.columnWidth = [NSMutableArray array];
    [DataSource.columnWidth addObject:@"100"];
    
    DataSource.titles = [NSMutableArray array];
    NSArray *NoData = [NSArray arrayWithObjects:@"无搜索结果", nil];
    [DataSource.titles setArray:NoData];

//    DataSource.data = [NSMutableArray array];
//    NSArray *NoData2 = [NSArray arrayWithObjects:@"无数据", nil];
//    [DataSource.data addObject:NoData2];
}

// 计算指定区域内的面积
-(double)CalculateInnerArea:(AGSGeometry*) orgGeometry
{
    double area = .0;
    AGSGeometryEngine *engine = [[[AGSGeometryEngine alloc] init] autorelease];
    //AGSGeometry *clipGeometry = [engine clipGeometry:orgGeometry withEnvelope:_geometry.envelope];
    AGSGeometry *clipGeometry = [engine intersectionOfGeometry:orgGeometry andGeometry:_geometry];
    if (clipGeometry != nil) 
    {
        AGSGeometry *tmpGeo = [engine simplifyGeometry:clipGeometry];
        area = [engine areaOfGeometry:tmpGeo];
        area = fabs(area);
    }
    return area;
}

-(void)dealloc
{
    self.DataMapUrl = nil;
    self.AreaLandView = nil;
    self.LineLandView = nil;
    self.PointLandView = nil;
    _ResultSets = nil;
    [self.DKInfoDic release];
    [self.ENNAME release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)okeyClick:(id)sender
{
    [_delegate DBLandAnalyseViewControllerPopoverDone];
}

- (void)didSelectRowAtIndexPath:(NSInteger)indexRow
{
    return;
}

@end
