//
//  DBApproveDocViewController.m
//  HZDuban
//
//  Created by sunz on 12-12-21.
//
//

#import "DBApproveDocViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "DDXML.h"
#import "DDXMLElementAdditions.h"
#import "Logger.h"

#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject]

@interface DBApproveDocViewController ()

@end

@implementation DBApproveDocViewController
@synthesize DocUnit;
@synthesize DocTitle;
@synthesize DocNum;
@synthesize DocYearNum;
@synthesize DocContent;
@synthesize DocID;
@synthesize searchStr;
@synthesize DocIndexPath;
@synthesize processOpinion;
@synthesize processName;
@synthesize processDate;
@synthesize circulatedOpinion;
@synthesize circulatedName;
@synthesize circulatedDate;
@synthesize SearchResultArr;
@synthesize ModelTableViewCtrl;
@synthesize ModelPopoverViewCtrl;
@synthesize SendPopoverViewCtrl;
@synthesize SendTableViewCtrl;

#pragma mark - view LifeCycle
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
	
    //键盘相关事件
    bIsKeybordShown = NO;
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown2:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide2:) name:UIKeyboardDidHideNotification object:nil];
    
    //背景图片
    UIImageView *AD_BgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768 - 20)];
    AD_BgImageView.image = [UIImage imageNamed:@"AD_BgImage.jpg"];
    [self.view addSubview:AD_BgImageView];
    [AD_BgImageView release];
    
    bIsCloseDoc = NO;
    self.SearchResultArr = [NSMutableArray arrayWithCapacity:0];
    
    //leftTitleLabel
    leftTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, 270, 30)];
    leftTitleLabel.tag = 600;
    leftTitleLabel.font = [UIFont systemFontOfSize:16];
    leftTitleLabel.backgroundColor = [UIColor clearColor];
    leftTitleLabel.text = @"文件搜索";
    leftTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:leftTitleLabel];
    [leftTitleLabel release];
    UIButton *BackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    BackBtn.frame = CGRectMake(30, 18, 50, 22);
    [BackBtn setImage:[UIImage imageNamed:@"AD_Back.png"] forState:UIControlStateNormal];
    [BackBtn addTarget:self action:@selector(BackBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:BackBtn];
    leftTitleSearchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftTitleSearchBtn.frame = CGRectMake(240, 18, 50, 22);
    [leftTitleSearchBtn setImage:[UIImage imageNamed:@"AD_Search.png"] forState:UIControlStateNormal];
    [leftTitleSearchBtn addTarget:self action:@selector(leftTitleSearchBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftTitleSearchBtn];
    leftTitleSearchBtn.hidden = YES;

    //搜索条件
    NSArray *array = [NSArray arrayWithObjects:@"来文单位:", @"文件标题:", @"收文编号:", @"收文年号:", @"内容摘要:", @"文件编号:", nil];
    for (int i = 0; i < 6; i++) {
        UILabel *Label0 = [[UILabel alloc] initWithFrame:CGRectMake(20, 70 + i * 40, 75, 21)];
        Label0.tag = 400 + i;
        Label0.backgroundColor = [UIColor clearColor];
        Label0.font = [UIFont systemFontOfSize:15];
        Label0.text = [array objectAtIndex:i];
        [self.view addSubview:Label0];
        [Label0 release];
        
        UITextField *TextField0 = [[UITextField alloc] initWithFrame:CGRectMake(95, 70 + i * 40, 140, 25)];
        TextField0.tag = 500 + i;
        TextField0.background = [UIImage imageNamed:@"AD_SearchViewTextFieldBgImage.png"];
        TextField0.delegate = self;
        [self.view addSubview:TextField0];
        [TextField0 release];
    }
    UIButton *resetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    resetBtn.frame = CGRectMake(50, 330, 65, 30);
    resetBtn.tag = 510;
    [resetBtn setImage:[UIImage imageNamed:@"AD_Reset.png"] forState:UIControlStateNormal];
    [resetBtn addTarget:self action:@selector(resetBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:resetBtn];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(180, 330, 65, 30);
    searchBtn.tag = 511;
    [searchBtn setImage:[UIImage imageNamed:@"AD_Search.png"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(searchBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    
    //rightTitleView
    UIImageView *rightTitleView = [[UIImageView alloc] initWithFrame:CGRectMake(340, 20, 1024 - 330 - 5 - 50, 100)];
    rightTitleView.image = [UIImage imageNamed:@"AD_RightTitleViewBgImage.png"];
    [self.view addSubview:rightTitleView];
    [rightTitleView release];
    
    UILabel *rightTitleLabel0 = [[UILabel alloc] initWithFrame:CGRectMake(20 + 340, 25 + 20, 75, 21)];
    rightTitleLabel0.backgroundColor = [UIColor clearColor];
    rightTitleLabel0.font = [UIFont systemFontOfSize:15];
    rightTitleLabel0.textColor = [UIColor redColor];
    rightTitleLabel0.text = @"来文单位:";
    [self.view addSubview:rightTitleLabel0];
    [rightTitleLabel0 release];
    unitLabel = [[UILabel alloc] initWithFrame:CGRectMake(95 + 340, 25 + 20, 435, 21)];
    unitLabel.tag = 601;
    unitLabel.backgroundColor = [UIColor clearColor];
    unitLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AD_UnitLabelBgImage.jpg"]];
    unitLabel.font = [UIFont systemFontOfSize:15];
    unitLabel.text = nil;
    [self.view addSubview:unitLabel];
    [unitLabel release];
    UILabel *rightTitleLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(20 + 340, 55 + 20, 75, 21)];
    rightTitleLabel1.backgroundColor = [UIColor clearColor];
    rightTitleLabel1.font = [UIFont systemFontOfSize:15];
    rightTitleLabel1.textColor = [UIColor redColor];
    rightTitleLabel1.text = @"标      题 :";
    [self.view addSubview:rightTitleLabel1];
    [rightTitleLabel1 release];
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(95 + 340, 55 + 20, 435, 21)];
    titleLabel.tag = 602;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AD_UnitLabelBgImage.jpg"]];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.text = nil;
    [self.view addSubview:titleLabel];
    [titleLabel release];
    
    UIButton *DocContentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    DocContentBtn.frame = CGRectMake(520 + 340 + 20, 50 + 20, 80, 25);
    [DocContentBtn setImage:[UIImage imageNamed:@"AD_ViewDoc.png"] forState:UIControlStateNormal];
    [DocContentBtn addTarget:self action:@selector(DocContentBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:DocContentBtn];
    
    //DocDetailView
    DocDetailView = [[UITableView alloc] initWithFrame:CGRectMake(307, 120, 1024 - 320, 768 - 130 - 20 - 5 - 7 - 10) style:UITableViewStyleGrouped];
    DocDetailView.tag = 603;
    DocDetailView.backgroundColor = [UIColor clearColor];
    DocDetailView.backgroundView = nil;
    DocDetailView.layer.cornerRadius = 4;
    DocDetailView.layer.masksToBounds = YES;
    DocDetailView.delegate = self;
    DocDetailView.dataSource = self;
    [self.view addSubview:DocDetailView];
    [DocDetailView release];
    
    //popover
    self.ModelTableViewCtrl = [[ModelTableViewController alloc] init];
    ModelTableViewCtrl.ModelTableViewDelegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self.ModelTableViewCtrl];
    ModelPopoverViewCtrl = [[UIPopoverController alloc] initWithContentViewController:nav];
    [nav release];
    ModelPopoverViewCtrl.popoverContentSize = CGSizeMake(320, 400);
    [ModelTableViewCtrl release];
    self.SendTableViewCtrl = [[SendTableViewController alloc] init];
    SendTableViewCtrl.SendTableViewDelegate = self;
    UINavigationController *nav2 = [[UINavigationController alloc] initWithRootViewController:self.SendTableViewCtrl];
    nav2.title = @"处理意见模版";
    SendPopoverViewCtrl = [[UIPopoverController alloc] initWithContentViewController:nav2];
    [nav2 release];
    SendPopoverViewCtrl.popoverContentSize = CGSizeMake(320, 400);
    [SendTableViewCtrl release];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

//NSNotification Responder
//- (void)keyboardShown2:(NSNotification *)aNotification
//{
//
//
//}

- (void)keyboardHide2:(NSNotification *)aNotification
{
    bIsKeybordShown = NO;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.1];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    DocDetailView.frame = CGRectMake(307, 120, 1024 - 320, 768 - 130 - 20 - 5 - 7 - 10);
    [UIView commitAnimations];
}

- (void)dealloc
{
    self.DocUnit = nil;
    self.DocTitle = nil;
    self.DocNum = nil;
    self.DocYearNum = nil;
    self.DocContent = nil;
    self.DocID = nil;
    self.searchStr = nil;
    self.DocIndexPath = nil;
    self.processOpinion = nil;
    self.processName = nil;
    self.processDate = nil;
    self.circulatedOpinion = nil;
    self.circulatedName = nil;
    self.circulatedDate = nil;
    self.SearchResultArr = nil;
    self.ModelTableViewCtrl = nil;
    self.ModelPopoverViewCtrl = nil;
    self.SendPopoverViewCtrl = nil;
    self.SendTableViewCtrl = nil;
    [previewCtrl release];
    
    [super dealloc];
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

#pragma mark - UIButtonResponder Method
- (IBAction)BackBtnTouch:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)resetBtnTouched:(id)sender
{
    for (UIView *view in self.view.subviews) {
        if (view.tag >= 500 && view.tag <= 505) {
            //搜索条件UITextField
            UITextField *textField = (UITextField *)view;
            textField.text = nil;
            self.DocUnit = nil;
            self.DocTitle = nil;
            self.DocNum = nil;
            self.DocYearNum = nil;
            self.DocContent = nil;
            self.DocID = nil;
        }
    }
}

- (void)leftTitleSearchBtnTouched:(id)sender
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDidStopSelector:@selector(leftTitleSearchBtnAnimationStopped)];
    DocListView.frame = CGRectMake(-320, 45, 320, 768 - 210 - 20 - 5 + 200 - 45 + 10);
    [UIView commitAnimations];
}

- (void)leftTitleSearchBtnAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    leftTitleSearchBtn.hidden = YES;
    leftTitleLabel.text = @"文件搜索";
    for (UIView *view in [self.view subviews]) {
        if (view.tag != 0 && view.tag < 600){
            view.hidden = NO;
        }
    }
    if (self.DocIndexPath != nil) {
        UITableViewCell *cell = [DocListView cellForRowAtIndexPath:self.DocIndexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
        imageView.image = [UIImage imageNamed:@"AD_SearchCellBgImage.png"];
        cell.backgroundView = imageView;
        [imageView release];
        for (UIView *view in [cell.contentView subviews]) {
            if (view.tag == 104) {
                UIButton *button = (UIButton *)view;
                [button setImage:[UIImage imageNamed:@"AD_BtnImage.png"] forState:UIControlStateNormal];
            }
        }
    }
    [UIView commitAnimations];
}

- (void)searchBtnTouched:(id)sender
{
    if (DocListView == nil) {
        //DocListView
        DocListView = [[UITableView alloc] initWithFrame:CGRectMake(-320, 47, 280, 768 - 210 - 20 - 5 + 200 - 45 + 10 - 20) style:UITableViewStylePlain];
        UIButton *Btn = [UIButton buttonWithType:UIButtonTypeCustom];
        DocListView.tableFooterView = Btn;
        DocListView.tableFooterView.hidden = YES;
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-320, 47, 280, 768 - 210 - 20 - 5 + 200 - 45 + 10 - 20)];
        imageView.image = [UIImage imageNamed:@"AD_DocListViewBgImage.png"];
        DocListView.backgroundView = imageView;
        [imageView release];
//        DocListView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AD_DocListViewBgImage.png"]];
//        DocListView.backgroundColor = [UIColor clearColor];
//        DocListView.backgroundView = nil;
//        DocListView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AD_SeparateLine.jpg"]];
        DocListView.layer.cornerRadius = 4;
        DocListView.layer.masksToBounds = YES;
        DocListView.delegate = self;
        DocListView.dataSource = self;
        [self.view addSubview:DocListView];
        [DocListView release];
    }else {
        [DocListView reloadData];
    }
    leftTitleSearchBtn.hidden = NO;
    leftTitleLabel.text = @"搜索结果";
    for (UIView *view in [self.view subviews]) {
         if (view.tag != 0 && view.tag < 600){
            view.hidden = YES;
        }
    }

    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    DocListView.frame = CGRectMake(12, 47, 260, 768 - 210 - 20 - 5 + 200 - 45 + 10 - 20 - 7);
    [UIView commitAnimations];

    [self.SearchResultArr removeAllObjects];

    [self.SearchResultArr addObject:@"1"];
    [DocListView reloadData];
}

