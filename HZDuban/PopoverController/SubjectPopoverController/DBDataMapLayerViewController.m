//
//  DBDataMapLayerViewController.m
//  HZDuban
//
//  Created by  on 12-9-18.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBDataMapLayerViewController.h"
#import "Logger.h"
#import "DBMapLayerDataItem.h"

@interface DBDataMapLayerViewController ()

@end

@implementation DBDataMapLayerViewController
@synthesize DataMapLayerSwitchArray = _DataMapLayerSwitchArray;
@synthesize FilePath = _FilePath;
@synthesize SwitchDelgate = _SwitchDelgate;
@synthesize SingleManager;

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    //init SingleManager
    SingleManager = [DBLocalTileDataManager instance];
    SingleManager.MapLayerDelegate = self;
    self.DataMapLayerSwitchArray = [NSMutableArray arrayWithCapacity:0];
    self.tableView = [[UITableView alloc] init];
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.showsHorizontalScrollIndicator = NO;
    //initContentSizeForViewInPopoverAndTableViewFrame
    [self initContentSizeForViewInPopoverAndTableViewFrame];
    
    self.tableView.rowHeight = 40;
    //self.tableView.backgroundColor = [UIColor clearColor];
    //self.tableView.delegate = self;
    //self.tableView.dataSource = self;
    
    //[self.view addSubview:self.tableView];
    //[_DataMapLayerTableView release];
    
    //init refreshHeaderView
    
    // del by niurg 2015.9
//    if (_refreshHeaderView == nil) {
//		
//		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
//        
//		view.delegate = self;
//		[self.tableView addSubview:view];
//		_refreshHeaderView = view;
//		[view release];
//		
//	}
//	//  update the last update date
//	[_refreshHeaderView refreshLastUpdatedDate];
    // end
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    self.DataMapLayerSwitchArray = nil;
    self.FilePath = nil;
    //self.SingleManager = nil;
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}
#pragma mark 自定义方法
- (void)initContentSizeForViewInPopoverAndTableViewFrame
{
    int nCnt = [[SingleManager MapLayerDataArray] count];
    //tableVeiw and popoverView height
    CGFloat fHeight = 0.0f;
    if (nCnt == 0) {
        fHeight = 37;
    }else if(nCnt < 10){
        fHeight = 37 * nCnt;
    }else if(nCnt >= 10){
        fHeight = 370.0;
    }
    
    [self.DataMapLayerSwitchArray removeAllObjects];
    for (int i = 0; i < SingleManager.MapLayerDataArray.count; i++) {
        [self.DataMapLayerSwitchArray addObject:[[SingleManager.MapLayerDataArray objectAtIndex:i] DataLayerDisplay]];
    }
    self.contentSizeForViewInPopover = CGSizeMake(270, fHeight);
    //self.tableView.frame = CGRectMake(0, 0, 270, fHeight);
}
#pragma mark - DBDataMapLayerViewReloadDelegate
- (void)DataMapLayerViewReload
{
    //resize ContentSizeForViewInPopoverAndTableViewFrame
    [self initContentSizeForViewInPopoverAndTableViewFrame];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nCnt = SingleManager.MapLayerDataArray.count;
    if (nCnt == 0) {
        nCnt = 1;
    }
    
    return nCnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        static NSString *MyIdentifier = @"MyIdentifier";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil)
        {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
            
            CGFloat fSwitchWidth = 80;
            CGFloat fNameWidth = [tableView frame].size.width - fSwitchWidth - 5 * 2;
            UILabel *DataMapName = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, fNameWidth, 27)];
            DataMapName.tag = 100;
            DataMapName.font = [UIFont systemFontOfSize:15];
            [cell.contentView addSubview:DataMapName];
            [DataMapName release];
            
