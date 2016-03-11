//
//  DBXCDKDetailViewController.m
//  HZDuban
//
//  Created by mac  on 13-6-24.
//
//

#import "DBXCDKDetailViewController.h"
#import "DBTopicDKDataItem.h"
#import "DBTopicAnnexDataItem.h"
#import "DBQueue.h"
#import "Logger.h"
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "ELCAssetTablePicker.h"
#import "NSDate+TKCategory.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "DBJGXCForm.h"
#import "CommHeader.h"
#import "AMProgressView.h"
#import "UIImagePickerController+Rotate.h"
#import "MBProgressHUD.h"
#import "GTMNSString+HTML.h"
#import <MediaPlayer/MediaPlayer.h>
#import <QuickLook/QuickLook.h>
#import "DBPreviewDataSource.h"
//#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "CellUITextField.h"


// 巡察登记表存储目录 
#define XCRecordFileDir [NSString stringWithFormat:@"%@/XCRecordFileDir", DocumentDir]
// 巡察登记表附件存储目录
#define XCRecordAttachmentDir [NSString stringWithFormat:@"%@/XCRecordFileDir", DocumentDir]

#define GEOMETRY_SECTION    6
#define PIC_SECTION     7
#define VIDEO_SECTION   8

#define WIDTH_VIEW      400
#define HEIGTH_VIEW     704

#define IS_BJ_KEY_NAME     @"bIsBaoJianFlag"
#define IS_DG_KEY_NAME     @"bIsDongGongFlag"
#define IS_KF_KEY_NAME     @"bIsKaiFaFlag"
#define IS_JG_KEY_NAME     @"bIsJunGongFlag"

#define XCR_KEY     @"XCR"
#define XC_DATE_KEY     @"XC_Date"
#define SRR_KEY     @"SRR"
#define AREA_KEY     @"Area"
#define ADDRESS_KEY     @"Address"
#define BJQK_REASON_KEY     @"BJQK_Reason"
#define DGQK_REASON_KEY     @"DGQK_Reason"
#define GCGHXKZBH_KEY     @"GCGHXKZBH"
#define KFQK_REASON_KEY     @"KFQK_Reason"

#define KF_PERCENT_KEY     @"KF_Percent"
#define JGYSHGZBH_KEY     @"JGYSHGZBH"
#define JGQK_REASON_KEY     @"JGQK_Reason"

@interface DBXCDKDetailViewController ()
{
    //CloseBtn的图片，默认为CloseViewBtn
    BOOL bDownloadFlg;
    BOOL isShow;
    BOOL isLoading;
    BOOL bIsUploaded;      // 当前巡查监管表的数据是不是从服务器端下载的
    BOOL bIsEditing;       // 是否正在编辑，如果是则提示保存到本地，不是则直接退出
    //议题ID
    NSString *_TopicId;
    //议题所属会议ID
    NSString *_TopicOwnerId;
    NSInteger nDelFileFlg;          //0:不删除任何 1:删除照片  2:删除视频 3:删除界限
    
    NSString *filePath;
}
@property (strong, nonatomic) UIPopoverController *popoverController;
@property (assign, atomic) BOOL bIsUploading;       // 同时只允许一个文件上传
@end

@implementation DBXCDKDetailViewController

@synthesize DBXCDKDataDic = _DBXCDKDataDic;
@synthesize XCRecordImagesArr;
@synthesize XCRecordVideosArr;
@synthesize XCRecordDataDic = _XCRecordDataDic;
@synthesize SourceDic;
@synthesize ChoosePicViewPopover;
@synthesize ChooseDateViewPopover;
@synthesize LandInfoTableView;
@synthesize delegate;
@synthesize DKDataDelegate;
@synthesize bCloseBtnFlg;
@synthesize CurrentXCRecordFileName = _CurrentXCRecordFileName;      // 当前巡察记录文件名称
@synthesize LocalXCRecordFileArr = _LocalXCRecordFileArr;            // 本地所有巡察记录文件的信息
@synthesize netXCRecordFileArr = _netXCRecordFileArr;
@synthesize CurrXCRecordGeometryArr = _CurrXCRecordGeometryArr;
@synthesize imgPicker = _imgPicker;
@synthesize popoverController;
@synthesize bIsUploading = _bIsUploading;

#pragma mark - ViewLifeCycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        nDelFileFlg = 0;
        _nTaskRunningFlg = 0;
        _bIsUploading = NO;
        self.XCRecordDataDic = [NSMutableDictionary dictionaryWithCapacity:3];
        self.XCRecordImagesArr = [NSMutableArray arrayWithCapacity:2];
        self.XCRecordVideosArr = [NSMutableArray arrayWithCapacity:2];
        self.LocalXCRecordFileArr = [NSMutableArray arrayWithCapacity:2];
        self.CurrXCRecordGeometryArr = [NSMutableArray arrayWithCapacity:1];
    }
    return self;
}

-(void)AlertMsg:(NSString*)Title Message:(NSString*)Msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:Title message:Msg delegate:nil cancelButtonTitle:@"确定"otherButtonTitles:nil];
    [alert show];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    @try {
        // Do any additional setup after loading the view from its nib.
        NSString *Id = [_DBXCDKDataDic valueForKey:@"Id"];
        [self LoadLocalXCRecord:Id];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(-3, 0, WIDTH_VIEW, HEIGTH_VIEW)];
        imageView.image = [UIImage imageNamed:@"TableViewBgImage.png"];
        LandInfoTableView.backgroundView = imageView;
        
        DBChoosePicViewController *ChoosePicViewCtrl = [[DBChoosePicViewController alloc] init];
        ChoosePicViewCtrl.delegate = self;
        self.ChoosePicViewPopover = [[UIPopoverController alloc] initWithContentViewController:ChoosePicViewCtrl];
        
        ChoosePicViewPopover.popoverContentSize = CGSizeMake(320.0, 60);
        
        DBChooseDateViewController *ChooseDateViewCtrl = [[DBChooseDateViewController alloc] init];
        ChooseDateViewCtrl.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ChooseDateViewCtrl];
        self.ChooseDateViewPopover = [[UIPopoverController alloc] initWithContentViewController:nav];
        ChooseDateViewPopover.popoverContentSize = CGSizeMake(225.0, 220 + 44);
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