- (void)DocContentBtnTouched:(id)sender
{
    UIButton *button = (UIButton *)sender;
    //NSString *BookName = @"FileTest.docx";
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    //NSString *FileFullPath = [DocumentsDirectory stringByAppendingPathComponent:BookName];
    NSString *FileFullPath1 = [[NSBundle mainBundle] bundlePath];
    NSString *FileFullPath = [NSString stringWithFormat:@"%@/FileTest.png",FileFullPath1];
    BOOL bRet = [fileMgr fileExistsAtPath:FileFullPath];
    if (bRet) {
        if (previewCtrl == nil) {
            previewCtrl = [[QLPreviewController alloc] init];
            previewCtrl.dataSource = self;
//            previewCtrl.view.frame = CGRectMake(330, 90, 1024 - 330 - 5, 768 - 20 - 90 - 5);
            previewCtrl.view.frame = CGRectMake(340, 120, 1024 - 340 - 5 - 7 - 30 - 5, 768 - 130 - 20 - 5 - 7 - 10);
            previewCtrl.view.layer.cornerRadius = 4;
            previewCtrl.view.layer.masksToBounds = YES;
        }
        if (bIsCloseDoc) {
            [previewCtrl.view removeFromSuperview];            
            [button setImage:[UIImage imageNamed:@"AD_ViewDoc"] forState:UIControlStateNormal];
        }else{
            [self.view addSubview:previewCtrl.view];
            [button setImage:[UIImage imageNamed:@"AD_Close.png"] forState:UIControlStateNormal];
        }
        bIsCloseDoc = !bIsCloseDoc;
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"没有文件" message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        [alert release];
    }
}

