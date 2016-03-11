//
//  DBLandDataViewController.m
//  HZDuban
//
//  Created by mac on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBLandDataViewController.h"
#import "Logger.h"
#import "DBLocalTileDataManager.h"
#import "DBDisplayFieldDataItem.h"
#import "CommHeader.h"

@interface DBLandDataViewController ()

@end

@implementation DBLandDataViewController
@synthesize areaOfLandArray;
@synthesize HeaderTitleArray = _HeaderTitleArray;
@synthesize delegate;
@synthesize ResultSets = _ResultSets;
@synthesize Graphic = _Graphic;
@synthesize nTypeFlg = _nTypeFlg;
@synthesize DataMapUrl = _DataMapUrl;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _nTypeFlg = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(okeyClick:)] autorelease];
    //LandDataTabView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    LandDataTabView = [[UITableView alloc] initWithFrame:CGRectMake(0, top_bar_heigth, 240, 416) style:UITableViewStyleGrouped];
    LandDataTabView.separatorColor = [UIColor clearColor];
    LandDataTabView.separatorStyle = UITableViewCellSeparatorStyleNone;
    LandDataTabView.delegate = self;
    LandDataTabView.dataSource = self;
    LandDataTabView.rowHeight = 43;
    LandDataTabView.showsVerticalScrollIndicator = YES;
     //_HeaderTitleArray = [[NSMutableArray alloc] initWithObjects:@"所在区域", @"占地面积", @"价格", @"土地类型", nil];
    [self.view addSubview:LandDataTabView];
    [LandDataTabView release];
}

