//
//  DBXCGeometryNameViewController.m
//  HZDuban
//
//  Created by sunz on 13-7-9.
//
//

#import "DBXCGeometryNameViewController.h"


@interface DBXCGeometryNameViewController ()
{
    BOOL bIsEditFlag;
    UIButton *LeftBtn;
    UIButton *RightBtn;
}

@property (nonatomic, retain) UITableView *NoteTableView;

@property (nonatomic, retain) UITextField *NameTextField;
@property (nonatomic, retain) UITextView *NoteTextView;

@end

@implementation DBXCGeometryNameViewController
@synthesize NoteTableView;
@synthesize delegate;
@synthesize NoteTextView;
@synthesize NameTextField;


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

- (void)DBXCGeometryNameViewAppear:(NSString *)GeometryName GeometryMemo:(NSString*)GeometryMemo
{
    if ([GeometryName length] == 0) {
        bIsEditFlag = YES;
        [LeftBtn setTitle:@"保存" forState:UIControlStateNormal];
        [RightBtn setTitle:@"取消" forState:UIControlStateNormal];
    }else {
        bIsEditFlag = NO;
        [LeftBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [RightBtn setTitle:@"删除" forState:UIControlStateNormal];
    }
    [NoteTableView reloadData];
}

- (void)saveGeometryName
{
    NSString *name = [NameTextField text];
    if (name == nil || [name isEqualToString:@""]) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"" message:@"名称不能为空" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
        return;
    }
    NSString *memo = [NoteTextView text];
    [delegate AddGeometry:name Memo:memo];
}

- (void)AddCancel
{
    [self CancelFirstResponder];
    [delegate AddGeometryCancel];
}

- (void)LeftBtnClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"保存"]) {
        [self saveGeometryName];
    }else if ([button.titleLabel.text isEqualToString:@"编辑"]) {
        [LeftBtn setTitle:@"保存" forState:UIControlStateNormal];
        [RightBtn setTitle:@"取消" forState:UIControlStateNormal];
        bIsEditFlag = YES;
        [NoteTableView reloadData];
    }
}

- (void)RightBtnClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"取消"]) {
        [self AddCancel];
    }
}

//键盘消失
- (void)CancelFirstResponder
{
    if ([NameTextField isFirstResponder]) {
        [NameTextField resignFirstResponder];
    }
    if ([NoteTextView isFirstResponder]) {
        [NoteTextView resignFirstResponder];
    }
}

#pragma mark - View lifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    bIsEditFlag = YES;
    NameTextField.enabled = NO;
    NoteTextView.editable = NO;
    
    
    LeftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    LeftBtn.frame = CGRectMake(10, 8, 50, 28);
    [LeftBtn setBackgroundImage:[UIImage imageNamed:@"BlackButton.png"] forState:UIControlStateNormal];
    LeftBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [LeftBtn addTarget:self action:@selector(LeftBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:LeftBtn];
    
    RightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    RightBtn.frame = CGRectMake(240, 8, 50, 28);
    [RightBtn setBackgroundImage:[UIImage imageNamed:@"BlackButton.png"] forState:UIControlStateNormal];
    RightBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [RightBtn addTarget:self action:@selector(RightBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:RightBtn];
//    
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 80, 25)];
//    label.backgroundColor = [UIColor clearColor];
//    label.text = @"采集界限名称";
//    label.font = [UIFont systemFontOfSize:20];
//    [self.view addSubview:label];
//    [label release];
    
    self.view.backgroundColor = [UIColor colorWithRed:225.0 / 255.0 green:228.0 / 255.0 blue:233.0 / 255.0 alpha:1.0];
    self.NoteTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 35, 300.0, 144.0) style:UITableViewStyleGrouped];
    NoteTableView.delegate = self;
    NoteTableView.dataSource = self;
    NoteTableView.scrollEnabled = NO;
    [self.view addSubview:NoteTableView];
    [NoteTableView release];
    
    self.title = @"采集界限";
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
    self.NoteTableView = nil;
    self.NameTextField = nil;
    self.NoteTextView = nil;
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        UILabel *NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 30, 20)];
        NameLabel.backgroundColor = [UIColor clearColor];
        NameLabel.tag = 100;
        NameLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:NameLabel];
        [NameLabel release];
        
        if(indexPath.row == 0){
            UITextField *TextField = [[UITextField alloc] initWithFrame:CGRectMake(40, 5, 237, 30)];
            TextField.backgroundColor = [UIColor whiteColor];
            TextField.tag = 101;
            TextField.enabled = NO;
            TextField.font = [UIFont systemFontOfSize:15];
            [cell.contentView addSubview:TextField];
            [TextField release];
        }else if (indexPath.row == 1) {
            UITextView *TextView = [[UITextView alloc] init];
            TextView.editable = NO;
            TextView.font = [UIFont systemFontOfSize:15];
            TextView.tag = 102;
            TextView.frame = CGRectMake(40, 5, 237, 70);
            [cell.contentView addSubview:TextView];
            [TextView release];
        }
    }
    UILabel *NameLabel = (UILabel *)[cell.contentView viewWithTag:100];
    if (indexPath.row == 0) {
        NameLabel.text = @"名称";
    }else if (indexPath.row == 1) {
        NameLabel.text = @"备注";
    }
    if (indexPath.row == 0) {
        NameTextField = (UITextField *)[cell.contentView viewWithTag:101];
    }else {
        NoteTextView = (UITextView *)[cell.contentView viewWithTag:102];
    }
    
    if (bIsEditFlag) {
        NameTextField.enabled = YES;
        NoteTextView.editable = YES;
    }else {
        NameTextField.enabled = NO;
        NoteTextView.editable = NO;
    }
    
    return cell;
}

- (void) viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.NameTextField.text = nil;
    self.NoteTextView.text = nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 40;
    }
    
    return 80;
}
@end