- (void)modelBtnTouched:(id)sender
{
    UIButton *button = (UIButton *)sender;
    float fWidth = 400.0f;
    float fHeight = 500.0f;
    float fXpos = 1024 - fWidth - 30;
    float fYpos = 748 / 2 - fHeight / 2;
    CGRect frame2 = CGRectMake(fXpos, fYpos, fWidth, fHeight);
    //1为处理意见 4为传阅意见
    DocSection = button.tag - 105;
    ModelTableViewCtrl.type = DocSection;
    [ModelPopoverViewCtrl presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
}

- (void)saveBtnTouched:(id)sender
{
    //1为处理意见 4为传阅意见
    UIButton *button = (UIButton *)sender;
    if (button.tag - 106 == 1) {
        
    }else if (button.tag - 106 == 4){
        
    }
}

- (void)sendBtnTouched:(id)sender
{
    //1为处理意见 4为传阅意见
    UIButton *button = (UIButton *)sender;
    float fWidth = 400.0f;
    float fHeight = 500.0f;
    float fXpos = 1024 - fWidth - 30;
    float fYpos = 748 / 2 - fHeight / 2;
    CGRect frame2 = CGRectMake(fXpos, fYpos, fWidth, fHeight);
    
    [SendPopoverViewCtrl presentPopoverFromRect:frame2 inView:self.view permittedArrowDirections:0 animated:YES];
    if (button.tag - 107 == 1) {
        
    }else if (button.tag - 107 == 4){
        
    }
}

#pragma mark - ModelTableViewDelegate Method
- (void)CancelBtnTouched
{
    if ([ModelPopoverViewCtrl isPopoverVisible]) {
        [ModelPopoverViewCtrl dismissPopoverAnimated:YES];
    }
}

- (void)OkeyBtnTouched
{
    if (DocSection == 0) {
        self.circulatedOpinion = @"传阅意见";
    }else if (DocSection == 1){
        self.processOpinion = @"处理意见";
    }
    [DocDetailView reloadData];
    if ([ModelPopoverViewCtrl isPopoverVisible]) {
        [ModelPopoverViewCtrl dismissPopoverAnimated:YES];
    }
}

- (void)ModelCellDidSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (DocSection == 1) {
        self.processOpinion = @"处理意见";
    }else if (DocSection == 4){
        self.circulatedOpinion = @"传阅意见";
    }
    [DocDetailView reloadData];
    if ([ModelPopoverViewCtrl isPopoverVisible]) {
        [ModelPopoverViewCtrl dismissPopoverAnimated:YES];
    }
    
}

#pragma mark - SendTableViewControllerDelegate Method
- (void)SendViewCancelBtnTouched
{
    //1为处理意见 4为传阅意见
    if (DocSection == 1) {
        
    }else if (DocSection == 4){
        
    }
    if ([SendPopoverViewCtrl isPopoverVisible]) {
        [SendPopoverViewCtrl dismissPopoverAnimated:NO];
    }
}

- (void)OkeyBtnTouchedWithArray:(NSArray *)array
{
    //1为处理意见 4为传阅意见
    if (DocSection == 1) {
        
    }else if (DocSection == 4){
        
    }
    if ([SendPopoverViewCtrl isPopoverVisible]) {
        [SendPopoverViewCtrl dismissPopoverAnimated:NO];
    }
}

