//
//  DBAllConfViewController.m
//  HZDuban
//
//  Created by mac on 12-7-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBAllConfViewController.h"
#import "DBLocalTileDataManager.h"
#import "DBWebServiceConfTableViewController.h"
#import "Logger.h"

@interface DBAllConfViewController ()

@end

@implementation DBAllConfViewController
@synthesize delegate;
@synthesize ConfOptionArray = _ConfOptionArray;
@synthesize BaseMapLayersDic = _BaseMapLayersDic;
//@synthesize DataMapLayerNameArray = _DataMapLayerNameArray;
//@synthesize DataMapLayerUrlArray = _DataMapLayerUrlArray;
@synthesize FirstTypeIndexArray = _FirstTypeIndexArray, FirstTypeLayerNameArray = _FirstTypeLayerNameArray;
@synthesize SecondTypeIndexArray = _SecondTypeIndexArray, SecondTypeLayerNameArray = _SecondTypeLayerNameArray;
@synthesize MapTypeArray = _MapTypeArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// 确定按钮按下，保存配置数据退出
-(void)okeyButtonPressed
{
    @try {
        for (NSNumber *number in _MapTypeArray) {
            NSInteger nMapType = number.intValue;
            if (nMapType == 0) {
                // 底图图层
                [delegate ReloadMapViewWithNameArray:_FirstTypeLayerNameArray andWithIndexArray:_FirstTypeIndexArray andWithType:nMapType];
            }
            else {
                // 
                [delegate ReloadMapViewWithNameArray:nil andWithIndexArray:nil andWithType:nMapType];
            }
            
        }
        
        [delegate AllConfPopoverDone];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }

}

// 取消按钮按下，不保存配置数据退出
-(void)CancelButtonPressed
{
    [delegate AllConfPopoverDone];
}

#pragma mark - MapLayerConfViewDelegate
- (void)ConfMapViewWithNameArray:(NSArray *)layerName andWithIndexArray:(NSArray *)index andWithType:(NSInteger)type
{
    NSNumber *number = [NSNumber numberWithInt:type];
    [_MapTypeArray addObject:number];
    if (type == 0) 
    {
        // 底图配置
        self.FirstTypeLayerNameArray = layerName;
        self.FirstTypeIndexArray = index;
    }else if(type == 1){
        self.SecondTypeLayerNameArray = layerName;
        self.SecondTypeIndexArray = index;
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.MapTypeArray = [NSMutableArray arrayWithCapacity:0];
    UIBarButtonItem *okButton = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(okeyButtonPressed)];
    [self.navigationItem setLeftBarButtonItem:okButton animated:NO];
    [okButton release];
    
    UIBarButtonItem *CancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(CancelButtonPressed)];
    [self.navigationItem setRightBarButtonItem:CancelButton animated:NO];
    [CancelButton release];
    
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    CGFloat fWidth = 300.0;
    CGFloat fHeight = 395.0;
    _AllConfTableView = [[UITableView alloc]initWithFrame:CGRectMake(xPos, yPos, fWidth, fHeight) style:UITableViewStylePlain];
    _AllConfTableView.rowHeight = 45.0;
    _AllConfTableView.delegate = self;
    _AllConfTableView.dataSource = self;
    [self.view addSubview:_AllConfTableView];
    [_AllConfTableView release];
    self.title = @"系统配置";
    //self.ConfOptionArray = [NSArray arrayWithObjects:@"底图配置", @"业务图层配置", @"Web服务配置", @"离线地图配置", @"清除本地配置数据", nil];
     self.ConfOptionArray = [NSArray arrayWithObjects:@"底图配置", @"Web服务配置", @"离线地图配置", @"清除本地数据", nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
    self.ConfOptionArray = nil;
//    self.DataMapLayerNameArray = nil;
//    self.DataMapLayerUrlArray = nil;
    self.BaseMapLayersDic = nil;
    self.FirstTypeLayerNameArray = nil;
    self.FirstTypeIndexArray = nil;
    self.SecondTypeLayerNameArray = nil;
    self.SecondTypeIndexArray = nil;
    self.MapTypeArray = nil;
    
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    CGSize size = CGSizeMake(300, 355);
    [self setContentSizeForViewInPopover:size];
}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

