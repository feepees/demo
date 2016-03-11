//
//  DBMarkNoteViewController.m
//  HZDuban
//
//  Created by mac on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBMarkNoteViewController.h"
#import "DBLocalTileDataManager.h"
#import "DBMarkData.h"
#import "DDXML.h"
#import "DDXMLElementAdditions.h"

@interface DBMarkNoteViewController ()
{
    BOOL bIsEditFlag;
    UIButton *LeftBtn;
    UIButton *RightBtn;
}

@property (nonatomic, retain) DBLocalTileDataManager *DataMan;
@property (nonatomic, retain) UITableView *MarkNoteTableView;
//@property (nonatomic, retain) DBAGSGraphic *MarkInfoGraphic;
@property (nonatomic, retain) DBMarkData *MarkData;
@property (nonatomic, retain) UITextField *NameTextField;
@property (nonatomic, retain) UITextView *NoteTextView;

@end

@implementation DBMarkNoteViewController
@synthesize DataMan;
@synthesize MarkNoteTableView;
@synthesize delegate;
@synthesize NoteTextView;
@synthesize NameTextField;
//@synthesize MarkInfoGraphic;
@synthesize MarkData;

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

- (void)MarkNoteViewWillAppearByGraphicID:(NSString *)GraphicID andWithCancelFalg:(NSInteger)CancelFalg 
{
    //取消的标志位，如果是从配置文件中读取出来的数据flag=100，如果是用户添加到图层的大头针flag=101.
    flag = CancelFalg;
    if ([[[DataMan.MarkDic objectForKey:GraphicID] MarkName] length] == 0) {
        bIsEditFlag = YES;
        [LeftBtn setTitle:@"保存" forState:UIControlStateNormal];
        [RightBtn setTitle:@"取消" forState:UIControlStateNormal];
    }else {
        bIsEditFlag = NO;
        [LeftBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [RightBtn setTitle:@"删除" forState:UIControlStateNormal];
    }
    self.MarkData = [DataMan.MarkDic objectForKey:GraphicID];
    [MarkNoteTableView reloadData];
}

- (void)saveMarkData
{
    if (NameTextField.text.length == 0) {
        [DataMan CreateFailedAlertViewWithFailedInfo:@"标注名称不能为空,请重新输入" andWithMessage:nil];
        return;
    }else {
        [self CancelFirstResponder];
        MarkData.MarkName = NameTextField.text;
        MarkData.MarkNote = NoteTextView.text;
        [DataMan.MarkDic setValue:MarkData forKey:MarkData.MarkID];
        
        // 检测本地是否有配置文件
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        // 本地本地配置信息文件
        NSString *FilePath = [documentsDirectory stringByAppendingPathComponent:@"DBMarkInfo.xml"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:FilePath];
        if (!bRet) {
            // 本地无此文件，则将此文件拷贝到本地目录。
            NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBMarkInfo" ofType:@"xml"];
            NSError *err;
            [fileMgr copyItemAtPath:xmlFilePath toPath:FilePath error:&err];
        }
        NSData *data = [[NSData alloc] initWithContentsOfFile:FilePath];
        DDXMLDocument *MarkDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
        NSArray *MarkArray = [MarkDocument nodesForXPath:@"//XML/MarkList/Mark" error:nil];
        int nCount = MarkArray.count;
        int i = 0;
        for (DDXMLElement *obj in MarkArray) 
        {
            DDXMLElement *eleVal = [obj elementForName:@"MarkID"];
            if ([eleVal.stringValue isEqual:MarkData.MarkID]) 
            {
                i++;
                // 标注名称
                eleVal = [obj elementForName:@"MarkName"];
                eleVal.stringValue = NameTextField.text;
                // 标注备注
                eleVal = [obj elementForName:@"MarkNote"];
                eleVal.stringValue = NoteTextView.text;                  
            }
        }
       
        if (i == 0) {
            NSArray *MarkArray = [MarkDocument nodesForXPath:@"//XML/MarkList" error:nil];
            for (DDXMLElement *MarkList in MarkArray) {
                //向XML文件中写入一个Mark。
                DDXMLElement *obj = [[DDXMLElement alloc] initWithName:@"Mark"];
                DDXMLNode *node = [DDXMLNode elementWithName:@"MarkID" stringValue:MarkData.MarkID];
                [obj addChild:node];
                node = [DDXMLNode elementWithName:@"MarkName" stringValue:MarkData.MarkName];
                [obj addChild:node];
                node = [DDXMLNode elementWithName:@"MarkNote" stringValue:MarkData.MarkNote];
                [obj addChild:node];
                node = [DDXMLNode elementWithName:@"MarkSpatialReferenceWKID" stringValue:MarkData.MarkSpatialReferenceWKID];
                [obj addChild:node];
                node = [DDXMLNode elementWithName:@"MarkSpatialReferenceWKT" stringValue:MarkData.MarkSpatialReferenceWKT];
                [obj addChild:node];
                //node = [DDXMLNode elementWithName:@"MarkCoordinateX" stringValue:[NSString stringWithFormat:@"%lf", MarkData.Point.x]];
                node = [DDXMLNode elementWithName:@"MarkCoordinateX" stringValue:[NSString stringWithFormat:@"%lf", MarkData.MarkCoordinateX.doubleValue]];
                [obj addChild:node];
                //node = [DDXMLNode elementWithName:@"MarkCoordinateY" stringValue:[NSString stringWithFormat:@"%lf", MarkData.Point.y]];
                node = [DDXMLNode elementWithName:@"MarkCoordinateY" stringValue:[NSString stringWithFormat:@"%lf", MarkData.MarkCoordinateY.doubleValue]];
                [obj addChild:node];
                [MarkList insertChild:obj atIndex:nCount];
                [obj release];
            }
        }
        
        NSData *data2 = [MarkDocument XMLData];
        [MarkDocument release];
        [data2 writeToFile:FilePath atomically:NO]; 
    }
    [delegate SaveMark];
}

- (void)cancelMarkData
{
    [self CancelFirstResponder];
    [delegate CancelMarkWithFlag:flag andWithMarkID:MarkData.MarkID];
}

- (void)deleteMarkData
{
    [DataMan.MarkDic removeObjectForKey:MarkData.MarkID];
    // 检测本地是否有配置文件
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    // 本地本地配置信息文件
    NSString *FilePath = [documentsDirectory stringByAppendingPathComponent:@"DBMarkInfo.xml"];
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    BOOL bRet = [fileMgr fileExistsAtPath:FilePath];
    if (!bRet) {
        // 本地无此文件，则将此文件拷贝到本地目录。
        NSString *xmlFilePath = [[NSBundle mainBundle] pathForResource:@"DBMarkInfo" ofType:@"xml"];
        NSError *err;
        [fileMgr copyItemAtPath:xmlFilePath toPath:FilePath error:&err];
    }
    NSData *data = [[NSData alloc] initWithContentsOfFile:FilePath];
    DDXMLDocument *MarkDocument = [[DDXMLDocument alloc] initWithData:data options:0 error:nil];
    NSArray *MarkArray = [MarkDocument nodesForXPath:@"//XML/MarkList/Mark" error:nil];
    for (int i = 0; i < MarkArray.count; i++) {
        DDXMLElement *obj = [MarkArray objectAtIndex:i];
        DDXMLElement *eleVal = [obj elementForName:@"MarkID"];
        if ([eleVal.stringValue isEqual:MarkData.MarkID]) 
        {
            //删除XML中的一个Mark
            NSArray *MarkArray = [MarkDocument nodesForXPath:@"//XML/MarkList" error:nil];
            for (DDXMLElement *MarkList in MarkArray) {
                [MarkList removeChildAtIndex:i];
            }
            break;
        }
    }
        
    NSData *data2 = [MarkDocument XMLData];
    [MarkDocument release];
    [data2 writeToFile:FilePath atomically:NO];
    [delegate DeleteMark:MarkData.MarkID];
}

- (void)LeftBtnClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"保存"]) {
        [self saveMarkData];
    }else if ([button.titleLabel.text isEqualToString:@"编辑"]) {
        [LeftBtn setTitle:@"保存" forState:UIControlStateNormal];
        [RightBtn setTitle:@"取消" forState:UIControlStateNormal];
        bIsEditFlag = YES;
        [MarkNoteTableView reloadData];
    }
}