#pragma mark - UITableViewDelegate Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == DocListView) {
        return 1;
    }else if (tableView == DocDetailView){
        return 5;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == DocListView) {
        if (self.SearchResultArr.count ==  0) {
            return 1;
        }else{
            return 7;
        }
    }else if (tableView == DocDetailView){
        if (section == 3) {
            return 4;
        }else{
         return 1;
        }
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == DocListView) {
        if (self.SearchResultArr.count == 0) {
            return 40;
        }else{
            return 70;
        }
    }else if (tableView == DocDetailView){
        switch (indexPath.section) {
            case 0:
                return 80;
                break;
            case 1:
                return 160;
                break;
            case 2:
                return 80;
                break;
            case 3:
                return 80;
                break;
            case 4:
                return 160;
                break;
            default:
                return 0;
                break;
        }
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == DocListView) {
        return 0;
    }else if (tableView == DocDetailView){
        return 40;
    }
    return 40;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    if (tableView == DocListView) {
//        return nil;
//    }else if (tableView == DocDetailView){
//        switch (section) {
//            case 0:
//                return @"拟办意见";
//                break;
//            case 1:
//                return @"处理意见";
//                break;
//            case 2:
//                return @"领导批示";
//                break;
//            case 3:
//                return @"处理结果";
//                break;
//            case 4:
//                return @"传阅意见";
//                break;
//            default:
//                return nil;
//                break;
//        }
//    }
//    return nil;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView == DocListView) {
        return nil;
    }else if (tableView == DocDetailView){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 155, 30)];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 10, 125, 30)];
        imageView.image = [UIImage imageNamed:@"AD_CellSectionView.png"];
        [view addSubview:imageView];
        [imageView release];
        UILabel *Label = [[UILabel alloc] initWithFrame:CGRectMake(75, 8, 110, 30)];
        Label.backgroundColor = [UIColor clearColor];
        Label.font = [UIFont boldSystemFontOfSize:15];
        Label.textColor = [UIColor brownColor];
        switch (section) {
            case 0:
                Label.text = @"拟办意见:";
                break;
            case 1:
                Label.text = @"处理意见:";
                break;
            case 2:
                Label.text = @"领导批示:";
                break;
            case 3:
                Label.text = @"处理结果:";
                break;
            case 4:
                Label.text = @"传阅意见:";
                break;
            default:
                break;
        }
        [view addSubview:Label];
        [Label release];
        return [view autorelease];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == DocListView) {
        if (self.SearchResultArr.count == 0) {
            static NSString *cellID = @"cellID0";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            cell.userInteractionEnabled = NO;
            cell.textLabel.text = @"无搜索结果";
            
            return cell;
        }else{
            NSString *CellID = @"CellId";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:cell.frame];
                backgroundView.image = [UIImage imageNamed:@"AD_SearchCellBgImage.png"];
                cell.backgroundView = backgroundView;
                [backgroundView release];
                
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 5.0, 270.0, 32.0)];
                nameLabel.tag = 101;
                nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.numberOfLines = 0;
                nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                [cell.contentView addSubview:nameLabel];
                [nameLabel release];
                
                UILabel *docUnitLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 42.0, 180.0, 20.0)];
                docUnitLabel.tag = 102;
                docUnitLabel.font = [UIFont systemFontOfSize:13.0];
                docUnitLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:docUnitLabel];
                [docUnitLabel release];
                
                UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(207.0 - 20, 42.0, 75.0, 20.0)];
                timeLabel.tag = 103;
                timeLabel.font = [UIFont systemFontOfSize:13.0];
                timeLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:timeLabel];
                [timeLabel release];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(227, 20, 20, 20);
                button.tag = 104;
                [button setImage:[UIImage imageNamed:@"AD_BtnImage.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:button];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 66, cell.frame.size.width - 50 - 3, 4)];
                imageView.tag = 105;
                [cell.contentView addSubview:imageView];
                [imageView release];
            }
            UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
            nameLabel.text = @"惠州市建委、惠州市财政局文件";
            UILabel *docUnitLabel = (UILabel *)[cell viewWithTag:102];
            docUnitLabel.text = @"惠州市建委、惠州市财政局";
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:103];
            timeLabel.text = @"2012.11.14";
            UIButton *button = (UIButton *)[cell viewWithTag:104];
            button.userInteractionEnabled = NO;
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:105];
            imageView.image = [UIImage imageNamed:@"AD_SeparateLine.jpg"];
            
            return cell;
        }
    }else if (tableView == DocDetailView){
        if (indexPath.section == 0) {
            static NSString *CellIdentifier = @"Cell0";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIImageView *cellBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AD_CellBgImage.png"]];
                cell.backgroundView = cellBgView;
                [cellBgView release];
                UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, 5, 540, 45)];
                contentTextView.tag = 100;
                contentTextView.editable = NO;
                contentTextView.backgroundColor = [UIColor clearColor];
                contentTextView.font = [UIFont systemFontOfSize:16];
                [cell.contentView addSubview:contentTextView];
                [contentTextView release];
                
                UILabel *UserLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 54, 50, 20)];
                UserLabel.tag = 101;
                UserLabel.backgroundColor = [UIColor clearColor];
                UserLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:UserLabel];
                [UserLabel release];
                
                UILabel *NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 54, 60, 20)];
                NameLabel.tag = 102;
                NameLabel.backgroundColor = [UIColor clearColor];
                NameLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:NameLabel];
                [NameLabel release];
                
                UILabel *DateLabel = [[UILabel alloc] initWithFrame:CGRectMake(470, 54, 40, 20)];
                DateLabel.tag = 103;
                DateLabel.backgroundColor = [UIColor clearColor];
                DateLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:DateLabel];
                [DateLabel release];
                
                UILabel *DateContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(510, 54, 80, 20)];
                DateContentLabel.tag = 104;
                DateContentLabel.backgroundColor = [UIColor clearColor];
                DateContentLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:DateContentLabel];
                [DateContentLabel release];
//                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 76, 615, 4)];
//                imageView.tag = 105;
//                [cell.contentView addSubview:imageView];
//                [imageView release];
            }
            UITextView *contentTextView = (UITextView *)[cell viewWithTag:100];
            contentTextView.text = @"拟办意见是收文单位文秘部门对所收到的文件提出的送负责人批示或者交有关部门办理的意见。拟办意见是收文单位文秘部门对所收到的文件提出的送负责人批示或者交有关部门办理的意见。";
            
            UILabel *UserLabel = (UILabel *)[cell viewWithTag:101];
            UserLabel.text = @"拟办人:";
            
            UILabel *NameLabel = (UILabel *)[cell viewWithTag:102];
            NameLabel.text = @"张三";
            
            UILabel *DateLabel = (UILabel *)[cell viewWithTag:103];
            DateLabel.text = @"日期:";
            UILabel *DateContentLabel = (UILabel *)[cell viewWithTag:104];
            DateContentLabel.text = @"2012.12.13";