#pragma mark- 注册键盘监听
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardAppeared:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDisappeared:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //移除键盘监听
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)keyboardAppeared:(NSNotification *)notification{
    if (isShow) { //fix bug: if change input of keyboard, would receive the UIKeyboardWillShowNotification again
        return;
    }
    isShow = YES;
    NSDictionary *userInfo = notification.userInfo;
    CGRect frame = TaskTableView.frame;
    frame.size.height -= [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
    TaskTableView.frame = frame;
}

- (void)keyboardDisappeared:(NSNotification *)notification{
    if (!isShow) {
        return;
    }
    isShow = NO;
    NSDictionary *userInfo = notification.userInfo;
    CGRect frame = TaskTableView.frame;
    frame.size.height += [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.width;
    TaskTableView.frame = frame;
}

-(NSString*)GetDate:(NSString*)dInterval
{
    NSTimeInterval dVal = [dInterval doubleValue];
    NSDate *Data2 = [NSDate dateWithTimeIntervalSince1970:dVal];

    NSDateFormatter *DataoutputFormatter = [[NSDateFormatter alloc] init];
    [DataoutputFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    NSString *newDate2String = [DataoutputFormatter stringFromDate:Data2];

    return newDate2String;
}

#pragma mark 加载指定地块的本地巡察记录文件信息列表
-(void)LoadLocalXCRecord:(NSString*)DKId
{
    @try {
        // 清除原数据
        [self.LocalXCRecordFileArr removeAllObjects];
        
        NSFileManager *localFileManager=[NSFileManager defaultManager];
        NSString *FileFullDir = [NSString  stringWithFormat:@"%@/%@", XCRecordFileDir, DKId];
        NSDirectoryEnumerator *dirEnum =
        [localFileManager enumeratorAtPath:FileFullDir];
        
        NSString *file;
        while ((file = [dirEnum nextObject]))
        {
            if ([[file pathExtension] isEqualToString: @"plist"]) {
                NSMutableDictionary *DicTmp = [NSMutableDictionary dictionaryWithCapacity:2];
                NSString *fileName = [file stringByDeletingPathExtension];
                NSArray *parts = [fileName componentsSeparatedByString:@"_"];
                
                // 检查地块ID
                if (![[parts objectAtIndex:0] isEqual:DKId]) {
                    continue;
                }
                
                // 取得巡察时间
                NSString *date = [parts objectAtIndex:1];
                if ([date length] <= 0) {
                    // error
                    [self AlertMsg:@"加载记录失败" Message:@"巡察时间为空"];
                    continue;
                }
                date = [self GetDate:date];
                if ([date length] <= 0) {
                    // error
                    [self AlertMsg:@"加载记录失败" Message:@"巡察人员为空"];
                    continue;
                }
                [DicTmp setObject:date forKey:XC_DATE_KEY];
                
                // 取得巡察人姓名
                NSString *XCR = [parts objectAtIndex:2];
                if ([XCR length] <= 0) {
                    // error
                    continue;
                }
                [DicTmp setObject:XCR forKey:XCR_KEY];
                
                // 巡察记录文件名
                [DicTmp setObject:file forKey:@"XCRecordFileName"];
                [self.LocalXCRecordFileArr addObject:DicTmp];
            }
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

- (void)loadNetXCRecord:(NSString *)DKId
{
    DBLocalTileDataManager *dataManager = [DBLocalTileDataManager instance];
    dataManager.XCDKRecordsDelegate = self;
    if (![dataManager InternetConnectionTest]) {
        [dataManager CreateFailedAlertViewWithFailedInfo:@"网络未联络状态" andWithMessage:@"未能完成下载地块巡察信息"];
        return;
    }
    bIsUploaded = YES;
    [self CleanCachaData];
    [MBProgressHUD showHUDAddedTo:TaskTableView animated:YES];
    [dataManager DownloadXCDKRecords:DKId];
}

- (void)DownloadXCDKRecordsDidFinish:(NSDictionary *)result{
    @try {
        _nTaskRunningFlg = 1;
        self.XCRecordDataDic = [result objectForKey:@"XCRecordData"];
        // 采集界限
        [self.CurrXCRecordGeometryArr setArray:[result objectForKey:@"GeometrysData"]];
        // 图片名称及备注
        [self.XCRecordImagesArr setArray:[result objectForKey:@"PicInfo"]];
        // 视频名称及备注
        [self.XCRecordVideosArr setArray:[result objectForKey:@"VideoInfo"]];
        bIsUploaded = YES;
        [TaskTableView reloadData];
        [MBProgressHUD hideHUDForView:TaskTableView animated:YES];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

- (void)DownloadXCDKRecordsError:(id)result{
    [MBProgressHUD hideHUDForView:TaskTableView animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:LandInfoTableView])
    {
        if (section == 0) {
            return 10;
        }else if(section == 1){
            if (self.LocalXCRecordFileArr.count == 0) {
                return 1;
            }else{
                return self.LocalXCRecordFileArr.count;
            }
        }else if(section == 2){
            if (self.netXCRecordFileArr.count == 0) {
                return 1;
            }else {
                return self.netXCRecordFileArr.count;
            }
        }
    }else if ([tableView isEqual: TaskTableView]) {
        NSInteger num;
        switch (section) {
            case 0:
                num = 3;
                break;
            case 1:
            case 2:
            case 3:
            case 4:
            case 5:
                num = 2;
                break;
            default:
                num = 1;
                break;
        }
        if (section == GEOMETRY_SECTION) {
            num = [self.CurrXCRecordGeometryArr count];
            num = (num == 0)? 1 : num;
        }
        else if (section == PIC_SECTION) {
            if (self.XCRecordImagesArr.count == 0) {
                num = 1;
            }else{
                num = self.XCRecordImagesArr.count;
            }
        }else if (section == VIDEO_SECTION){
            if (self.XCRecordVideosArr.count == 0) {
                num = 1;
            }else{
                num = self.XCRecordVideosArr.count;
            }
        }
        return num;
    }
    return 0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual: LandInfoTableView])
    {
        return 3;
    }else if ([tableView isEqual: TaskTableView]) {
        return 9;
    }
    return 0;
}

#pragma mark 创建Cell

-(void)Section134Common:(UITableViewCell*)cell Section:(NSInteger)nSection
{
    UIButton *FlagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    NSInteger nTag = (nSection + 1) * 100;
    FlagBtn.tag = nTag++;
    FlagBtn.frame = CGRectMake(10, 15, 20, 20);
    [FlagBtn addTarget:self action:@selector(FlagBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [FlagBtn setImage:[UIImage imageNamed:@"ButtonBgImage02.jpg"] forState:UIControlStateSelected];
    [FlagBtn setImage:[UIImage imageNamed:@"ButtonBgImage01.jpg"] forState:UIControlStateNormal];
    [cell.contentView addSubview:FlagBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 15, 30, 20)];
    label.tag = nTag++;
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:16];
    [cell.contentView addSubview:label];
    
    UILabel *contentlabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, 300, 20)];
    contentlabel.tag = nTag++;
    contentlabel.backgroundColor = [UIColor clearColor];
    contentlabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:contentlabel];
    
    CellUITextField *textField = [[CellUITextField alloc] initWithFrame:CGRectMake(260, 15, 120, 25)];
    textField.tag = nTag++;
    textField.adjustsFontSizeToFitWidth = YES;
    textField.background = [UIImage imageNamed:@"TextFieldBgImage.png"];
    textField.font = [UIFont systemFontOfSize:15];
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    [cell.contentView addSubview:textField];

}

- (void)setDBXCDKDataDic:(NSDictionary *)DBXCDKDataDic
{
    _DBXCDKDataDic = DBXCDKDataDic;
    _netXCRecordFileArr = [DBXCDKDataDic objectForKey:@"XCRecordsInfo"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        NSInteger nRow = indexPath.row;
        if ([tableView isEqual: LandInfoTableView])
#pragma mark 地块信息
        {
            static NSString *SubDataTableViewCellID = @"cellID";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SubDataTableViewCellID];
            if (cell == nil)
            {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SubDataTableViewCellID];
                
                UILabel *ValLable = [[UILabel alloc] initWithFrame:CGRectMake(112, 12, 265, 20)];
                ValLable.tag = 100;
                ValLable.backgroundColor = [UIColor clearColor];
                ValLable.font = [UIFont systemFontOfSize:16];
                [ValLable setTextAlignment:NSTextAlignmentRight];
                [cell.contentView addSubview:ValLable];
                
            }
            if (indexPath.section == 0) {
                if (nRow == 0) {
                    // 项目名称
                    cell.textLabel.text = @"项目名称";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    NSString *val = [_DBXCDKDataDic valueForKey:@"ProjectName"];
                    [label setText:val];
                }
                else if (nRow == 1)
                {
                    cell.textLabel.text = @"受让人";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    NSString *val = [_DBXCDKDataDic valueForKey:SRR_KEY];
                    [label setText:val];
                }
                else if (nRow == 2)
                {
                    cell.textLabel.text = @"宗地号";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    NSString *val = [_DBXCDKDataDic valueForKey:@"ZDH"];
                    [label setText:val];
                }
                else if (nRow == 3)
                {
                    cell.textLabel.text = @"面积";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    NSString *val = [_DBXCDKDataDic valueForKey:AREA_KEY];
                    [label setText:val];
                }
                else if (nRow == 4)
                {
                    cell.textLabel.text = @"坐落";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    NSString *val = [_DBXCDKDataDic valueForKey:ADDRESS_KEY];
                    [label setText:val];
                }
                else if (nRow == 5)
                {
                    cell.textLabel.text = @"用途";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    NSString *val = [_DBXCDKDataDic valueForKey:@"UsePurpose"];
                    [label setText:val];
                }
                else if (nRow == 6)
                {
                    cell.textLabel.text = @"约定开工时间";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    NSString *val = [_DBXCDKDataDic valueForKey:@"StartDate"];
                    [label setText:val];
                }
                else if (nRow == 7)
                {
                    cell.textLabel.text = @"约定竣工时间";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    NSString *val = [_DBXCDKDataDic valueForKey:@"EndDate"];
                    [label setText:val];
                }
                else if (nRow == 8)
                {
                    cell.textLabel.text = @"工程状态";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    NSString *val = [_DBXCDKDataDic valueForKey:@"ProjectStatus"];
                    if ([val isEqualToString:@"0"]) {
                        [label setText:@"未竣工"];
                    }
                    else{
                        [label setText:@"已竣工"];
                    }
                }else if (nRow == 9)
                {
                    cell.textLabel.text = @"土地使用证书号";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    NSString *val = [_DBXCDKDataDic valueForKey:@"TDSYZH"];
                    [label setText:val];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }else if (indexPath.section == 1){
                if (self.LocalXCRecordFileArr.count == 0) {
                    cell.textLabel.text = @"暂无巡查记录";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    [label setText:@""];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }else{
                    NSDictionary *dicTmp = [self.LocalXCRecordFileArr objectAtIndex:indexPath.row];
                    NSString *XCDate = [dicTmp valueForKey:XC_DATE_KEY];
                    cell.textLabel.text = XCDate;
                    NSString *XCR = [dicTmp valueForKey:XCR_KEY];
        
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    [label setText:XCR];
                }
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }else if (indexPath.section == 2){
                
                if (self.netXCRecordFileArr.count == 0) {
                    cell.textLabel.text = @"暂无上传巡查记录";
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    [label setText:@""];
                } else{
                    NSDictionary *dicTmp = [self.netXCRecordFileArr objectAtIndex:indexPath.row];
                    cell.textLabel.text = [dicTmp objectForKey:@"Date"];
                    UILabel *label = (UILabel *)[cell viewWithTag:100];
                    label.text =  [dicTmp objectForKey:@"XCR"];
                }
            }
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
        }else if ([tableView isEqual:TaskTableView])
#pragma mark 巡察登记表
        {
            if (indexPath.section == 0)
            {
                static NSString *cellID = @"DocCellID0";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 75, 20)];
                    NSInteger nTag = (indexPath.section + 1) * 100;
                    label.tag = nTag++;
                    label.backgroundColor = [UIColor clearColor];
                    label.font = [UIFont systemFontOfSize:16];
                    [cell.contentView addSubview:label];
                    
                    CellUITextField *textField = [[CellUITextField alloc] initWithFrame:CGRectMake(90, 15, 200, 25)];
                    textField.tag = nTag++;
                    textField.background = [UIImage imageNamed:@"TextFieldBgImage.png"];
                    textField.font = [UIFont systemFontOfSize:15];
                    textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    [cell.contentView addSubview:textField];
                }
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                NSInteger nTag = (indexPath.section + 1) * 100;
                UILabel *label = (UILabel *)[cell.contentView viewWithTag:nTag++];
                CellUITextField *textField = (CellUITextField *)[cell.contentView viewWithTag:nTag++];
                [textField setCellPath:indexPath];
                textField.userInteractionEnabled = !bIsUploaded;
                textField.delegate = self;
                [cell setTag:indexPath.row];

                label.frame = CGRectMake(10, 15, 75, 20);
                textField.frame = CGRectMake(80, 15, 280, 25);
                if (indexPath.row == 0) {
                    label.text = @"受让人:";
                    NSString *SRR = [self.XCRecordDataDic objectForKey:SRR_KEY];
                    if ([SRR length] <= 0) {
                        NSString *val = [_DBXCDKDataDic valueForKey:SRR_KEY];
                        [self.XCRecordDataDic setObject:val forKey:SRR_KEY];
                        textField.text = val;
                    }
                    else{
                        textField.text = SRR;
                    }
                }else if (indexPath.row == 1) {
                    label.text = @"面积:";
                    textField.text = [self.XCRecordDataDic objectForKey:AREA_KEY];
                }else if (indexPath.row == 2) {
                    label.text = @"位置:";
                    textField.text = [self.XCRecordDataDic objectForKey:ADDRESS_KEY];
                }
                
                return cell;
            }
            else if(indexPath.section == 5)
            {
                static NSString *cellID = @"DocCellID5";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
                    
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 15, 75, 20)];
                    NSInteger nTag = (indexPath.section + 1) * 100;
                    label.tag = nTag++;
                    label.backgroundColor = [UIColor clearColor];
                    label.font = [UIFont systemFontOfSize:16];
                    [cell.contentView addSubview:label];
                    
                    CellUITextField *textField = [[CellUITextField alloc] initWithFrame:CGRectMake(90, 15, 200, 25)];
                    textField.tag = nTag++;
                    textField.background = [UIImage imageNamed:@"TextFieldBgImage.png"];
                    textField.font = [UIFont systemFontOfSize:15];
                    textField.autocorrectionType = UITextAutocorrectionTypeNo;
                    [cell.contentView addSubview:textField];
                    
                    UIButton *TimeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                    TimeBtn.tag = nTag++;
                    [TimeBtn addTarget:self action:@selector(TimeBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                    [TimeBtn setImage:[UIImage imageNamed:@"Calendar.png"] forState:UIControlStateNormal];
                    [cell.contentView addSubview:TimeBtn];
                }
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                NSInteger nTag = (indexPath.section + 1) * 100;
                UILabel *label = (UILabel *)[cell.contentView viewWithTag:nTag++];
                CellUITextField *textField = (CellUITextField *)[cell.contentView viewWithTag:nTag++];
                UIButton *timeBtn = (UIButton *)[cell.contentView viewWithTag:nTag++];
                timeBtn.hidden = YES;
                textField.delegate = self;
                textField.userInteractionEnabled = !bIsUploaded;
                [textField setCellPath:indexPath];
                [cell setTag:indexPath.row];

                label.frame = CGRectMake(10, 15, 140, 20);
                textField.frame = CGRectMake(130, 15, 230, 25);
                if (indexPath.row == 0) {
                    label.text = @"巡查人员签名:";
                    textField.text = [self.XCRecordDataDic objectForKey:XCR_KEY];
                }else if (indexPath.row == 1) {
                    label.text = @"巡查时间:";
                    timeBtn.hidden = bIsUploaded;
                    timeBtn.frame = CGRectMake(90, 10, 30, 30);
                    textField.text = [self.XCRecordDataDic objectForKey:XC_DATE_KEY];
                }
                
                return cell;
            }
            else if (indexPath.section == 1)
            {
                static NSString *CellId = @"DocCellID1";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
                    [self Section134Common:cell Section:indexPath.section];
                }
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                NSInteger nTag = (indexPath.section + 1) * 100;
                UIButton *FlagBtn = (UIButton *)[cell.contentView viewWithTag:nTag++];
                FlagBtn.userInteractionEnabled = !bIsUploaded;
                UILabel *label = (UILabel *)[cell.contentView viewWithTag:nTag++];
                UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:nTag++];
                CellUITextField *textField = (CellUITextField *)[cell.contentView viewWithTag:nTag++];
                textField.delegate = self;
                textField.userInteractionEnabled = !bIsUploaded;
                [textField setCellPath:indexPath];
#pragma mark 报建情况
                NSString *val = [self.XCRecordDataDic objectForKey:IS_BJ_KEY_NAME];
                if (indexPath.row == 0)
                {
                    label.text = @"是";
                    contentLabel.text = @"建设工程规划许可证编号:";
                    textField.frame = CGRectMake(225, 15, 135, 25);
                    textField.text = [self.XCRecordDataDic objectForKey:GCGHXKZBH_KEY];
                    if ((val == nil) || ([val isEqualToString:@"0"])) {
                        FlagBtn.selected = NO;
                    }else{
                        FlagBtn.selected = YES;
                    }
                }else{
                    textField.text = [self.XCRecordDataDic objectForKey:BJQK_REASON_KEY];
                    label.text = @"否";
                    contentLabel.text = @"原因:";
                    textField.frame = CGRectMake(100, 15, 260, 25);
                    if ((val == nil) || ([val isEqualToString:@"1"])) {
                        FlagBtn.selected = NO;
                    }else{
                        FlagBtn.selected = YES;
                    }
                }

                return cell;
            }
            else if (indexPath.section == 3)
            {
                static NSString *CellId = @"DocCellID3";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
                    [self Section134Common:cell Section:indexPath.section];
                }
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                NSInteger nTag = (indexPath.section + 1) * 100;
                UIButton *FlagBtn = (UIButton *)[cell.contentView viewWithTag:nTag++];
                FlagBtn.userInteractionEnabled = !bIsUploaded;
                UILabel *label = (UILabel *)[cell.contentView viewWithTag:nTag++];
                UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:nTag++];
                CellUITextField *textField = (CellUITextField *)[cell.contentView viewWithTag:nTag++];
                textField.delegate = self;
                textField.userInteractionEnabled = !bIsUploaded;
                [textField setCellPath:indexPath];
#pragma mark 开发情况
                NSString *val = [self.XCRecordDataDic objectForKey:IS_KF_KEY_NAME];
                if (indexPath.row == 0) {
                    label.text = @"是";
                    contentLabel.text = @"完成基础、完成主体、封顶、开发建设比例:";
                    textField.frame = CGRectMake(340, 15, 40, 25);
                    textField.text = [self.XCRecordDataDic objectForKey:KF_PERCENT_KEY];
                    if ((val == nil) || ([val isEqualToString:@"0"])) {
                        FlagBtn.selected = NO;
                    }else{
                        FlagBtn.selected = YES;
                    }
                }else{
                    label.text = @"否";
                    contentLabel.text = @"原因:";
                    textField.frame = CGRectMake(100, 15, 280, 25);
                    textField.text = [self.XCRecordDataDic objectForKey:KFQK_REASON_KEY];
                    if ((val == nil) || ([val isEqualToString:@"1"])) {
                        FlagBtn.selected = NO;
                    }else{
                        FlagBtn.selected = YES;
                    }
                }
                
                return cell;
            }
            else if (indexPath.section == 4)
            {
                static NSString *CellId = @"DocCellID4";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
                    [self Section134Common:cell Section:indexPath.section];
                }
                cell.backgroundColor = [UIColor clearColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                NSInteger nTag = (indexPath.section + 1) * 100;
                UIButton *FlagBtn = (UIButton *)[cell.contentView viewWithTag:nTag++];
                FlagBtn.userInteractionEnabled = !bIsUploaded;
                UILabel *label = (UILabel *)[cell.contentView viewWithTag:nTag++];
                UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:nTag++];
                CellUITextField *textField = (CellUITextField *)[cell.contentView viewWithTag:nTag++];
                textField.delegate = self;
                textField.userInteractionEnabled = !bIsUploaded;
                [textField setCellPath:indexPath];
#pragma mark 竣工情况
                NSString *val = [self.XCRecordDataDic objectForKey:IS_JG_KEY_NAME];
                if (indexPath.row == 0) {
                    label.text = @"是";
                    contentLabel.text = @"竣工验收合格证编号:";
                    textField.frame = CGRectMake(200, 15, 160, 25);
                    textField.text = [self.XCRecordDataDic objectForKey:JGYSHGZBH_KEY];
                    if ((val == nil) || ([val isEqualToString:@"0"])) {
                        FlagBtn.selected = NO;
                    }else{
                        FlagBtn.selected = YES;
                    }
                }else{
                    label.text = @"否";
                    contentLabel.text = @"原因:";
                    textField.frame = CGRectMake(100, 15, 260, 25);
                    textField.text = [self.XCRecordDataDic objectForKey:JGQK_REASON_KEY];
                    if ((val == nil) || ([val isEqualToString:@"1"])) {
                        FlagBtn.selected = NO;
                    }else{
                        FlagBtn.selected = YES;
                    }
                }
                
                return cell;
            }
            else if (indexPath.section == 2)
