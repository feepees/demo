//
//  DBLandAttributeViewController.m
//  HZDuban
//
//  Created by mac on 12-8-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBLandAttributeViewController.h"
#import <ArcGIS/ArcGIS.h>
#import "Logger.h"

#import "CommHeader.h"

@interface DBLandAttributeViewController ()

@end

@implementation DBLandAttributeViewController

//@synthesize allFeatureSet;
@synthesize delegate;
//@synthesize graphicArray;
//@synthesize BSMArray, OBJECTIDArray, AreaArray, LengthArray, YSDMArray;
//@synthesize TitleArray;
@synthesize PriceResults = _PriceResults;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//- (void)viewWillAppear:(BOOL)animated
//{    
//    [LandDataTabView reloadData];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.TitleArray = [NSArray arrayWithObjects:@"标识码(BSM):", @"地号(ID):", @"面积(Area):", @"长度(Length):", @"要素代码(YSDM):", nil];
    self.title = @"地价信息(元/平方米)";
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(okeyClick:)] autorelease];
    
//    LandDataTabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 300, 360) style:UITableViewStylePlain];
//    //LandDataTabView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
//    LandDataTabView.rowHeight = 43;
//    LandDataTabView.delegate = self;
//    LandDataTabView.dataSource = self;
//    //LandDataTabView.showsVerticalScrollIndicator = NO;
//    //LandDataTabView.bounces = NO;
//    [self.view addSubview:LandDataTabView];
//    [LandDataTabView release];
}

-(void)viewWillAppear:(BOOL)animated
{
    @try {
        DataGridComponentDataSource *ds = [[DataGridComponentDataSource alloc] init];
        int nCnt = 0;
        for (AGSIdentifyResult* result in _PriceResults) 
        {
            
            if (nCnt++ == 0) 
            {
                // 只显示3列
                ds.columnWidth = [NSMutableArray array];
                for (int nCnt2 = 0; nCnt2 < 3; nCnt2++)
                {
                    NSString * str = [NSString stringWithFormat:@"%d", 120];
                    [ds.columnWidth addObject:str];
                }
                ds.titles = [NSMutableArray arrayWithObjects: @"土地类型", @"生地价格",@"熟地价格",nil];
                ds.data = [NSMutableArray array];
            }
            
            NSMutableArray *arrTmp = [NSMutableArray array];
            // 土地类型
            NSRange range = [[result layerName] rangeOfString:@"商业"];
            if (range.location != NSNotFound ) 
            {
                [arrTmp addObject:@"商业用地"];
            }
            else 
            {
                NSRange range = [[result layerName] rangeOfString:@"工业"];
                if (range.location != NSNotFound ) 
                {
                    [arrTmp addObject:@"工业用地"];
                }
                else 
                {
                    NSRange range = [[result layerName] rangeOfString:@"住宅"];
                    if (range.location != NSNotFound ) 
                    {
                        [arrTmp addObject:@"住宅用地"];
                    }
                    else 
                    {
                        [arrTmp addObject:@"其它"];
                    }
                }
            }
            
            // 生地价格
            NSNumber * nVal = [[[result feature] attributes] valueForKey:@"生地价格"];
            double dVal = [nVal doubleValue];
            NSString *strVal = [NSString stringWithFormat:@"%1.3f", dVal];
            [arrTmp addObject:strVal];
            
            // 熟地价格
            nVal = [[[result feature] attributes] valueForKey:@"熟地价格"];
            dVal = [nVal doubleValue];
            strVal = [NSString stringWithFormat:@"%1.3f", dVal];
            [arrTmp addObject:strVal];
            [ds.data addObject:arrTmp];
        }
        
        DataGridComponent *grid = [[DataGridComponent alloc] initWithFrame:CGRectMake(0, top_bar_heigth, 360, 256) data:ds DoubleTitleFlg:1];
        [ds release];
        [grid setDelegate:self];
        [self.view addSubview:grid];
        [grid release];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

    return;
}

- (void)viewDidUnload
{
    self.PriceResults = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{

    self.PriceResults = nil;
    [super dealloc];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)didSelectRowAtIndexPath:(NSInteger)indexRow
{
    return;
}

#pragma mark - okeyButtonResponder
- (void)okeyClick:(id)sender
{
    [delegate LandAttributeViewPopoverDone];
}

/*
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int nCnt = [self.PriceResults count];
    return nCnt;
    //return graphicArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
	// The header for the section is the region name -- get this from the region at the section index.
//    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
//	for (int i = 0; i < allFeatureSet.features.count; i++) {
//        NSString *string = [NSString stringWithFormat:@"第%d块地", i + 1];
//        [array addObject:string];
//    }
//	return [array objectAtIndex:section];
    //AGSIdentifyResult* result = [self.PriceResults objectAtIndex:section];
    NSString *str = [NSString stringWithFormat:@"地价信息%d", section + 1];
    return str;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *string = @"CellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:string];
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:string] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 10, 120, 20)];
        titleLabel.text = @"title";
        titleLabel.font = [UIFont systemFontOfSize:15.0];
        titleLabel.textAlignment = UITextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.tag = 101;
        [cell.contentView addSubview:titleLabel];
        [titleLabel release];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 10, 170, 17)];
        contentLabel.text = @"content";
        contentLabel.font = [UIFont systemFontOfSize:15.0];
        contentLabel.textAlignment = UITextAlignmentLeft;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.tag = 102;
        [cell.contentView addSubview:contentLabel];
        [contentLabel release];
    }
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    UILabel * titleLabel = (UILabel *)[cell.contentView viewWithTag:101];
    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:102];
    AGSIdentifyResult* result = [self.PriceResults objectAtIndex:indexPath.section];
    
    switch (indexPath.row) 
    {
        case 0:
            // 土地类型
            {
                titleLabel.text = @"土地类型:";
                NSRange range = [[result layerName] rangeOfString:@"商业"];
                if (range.location != NSNotFound ) 
                {
                    contentLabel.text = @"商业用地";
                }
                else 
                {
                    NSRange range = [[result layerName] rangeOfString:@"工业"];
                    if (range.location != NSNotFound ) 
                    {
                        contentLabel.text = @"工业用地";
                    }
                    else 
                    {
                        NSRange range = [[result layerName] rangeOfString:@"住宅"];
                        if (range.location != NSNotFound ) 
                        {
                            contentLabel.text = @"住宅用地";
                        }
                        else 
                        {
                            contentLabel.text = @"其它";
                        }
                    }
                }
            }
            break;
        case 1:
        {
            // 生地价格
            titleLabel.text = @"生地价格:";   
            NSNumber * nVal = [[[result feature] attributes] valueForKey:@"生地价格"];
            double dVal = [nVal doubleValue];
            contentLabel.text = [NSString stringWithFormat:@"%1.3f", dVal];
        }
            break;
        case 2:
        {
            // 熟地价格
            titleLabel.text = @"熟地价格:";
            NSNumber * nVal = [[[result feature] attributes] valueForKey:@"熟地价格"];
            double dVal = [nVal doubleValue];
            contentLabel.text = [NSString stringWithFormat:@"%1.3f", dVal];
        }
            break;
        default:
            break;
    }
    return cell;
}  
*/
@end