- (void)viewDidUnload
{
    self.DataMapUrl = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)viewWillAppear:(BOOL)animated
{
    self.title = @"地块信息";
    AGSIdentifyResult* result = [self.ResultSets objectAtIndex:0];
    indexOfNote  = [[[[result feature] attributes] allKeys] indexOfObject:@"地类备注"];
    [LandDataTabView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)dealloc
{
    [self.DataMapUrl release];
    self.HeaderTitleArray = nil;
    self.areaOfLandArray = nil;
    _ResultSets = nil;
    _Graphic = nil;
    [super dealloc];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - okeyButtonResponder
- (void)okeyClick:(id)sender
{
    [delegate LandDataViewPopoverDone];
}

#pragma mark - 重新加载数据
-(void)ReloadTableData:(NSString*)Url
{
    if ([Url isEqualToString:self.DataMapUrl]) {
        [LandDataTabView reloadData];
    }
    return;
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int nCnt;
    if (_nTypeFlg == 0) {
        nCnt = 1;
    }else {
        nCnt = [[_Graphic attributes] count];
    }
    
    return nCnt;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int nCnt;
    if (_nTypeFlg == 0) {
//        // 所有地块属性
//        nCnt = [[[[_ResultSets objectAtIndex:0] feature] attributes] count];
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        NSArray *fieldArr = [[DataMan PhyLayerIdToFieldsDic] objectForKey:self.DataMapUrl];
        nCnt = [fieldArr count];
    }else {
        nCnt = 1;
    }
    
    return nCnt;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	// The header for the section is the region name -- get this from the region at the section index.
//	NSString *title = [_HeaderTitleArray objectAtIndex:section];
//	return title;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        /* 暂时commented by niurg 2012-09-17
        // 如果是备注字段
        if (indexPath.section == indexOfNote) 
        {
            static NSString *CellNoteID = @"CellNoteID";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellNoteID];
            if (cell == nil) 
            {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellNoteID] autorelease];
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
                UITextView *TextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 5, 235, 60)];
                [TextView setTag:100];
                [TextView setFont:[UIFont systemFontOfSize:13]];
                [TextView setBackgroundColor:[UIColor clearColor]];
                [TextView setEditable:NO];
                [cell.contentView addSubview:TextView];
                [TextView release];
            }
            UITextView *TextView = (UITextView *)[cell.contentView viewWithTag:100];
            AGSIdentifyResult* result = [self.ResultSets objectAtIndex:0];
            NSString *content = [[[[result feature] attributes] allValues] objectAtIndex:indexOfNote];
            if ([content isEqualToString:@"Null"]) {
                content = @"暂无数据";
            }
            TextView.text = content;
            [cell setBackgroundColor:[UIColor clearColor]];
            return cell;
        }
        */
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
        }
        
        [cell setBackgroundColor:[UIColor clearColor]];
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
        if (_nTypeFlg == 0) 
        {
            AGSIdentifyResult* result = [self.ResultSets objectAtIndex:0];
            //--- chg by nirug 2012-09-17 显示所配置好的字段
            //NSString *content = [[[[result feature] attributes] allValues] objectAtIndex:indexPath.section];
            DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
            NSArray * fieldArr = [[DataMan PhyLayerIdToFieldsDic] objectForKey:self.DataMapUrl];
            DBDisplayFieldDataItem *DBDisplayFieldData = [fieldArr objectAtIndex:indexPath.section];
            
            NSString *key = [DBDisplayFieldData FIELDDEFALIAS];
            if ([key length] <= 0) {
                key = [DBDisplayFieldData FIELDDEFNAME];
            }
            NSString *content = [[[result feature] attributes] objectForKey:key]; 
            if ([content length] <= 0) {
                key = [DBDisplayFieldData FIELDDEFNAME];
                content = [[[result feature] attributes] objectForKey:key]; 
                if ([content length] <= 0) 
                {
                    // 针对权力人的特别处理
                    NSRange Range = [key rangeOfString:@"QLR"];
                    if (Range.location != NSNotFound) 
                    {
                        key = @"QLR";
                        content = [[[result feature] attributes] objectForKey:key]; 
                    }
                }
            }
            //---
            if ([content isEqualToString:@"Null"]) 
            {
                content = @"暂无数据";
            }
            cell.textLabel.text = content;
        }
        else 
        {
            NSString *content = [[[_Graphic attributes] allValues] objectAtIndex:indexPath.row];
            cell.textLabel.text = content;
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
//    if (indexPath.section == indexOfNote) {
//        return 60;
//    }
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSArray * fieldArr = [[DataMan PhyLayerIdToFieldsDic] objectForKey:self.DataMapUrl];
    DBDisplayFieldDataItem *DBDisplayFieldData = [fieldArr objectAtIndex:indexPath.section];
    
    NSString *key = [DBDisplayFieldData FIELDDEFALIAS];
    if ([key length] <= 0) {
        key = [DBDisplayFieldData FIELDDEFNAME];
    }
    AGSIdentifyResult* result = [self.ResultSets objectAtIndex:0];
    NSString *content = [[[result feature] attributes] objectForKey:key]; 
    if ([content length] <= 0) {
        key = [DBDisplayFieldData FIELDDEFNAME];
        content = [[[result feature] attributes] objectForKey:key]; 
        if ([content length] <= 0) 
        {
            // 针对权力人的特别处理
            NSRange Range = [key rangeOfString:@"QLR"];
            if (Range.location != NSNotFound) 
            {
                key = @"QLR";
                content = [[[result feature] attributes] objectForKey:key]; 
            }
        }
    }
    
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
    return 10;
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
    //AGSIdentifyResult* result = [self.ResultSets objectAtIndex:0];
    //--- chg by niurg 2012-09-17
    //label.text = [[[[result feature] attributes] allKeys] objectAtIndex:section];
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSArray * fieldArr = [[DataMan PhyLayerIdToFieldsDic] objectForKey:self.DataMapUrl];
    DBDisplayFieldDataItem *DBDisplayFieldData = [fieldArr objectAtIndex:section];
    NSString *key = [DBDisplayFieldData FIELDDEFALIAS];
    if ([key length] <= 0) {
        key = [DBDisplayFieldData FIELDDEFNAME];
    }
    label.text = key;
    //---
    [view addSubview:label];
    [label release];

    return [view autorelease];
}

@end