#pragma mark -UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _ConfOptionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        static NSString *cellID = @"cellID";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }
        if (indexPath.row == 3) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }else {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        UIFont *font = [UIFont systemFontOfSize:15];
        [cell.textLabel setFont:font];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.text = [_ConfOptionArray objectAtIndex:indexPath.row];
//        if (indexPath.row == 1) {
//            cell.userInteractionEnabled = NO;
//            return cell;
//        }
//        cell.userInteractionEnabled = YES;
        
        return cell;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    @try {
        NSInteger row = indexPath.row;
        if (row == 0)
        {   
            //底图配置
            DBBaseMapConfViewController *BaseMapConfViewContrl = [[DBBaseMapConfViewController alloc] initWithStyle:UITableViewStyleGrouped];
            BaseMapConfViewContrl.Delegate = self;
            [BaseMapConfViewContrl setBaseMapLayersDic:_BaseMapLayersDic];
            [BaseMapConfViewContrl setOrgBaseMapLayersDic:[_BaseMapLayersDic copy]];
            BaseMapConfViewContrl.title = @"底图设置";
            CGSize size = CGSizeMake(300, 350);
            [BaseMapConfViewContrl setContentSizeForViewInPopover:size];
            [self.navigationController pushViewController:BaseMapConfViewContrl animated:YES];
            [BaseMapConfViewContrl release];
        }
        else if(row == 1)
        {
            NSNumber *number = [NSNumber numberWithInt:row];
            [_MapTypeArray addObject:number];
            
            // Web服务配置
            DBWebServiceConfTableViewController *DBWebServiceConfTableViewContrl = [[DBWebServiceConfTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
            DBWebServiceConfTableViewContrl.title = @"Web服务设置";
            CGSize size = CGSizeMake(300, 350);
            [DBWebServiceConfTableViewContrl setContentSizeForViewInPopover:size];
            [self.navigationController pushViewController:DBWebServiceConfTableViewContrl animated:YES];
            [DBWebServiceConfTableViewContrl release];
        }
        else if(row == 2){
            // 离线数据配置
            DBOfflineConfViewController *OfflineConfViewContrl= [[DBOfflineConfViewController alloc] init];
            OfflineConfViewContrl.NodifyDelegate = self;
            CGSize size = CGSizeMake(300, 350);
            [OfflineConfViewContrl setContentSizeForViewInPopover:size];
            [self.navigationController pushViewController:OfflineConfViewContrl animated:YES];
            [OfflineConfViewContrl release];
        }
        else  if(row == 3){
            // 清除本地配置数据-->删除所有本地配置文件，下次启动系统重新从服务器下载.
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            //立刻取消选中状态
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            //清除本地数据
            DBLocalTileDataManager *LocalTileDataManager = [DBLocalTileDataManager instance];
//            LocalTileDataManager.GISWebServiceUrl = nil;
//            LocalTileDataManager.TopicWebServiceUrl = nil;
//            LocalTileDataManager.AnnexDownloadServiceUrl = nil;
            LocalTileDataManager.RoadDataMapLayerName = nil;
            LocalTileDataManager.RoadDataMapLayerUrl = nil;
            [LocalTileDataManager CleanLocalData];
            
            
            // 本地配置信息文件
            NSString *ConfigurePath = [documentsDirectory stringByAppendingPathComponent:@"DBConfigure.xml"];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:ConfigurePath];
            if (bRet) {
                // 
                NSError *err;
                [fileMgr removeItemAtPath:ConfigurePath error:&err];
            }
            
            
            //专题图层及配置信息文件
            //NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSString *MapLayerDataPath = [documentsDirectory stringByAppendingPathComponent:@"DBMapLayerData.xml"];
            bRet = [fileMgr fileExistsAtPath:MapLayerDataPath];
            if (bRet) {
                // 
                NSError *err;
                [fileMgr removeItemAtPath:MapLayerDataPath error:&err];
            }
            
            // add 2015.11.22 begin
            // 清除议题附件文件
            NSString *annexFileDir = [documentsDirectory stringByAppendingPathComponent:@"AnnexFiles"];
            bRet = [fileMgr fileExistsAtPath:annexFileDir];
            if (bRet)
            {
                // 清除
                NSError *err;
                [fileMgr removeItemAtPath:annexFileDir error:&err];
                
            }
            // end
            /*
            //标注信息文件
            NSString *MarkInfoPath = [documentsDirectory stringByAppendingPathComponent:@"DBMarkInfo.xml"];
            bRet = [fileMgr fileExistsAtPath:MarkInfoPath];
            if (bRet) {
                // 
                NSError *err;
                [fileMgr removeItemAtPath:MarkInfoPath error:&err];
            }
            */
            
//            // 清除所有议题附件文件
//            NSString *TilesDir = [documentsDirectory stringByAppendingPathComponent:@"AnnexFiles"];
//            bRet = [fileMgr fileExistsAtPath:TilesDir];
//            if (bRet) {
//                // 
//                NSError *err;
//                [fileMgr removeItemAtPath:TilesDir error:&err];
//            }
            
            // 显示清除完成view
            [delegate ClearCacheCompleted:@"清除完成"];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

// 清除缓存地图数据完成
-(void)ClearOfflinCacheMapDataCompleted:(NSString*)TipMsg
{
    // 显示清除完成view
    [delegate ClearCacheCompleted:TipMsg];
    return;
}
@end
