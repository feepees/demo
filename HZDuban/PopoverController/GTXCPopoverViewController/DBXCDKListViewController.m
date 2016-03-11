//
//  DBXCDKListViewController.m
//  HZDuban
//
//  Created by sunz on 13-7-4.
//
//

#import "DBXCDKListViewController.h"
#import "CommHeader.h"
#import "DBLocalTileDataManager.h"

#define DOWNLOAD_COUNT  5
@interface DBXCDKListViewController ()

@property (nonatomic, retain) DBLocalTileDataManager *singleManager;
// 当前地块列表中地块的状态  0:显示未竣工地块  1：显示已竣工地块
@property (nonatomic, assign) int nCurrDKListState;
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeadView;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) int JGDKListTotalCount;
@property (nonatomic, assign) int DKListTotalCount;

@end

@implementation DBXCDKListViewController

@synthesize delegate;
@synthesize singleManager = _singleManager;
@synthesize nCurrDKListState = _nCurrDKListState;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _nCurrDKListState = 0;
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
    
    UISegmentedControl *statusSeg = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"未竣工", @"已竣工", nil]];
    [statusSeg addTarget:self action:@selector(changeStatus:) forControlEvents:UIControlEventValueChanged];
    CGRect frame = statusSeg.frame;
    frame.size = CGSizeMake(150, 25);
    statusSeg.frame = frame;
    statusSeg.selectedSegmentIndex = 0;
    statusSeg.segmentedControlStyle = UISegmentedControlStyleBar;
    self.navigationItem.titleView = statusSeg;
    
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    DataMan.XCDKDelegate = self;
    [self.tableView setFrame:CGRectMake(0, 0, 320.0, 110.0)];
    self.tableView.showsVerticalScrollIndicator = YES;
    
    //添加“查看更多”按钮
    UIButton *MoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];;
    [MoreBtn setFrame:CGRectMake(40, 16, 260 - 40, 30)];
    UIImage *ImageData = [UIImage imageNamed:@"MoreBtn.png"];
    [MoreBtn setBackgroundImage:ImageData forState:UIControlStateNormal];
    [MoreBtn addTarget:self action:@selector(DownLoadXCDK) forControlEvents:UIControlEventTouchUpInside];
    [MoreBtn setTitle:@"显示更多" forState:UIControlStateNormal];
    [MoreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [MoreBtn setTag:100];
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 50)];
    [footView addSubview:MoreBtn];
    self.tableView.tableFooterView = footView;
    //self.tableView.tableFooterView.hidden = YES;
    self.tableView.showsVerticalScrollIndicator = YES;
    
    //下拉刷新
    if (_refreshHeadView == nil) {
		
		EGORefreshTableHeaderView *view = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableView.bounds.size.height, self.view.frame.size.width, self.tableView.bounds.size.height)];
        
		view.delegate = self;
		[self.tableView addSubview:view];
		_refreshHeadView = view;
	}
	//  update the last update date
	[_refreshHeadView refreshLastUpdatedDate];
}