//            UIImageView *imageView = (UIImageView *)[cell viewWithTag:105];
//            imageView.image = [UIImage imageNamed:@"AD_DocDetailSeparateLine.jpg"];
            
            return cell;
        }
        else if (indexPath.section == 1){
            static NSString *CellIdentifier = @"Cell1";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIImageView *cellBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AD_CellBgImage.png"]];
                cell.backgroundView = cellBgView;
                [cellBgView release];
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, 440, 100)];
                textView.tag = 201;
                textView.contentSize = CGSizeMake(440, 100);
                textView.scrollEnabled = NO;
                textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AD_TextViewBgImage.png"]];
                textView.layer.cornerRadius = 4;
                textView.layer.masksToBounds = YES;
                textView.layer.borderWidth = 0.5;
                [cell.contentView addSubview:textView];
                [textView release];
                
                UILabel *UserLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 130, 57, 21)];
                UserLabel.tag = 101;
                UserLabel.backgroundColor = [UIColor clearColor];
                UserLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:UserLabel];
                [UserLabel release];
                
                UITextField *NameTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 130, 130, 22)];
                NameTextField.tag = 301;
                NameTextField.background = [UIImage imageNamed:@"AD_TransactorTextFieldBgImage.png"];
                [cell.contentView addSubview:NameTextField];
                [NameTextField release];
                
                UILabel *DateLabel = [[UILabel alloc] initWithFrame:CGRectMake(470, 130, 40, 20)];
                DateLabel.tag = 103;
                DateLabel.backgroundColor = [UIColor clearColor];
                DateLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:DateLabel];
                [DateLabel release];

//                UILabel *DateContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(510, 130, 80, 20)];
//                DateContentLabel.tag = 104;
//                DateContentLabel.backgroundColor = [UIColor clearColor];
//                DateContentLabel.font = [UIFont systemFontOfSize:15];
//                [cell.contentView addSubview:DateContentLabel];
//                [DateContentLabel release];
                
                UITextField *DateTextField = [[UITextField alloc] initWithFrame:CGRectMake(510, 130, 100, 20)];
                DateTextField.tag = 302;
                DateTextField.font = [UIFont systemFontOfSize:15];
                DateTextField.placeholder = @"如:2012.01.01";
                DateTextField.background = [UIImage imageNamed:@"AD_TransactorTextFieldBgImage.png"];
                [cell.contentView addSubview:DateTextField];
                [DateTextField release];
                
                
                UIButton *modelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                modelBtn.tag = 106;
                modelBtn.frame = CGRectMake(470, 25, 60, 20);
                [modelBtn setImage:[UIImage imageNamed:@"AD_Model.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:modelBtn];
                
                UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                saveBtn.tag = 107;
                saveBtn.frame = CGRectMake(470, 59, 60, 20);
                [saveBtn setImage:[UIImage imageNamed:@"AD_Save.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:saveBtn];
                
                UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                sendBtn.tag = 108;
                sendBtn.frame = CGRectMake(470, 92, 60, 20);
                [sendBtn setImage:[UIImage imageNamed:@"AD_Send.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:sendBtn];
                
//                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 156, 615, 4)];
//                imageView.tag = 130;
//                [cell.contentView addSubview:imageView];
//                [imageView release];
            }
            UITextView *textView = (UITextView *)[cell viewWithTag:201];
            textView.delegate = self;
            
            UILabel *UserLabel = (UILabel *)[cell viewWithTag:101];
            UserLabel.text = @"办理人:";
            textView.text = processOpinion;
           
            
            UITextField *NameTextField = (UITextField *)[cell viewWithTag:301];
            NameTextField.delegate = self;
            NameTextField.text = processName;
            
            UILabel *DateLabel = (UILabel *)[cell viewWithTag:103];
            DateLabel.text = @"日期:";
            
//            UILabel *DateContentLabel = (UILabel *)[cell viewWithTag:104];
//            NSDate * date = [NSDate date];
//            NSTimeZone *zone = [NSTimeZone systemTimeZone];
//            NSInteger interval = [zone secondsFromGMTForDate:date];
//            NSDate *localeDate = [date dateByAddingTimeInterval:interval];
//            DateContentLabel.text = [[localeDate description] substringToIndex:10];;
            
            UITextField *DateTextField = (UITextField *)[cell viewWithTag:302];
            DateTextField.delegate = self;
            DateTextField.text = processDate;
            
            UIButton *modelBtn = (UIButton *)[cell viewWithTag:106];
            [modelBtn addTarget:self action:@selector(modelBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            UIButton *saveBtn = (UIButton *)[cell viewWithTag:107];
            [saveBtn addTarget:self action:@selector(saveBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            UIButton *sendBtn = (UIButton *)[cell viewWithTag:108];
            [sendBtn addTarget:self action:@selector(sendBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
//            UIImageView *imageView = (UIImageView *)[cell viewWithTag:130];
//            imageView.image = [UIImage imageNamed:@"AD_DocDetailSeparateLine.jpg"];
            
            return cell;
        }
        else if (indexPath.section == 2){
            static NSString *CellIdentifier = @"Cell2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIImageView *cellBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AD_CellBgImage.png"]];
                cell.backgroundView = cellBgView;
                [cellBgView release];
                UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, 5, 520, 45)];
                contentTextView.tag = 100;
                contentTextView.editable = NO;
                contentTextView.backgroundColor = [UIColor clearColor];
                contentTextView.font = [UIFont systemFontOfSize:16];
                [cell.contentView addSubview:contentTextView];
                [contentTextView release];
                
                UILabel *UserLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 54, 65, 20)];
                UserLabel.tag = 101;
                UserLabel.backgroundColor = [UIColor clearColor];
                UserLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:UserLabel];
                [UserLabel release];
                
                UILabel *NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 54, 60, 20)];
                NameLabel.tag = 102;
                NameLabel.backgroundColor = [UIColor clearColor];
                NameLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:NameLabel];
                [NameLabel release];
                
                UILabel *DateLabel = [[UILabel alloc] initWithFrame:CGRectMake(470, 54, 40, 20)];
                DateLabel.tag = 103;
                DateLabel.backgroundColor = [UIColor clearColor];
                DateLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:DateLabel];
                [DateLabel release];
                
                UILabel *DateContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(510, 54, 80, 20)];
                DateContentLabel.tag = 104;
                DateContentLabel.backgroundColor = [UIColor clearColor];
                DateContentLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:DateContentLabel];
                [DateContentLabel release];
                
//                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 76, 615, 4)];
//                imageView.tag = 105;
//                [cell.contentView addSubview:imageView];
//                [imageView release];
            }
            UITextView *contentTextView = (UITextView *)[cell viewWithTag:100];
            contentTextView.text = @"领导批示是收文单位负责人就收文的性质，根据拟办意见签署的意见，";
            
            UILabel *UserLabel = (UILabel *)[cell viewWithTag:101];
            UserLabel.text = @"领导签字:";
            
            UILabel *NameLabel = (UILabel *)[cell viewWithTag:102];
            NameLabel.text = @"李四";
            
            UILabel *DateLabel = (UILabel *)[cell viewWithTag:103];
            DateLabel.text = @"日期:";
            UILabel *DateContentLabel = (UILabel *)[cell viewWithTag:104];
            DateContentLabel.text = @"2012.12.14";
