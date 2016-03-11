//
//  DBLandDataViewController.m
//  HZDuban
//
//  Created by mac on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBSingleLandInfoViewController.h"
#import "Logger.h"
#import "DBLocalTileDataManager.h"
#import "DBDisplayFieldDataItem.h"

@interface DBSingleLandInfoViewController ()

@property (nonatomic, retain) NSDictionary *DJFieldNameDic;
@property (nonatomic, retain) NSDictionary *JZDJFieldNameDic;
@property (nonatomic, retain) NSDictionary *TDZTGHFieldNameDic;
@property (nonatomic, retain) NSDictionary *TDLYXZFieldNameDic;
@property (nonatomic, retain) NSMutableArray *keyOfRowValue;
@property (nonatomic, retain) NSMutableArray *headerTitleArray;
@property (nonatomic, retain) AGSIdentifyResult *identifyResult;

@end

@implementation DBSingleLandInfoViewController

- (id)initWithResult:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        self.result = info;
        self.headerTitleArray = [[NSMutableArray alloc] init];
        self.keyOfRowValue = [[NSMutableArray alloc] init];
        
        [self.headerTitleArray addObject:@"宗地编号"];
        [self.keyOfRowValue addObject:@"ZDBH"];
        self.DJFieldNameDic = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"权利人名称", @"QLRMC", @"土地坐落", @"TDZL",@"土地用途", @"TDYT",@"土地证号", @"TDZH",@"权属性质", @"QSXZ",@"使用权类型", @"SYQLX",@"宗地面积", @"ZDMJ",@"当前分析区域内面积", @"DQFXQYNMJ",nil];
        [self.headerTitleArray addObjectsFromArray: [self.DJFieldNameDic allValues] ];
        [self.keyOfRowValue addObjectsFromArray: [self.DJFieldNameDic allKeys]];
        self.title = @"地籍权属信息";
    }
    return self;
}

- (id)initWithResult:(AGSIdentifyResult *)result andENNAME:(NSString *)ENNAME
{
    self = [super init];
    if (self) {
        self.result = result.feature.attributes;
        self.identifyResult = result;
        self.headerTitleArray = [[NSMutableArray alloc] init];
        self.keyOfRowValue = [[NSMutableArray alloc] init];
        
        if ([ENNAME isEqualToString:@"jzdjtheme"]) {
            self.JZDJFieldNameDic = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"对象代码", @"OBJECTID", @"生地价格", @"生地价格", @"熟地价格",@"熟地价格", @"面积",@"面积", @"周长", @"周长", @"SHAPE.AREA",@"SHAPE.AREA", @"SHAPE", @"SHAPE", @"要素代码", @"YSDM", @"标识码", @"BSM", @"当前分析区域内面积", @"FEATURE_DQFXQYNMJ",nil];
            [self.headerTitleArray addObjectsFromArray:[self.JZDJFieldNameDic allValues]];
            [self.keyOfRowValue addObjectsFromArray:[self.JZDJFieldNameDic allKeys]];
            self.title = @"城镇基准地价信息";
        }else if ([ENNAME isEqualToString:@"GTL_HZTDLYZTGH "]){
            self.TDZTGHFieldNameDic = [NSDictionary dictionaryWithObjectsAndKeys: @"地类编码", @"DLBM", @"图斑号", @"TBH", @"图斑地类面积", @"DLMJ", @"规划年份", @"GHNF", @"行政区划名称",@"XZQHMC", @"期末规划分类名称", @"期末规划分类名称", @"当前分析区域内面积", @"FEATURE_DQFXQYNMJ",nil];
            [self.headerTitleArray addObjectsFromArray:[self.TDZTGHFieldNameDic allValues]];
            [self.keyOfRowValue addObjectsFromArray:[self.TDZTGHFieldNameDic allKeys]];
            self.title = @"土地总体规划信息";
        }else if ([ENNAME isEqualToString:@"GTL_TDLYXZ"]){
            [self.headerTitleArray addObjectsFromArray:[NSArray arrayWithObjects: @"图斑编号", @"座落单位名称",@"地类名称",@"地类类型", @"当前分析区域内面积", @"权属单位名称", nil]];
            [self.keyOfRowValue addObjectsFromArray:[NSArray arrayWithObjects: @"图斑编号", @"座落单位名称",@"地类名称",@"图斑预编号", @"FEATURE_DQFXQYNMJ",@"权属单位名称", nil]];
            self.title = @"土地利用现状信息";
        }
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(okeyClick:)] autorelease];
    LandDataTabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 240, 416) style:UITableViewStyleGrouped];
    LandDataTabView.separatorColor = [UIColor clearColor];
    LandDataTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    LandDataTabView.delegate = self;
    LandDataTabView.dataSource = self;
    LandDataTabView.showsVerticalScrollIndicator = YES;
    [self.view addSubview:LandDataTabView];
    [LandDataTabView release];
}