#pragma mark 动工情况
            {
                if (indexPath.row == 0) {
                    static NSString *CellId = @"DocCellID20";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
                        
                        UIButton *FlagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        NSInteger nTag = (indexPath.section + 1) * 100;
                        FlagBtn.tag = nTag++;
                        FlagBtn.frame = CGRectMake(10, 15, 20, 20);
                        [FlagBtn addTarget:self action:@selector(FlagBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                        [FlagBtn setImage:[UIImage imageNamed:@"ButtonBgImage02.jpg"] forState:UIControlStateSelected];
                        [FlagBtn setImage:[UIImage imageNamed:@"ButtonBgImage01.jpg"] forState:UIControlStateNormal];
                        [cell.contentView addSubview:FlagBtn];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 15, 30, 20)];
                        label.tag = nTag++;
                        label.backgroundColor = [UIColor clearColor];
                        label.font = [UIFont systemFontOfSize:16];
                        [cell.contentView addSubview:label];
                        
                        UILabel *contentlabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 320, 60)];
                        contentlabel.numberOfLines = 0;
                        contentlabel.lineBreakMode = NSLineBreakByWordWrapping;
                        contentlabel.tag = nTag++;
                        contentlabel.backgroundColor = [UIColor clearColor];
                        contentlabel.font = [UIFont systemFontOfSize:15];
                        [cell.contentView addSubview:contentlabel];
                    }
                    cell.backgroundColor = [UIColor clearColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    NSInteger nTag = (indexPath.section + 1) * 100;
                    UIButton *FlagBtn = (UIButton *)[cell.contentView viewWithTag:nTag++];
                    FlagBtn.userInteractionEnabled = !bIsUploaded;
                    UILabel *label = (UILabel *)[cell.contentView viewWithTag:nTag++];
                    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:nTag++];
                    label.text = @"是";
                    contentLabel.text = @"动工指:依法取得施工许可证后，需挖深基坑的项目，基坑开挖完毕；使用桩基的项目，打入所有基础桩；其他项目，地基施工完成三分之一；";
                    NSString *val = [self.XCRecordDataDic objectForKey:IS_DG_KEY_NAME];
                    if ((val == nil) || ([val isEqualToString:@"0"])) {
                        FlagBtn.selected = NO;
                    }else{
                        FlagBtn.selected = YES;
                    }
                    return cell;
                }else if (indexPath.row == 1){
                    static NSString *CellId = @"DocCellID21";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellId];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
                        
                        UIButton *FlagBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        NSInteger nTag = (indexPath.section + 1) * 100;
                        FlagBtn.tag = nTag++;
                        FlagBtn.frame = CGRectMake(10, 15, 20, 20);
                        [FlagBtn addTarget:self action:@selector(FlagBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                        [FlagBtn setImage:[UIImage imageNamed:@"ButtonBgImage02.jpg"] forState:UIControlStateSelected];
                        [FlagBtn setImage:[UIImage imageNamed:@"ButtonBgImage01.jpg"] forState:UIControlStateNormal];
                        [cell.contentView addSubview:FlagBtn];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(30, 15, 30, 20)];
                        label.tag = nTag++;
                        label.backgroundColor = [UIColor clearColor];
                        label.font = [UIFont systemFontOfSize:16];
                        [cell.contentView addSubview:label];
                        
                        UILabel *contentlabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 15, 200, 20)];
                        contentlabel.tag = nTag++;
                        contentlabel.backgroundColor = [UIColor clearColor];
                        contentlabel.font = [UIFont systemFontOfSize:15];
                        [cell.contentView addSubview:contentlabel];
                        
                        CellUITextField *textField = [[CellUITextField alloc] initWithFrame:CGRectMake(100, 15, 260, 25)];
                        textField.tag = nTag++;
                        textField.adjustsFontSizeToFitWidth = YES;
                        textField.background = [UIImage imageNamed:@"TextFieldBgImage.png"];
                        textField.font = [UIFont systemFontOfSize:15];
                        textField.autocorrectionType = UITextAutocorrectionTypeNo;
                        [cell.contentView addSubview:textField];
                    }
                    cell.backgroundColor = [UIColor clearColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    NSInteger nTag = (indexPath.section + 1) * 100;
                    UIButton *FlagBtn = (UIButton *)[cell.contentView viewWithTag:nTag++];
                    FlagBtn.userInteractionEnabled = !bIsUploaded;
                    UILabel *label = (UILabel *)[cell.contentView viewWithTag:nTag++];
                    UILabel *contentLabel = (UILabel *)[cell.contentView viewWithTag:nTag++];
                    CellUITextField *textField = (CellUITextField *)[cell.contentView viewWithTag:nTag++];
                    textField.userInteractionEnabled = !bIsUploaded;
                    textField.delegate = self;
                    [textField setCellPath:indexPath];
                    label.text = @"否";
                    contentLabel.text = @"原因:";
                    NSString *val = [self.XCRecordDataDic objectForKey:IS_DG_KEY_NAME];
                    if ((val == nil) || ([val isEqualToString:@"1"])) {
                        FlagBtn.selected = NO;
                    }else{
                        FlagBtn.selected = YES;
                    }
                    textField.text = [self.XCRecordDataDic objectForKey:DGQK_REASON_KEY];
                    return cell;
                    
                }
            }
            else if (indexPath.section == GEOMETRY_SECTION)
#pragma mark 采集界限
            {
                static NSString *CellID = @"CellId0";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
                if (cell == nil) {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
                }
                
                cell.backgroundColor = [UIColor clearColor];
                cell.textLabel.font = [UIFont systemFontOfSize:17];

                if (self.CurrXCRecordGeometryArr.count == 0) {
                    cell.textLabel.text = @"暂无采集界限";
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }else{
                    NSDictionary *DicTmp = [self.CurrXCRecordGeometryArr objectAtIndex:indexPath.row];
                    NSString *GeometryName = [DicTmp valueForKey:@"GeometryName"];
                    cell.textLabel.text = GeometryName;
                    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                }
                return cell;
            }
            else if (indexPath.section == PIC_SECTION)
#pragma mark 图片选择
            {
                if (self.XCRecordImagesArr.count == 0) {
                    static NSString *CellID = @"CellId0";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
                    }
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = [UIColor clearColor];
                    cell.textLabel.font = [UIFont systemFontOfSize:17];
                    cell.textLabel.text = @"暂无图片";
                    return cell;
                }else{
                    static NSString *CellID = @"CellIdImage";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
                    if (cell == nil)
                    {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
                        UIImageView * iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 8.0, 75.0, 75.0)];
                        iconView.tag = 100;
                        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
                        tapGesture.numberOfTapsRequired = 1;
                        tapGesture.numberOfTouchesRequired = 1;
                        [iconView addGestureRecognizer:tapGesture];
                        iconView.userInteractionEnabled = YES;
                        cell.userInteractionEnabled = YES;
                        [cell.contentView addSubview:iconView];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 140, 20)];
                        label.tag = 101;
                        label.backgroundColor = [UIColor clearColor];
                        [cell.contentView addSubview:label];
                        
                        // 上传状态
                        UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 10, 100, 20)];
                        stateLabel.tag = 102;
                        stateLabel.backgroundColor = [UIColor clearColor];
                        [cell.contentView addSubview:stateLabel];
                        
                        // 备注
                        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(90, 35, 240, 45)];
                        textView.tag = 200;
                        textView.delegate = self;
                        textView.font = [UIFont systemFontOfSize:15];
                        textView.scrollEnabled = NO;
                        textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AD_TextViewBgImage.png"]];
                        textView.layer.cornerRadius = 4;
                        textView.layer.masksToBounds = YES;
                        textView.layer.borderWidth = 0.5;
                        [cell.contentView addSubview:textView];
                        // Instantiate: vertical standard red to yellow to green with border
                        AMProgressView *pv7 = [[AMProgressView alloc] initWithFrame:CGRectMake(5.0, 8.0, 75.0, 75.0)
                                                                  andGradientColors:[NSArray arrayWithObjects:
                                                                                     [UIColor darkGrayColor], nil]
                                                                   andOutsideBorder:NO
                                                                        andVertical:YES];
                        pv7.tag = 300;
                        [pv7 setHidden:YES];
                        [cell.contentView addSubview:pv7];
                        
                        // upload btn
                        UIButton *UploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        UploadBtn.tag = 301;
                        UploadBtn.frame = CGRectMake(335, 28, 40, 40);
                        [UploadBtn setImage:[UIImage imageNamed:@"uploadBtn.png"] forState:UIControlStateNormal];
                        [UploadBtn addTarget:self action:@selector(AnnexUploadBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:UploadBtn];
                        
                        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        cancelBtn.tag = 302;
                        cancelBtn.frame = CGRectMake(335, 28, 40, 40);
                        cancelBtn.hidden = YES;
                        [cancelBtn setImage:[UIImage imageNamed:@"cancelBtn.png"] forState:UIControlStateNormal];
                        [cancelBtn addTarget:self action:@selector(cancelUpload:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:cancelBtn];
                    }
                    cell.backgroundColor = [UIColor clearColor];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.tag = indexPath.row;

                    UIImageView *iconView = (UIImageView *)[cell.contentView viewWithTag:100];
                    UITextView *textView = (UITextView *)[cell.contentView viewWithTag:200];
                    UILabel *label = (UILabel *)[cell.contentView viewWithTag:101];
                    UILabel *stateLabel = (UILabel *)[cell.contentView viewWithTag:102];
                    UIButton *Btn = (UIButton*)[cell.contentView viewWithTag:301];
                    textView.userInteractionEnabled = !bIsUploaded;
                    if ([[[self.XCRecordImagesArr objectAtIndex:indexPath.row] objectForKey:@"UploadState"] isEqual:@"1"]) {
                        stateLabel.text = @"已上传";
                        stateLabel.textColor = [UIColor blackColor];
                        [Btn setHidden:YES];
                    }else{
                        stateLabel.text = @"未上传";
                        stateLabel.textColor = [UIColor redColor];
                        [Btn setHidden:NO];
                    }
                    label.text = @"备注:";
                    NSString *ImagePath = [[self.XCRecordImagesArr objectAtIndex:indexPath.row] objectForKey:@"ImagePath"];
                    
                    ImagePath = [self GetCheckedImagePath:ImagePath Flg:1];
                    if ([ImagePath hasSuffix:@"PictureDefault.png"]) {
                        Btn.hidden = YES;
                    }
                    iconView.image = [UIImage imageWithContentsOfFile:ImagePath];
                    NSString *str = [[self.XCRecordImagesArr objectAtIndex:indexPath.row] objectForKey:@"ImageNote"];
                    if (str == nil) {
                        textView.text = @"";
                    }else{
                        textView.text = str;
                    }
                    
                    return cell;
                }
            }else if (indexPath.section == VIDEO_SECTION)
#pragma mark 视频选择
            {
                if (self.XCRecordVideosArr.count == 0) {
                    static NSString *CellID = @"CellId0";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }
                    cell.backgroundColor = [UIColor clearColor];
                    cell.textLabel.font = [UIFont systemFontOfSize:17];
                    cell.textLabel.text = @"暂无视频";
                    return cell;
                }else{
                    static NSString *CellID = @"CellIdVideo";
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
                    if (cell == nil) {
                        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
                        UIImageView * iconView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 8.0, 75.0, 75.0)];
                        iconView.tag = 100;
                        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
                        tapGesture.numberOfTapsRequired = 1;
                        tapGesture.numberOfTouchesRequired = 1;
                        [iconView addGestureRecognizer:tapGesture];
                        iconView.userInteractionEnabled = YES;
                        cell.userInteractionEnabled = YES;

                        [cell.contentView addSubview:iconView];
                        
                        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(90, 10, 140, 20)];
                        label.tag = 101;
                        label.backgroundColor = [UIColor clearColor];
                        [cell.contentView addSubview:label];
                        
                        UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 10, 100, 20)];
                        stateLabel.tag = 102;
                        stateLabel.backgroundColor = [UIColor clearColor];
                        [cell.contentView addSubview:stateLabel];
                        
                        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(90, 35, 240, 45)];
                        textView.tag = 200;
                        textView.delegate = self;
                        textView.font = [UIFont systemFontOfSize:15];
                        textView.scrollEnabled = NO;
                        textView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"AD_TextViewBgImage.png"]];
                        textView.layer.cornerRadius = 4;
                        textView.layer.masksToBounds = YES;
                        textView.layer.borderWidth = 0.5;
                        
                        [cell.contentView addSubview:textView];
                        
                        AMProgressView *pv7 = [[AMProgressView alloc] initWithFrame:CGRectMake(5.0, 8.0, 75.0, 75.0)
                                                                  andGradientColors:[NSArray arrayWithObjects:
                                                                                     [UIColor darkGrayColor], nil]
                                                                   andOutsideBorder:NO
                                                                        andVertical:YES];
                        pv7.tag = 300;
                        [pv7 setHidden:YES];
                        [cell.contentView addSubview:pv7];
                        
                        // upload btn
                        UIButton *UploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        UploadBtn.tag = 301;
                        UploadBtn.frame = CGRectMake(335, 28, 40, 40);
                        [UploadBtn setImage:[UIImage imageNamed:@"uploadBtn.png"] forState:UIControlStateNormal];
                        [UploadBtn addTarget:self action:@selector(AnnexUploadBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:UploadBtn];
                        
                        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                        cancelBtn.tag = 302;
                        cancelBtn.frame = CGRectMake(335, 28, 40, 40);
                        cancelBtn.hidden = YES;
                        [cancelBtn setImage:[UIImage imageNamed:@"cancelBtn.png"] forState:UIControlStateNormal];
                        [cancelBtn addTarget:self action:@selector(cancelUpload:) forControlEvents:UIControlEventTouchUpInside];
                        [cell.contentView addSubview:cancelBtn];
                    }
                    cell.backgroundColor = [UIColor clearColor];
                    cell.tag = indexPath.row;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    UIImageView *iconView = (UIImageView *)[cell.contentView viewWithTag:100];
                    UITextView *textView = (UITextView *)[cell.contentView viewWithTag:200];
                    textView.userInteractionEnabled = !bIsUploaded;
                    UILabel *label = (UILabel *)[cell.contentView viewWithTag:101];
                    UILabel *stateLabel = (UILabel *)[cell.contentView viewWithTag:102];
                    UIButton *Btn = (UIButton*)[cell.contentView viewWithTag:301];
                    if ([[[self.XCRecordVideosArr objectAtIndex:indexPath.row] objectForKey:@"UploadState"] isEqual:@"1"]) {
                        stateLabel.text = @"已上传";
                        stateLabel.textColor = [UIColor blackColor];
                        [Btn setHidden:YES];
                    }else{
                        stateLabel.text = @"未上传";
                        stateLabel.textColor = [UIColor redColor];
                        [Btn setHidden:NO];
                    }
                    label.text = @"备注:";
                    NSString *VideoPath = [[self.XCRecordVideosArr objectAtIndex:indexPath.row] objectForKey:@"PreviewVideoPath"];
                     VideoPath = [self GetCheckedImagePath:VideoPath Flg:2];
                    iconView.image = [UIImage imageWithContentsOfFile:VideoPath];
                    NSString *str = [[self.XCRecordVideosArr objectAtIndex:indexPath.row] objectForKey:@"VideoNote"];
                    if (str == nil) {
                        textView.text = @"";
                    }else{
                        textView.text = str;
                    }
                    
                    return cell;
                }
            }
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }
}

