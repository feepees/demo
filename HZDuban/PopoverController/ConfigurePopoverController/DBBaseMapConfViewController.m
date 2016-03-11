//
//  DBBaseMapConfViewController.m
//  HZDuban
//
//  Created by  on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBBaseMapConfViewController.h"

@interface DBBaseMapConfViewController ()

@end

@implementation DBBaseMapConfViewController
@synthesize Delegate;
@synthesize nBaseMapType = _nBaseMapType;
@synthesize BaseMapLayersDic = _BaseMapLayersDic;
@synthesize OrgBaseMapLayersDic = _OrgBaseMapLayersDic;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.tableView setRowHeight:75];
}

-(void)dealloc
{
    self.BaseMapLayersDic = nil;
    self.OrgBaseMapLayersDic = nil;
    [super dealloc];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    NSMutableArray *LayerNames = [NSMutableArray arrayWithCapacity:2];
    NSMutableArray *LayerIndex = [NSMutableArray arrayWithCapacity:2];
    NSArray *allKeys = [self.BaseMapLayersDic allKeys];
    int nCnt = 0;
    for (NSString *LayerName in allKeys) 
    {
        NSString *UrlVal = [self.BaseMapLayersDic valueForKey:LayerName];
        NSString *OrgUrlVal = [self.OrgBaseMapLayersDic valueForKey:LayerName];
        if ([UrlVal isEqualToString:OrgUrlVal]) {
            nCnt++;
            continue;
        }
        [LayerNames addObject:LayerName];
        NSString *strIndex = [NSString stringWithFormat:@"%d", nCnt];
        [LayerIndex addObject:strIndex];
        nCnt++;
    }
    
    [self.Delegate ConfMapViewWithNameArray:LayerNames andWithIndexArray:LayerIndex andWithType:0];
    
//    if([self isMovingFromParentViewController])
//    {
//
//    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    int nCnt = [self.OrgBaseMapLayersDic count];
    return nCnt;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

// 返回标题
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section 
{
    NSString *Title = [[self.BaseMapLayersDic allKeys] objectAtIndex:section];
    return Title;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSInteger nSection = indexPath.section;
    // Configure the cell...
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        // 
        UITextView *TextView  = [[UITextView alloc] initWithFrame:CGRectMake(3, 5, 270, 65)];
        TextView.tag = 100;
        [TextView setDelegate:self];
        [TextView setFont:[UIFont systemFontOfSize:13.5f]];
        [TextView setBackgroundColor:[UIColor clearColor]];
        [cell.contentView addSubview:TextView ];
        [TextView release];
        
    }
    UITextView *TextView  = (UITextView *)[cell.contentView viewWithTag:100];
    NSString *Url = [[self.BaseMapLayersDic allValues] objectAtIndex:nSection];
    [TextView setText:Url];
    
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
}

#pragma mark - UITextViewDelegate
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    NSString *text = textView.text;
    NSInteger tag = textView.tag;
    if (tag == 100) {
        // 地图
        NSString *key = [[self.BaseMapLayersDic allKeys] objectAtIndex:0];
        [self.BaseMapLayersDic setValue:text forKey:key];
    }
    else if (tag == 110){
        // 影像
        NSString *key = [[self.BaseMapLayersDic allKeys] objectAtIndex:1];
        [self.BaseMapLayersDic setValue:text forKey:key];
    }
    return;
}
@end
