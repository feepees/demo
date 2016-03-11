//
//  DBAttributeViewController.m
//  HZDuban
//
//  Created by  on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBAttributeViewController.h"
#import "Logger.h"
#import "CommHeader.h"

@interface DBAttributeViewController ()
@property (retain, nonatomic) UITableView *BookMarkTableView;

@property (retain, nonatomic) NSMutableArray *AllBookMarkDataArray;
@property (retain, nonatomic) NSMutableArray *TitleArray;
@property (retain, nonatomic) NSMutableArray *pictureArray;
@property (retain, nonatomic) NSMutableArray *audioArray;
@property (retain, nonatomic) NSMutableArray *videoArray;
@property (retain, nonatomic) NSString *imageTitleForHeader;
@end

@implementation DBAttributeViewController

@synthesize BookMarkTableView = _BookMarkTableView;
@synthesize AllBookMarkDataArray = _AllBookMarkDataArray;
@synthesize TitleArray = _TitleArray;
@synthesize pictureArray = _pictureArray;
@synthesize audioArray = _audioArray;
@synthesize videoArray = _videoArray;
@synthesize imageTitleForHeader = _imageTitleForHeader;
@synthesize delegate = _delegate;
@synthesize DBPOIDataItem = _DBPOIDataItem;

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

- (void)POIInfoViewWillAppearByPOIData:(DBPOIData *)DBPOIData
{
    self.DBPOIDataItem = DBPOIData;
    [_BookMarkTableView reloadData];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _TitleArray = [[NSMutableArray alloc] initWithCapacity:0];
        _AllBookMarkDataArray = [[NSMutableArray alloc] initWithCapacity:5];
        _pictureArray = [[NSMutableArray alloc] initWithCapacity:0];
        _audioArray = [[NSMutableArray alloc] initWithCapacity:5];
        _videoArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //_AllBookMarkDataArray = [[NSMutableArray alloc] initWithObjects:@"data1", @"data2", @"data3", nil];
    self.TitleArray = [NSMutableArray arrayWithObjects:@"名称", @"电话", @"地址", @"公交线路", @"标识码", nil];

    CGFloat fWidth = 260;
    CGFloat fHeight = 360.0f;
    
    CGFloat xPos = 0;
    CGFloat yPos = top_bar_heigth;
    _BookMarkTableView = [[UITableView alloc]initWithFrame:CGRectMake(xPos, yPos, fWidth, fHeight) style:UITableViewStyleGrouped];
    _BookMarkTableView.showsVerticalScrollIndicator = NO;
    _BookMarkTableView.backgroundColor = [UIColor clearColor];
    _BookMarkTableView.separatorColor = [UIColor clearColor];
    _BookMarkTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _BookMarkTableView.delegate = self;
    _BookMarkTableView.dataSource = self;
    [self.view addSubview:_BookMarkTableView];
    [_BookMarkTableView release];
}

