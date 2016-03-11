//
//  DBLatelySearchOrPOIViewController.m
//  HZDuban
//
//  Created by mac on 12-8-14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBLatelySearchOrPOIViewController.h"
#import "BookMarkManager.h"
#import "DBPOIData.h"

@interface DBLatelySearchOrPOIViewController ()

@end

@implementation DBLatelySearchOrPOIViewController
@synthesize AllBookMarkDataArray = _AllBookMarkDataArray;
@synthesize SearchedDataArray = _SearchedDataArray;
@synthesize nDataSourceFlg = _nDataSourceFlg;
@synthesize delegate = _delegate;
@synthesize QueryWord;
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
-(void)okeyClick:(id)sender
{
    [_delegate POISearchPopoverViewOkeyBtnClicked];
}

-(void)searchBtnClick:(id)sender
{
    [_delegate ExecSearchFunc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(okeyClick:)] autorelease];
    
    //self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"search" style:UIBarButtonItemStylePlain target:self action:@selector(okeyClick:)] autorelease];
    
    UIImage *image = [UIImage imageNamed:@"SearchBtn.png"];
    
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:@selector(searchBtnClick:)] autorelease];

    
    //[self.navigationItem.leftBarButtonItem setBackgroundImage:image forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    SingleManager = [DBLocalTileDataManager instance];
    _AllBookMarkDataArray = [BookMarkManager GetBookMarks];
    
    //设置footerView
    UIButton *MoreBtn = [UIButton buttonWithType:UIButtonTypeCustom];;
    [MoreBtn setFrame:CGRectMake(20, 6, 260 - 40, 30)];
    UIImage *ImageData = [UIImage imageNamed:@"MoreBtn.png"];
    [MoreBtn setBackgroundImage:ImageData forState:UIControlStateNormal];
    [MoreBtn addTarget:self action:@selector(DownLoadMorePOI) forControlEvents:UIControlEventTouchUpInside];
    [MoreBtn setTitle:@"显示更多" forState:UIControlStateNormal];    
    [MoreBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIView *footView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 50)] autorelease];
    [footView addSubview:MoreBtn];
    self.tableView.tableFooterView = footView;
    self.tableView.tableFooterView.hidden = YES;
    self.tableView.showsVerticalScrollIndicator = YES; 
    _PreIndexPath = nil;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)dealloc
{
    [self.AllBookMarkDataArray removeAllObjects];
    self.AllBookMarkDataArray = nil;
    [self.SearchedDataArray removeAllObjects];
    self.SearchedDataArray = nil;
    self.QueryWord = nil;
    //self.SingleManager = nil;
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)ReloadBookMarkData
{
    [self.tableView reloadData];
}

- (void)DownLoadMorePOI
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    BOOL bNetConn = [DataMan InternetConnectionTest];
    if (!bNetConn) {
        [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
        return;
    }
    
    [self.delegate MoreSearchDisplayLoadingView];
    SingleManager.FooterDelegate = self;
    [SingleManager DownLoadPOI:nil downLoadFlg:1];
}