-(NSString*)GetCheckedImagePath:(NSString*)ImagePath Flg:(int)nFlg
{
    NSString *ext, *DefaultImage;
    if (nFlg == 1) {
        // image
        ext = @"png";
        DefaultImage = @"PictureDefault";
    }
    else{
        ext = @"png";
        DefaultImage = @"VideoDefault";
    }
    NSFileManager *fileMan = [[NSFileManager alloc] init];
    // 检查是否只是文件名
    NSRange Range = [ImagePath rangeOfString:@"/"];
    if (Range.location == NSNotFound){
    //if (bIsUploaded){
        // only filename, create full path
        NSString *FileFullDir = [self GetCurrentBaseDataDir];
        ImagePath = [NSString stringWithFormat:@"%@/%@", FileFullDir, ImagePath];
    }
    
    if (![fileMan fileExistsAtPath:ImagePath])
    {
        // not exist, load placeholder image
        ImagePath = [[NSBundle mainBundle] pathForResource:DefaultImage ofType:ext];
    }
    
    return ImagePath;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual: LandInfoTableView])
    {
        return 40;
    }else if ([tableView isEqual:TaskTableView]){
        if (indexPath.section == 2 && indexPath.row == 0) {
            return 80;
        }
        if (indexPath.section == PIC_SECTION) {
            if (self.XCRecordImagesArr.count == 0) {
                return 50;
            }else{
                return 90;
            }
        }
        if (indexPath.section == VIDEO_SECTION) {
            if (self.XCRecordVideosArr.count == 0) {
                return 50;
            }else{
                return 90;
            }
        }
        return 50;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual: LandInfoTableView])
    {
        return 60;
    }else if ([tableView isEqual:TaskTableView]){
//        if (section == PIC_SECTION) {
//            return 90;
//        }
        return 40;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if ([tableView isEqual:TaskTableView]) {
        if (section == 2) {
            return 40;
        }
        else if(section == VIDEO_SECTION && !bIsUploaded)
        {
            return 90;
        }
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([tableView isEqual: LandInfoTableView])
    {
        if (section == 0) {
            return @"地块信息";
        }
        else if (section == 1) {
            return @"本地未上传的巡查记录";
        }else if (section == 2){
            return @"已上传的巡查记录";
        }
    }

    return nil;
}

#pragma  mark  TableView表头处理
// 设置表头按钮可见性
-(void)SetHeaderViewBtnVisible:(UIView*)HeaderView Visible:(BOOL)bVal
{
    UIButton *btn = (UIButton*)[HeaderView viewWithTag:200];
    if (btn) {
        [btn setHidden:bVal];
    }
    
}
- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    if ([tableView isEqual:TaskTableView])
    {
        NSInteger num;
        BOOL bVal;
        if (section == GEOMETRY_SECTION) {
            num = [self.CurrXCRecordGeometryArr count];
            bVal = (num <= 0)? YES : NO;
            [self SetHeaderViewBtnVisible:view Visible:bVal || bIsUploaded];
        }
        else if (section == PIC_SECTION) {
            num = self.XCRecordImagesArr.count;
            bVal = (num <= 0)? YES : NO;
            [self SetHeaderViewBtnVisible:view Visible:bVal || bIsUploaded];
            
        }else if (section == VIDEO_SECTION){
            num = self.XCRecordVideosArr.count;
            bVal = (num <= 0)? YES : NO;
            [self SetHeaderViewBtnVisible:view Visible:bVal || bIsUploaded];
        }
    }

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    @try {
        if ([tableView isEqual:TaskTableView]) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 155, 30)];
            UIImageView *imageView;
            if (section == PIC_SECTION)
            {
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 60, 125, 30)];
            }
            else{
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, 125, 30)];
            }
            UILabel *Label = [[UILabel alloc] initWithFrame:CGRectMake(35, 8, 110, 30)];
            Label.backgroundColor = [UIColor clearColor];
            Label.font = [UIFont boldSystemFontOfSize:15];
            Label.textColor = [UIColor brownColor];
            switch (section) {
                case 0:
                    Label.text = @"地块信息:";
                    break;
                case 1:
                    Label.text = @"报建情况:";
                    break;
                case 2:
                    Label.text = @"动工情况:";
                    break;
                case 3:
                    Label.text = @"开发情况:";
                    break;
                case 4:
                    Label.text = @"竣工情况:";
                    break;
                case 5:
                    Label.text = @"巡查人员:";
                    break;
                default:
                    break;
            }
            [view addSubview:Label];
            if (section == GEOMETRY_SECTION) {
                Label.text = @"采集界限";
                
                // 采集界限增加按钮
                UIButton *AddGeometryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                AddGeometryBtn.frame = CGRectMake(125, 5, 30, 30);
                [AddGeometryBtn setImage:[UIImage imageNamed:@"Add.png"] forState:UIControlStateNormal];
                [AddGeometryBtn addTarget:self action:@selector(AddGeometryBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                [AddGeometryBtn setTag:100];
                AddGeometryBtn.hidden = bIsUploaded;
                [view addSubview:AddGeometryBtn];
                
                // 采集界限删除按钮
                UIButton *DelGeometryBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                DelGeometryBtn.frame = CGRectMake(300, 5, 30, 30);
                [DelGeometryBtn setImage:[UIImage imageNamed:@"ImageViewClose.png"] forState:UIControlStateNormal];
                [DelGeometryBtn addTarget:self action:@selector(DelGeometryBtnTouched:) forControlEvents:UIControlEventTouchUpInside];

                [DelGeometryBtn setTag:200];
                [view addSubview:DelGeometryBtn];
            }
            else if (section == PIC_SECTION) {
                Label.text = @"图片选择";
                //            [Label setFrame:CGRectMake(35, 55, 110, 30)];
                //
                //            // 巡察登记表基本信息上传
                //            UIButton *BaseDataUpLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                //            BaseDataUpLoadBtn.frame = CGRectMake(WIDTH_VIEW / 2 - 40, 0, 100, 30);
                //            [BaseDataUpLoadBtn setImage:[UIImage imageNamed:@"XCUpload.png"] forState:UIControlStateNormal];
                //            [BaseDataUpLoadBtn addTarget:self action:@selector(BaseDataUpLoadBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                //            [view addSubview:BaseDataUpLoadBtn];
                
                // 照片添加按钮
                UIButton *choosePicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                choosePicBtn.frame = CGRectMake(125, 5, 25, 25);
                choosePicBtn.tag = 100;
                [choosePicBtn setImage:[UIImage imageNamed:@"Camera_add.png"] forState:UIControlStateNormal];
                [choosePicBtn addTarget:self action:@selector(ChoosePicBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                choosePicBtn.hidden = bIsUploaded;
                [view addSubview:choosePicBtn];
                // 照片删除按钮
                UIButton *DeletePicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                DeletePicBtn.frame = CGRectMake(300, 5, 30, 30);
                [DeletePicBtn setImage:[UIImage imageNamed:@"ImageViewClose.png"] forState:UIControlStateNormal];
                [DeletePicBtn addTarget:self action:@selector(DeletePicBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                DeletePicBtn.tag = 200;
                choosePicBtn.hidden = bIsUploaded;
                [view addSubview:DeletePicBtn];
                
            }else if (section == VIDEO_SECTION){
                Label.text = @"视频选择";
                UIButton *choosePicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                choosePicBtn.frame = CGRectMake(123, 10, 26, 26);
                [choosePicBtn setImage:[UIImage imageNamed:@"videocamera.png"] forState:UIControlStateNormal];
                [choosePicBtn addTarget:self action:@selector(ChoosePicBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                choosePicBtn.hidden = bIsUploaded;
                [view addSubview:choosePicBtn];
                
                // 视频删除按钮
                UIButton *DeletePicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                DeletePicBtn.frame = CGRectMake(300, 5, 30, 30);
                [DeletePicBtn setImage:[UIImage imageNamed:@"ImageViewClose.png"] forState:UIControlStateNormal];
                [DeletePicBtn addTarget:self action:@selector(VideoDeletePicBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
                DeletePicBtn.tag = 200;
                DeletePicBtn.hidden = bIsUploaded;
                [view addSubview:DeletePicBtn];
                
            }
            //can not invoked by system, Why ?
            [self tableView:TaskTableView willDisplayHeaderView:view forSection:section];
            return view;
        }

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    return nil;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if ([tableView isEqual:TaskTableView]) {
        if (section == 2) {
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TaskTableView.frame.size.width, 40)];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, TaskTableView.frame.size.width - 40, 40)];
            label.backgroundColor = [UIColor clearColor];
            label.text = @"说明:未动工原因主要包括:道路未通、规划调整、企业自身原因；";
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            label.font = [UIFont systemFontOfSize:16];
            [view addSubview:label];
            return view;
        }
        else if (section == VIDEO_SECTION && !bIsUploaded)
        {
            // 巡察登记表基本信息上传
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TaskTableView.frame.size.width, 50)];
            
            UIButton *BaseDataUpLoadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            BaseDataUpLoadBtn.frame = CGRectMake(WIDTH_VIEW / 2 - 50, 20, 100, 30);
            [BaseDataUpLoadBtn setImage:[UIImage imageNamed:@"XCUpload.png"] forState:UIControlStateNormal];
            [BaseDataUpLoadBtn addTarget:self action:@selector(BaseDataUpLoadBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:BaseDataUpLoadBtn];
            
            // 上传提示
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 370, 30)];
            [label setBackgroundColor:[UIColor clearColor]];
            [label setFont:[UIFont systemFontOfSize:13]];
            label.numberOfLines = 0;
            label.lineBreakMode = NSLineBreakByWordWrapping;
            [label setText:@"*此操作不会上传图片和视频文件，请点击文件右侧绿色上传按钮单独上传.欲上传图片和视频文件，请先上传巡查基本信息."];
            [view addSubview:label];
            return view;
            
//            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, TaskTableView.frame.size.width, 50)];
//            
//            UIButton *FileUploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//            [FileUploadBtn setImage:[UIImage imageNamed:@"XCUpload.png"] forState:UIControlStateNormal];
//            FileUploadBtn.frame = CGRectMake(WIDTH_VIEW / 2 - 50, 20, 100, 30);
//            [FileUploadBtn addTarget:self action:@selector(FileUploadBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
//            [view addSubview:FileUploadBtn];
//            return view;
        }
    }
    return nil;
}

//是否可以编辑
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((indexPath.section == PIC_SECTION) && (nDelFileFlg == 1)) {
        if (self.XCRecordImagesArr.count == 0) {
            return NO;
        }else{
            return YES;
        }
    }
    if ((indexPath.section == VIDEO_SECTION) && (nDelFileFlg == 2)) {
        if (self.XCRecordVideosArr.count == 0) {
            return NO;
        }else{
            return YES;
        }
    }
    if ((indexPath.section == GEOMETRY_SECTION) && (nDelFileFlg == 3)) {
        if (self.CurrXCRecordGeometryArr.count == 0) {
            return NO;
        }else{
            return YES;
        }
    }
    
    return NO;
}