//            UIImageView *imageView = (UIImageView *)[cell viewWithTag:105];
//            imageView.image = [UIImage imageNamed:@"AD_DocDetailSeparateLine.jpg"];
            
            return cell;
        }
        else if (indexPath.section == 3){
            if (indexPath.row == 0) {
                static NSString *CellIdentifier = @"Cell30";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UIImage *CellBgImage = [UIImage imageNamed:@"AD_CellBgImage.png"];
                    UIImageView *cellBgView = [[UIImageView alloc] initWithImage:CellBgImage];
                    cell.backgroundView = cellBgView;
                    [cellBgView release];
                    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, 5, 520, 45)];
                    contentTextView.tag = 100;
                    contentTextView.editable = NO;
                    contentTextView.backgroundColor = [UIColor clearColor];
                    contentTextView.font = [UIFont systemFontOfSize:16];
                    [cell.contentView addSubview:contentTextView];
                    [contentTextView release];
                    
                    UILabel *UserLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 54, 65, 20)];
                    UserLabel.tag = 101;
                    UserLabel.backgroundColor = [UIColor clearColor];
                    UserLabel.font = [UIFont systemFontOfSize:15];
                    [cell.contentView addSubview:UserLabel];
                    [UserLabel release];
                    
                    UILabel *NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 54, 60, 20)];
                    NameLabel.tag = 102;
                    NameLabel.backgroundColor = [UIColor clearColor];
                    NameLabel.font = [UIFont systemFontOfSize:15];
                    [cell.contentView addSubview:NameLabel];
                    [NameLabel release];
                    
                    UILabel *DateLabel = [[UILabel alloc] initWithFrame:CGRectMake(470, 54, 40, 20)];
                    DateLabel.tag = 103;
                    DateLabel.backgroundColor = [UIColor clearColor];
                    DateLabel.font = [UIFont systemFontOfSize:15];
                    [cell.contentView addSubview:DateLabel];
                    [DateLabel release];
                    
                    UILabel *DateContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(510, 54, 80, 20)];
                    DateContentLabel.tag = 104;
                    DateContentLabel.backgroundColor = [UIColor clearColor];
                    DateContentLabel.font = [UIFont systemFontOfSize:15];
                    [cell.contentView addSubview:DateContentLabel];
                    [DateContentLabel release];
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 76, 615, 4)];
                    imageView.tag = 105;
                    [cell.contentView addSubview:imageView];
                    [imageView release];
                }
                UITextView *contentTextView = (UITextView *)[cell viewWithTag:100];
                contentTextView.text = @"请王宏伟全力配合";
                
                UILabel *UserLabel = (UILabel *)[cell viewWithTag:101];
                UserLabel.text = @"签字:";
                
                UILabel *NameLabel = (UILabel *)[cell viewWithTag:102];
                NameLabel.text = @"李四";
                
                UILabel *DateLabel = (UILabel *)[cell viewWithTag:103];
                DateLabel.text = @"日期:";
                UILabel *DateContentLabel = (UILabel *)[cell viewWithTag:104];
                DateContentLabel.text = @"2012.12.14";
                UIImageView *imageView = (UIImageView *)[cell viewWithTag:105];
                imageView.image = [UIImage imageNamed:@"AD_DocDetailSeparateLine.jpg"];
                
                return cell;
            }else{
                static NSString *CellIdentifier = @"Cell3";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
                if (cell == nil) {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UIImage *CellBgImage = [UIImage imageNamed:@"AD_CellBgImage2.png"];
                    UIImageView *cellBgView = [[UIImageView alloc] initWithImage:CellBgImage];
                    cell.backgroundView = cellBgView;
                    [cellBgView release];
                    UITextView *contentTextView = [[UITextView alloc] initWithFrame:CGRectMake(50, 5, 520, 45)];
                    contentTextView.tag = 100;
                    contentTextView.editable = NO;
                    contentTextView.backgroundColor = [UIColor clearColor];
                    contentTextView.font = [UIFont systemFontOfSize:16];
                    [cell.contentView addSubview:contentTextView];
                    [contentTextView release];
                    
                    UILabel *UserLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 54, 65, 20)];
                    UserLabel.tag = 101;
                    UserLabel.backgroundColor = [UIColor clearColor];
                    UserLabel.font = [UIFont systemFontOfSize:15];
                    [cell.contentView addSubview:UserLabel];
                    [UserLabel release];
                    
                    UILabel *NameLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 54, 60, 20)];
                    NameLabel.tag = 102;
                    NameLabel.backgroundColor = [UIColor clearColor];
                    NameLabel.font = [UIFont systemFontOfSize:15];
                    [cell.contentView addSubview:NameLabel];
                    [NameLabel release];
                    
                    UILabel *DateLabel = [[UILabel alloc] initWithFrame:CGRectMake(470, 54, 40, 20)];
                    DateLabel.tag = 103;
                    DateLabel.backgroundColor = [UIColor clearColor];
                    DateLabel.font = [UIFont systemFontOfSize:15];
                    [cell.contentView addSubview:DateLabel];
                    [DateLabel release];
                    
                    UILabel *DateContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(510, 54, 80, 20)];
                    DateContentLabel.tag = 104;
                    DateContentLabel.backgroundColor = [UIColor clearColor];
                    DateContentLabel.font = [UIFont systemFontOfSize:15];
                    [cell.contentView addSubview:DateContentLabel];
                    [DateContentLabel release];
                    
                    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 76, 615, 4)];
                    imageView.tag = 105;
                    [cell.contentView addSubview:imageView];
                    [imageView release];
                }
                UITextView *contentTextView = (UITextView *)[cell viewWithTag:100];
                contentTextView.text = @"请王宏伟全力配合";
                
                UILabel *UserLabel = (UILabel *)[cell viewWithTag:101];
                UserLabel.text = @"签字:";
                
                UILabel *NameLabel = (UILabel *)[cell viewWithTag:102];
                NameLabel.text = @"李四";
                
                UILabel *DateLabel = (UILabel *)[cell viewWithTag:103];
                DateLabel.text = @"日期:";
                UILabel *DateContentLabel = (UILabel *)[cell viewWithTag:104];
                DateContentLabel.text = @"2012.12.14";
                UIImageView *imageView = (UIImageView *)[cell viewWithTag:105];
                imageView.image = [UIImage imageNamed:@"AD_DocDetailSeparateLine.jpg"];
                if (indexPath.row == 3) {
                    imageView.hidden = YES;
                }else{
                    imageView.hidden = NO;
                }
                
                return cell;
            }
        }
        else if (indexPath.section == 4){
            static NSString *CellIdentifier = @"Cell4";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *cellBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AD_CellBgImage.png"]];
                cell.backgroundView = cellBgView;
                [cellBgView release];
                UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20, 20, 440, 100)];
                textView.tag = 204;
                textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AD_TextViewBgImage.png"]];
                textView.layer.cornerRadius = 4;
                textView.layer.masksToBounds = YES;
                textView.layer.borderWidth = 0.5;
                [cell.contentView addSubview:textView];
                [textView release];
                
                UILabel *UserLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 130, 57, 21)];
                UserLabel.tag = 101;
                UserLabel.backgroundColor = [UIColor clearColor];
                UserLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:UserLabel];
                [UserLabel release];
                
                UITextField *NameTextField = [[UITextField alloc] initWithFrame:CGRectMake(80, 130, 130, 22)];
                NameTextField.tag = 304;
                NameTextField.background = [UIImage imageNamed:@"AD_TransactorTextFieldBgImage.png"];
                [cell.contentView addSubview:NameTextField];
                [NameTextField release];
                
                UILabel *DateLabel = [[UILabel alloc] initWithFrame:CGRectMake(470, 130, 40, 20)];
                DateLabel.tag = 103;
                DateLabel.backgroundColor = [UIColor clearColor];
                DateLabel.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:DateLabel];
                [DateLabel release];
                
