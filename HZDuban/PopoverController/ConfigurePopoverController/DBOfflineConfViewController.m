//
//  DBOfflineConfViewController.m
//  HZDuban
//
//  Created by mac on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBOfflineConfViewController.h"
#import "Logger.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"

@interface DBOfflineConfViewController ()

@end

@implementation DBOfflineConfViewController

@synthesize NodifyDelegate;
@synthesize OfflineConfTableView = _OfflineConfTableView;
@synthesize HeaderTitleContentArray = _HeaderTitleContentArray;
@synthesize FirstSectionOptionArray = _FirstSectionOptionArray;
@synthesize FirstSectionSwitchArray = _FirstSectionSwitchArray;
@synthesize SecondSectionOptionArray = _SecondSectionOptionArray;
@synthesize SecondSectionSwitchArray = _SecondSectionSwitchArray;
@synthesize ThirdSectionOptionArray = _ThirdSectionOptionArray;
@synthesize FilePath = _FilePath;
@synthesize ReloadIndexPathsArray = _ReloadIndexPathsArray;


#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
       
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    CGFloat fWidth = 300.0;
    CGFloat fHeight = 450.0;
    self.OfflineConfTableView = [[UITableView alloc]initWithFrame:CGRectMake(xPos, yPos, fWidth, fHeight) style:UITableViewStyleGrouped];
    _OfflineConfTableView.rowHeight = 42.0;
    _OfflineConfTableView.delegate = self;
    _OfflineConfTableView.dataSource = self;
    [self.view addSubview:_OfflineConfTableView];
    [_OfflineConfTableView release];
    
    //解析数据
    self.FirstSectionSwitchArray = [NSMutableArray arrayWithCapacity:0];
    self.SecondSectionSwitchArray = [NSMutableArray arrayWithCapacity:0];
    // 本地本地配置信息文件
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
    //self.FilePath = [[NSBundle mainBundle] pathForResource:@"DBConfigure" ofType:@"xml"];
    self.FilePath = path;
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:_FilePath];
    [self parsedOfflineConfFromData:xmlData];
    [xmlData release];
    
    self.title = @"离线地图配置";  
    self.HeaderTitleContentArray = [NSMutableArray arrayWithObjects:@"网络连通状态", @"网络中断状态", @"通用", nil];
    self.FirstSectionOptionArray = [NSMutableArray arrayWithObjects:@"是否优先加载本地离线数据", @"是否更新本地离线数据", @"是否保存在线数据", nil];
    self.SecondSectionOptionArray = [NSMutableArray arrayWithObjects:@"是否加载本地离线数据", nil];
    self.ThirdSectionOptionArray = [NSMutableArray arrayWithObjects:@"清除本地离线数据", @"下载底图切片数据", nil];
    // 锁对象
    valueCondition = [[NSCondition alloc] init];
    ProgressValue = 0;
    self.ReloadIndexPathsArray = [NSArray arrayWithObjects: [NSIndexPath indexPathForRow:1 inSection:2], nil];
    bIsUpdateLocalData = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)dealloc
{
    self.HeaderTitleContentArray = nil;
    self.FirstSectionOptionArray = nil;
    self.FirstSectionSwitchArray = nil;
    self.SecondSectionOptionArray = nil;
    self.SecondSectionSwitchArray = nil;
    self.ThirdSectionOptionArray = nil;
    self.ReloadIndexPathsArray = nil;
    [valueCondition release];
    
    [super dealloc];
}