//设置编辑模式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (nDelFileFlg == 1) {
        if (indexPath.section == PIC_SECTION) {
            return UITableViewCellEditingStyleDelete;
        }
    }
    else if(nDelFileFlg == 2)
    {
        if (indexPath.section == VIDEO_SECTION) {
            return UITableViewCellEditingStyleDelete;
        }
    }
    else if(nDelFileFlg == 3)
    {
        if (indexPath.section == GEOMETRY_SECTION) {
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
    
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        if (indexPath.section == PIC_SECTION) {
            // 删除本地图片文件
            NSFileManager *fileMan = [NSFileManager defaultManager];
            NSError *err;
            NSString *Path = [[self.XCRecordImagesArr objectAtIndex:indexPath.row] objectForKey:@"ImagePath"];
            if ([Path length] > 0) {
                BOOL bRet = [fileMan removeItemAtPath:Path error:&err];
                [self.XCRecordImagesArr removeObjectAtIndex:indexPath.row];
                [TaskTableView reloadData];
            }
        }else if (indexPath.section == VIDEO_SECTION){
            // 删除本地视频文件
            NSFileManager *fileMan = [NSFileManager defaultManager];
            NSError *err;
            NSString *Path = [[self.XCRecordVideosArr objectAtIndex:indexPath.row] objectForKey:@"VideoPath"];
            if ([Path length] > 0)
            {
                BOOL bRet = [fileMan removeItemAtPath:Path error:&err];
                [self.XCRecordVideosArr removeObjectAtIndex:indexPath.row];
                [TaskTableView reloadData];
            }
        }
        else if (indexPath.section == GEOMETRY_SECTION){
            // 删除界限记录数据
            [self.CurrXCRecordGeometryArr removeObjectAtIndex:indexPath.row];
            [TaskTableView reloadData];
        }
        
        // 如果本地数据已经保存，则一定要做保存处理
        if ([self.CurrentXCRecordFileName length] > 0) {
            [self BaseDataSave];
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

#pragma mark 点击TableView一行
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        if (tableView == LandInfoTableView)
        {
            if (indexPath.section == 1)
            {
                if ([self.LocalXCRecordFileArr count] <= 0) {
                    // 无本地巡察记录的场合
                    return;
                }
                NSDictionary *DicTmp = [self.LocalXCRecordFileArr objectAtIndex:indexPath.row];
                NSString *fileName = [DicTmp valueForKey:@"XCRecordFileName"];
                NSString *DKId = [_DBXCDKDataDic valueForKey:@"Id"];
                NSString *FileFullDir = [NSString  stringWithFormat:@"%@/%@", XCRecordFileDir, DKId];
                NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@", FileFullDir, fileName];
                NSFileManager *FileMan = [[NSFileManager alloc] init];
                // Document 文件是否存在
                if ([FileMan fileExistsAtPath:fileFullPath])
                {
                    // 加载显示文件内的数据
                    [self LoadLocalRecord:fileFullPath];
                    self.CurrentXCRecordFileName = fileName;
                }
                
            }else if (indexPath.section == 2){
                
                if (self.netXCRecordFileArr.count <= 0) {
                    return;
                }
                NSString *XCDKId = [[self.netXCRecordFileArr objectAtIndex:indexPath.row] objectForKey:@"Id"];
                [self loadNetXCRecord:XCDKId];
            }
        }else if ([tableView isEqual:TaskTableView]){
            if (indexPath.section == GEOMETRY_SECTION) {
                // 显示当前地块信息
                if ([self.CurrXCRecordGeometryArr count] <= 0) {
                    return;
                }
                NSDictionary *geoDic = [self.CurrXCRecordGeometryArr objectAtIndex:indexPath.row];
                NSDictionary *GeoJson = [geoDic objectForKey:@"Geometry"];
                if (GeoJson != nil)
                {
                    AGSPolygon *Geo = [[AGSPolygon alloc] init];
                    [Geo decodeWithJSON:GeoJson];
                    if (Geo != nil) {
                        // 在地图上显示
                        [delegate DisplayGeometryOnMap:Geo];
                    }
                }
                else{
                    // 没有地块数据的场合才会打开画图操作
                    [delegate OpenPolygonDrawing];
                }
            }
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        //
    }

}

#pragma mark 定位地块
- (IBAction)GPRSBtnTouched:(id)sender
{
    NSString *Id = [_DBXCDKDataDic valueForKey:@"Id"] ;
    [self.delegate XCDKGeometryLocation:Id];
}

#pragma mark 隐藏左侧视图
- (IBAction)ClosedBtnTouched:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (bCloseBtnFlg) {

        [button setImage:[UIImage imageNamed:@"CloseViewBtn.png"] forState:UIControlStateNormal];
        bCloseBtnFlg = NO;
    }else{
        [button setImage:[UIImage imageNamed:@"OpenViewBtn.png"] forState:UIControlStateNormal];
        bCloseBtnFlg = YES;
    }
    [delegate ClosedBtnTouchedWithFlag:bCloseBtnFlg];
}

#pragma mark 巡察视图创建/显示
-(void)TaskViewDisplay
{
    if (TaskView == nil) {
        TaskView = [[UIView alloc] initWithFrame:CGRectMake(-WIDTH_VIEW, 0, WIDTH_VIEW, HEIGTH_VIEW)];
        TaskView.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"TableViewBgImage.png"]];
        //TaskTableView
        TaskTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0 + 60, WIDTH_VIEW, HEIGTH_VIEW - 60 - 40) style:UITableViewStyleGrouped];
        UIButton *Btn = [UIButton buttonWithType:UIButtonTypeCustom];
        TaskTableView.separatorColor = [UIColor darkGrayColor];
        TaskTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        TaskTableView.backgroundColor = [UIColor clearColor];
        TaskTableView.backgroundView = nil;
        TaskTableView.tableFooterView = Btn;
        TaskTableView.tableFooterView.hidden = YES;
        TaskTableView.layer.cornerRadius = 4;
        TaskTableView.layer.masksToBounds = YES;
        TaskTableView.delegate = self;
        TaskTableView.dataSource = self;
        [TaskView addSubview:TaskTableView];
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 400, 60)];
        [imageView setImage:[UIImage imageNamed:@"FormTop.png"]];
        [TaskView addSubview:imageView];
        
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 704-40, 400, 40)];
        [imageView setImage:[UIImage imageNamed:@"FormBottom.png"]];
        [TaskView addSubview:imageView];
        
        // 任务结束返回按钮
        UIButton *BackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        BackBtn.frame = CGRectMake(10, 15, 50, 25);
        [BackBtn setImage:[UIImage imageNamed:@"Back.png"] forState:UIControlStateNormal];
        [BackBtn addTarget:self action:@selector(BackBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        [TaskView addSubview:BackBtn];
        
        // 巡察登记表基本信息保存
        UIButton *BaseDataSaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        BaseDataSaveBtn.frame = CGRectMake(300, 12, 70, 30);
        [BaseDataSaveBtn setImage:[UIImage imageNamed:@"XCSave.png"] forState:UIControlStateNormal];
        [BaseDataSaveBtn addTarget:self action:@selector(BaseDataSaveBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        BaseDataSaveBtn.tag = 110;
        [TaskView addSubview:BaseDataSaveBtn];
        
        
        UILabel *leftTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(65, 15, 270, 30)];
        leftTitleLabel.font = [UIFont boldSystemFontOfSize:18];
        leftTitleLabel.backgroundColor = [UIColor clearColor];
        leftTitleLabel.text = @"批后监管巡查表";
        //        leftTitleLabel.textColor = [UIColor whiteColor];
        leftTitleLabel.textAlignment = NSTextAlignmentCenter;
        [TaskView addSubview:leftTitleLabel];
        
        //        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        //        cancelBtn.frame = CGRectMake(30, 704 - 40 + 9, 50, 22);
        //        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        //        [cancelBtn addTarget:self action:@selector(BackBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
        //        [TaskView addSubview:cancelBtn];
        
        
        //        UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        saveBtn.frame = CGRectMake(40, 704 - 80 + 15, 70, 30);
        //        [saveBtn setImage:[UIImage imageNamed:@"AD_Save.png"] forState:UIControlStateNormal];
        //        [saveBtn addTarget:self action:@selector(saveBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        //        [TaskView addSubview:saveBtn];
        
        //        UIButton *FileUploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        //        [FileUploadBtn setImage:[UIImage imageNamed:@"AD_Send.png"] forState:UIControlStateNormal];
        //        FileUploadBtn.frame = CGRectMake(200, 704 - 80 + 15, 70, 30);
        //        [FileUploadBtn addTarget:self action:@selector(FileUploadBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
        //        [TaskView addSubview:FileUploadBtn];
        
        
        [self.view addSubview:TaskView];
    }
    [TaskView viewWithTag:110].hidden = bIsUploaded;
    [TaskTableView reloadData];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    TaskView.frame = CGRectMake(0, 0, 400, 704);
    [UIView commitAnimations];
    
    return;
}
#pragma mark 开始巡查
- (IBAction)PatrolBtnTouched:(id)sender
{
    _nTaskRunningFlg = 1;
    bIsUploaded = NO;
    [self CleanCachaData];
    return;
}

-(void)CleanCachaData
{
    self.CurrentXCRecordFileName = nil;
    [self.XCRecordDataDic removeAllObjects];
    [self.CurrXCRecordGeometryArr removeAllObjects];
    [self.XCRecordImagesArr removeAllObjects];
    [self.XCRecordVideosArr removeAllObjects];
    [self TaskViewDisplay];
}

#pragma mark 加载指定的本地巡察记录
-(BOOL)LoadLocalRecord:(NSString*)fileFullPath
{
    @try {
        filePath = fileFullPath;
        _nTaskRunningFlg = 1;
        [self CleanCachaData];
        self.SourceDic = [NSDictionary dictionaryWithContentsOfFile:fileFullPath];
        // 基本信息
        self.XCRecordDataDic = [self.SourceDic objectForKey:@"XCRecordData"];
        // 采集界限
        [self.CurrXCRecordGeometryArr setArray:[self.SourceDic objectForKey:@"GeometrysData"]];
        // 图片名称及备注
        [self.XCRecordImagesArr setArray:[self.SourceDic objectForKey:@"PicInfo"]];
        // 视频名称及备注
        [self.XCRecordVideosArr setArray:[self.SourceDic objectForKey:@"VideoInfo"]];
        
        [self TaskViewDisplay];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
    
    return YES;
}
#pragma mark 结束巡察
- (void)BackBtnTouch:(id)sender
{
    if (self.bIsUploading) {
        [self AlertMsg:nil Message:@"请首先取消正在上传的附件"];
        return;
    }
    [self hiddenKeyboard:TaskTableView];
    if (!bIsUploaded && bIsEditing) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"是否保存到本地？" message:nil delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
        [alertView show];
    }else {
        [self backToLandInfoView];
    }
}

- (void)backToLandInfoView{
    @try {
        bIsUploaded = NO;
        [self CleanCachaData];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDidStopSelector:@selector(leftTitleSearchBtnAnimationStopped)];
        TaskView.frame = CGRectMake(-400, 0, 400, 704);
        [UIView commitAnimations];
        
        _nTaskRunningFlg = 0;
        [self hiddenKeyboard:self.view];
        // 重新加载本地巡察记录
        NSString *Id = [_DBXCDKDataDic valueForKey:@"Id"];
        [self LoadLocalXCRecord:Id];
        [self.LandInfoTableView reloadData];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        if (![self validateData:self.XCRecordDataDic]) {
            return;
        }
        if (![self BaseDataSave]) {
            return;
        }
    }
    bIsEditing = NO;
    [self backToLandInfoView];
}

// 取得当前任务相关文件存储目录
-(NSString*)GetCurrentTaskFileDir:(NSString*)dkId
{
    self.SourceDic = [NSMutableDictionary dictionaryWithCapacity:0];
    NSString *FileFullDir = [NSString  stringWithFormat:@"%@/%@", XCRecordFileDir, dkId];
    NSFileManager *fileMan = [[NSFileManager alloc] init];
    // Document 目录是否存在
    NSError *err;
    if (![fileMan fileExistsAtPath:FileFullDir])
    {
        BOOL bRet = [fileMan createDirectoryAtPath:FileFullDir withIntermediateDirectories:YES attributes:nil error:&err];
        if (!bRet) {
            [self AlertMsg:@"错误" Message:@"创建本地文件失败"];
            return nil;
        }
    }
    return FileFullDir;
}

-(NSString*)GettimeIntervalSince1970
{
   NSDate *today = [NSDate date];
    NSTimeInterval dVal = [today timeIntervalSince1970];
    NSInteger nVal = dVal;
    NSNumber *odVal = [NSNumber numberWithDouble:nVal];
    
    NSString *sVal = [odVal stringValue];
    return sVal;
}