#pragma mark - okeyButtonResponder
- (void)okeyClick:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(LandDataViewPopoverDone)]) {
        [self.delegate singleLandInfoViewPopoverDone];
    }
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nCnt=1;
    return nCnt;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int nCnt = [self.headerTitleArray count];
    return nCnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        static NSString *string = @"CellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:string];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:string] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UIImage *Image = [UIImage imageNamed:@"SeparateLine"];
            UIImageView *ImageView = [[UIImageView alloc] initWithImage:Image];
            CGRect frame = [cell frame];
            frame.size.height = 1.f;
            frame.size.width = 220.f;
            frame.origin.x = 0.0f;
            frame.origin.y = 4.f;
            [ImageView setFrame:frame];
            [cell.contentView addSubview:ImageView];
            [ImageView release];
            
            [cell setBackgroundColor:[UIColor clearColor]];
            cell.textLabel.font = [UIFont systemFontOfSize:13];
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        }
        NSString *key = [self.keyOfRowValue objectAtIndex:indexPath.section];
        
        if ([key rangeOfString:@"DQFXQYNMJ"].location != NSNotFound) {
            AGSGeometry *geomotry = nil;
            if ([key isEqualToString:@"DQFXQYNMJ"]) {
                geomotry = [self.result objectForKey:@"Geometry"];
            } else {
                geomotry = [[self.identifyResult feature] geometry];
            }
            
            float area = [self CalculateInnerArea:geomotry];
            cell.textLabel.text = [NSString stringWithFormat:@"%.3f平方米", area];
        }else{
            cell.textLabel.text = [self.result objectForKey:key];
        }
        return cell;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [self.keyOfRowValue objectAtIndex:indexPath.section];
    NSString *content = [self.result objectForKey:key];
    
    UIFont * font = [UIFont systemFontOfSize:13];
    CGSize stringSize = [content sizeWithFont:font];
    CGFloat stringWidth = stringSize.width;
    int nVal = stringWidth / 200;
    if(nVal > 1)
    {
        nVal -= 1;
    }
    
    CGFloat height = 30 + (nVal * 30);
    
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 25;
    }
    return 15;
}

// custom view for header. will be adjusted to default or specified header height
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 26)];
    if (section == 0) {
        label.frame = CGRectMake(10, 10, 240, 15);
    }else {
        label.frame = CGRectMake(10, 0, 240, 15);
    }
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = [self.headerTitleArray objectAtIndex:section];
    
    [view addSubview:label];
    [label release];
    
    return [view autorelease];
}

-(double)CalculateInnerArea:(AGSGeometry*) orgGeometry
{
    double area = .0;
    AGSGeometryEngine *engine = [[[AGSGeometryEngine alloc] init] autorelease];
    AGSGeometry *clipGeometry = orgGeometry;
    if (_geometry != nil) {
        clipGeometry = [engine intersectionOfGeometry:orgGeometry andGeometry:_geometry];
    }
    
    if (clipGeometry != nil)
    {
        AGSGeometry *tmpGeo = [engine simplifyGeometry:clipGeometry];
        area = [engine areaOfGeometry:tmpGeo];
        area = fabs(area);
    }
    return area;
}
@end
