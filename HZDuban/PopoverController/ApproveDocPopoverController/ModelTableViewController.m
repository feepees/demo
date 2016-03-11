//
//  ModelTableViewController.m
//  DocumentManager
//
//  Created by mac  on 12-12-19.
//  Copyright (c) 2012年 mac . All rights reserved.
//

#import "ModelTableViewController.h"

@interface ModelTableViewController ()

@end

@implementation ModelTableViewController
@synthesize ModelTableViewDelegate;
@synthesize type;

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
    
    bIsSelectedModel = NO;
    
    UIBarButtonItem *CancelBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleBordered target:self action:@selector(CancelBtnItemTouched:)];
    [self.navigationItem setLeftBarButtonItem:CancelBtnItem animated:NO];
    [CancelBtnItem release];
    
    UIBarButtonItem *OkBtnItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStyleBordered target:self action:@selector(OkeyBtnItemTouched:)];
    [self.navigationItem setRightBarButtonItem:OkBtnItem animated:NO];
    [OkBtnItem release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (type == 1) {
        self.title = @"处理意见模版";
    }else{
        self.title = @"传阅意见模版";
    }
    bIsSelectedModel = NO;
    [self.tableView reloadData];
}
#pragma mark - UIButtonResponder Method
-(void)CancelBtnItemTouched:(id)sender
{
    [ModelTableViewDelegate CancelBtnTouched];
}

-(void)OkeyBtnItemTouched:(id)sender
{
    if (bIsSelectedModel) {
        [ModelTableViewDelegate OkeyBtnTouched];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择模版" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

#pragma mark - UITableViewDelegate Method
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 11;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    if (type == 1) {
        cell.textLabel.text = @"处理意见";
    }else{
        cell.textLabel.text = @"传阅意见";
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    bIsSelectedModel = YES;
    [ModelTableViewDelegate ModelCellDidSelectRowAtIndexPath:indexPath];
}

@end