#pragma mark 基本信息和附件信息保存
// 获取当前任务存储目录
-(NSString*)GetCurrentBaseDataDir
{
    @try {
        // 获取存储位置
        NSString *dkId = [_DBXCDKDataDic valueForKey:@"Id"];
        NSString *FileFullDir = [self GetCurrentTaskFileDir:dkId];
        if ([FileFullDir length] <= 0) {
            [self AlertMsg:@"" Message:@"创建存储路径失败"];
            return nil;
        }
        return FileFullDir;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}
// 获取当前任务存储文件名(.plist文件)
-(NSString*)GetCurrentBaseDataFileName
{
    @try {
        // 创建本地巡察的记录文件
        if ([self.CurrentXCRecordFileName length] <= 0) {
            // 以地块ID+当前时间+巡察人为文件名
            NSString *sDate = [self GettimeIntervalSince1970];
            NSString *XCR = [self.XCRecordDataDic objectForKey:XCR_KEY];
            if ([XCR length] <= 0) {
                [self AlertMsg:@"" Message:@"巡察人员不能为空"];
                return nil;
            }
            NSString *dkId = [_DBXCDKDataDic valueForKey:@"Id"];
            self.CurrentXCRecordFileName = [NSString stringWithFormat:@"%@_%@_%@.plist", dkId, sDate, XCR];
            
            [self AddXCRecordFileInfo:dkId Date:sDate XCR:XCR];
        }
        return self.CurrentXCRecordFileName;
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}
// 保存按钮响应函数
- (void)BaseDataSaveBtnTouched:(id)sender
{
    [self hiddenKeyboard:self.view];
    if (![self validateData:self.XCRecordDataDic]) {
        return;
    }
    BOOL bRet = [self BaseDataSave];
    if (bRet) {
        [self AlertMsg:@"提示" Message:@"本地保存成功"];
        bIsEditing = NO;
    }
    return;
}

// 真正数据保存处理
-(BOOL)BaseDataSave
{
    @try {
        
        NSString *FileFullDir = [self GetCurrentBaseDataDir];
        NSString *fileName = [self GetCurrentBaseDataFileName];
        if (([fileName length] <= 0) || ([FileFullDir length] <= 0))  {
            return NO;
        }
        NSString *FileFullPath = [NSString stringWithFormat:@"%@/%@", FileFullDir, fileName];

        filePath = FileFullPath;
        
        NSString *dkId = [_DBXCDKDataDic valueForKey:@"Id"];
        // 巡察地块ID
        [self.SourceDic setObject:dkId forKey:@"XCDKId"];
        
        // 基本信息
        [self.SourceDic setObject:self.XCRecordDataDic forKey:@"XCRecordData"];
        // 采集界限
        [self.SourceDic setObject:self.CurrXCRecordGeometryArr forKey:@"GeometrysData"];
        // 附件信息
        [self.SourceDic setObject:self.XCRecordImagesArr forKey:@"PicInfo"];
        [self.SourceDic setObject:self.XCRecordVideosArr forKey:@"VideoInfo"];
        // 写入本地文件
        // NSError *err = nil;
        BOOL bRet = [self.SourceDic writeToFile:FileFullPath atomically:YES];
        if (!bRet) {
            [self AlertMsg:@"错误" Message:@"创建本地文件失败"];
            return NO;
        }
        return YES;
    }
    @catch (NSException *exception) {
        [self AlertMsg:@"错误" Message:@"文件保存失败"];
        return NO;
    }
    @finally {
        
    }
}

- (BOOL)validateData:(NSDictionary *)XCRecordData{
    
    NSString *temp = [XCRecordData objectForKey:SRR_KEY];
    if (![self checkField:temp]) {
        [self AlertMsg:@"" Message:@"受让人不能为空"];
        return NO;
    }
    
    temp = [XCRecordData objectForKey:AREA_KEY];
    if (![self checkField:temp]) {
        [self AlertMsg:@"" Message:@"面积不能为空"];
        return NO;
    }
    
    temp = [XCRecordData objectForKey:ADDRESS_KEY];
    if (![self checkField:temp]) {
        [self AlertMsg:@"" Message:@"位置不能为空"];
        return NO;
    }
    
    //报建情况校验
    temp = [XCRecordData objectForKey:IS_BJ_KEY_NAME];
    if (temp == nil || [temp isEqualToString:@"0"])
    {
        // 未报建
        temp = [XCRecordData objectForKey:BJQK_REASON_KEY];
        if (![self checkField:temp]) {
            [self AlertMsg:@"" Message:@"没有报建的原因不能为空"];
            return NO;
        }
    }else{
        NSString *reason = [XCRecordData objectForKey:GCGHXKZBH_KEY];
        if (![self checkField:reason]) {
            [self AlertMsg:@"" Message:@"工程规划许可证编号不能为空"];
            return NO;
        }
    }
    
    //动工情况校验
    temp = [XCRecordData objectForKey:IS_DG_KEY_NAME];
    if (temp == nil || [temp isEqualToString:@"0"])
    {
        // 未动工
        NSString *reason = [XCRecordData objectForKey:DGQK_REASON_KEY];
        if (![self checkField:reason])
        {
            [self AlertMsg:@"" Message:@"没有动工原因不能为空"];
            return NO;
        }
    }
    
    //开发情况校验
    temp = [XCRecordData objectForKey:IS_KF_KEY_NAME];
    if (temp == nil || [temp isEqualToString:@"0"])
    {
        // 未开发完成
        temp = [XCRecordData objectForKey:KFQK_REASON_KEY];
        if (![self checkField:temp]) {
            [self AlertMsg:@"" Message:@"没有开发的原因不能为空"];
            return NO;
        }
    }else{
        NSString *percent = [XCRecordData objectForKey:KF_PERCENT_KEY];
        if (![self checkField:percent]) {
            [self AlertMsg:@"" Message:@"开发建设比例不能为空"];
            return NO;
        }
    }
    
    //竣工情况校验
    temp = [XCRecordData objectForKey:IS_JG_KEY_NAME];
    if (temp == nil || [temp isEqualToString:@"0"])
    {
        // 未竣工
        temp = [XCRecordData objectForKey:JGQK_REASON_KEY];
        if (![self checkField:temp]) {
            [self AlertMsg:@"" Message:@"没有竣工的原因不能为空"];
            return NO;
        }
    }else{
        NSString *percent = [XCRecordData objectForKey:JGYSHGZBH_KEY];
        if (![self checkField:percent]) {
            [self AlertMsg:@"" Message:@"竣工验收合格证编号不能为空"];
            return NO;
        }
    }

    temp = [XCRecordData objectForKey:XCR_KEY];
    if (![self checkField:temp]) {
        [self AlertMsg:@"" Message:@"巡察人不能为空"];
        return NO;
    }
    
    temp = [XCRecordData objectForKey:XC_DATE_KEY];
    if (![self checkField:temp]) {
        [self AlertMsg:@"" Message:@"巡察日期不能为空"];
        return NO;
    }
    return YES;
}

- (BOOL)checkField:(NSString *)value
{
    if ([value length] <= 0) {
        return NO;
    }
    return YES;
}

-(void)AddXCRecordFileInfo:(NSString*)DKId Date:(NSString*)dVal XCR:(NSString*)XCR
{
    NSMutableDictionary *DicTmp = [NSMutableDictionary dictionaryWithCapacity:2];
    [DicTmp setObject:DKId forKey:@"DKId"];
    
    NSString *date = [self GetDate:dVal];
    [DicTmp setObject:date forKey:XC_DATE_KEY];
    [DicTmp setObject:XCR forKey:XCR_KEY];
    
    [DicTmp setObject:self.CurrentXCRecordFileName forKey:@"XCRecordFileName"];
    [self.LocalXCRecordFileArr addObject:DicTmp];
    return;
}

#pragma mark 基本信息上传
- (void)BaseDataUpLoadBtnTouched:(id)sender
{
    @try {
        if (![self validateData:self.XCRecordDataDic]) {
            return;
        }
        DBLocalTileDataManager *dataMan = [DBLocalTileDataManager instance];
        if (![dataMan InternetConnectionTest]) {
            [dataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
            return;
        }
        
        self.CurrentXCRecordFileName = nil;
        if ([self.SourceDic count] <= 0) {
            [dataMan CreateFailedAlertViewWithFailedInfo:@"请先保存数据" andWithMessage:nil];
            return;
        }
        [self.delegate DisplayLoadingXCDKView:@"正在上传巡查记录"];
        NSData *jsonDataWrite = [NSJSONSerialization dataWithJSONObject:self.SourceDic options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *strJson = [[NSString alloc] initWithData:jsonDataWrite encoding:NSUTF8StringEncoding];
        dataMan.XCDKUploadDelegate = self;
        [dataMan UploadXCRecordData:strJson];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

    return ;
}

#pragma mark 采集界限增加
-(void)AddGeometryBtnTouched:(id)sender
{
    [self.delegate DisplayGeometryNameView:nil GeometryMemo:nil];
    return;
}

// 删除
-(void)DelGeometryBtnTouched:(id)sender
{
    BOOL bRet = [TaskTableView isEditing];
    if (bRet) {
        nDelFileFlg = 0;
    }
    else{
        nDelFileFlg = 3;
    }
    [TaskTableView setEditing:!bRet];
    return;
}

-(void)AddGeometryItem:(NSString*)Name Memo:(NSString*)Memo
{
    NSMutableDictionary *AddDic = [NSMutableDictionary dictionaryWithCapacity:2];
    [AddDic setObject:Name forKey:@"GeometryName"];
    [AddDic setObject:Memo forKey:@"Memo"];
    [self.CurrXCRecordGeometryArr addObject:AddDic];
    [TaskTableView reloadData];
}

// 存储当前巡察记录的地块采集数据
-(void)AddGeometryData:(AGSGeometry*)Geometry
{
    if (_nTaskRunningFlg == 0) {
        [self AlertMsg:@"" Message:@"当前未在巡察任务中"];
        return;
    }
    NSIndexPath *path = [TaskTableView indexPathForSelectedRow];
    if (path.section == GEOMETRY_SECTION) {
        //
        NSInteger nRow = [path row];
        NSMutableDictionary *GeoDic = [self.CurrXCRecordGeometryArr objectAtIndex:nRow];
        NSDictionary *GeoJson = [Geometry encodeToJSON];
        [GeoDic setObject:GeoJson forKey:@"Geometry"];
    }
    
    return;
}
#pragma mark 附件上传
- (void)AnnexUploadBtnTouched:(id)sender
{
    if (!bIsUploaded) {
        [self AlertMsg:@"请先上传基本信息" Message:nil];
        return;
    }
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    if (![DataMan InternetConnectionTest]) {
        [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
        return;
    }
    
    if (self.bIsUploading ==YES) {
        [self AlertMsg:nil Message:@"不能同时上传多个文件"];
        return;
    }
    UIButton *Btn = (UIButton*)sender;
    UITableViewCell *curCell = (UITableViewCell *)Btn.superview.superview;
    [curCell viewWithTag:302].hidden = NO;
    NSIndexPath *path = [TaskTableView indexPathForCell:curCell];
    [self UploadAnnexFileByIndexPath:path];
}

// 上传指定CELL里的附件
-(void)UploadAnnexFileByIndexPath:(NSIndexPath*)IndexPath;
{
    @try {
        NSString *FileFullPath;
        if (IndexPath.section == PIC_SECTION) {
            //
            if ([self.XCRecordImagesArr count] <= IndexPath.row) {
                [self AlertMsg:nil Message:@"请先本地保存"];
                return;
            }
            NSDictionary *ImageDic = [self.XCRecordImagesArr objectAtIndex:IndexPath.row];
            // 检查上传状态
            NSString *state = [ImageDic objectForKey:@"UploadState"];
            if ([state isEqualToString:@"1"]) {
                //
                [self AlertMsg:nil Message:@"此文件已经上传"];
                return;
            }
            FileFullPath = [ImageDic valueForKey:@"ImagePath"];
        }
        else if(IndexPath.section == VIDEO_SECTION)
        {
            if ([self.XCRecordVideosArr count] <= IndexPath.row) {
                [self AlertMsg:nil Message:@"请先本地保存"];
                return;
            }
            NSDictionary *VideoDic = [self.XCRecordVideosArr objectAtIndex:IndexPath.row];
            // 检查上传状态
            NSString *state = [VideoDic objectForKey:@"UploadState"];
            if ([state isEqualToString:@"1"]) {
                //
                [self AlertMsg:nil Message:@"此文件已经上传"];
                return;
            }
            FileFullPath = [VideoDic valueForKey:@"VideoPath"];
        }
        if ([FileFullPath length] <= 0) {
            [self AlertMsg:nil Message:@"请确保您选中了所要上传的图片或视频"];
            return;
        }
        
        [self UpLoadFile:FileFullPath IndexPath:IndexPath];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

//// 上传文件按钮响应
//- (void)FileUploadBtnTouched:(id)sender
//{
//    // 确保上传之前检查文件名组成各要素正常
//    NSString *XCR = [self.XCRecordDataDic objectForKey:XCR_KEY];
//    if ([XCR length] <= 0) {
//        [self AlertMsg:@"" Message:@"巡察人员不能为空"];
//        return;
//    }
//    
//    NSIndexPath *index = [TaskTableView indexPathForSelectedRow];
//    [self UploadAnnexFileByIndexPath:index];
//}

// 上传中进度条更新处理
-(int)SetUploadProgressVal:(double)dVal IndexPath:(NSIndexPath*)Path
{
    UITableViewCell *Cell = [TaskTableView cellForRowAtIndexPath:Path];
    UIView *view = [Cell viewWithTag:300];
    AMProgressView *PView;
    if([view isKindOfClass:[AMProgressView class]])
    {
        PView = (AMProgressView*)view;
        [PView setProgress:dVal];
    }
    else{
        return 0;
    }
    return 1;
}

// 上传正常完成处理
-(void)UploadCompleted:(NSIndexPath*)IndexPath Msg:(NSString*)RetMsg
{
    @try {
        [self SetUploadProgressVal:100.0 IndexPath:IndexPath];
        UITableViewCell *Cell = [TaskTableView cellForRowAtIndexPath:IndexPath];
        UIView *view = [Cell viewWithTag:300];
        AMProgressView *PView;
        if([view isKindOfClass:[AMProgressView class]])
        {
            PView = (AMProgressView*)view;
            [PView setHidden:YES];
        }
        view = [Cell viewWithTag:302];
        if ([view isMemberOfClass:[UIButton class]]) {
            UIButton *cancelBtn = (UIButton *)view;
            cancelBtn.hidden = YES;
        }
        NSError *err;
        NSDictionary *retDic = [NSJSONSerialization JSONObjectWithData: [RetMsg dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &err];
        
        NSString *Msg;
        NSString *memo;
        NSString *code = [retDic objectForKey:@"ErrCode"];
        if ([code isEqualToString:@"200"]) {
            //
            Msg = @"上传成功";
        }else
        {
            memo = [retDic objectForKey:@"Memo"];
            Msg = [NSString stringWithFormat:@"上传失败\n%@memo", memo];
            
        }
        UIButton *Btn = (UIButton*)[Cell.contentView viewWithTag:301];
        [Btn setHidden:YES];
        
        view = [Cell viewWithTag:102];
        if([view isKindOfClass:[UILabel class]]) {
            UILabel *label = (UILabel*)view;
            [label setText:@"已上传"];
            label.textColor = [UIColor blackColor];
            [PView setHidden:YES];
            
            // 修改状态
            if (IndexPath.section == PIC_SECTION) {
                [[self.XCRecordImagesArr objectAtIndex:IndexPath.row] setObject:@"1" forKey:@"UploadState"];
            }
            else if(IndexPath.section == VIDEO_SECTION)
            {
                [[self.XCRecordVideosArr objectAtIndex:IndexPath.row] setObject:@"1" forKey:@"UploadState"];
            }
        }
        
        [self AlertMsg:nil Message:Msg];
        
        // 如果不是已上传的巡查记录，则一定要做保存处理
        if(!bIsUploaded){
            [self BaseDataSave];
        }

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

// 上传出错处理
-(void)UploadonError:(NSIndexPath*)IndexPath Error:(NSError*)err
{
    UITableViewCell *Cell = [TaskTableView cellForRowAtIndexPath:IndexPath];
    UIView *view = [Cell viewWithTag:300];
    AMProgressView *PView;
    if([view isKindOfClass:[AMProgressView class]])
    {
        PView = (AMProgressView*)view;
        [PView setHidden:YES];
    }
    view = [Cell viewWithTag:302];
    if ([view isMemberOfClass:[UIButton class]]) {
        UIButton *cancelBtn = (UIButton *)view;
        cancelBtn.hidden = YES;
    }
    UIButton *Btn = (UIButton*)[Cell.contentView viewWithTag:301];
    [Btn setHidden:NO];
    [self AlertMsg:nil Message:@"上传失败"];
}

// 数据上传处理
-(void)UpLoadFile:(NSString*)FullPath IndexPath:(NSIndexPath*)IndexPath
{
    // 隐藏上传按钮
    UITableViewCell *curCell = [TaskTableView cellForRowAtIndexPath:IndexPath];
    UIButton *Btn = (UIButton*)[curCell.contentView viewWithTag:301];
    [Btn setHidden:YES];
    
    AMProgressView *PView = (AMProgressView*)[curCell.contentView viewWithTag:300];
    [PView setHidden:NO];
    
    self.bIsUploading = YES;
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    AuthHttpEngine *AuthEngine = [DataMan GetNetEngine];
    MKNetworkOperation *uploadOperation = [AuthEngine uploadImageFromFile:FullPath
                                                  cellPath:IndexPath
                                                   onCompletion:^(NSString *RetMsg, MKNetworkOperation*Operation) {
                                                       
                                                       //NSIndexPath *Path = [Operation UserIndexPath];
                                                       [self UploadCompleted:IndexPath Msg:RetMsg];
                                                       self.bIsUploading = NO;
                                                   }
                                                        onError:^(NSError* error, MKNetworkOperation* Operation) {
                                                            
                                                            //NSIndexPath *Path = [Operation UserIndexPath];
                                                            [self UploadonError:IndexPath Error:error];
                                                            self.bIsUploading = NO;
                                                            
                                                        }];
    
    
    [uploadOperation onUploadProgressChanged:^(double progress, MKNetworkOperation *Operation) {
        //NSIndexPath *Path = [Operation UserIndexPath];
        DLog(@"%.2f", progress*100.0);
        [self SetUploadProgressVal:progress IndexPath:IndexPath];
    }];
}

- (void)cancelUpload:(id)sender{
    if (![sender isMemberOfClass:[UIButton class]]) {
        return;
    }
    DBLocalTileDataManager *dataManager = [DBLocalTileDataManager instance];
    AuthHttpEngine *engine = [dataManager GetNetEngine];
    [engine cancelAllOperations];
    self.bIsUploading = NO;
    UIButton *button = (UIButton *)sender;
    button.hidden = YES;
    
    UITableViewCell *cell = (UITableViewCell *)button.superview.superview;
    UIView *sub = [cell viewWithTag:300];
    if ([sub isMemberOfClass:[AMProgressView class]]) {
        AMProgressView *progressView = (AMProgressView *)sub;
        [progressView setProgress:0.0f];
        progressView.hidden = YES;
    }
    
    sub = [cell viewWithTag:301];
    if ([sub isMemberOfClass:[UIButton class]]) {
        sub.hidden = NO;
    }
    
}

#pragma mark  单选信息编辑
-(void)SetReverseBtn:(NSIndexPath*)Path Val:(BOOL)bVal
{
    unsigned char nRow = 0x01 ^ Path.row;
    NSIndexPath *RevPath = [NSIndexPath indexPathForRow:nRow inSection:Path.section];
    UITableViewCell *cell = [TaskTableView cellForRowAtIndexPath:RevPath];
    
    NSInteger nTag = (Path.section + 1) * 100;
    UIButton *FlgBtn = (UIButton*)[cell viewWithTag:nTag];
    if (FlgBtn) {
        //
        [FlgBtn setSelected:bVal];
    }
}
- (void)FlagBtnTouched:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.selected) {
        return;
    }
    btn.selected = YES;
    UITableViewCell *cell = (UITableViewCell *)btn.superview.superview;
    NSIndexPath *indexPath = [TaskTableView indexPathForCell:cell];
    
    NSInteger section = indexPath.section;
    //NSInteger section = btn.tag / 100 + 1;
    //NSIndexPath *indexPath = [NSIndexPath indexPathForRow:indexPath1.row inSection:section];
    NSInteger row = indexPath.row;

    [self SetReverseBtn:indexPath Val:!btn.selected];
    unsigned char nVal = 0x01 ^ row;
    NSString *sVal = [NSString stringWithFormat:@"%d", nVal];
    if (section == 1){
        //  报建
        [self.XCRecordDataDic setObject:sVal forKey:IS_BJ_KEY_NAME];
    }else if (section == 2){
        // 动工
        [self.XCRecordDataDic setObject:sVal forKey:IS_DG_KEY_NAME];
    }else if (section == 3){
        // 开发
        [self.XCRecordDataDic setObject:sVal forKey:IS_KF_KEY_NAME];
    }else if (section == 4){
        // 竣工
        [self.XCRecordDataDic setObject:sVal forKey:IS_JG_KEY_NAME];
    }
}

- (void)TimeBtnTouched:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    UITableViewCell *cell = (UITableViewCell *)btn.superview.superview;
    [ChooseDateViewPopover presentPopoverFromRect:cell.frame inView:TaskView permittedArrowDirections:0 animated:YES];
}

- (void)chooseDateWith:(NSString *)DateStr
{
    if ([ChooseDateViewPopover isPopoverVisible]) {
        [ChooseDateViewPopover dismissPopoverAnimated:YES];
    }
    [self.XCRecordDataDic setObject:DateStr forKey:XC_DATE_KEY];
    [TaskTableView reloadData];
}

- (void)ChoosePicBtnTouched:(id)sender
{
    NSString *XCR = [self.XCRecordDataDic objectForKey:XCR_KEY];
    if ([XCR length] <= 0) {
     [self AlertMsg:@"" Message:@"巡察人员不能为空"];
     return;
     }
    
    UIButton *btn = (UIButton*)sender;
    DBChoosePicViewController *VCtrl = (DBChoosePicViewController*)[ChoosePicViewPopover contentViewController];
    [VCtrl setNFlg:btn.tag];
    [ChoosePicViewPopover presentPopoverFromRect:CGRectMake(352, 354, 320, 60) inView:TaskView permittedArrowDirections:0 animated:YES];
}

#pragma mark 照片编辑
- (void)DeletePicBtnTouched:(id)sender
{
    BOOL bRet = [TaskTableView isEditing];
    if (bRet) {
        nDelFileFlg = 0;
    }
    else{
        nDelFileFlg = 1;
    }
    [TaskTableView setEditing:!bRet];
    return;
}


#pragma mark 视频编辑
- (void)VideoDeletePicBtnTouched:(id)sender
{
    BOOL bRet = [TaskTableView isEditing];
    if (bRet) {
        nDelFileFlg = 0;
    }
    else{
        nDelFileFlg = 2;
    }
    [TaskTableView setEditing:!bRet];
    return;
}

#pragma mark 从相机添加
- (void)chooseBtnTouched:(NSInteger)index
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if ([ChoosePicViewPopover isPopoverVisible]) {
        [ChoosePicViewPopover dismissPopoverAnimated:YES];
    }
    if (index == 100) {
        // 照片
        [self addPicEvent:UIImagePickerControllerSourceTypeCamera];
    }else{
        // 视频
        [self addPicEvent:UIImagePickerControllerSourceTypeCamera];
    }
}
#pragma mark  从本地相册添加
- (void)chooseBtn2Touched:(NSInteger)index
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    if ([ChoosePicViewPopover isPopoverVisible]) {
        [ChoosePicViewPopover dismissPopoverAnimated:YES];
    }
    if (index == 100) {
        // 照片
        [self launchController];
    }else{
        // 视频
        [self addPicEventFromLocal:index];
    }
}

#pragma mark - UITextFieldDelegate Method
//改变键盘的类型
- (BOOL)textFieldShouldBeginEditing:(CellUITextField *)textField
{
    UITableViewCell *cell = (UITableViewCell *)textField.superview.superview;
    NSIndexPath *indexPath = [TaskTableView indexPathForCell:cell];
    [TaskTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    if (indexPath.section == 0) {
        textField.keyboardType = UIKeyboardTypeNamePhonePad;
    }else if (indexPath.section == 5){
        if (indexPath.row == 0) {
            textField.keyboardType = UIKeyboardTypeNamePhonePad;
        }else{
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }
    }else{
        if (indexPath.row == 0) {
            textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        }else{
            textField.keyboardType = UIKeyboardTypeNamePhonePad;
        }
    }
    
    return YES;
}

#pragma mark 巡察登记表基本信息编辑
- (void)textFieldTextDidChange:(NSNotification *)notification
{
    @try {
        id object = notification.object;
        if (![object isMemberOfClass:[CellUITextField class]]) {
            return;
        }
        
        bIsEditing = YES; // 数据已被编辑， 提示保存
        
        CellUITextField *textField = (CellUITextField *)object;
        NSIndexPath *indexPath = [textField CellPath];
        NSInteger section = indexPath.section;
        NSInteger row = indexPath.row;
        NSInteger nLen = [textField.text length];
        NSString *value = nLen <= 0 ? @"" : textField.text;
        if (section == 0) {
            if (row == 0) {
                // 权力人
                [self.XCRecordDataDic setObject:value forKey:SRR_KEY];
            }else if (row == 1){
                //
                [self.XCRecordDataDic setObject:value forKey:AREA_KEY];
            }else if (row == 2){
                //
                [self.XCRecordDataDic setObject:value forKey:ADDRESS_KEY];
            }
        }else if (section == 1){
            if (row == 0) {
                // 工程规划许可证编号
                [self.XCRecordDataDic setObject:value forKey:GCGHXKZBH_KEY];
            }else if (row == 1){
                //  没有报建的原因
                [self.XCRecordDataDic setObject:value forKey:BJQK_REASON_KEY];
            }
        }else if (section == 2){
            if (row == 1) {
                //  没有动工的原因
                [self.XCRecordDataDic setObject:value forKey:DGQK_REASON_KEY];
            }
        }else if (section == 3){
            if (row == 0) {
                // 开发建设比例
                [self.XCRecordDataDic setObject:value forKey:KF_PERCENT_KEY];
            }else if (row == 1){
                // 没有开发的原因
                [self.XCRecordDataDic setObject:value forKey:KFQK_REASON_KEY];
            }
        }else if (section == 4){
            if (row == 0) {
                //  竣工验收合格证编号
                [self.XCRecordDataDic setObject:value forKey:JGYSHGZBH_KEY];
            }else if (row == 1){
                // 没有竣工的原因
                [self.XCRecordDataDic setObject:value forKey:JGQK_REASON_KEY];
            }
        }else if (section == 5){
            if (row == 0) {
                // 巡察人
                // 检查是否需要修改存储文件名称
                NSString *XCR = [self.XCRecordDataDic objectForKey:XCR_KEY];
                if ([XCR length] > 0) {
                    if (![XCR isEqualToString:value]) {
                        if ([self.CurrentXCRecordFileName length] > 0)
                        {// 当前巡查记录已经保存为本地文件
                            // 删除原来的文件
                            NSString *FileFullDir = [self GetCurrentBaseDataDir];
                            NSString *fileName = [self GetCurrentBaseDataFileName];
                            if (([fileName length] <= 0) || ([FileFullDir length] <= 0))  {
                                return;
                            }
                            NSString *FileFullPath = [NSString stringWithFormat:@"%@/%@", FileFullDir, fileName];
                            NSFileManager *fileMan = [NSFileManager defaultManager];
                            // Document 目录是否存在
                            NSError *err;
                            if ([fileMan fileExistsAtPath:FileFullPath])
                            {
                                [fileMan removeItemAtPath:FileFullPath error:&err];
                            }
                            
                            // 重新保存文件
                            self.CurrentXCRecordFileName = nil;
                            [self.XCRecordDataDic setObject:value forKey:XCR_KEY];
                            [self BaseDataSaveBtnTouched:nil];
                            return;
                        }
                    }
                }
                [self.XCRecordDataDic setObject:value forKey:XCR_KEY];
                
            }else if (row == 1){
                // 巡察日期
                [self.XCRecordDataDic setObject:value forKey:XC_DATE_KEY];
            }
        }
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

- (BOOL)textFieldShouldReturn:(CellUITextField *)textField
{
    
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    textView.returnKeyType = UIReturnKeyDone;
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    UITableViewCell *cell = (UITableViewCell *)textView.superview.superview;
    NSIndexPath *indexPath = [TaskTableView indexPathForCell:cell];
    [TaskTableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.contentSize.height > 100) {
        return NO;
    }
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    @try {
        UITableViewCell *cell = (UITableViewCell *)textView.superview.superview;
        NSIndexPath *indexPath = [TaskTableView indexPathForCell:cell];
        
        NSInteger row = [cell tag];
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        if (indexPath.section == PIC_SECTION) {
            [dic setDictionary:[self.XCRecordImagesArr objectAtIndex:row]];
            [dic setObject:textView.text forKey:@"ImageNote"];
            [self.XCRecordImagesArr replaceObjectAtIndex:row withObject:dic];
        }else if (indexPath.section == VIDEO_SECTION){
            [dic setDictionary:[self.XCRecordVideosArr objectAtIndex:row]];
            [dic setObject:textView.text forKey:@"VideoNote"];
            [self.XCRecordVideosArr replaceObjectAtIndex:row withObject:dic];
        }
        
        [textView resignFirstResponder];

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

#pragma mark - 从本地相册添加
- (void) addPicEventFromLocal:(int)nOpenType
{
    self.imgPicker = [[UIImagePickerController alloc] init];
    self.imgPicker.delegate = self;
    self.imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    if (nOpenType == 100) {
        // pic
        self.imgPicker.mediaTypes =
        [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMPEG, nil];
    }
    else{
        // video
        self.imgPicker.mediaTypes =
        [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, (NSString*)kUTTypeVideo, (NSString*)kUTTypeQuickTimeMovie, nil];
    }

    UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:self.imgPicker];
    //popover.delegate = self;
    float fWidth = 500.0f;
    float fHeight = 400.0f;
    popover.popoverContentSize = CGSizeMake(fWidth, fHeight);
    self.popoverController = popover;
    // Present the popover from the button that was tapped in the detail view.

    float fXpos = 1024 / 2 - fWidth / 2;
    float fYpos = 748 / 2 - fHeight / 2;
    CGRect frame = CGRectMake(fXpos, fYpos, fWidth, fHeight);
    [self.popoverController presentPopoverFromRect:frame inView:self.view permittedArrowDirections:0 animated:YES];
}
#pragma mark - 选择图片
- (void) addPicEvent:(int)nOpenType
{
	//先设定sourceType为相机，然后判断相机是否可用（ipod）没相机，不可用将sourceType设定为相片库
	UIImagePickerControllerSourceType sourceType = nOpenType;
    
    if(nOpenType == UIImagePickerControllerSourceTypeCamera)
    {
        if(![UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
        {
            sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = sourceType;
    NSArray *sourceTypes = [UIImagePickerController availableMediaTypesForSourceType:picker.sourceType];
    if ([sourceTypes containsObject:(NSString *)kUTTypeMovie ])
    {
        picker.mediaTypes= [NSArray arrayWithObjects:(NSString *)kUTTypeMovie,(NSString *)kUTTypeImage,nil];
    }
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0)
    {
        [self presentViewController:picker animated:YES completion:nil];
    }
    else {
        [self presentModalViewController:picker animated:YES];
    }
    
    [self.view bringSubviewToFront:picker.view];
}


- (void)launchController
{
    ELCAlbumPickerController *albumController = [[ELCAlbumPickerController alloc] initWithNibName: nil bundle: nil];
	ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initWithRootViewController:albumController];
    [albumController setParent:elcPicker];
    elcPicker.view.frame = CGRectMake(0, 0, 1024, 768);
	[elcPicker setDelegate:self];
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 5.0)
    {
        [self presentViewController:elcPicker animated:YES completion:nil];
    }
    else {
        [self presentModalViewController:elcPicker animated:YES];
    }
    
    [self.view bringSubviewToFront:elcPicker.view];
}


#pragma mark - 1.拍摄照片完成  2.选择本地视频完成  3.拍摄视频完成
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    @try {
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 5.0)
        {
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [picker dismissModalViewControllerAnimated:YES];
        }
        
        NSString *dkId = [_DBXCDKDataDic valueForKey:@"Id"];
        NSString *FileFullDir = [self GetCurrentTaskFileDir:dkId];
        if ([FileFullDir length] <= 0) {
            return;
        }
        NSString *fileFullPath;
        NSString *fileName;
        // 以地块ID+当前时间+巡察人为文件名
        NSString *sDate = [self GettimeIntervalSince1970];
        NSString *XCR = [self.XCRecordDataDic objectForKey:XCR_KEY];
        /*if ([XCR length] <= 0) {
            [self AlertMsg:@"" Message:@"巡察人员不能为空"];
            return;
        }*/
        // 图片类型
        if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeImage]) {
            UIImage* image = [info objectForKey:UIImagePickerControllerOriginalImage];
            // 保存到沙盒
            NSData *imageData = UIImagePNGRepresentation(image);
            fileName = [NSString stringWithFormat:@"%@_%@_%@.png", dkId, sDate, XCR];
            fileFullPath = [NSString stringWithFormat:@"%@/%@", FileFullDir, fileName];
            [imageData writeToFile:fileFullPath atomically:YES];
            //NSDictionary *dic = [NSDictionary dictionaryWithObject:fileFullPath forKey:@"ImagePath"];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
            [dic setObject:fileFullPath forKey:@"ImagePath"];
            // 上传状态
            [dic setObject:@"0" forKey:@"UploadState"];
            [self.XCRecordImagesArr addObject:dic];
            
            // 将图片保存到相册
            UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqualToString:(NSString*)kUTTypeMovie]) {
            // 视频类型 kut什么的定义需要 MobileCoreServices.framework 支持
            NSString* path = [[info objectForKey:UIImagePickerControllerMediaURL] path];
            // 保存视频
            UISaveVideoAtPathToSavedPhotosAlbum(path, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            
            // 保存到沙盒
            NSData *VideoData = [NSData dataWithContentsOfFile:path];
            
            // 存储在应用程序指定目录下
            fileName = [NSString stringWithFormat:@"%@_%@_%@.mov", dkId, sDate, XCR];
            fileFullPath = [NSString stringWithFormat:@"%@/%@", FileFullDir, fileName];
            
            [VideoData writeToFile:fileFullPath atomically:YES];
            
            //NSDictionary *dic = [NSDictionary dictionaryWithObject:fileFullPath forKey:@"VideoPath"];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
            [dic setObject:fileFullPath forKey:@"VideoPath"];
            // 上传状态
            [dic setObject:@"0" forKey:@"UploadState"];
            
            NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
            //获取视频的某一帧作为预览
            NSString *PreviewFileName = [NSString stringWithFormat:@"%@_%@_%@.jpg", dkId, sDate, XCR];
            NSString *PreviewImagePath = [NSString stringWithFormat:@"%@/%@", FileFullDir, PreviewFileName];
            [dic setObject:PreviewImagePath forKey:@"PreviewVideoPath"];
            [self.XCRecordVideosArr addObject:dic];
            [self getPreViewImg:url SavePath:PreviewImagePath];
        }
        
        if ([self.popoverController isPopoverVisible]) {
            [self.popoverController dismissPopoverAnimated:YES];
        }
        bIsEditing = YES;
        [TaskTableView reloadData];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
 
}

-(void)getPreViewImg:(NSURL *)url SavePath:(NSString*)SavePath
{
    @try {
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 600);
        NSError *error = nil;
        CMTime actualTime;
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *img = [[UIImage alloc] initWithCGImage:image];
        CGImageRelease(image);
        
        NSData *imageData = UIImagePNGRepresentation(img);
        [imageData writeToFile:SavePath atomically:YES];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

#pragma mark 图片保存完成回调
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
#pragma mark 视频保存完成回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

#pragma mark 选择本地相册图片完成
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    @try {
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 5.0)
        {
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [picker dismissModalViewControllerAnimated:YES];
        }
        
        for(int i = 0; i < info.count; i++)
        {
            NSDictionary *dict = [info objectAtIndex:i];
            UIImage *image = [dict objectForKey:UIImagePickerControllerOriginalImage];
            NSData *imageData = UIImagePNGRepresentation(image);
            
            // 存储文件
            NSString *dkId = [_DBXCDKDataDic valueForKey:@"Id"];
            NSString *FileFullDir = [self GetCurrentTaskFileDir:dkId];
            if ([FileFullDir length] <= 0) {
                return;
            }
            
            // 存储在应用程序指定目录下
            NSString *fileFullPath;
            NSString *fileName;
            // 以地块ID+当前时间+巡察人为文件名
            NSString *sDate = [self GettimeIntervalSince1970];
            NSString *XCR = [self.XCRecordDataDic objectForKey:XCR_KEY];
            /*if ([XCR length] <= 0) {
                [self AlertMsg:@"" Message:@"巡察人员不能为空"];
                return;
            }*/
            fileName = [NSString stringWithFormat:@"%@_%@_%@_%d.png", dkId, sDate, XCR, i];
            fileFullPath = [NSString stringWithFormat:@"%@/%@", FileFullDir, fileName];
            
            
            BOOL bRet = [imageData writeToFile:fileFullPath atomically:YES];
            if (!bRet) {
                [self AlertMsg:@"" Message:@"存储图片失败"];
                return;
            }
            //NSDictionary *dic = [NSDictionary dictionaryWithObject:fileFullPath forKey:@"ImagePath"];
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:3];
            [dic setObject:fileFullPath forKey:@"ImagePath"];
            // 上传状态
            [dic setObject:@"0" forKey:@"UploadState"];
            [self.XCRecordImagesArr addObject:dic];
        }
        bIsEditing = YES;
        [TaskTableView reloadData];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }

}

#pragma mark 从相机选择图片/视频取消
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    @try {
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 5.0)
        {
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [picker dismissModalViewControllerAnimated:YES];
        }
        [picker dismissModalViewControllerAnimated:YES];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
}

#pragma mark 从本地相册选择图片/视频取消
- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    @try {
        float version = [[[UIDevice currentDevice] systemVersion] floatValue];
        if (version >= 5.0)
        {
            [picker dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            [picker dismissModalViewControllerAnimated:YES];
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }

}

//reloadView
- (void)SubjectViewReloadData
{
    @try {
        NSString *Id = [_DBXCDKDataDic valueForKey:@"Id"];
        [self LoadLocalXCRecord:Id];
        
        [self.LandInfoTableView reloadData];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }
}

#pragma mark 基本信息上传完成代理
- (void)XCDKRecordUploadError:(NSDictionary *)result{
    
}

- (void)XCDKRecordUploadFinish:(NSDictionary *)result{
    bIsUploaded = YES;
    bIsEditing = NO;
    @try {
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:filePath]) {
            NSError *error = nil;
            [fileManager removeItemAtPath:filePath error:&error];
        }
        
        NSMutableDictionary *recordInfo = [NSMutableDictionary dictionaryWithCapacity:3];
        [recordInfo setObject:[result objectForKey:@"XCRecordId"] forKey:@"Id"];
        [recordInfo setObject:[result objectForKey:@"XC_Date"] forKey:@"Date"];
        [recordInfo setObject:[result objectForKey:@"XCR"] forKey:@"XCR"];
        [_netXCRecordFileArr addObject:recordInfo];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
}

- (void)tapGesture:(UITapGestureRecognizer *)recognizer{
    UIImageView *view = (UIImageView *)recognizer.view;
    UITableViewCell *cell = (UITableViewCell *)view.superview.superview;
    NSIndexPath *indexPath = [TaskTableView indexPathForCell:cell];
    NSString *url = nil;
    if (indexPath.section == PIC_SECTION) {
        NSDictionary *picData = [self.XCRecordImagesArr objectAtIndex:indexPath.row];
        if ([@"0" isEqualToString:[picData objectForKey:@"UploadState"]]) {
            [self AlertMsg:@"用户未上传该文件" Message:nil];
            return;
        }
        //本地存在直接预览
        NSString *fileFullPath = [self checkFileExits:[picData objectForKey:@"ImagePath"]];
        if (fileFullPath != nil) {
            [self previewImage:fileFullPath];
            return;
        }
        
        DBLocalTileDataManager *dataManager = [DBLocalTileDataManager instance];
        //拼接URL
        NSString *baseURL = [dataManager.TopicWebServiceUrl substringToIndex:[dataManager.TopicWebServiceUrl rangeOfString:@"/GoverDeciServerPort"].location];
        url = [NSString stringWithFormat:@"%@%@", baseURL, [picData objectForKey:@"Path"]];
        
        MKNetworkEngine *engine = [dataManager GetNetEngine];
        MKNetworkOperation *operation = [engine imageAtURL:[NSURL URLWithString:
                                                            [url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]
                                         completionHandler:^(UIImage *fetchedImage, NSURL *url, BOOL isIncache){
            view.image = fetchedImage;
            //保存到本地
            NSString *fileFullPath = [self saveImageToDisk:fetchedImage url:url];
            [self previewImage:fileFullPath];
            UIView *view = [cell viewWithTag:300];
            view.hidden = YES;
            
        } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error){
            [self AlertMsg:@"图片下载失败" Message:nil];
            UIView *view = [cell viewWithTag:300];
            view.hidden = YES;
        }];
        
        [operation onDownloadProgressChanged:^(double progress, MKNetworkOperation *operation){
            UIView *view = [cell viewWithTag:300];
            if([view isKindOfClass:[AMProgressView class]])
            {
                AMProgressView *PView = (AMProgressView*)view;
                PView.hidden = NO;
                [PView setProgress:progress];
            }
        }];
        
    } else if (indexPath.section == VIDEO_SECTION){
        NSDictionary *videoData = [self.XCRecordVideosArr objectAtIndex:indexPath.row];
        DBLocalTileDataManager *dataManager = [DBLocalTileDataManager instance];
        //拼接URL
        NSString *baseURL = [dataManager.TopicWebServiceUrl substringToIndex:[dataManager.TopicWebServiceUrl rangeOfString:@"/GoverDeciServerPort"].location];
        url = [NSString stringWithFormat:@"%@%@", baseURL, [videoData objectForKey:@"Path"]];
        MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        
        [self presentMoviePlayerViewControllerAnimated:player];
    }
}
// 保存文件至硬盘
- (NSString *)saveImageToDisk:(UIImage *)fetchedImage url:(NSURL *)url{
    NSString *dkId = [_DBXCDKDataDic valueForKey:@"Id"];
    NSString *FileFullDir = [self GetCurrentTaskFileDir:dkId];
    NSString *fileName = [url lastPathComponent];
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@", FileFullDir, fileName];
    
    NSData *imageData = UIImagePNGRepresentation(fetchedImage);
    [imageData writeToFile:fileFullPath atomically:YES];
    
    return fileFullPath;
}

//预览文件
- (void)previewImage:(NSString *)fileFullPath{
    QLPreviewController *previewer = [[QLPreviewController alloc] init];
    DBPreviewDataSource *dataSource = [[DBPreviewDataSource alloc] init];
    dataSource.path = fileFullPath;
    previewer.dataSource = dataSource;
    [self presentViewController:previewer animated:YES completion:nil];
}

//检查文件是否存在
- (NSString *)checkFileExits:(NSString *)fileName{
    NSString *dkId = [_DBXCDKDataDic valueForKey:@"Id"];
    NSString *FileFullDir = [self GetCurrentTaskFileDir:dkId];
    NSString *fileFullPath = [NSString stringWithFormat:@"%@/%@", FileFullDir, fileName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:fileFullPath]) {
        return fileFullPath;
    }
    return nil;
}

- (void)hiddenKeyboard:(UIView *)view{
    
    if ([view isKindOfClass:[CellUITextField class]] || [view isKindOfClass:[UITextView class]]) {
        if ([view isFirstResponder]) {
            [view resignFirstResponder];
        }
        return;
    }
    
    for (UIView *sub in view.subviews) {
        [self hiddenKeyboard:sub];
    }
}

@end
