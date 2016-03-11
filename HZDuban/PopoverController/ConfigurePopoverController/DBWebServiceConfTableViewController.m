//
//  DBWebServiceConfTableViewController.m
//  HZDuban
//
//  Created by  on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBWebServiceConfTableViewController.h"
#import "DBLocalTileDataManager.h"
#import "Logger.h"

@interface DBWebServiceConfTableViewController ()
{
}
@property (nonatomic, retain) NSURL *TopicWebServiceURL;
@property (nonatomic, retain) NSURL *GisWebServiceURL;
@property (nonatomic, retain) NSURL *AnnexDownloadServiceURL;
@end

@implementation DBWebServiceConfTableViewController

@synthesize TopicWebServiceURL = _TopicWebServiceURL;
@synthesize GisWebServiceURL = _GisWebServiceURL;
@synthesize AnnexDownloadServiceURL = _AnnexDownloadServiceURL;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)dealloc
{
    self.TopicWebServiceURL = nil;
    self.GisWebServiceURL = nil;
    self.AnnexDownloadServiceURL = nil;
    [super dealloc];
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    
    // 议题服务器
    NSString *TopicWebServiceUrl = [DataMan TopicWebServiceUrl];
    //self.TopicWebServiceURL = [NSURL URLWithString:TopicWebServiceUrl];
    self.TopicWebServiceURL = [NSURL URLWithString:[TopicWebServiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

 
    // GIS服务服务器
    NSString *GisWebServiceUrl = [DataMan GISWebServiceUrl];
    //self.GisWebServiceURL = [NSURL URLWithString:GisWebServiceUrl];
    self.GisWebServiceURL = [NSURL URLWithString:[GisWebServiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    
    // 附件服务器
    NSString *AnnexWebServiceUrl = [DataMan AnnexDownloadServiceUrl];
    //self.AnnexDownloadServiceURL = [NSURL URLWithString:AnnexWebServiceUrl];
    self.AnnexDownloadServiceURL = [NSURL URLWithString:[AnnexWebServiceUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];


    [[self tableView] setRowHeight:40];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 2;
}
//- (NSInteger)

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"议题Web服务器";
    }
    else if (section == 1) {
        return @"Gis查询Web服务器";
    }else {
        return @"附件下载服务器";
    }
    
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
    NSInteger nRow = indexPath.row;
    // Configure the cell...
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        // 主机名称/IP、端口号
        UITextField *TextField = [[UITextField alloc] initWithFrame:CGRectMake(3, 7, 280, 30)];
        TextField.tag = 100;//100 + nSection * 10 + nRow;
        [TextField setFont:[UIFont systemFontOfSize:13.5f]];
        [cell.contentView addSubview:TextField];
        [TextField release];

    }
    NSInteger nTag = 100; //100 + nSection * 10 + nRow;
    UITextField *TextField = (UITextField *)[cell.contentView viewWithTag:nTag];
    if (nRow == 0) {
        [TextField setPlaceholder:@"主机名称或IP地址"];
    }
    else {
        [TextField setPlaceholder:@"端口号"];
    }
    
    if (nSection == 0) {
        if (nRow == 0) {
            [TextField setText:[self.TopicWebServiceURL host]];
        }
        else {
            NSNumber *nPort = [self.TopicWebServiceURL port];
            [TextField setText:[nPort stringValue]];
        }
    }
    if (nSection == 1) {
        if (nRow == 0) {
            [TextField setText:[self.GisWebServiceURL host]];
        }
        else {
            NSNumber *nPort = [self.GisWebServiceURL port];
            [TextField setText:[nPort stringValue]];
        }
    }
    if (nSection == 2) {
        if (nRow == 0) {
            [TextField setText:[self.AnnexDownloadServiceURL host]];
        }
        else {
            NSNumber *nPort = [self.AnnexDownloadServiceURL port];
            [TextField setText:[nPort stringValue]];
        }
    }
    return cell;
}

-(NSString*)GetFieldText:(NSInteger)nSection Row:(NSInteger)nRow
{
    NSIndexPath *path = [NSIndexPath indexPathForRow:nRow inSection:nSection];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:path];
    NSInteger nTag = 100; //100 + nSection * 10 + nRow;
    UITextField *TextField = (UITextField *)[cell.contentView viewWithTag:nTag];
    NSString *NewValue = [TextField text];
    return NewValue;
}

-(NSMutableString*)GetNewUrl:(NSInteger)nSection Row:(NSInteger)nRow OldUrl:(NSURL*)OldURL
{
    @try {
        NSMutableString *OldUrlString = [NSMutableString stringWithCapacity:100];
        [OldUrlString appendString:[OldURL absoluteString]];
        // 更新主机
        NSString *NewHost = [self GetFieldText:nSection Row:nRow];
        NSString *OldHost = [OldURL host];
        [OldUrlString replaceOccurrencesOfString:OldHost withString:NewHost options:NSLiteralSearch range:NSMakeRange(0, [OldUrlString length])];
        
        // 更新端口号
        nRow++;
        NSString *NewPort= [self GetFieldText:nSection Row:nRow];
        NSNumber *OldPortNum = [OldURL port];
        NSString *OldPort = [OldPortNum stringValue];
        [OldUrlString replaceOccurrencesOfString:OldPort withString:NewPort options:NSLiteralSearch range:NSMakeRange(0, [OldUrlString length])];
        
        return OldUrlString;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return nil;
    }
    @finally {
        
    }

}

-(void)viewWillDisappear:(BOOL)animated
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    
    //议题服务器
    NSInteger nSection = 0;
    NSInteger nRow = 0;
    NSMutableString *NewUrl = [self GetNewUrl:nSection Row:nRow OldUrl:self.TopicWebServiceURL];
    if (![[DataMan TopicWebServiceUrl] isEqualToString:NewUrl]) {
        [DataMan setTopicWebServiceUrl:NewUrl];
        [DataMan.MeetingList removeAllObjects];
    }
    
    // GIS服务器
    nSection++;
    NewUrl = [self GetNewUrl:nSection Row:nRow OldUrl:self.GisWebServiceURL];
    if (![[DataMan GISWebServiceUrl] isEqualToString:NewUrl]) {
        [DataMan setGISWebServiceUrl:NewUrl];
        [DataMan.POIArray removeAllObjects];
        [DataMan.TopicIDToFeatureDic removeAllObjects];
    }
    
    // 附件下载服务器
    nSection++;
    NewUrl = [self GetNewUrl:nSection Row:nRow OldUrl:self.AnnexDownloadServiceURL];
    if (![[DataMan AnnexDownloadServiceUrl] isEqualToString:NewUrl]) {
        [DataMan setAnnexDownloadServiceUrl:NewUrl];
        [[DataMan TopicsAnnexDic] removeAllObjects];
        [[DataMan TopicsReason] removeAllObjects];
    }
    
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

@end