-(void)viewWillAppear:(BOOL)animated
{
    @try 
    {
        
        
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:_FilePath];
    DDXMLDocument *_OfflineConfDocument = [[DDXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    NSArray *subject = [_OfflineConfDocument nodesForXPath:@"//XML/OfflineConf" error:nil];
    for (DDXMLElement *obj in subject) 
    {
        NSArray *array = [obj elementsForName:@"NetConnect"];
        for (DDXMLElement *obj in array) {
            DDXMLElement *PriorityLoadLocalData = [obj elementForName:@"IsPriorityLoadLocalData"];
            PriorityLoadLocalData.stringValue = [NSString stringWithFormat:@"%d", [[_FirstSectionSwitchArray objectAtIndex:0] boolValue]];
            DDXMLElement *UpdateLoadLocalData = [obj elementForName:@"IsUpdateLoadLocalData"];
            UpdateLoadLocalData.stringValue = [NSString stringWithFormat:@"%d", [[_FirstSectionSwitchArray objectAtIndex:1] boolValue]];
            DDXMLElement *SaveOnlineData = [obj elementForName:@"IsSaveOnlineData"];
            SaveOnlineData.stringValue = [NSString stringWithFormat:@"%d", [[_FirstSectionSwitchArray objectAtIndex:2] boolValue]];
        }
        DDXMLElement *NetDisConnect = [obj elementForName:@"NetDisConnect"];
        DDXMLElement *LoadLocalData = [NetDisConnect elementForName:@"IsLoadLocalData"];
        LoadLocalData.stringValue = [NSString stringWithFormat:@"%d", [[_SecondSectionSwitchArray objectAtIndex:0] boolValue]];
    }
    
    NSData *modifiedData = [_OfflineConfDocument XMLData];
    [modifiedData writeToFile:_FilePath atomically:NO];  
    [_OfflineConfDocument release];
    
    return;
}

-(void)viewDidDisappear:(BOOL)animated
{
    return;
}

#pragma mark -
#pragma mark UITableViewDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    BOOL FirstSwitchValue = [[_FirstSectionSwitchArray objectAtIndex:0] boolValue];
    if (0 == section) {
        if (FirstSwitchValue) {
            return _FirstSectionOptionArray.count - 1;
        }else {
            return _FirstSectionOptionArray.count;
        }
    }

    if (2 == section) {
        return _ThirdSectionOptionArray.count;
    }
    
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section < 2) 
    {
        static NSString *CellIdentifier = @"CellIDFirst";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) 
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryNone;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(190, 10, 45, 30)];
            switchView.tag = 100;
            switchView.on = YES;
            [switchView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
            [cell.contentView addSubview:switchView];
            [switchView release];
        }
    }else 
    {
        static NSString *CellIdentifier = @"CellIDSecond";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            if (indexPath.row == 1 && bIsUpdateLocalData == YES) {
                UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(10, 30, 240, 0)];
                progressView.tag = 101;
                [cell.contentView addSubview:progressView];
                [progressView release];                
                UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                [cancelBtn setImage:[UIImage imageNamed:@"ImageViewClose.png"] forState:UIControlStateNormal];
                [cancelBtn addTarget:self action:@selector(cancelUpdate:) forControlEvents:UIControlEventTouchUpInside];
                cancelBtn.frame = CGRectMake(250, 10, 20, 20);
                [cell.contentView addSubview:cancelBtn];
            }
        }
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    UIFont *font = [UIFont systemFontOfSize:14];
    [cell.textLabel setFont:font];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    UISwitch *switchView = (UISwitch *)[cell.contentView viewWithTag:100];
    switchView.onTintColor = [UIColor lightGrayColor];
    if (bIsUpdateLocalData) {
        _UpdateProgressView = (UIProgressView *)[cell.contentView viewWithTag:101];
        _UpdateProgressView.progress = 0;
    }
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    switch (section) {
        case 0:
            switch (row) {
                case 0:
                    cell.textLabel.text = [_FirstSectionOptionArray objectAtIndex:row];
                    switchView.on = [[_FirstSectionSwitchArray objectAtIndex:row] boolValue];
                    break;
                case 1:
                    if ([[_FirstSectionSwitchArray objectAtIndex:row - 1] boolValue] == YES) 
                    {
                        cell.textLabel.text = [_FirstSectionOptionArray objectAtIndex:row + 1];
                        switchView.on = [[_FirstSectionSwitchArray objectAtIndex:row + 1] boolValue];
                    }else{
                        cell.textLabel.text = [_FirstSectionOptionArray objectAtIndex:row];
                        switchView.on = [[_FirstSectionSwitchArray objectAtIndex:row] boolValue];
                    }
                    break;
                case 2:
                    cell.textLabel.text = [_FirstSectionOptionArray objectAtIndex:row];
                    switchView.on = [[_FirstSectionSwitchArray objectAtIndex:row] boolValue];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            cell.textLabel.text = [_SecondSectionOptionArray objectAtIndex:row];
            switchView.on = [[_SecondSectionSwitchArray objectAtIndex:row] boolValue];
            break;
        case 2:
            switch (row) {
                case 0:
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.textLabel.text = [_ThirdSectionOptionArray objectAtIndex:row];
                    break;
                 case 1: 
                    if (bIsUpdateLocalData) {
  cell.accessoryType = UITableViewCellAccessoryNone;
                        cell.textLabel.text = @"正在下载:";
                        
                    }else {
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                        cell.textLabel.text = [_ThirdSectionOptionArray objectAtIndex:row];
                    }
                    break;
                default:
                    break;
            }
            break;
        default:
            break;
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = [_HeaderTitleContentArray objectAtIndex:section];
    return title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 25.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    @try {
        //选中后的反显颜色即刻消失
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        if (section == 2 && row == 0) {
            // 清除本地缓存数据(删除切片目录及数据库)
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];

            // 本地数据库文件
            NSString *MapInfDBPath = [documentsDirectory stringByAppendingPathComponent:@"OfflineTiles.db"];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:MapInfDBPath];
            if (bRet) {
                // 
                NSError *err;
                [fileMgr removeItemAtPath:MapInfDBPath error:&err];
            }
            
            //本地切片目录
            NSString *TilesDir = [documentsDirectory stringByAppendingPathComponent:@"Tiles"];
            bRet = [fileMgr fileExistsAtPath:TilesDir];
            if (bRet) {
                // 
                NSError *err;
                [fileMgr removeItemAtPath:TilesDir error:&err];
            }
            [NodifyDelegate ClearOfflinCacheMapDataCompleted:@"清除离线地图数据完成"];
        }
        else if (section == 2 && row == 1) {
            if (bIsUpdateLocalData == NO) {
                ProgressValue = 0;
                _UpdateProgressView = 0;
                _UpdateLocalDataThread = [[NSThread alloc] initWithTarget:self selector:@selector(UpdateLocalDataThreadMain:) object:nil];
                [_UpdateLocalDataThread start];
                bIsUpdateLocalData = YES;
                
                [_OfflineConfTableView beginUpdates];
                [_OfflineConfTableView reloadRowsAtIndexPaths:_ReloadIndexPathsArray withRowAnimation:UITableViewRowAnimationNone];  
                [_OfflineConfTableView endUpdates];
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

#pragma mark - NSThread
//cancelBtn Responder
- (void)cancelUpdate:(id)sender
{
    ProgressValue = 0;
    bIsUpdateLocalData = NO;
    [_UpdateLocalDataThread cancel];
    [_OfflineConfTableView reloadRowsAtIndexPaths:_ReloadIndexPathsArray withRowAnimation:UITableViewRowAnimationNone];
}

//子线程
- (void)UpdateLocalDataThreadMain:(id)sender
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    DataMan.LocalDelegate = self;
    //NSString *layerUrl = @"http://gis.huizhou.gov.cn:8399/arcgis/rest/services/basemp114/GGBFWDT114/MapServer";
    NSString *layerUrl = [DataMan CurrentBaseMapUrl]; 
    if (layerUrl == nil) {
        return;
    }
    // @"http://172.16.200.5:8399/arcgis/rest/services/gt570basemap/GGGLMAP/MapServer";
    //NSURL *MapUrl = [NSURL URLWithString:layerUrl];
    NSURL *MapUrl = [[NSURL alloc] initWithString:[layerUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [DataMan DownloadAllTilesByMapUrl:MapUrl];
    while (1) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        if ([[NSThread currentThread] isCancelled]) {
            [NSThread exit];
            [_UpdateLocalDataThread release];
        }
        if (ProgressValue == 1) {
            ProgressValue = 0;
            bIsUpdateLocalData = NO;
            [_OfflineConfTableView beginUpdates];  
            [_OfflineConfTableView reloadRowsAtIndexPaths:_ReloadIndexPathsArray withRowAnimation:UITableViewRowAnimationNone];  
            [_OfflineConfTableView endUpdates];
            [NSThread exit];
            [_UpdateLocalDataThread release];
        }
        [NSThread sleepForTimeInterval:0.5f]; 
    }

    [pool release];
}

//在主线程中进行的操作函数
- (void)updateProgressView:(id)sender
{
    NSNumber * num = (NSNumber *)sender;
    float value = [num floatValue]; 
    _UpdateProgressView.progress = value;
}

#pragma mark Custom Methods
//解析数据
- (void)parsedOfflineConfFromData:(NSData *)data
{
    @try {
        DDXMLDocument *_LayerDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
        NSArray *OfflineConf = [_LayerDocument nodesForXPath:@"//XML/OfflineConf" error:nil];
        for (DDXMLElement *obj in OfflineConf) 
        {
            NSArray *array = [obj elementsForName:@"NetConnect"];
            for (DDXMLElement *obj in array) 
            {
                DDXMLElement *PriorityLoadLocalData = [obj elementForName:@"IsPriorityLoadLocalData"];
                [_FirstSectionSwitchArray addObject:PriorityLoadLocalData.stringValue];
                DDXMLElement *UpdateLoadLocalData = [obj elementForName:@"IsUpdateLoadLocalData"];
                [_FirstSectionSwitchArray addObject:UpdateLoadLocalData.stringValue];
                DDXMLElement *SaveOnlineData = [obj elementForName:@"IsSaveOnlineData"];
                [_FirstSectionSwitchArray addObject:SaveOnlineData.stringValue];
            }
            DDXMLElement *NetDisConnect = [obj elementForName:@"NetDisConnect"];
            DDXMLElement *LoadLocalData = [NetDisConnect elementForName:@"IsLoadLocalData"];
            [_SecondSectionSwitchArray addObject:LoadLocalData.stringValue];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

//UISwitchResponder
- (void)valueChanged:(id)sender
{
    @try {
        UISwitch *switchView = (UISwitch *)sender;
        //二级父视图
        UITableViewCell *curCell = (UITableViewCell *)switchView.superview.superview;
        NSInteger row = [_OfflineConfTableView indexPathForCell:curCell].row;
        NSInteger section = [_OfflineConfTableView indexPathForCell:curCell].section;
        BOOL curSwitchValue = switchView.on;
        switch (section) {
            case 0:
                switch (row) {
                    case 0:
                        [_FirstSectionSwitchArray replaceObjectAtIndex:row withObject:[NSString stringWithFormat:@"%d", curSwitchValue]];
                        NSArray *IndexPaths = [NSArray arrayWithObjects: [NSIndexPath indexPathForRow:row + 1 inSection:section], nil];
                        if (curSwitchValue) 
                        {
                            [_OfflineConfTableView beginUpdates];  
                            [_OfflineConfTableView deleteRowsAtIndexPaths:IndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];  
                            [_OfflineConfTableView endUpdates]; 
                        }else{
                            [_OfflineConfTableView beginUpdates]; 
                            [_OfflineConfTableView insertRowsAtIndexPaths:IndexPaths withRowAnimation:UITableViewRowAnimationBottom];  
                            [_OfflineConfTableView endUpdates]; 
                        }
                        break;
                    case 1:
                        if ([[_FirstSectionSwitchArray objectAtIndex:row - 1] boolValue] == YES) 
                        {
                            [_FirstSectionSwitchArray replaceObjectAtIndex:row + 1 withObject:[NSString stringWithFormat:@"%d", curSwitchValue]];
                        }else {
                            [_FirstSectionSwitchArray replaceObjectAtIndex:row withObject:[NSString stringWithFormat:@"%d", curSwitchValue]];
                        }
                        break;
                    case 2:
                        [_FirstSectionSwitchArray replaceObjectAtIndex:row withObject:[NSString stringWithFormat:@"%d", curSwitchValue]];
                        break;
                    default:
                        break;
                }
                break;
            case 1:
                [_SecondSectionSwitchArray replaceObjectAtIndex:row withObject:[NSString stringWithFormat:@"%d", curSwitchValue]];
                break;
            default:
                break;
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (UIInterfaceOrientationLandscapeLeft == interfaceOrientation);
	//return YES;
}

#pragma mark - DBLocalTileDataDownloadDelegate  
- (void)DidDownloadProgress:(float)value
{
    
    [valueCondition lock];
    ProgressValue = value;
    [valueCondition unlock];
    
    NSNumber *param = [NSNumber numberWithFloat:value];
    [self performSelectorOnMainThread:@selector(updateProgressView:) withObject:param waitUntilDone:NO];
    
    return;
}

@end

