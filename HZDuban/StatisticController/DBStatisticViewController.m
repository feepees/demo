//
//  DBStatisticViewController.m
//  HZDuban
//
//  Created by sunz on 13-1-6.
//
//

#import "DBStatisticViewController.h"
#import "DBBarChartViewController.h"
#import "DBPieChartViewController.h"
#import "DBLineChartViewController.h"
#import "DBLine2ChartViewController.h"

@interface DBStatisticViewController ()

@end

@implementation DBStatisticViewController

#pragma mark - ViewLifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
//    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleBordered target:self action:@selector(BackBtnClick:)] autorelease];
    ////
    CGFloat xPos = 0;
    CGFloat yPos = 0;
    CGFloat fWidth = 1024.0;
    CGFloat fHeight = 768.0;
    MyTableView = [[UITableView alloc]initWithFrame:CGRectMake(xPos, yPos + 44, fWidth, fHeight - 44 - 20)];
    MyTableView.delegate = self;
    MyTableView.dataSource = self;
    [self.view addSubview:MyTableView];
    [MyTableView release];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 44)];
    imageView.image = [UIImage imageNamed:@"TopBarBackground.png"];
    [self.view addSubview:imageView];
    [imageView release];
    UIButton *prePageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [prePageBtn addTarget:self action:@selector(BackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    UIImage * ImageData = [UIImage imageNamed:@"DBBackBtn.png"];
    [prePageBtn setBackgroundImage:ImageData forState:UIControlStateNormal];
    [prePageBtn setFrame:CGRectMake(5, 6, 32, 32)];
    [self.view addSubview:prePageBtn];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(412, 0, 200, 40)];
    titleLabel.font = [UIFont systemFontOfSize:25];
    titleLabel.textColor = [UIColor cyanColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textAlignment = UITextAlignmentCenter;
    titleLabel.text = @"统计分析";
    [self.view addSubview:titleLabel];
    [titleLabel release];
//    UIView *BackView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 50)];
//    // 上一页按钮
//    UIButton *prePageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [prePageBtn addTarget:self action:@selector(BackBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    UIImage * ImageData = [UIImage imageNamed:@"BackButton.png"];
//    [prePageBtn setBackgroundImage:ImageData forState:UIControlStateNormal];
//    [prePageBtn setFrame:CGRectMake(0, 6, 70, 36)];
//    [prePageBtn setTitle:@"返回" forState:UIControlStateNormal];
//    [prePageBtn setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
//    [BackView addSubview:prePageBtn];
//    self.navigationItem.leftBarButtonItem.customView = BackView;
//    [BackView release];
//    BackView = nil;
    ////
    
    //self.title = @"统计分析图查看列表";
    
//    [MyTableView setBackgroundColor:[UIColor clearColor]];
//    MyTableView.separatorColor = [UIColor clearColor];
    
    strTitleArr = [[NSArray alloc] initWithObjects:@"近4年土地违法案件柱状统计图", @"已查出的土地利用违法类别构成饼图", @"批准建设项目用地趋势图", @"各区县违法用地情况曲线图", nil];
    
//    NSString *strImageName = [NSString stringWithFormat:@"TableViewBackground.jpg"];
//    UIImageView * _image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:strImageName]];
//    [MyTableView setBackgroundView:_image];
//    [_image release];
    UIButton *Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    MyTableView.tableFooterView = Btn;
    MyTableView.tableFooterView.hidden = YES;
    
    
//    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.243 green:0.18 blue:0.063 alpha:0];
    

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if((UIInterfaceOrientationLandscapeLeft == interfaceOrientation) || (UIInterfaceOrientationLandscapeRight == interfaceOrientation))
    {
        return YES;
    }
    return NO;
}

- (void)dealloc
{
    [strTitleArr release];
//    [MyTableView release];
    //[MyNavigationBar release];
    [super dealloc];
}


#pragma mark - UIButton Responsder
- (void)BackBtnClick:(id)sender {
    [self dismissViewControllerAnimated:NO completion:NULL];
    //    [self dismissModalViewControllerAnimated:NO];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [strTitleArr count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int nRow = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell...
    cell.textLabel.text = [strTitleArr objectAtIndex:nRow];
    //    if(nRow == 0)
    //    {
    //        // 默认选择详情项
    //        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    //        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition: UITableViewScrollPositionNone];
    //    }
    
    NSString *strImageName = [NSString stringWithFormat:@"border1.png"];
    UIImageView * _image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:strImageName]];
    [cell setBackgroundView:_image];
    [_image release];
    
    //cell.backgroundColor = [UIColor clearColor];
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
    int nRow = [indexPath row];
    
    if(nRow == 0)
    {
        // 柱图
        DBBarChartViewController * BarChartViewContrl = [[[DBBarChartViewController alloc] init] autorelease];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 40)];
        titleLabel.font = [UIFont systemFontOfSize:25];
        titleLabel.textColor = [UIColor cyanColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.text = [strTitleArr objectAtIndex:nRow];
        BarChartViewContrl.navigationItem.titleView = titleLabel;
        [titleLabel release];
        UINavigationController *nav;
        nav = [[[UINavigationController alloc] initWithRootViewController:BarChartViewContrl] autorelease];
        assert(nav != nil);
//        [self presentModalViewController:nav animated:NO];
        [self presentViewController:nav animated:NO completion:NULL];
    }
    else if(nRow == 1)
    {
        // 饼图
        DBPieChartViewController * PieChartViewContrl = [[[DBPieChartViewController alloc] init] autorelease];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 40)];
        titleLabel.font = [UIFont systemFontOfSize:25];
        titleLabel.textColor = [UIColor cyanColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.text = [strTitleArr objectAtIndex:nRow];
        PieChartViewContrl.navigationItem.titleView = titleLabel;
        [titleLabel release];
        
        UINavigationController *nav;
        nav = [[[UINavigationController alloc] initWithRootViewController:PieChartViewContrl] autorelease];
        assert(nav != nil);
//        [self presentModalViewController:nav animated:NO];
        [self presentViewController:nav animated:NO completion:NULL];
    }
    else if(nRow == 2)
         {
        // 点线图
        DBLineChartViewController * LineChartViewContrl = [[[DBLineChartViewController alloc] init] autorelease];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 40)];
        titleLabel.font = [UIFont systemFontOfSize:25];
        titleLabel.textColor = [UIColor cyanColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.text = [strTitleArr objectAtIndex:nRow];
        LineChartViewContrl.navigationItem.titleView = titleLabel;
        [titleLabel release];
        UINavigationController *nav;
        nav = [[[UINavigationController alloc] initWithRootViewController:LineChartViewContrl] autorelease];
        assert(nav != nil);
//        [self presentModalViewController:nav animated:NO];
        [self presentViewController:nav animated:NO completion:NULL];
    }
    else
    {
        // 折线图
        DBLine2ChartViewController * Line2ChartViewContrl = [[[DBLine2ChartViewController alloc] init] autorelease];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 500, 40)];
        titleLabel.font = [UIFont systemFontOfSize:25];
        titleLabel.textColor = [UIColor cyanColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textAlignment = UITextAlignmentCenter;
        titleLabel.text = [strTitleArr objectAtIndex:nRow];
        Line2ChartViewContrl.navigationItem.titleView = titleLabel;
        [titleLabel release];
        UINavigationController *nav;
        nav = [[[UINavigationController alloc] initWithRootViewController:Line2ChartViewContrl] autorelease];
        assert(nav != nil);
//        [self presentModalViewController:nav animated:NO];
        [self presentViewController:nav animated:NO completion:NULL];
        
    }
    
    return;
}


@end
