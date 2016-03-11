//
//  DBLandInfoViewController.m
//  HZDuban
//
//  Created by mac on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBLandInfoViewController.h"
#import "CommHeader.h"


@interface DBLandInfoViewController ()

@property (retain, nonatomic) UITableView *LandInfoTableView;
@property (retain, nonatomic) DBAGSGraphic *LandInfoGraphic;

@end

@implementation DBLandInfoViewController
@synthesize LandInfoTableView = _LandInfoTableView;
@synthesize LandInfoGraphic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//自定义初始化方法
- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
    }
    return self;
}

- (void)LandInfoViewWillAppearByGraphic:(DBAGSGraphic *)Graphic
{
    self.LandInfoGraphic = Graphic;
    [_LandInfoTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    _LandInfoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, top_bar_heigth, 260.0, 300.0) style:UITableViewStyleGrouped];
    _LandInfoTableView.delegate = self;
    _LandInfoTableView.dataSource = self;
    _LandInfoTableView.backgroundColor = [UIColor clearColor];
    _LandInfoTableView.separatorColor = [UIColor clearColor];
    //_LandInfoTableView.scrollEnabled = NO;
    _LandInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_LandInfoTableView];
    [_LandInfoTableView release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)dealloc
{
    [self.LandInfoTableView release];
    self.LandInfoTableView = nil;
    [self.LandInfoGraphic release];
    self.LandInfoGraphic = nil;
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        if (indexPath.section == 3) {
            UITextView *MemoView = [[UITextView alloc] initWithFrame:CGRectMake(3, 0, 235, 55)];
            [MemoView setTag:100];
            [MemoView setFont:[UIFont systemFontOfSize:13]];
            [MemoView setBackgroundColor:[UIColor clearColor]];
            [MemoView setEditable:NO];
            [cell.contentView addSubview:MemoView];
            [MemoView release];
        }
        
        UIImage *Image = [UIImage imageNamed:@"SeparateLine"];
        UIImageView *ImageView = [[UIImageView alloc] initWithImage:Image];
        CGRect frame = [cell frame];
        frame.size.height = 1.f;
        frame.size.width = 230.f;
        frame.origin.x = 2.0f;
        frame.origin.y = 7.f;
        [ImageView setFrame:frame];
        [cell.contentView addSubview:ImageView];
        [ImageView release];

//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 234, 40)];
//        label.backgroundColor = [UIColor clearColor];
//        label.tag = 100;
//        label.font = [UIFont systemFontOfSize:13];
//        label.numberOfLines = 0;
//        label.lineBreakMode = UILineBreakModeWordWrap;
//        [cell.contentView addSubview:label];
//        [label release];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell.textLabel setFont:[UIFont systemFontOfSize:13]];
    [cell.textLabel setLineBreakMode:UILineBreakModeWordWrap];
    //UILabel *label = (UILabel *)[cell.contentView viewWithTag:100];
    if (indexPath.section == 0) {
        // 地块编号
        cell.textLabel.text = LandInfoGraphic.DKBH;
    }else if (indexPath.section == 1) {
        // 地块标识码
        cell.textLabel.text = LandInfoGraphic.DKBsm;
    }else if (indexPath.section == 2) {
        // 地块申请单位
        cell.textLabel.text = LandInfoGraphic.DKApplicant;
    }
    else if (indexPath.section == 3){
        // 地块备注
        UITextView *MemoView = (UITextView *)[cell.contentView viewWithTag:100];
        MemoView.text = LandInfoGraphic.Notes;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        // 备注
        return 60;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 30;
    }
   return 15;
}


// custom view for header. will be adjusted to default or specified header height
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *label = [[UILabel alloc] init];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 260, 26)];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    if (section == 0) {
        label.frame = CGRectMake(10, 15, 240, 20);
        label.text = @"地块编号";
    }else if(section == 1){
        label.frame = CGRectMake(10, 0, 240, 20);
        label.text = @"地块标识码";
    }else if (section == 2) {
        label.frame = CGRectMake(10, 0, 240, 20);
        label.text = @"申请单位";
    }
    else if (section == 3){
        label.frame = CGRectMake(10, 0, 240, 15);
        label.text = @"备注";
    }
    [view addSubview:label];
    [label release];
    return [view autorelease];
}

@end
