//
//  DBSubjectListController.m
//  HZDuban
//
//  Created by mac on 12-7-9.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBSubjectListController.h"

#import "DBSubProjectDataItem.h"
#import "DBTopicDKDataItem.h"
#import "Logger.h"

@interface DBSubjectListController ()

@end

@implementation DBSubjectListController
//@synthesize ContentDataArray = _ContentDataArray;
@synthesize delegate;
@synthesize SubProjectDataItem;
@synthesize nLoadFlg = _nLoadFlg;
@synthesize MeettingId = _MeettingId;
@synthesize TopicResultArray;

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
        _nLoadFlg = 1;
    }
    return self;
}

//Custom
//- (void)reloadContentDataArray:(NSArray *)array
- (void)reloadContentDataArray:(NSString *)MeetingID
{
    //self.ContentDataArray = array;
    self.MeettingId = MeetingID;
    _nDataSourceFlg = 0;
    _searchBar.text = nil;
    [_ContentTableView reloadData];
    
    // 动态设置议题table view高度
    DBLocalTileDataManager * DataMan = [DBLocalTileDataManager instance];
    NSMutableArray *DataArr = [[DataMan MeettingToTopicIDSeqDic] valueForKey:MeetingID];
    NSInteger nCnt = 1;
    if ([DataArr count] > 0) 
    {
        nCnt = [DataArr count];
    }
    
    if ([DataArr count] >= 8 ) {
//        [_ContentTableView setFrame:CGRectMake(0.0f, 0.0f, 320, 320)];
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.9)
        {
            [_ContentTableView setFrame:CGRectMake(0.0f, 0.0f, 450, 360)];
        }
        else{
            [_ContentTableView setFrame:CGRectMake(0.0f, 0.0f, 450, 320)];
        }
        
    }
    else {
        [_ContentTableView setFrame:CGRectMake(0.0f, 0.0f, 450, 55.0 * nCnt + 40)];
    }
}

