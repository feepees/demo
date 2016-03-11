//
//  DBCustomPriceViewController.m
//  HZDuban
//
//  Created by mac on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBCustomPriceViewController.h"

@interface DBCustomPriceViewController ()

@property (retain, nonatomic) UITableView *PriceTableView;
@property (retain, nonatomic) NSMutableArray *PriceInfoArray;
@property (retain, nonatomic) NSMutableArray *HeaderTitleArray;

@end

@implementation DBCustomPriceViewController

@synthesize PriceTableView = _PriceTableView;
@synthesize PriceInfoArray = _PriceInfoArray;
@synthesize HeaderTitleArray = _HeaderTitleArray;

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
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super init];
    if (self) {
        self.view.frame = frame;
        _PriceTableView = [[UITableView alloc]initWithFrame: frame];
        _PriceTableView.rowHeight = 30;
        _PriceTableView.delegate = self;
        _PriceTableView.dataSource = self;
        [self.view addSubview:_PriceTableView];
        [_PriceTableView release];
        
        _PriceInfoArray = [[NSMutableArray alloc] initWithObjects:@"惠州市惠阳区", @"8000平方米", @"5000每平方米", @"惠州市人民政府", nil];
        _HeaderTitleArray = [[NSMutableArray alloc] initWithObjects:@"所在区域", @"占地面积", @"价格", @"所有权", nil];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)dealloc
{
    self.HeaderTitleArray = nil;
    self.PriceInfoArray = nil;
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_HeaderTitleArray count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	// The header for the section is the region name -- get this from the region at the section index.
	NSString *title = [_HeaderTitleArray objectAtIndex:section];
	return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
    int nSection = indexPath.section;
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = [_PriceInfoArray objectAtIndex:nSection];
    cell.textLabel.font = [UIFont systemFontOfSize:17];
    return cell;
}

@end;