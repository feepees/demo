//
//  SendTableViewController.m
//  DocumentManager
//
//  Created by mac  on 12-12-20.
//  Copyright (c) 2012年 mac . All rights reserved.
//

#import "SendTableViewController.h"

@interface SendTableViewController ()

@end

@implementation SendTableViewController
@synthesize SendTableViewDelegate;
@synthesize NameArr;

#pragma mark - View LifeCycle
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

    UIBarButtonItem *CancelBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(CancelBtnItemTouched:)];
    [self.navigationItem setLeftBarButtonItem:CancelBtnItem animated:NO];
    [CancelBtnItem release];
    
    UIBarButtonItem *OkBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(OkeyBtnItemTouched:)];
    [self.navigationItem setRightBarButtonItem:OkBtnItem animated:NO];
    [OkBtnItem release];
    
    self.NameArr = [NSMutableArray arrayWithCapacity:0];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.tableView.editing = YES;
    [self.NameArr removeAllObjects];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionNone animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.NameArr = nil;
    
    [super dealloc];
}
#pragma mark - UIButtonResponder Method
- (void)CancelBtnItemTouched:(id)sender
{
    self.tableView.editing = NO;
    [SendTableViewDelegate SendViewCancelBtnTouched];
}
- (void)OkeyBtnItemTouched:(id)sender
{
    if (self.NameArr.count == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择发送对象" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }else{
        self.tableView.editing = NO;
        [SendTableViewDelegate OkeyBtnTouchedWithArray:self.NameArr];
    }
}
#pragma mark - UITableViewDelegate Method

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"市长办公室";
            break;
        case 1:
            return @"局长办公室";
            break;
        case 2:
            return @"处长办公室";
            break;
        case 3:
            return @"所长办公室";
            break;
        case 4:
            return @"办公室";
            break;
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    cell.textLabel.text = @"张三";
    
    return cell;
}

//设置编辑模式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleInsert | UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.NameArr addObject:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.NameArr removeObject:indexPath];
}
@end