#pragma mark - View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _nLoadFlg = 1;
    _nDataSourceFlg = 0;
    if (self.MeettingId.length > 0) {
        // 动态设置议题table view高度
        DBLocalTileDataManager * DataMan = [DBLocalTileDataManager instance];
        NSMutableArray *DataArr = [[DataMan MeettingToTopicIDSeqDic] valueForKey:self.MeettingId];
        NSInteger nCnt = 1;
        if ([DataArr count] > 0)
        {
            nCnt = [DataArr count];
        }
        
        if ([DataArr count] >= 8 ) {
            //        [_ContentTableView setFrame:CGRectMake(0.0f, 0.0f, 320, 320)];
//            [_ContentTableView setFrame:CGRectMake(0.0f, 0.0f, 450, 360)];
            _ContentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 450.0, 360.0) style:UITableViewStylePlain];
        }
        else {
//            [_ContentTableView setFrame:CGRectMake(0.0f, 0.0f, 450, 55.0 * nCnt + 40)];
            _ContentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 450, 55.0 * nCnt + 40) style:UITableViewStylePlain];
        }
    }
    else{
            _ContentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 450.0, 110.0) style:UITableViewStylePlain];
    }

    _ContentTableView.delegate = self;
    _ContentTableView.dataSource = self;
    _ContentTableView.rowHeight = 55;
    [self.view addSubview:_ContentTableView];
    [_ContentTableView release];
    
    DBLocalTileDataManager *dataMan = [DBLocalTileDataManager instance];
    NSString *topicFlg = [dataMan CurSubjectIsHistory];
    if ([topicFlg isEqualToString:@"0"]) {
        // 当前会议
        // refresh subject list add by niurg 2015.9
        _titleContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 450, 44)];
        _refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_refreshBtn setFrame:CGRectMake(0, 0, 45, 44)];
        //    [_refreshBtn setBackgroundColor:[UIColor blackColor]];
        //    [_refreshBtn setBackgroundImage:[UIImage imageNamed:@"ReLoad.png"] forState:UIControlStateNormal];
        [_refreshBtn setTitle:@"刷新" forState:UIControlStateNormal];
        [_refreshBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_refreshBtn addTarget:self action:@selector(refreshBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_titleContainerView addSubview:_refreshBtn];
        //    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_refreshBtn];
        [_refreshBtn release];
        // end
        //Seraching Topic
        _searchBar =[[[UISearchBar alloc] initWithFrame:CGRectMake(60, 0, 390, 44)] autorelease];
        _searchBar.delegate = self;
        //    [_searchBar setBackgroundColor:[UIColor blueColor]];
        [_titleContainerView addSubview:_searchBar];
        self.navigationItem.titleView = _titleContainerView;
    }
    else{
        // 历史会议
        //Seraching Topic
        _searchBar =[[[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 390, 44)] autorelease];
        _searchBar.delegate = self;
        self.navigationItem.titleView = _searchBar;
    }

    self.TopicResultArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
    self.MeettingId = nil;
    //self.ContentDataArray = nil;
    self.SubProjectDataItem = nil;
    self.TopicResultArray = nil;
    
    [super dealloc];
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DBLocalTileDataManager * DataMan = [DBLocalTileDataManager instance];
    NSMutableArray *DataArr = [[DataMan MeettingToTopicIDSeqDic] valueForKey:self.MeettingId];
    int nCount = 0;
    if (_nDataSourceFlg == 0){
        nCount = [DataArr count];
    }else{
        nCount = [TopicResultArray count];
    }
    
    if (nCount == 0) {
        nCount = 1;
    }
    return nCount;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (TopicResultArray.count == 0 && _nDataSourceFlg == 1) {
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
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UILabel *Name = [[UILabel alloc] initWithFrame:CGRectMake(5, 3, 430, 50)];
        Name.font = [UIFont systemFontOfSize:15];
        Name.lineBreakMode = UILineBreakModeWordWrap;
        Name.numberOfLines = 0;
        Name.tag = 100;
        [cell.contentView addSubview:Name];
        [Name release];
      
//        UILabel *OwnerUnit = [[UILabel alloc] initWithFrame:CGRectMake(86, 37, 230, 18)];
//        OwnerUnit.textAlignment = UITextAlignmentRight;
//        OwnerUnit.font = [UIFont systemFontOfSize:13];
//        OwnerUnit.tag = 101;
//        [cell.contentView addSubview:OwnerUnit];
//        [OwnerUnit release];
    }
    if (_nDataSourceFlg == 0)
    {
        DBLocalTileDataManager * DataMan = [DBLocalTileDataManager instance];
        NSMutableArray *DataArr = [[DataMan MeettingToTopicIDSeqDic] valueForKey:self.MeettingId];
        
        if ([DataArr count] > 0) 
        {
            UILabel *SubjectName = (UILabel *)[cell.contentView viewWithTag:100];
            NSString *TopicId = [DataArr objectAtIndex:indexPath.row];
            if ([self.MeettingId length] > 0) 
            {
                DBSubProjectDataItem *Data = [[[DataMan TopicsOfMeeting] objectForKey:self.MeettingId] objectForKey:TopicId];
//                SubjectName.text = [Data TopicName];
                SubjectName.text = [NSString stringWithFormat:@"%d.%@", indexPath.row+1, [Data TopicName]];
            }
            else {
                SubjectName.text = @"无数据";
            }
            //SubjectName.text = [[_ContentDataArray objectAtIndex:indexPath.row] TopicName];
            //        
            //        UILabel *SubjectOwnerUnit = (UILabel *)[cell.contentView viewWithTag:101];
            //        SubjectOwnerUnit.text = [[_ContentDataArray objectAtIndex:indexPath.row] OwnerUnit];
        }
        else {
            UILabel *SubjectName = (UILabel *)[cell.contentView viewWithTag:100];
            if (_nLoadFlg == 1) {
                SubjectName.text = @"正在加载...";
            }
            else {
                SubjectName.text = @"暂无议题";
            }
            cell.userInteractionEnabled = NO;
            return cell;
        }
        
        cell.userInteractionEnabled = YES;
        return cell;
    }
    else {
        UILabel *SubjectName = (UILabel *)[cell.contentView viewWithTag:100];
        SubjectName.text = [[TopicResultArray objectAtIndex:indexPath.row] TopicName];
    }
    cell.userInteractionEnabled = YES;
    return cell;
}