- (void)RightBtnClicked:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if ([button.titleLabel.text isEqualToString:@"取消"]) {
        [self cancelMarkData];
    }else if ([button.titleLabel.text isEqualToString:@"删除"]) {
        [self deleteMarkData];
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
    
    DataMan = [DBLocalTileDataManager instance];
    
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
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(128, 10, 44, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.text = @"标注";
    label.font = [UIFont systemFontOfSize:20];
    [self.view addSubview:label];
    [label release];

    self.view.backgroundColor = [UIColor colorWithRed:225.0 / 255.0 green:228.0 / 255.0 blue:233.0 / 255.0 alpha:1.0];
    self.MarkNoteTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 300.0, 144.0) style:UITableViewStyleGrouped];
    MarkNoteTableView.delegate = self;
    MarkNoteTableView.dataSource = self;
    MarkNoteTableView.scrollEnabled = NO;
    //[self.view addSubview:MarkNoteTableView];
    [self.view insertSubview:MarkNoteTableView atIndex:0];
    [MarkNoteTableView release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)dealloc
{
    self.MarkNoteTableView = nil;
    self.NameTextField = nil;
    self.NoteTextView = nil;
    self.MarkData = nil;
    
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
    
    if(indexPath.row == 0){
        NameTextField.text = MarkData.MarkName;
    }else if (indexPath.row == 1) {
        NoteTextView.text = MarkData.MarkNote;
    }
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return 40;
    }
    
    return 80;
}

@end