//            CGFloat fXOffset = [tableView frame].size.width - fSwitchWidth - 5;
            UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 5, 0, 0)];
            CGRect frame = switchView.frame;
            frame.origin.x = [tableView frame].size.width - switchView.frame.size.width - 5;
            [switchView setFrame:frame];
            
            switchView.tag = 101;
            switchView.hidden = YES;
            switchView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
            [switchView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];            
            [cell.contentView addSubview:switchView];
            [switchView release];
            
            // 查询控制按钮
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(235, 5, 28, 30);
            [button addTarget:self action:@selector(LayerRadioBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = 102;
            [cell.contentView addSubview:button];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        // 设置背景透明
        [cell setBackgroundColor:[UIColor clearColor]];
        UILabel *DataMapName = (UILabel *)[cell.contentView viewWithTag:100];
        UISwitch *switchView = (UISwitch *)[cell.contentView viewWithTag:101];
        UIButton *RadioButton = (UIButton *)[cell.contentView viewWithTag:102];
        if (SingleManager.MapLayerDataArray.count == 0) {
            switchView.hidden = YES;
            RadioButton.hidden = YES;
            DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
            int nLoadFlg = [DataMan nMapLayerLoadFlg];
            if (nLoadFlg == 1) {
                DataMapName.text = @"正在加载...";
            }
            else {
                DataMapName.text = @"暂无数据";
            }
            cell.userInteractionEnabled = NO;
        }else {
            cell.userInteractionEnabled = YES;
            switchView.hidden = NO;
            RadioButton.hidden = NO;
            DataMapName.text = [[SingleManager.MapLayerDataArray objectAtIndex:indexPath.row] Name];
            switchView.on = [[_DataMapLayerSwitchArray objectAtIndex:indexPath.row] boolValue];
        }
        
        // 设置Radio按钮状态
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        if ([DataMan nCurrentSelRadioBtnIndex] == indexPath.row) {
            [RadioButton setImage:[UIImage imageNamed:@"RadioBtn_Sel.png"] forState:UIControlStateNormal];
        }
        else {
            [RadioButton setImage:[UIImage imageNamed:@"RadioBtn_NoSel.png"] forState:UIControlStateNormal];
        }
        [RadioButton setHidden:YES];
        return cell;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - UIScrollViewDeledate Method

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{	
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
	
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
	
	//  should be calling your tableviews data source model to reload
	//  put here just for demo
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    BOOL bNetConn = [DataMan InternetConnectionTest];
    if (!bNetConn) {
        [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:@"无法完成刷新"];
        _reloading = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
        return;
    }else {
        _reloading = YES;
        [self performSelector:@selector(ReloadBeforeRefreshMapLayerData) withObject:nil afterDelay:0];
        [DataMan DownLoadMapLayerData:@""];
    }
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
}

-(void)ReloadBeforeRefreshMapLayerData
{
     // add by niurg 2015.9
    // 清除所有图层相关数据
//    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
//    [DataMan CleanAllDataMapCacheData];
//    [self.tableView reloadData];
    // end
    
    
}

- (void)doneLoadingTableViewData{
    
	//  model should call this when its done loading
	_reloading = NO;
    // add by niurg 2015.9
//    [self.tableView reloadData];
    // end
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; // should return date data source was last changed	
}


//Custom UISwitch responder
- (void)valueChanged:(id)sender
{
    @try {
        UISwitch *switchView = (UISwitch *)sender;
        UITableViewCell *curCell = (UITableViewCell *)switchView.superview.superview;
        NSInteger row = [self.tableView indexPathForCell:curCell].row;
       
        //存放修改后的value值
        [_DataMapLayerSwitchArray replaceObjectAtIndex:row withObject:[NSString stringWithFormat:@"%d", switchView.on]];
        //从沙盒中读取数据
        NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DBMapLayerData.xml"];
        NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
        DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
        NSArray *MapLayer = [doc nodesForXPath:@"//ThemeManage/ThemeManageJSONArray/ThemeManageObject" error:nil];
        
        //DDXMLElement *obj = [MapLayer objectAtIndex:row];
        NSString *layerId = [[SingleManager.MapLayerDataArray objectAtIndex:row] Id];
        BOOL bFlg = NO;
        for (DDXMLElement *obj in MapLayer) {
            DDXMLElement *value = [obj elementForName:@"THEMEID"];
            if([layerId isEqualToString: [value stringValue]])
            {
                DDXMLElement *value = [obj elementForName:@"DataLayerDisplay"];
                //如果为空的话，说明是第一次点击，向XML文件中做addChild:操作，否则去修改value的值。
                if (value == nil) {
                    DDXMLNode *node = [DDXMLNode elementWithName:@"DataLayerDisplay" stringValue:[NSString stringWithFormat:@"%d", switchView.on]];
                    [obj addChild:node];
                }else {
                    value.stringValue = [NSString stringWithFormat:@"%d", switchView.on];
                }
                [_SwitchDelgate MapLayerSwitch:row SwitchValue:switchView.on];
                NSData *data2 = [doc XMLData];
                [data2 writeToFile:filePath atomically:NO];
                [doc release];
                bFlg = YES;
                break;
            }
        }
        if (!bFlg) {
            // error
        }

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return;
}

-(void)LayerRadioBtnClicked:(id)sender
{
    UIButton *button = (UIButton*)sender;
    UISwitch *switchView = (UISwitch *)sender;
    UITableViewCell *curCell = (UITableViewCell *)switchView.superview.superview;
    
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSInteger row = [self.tableView indexPathForCell:curCell].row;
    NSInteger nPreRow = [DataMan nCurrentSelRadioBtnIndex];
    //从沙盒中读取数据
    NSString *documentsDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"DBMapLayerData.xml"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:filePath];
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    NSArray *MapLayer = [doc nodesForXPath:@"//ThemeManage/ThemeManageJSONArray" error:nil];
    //取出DDXMLElement，因为只有一项所以index为0.
    DDXMLElement *obj = [MapLayer objectAtIndex:0];
    DDXMLElement *value = [obj elementForName:@"DataLayerSelected"];
    if (nPreRow == row) {
        // 取消操作
        [button setImage:[UIImage imageNamed:@"RadioBtn_NoSel.png"] forState:UIControlStateNormal];
        [DataMan setNCurrentSelRadioBtnIndex:-1];
        
        value.stringValue = [NSString stringWithFormat:@"%d", -1];
    }
    else {
        // 选中操作
        // (1.)首先取消前一选中btn
        if (nPreRow != -1) 
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nPreRow inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            UIButton *PreRadioBtn = (UIButton *)[cell.contentView viewWithTag:102];
            [PreRadioBtn setImage:[UIImage imageNamed:@"RadioBtn_NoSel.png"] forState:UIControlStateNormal];
            value.stringValue = [NSString stringWithFormat:@"%d", -1];
        }
        
        // (2.)设置当前为选中
        [button setImage:[UIImage imageNamed:@"RadioBtn_Sel.png"] forState:UIControlStateNormal];
        [DataMan setNCurrentSelRadioBtnIndex:row];
        if (value == nil) {
            DDXMLNode *node = [DDXMLNode elementWithName:@"DataLayerSelected" stringValue:[NSString stringWithFormat:@"%d", row]];
            [obj addChild:node];
        }else {
            value.stringValue = [NSString stringWithFormat:@"%d", row];
        } 
    }
    NSData *data2 = [doc XMLData];
    [data2 writeToFile:filePath atomically:NO];
    [doc release];
    return;
}
@end