//                UILabel *DateContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(510, 130, 80, 20)];
//                DateContentLabel.tag = 104;
//                DateContentLabel.backgroundColor = [UIColor clearColor];
//                DateContentLabel.font = [UIFont systemFontOfSize:15];
//                [cell.contentView addSubview:DateContentLabel];
//                [DateContentLabel release];
                UITextField *DateTextField = [[UITextField alloc] initWithFrame:CGRectMake(510, 130, 100, 20)];
                DateTextField.tag = 305;
                DateTextField.font = [UIFont systemFontOfSize:15];
                DateTextField.placeholder = @"如:2012.01.01";
                DateTextField.background = [UIImage imageNamed:@"AD_TransactorTextFieldBgImage.png"];
                [cell.contentView addSubview:DateTextField];
                [DateTextField release];
                
                UIButton *modelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                modelBtn.tag = 109;
                modelBtn.frame = CGRectMake(470, 25, 60, 20);
                [modelBtn setImage:[UIImage imageNamed:@"AD_Model.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:modelBtn];
                
                UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                saveBtn.tag = 110;
                saveBtn.frame = CGRectMake(470, 59, 60, 20);
                [saveBtn setImage:[UIImage imageNamed:@"AD_Save.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:saveBtn];
                
                UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                sendBtn.tag = 111;
                sendBtn.frame = CGRectMake(470, 92, 60, 20);
                [sendBtn setImage:[UIImage imageNamed:@"AD_Send.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:sendBtn];
                
                //                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 156, 615, 4)];
                //                imageView.tag = 130;
                //                [cell.contentView addSubview:imageView];
                //                [imageView release];
            }
            UITextView *textView = (UITextView *)[cell viewWithTag:204];
            textView.delegate = self;
            
            UILabel *UserLabel = (UILabel *)[cell viewWithTag:101];
            UserLabel.text = @"传阅人:";
            textView.text = circulatedOpinion;

            
            UITextField *NameTextField = (UITextField *)[cell viewWithTag:304];
            NameTextField.delegate = self;
            NameTextField.text = circulatedName;
            
            UILabel *DateLabel = (UILabel *)[cell viewWithTag:103];
            DateLabel.text = @"日期:";
            
//            UILabel *DateContentLabel = (UILabel *)[cell viewWithTag:104];
//            NSDate * date = [NSDate date];
//            NSTimeZone *zone = [NSTimeZone systemTimeZone];
//            NSInteger interval = [zone secondsFromGMTForDate:date];
//            NSDate *localeDate = [date dateByAddingTimeInterval:interval];
//            DateContentLabel.text = [[localeDate description] substringToIndex:10];
            UITextField *DateTextField = (UITextField *)[cell viewWithTag:305];
            DateTextField.delegate = self;
            DateTextField.text = circulatedDate;
            
            UIButton *modelBtn = (UIButton *)[cell viewWithTag:109];
            [modelBtn addTarget:self action:@selector(modelBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            UIButton *saveBtn = (UIButton *)[cell viewWithTag:110];
            [saveBtn addTarget:self action:@selector(saveBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            UIButton *sendBtn = (UIButton *)[cell viewWithTag:111];
            [sendBtn addTarget:self action:@selector(sendBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            //            UIImageView *imageView = (UIImageView *)[cell viewWithTag:130];
            //            imageView.image = [UIImage imageNamed:@"AD_DocDetailSeparateLine.jpg"];
            
            return cell;
        }
    }
    static NSString *cellID = @"cellID5";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = @"无搜索结果";
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == DocListView) {
        self.DocIndexPath = indexPath;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
        imageView.image = [UIImage imageNamed:@"AD_SearchCellBgImage2.png"];
        cell.backgroundView = imageView;
        [imageView release];
        for (UIView *view in [cell.contentView subviews]) {
            if (view.tag == 104) {
                //cell中的Button
                UIButton *button = (UIButton *)view;
                [button setImage:[UIImage imageNamed:@"AD_BtnImage2.png"] forState:UIControlStateNormal];
            }
        }
        unitLabel.text = @"市建委";
        titleLabel.text = @"关于旧城改造的文件";
        self.processOpinion = nil;
        self.processName = nil;
        self.processDate = nil;
        self.circulatedOpinion = nil;
        self.circulatedName = nil;
        self.circulatedDate = nil;
        [DocDetailView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == DocListView) {
        self.DocIndexPath = nil;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.frame];
        imageView.image = [UIImage imageNamed:@"AD_SearchCellBgImage.png"];
        cell.backgroundView = imageView;
        [imageView release];
        for (UIView *view in [cell.contentView subviews]) {
            if (view.tag == 104) {
                UIButton *button = (UIButton *)view;
                [button setImage:[UIImage imageNamed:@"AD_BtnImage.png"] forState:UIControlStateNormal];
            }
        }
    }
}

#pragma mark - QLPreviewControllerDataSource Methods
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller
{
    return 1;
}

- (id <QLPreviewItem>)previewController:(QLPreviewController *)controller previewItemAtIndex:(NSInteger)index
{
    NSString *FileFullPath = [[NSBundle mainBundle] pathForResource:@"FileTest" ofType:@"png"];
    return [NSURL fileURLWithPath:FileFullPath];
    //NSString *BookName = @"FileTest.docx";
    //NSString *FileFullPath = [self GetKnowledgeFileFullPath:BookName];
    //return [NSURL fileURLWithPath:FileFullPath];
}

//得到文件路径
-(NSString*)GetKnowledgeFileFullPath:(NSString*)FileName
{
    @try {
        // 文件存放目录
        NSString *pngDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        NSError *err;
        [fileMgr createDirectoryAtPath:pngDir withIntermediateDirectories:YES attributes:nil error:&err];
        NSString *FileFullPath = [pngDir stringByAppendingPathComponent:FileName];
        
        return FileFullPath;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
        return nil;
    }
    @finally {
        
    }
    
}

#pragma mark - UITextFieldDelegate Method
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    if (textField.tag == 302 || textField.tag == 305) {
        //日期
        textField.keyboardType = UIKeyboardTypeASCIICapable;
    }else if (textField.tag == 502 || textField.tag == 503 || textField.tag == 505){
        //收文编号 收文年号 文件编号
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }else{
        textField.keyboardType = UIKeyboardTypeNamePhonePad;
    }
    
    return YES;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    switch (textField.tag - 500) {
        case 0:
            if (self.DocUnit == nil) {
                self.DocUnit = string;
            }else{
                self.DocUnit = [self.DocUnit stringByAppendingString:string];
            }
            break;
        case 1:
            if (self.DocTitle == nil) {
                self.DocTitle = string;
            }else{
                self.DocTitle = [self.DocUnit stringByAppendingString:string];
            }
            break;
        case 2:
            if (self.DocNum == nil) {
                self.DocNum = string;
            }else{
                self.DocNum = [self.DocUnit stringByAppendingString:string];
            }
            break;
        case 3:
            if (self.DocYearNum == nil) {
                self.DocYearNum = string;
            }else{
                self.DocYearNum = [self.DocUnit stringByAppendingString:string];
            }
            break;
        case 4:
            if (self.DocContent == nil) {
                self.DocContent = string;
            }else{
                self.DocContent = [self.DocUnit stringByAppendingString:string];
            }
            break;
        case 5:
            if (self.DocID == nil) {
                self.DocID = string;
            }else{
                self.DocID = [self.DocUnit stringByAppendingString:string];
            }
            break;
        default:
            break;
    }
    if (textField.tag == 301) {
        if (self.processName == nil) {
            self.processName = string;
        }else{
            self.processName = [self.processName stringByAppendingString:string];
        }
    }else if (textField.tag == 302){
        if (self.processDate == nil) {
            self.processDate = string;
        }else{
            self.processDate = [self.processDate stringByAppendingString:string];
        }
    }else if (textField.tag == 304){
        if (self.circulatedName == nil) {
            self.circulatedName = string;
        }else{
            self.circulatedName = [self.circulatedName stringByAppendingString:string];
        }
    }else if (textField.tag == 305){
        if (self.circulatedDate == nil) {
            self.circulatedDate = string;
        }else{
            self.circulatedDate = [self.circulatedDate stringByAppendingString:string];
        }
    }
        
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag == 301 || textField.tag == 304 || textField.tag == 302 || textField.tag == 305) {
        //处理意见
        if (!bIsKeybordShown) {
            DocDetailView.frame = CGRectMake(307, 120, 1024 - 320, 768 - 130 - 20 - 5 - 7 - 10 - 340);
        }
        bIsKeybordShown = YES;
        NSInteger section = textField.tag - 300;
        if (section == 2) {
            //处理意见日期
            section = 1;
        }else if(section == 5){
            //传阅意见日期
            section = 4;
        }
        NSIndexPath *padt = [NSIndexPath indexPathForRow:0 inSection:section];
        [DocDetailView scrollToRowAtIndexPath:padt atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else if(textField.tag >= 500){
        //搜索条件
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 301) {
        //处理意见
    }else if (textField.tag == 302){
        //处理意见日期
    }else if (textField.tag == 304){
        //传阅意见
    }else if (textField.tag == 305){
        //传阅意见日期
    }else if(textField.tag >= 500){
        //搜索条件
    }
    [textField resignFirstResponder];
}

#pragma mark - UITextViewDelegate Method
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.keyboardType = UIKeyboardTypeNamePhonePad;
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    textView.text = [NSString stringWithFormat:@"%@%@", textView.text, text];
    if (textView.contentSize.height > 100) {
        if (text.length != 0) {
            textView.text = [textView.text substringToIndex:[textView.text length] - 1];
        }
        return NO;
    }
    if (text.length != 0) {
        textView.text = [textView.text substringToIndex:[textView.text length] - 1];
    }
    if (textView.tag == 201) {
        if (self.processOpinion == nil) {
            self.processOpinion = text;
        }else{
            self.processOpinion = [self.processOpinion stringByAppendingString:text];
        }
    }else if (textView.tag == 204){
        if (self.circulatedOpinion == nil) {
            self.circulatedOpinion = text;
        }else{
            self.circulatedOpinion = [self.circulatedOpinion stringByAppendingString:text];
        }
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if (!bIsKeybordShown) {
        DocDetailView.frame = CGRectMake(307, 120, 1024 - 320, 768 - 130 - 20 - 5 - 7 - 10 - 340);
    }
    bIsKeybordShown = YES;
    NSIndexPath *padt = [NSIndexPath indexPathForRow:0 inSection:textView.tag - 200];
    [DocDetailView scrollToRowAtIndexPath:padt atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if (textView.tag - 200 == 1) {
        //处理意见
    }else if(textView.tag - 200 == 4){
        //传阅意见
    }
    [textView resignFirstResponder];
}

@end
