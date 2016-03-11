//
//  DBMeetingViewController.m
//  HZDuban
//
//  Created by mac on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBMeetingViewController.h"
#import "DBViewController.h"
#import "Logger.h"
#import "DBMeetingDataItem.h"
#import "DB2GoverDeciServerService.h"
#import "EncryptUtil.h"

@interface DBMeetingViewController ()

@end

@implementation DBMeetingViewController
@synthesize Subject2ViewPopover = _Subject2ViewPopover;
@synthesize mainView;
@synthesize superViewCtrl = _superViewCtrl;
//@synthesize MeetingResultArray = _MeetingResultArray;

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

//Custom
-(void)SetSubPopoverHiden
{
    if ([_Subject2ViewPopover isPopoverVisible]) {
        [_Subject2ViewPopover dismissPopoverAnimated:NO];
        _Subject2ViewPopover = nil;
        SubContentView = nil;
    }
}

- (UIViewController*)GetViewController 
{
    for (UIView* next = [mainView superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    //MeetingIdQueue = [[DBQueue alloc] init];
    /*
    //创建PopoverController
    SubContentView = [[DBSubjectListController alloc] init];
    UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:SubContentView];
    [SubContentView release];
    SubContentView.delegate = (DBViewController*)_superViewCtrl;
    
	// Setup the popover for use in the detail view.
	_Subject2ViewPopover = [[UIPopoverController alloc] initWithContentViewController:nav1];
    [nav1 release];
	_Subject2ViewPopover.delegate = self;
    NSArray *InteractionViews = [NSArray arrayWithObjects:self.view, [self mainView],  nil];
    [_Subject2ViewPopover setPassthroughViews:InteractionViews];
    */
//    //Seraching Meeting
//    _searchBar =[[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 300, 44)] autorelease];
//    _searchBar.delegate = self;
//    self.navigationItem.titleView = _searchBar;

    self.tableView.showsVerticalScrollIndicator = YES;    
    DBLocalTileDataManager *LocalTileDataManager = [DBLocalTileDataManager instance];
    LocalTileDataManager.MeetingDelegate = self;
//    self.MeetingResultArray = [NSMutableArray arrayWithCapacity:0];
    //init refreshHeaderView
    if (_refreshHeaderView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeaderView = view;
		[view release];
		
	}
	//  update the last update date
	[_refreshHeaderView refreshLastUpdatedDate];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    //MeetingIdQueue = nil;
    self.Subject2ViewPopover = nil;
    self.mainView = nil;
    self.superViewCtrl = nil;
//    self.MeetingResultArray = nil;
    [SubContentView release];
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - DBMeetingViewReloadDelegate
- (void)MeetingViewReload
{
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DBLocalTileDataManager *LocalTileDataManager = [DBLocalTileDataManager instance];
    NSInteger nCount = 0;
//    if (_nDataSourceFlg == 0){
//        nCount = LocalTileDataManager.MeetingList.count;
//    }else{
//        nCount = [_MeetingResultArray count];
//    }
    nCount = LocalTileDataManager.MeetingList.count;
    if (nCount == 0) {
        nCount = 1;
    }
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    if (_MeetingResultArray.count == 0 && _nDataSourceFlg == 1) {
        static NSString *ResultCellID = @"ResultCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ResultCellID];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ResultCellID] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"没有结果";
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [cell.textLabel.font fontWithSize:15];
        return cell;
    }
    */
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        UILabel *Name = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, 300, 36)];
        Name.numberOfLines = 0;
        //Name.shadowColor = [UIColor grayColor];
        Name.lineBreakMode = UILineBreakModeWordWrap;
        //Name.font = [UIFont systemFontOfSize:15];
        Name.font = [UIFont boldSystemFontOfSize:15];
        Name.tag = 101;
        [cell.contentView addSubview:Name];
        [Name release];
        
        UILabel *Address = [[UILabel alloc] initWithFrame:CGRectMake(3, 50, 190, 15)];
        Address.backgroundColor = [UIColor clearColor];
        Address.font = [UIFont systemFontOfSize:13];
        Address.tag = 102;
        [cell.contentView addSubview:Address];
        [Address release];
        
//        UILabel *OwnerUnit = [[UILabel alloc] initWithFrame:CGRectMake(120, 42, 170, 15)];
//        OwnerUnit.textAlignment = UITextAlignmentRight;
//        OwnerUnit.backgroundColor = [UIColor clearColor];
//        OwnerUnit.font = [UIFont systemFontOfSize:13];
//        OwnerUnit.tag = 103;
//        [cell.contentView addSubview:OwnerUnit];
//        [OwnerUnit release];
        
        UILabel *Time = [[UILabel alloc] initWithFrame:CGRectMake(185, 50, 126, 15)];
        Time.textAlignment = UITextAlignmentRight;
        Time.backgroundColor = [UIColor clearColor];
        Time.font = [UIFont systemFontOfSize:13];
        Time.tag = 104;
        [cell.contentView addSubview:Time];
        [Time release];
	}
    UILabel *MeetingName = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *MeetingAddress = (UILabel *)[cell.contentView viewWithTag:102];
    //UILabel *MeetingOwnerUnit = (UILabel *)[cell.contentView viewWithTag:103];
    UILabel *MeetingTime = (UILabel *)[cell.contentView viewWithTag:104];
    NSArray *DataArray = nil;
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
//    if (_nDataSourceFlg == 0) {
//        DataArray = DataMan.MeetingList;
//        if (DataArray.count == 0) 
//        {
//            MeetingName.shadowColor = [UIColor clearColor];
//            int nLoadFlg = [DataMan nMeetingLoadFlg];
//            if (nLoadFlg == 1) {
//                MeetingName.text = @"正在加载...";
//            }
//            else {
//                MeetingName.text = @"暂无数据";
//            }
//            cell.userInteractionEnabled = NO;
//            cell.accessoryType = UITableViewCellAccessoryNone;
//            
//            return cell;
//        }
//    }else {
//        DataArray = _MeetingResultArray;
//    }
    DataArray = DataMan.MeetingList;
    if (DataArray.count == 0) 
    {
        MeetingName.shadowColor = [UIColor clearColor];
        int nLoadFlg = [DataMan nMeetingLoadFlg];
        if (nLoadFlg == 1) {
            MeetingName.text = @"正在加载...";
        }
        else {
            MeetingName.text = @"暂无数据";
        }
        [MeetingAddress setText:nil];
        [MeetingTime setText:nil];
        cell.userInteractionEnabled = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
    cell.userInteractionEnabled = YES;

    int nRow = indexPath.row;
    [MeetingName setText:@""];
    
    // 修改时间顺序
    //NSString *Name = [[DataArray objectAtIndex:nRow] MeetingName];
    nRow = [DataArray count] - nRow - 1;
    NSString *Name = [[DataArray objectAtIndex:nRow] MeetingName];
    //
    
    if ([Name length] > 0) 
    {
        if (![Name isEqualToString:@"Empty"]) {
            [MeetingName setText:Name];
        }
    }
    
    [MeetingAddress setText:@""];
    NSString *addres = [NSString stringWithFormat:@"地址:%@", [[DataArray objectAtIndex:nRow] Address]];
    if ([addres length] > 0) 
    {
        if (![addres isEqualToString:@"Empty"]) {
            [MeetingAddress setText:addres];
        }
    }
    
    //MeetingOwnerUnit.text = [[DataArray objectAtIndex:indexPath.row] OwnerUnit];
    
    [MeetingTime setText:@""];
    NSString *startTime = [[DataArray objectAtIndex:nRow] StartTime];
    if ([startTime length] > 0) 
    {
        if (![startTime isEqualToString:@"Empty"]) {
            [MeetingTime setText:startTime];
        }
    }
    
    return cell;
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
        [SubContentView HideLoadingView:string];
        //DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        //[DataMan CreateFailedAlertViewWithFailedInfo:@"下载错误!" andWithMessage:string];
        [UIApplication showNetworkActivityIndicator:NO];
        [_Subject2ViewPopover dismissPopoverAnimated:NO];
        _Subject2ViewPopover = nil;
        SubContentView = nil;
		return;
	}
    
	// Handle faults
	if([value isKindOfClass:[SoapFault class]]) {
		//NSLog(@"%@", value);
        SoapFault *soapFault = (SoapFault *)value;
        NSString *string = [soapFault description];
        [SubContentView HideLoadingView:string];
        //DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        //[DataMan CreateFailedAlertViewWithFailedInfo:@"下载失败!" andWithMessage:string];
        [UIApplication showNetworkActivityIndicator:NO];
        [_Subject2ViewPopover dismissPopoverAnimated:NO];
        _Subject2ViewPopover = nil;
        SubContentView = nil;
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
    [SubContentView HideLoadingView:@"议题数据下载完成"];
    // 重新加载 议题数据
    //数组里存放的是所有议题信息
    NSArray *DataArray = [[DataMan.TopicsOfMeeting objectForKey:MeetingID] allValues];
    // 动态设置议题popoverView高度
    NSInteger nCnt = 1;
    if ([DataArray count] > 0) 
    {
        nCnt = [DataArray count];
    }
    [SubContentView setMeettingId:MeetingID];
    if (DataArray.count >= 8 ) {
        [_Subject2ViewPopover setPopoverContentSize:CGSizeMake(450, 360.0) animated:NO];
    }
    else {
        [_Subject2ViewPopover setPopoverContentSize:CGSizeMake(450, 55.0 * nCnt + 37) animated:NO];
    }
    [SubContentView setNLoadFlg:0];
    //[SubContentView reloadContentDataArray:DataArray];
    [SubContentView reloadContentDataArray:MeetingID];

}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    @try 
    {
        // 取得会议ID
        NSString *MeetingID = nil;
        int nRow = indexPath.row;
//        if (_nDataSourceFlg == 0) 
//        {
//            [_searchBar resignFirstResponder];
//            nRow = [DataMan.MeetingList count] - nRow - 1;
//            MeetingID = [[DataMan.MeetingList objectAtIndex:nRow] Id];
//        }
//        else 
//        {
//            nRow = [_MeetingResultArray count] - nRow - 1;      
//            MeetingID = [[_MeetingResultArray objectAtIndex:nRow] Id];
//        }
        //---
        //创建PopoverController
        if ([_Subject2ViewPopover isPopoverVisible]) {
            [_Subject2ViewPopover dismissPopoverAnimated:NO];
        }
        _Subject2ViewPopover = nil;
        SubContentView = nil;
        SubContentView = [[DBSubjectListController alloc] init];
        UINavigationController *nav1 = [[UINavigationController alloc] initWithRootViewController:SubContentView];
        [SubContentView release];
        SubContentView.delegate = (DBViewController*)_superViewCtrl;
        
        // Setup the popover for use in the detail view.
        _Subject2ViewPopover = nil;
        _Subject2ViewPopover = [[UIPopoverController alloc] initWithContentViewController:nav1];
        [nav1 release];
        _Subject2ViewPopover.delegate = self;
        NSArray *InteractionViews = [NSArray arrayWithObjects:self.view, [self mainView],  nil];
        [_Subject2ViewPopover setPassthroughViews:InteractionViews];
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
            [SubContentView DisPlayLoadingView:@"正在下载议题数据,请稍后..."];
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
            [SubContentView waitDownload];
            // 压入下载队列
            //[MeetingIdQueue enqueue:MeetingID];
        }
        
        // 动态设置议题popoverView高度
        NSInteger nCnt = 1;
        if ([DataArray count] > 0) 
        {
            nCnt = [DataArray count];
        }
        [SubContentView setMeettingId:MeetingID];
        if (DataArray.count >= 8 ) {
            //[_Subject2ViewPopover setPopoverContentSize:CGSizeMake(320.0, 320.0) animated:NO];
            [_Subject2ViewPopover setPopoverContentSize:CGSizeMake(450, 360.0) animated:NO];
        }
        else {
            [_Subject2ViewPopover setPopoverContentSize:CGSizeMake(450, 55.0 * nCnt + 37) animated:NO];
       }
        
        // 从本地获取数据
        [SubContentView setNLoadFlg:nFlg];
        //[SubContentView reloadContentDataArray:DataArray];
        [SubContentView reloadContentDataArray:MeetingID];
        
        //显示议题popoverView
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [_Subject2ViewPopover presentPopoverFromRect:cell.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        
        [DataMan setNCurMeetingRowIndex:nRow];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        [DataMan setNCurMeetingRowIndex:-1];
    }
    @finally {

    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    if (DataMan.MeetingList.count == 0) {
        return 39;
    }
    
    return 70;
}
/*
#pragma mark - searchBarDelegate
// 自定义搜索方法
- (void)filterContentForSearchText:(NSString*)searchText
{
    [_MeetingResultArray removeAllObjects];
    if (searchText.length == 0) {
        _nDataSourceFlg = 0;
        [self.tableView reloadData];
        [self SetSubPopoverHiden];
        return;
    }
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
     for (DBMeetingDataItem *meetingData in DataMan.MeetingList) {
        NSComparisonResult result = [meetingData.MeetingName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSRange range = [meetingData.MeetingName rangeOfString:searchText];
        if((result == NSOrderedSame) || (range.location != NSNotFound))
        {
            [_MeetingResultArray addObject:meetingData];
        }
    }
    _nDataSourceFlg = 1;
    [self.tableView reloadData]; 
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterContentForSearchText:searchText];
}
*/
#pragma mark - UIScrollViewDeledate Method

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self SetSubPopoverHiden];
}
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
        [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态!" andWithMessage:@"无法完成刷新"];
        _reloading = NO;
        [_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
        [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
        return;
    }else {
        _reloading = YES;
        [self performSelector:@selector(ReloadBeforeRefreshData) withObject:nil afterDelay:0];
        [DataMan DownLoadMeetingData:@""];
    }
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];
}

-(void)ReloadBeforeRefreshData
{
    // 清除所有议题、会议相关数据
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    [DataMan CleanAllMeetingAboutCacheData];
    [self.tableView reloadData];
}
- (void)doneLoadingTableViewData{
	
	//  model should call this when its done loading
	_reloading = NO;
    //[self.tableView reloadData];
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

@end