-(void)viewWillAppear:(BOOL)animated
{
    return;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
-(void)dealloc
{
    [_BookMarkTableView release];
    [_TitleArray release];
    [_AllBookMarkDataArray release];
    [_pictureArray release];
    [_audioArray release];
    [_videoArray release];
    self.imageTitleForHeader = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

-(void)SetAttributeData:(NSMutableDictionary*)attributes
{
    @try {
        int nCnt = [attributes count];
        if(nCnt <= 0)
        {
            return;
        }
        ///////////////////////////////////////////////////

         //创建一个临时UIImage
        UIImage * tmpImage;
       
        for (int i = 1; i < 7; i++) {
            tmpImage = [UIImage imageNamed:[NSString stringWithFormat:@"%d.jpg", i]];
    
            [_pictureArray addObject:tmpImage];
        }
    
        self.imageTitleForHeader = [NSString stringWithFormat:@"图片（%d张）", _pictureArray.count];
    
        NSEnumerator *enumerator = [attributes keyEnumerator];
        id key;
        while ((key = [enumerator nextObject])) 
        {
            NSString * KeyString = (NSString*)key;
            NSString *ValueString = [attributes objectForKey:KeyString];
            if ([KeyString isEqualToString:@"NAME"]) {
                KeyString = @"单位名称";
            }
            else  if([KeyString isEqualToString:@"TEL"]){
                KeyString = @"电话";
            }
            else  if([KeyString isEqualToString:@"PHOTO"]){
                continue;
            }
            else  if([KeyString isEqualToString:@"ADDRESS"]){
                KeyString = @"地址";
            }
            else  if([KeyString isEqualToString:@"BUS"]){
                KeyString = @"公交线路";
            }
            else  if([KeyString isEqualToString:@"DETAILHREF"]){
                KeyString = @"网址";
            }
            else  if([KeyString isEqualToString:@"BSXM"]){
                KeyString = @"网址";
            }
            else {
                continue;
            }
            
            [_TitleArray addObject:KeyString];
            [_AllBookMarkDataArray addObject:ValueString];
        }
        

        /*
        //0
        NSString *key = @"NAME";
        NSString *name = [attributes valueForKey:key];
        [_TitleArray addObject:@"企业名称"];
        [_AllBookMarkDataArray addObject:name];
        
        //1
        key = @"TYPENAME";
        NSString *typeName = [attributes valueForKey:key];
        [_TitleArray addObject:@"类型名称"];
        [_AllBookMarkDataArray addObject:typeName];
        
        //2
        // convert number to string operation
        key = @"BSM";
        NSNumber * nVal = [attributes valueForKey:key];
        NSNumberFormatter* numberFormatter = [[NSNumberFormatter alloc] init];
        NSString *bsmValue = [numberFormatter stringFromNumber:nVal];
        [_TitleArray addObject:key];
        [_AllBookMarkDataArray addObject:bsmValue];
        
        //3
        key = @"OBJECTID";
        nVal = [attributes valueForKey:key];
        NSString *objectid = [numberFormatter stringFromNumber:nVal];
        [_TitleArray addObject:key];
        [_AllBookMarkDataArray addObject:objectid];
        [numberFormatter release];
        
        //4
        key = @"CODE";
        NSString *codeValue = [attributes valueForKey:key];
        [_TitleArray addObject:@"企业代码号"];
        [_AllBookMarkDataArray addObject:codeValue];
        
        */
        
        //5
        [_TitleArray addObject:_imageTitleForHeader];
        //[_pictureArray addObject:@"1.jpg"];
        //[_pictureArray addObject:@"LoginViewBackground.png"];
        ///////////////////////////////////////////////////
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

    return;
}

#pragma mark -
#pragma mark AGSGeometryServiceTaskDelegate Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
//    int nCnt = 0;
//    if(section == 5)
//    {
//        // picture
//        nCnt = [_pictureArray count];
//    }
//    else {
//        nCnt = 1;
//    }
//    return nCnt; //[_AllBookMarkDataArray count];
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_TitleArray count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//	// The header for the section is the region name -- get this from the region at the section index.
//	NSString *title = [_TitleArray objectAtIndex:section];
//	return title;
//}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    int nSection = indexPath.section;
    int nRow = indexPath.row;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
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
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    cell.textLabel.font = [UIFont systemFontOfSize:13];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.lineBreakMode = UILineBreakModeWordWrap;
    NSString *title = [_TitleArray objectAtIndex:nSection];
    if ([title isEqualToString:_imageTitleForHeader]) 
    {
        UIImage *image = [_pictureArray objectAtIndex:nRow];
        UIImageView *imageView = [cell imageView];
        [imageView setImage:image];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    if (nSection == 0) {
        // 名称
        cell.textLabel.text = [_DBPOIDataItem POIName];
    }
    else if(nSection == 1)
    {
        // 电话
        if ([[_DBPOIDataItem LXDH] length] > 0) {
            cell.textLabel.text = [_DBPOIDataItem LXDH];
        }
        else {
            [cell.textLabel setText:@""];
        }
    }else if(nSection == 2){
        // 地址
        if ([[_DBPOIDataItem POIXXDZ] length] > 0) {
            cell.textLabel.text = [_DBPOIDataItem POIXXDZ];
        }
    }
    else if(nSection == 3){
        //公交线路
    }else if(nSection == 4){
        //标识码
        if ([[_DBPOIDataItem BSM] length] > 0) {
            cell.textLabel.text = [_DBPOIDataItem BSM];
        }
    }
    else {
        //cell.textLabel.text = [_AllBookMarkDataArray objectAtIndex:nSection];
    }
//    UIFont *font = [UIFont systemFontOfSize:17];
//    [cell.textLabel setFont:font];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
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
    label.text = [_TitleArray objectAtIndex:section];
    [view addSubview:label];
    [label release];
    return [view autorelease];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    /*
    int nSection = indexPath.section;
    NSString *str = [_TitleArray objectAtIndex:nSection];
    if ([str isEqualToString:_imageTitleForHeader]) 
    {
        [_delegate ScrollViewAppearWithPictureArray:_pictureArray];
    }
    */
    return;
}

@end