- (void)TableFooterViewHidden
{
    self.tableView.tableFooterView.hidden = YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    _PreIndexPath = nil;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger nCount = 0;
    if(_nDataSourceFlg == 0)
    {
        tableView.rowHeight = 45;
        self.tableView.tableFooterView.hidden = YES;
        nCount = [_AllBookMarkDataArray count];
        if (nCount == 0) {
            self.contentSizeForViewInPopover = CGSizeMake(260, 45);
            nCount = 1;
        }else if(nCount <= 7) {
            self.contentSizeForViewInPopover = CGSizeMake(260, nCount * 45);
        }else {
            self.contentSizeForViewInPopover = CGSizeMake(260, 400);
        }
    }
    else if(_nDataSourceFlg == 1)
    {
        tableView.rowHeight = 45;
        self.tableView.tableFooterView.hidden = YES;
        nCount = [_SearchedDataArray count];
        if (nCount == 0) {
            self.contentSizeForViewInPopover = CGSizeMake(260, 45);
            nCount = 1;
        }else if(nCount <= 7) {
            self.contentSizeForViewInPopover = CGSizeMake(260, nCount * 45);
        }else {
            self.contentSizeForViewInPopover = CGSizeMake(260, 400);
        }
    }else if(_nDataSourceFlg == 2)
    {
        
        tableView.rowHeight = 75;
        self.tableView.tableFooterView.hidden = NO;
        nCount = SingleManager.POIArray.count;
        if (nCount == 0) {
            self.contentSizeForViewInPopover = CGSizeMake(260, 100);
        }else if(nCount < 5) {
            self.tableView.tableFooterView.hidden = YES;
            self.contentSizeForViewInPopover = CGSizeMake(260, nCount * 75 + 200);
        }else {
            self.contentSizeForViewInPopover = CGSizeMake(260, 400);
        }
    }  
    return nCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_nDataSourceFlg == 2) {
        static NSString *MyIdentifier = @"POI";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MyIdentifier] autorelease];
            UILabel *Name = [[UILabel alloc] initWithFrame:CGRectMake(30, 3, 225, 34)];
            //Name.font = [UIFont systemFontOfSize:15];
            Name.font = [UIFont boldSystemFontOfSize:15];
            [Name setTextColor:[UIColor brownColor]];
            Name.lineBreakMode = UILineBreakModeWordWrap;
            Name.numberOfLines = 0;
            Name.tag = 100;
            [cell.contentView addSubview:Name];
            [Name release];
            
            UILabel *Address = [[UILabel alloc] initWithFrame:CGRectMake(30, 38, 225, 18)];
            Address.font = [UIFont systemFontOfSize:12];
            Address.tag = 101;
            [cell.contentView addSubview:Address];
            [Address release];
            
            UILabel *TelNum = [[UILabel alloc] initWithFrame:CGRectMake(30, 57, 200, 18)];
            TelNum.font = [UIFont systemFontOfSize:12];
            TelNum.tag = 102;
            [cell.contentView addSubview:TelNum];
            [TelNum release];
            
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 20, 30, 30)];
            [imageView setTag:103];
            [cell.contentView addSubview:imageView];
            [imageView release];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        UILabel *name = (UILabel *)[cell.contentView viewWithTag:100];
        name.text = [[SingleManager.POIArray objectAtIndex:indexPath.row] POIName];
        UILabel *address = (UILabel *)[cell.contentView viewWithTag:101];
        address.text = [NSString stringWithFormat:@"地址:%@", [[SingleManager.POIArray objectAtIndex:indexPath.row] POIXXDZ]];
        UILabel *telNumber = (UILabel *)[cell.contentView viewWithTag:102];
    
        telNumber.text = [NSString stringWithFormat:@"联系电话:%@", [[SingleManager.POIArray objectAtIndex:indexPath.row] LXDH]];
        //telNumber.text = @"联系电话:";
        
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:103];
        NSString *ImageName = nil;
        if (_PreIndexPath == nil) {
            ImageName = @"POIBluePin.png";
        }
        else {
            if ((indexPath.section == _PreIndexPath.section) && (indexPath.row == _PreIndexPath.row)) {
                ImageName = @"POIRedPin.png";
            }
            else {
                ImageName = @"POIBluePin.png";
            }
        }

        UIImage *image = [UIImage imageNamed:ImageName];
        [imageView setImage:image];
        return cell;
    }
    static NSString *CellIdentifier = @"Cell";
    int nRow = [indexPath row];
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
	}
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    [cell setBackgroundColor:[UIColor clearColor]];
    if(_nDataSourceFlg == 0)
    {
        if (_AllBookMarkDataArray.count == 0) {
            cell.textLabel.text = @"没有结果";
        }else {
            cell.textLabel.text = [_AllBookMarkDataArray objectAtIndex:nRow];
        }
    }
    else if(_nDataSourceFlg == 1)
    {
        if (_SearchedDataArray.count == 0) {
            cell.textLabel.text = @"没有结果";
        }else {
            cell.textLabel.text = [_SearchedDataArray objectAtIndex:nRow];
        }
    }
    
    cell.textLabel.textColor = [UIColor blackColor];
    cell.textLabel.font = [cell.textLabel.font fontWithSize:15];

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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int nRow = indexPath.row;
    NSString *text;
    if(_nDataSourceFlg == 0)
    {
        text = [_AllBookMarkDataArray objectAtIndex:nRow];
    }
    else if (_nDataSourceFlg == 1)
    {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        NSString *string = cell.textLabel.text;
        if ([string isEqualToString:@"没有结果"]) {
            return;
        }
        text = [_SearchedDataArray objectAtIndex:nRow];
    }else {
        // 上一选中cell 图标恢复为蓝色
        if (_PreIndexPath != nil) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:_PreIndexPath];
            UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:103];
            UIImage *image = [UIImage imageNamed:@"POIBluePin.png"];
            [imageView setImage:image];
        }
        
        // 点击POI数据，设置图标为红色
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:103];
        UIImage *image = [UIImage imageNamed:@"POIRedPin.png"];
        [imageView setImage:image];
        _PreIndexPath = nil;
        _PreIndexPath = [indexPath copy];
        
        // 更新或追加地图图标
        text = [[SingleManager.POIArray objectAtIndex:nRow] OID];
        [self.delegate POIAppear:text Type:1];
        return;
    }
    [self.delegate SearchTextSet:text];
    
    return;
}

// 设置选中Cell的image为红色状态,原来的为蓝色状态.
-(void)SetSelectedCellImage:(NSInteger)nIndex
{
    // 上一选中cell 图标恢复为蓝色
    if (_PreIndexPath != nil) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:_PreIndexPath];
        UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:103];
        UIImage *image = [UIImage imageNamed:@"POIBluePin.png"];
        [imageView setImage:image];
    }
    
    // 点击POI数据，设置图标为红色
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nIndex inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:103];
    UIImage *image = [UIImage imageNamed:@"POIRedPin.png"];
    [imageView setImage:image];
    _PreIndexPath = nil;
    _PreIndexPath = [indexPath copy];
    
    return;
}
@end