- (void)waitDownload
{
    _nDataSourceFlg = 0;
    [_ContentTableView reloadData];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    @try {
        NSMutableArray *DataArr = [[DataMan MeettingToTopicIDSeqDic] valueForKey:self.MeettingId];
        // 从GIS服务器下载地块数据
        NSString *TopicId = [DataArr objectAtIndex:indexPath.row];
        DBSubProjectDataItem *DBSubProjectData = nil;
        if (_nDataSourceFlg == 0) {
            if ([self.MeettingId length] > 0) 
            {
                DBSubProjectData = [[[DataMan TopicsOfMeeting] objectForKey:self.MeettingId] objectForKey:TopicId];
            }
        }else {
            DBSubProjectData = [TopicResultArray objectAtIndex:indexPath.row];
        }

        //DBSubProjectDataItem *DBSubProjectData = [_ContentDataArray objectAtIndex:indexPath.row];
        TopicId = [DBSubProjectData Id];
        bDownloadFlg = NO;
        
        // 下载议题详细数据
        id Value1 = [[DataMan TopicsReason] objectForKey:TopicId];
        if (Value1 == nil) {
            [delegate DisPlayLoadTopicDataWaittingView:@"正在下载议题详细数据,请稍后..."];
            [DataMan setTopicDKDataQueryDelegate:self];
            [DataMan DownLoadTopicReasonData:TopicId];
        }
        else {
            // 重新加载基本情况数据
            [delegate ReloadTopicReasonData:TopicId];
        }
        
        //检测是否已经有此议题的地块数据
        id Value = [[DataMan TopicIDToFeatureDic] objectForKey:TopicId];
        if (Value == nil) 
        {
            //NSMutableArray *DKArr = [DBSubProjectData DKDataArr];
            NSArray *DKArr = [[DataMan TopicsDKDataDic] objectForKey:TopicId];
            NSMutableArray *BsmArr = [NSMutableArray arrayWithCapacity:3];
            for (DBTopicDKDataItem *obj in DKArr) 
            {
                NSString *Bsm = obj.DKBsm;
                int nLen = [Bsm length];
                if ((nLen <= 0) || [Bsm isEqualToString:@"Empty"]) {
                    continue;
                }
                [BsmArr addObject:Bsm];
            }
            
            // 开始下载地块数据
            if ([BsmArr count] > 0) {
                [DataMan setTopicDKDataQueryDelegate:self];
                [DataMan DownLoadFeatureByBsm:BsmArr KeyWord:TopicId];
            }
        }
        else {
            // 重新加载地块数据
            [delegate ReloadDKData:TopicId];
        }
        
        //self.SubProjectDataItem = [_ContentDataArray objectAtIndex:indexPath.row];
        if (_nDataSourceFlg == 0) {
            self.SubProjectDataItem = [[[DataMan TopicsOfMeeting] objectForKey:self.MeettingId] objectForKey:TopicId];
        }else {
            self.SubProjectDataItem = [TopicResultArray objectAtIndex:indexPath.row];
        }
        
        [DataMan setNCurSubjectRowIndex:indexPath.row];
        
        [delegate SubjectDataViewAppearWithSubProjectDataItem:SubProjectDataItem index:indexPath.row];
    }
    @catch (NSException *exception) {
        [DataMan setNCurSubjectRowIndex:-1];
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - DBDataManagerTopicDKDataQueryDelegate Method
// 议题地块数据查询结束
- (void)TopicDKDidQuery:(NSString*)TopicID
{
    @synchronized(self) 
    {
        if (bDownloadFlg) {
            [delegate HidLoadTopicDataWaittingView:@"基本情况下载完成"];
        }
        else {
            [delegate SetWaittingViewText:@"正在下载基本情况数据,请稍后..."];
        }
        bDownloadFlg = YES;
    }

    // 重新加载地块数据
    [delegate ReloadDKData:TopicID];
    return;
}
// 议题基本情况数据查询结束
- (void)TopicReasonDidQuery:(NSString*)TopicID
{
    @synchronized(self)
    {
        if (bDownloadFlg) {
            [delegate HidLoadTopicDataWaittingView:@"地块数据下载完成"];
        }
        else {
            [delegate SetWaittingViewText:@"正在下载地块数据,请稍后..."];
        }
        bDownloadFlg = YES;
    }
    
    // 加载基本情况数据
    [delegate ReloadTopicReasonData:TopicID];
    
    //下载地块数据
    return;
}

// 显示等待View
- (void)DisPlayLoadingView:(NSString*)Msg
{
    [delegate DisPlayLoadTopicDataWaittingView:Msg];
}

// 消失等待View
- (void)HideLoadingView:(NSString*)Msg
{
    [delegate HidLoadTopicDataWaittingView:Msg];
}
#pragma mark - searchBarDelegate
// 自定义搜索方法
- (void)filterContentForSearchText:(NSString*)searchText
{
    [TopicResultArray removeAllObjects];
    if (searchText.length == 0) {
        _nDataSourceFlg = 0;
        [_ContentTableView reloadData];
        return;
    }
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSArray *TopicArr = [[[DataMan TopicsOfMeeting] objectForKey:self.MeettingId] allValues];
    for (DBSubProjectDataItem *TopicData in TopicArr) {
        NSComparisonResult result = [TopicData.TopicName compare:searchText options:(NSCaseInsensitiveSearch|NSDiacriticInsensitiveSearch) range:NSMakeRange(0, [searchText length])];
        NSRange range = [TopicData.TopicName rangeOfString:searchText];
        if((result == NSOrderedSame) || (range.location != NSNotFound))
        {
            [TopicResultArray addObject:TopicData];
        }
    }
    _nDataSourceFlg = 1;
    [_ContentTableView reloadData]; 
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self filterContentForSearchText:searchText];
}

#pragma mark 议题刷新点击事件处理
-(void)refreshBtnClick:(UIButton*)sender
{
    // 会议数据不刷新，只刷新当前会议下的所有这议题数据
    if ([self.delegate respondsToSelector:@selector(refreshSubjectListData)]) {
        [self.delegate refreshSubjectListData];
    }
    
    return;
}

@end