-(void)DataInit
{
//    NSMutableDictionary *DicTmp = [NSMutableDictionary dictionaryWithCapacity:2];
//    [DicTmp setObject:@"江北地块" forKey:@"ProjectName"];
//    [DicTmp setObject:@"300平方米" forKey:AREA_KEY];
//    [_XCDKDataArr addObject:DicTmp];
//    [DicTmp removeAllObjects];
//    [DicTmp setObject:@"江南地块" forKey:@"ProjectName"];
//    [DicTmp setObject:@"280" forKey:AREA_KEY];
//    [_XCDKDataArr addObject:DicTmp];
//
//    NSData *jsonDataWrite = [NSJSONSerialization dataWithJSONObject:_XCRecordImagesArr options:NSJSONWritingPrettyPrinted error:nil];
//    
//    NSString *strJson = [[NSString alloc] initWithData:jsonDataWrite encoding:NSUTF8StringEncoding];
//    NSString *path = [NSString stringWithFormat:@"%@/test6.txt", DocumentDir];
//    [strJson writeToFile:path atomically:NO encoding:NSUTF8StringEncoding error:nil];
//   
//    NSData *jsonDataRead = [NSData dataWithContentsOfFile:path];
//    
//    NSArray *arr = [NSJSONSerialization JSONObjectWithData:jsonDataRead options:NSJSONWritingPrettyPrinted error:nil];
    

    return;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSInteger nCnt = 0;
    if (_nCurrDKListState == 0) {
        nCnt = [DataMan.XCDKList count];
    }
    else{
        nCnt = [DataMan.JGXCDKList count];
    }
    nCnt = (nCnt > 0)?nCnt:1;
    return nCnt;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // Configure the cell...
    if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;

        UILabel *Name = [[UILabel alloc] initWithFrame:CGRectMake(3, 3, 300, 36)];
        Name.numberOfLines = 0;
        //Name.shadowColor = [UIColor grayColor];
        Name.lineBreakMode = UILineBreakModeWordWrap;
        //Name.font = [UIFont systemFontOfSize:15];
        Name.font = [UIFont boldSystemFontOfSize:15];
        Name.tag = 101;
        [cell.contentView addSubview:Name];
        
        UILabel *Address = [[UILabel alloc] initWithFrame:CGRectMake(3, 50, 220, 15)];
        Address.backgroundColor = [UIColor clearColor];
        Address.font = [UIFont systemFontOfSize:13];
        Address.tag = 102;
        [cell.contentView addSubview:Address];
        
        //        UILabel *OwnerUnit = [[UILabel alloc] initWithFrame:CGRectMake(120, 42, 170, 15)];
        //        OwnerUnit.textAlignment = UITextAlignmentRight;
        //        OwnerUnit.backgroundColor = [UIColor clearColor];
        //        OwnerUnit.font = [UIFont systemFontOfSize:13];
        //        OwnerUnit.tag = 103;
        //        [cell.contentView addSubview:OwnerUnit];
        //        [OwnerUnit release];
        
        UILabel *ProjectStratTime = [[UILabel alloc] initWithFrame:CGRectMake(205, 50, 100, 15)];
        ProjectStratTime.textAlignment = UITextAlignmentRight;
        ProjectStratTime.backgroundColor = [UIColor clearColor];
        ProjectStratTime.font = [UIFont systemFontOfSize:13];
        ProjectStratTime.tag = 104;
        [cell.contentView addSubview:ProjectStratTime];
	}
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    UILabel *Name = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *Address = (UILabel *)[cell.contentView viewWithTag:102];
    UILabel *Time = (UILabel *)[cell.contentView viewWithTag:104];
    
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSArray *ArrTmp;
    if (_nCurrDKListState == 0) {
        //
        ArrTmp = DataMan.XCDKList;
    }
    else{
        ArrTmp = DataMan.JGXCDKList;
    }
    if ([ArrTmp count] <= 0) {
        int nLoadFlg = [DataMan XCDKDownloadingFlg];
        if (nLoadFlg == 1) {
            [Name setText:@"正在加载..."];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        else {
            [Name setText:@"暂无数据"];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [Address setText:@""];
        [Time setText:@""];
    }
    else{
        NSDictionary *DicData = [[ArrTmp objectAtIndex:indexPath.row] objectForKey:@"LandInfoObject"];
        // 受让人 
        NSString *SRR = [[DicData valueForKey:@"SRR"] objectAtIndex:0];
        // 用途  
        NSString *notifiNo = [[DicData valueForKey:@"UsePurpose"] objectAtIndex:0];
        // 国有土地使用证号
        NSString *certifiNo = [[DicData valueForKey:@"TDSYZH"] objectAtIndex:0];
        
        [Name setText:SRR];
        [Address setText:certifiNo];
        [Time setText:notifiNo];
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
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    if([DataMan XCDKDownloadingFlg] == 0)
    {
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        if (_nCurrDKListState == 0) {
            // 未竣工 
            NSDictionary *DicData = [[[DataMan.XCDKList objectAtIndex:indexPath.row] objectForKey:@"LandInfoObject"] objectAtIndex:0];
            [self.delegate ViewAppearWithJGDKDataItem:DicData];
        }
        else{
            // 已竣工
            NSDictionary *DicData = [[[DataMan.JGXCDKList objectAtIndex:indexPath.row] objectForKey:@"LandInfoObject"] objectAtIndex:0];
            [self.delegate ViewAppearWithJGDKDataItem:DicData];
        }

    }

    return;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
//    if (DataMan.XCDKList.count == 0) {
//        return 39;
//    }
    
    return 70;
}

//Custom
-(void)SetSubPopoverHiden
{
//    if ([_Subject2ViewPopover isPopoverVisible]) {
//        [_Subject2ViewPopover dismissPopoverAnimated:NO];
//        _Subject2ViewPopover = nil;
//        SubContentView = nil;
//    }
}

#pragma mark --
#pragma 改变列表内容
- (void)changeStatus:(id)sender{
    
    if (![sender isMemberOfClass:[UISegmentedControl class]]) {
        return;
    }
    // 当前加载什么状态(已竣工/未竣工)的地块
    UISegmentedControl *controller = (UISegmentedControl *)sender;
    _nCurrDKListState = controller.selectedSegmentIndex;
    
    _singleManager = [DBLocalTileDataManager instance];
    if (![_singleManager InternetConnectionTest]){
        [_singleManager CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
        return;
    }

    int nCnt = 0;
    if (_nCurrDKListState == 0) {
        // not complete
        nCnt = [[_singleManager XCDKList] count];
    }
    else{
        // already
        nCnt = [[_singleManager JGXCDKList] count];
    }
    if (nCnt == 0) {
        // 只在没有任何地块时去下载
        self.tableView.tableFooterView.hidden = YES;
        [_singleManager GetXCDKDataList:nCnt Count:DOWNLOAD_COUNT StateFlg:_nCurrDKListState];
    }
    
    [self XCDKViewReload:_nCurrDKListState==0 ? self.DKListTotalCount : self.JGDKListTotalCount State:_nCurrDKListState];
}

- (void)DownLoadXCDK
{
    _singleManager = [DBLocalTileDataManager instance];
    
    if (![_singleManager InternetConnectionTest]){
        [_singleManager CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
        return;
    }
    int nCnt = 0;
    if (_nCurrDKListState == 0) {
        nCnt = [[_singleManager XCDKList] count];
    }
    else{
        nCnt = [[_singleManager JGXCDKList] count];
    }
    
    [_singleManager GetXCDKDataList:nCnt Count:DOWNLOAD_COUNT StateFlg:_nCurrDKListState];
}


#pragma mark 巡查地块数据下载完毕后重新加载画面
- (void)XCDKViewReload:(NSInteger)totalCount State:(NSInteger)nDKState
{
    _isLoading = NO;
    BOOL bHasNewData = YES;
    if (nDKState == 0) {
        bHasNewData = totalCount > [_singleManager.XCDKList count];
        self.DKListTotalCount = totalCount;
    }else{
        bHasNewData = totalCount > [_singleManager.JGXCDKList count];
        self.JGDKListTotalCount = totalCount;
    }
    
    if (!bHasNewData) {
        self.tableView.tableFooterView.hidden = NO;
        // 再无更多数据
        UIButton *Btn = (UIButton*)[self.tableView.tableFooterView viewWithTag:100];
        if (Btn) {
            [Btn setTitle:@"已无更多数据" forState:UIControlStateNormal];
        }
    }else if(bHasNewData){
        self.tableView.tableFooterView.hidden = NO;
        UIButton *Btn = (UIButton*)[self.tableView.tableFooterView viewWithTag:100];
        if (Btn) {
            [Btn setTitle:@"显示更多" forState:UIControlStateNormal];
        }
    }

    [self.tableView reloadData];
    [_refreshHeadView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tableView];
}

#pragma mark - 下拉刷新
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
    return self.isLoading;
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
    self.tableView.tableFooterView.hidden = YES;
    if (![_singleManager InternetConnectionTest]) {
        [_singleManager CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:@"无法完成刷新"];
        _isLoading = NO;
        return;
    }
    
    _isLoading = YES;
    if (_nCurrDKListState == 0) {
        [[_singleManager XCDKList] removeAllObjects];
    }else{
        [[_singleManager JGXCDKList] removeAllObjects];
    }
    [self DownLoadXCDK];
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [_refreshHeadView egoRefreshScrollViewDidEndDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [_refreshHeadView egoRefreshScrollViewDidScroll:scrollView];
}


@end
