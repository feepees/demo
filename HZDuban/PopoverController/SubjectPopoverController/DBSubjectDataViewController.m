//
//  DBSubjectDataViewController.m
//  HZDuban
//
//  Created by mac on 12-8-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBSubjectDataViewController.h"
#import "DBTopicDKDataItem.h"
#import "DBTopicAnnexDataItem.h"
//#import "ASIHTTPRequest.h"
#import "DBQueue.h"
#import "Logger.h"
#import "MJPhoto.h"
#import "MJPhotoBrowser.h"
#import "UIImageView+MJWebCache.h"
#import "CommHeader.h"


@interface DBSubjectDataViewController ()<UIGestureRecognizerDelegate, MJPhotoBrowserDelegate>
{
//    // ASI 下载
//    ASIHTTPRequest * _ASIRequest;
    // for queue
    NSOperationQueue *_ASIQueue;
    
    // 附件下载队列
    DBQueue *_AnnexNameQueue;
    
    NSMutableDictionary *_AnnexDownloadCompleteFlgDic;
    
    //CloseBtn的图片，默认为CloseViewBtn
    BOOL bDownloadFlg;
    //议题ID
    NSString *_TopicId;
    //议题所属会议ID
    NSString *_TopicOwnerId;
    //标记CloseBtn的图片状态
    BOOL bCloseBtnFlg;
    MJPhotoBrowser *_photoBrowser;
}

@end

@implementation DBSubjectDataViewController
@synthesize RootView, SubDataView, SubView, GPRSBtn, ClosedBtn, UpdateBtn, segmentedContl, SubDataTableView;
@synthesize BaseDataWebView;
@synthesize AccessoryDataArray;
@synthesize SubjectDataItem;
@synthesize delegate;
@synthesize DKDataDelegate;
@synthesize DragViewDelegate;
@synthesize bCloseBtnFlg = _bCloseBtnFlg;

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector 
{  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);  
    return [super respondsToSelector:aSelector];  
}  
#endif


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _AnnexNameQueue = [[DBQueue alloc] init];
        _AnnexDownloadCompleteFlgDic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

#pragma mark - CustomMethods
//重新加载地块数据
- (void)ReloadLandData:(NSString*)TopicId
{
    _TopicId = [TopicId copy];
//    [LandDataTabView reloadData];
    [SubDataTableView reloadData];
    // 定位地块
    [self GPRSBtnTouched:nil];
}

// 重新加载基本情况数据
- (void)ReloadReasonData:(NSString*)TopicId
{
    _TopicId = [TopicId copy];
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    // 加载基本情况数据
    NSString *ReasonStr = [[DataMan TopicsReason] valueForKey:TopicId];
    if ([ReasonStr length] > 0) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDir = [paths objectAtIndex:0]; 
        NSString * BaseDir = [NSString stringWithFormat:@"%@/", documentsDir];
        //NSURL * apiurl = [NSURL URLWithString:BaseDir];
        NSURL * apiurl = [NSURL URLWithString:[BaseDir stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        [BaseDataWebView loadHTMLString:ReasonStr baseURL:apiurl];
        [_BaseDataFullScreenWebView loadHTMLString:ReasonStr baseURL:apiurl];
//        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://news.163.com/15/0802/01/AVVOAI2500014AED.html"]];
//        [BaseDataWebView loadRequest:req];
    }
    [SubDataTableView reloadData];
    // 加载附件数据
    [_AccessoryTabView reloadData];
    
}

// 清除议题详细数据
- (void)CleanTopicDetailData:(NSString*)TopicID
{
    @try {
        // 消除基本情况数据
        NSString *ReasonStr = @"";
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDir = [paths objectAtIndex:0]; 
        NSString * BaseDir = [NSString stringWithFormat:@"%@/", documentsDir];
        //NSURL * apiurl = [NSURL URLWithString:BaseDir];
        NSURL * apiurl = [NSURL URLWithString:[BaseDir stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

//        [BaseDataWebView loadHTMLString:ReasonStr baseURL:apiurl];
//        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://news.163.com/15/0802/01/AVVOAI2500014AED.html"]];
//        [BaseDataWebView loadRequest:req];
//        [_BaseDataFullScreenWebView loadRequest:req];
        
        [self setSubjectDataItem:nil];
        
        // 清除地块数据
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        [[[DataMan TopicsDKDataDic] objectForKey:TopicID ] removeAllObjects];
        [[[DataMan TopicIDToFeatureDic] objectForKey:TopicID] removeAllObjects];
        [[[DataMan TopicsAnnexDic] objectForKey:TopicID] removeAllObjects];
        //
        // 清除地图上所有地块的Graphic
        //...
        
//        [LandDataTabView reloadData];
        [SubDataTableView reloadData];
        
        // 清除附件数据
        // 清除当前议题的附件文件
        NSString *TilesDir = [documentsDir stringByAppendingPathComponent:@"AnnexFiles"];
        NSString *subDir = [NSString stringWithFormat:@"%@", TopicID];
        NSString *TopicTilesDir = [TilesDir stringByAppendingPathComponent:subDir];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:TopicTilesDir];
        if (bRet) {
            // 
            NSError *err;
            [fileMgr removeItemAtPath:TilesDir error:&err];
        }

        [_AccessoryTabView reloadData];

    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        
    }

}

//reloadView
- (void)SubjectViewReloadData
{
    //恢复初始状态
    [ClosedBtn setImage:[UIImage imageNamed:@"CloseViewBtn.png"] forState:UIControlStateNormal];
    segmentedContl.selectedSegmentIndex = 0;
    [SubView bringSubviewToFront:BaseDataWebView];
    [self initDataSource];
    //刷新view
    [SubDataTableView reloadData];
    [_AccessoryTabView reloadData];
//    [LandDataTabView reloadData];
}

- (void)initDataSource
{
    if(SubjectDataItem != nil){
        _TopicId = [SubjectDataItem.Id copy];
        _TopicOwnerId = [SubjectDataItem.OwnerMeetringID copy];
    }
    //默认CloseBtn显示的是CloseViewBtn.png，bCloseBtnFlg为YES。
    bCloseBtnFlg = YES;
    NSString *ContentString = SubjectDataItem.Reason;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDir = [paths objectAtIndex:0]; 
    NSString * BaseDir = [NSString stringWithFormat:@"%@/", documentsDir];
    //NSURL * apiurl = [NSURL URLWithString:BaseDir];
    NSURL * apiurl = [NSURL URLWithString:[BaseDir stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    if ([ContentString length] > 0) {
//        [BaseDataWebView loadHTMLString:ContentString baseURL:apiurl];
//        NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://news.163.com/15/0802/01/AVVOAI2500014AED.html"]];
//        [BaseDataWebView loadRequest:req];
    }
    
    //self.LandDataArray = [NSArray arrayWithObjects:@"小金口柏岗旧厂房", @"小金口柏岗旧工厂", @"小金口柏岗员工旧宿舍", nil];
    self.AccessoryDataArray = [NSArray arrayWithObjects:@"相关文档", @"相关图片", nil];
}

#pragma mark - view lifeCycle

- (void)viewWillAppear:(BOOL)animated
{
    [self initDataSource];
}

-(void)SetViewsFrame:(CGFloat)fWidth
{
    CGRect rect = [self.RootView frame];
//    CGFloat fWidth = SCREEN_WIDTH / 2;
    rect.size.width = fWidth;
    
    CGFloat fHeight = [UIScreen mainScreen].bounds.size.width - 44 - 20;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.999)
    {
        fHeight = [UIScreen mainScreen].bounds.size.width - 44;
    }
    rect.size.height = fHeight;
    [self.RootView setFrame:rect];
    
    // add by niurg 2015.12.20
    CGRect rectTmp = SubDataView.frame;
    CGFloat fwidth = SCREEN_HEIGHT;
    CGFloat fheigth = SCREEN_WIDTH;
    CGFloat fwidth2 = SCREEN_HEIGHT2;
    CGFloat fheigth2 = SCREEN_WIDTH2;
    
    rectTmp.size.height = fwidth - 50 - 44;
    
    rectTmp.origin.y = 50;
    _BaseDataFullScreenView.frame = rectTmp;
    rectTmp.origin.y = 0;
    _BaseDataFullScreenWebView.frame = rectTmp;
    // end
    
    fWidth -= 3.f;
    rect = [self.SubDataView frame];
    rect.size.width = fWidth;
    [self.SubDataView setFrame:rect];
    
    rect = [self.SubDataTableView frame];
    rect.size.width = fWidth;
    [self.SubDataTableView setFrame:rect];
    
    rect = [self.segmentedContl frame];
    rect.size.width = fWidth;
    [self.segmentedContl setFrame:rect];
    
    rect = [self.SubView frame];
    rect.size.width = fWidth;
    [self.SubView setFrame:rect];
    
    rect = [self.ClosedBtn frame];
    rect.origin.x = fWidth - 5;
    [self.ClosedBtn setFrame:rect];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
    
}

////呈现图片
//-(void)showImageURL:(NSString *)url point:(CGPoint)point
//{
//    UIImageView *showView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-44)];
////    showView.center = point;
//    [UIView animateWithDuration:0.5f animations:^{
//        CGPoint newPoint = self.view.center;
//        newPoint.y += 20;
//        showView.center = newPoint;
//    }];
//    
//    showView.backgroundColor = [UIColor blackColor];
//    showView.alpha = 0.9;
//    showView.userInteractionEnabled = YES;
//    [self.view addSubview:showView];
//    [showView setImageWithURL:[NSURL URLWithString:url]];
//    
//    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleViewTap:)];
//    [showView addGestureRecognizer:singleTap];
//    
//    [self.navigationController setNavigationBarHidden:YES animated:YES];
//}


-(void) singleWebViewTap :(UITapGestureRecognizer*) sender
{
//    //  <Find HTML tag which was clicked by user>
//    //  <If tag is IMG, then get image URL and start saving>
//    int scrollPositionY = [[BaseDataWebView stringByEvaluatingJavaScriptFromString:@"window.pageYOffset"] intValue];
//    int scrollPositionX = [[BaseDataWebView stringByEvaluatingJavaScriptFromString:@"window.pageXOffset"] intValue];
//    
//    int displayWidth = [[BaseDataWebView stringByEvaluatingJavaScriptFromString:@"window.outerWidth"] intValue];
//    CGFloat scale = BaseDataWebView.frame.size.width / displayWidth;
//    
//    CGPoint pt = [sender locationInView:BaseDataWebView];
//    pt.x *= scale;
//    pt.y *= scale;
//    pt.x += scrollPositionX;
//    pt.y += scrollPositionY;
//    
//    NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", pt.x, pt.y];
//    NSString * tagName = [BaseDataWebView stringByEvaluatingJavaScriptFromString:js];
//    if ([tagName isEqualToString:@"img"]) {
//        NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
//        NSString *urlToSave = [BaseDataWebView stringByEvaluatingJavaScriptFromString:imgURL];
//        NSLog(@"image url=%@", urlToSave);
//    }
    
    CGPoint pt = [sender locationInView:BaseDataWebView];
    // 获取当前点击的图片
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
    NSString *tapImageUrl = [BaseDataWebView stringByEvaluatingJavaScriptFromString:imgURL];
    
    // 获取当前页面中图片个数
    NSString *getImgCnt = @"document.getElementsByTagName(\"img\").length";
    NSString *imgCnt = [BaseDataWebView stringByEvaluatingJavaScriptFromString:getImgCnt];
    NSInteger nTotalImageCnt = [imgCnt integerValue];
//    NSMutableArray *imageUrls = [NSMutableArray arrayWithCapacity:];
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:nTotalImageCnt];
    // 当前点击的是第几张图片
    int nCurrTapIndex = 0;
    BOOL bHas = NO;
    for (int nIndex = 0; nIndex < nTotalImageCnt; nIndex++) {
        //
        NSString *getImgJs = [NSString stringWithFormat:@"document.getElementsByTagName(\"img\")[%d].src", nIndex];
        NSString *imgUrl = [BaseDataWebView stringByEvaluatingJavaScriptFromString:getImgJs];
        if (imgUrl.length > 0) {
//            [imageUrls addObject:imgUrl];
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString:imgUrl]; // 图片路径
            [photos addObject:photo];
            bHas = YES;
            if ([imgUrl isEqualToString:tapImageUrl]) {
                nCurrTapIndex = nIndex;
            }
        }
    }
    
    if (bHas) {
        // 2.显示相册
        _photoBrowser = [[MJPhotoBrowser alloc] init];
        [_photoBrowser setDelegate:self];
        _photoBrowser.currentPhotoIndex = nCurrTapIndex; // 弹出相册时显示的第一张图片是？
        _photoBrowser.photos = photos; // 设置所有的图片
//#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
//        _photoBrowser.wantsFullScreenLayout = YES;//是否全屏
//        _photoBrowser.automaticallyAdjustsScrollViewInsets = YES;
        
//#endif
        [_photoBrowser show];
//        [self presentViewController:_photoBrowser animated:YES completion:nil];
    }

    return;
}

// add by niurg 2016.02.20 for 动态调整字体大小 begin
float fontSizeScaleRate = 1.0;
// 字体缩放最大倍数
#define Font_Size_Max_Times  2.0
// 字体缩放最小倍数
#define Font_Size_Min_Times  1.0
// 字体缩放级别值
#define Font_Size_Differ    0.1
-(void)PinchWebViewGesture:(UIPinchGestureRecognizer*)gesture
{
//    if (gesture.state==UIGestureRecognizerStateEnded | gesture.state==UIGestureRecognizerStateCancelled) {
    if(gesture.state == UIGestureRecognizerStateChanged)
    {
//        NSString *js = @"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '200%'";
        NSString *js = @"";
        
        if (gesture.scale<1.0)
        {
            fontSizeScaleRate<=Font_Size_Min_Times?fontSizeScaleRate:(fontSizeScaleRate -= Font_Size_Differ);
            
//            js = [NSString stringWithFormat:@"document.body.style.fontSize = \"%.0f",fontSizeScaleRate*100];
            js = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%.0f%%'",fontSizeScaleRate*100];
        }
        else
        {
            fontSizeScaleRate>=Font_Size_Max_Times?fontSizeScaleRate:(fontSizeScaleRate += Font_Size_Differ);
            js = [NSString stringWithFormat:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '%.0f%%'",fontSizeScaleRate*100];
        }
        NSLog(@"font size:%@", js);
        
        [BaseDataWebView stringByEvaluatingJavaScriptFromString:js];
        [_BaseDataFullScreenWebView stringByEvaluatingJavaScriptFromString:js];
    }
    
    return;
}
// end

// add by niurg 2015.12.20
-(void) SingleFullScreenWebViewTap :(UITapGestureRecognizer*) sender
{
    CGPoint pt = [sender locationInView:_BaseDataFullScreenWebView];
    // 获取当前点击的图片
    NSString *imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", pt.x, pt.y];
    NSString *tapImageUrl = [_BaseDataFullScreenWebView stringByEvaluatingJavaScriptFromString:imgURL];
    
    // 获取当前页面中图片个数
    NSString *getImgCnt = @"document.getElementsByTagName(\"img\").length";
    NSString *imgCnt = [_BaseDataFullScreenWebView stringByEvaluatingJavaScriptFromString:getImgCnt];
    NSInteger nTotalImageCnt = [imgCnt integerValue];
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:nTotalImageCnt];
    // 当前点击的是第几张图片
    int nCurrTapIndex = 0;
    BOOL bHas = NO;
    for (int nIndex = 0; nIndex < nTotalImageCnt; nIndex++) {
        //
        NSString *getImgJs = [NSString stringWithFormat:@"document.getElementsByTagName(\"img\")[%d].src", nIndex];
        NSString *imgUrl = [_BaseDataFullScreenWebView stringByEvaluatingJavaScriptFromString:getImgJs];
        if (imgUrl.length > 0)
        {
            MJPhoto *photo = [[MJPhoto alloc] init];
            photo.url = [NSURL URLWithString:imgUrl]; // 图片路径
            [photos addObject:photo];
            bHas = YES;
            if ([imgUrl isEqualToString:tapImageUrl]) {
                nCurrTapIndex = nIndex;
            }
        }
    }
    
    if (bHas) {
        // 2.显示相册
        _photoBrowser = [[MJPhotoBrowser alloc] init];
        [_photoBrowser setDelegate:self];
        _photoBrowser.currentPhotoIndex = nCurrTapIndex; // 弹出相册时显示的第一张图片是？
        _photoBrowser.photos = photos; // 设置所有的图片
        [_photoBrowser show];
    }
    
    return;
}
//end

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // 初始为屏幕宽度一半
    CGFloat fWidth = SCREEN_WIDTH * 0.6;
    //[self.view setBackgroundColor:[UIColor redColor]];
    
    //上部显示基本信息的TableView
//    SubDataTableView.scrollEnabled = NO;
    SubDataTableView.delegate = self;
    SubDataTableView.dataSource = self;
    
    //基本情况
    // chg 2015.11.22
//    BaseDataWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 30, fWidth - 3, 409)];
    BaseDataWebView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 30, fWidth, 409)];
    // end
    
    BaseDataWebView.delegate = self;
    BaseDataWebView.backgroundColor = [UIColor grayColor];
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleWebViewTap:)];
    singleTap.numberOfTouchesRequired = 1;
    singleTap.delegate = self;
    [BaseDataWebView addGestureRecognizer:singleTap];
    BaseDataWebView.userInteractionEnabled = YES;
    [SubView addSubview:BaseDataWebView];
    [BaseDataWebView release];
    
    // add by niurg 2015.12.20
    _BaseDataFullScreenWebView.delegate = self;
    _BaseDataFullScreenWebView.backgroundColor = [UIColor grayColor];
    UITapGestureRecognizer *singleTap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(SingleFullScreenWebViewTap:)];
    singleTap2.numberOfTouchesRequired = 1;
    singleTap2.delegate = self;
    [_BaseDataFullScreenWebView addGestureRecognizer:singleTap2];
    _BaseDataFullScreenWebView.userInteractionEnabled = YES;
    // end
    // add by niurg 2016.01.20
    // 增加字体缩放的手势操作
    UIPinchGestureRecognizer *pinchGes1 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(PinchWebViewGesture:)];
    [_BaseDataFullScreenWebView addGestureRecognizer:pinchGes1];
    
    UIPinchGestureRecognizer *pinchGes2 = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(PinchWebViewGesture:)];
    [BaseDataWebView addGestureRecognizer:pinchGes2];
    
    // end
    
//    //地块信息
//    LandIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 29, fWidth - 3, 29)];
//    LandIDLabel.textAlignment = UITextAlignmentCenter;
//    LandIDLabel.text = @"地块编号";
//    LandIDLabel.backgroundColor = [UIColor grayColor];
//    [SubView addSubview:LandIDLabel];
//    [LandIDLabel release];
    
//    LandDataTabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 58, fWidth - 3, 395)];
//    LandDataTabView.delegate = self;
//    LandDataTabView.dataSource = self;
//    [SubView addSubview:LandDataTabView];
//    [LandDataTabView release];
    
    //附件材料
//    AccessoryDataTabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 30, fWidth - 3, 423)];
    _AccessoryTabView.delegate = self;
    _AccessoryTabView.dataSource = self;
//    [SubView addSubview:AccessoryDataTabView];
//    [AccessoryDataTabView release];

    //默认让基本情况界面显示在SubView的最前端。
    [SubView bringSubviewToFront:BaseDataWebView];
    
    // 初始为屏幕宽度一半
    [_fullScreenSegBtn setSelectedSegmentIndex:0];
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    [DataMan setCurrSubjectViewAreaConf:1];
    [self SetViewsFrame:fWidth];
    
//    //
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pressedLong:)];
//    [ClosedBtn addGestureRecognizer:longPress];
//    longPress = nil;
    
//    //
//    UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeSubject:)];
//    [self.view addGestureRecognizer:swipe];
//    [self.RootView addGestureRecognizer:swipe];
//    swipe = nil;
    
    // add subject btn
    CGRect rect = [self.GPRSBtn frame];
    UIButton *upBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rect.origin.x = 30;
    rect.size.width = 70;
    [upBtn setFrame:rect];
    [upBtn setTitle:@"上一议题" forState:UIControlStateNormal];
    [upBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [upBtn addTarget:self action:@selector(PreSubjectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
//    UIImage *image = [UIImage imageNamed:@"DBBackBtn.png"];
    //[upBtn setImage:image forState:UIControlStateNormal];
    [self.SubDataView addSubview:upBtn];
    
    UIButton *downBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rect.origin.x = rect.origin.x + rect.size.width + 10;
    [downBtn setFrame:rect];
    [downBtn setTitle:@"下一议题" forState:UIControlStateNormal];

    [downBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [downBtn addTarget:self action:@selector(BackSubjectBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    //[downBtn setImage:image forState:UIControlStateNormal];
    [self.SubDataView addSubview:downBtn];
    
//    CGRect rect2 = [self.GPRSBtn frame];
//    rect2.origin.x = rect.origin.x + rect.size.width + 100;
//    [self.GPRSBtn setFrame:rect2];
//    
//    CGRect rect3 = [self.UpdateBtn frame];
//    rect3.origin.x = rect2.origin.x + rect2.size.width + 50;
//    [self.UpdateBtn setFrame:rect3];
    
    return;
}

-(BOOL)LoadSubjectByIndex:(NSInteger)nSubjectIndex
{
    BOOL bRet = NO;
    @try {
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        NSInteger nRow = [DataMan nCurMeetingRowIndex];
        //        nRow = [DataMan.MeetingList count] - nRow - 1;
        if (nRow < 0) {
            return bRet;
        }
        NSString *MeettingId = [[DataMan.MeetingList objectAtIndex:nRow] Id];
        
        NSMutableArray *DataArr = [[DataMan MeettingToTopicIDSeqDic] valueForKey:MeettingId];
        if (!DataArr) {
            return bRet;
        }
        // 从GIS服务器下载地块数据
        NSInteger nCount = [DataArr count];
        if (nSubjectIndex < 0) {
            // 已经是第一条
            [delegate DisplayDownLoadWaittingView:@"已经是第一条"];
            return NO;
        }
        if (nSubjectIndex > (nCount - 1)) {
            // 已经是最后一条
            [delegate DisplayDownLoadWaittingView:@"已经是最后一条"];
            return NO;
        }
        
        NSString *TopicId = [DataArr objectAtIndex:nSubjectIndex];
        DBSubProjectDataItem *DBSubProjectData = [[[DataMan TopicsOfMeeting] objectForKey:MeettingId] objectForKey:TopicId];
        if (!DBSubProjectData) {
            return bRet;
        }
        
        [delegate RemoveAllGraphics];
        
        TopicId = [DBSubProjectData Id];
        bDownloadFlg = NO;
        
        // 下载议题详细数据
        id Value1 = [[DataMan TopicsReason] objectForKey:TopicId];
        if (Value1 == nil) {
            //[delegate DisPlayLoadTopicDataWaittingView:@"正在下载议题详细数据,请稍后..."];
            [delegate DisplayDownLoadWaittingView:@"正在下载议题详细数据,请稍后..."];
            
            [DataMan setTopicDKDataQueryDelegate:self];
            [DataMan DownLoadTopicReasonData:TopicId];
        }
        else {
            // 重新加载基本情况数据
            //[delegate ReloadTopicReasonData:TopicId];
            [self ReloadReasonData:TopicId];
        }
        
        //检测是否已经有此议题的地块数据
        id Value = [[DataMan TopicIDToFeatureDic] objectForKey:TopicId];
        if (Value == nil)
        {
            //NSMutableArray *DKArr = [DBSubProjectData DKDataArr];
            NSArray *DKArr = [[DataMan TopicsDKDataDic] objectForKey:TopicId];
            NSMutableArray *BsmArr = [NSMutableArray arrayWithCapacity:3];
            for (DBTopicDKDataItem *obj in DKArr)
            {
                NSString *Bsm = obj.DKBsm;
                int nLen = [Bsm length];
                if ((nLen <= 0) || [Bsm isEqualToString:@"Empty"]) {
                    continue;
                }
                [BsmArr addObject:Bsm];
            }
            
            // 开始下载地块数据
            if ([BsmArr count] > 0) {
                [DataMan setTopicDKDataQueryDelegate:self];
                [DataMan DownLoadFeatureByBsm:BsmArr KeyWord:TopicId];
            }
        }
        else {
            // 重新加载地块数据
            //[delegate ReloadDKData:TopicId];
            [self ReloadLandData:TopicId];
        }
        
        //self.SubProjectDataItem = [_ContentDataArray objectAtIndex:indexPath.row];
        self.SubjectDataItem = [[[DataMan TopicsOfMeeting] objectForKey:MeettingId] objectForKey:TopicId];
        [self SubjectViewReloadData];
        
        bRet = YES;
        //[delegate SubjectDataViewAppearWithSubProjectDataItem:SubProjectDataItem];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        return bRet;
    }
    
}
-(void)PreSubjectBtnClicked:(id)sender
{
    NSLog(@"\nPre subjecdt");
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSInteger nSubjectIndex = [DataMan nCurSubjectRowIndex] - 1;
    if (nSubjectIndex < 0) {
        //
    }
    BOOL bRet = [self LoadSubjectByIndex:nSubjectIndex];
    if (bRet) {
        [DataMan setNCurSubjectRowIndex:nSubjectIndex];
        self.nCurrIndex--;
    }
    return;
}
-(void)BackSubjectBtnClicked:(id)sender
{
    NSLog(@"\nBack subjecdt");
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSInteger nSubjectIndex = [DataMan nCurSubjectRowIndex] + 1;
    BOOL bRet = [self LoadSubjectByIndex:nSubjectIndex];
    if (bRet) {
        [DataMan setNCurSubjectRowIndex:nSubjectIndex];
        self.nCurrIndex++;
    }
    return;
}

- (void) swipeSubject:(UISwipeGestureRecognizer *) gestureRecognizer
{
    switch ([gestureRecognizer direction])
    {
        case UISwipeGestureRecognizerDirectionRight:
        {
            NSLog(@"\n Right");
            break;
        }
        case UISwipeGestureRecognizerDirectionLeft:
        {
            NSLog(@"\n Left");
            break;
        }
        case UISwipeGestureRecognizerDirectionUp:
        {
            NSLog(@"\n up");
            break;
        }
        default:
        {
            NSLog(@"\n default");
        }
        break;
    }
    
    CGPoint point;
    switch (gestureRecognizer.state)
    {
        case UIGestureRecognizerStateBegan:
            _initialPostion = [gestureRecognizer locationInView:self.view];
            //放大这个item
            NSLog(@"swipe began");
            break;
        case UIGestureRecognizerStateEnded:
            point = [gestureRecognizer locationInView:ClosedBtn];
            //变回原来大小
            NSLog(@"swipe ended");
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"swipe failed");
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint p = [gestureRecognizer locationInView:self.view];
            double dx = p.x - _initialPostion.x;
            
            NSLog(@"swipe changed");
        }
            break;
        default:
            NSLog(@"swipe else");
            break;
    }
    NSLog(@"\n==== %f-- %f ", point.x, point.y);
}

static CGPoint _initialPostion;
- (void) pressedLong:(UILongPressGestureRecognizer *) gestureRecognizer
{
    CGPoint point;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            _initialPostion = [gestureRecognizer locationInView:self.view];
            //放大这个item
            NSLog(@"press long began");
            break;
        case UIGestureRecognizerStateEnded:
            point = [gestureRecognizer locationInView:ClosedBtn];
            //变回原来大小
            NSLog(@"press long ended");
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"press long failed");
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGPoint p = [gestureRecognizer locationInView:self.view];
            double dx = p.x - _initialPostion.x;
//            if (dx > 0) {
//                NSLog(@"Finger moved to the right");
//            }
//            else {
//                NSLog(@"Finger moved to the left");
//            }
            
            CGRect rec = [self.view frame];
            rec.origin.x += dx;
            self.view.frame = rec;
            
            [DragViewDelegate ViewDragMove:dx];
//           // CGRect rec2 = [self.BaseMapView frame];
//            self.BaseMapView.frame = CGRectMake(0, 0, 1024, 704);
            
            NSLog(@"press long changed");
        }
            break;
        default:
            NSLog(@"press long else");
            break;
    }
    NSLog(@"\n==== %f-- %f ", point.x, point.y);
    
//    if (!flag) {
//        //隐藏议题界面
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.4];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//        SubjectDataView.frame = CGRectMake(-405, 44, 433, 704);
//        self.BaseMapView.frame = CGRectMake(0, 0, 1024, 704);
//        [UIView commitAnimations];
//    }else if (flag) {
//        //显示议题界面
//        [UIView beginAnimations:nil context:nil];
//        [UIView setAnimationDuration:0.4];
//        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//        SubjectDataView.frame = CGRectMake(0, 44, 433, 704);
//        self.BaseMapView.frame = CGRectMake(400, 0, 1024 - 400, 704);
//        [UIView commitAnimations];
//    }
    
    return;
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

- (void)dealloc
{
    _AnnexDownloadCompleteFlgDic = nil;
    _AnnexNameQueue = nil;
    self.RootView = nil;
    self.SubDataView = nil;
    self.SubView = nil;
    self.GPRSBtn = nil;
    self.ClosedBtn = nil;
    self.UpdateBtn = nil;
    self.segmentedContl = nil;
    self.SubDataTableView = nil;
    self.BaseDataWebView = nil;
//    self.LandDataTabView = nil;
//    self.LandIDLabel = nil;
//    self.AccessoryDataTabView = nil;
    //self.LandDataArray = nil;
    self.AccessoryDataArray = nil;
    //self.SubjectDataItem = nil;
    [self.SubjectDataItem release];
    
    [_fullScreenSegBtn release];
    [_AccessoryTabView release];
    [_BaseDataFullScreenView release];
    [_BaseDataFullScreenWebView release];
    [super dealloc];
}

#pragma mark - UIWebViewDelegate
//设置UIWebView的字体
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [self.BaseDataWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '80%'"];
   [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '80%'"];
    
    return;
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == SubDataTableView)
    {
        return 2;
    }
//    else if(tableView == LandDataTabView)
//    {
//        return 1;
//    }
    else if(tableView == _AccessoryTabView)
    {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == SubDataTableView) 
    {
        if (section == 0) {
            return 2;
        }else if(section == 1){
//            return 1;
            DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
            //NSArray * DKDatas = [[DataMan TopicIDToFeatureDic] objectForKey:_TopicId];
            NSArray * DKDatas = [[DataMan TopicsDKDataDic] objectForKey:_TopicId];
            if (!DKDatas) {
                return 0;
            }
            return DKDatas.count;
        }
    }
    else if(tableView == _AccessoryTabView)
    {
//        // 附件
//        //return [[SubjectDataItem TopicAnnexArr] count];
//        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
//        int nCnt = [[[DataMan TopicsAnnexDic] objectForKey:_TopicId] count];
//        return nCnt;
        NSArray *allAnnexUrl = [self getAllAnnexFullUrl];
        int count = allAnnexUrl.count;
        return count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        if (tableView == SubDataTableView)
        {
            if (indexPath.section == 0)
            {
                static NSString *SubDataTableViewCellID = @"cellID";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SubDataTableViewCellID];
                if (cell == nil)
                {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SubDataTableViewCellID] autorelease];
                    
                    if (indexPath.section == 0)
                    {
                        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 0, 60, 40)];
                        nameLabel.tag = 100;
                        nameLabel.font = [UIFont boldSystemFontOfSize:14];
                        nameLabel.backgroundColor = [UIColor clearColor];
                        [cell.contentView addSubview:nameLabel];
                        [nameLabel release];
                        
//                        CGFloat fWidth = SCREEN_WIDTH * 0.5;
                        CGFloat fWidth = SubDataTableView.frame.size.width;
                        
//                        UITextView *LeaderOpinion = [[UITextView alloc] initWithFrame:CGRectMake(70, 0, fWidth - 70, 40)];
                        CGFloat fHeight = cell.frame.size.height;
                        UILabel *topicNameLable = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, fWidth - 70, fHeight)];
                        topicNameLable.tag = 101;
                        topicNameLable.numberOfLines = 0;
//                        LeaderOpinion.editable = NO;
                        topicNameLable.font = [UIFont systemFontOfSize:16];
                        topicNameLable.backgroundColor = [UIColor clearColor];
                        [cell.contentView addSubview:topicNameLable];
                        [topicNameLable release];
                        
                        
                    }
                }
                UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:100];
                UITextView *contentLabel = (UITextView *)[cell.contentView viewWithTag:101];
                if (indexPath.row == 0) {
                    nameLabel.text = @"所属单位";
                    if ([[SubjectDataItem SectionName] length] > 0) {
                        contentLabel.text = [SubjectDataItem SectionName];
                    }
                    else {
                        [contentLabel setText:@""];
                    }
                }
                else {
                    nameLabel.text = @"名称";
                    if ([[SubjectDataItem TopicName] length] > 0) {
//                        contentLabel.text = [SubjectDataItem TopicName];
                        contentLabel.text = [NSString stringWithFormat:@"%d.%@", self.nCurrIndex+1, [SubjectDataItem TopicName]];
                    }
                    else {
                        [contentLabel setText:@""];
                    }
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
            else
            {
                static NSString *SubDataTableViewCellID = @"cellID2";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SubDataTableViewCellID];
                if (cell == nil)
                {
                    cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:SubDataTableViewCellID] autorelease];
                    CGRect frame = SubDataTableView.frame;
                    frame.size.height = 1.f;
                    frame.size.width -= 6;
                    frame.origin.x = 3;
                    frame.origin.y = frame.size.height - 1;
                    UILabel *spLable = [[UILabel alloc] initWithFrame:frame];
                    [spLable setTag:101];
                    [spLable setAlpha:0.7];
                    [spLable setBackgroundColor:[UIColor lightGrayColor]];
                    [cell.contentView addSubview:spLable];
                }
                UILabel *spLable = (UILabel*)[cell.contentView viewWithTag:101];
                if (indexPath.row == 0) {
                    [spLable setHidden:YES];
                }
                else{
                    [spLable setHidden:NO];
                }
                DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
                NSArray * DKDatas = [[DataMan TopicsDKDataDic] objectForKey:_TopicId];
                if (DKDatas.count == 0) {
                    cell.textLabel.text = @"无相关地块数据";
                    [cell setBackgroundColor:[UIColor darkGrayColor]];
                }else {
                    int nIndex = indexPath.row;
                    DBTopicDKDataItem *DBTopicDKData = [DKDatas objectAtIndex:nIndex];
                    if ([[DBTopicDKData DKBH] length] >0) {
                        cell.textLabel.text = [DBTopicDKData DKBH];
                    }
                    else if ([[DBTopicDKData DKName] length] > 0 ) {
                        cell.textLabel.text = [DBTopicDKData DKName];
                    }
                    else if ([[DBTopicDKData DKApplicant] length] > 0) {
                        cell.textLabel.text = [DBTopicDKData DKApplicant];
                    }
                    else {
                        [cell.textLabel setText:@""];
                    }
                }
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.textLabel.font = [UIFont systemFontOfSize:16];
                return cell;
            }
            
            
            
        }
        else if(tableView == _AccessoryTabView)
        {
            static NSString *AccessoryDataTabViewCellID = @"cellID2";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:AccessoryDataTabViewCellID];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:AccessoryDataTabViewCellID] autorelease];
                
                CGRect frame1 = [SubView frame];
                CGFloat fOrgx = 30.f;
                CGFloat fWidth = frame1.size.width - fOrgx - 30.f - 5.f;
                UILabel *AccessoryName = [[UILabel alloc] initWithFrame:CGRectMake(fOrgx, 5, fWidth, 30.f)];
                AccessoryName.tag = 103;
                AccessoryName.font = [UIFont systemFontOfSize:16];
                AccessoryName.backgroundColor = [UIColor clearColor];
                AccessoryName.autoresizingMask = UIViewAutoresizingNone;
                [cell.contentView addSubview:AccessoryName];
                [AccessoryName release];
                
                // del by niurg 2015.9
//                UIButton *DownloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//                DownloadBtn.tag = 104;
//                DownloadBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
//                fOrgx = fOrgx + fWidth + 5.f;
//                DownloadBtn.frame = CGRectMake(fOrgx, 5, 30.f, 30.f);
//                
//                [DownloadBtn setImage:[UIImage imageNamed:@"Preview.png"] forState:UIControlStateNormal];
//                [DownloadBtn addTarget:self action:@selector(DownloadBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
//                [cell.contentView addSubview:DownloadBtn];
                // end
                
            }
            UILabel *AccessoryName = (UILabel *)[cell.contentView viewWithTag:103];
            //int nCount = [[SubjectDataItem TopicAnnexArr] count];
            DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
//            int nCount = [[[DataMan TopicsAnnexDic] objectForKey:_TopicId] count];
            NSArray *allAnnexUrl = [self getAllAnnexFullUrl];
            int nCount = [allAnnexUrl count];
            if (nCount == 0) {
                AccessoryName.text = @"无相关信息";
            }else {
                //DBTopicAnnexDataItem *DBTopicAnnexData = [[SubjectDataItem TopicAnnexArr] objectAtIndex:indexPath.row ];
                
                NSArray * TopicsAnnexs = [[DataMan TopicsAnnexDic] objectForKey:_TopicId];
                DBTopicAnnexDataItem *DBTopicAnnexData = [TopicsAnnexs objectAtIndex:indexPath.row];
                [DBTopicAnnexData setIndex:indexPath.row];
                // 显示附件名称
                if ([[DBTopicAnnexData Name] length] > 0) {
                    AccessoryName.text = [DBTopicAnnexData Name];
                }
                else {
                    [AccessoryName setText:@""];
                }
                NSString *ImageFile = nil;
                // 检查此附件是否已经下载
                NSString *FilePath = [self GetAnnexFileFullPath:[DBTopicAnnexData Name]];
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                BOOL bRet = [fileMgr fileExistsAtPath:FilePath];
//                if (bRet) {
                    ImageFile = @"Preview.png";
                    [_AnnexDownloadCompleteFlgDic setValue:@"1" forKey:[DBTopicAnnexData Id]];
//                }
//                else {
//                    ImageFile = @"DownLoad.png";
//                    [_AnnexDownloadCompleteFlgDic setValue:@"0" forKey:[DBTopicAnnexData Id]];
//                }
                UIButton *DownloadBtn = (UIButton *)[cell.contentView viewWithTag:104];
                [DownloadBtn setImage:[UIImage imageNamed:ImageFile] forState:UIControlStateNormal];
                
                
//                NSString *annexUrl = [allAnnexUrl objectAtIndex:indexPath.row];
//                [AccessoryName setText:annexUrl];
            }
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            
            return cell;
        }   
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }

    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == SubDataTableView)
    {
        if (section == 0) {
//            return @"议题";
            return nil;
        }
        else if (section == 1) {
            return @"地块信息";
        }
    }
    
    return nil;
}

-(CGRect)cacuCellHeight:(NSString *)content fontSize:(CGFloat)size
{
    // tableView 宽度
    
    //    CGFloat tableViewWidth = self.tab.frame.size.width ;
    CGFloat fWidth = SubDataTableView.frame.size.width - 70 - 6;
    
    if (content == nil) {
        return CGRectMake(0, 0, fWidth, 0);
    }
    NSDictionary *stringAttributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:size] forKey: NSFontAttributeName];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:content attributes:stringAttributes];
    
    CGRect rect = [string boundingRectWithSize:CGSizeMake(fWidth, 5000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return rect;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    if (tableView == SubDataTableView)
    {
        if (indexPath.section == 0) {
            if (indexPath.row == 1) {
                // 名称动态计算
                NSString *topicName = [SubjectDataItem TopicName];
                if ([topicName length] > 0) {
                    CGRect frame = [self cacuCellHeight:topicName fontSize:16.];
                    CGRect singleRowRec = [self cacuCellHeight:@"单行高度" fontSize:16.];
                    CGFloat singleHeight = floorf(singleRowRec.size.height);
                    CGFloat fHeight = ceilf(frame.size.height);
                    NSInteger nTimes = fHeight / singleHeight;
                    if (nTimes > 1) {
                        return (fHeight + 6);
                    }
                }
            }
        }
    }
    
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == SubDataTableView)
    {
        if (section == 0) {
            return 45;
        }else if(section == 1) {
            return 20;
        }
    }
    
    return 0;
}

#pragma mark MJPhotoBrowserDelegate
// 切换到某一页图片
- (void)photoBrowser:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index
{
    // 检查当前页是否有图片
    MJPhoto *photo = [[photoBrowser photos] objectAtIndex:index];
    if (!photo.srcImageView) {
        NSString *FileFullPath = [self getImageLocalFullPath:index];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:FileFullPath];
        if (bRet)
        {
            UIImage *image = [UIImage imageWithContentsOfFile:FileFullPath];
//            [photo setImage:image];
            UIImageView *iv = [[UIImageView alloc] initWithImage:image];
            [photo setSrcImageView:iv];
            
        }
        
    }
    
    return;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    if (tableView == SubDataTableView) {
        if (indexPath.section == 1) {
            // 显示定位地块,以BSM为参数
            NSArray * DKDatas = [[DataMan TopicsDKDataDic] objectForKey:_TopicId];
            DBTopicDKDataItem *DBTopicDKData = [DKDatas objectAtIndex:indexPath.row];
            [delegate LandDataViewAppear:_TopicId DKBsm:[DBTopicDKData DKBsm] newCenterPoint:nil :nil];
        }
    }
    else if (tableView == _AccessoryTabView)
    {
        
        NSArray *allAnnexUrl = [self getAllAnnexFullUrl];
        int count = allAnnexUrl.count;
        
        // 1.封装图片数据
        bIsFirst = YES;
        
        NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
        /*
        {
            // 替换为中等尺寸图片
            MJPhoto *photo = [[MJPhoto alloc] init];
            NSString *FileFullPath = [self getImageLocalFullPath:indexPath.row];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:FileFullPath];
            if (bRet)
            {
                UIImage *imageData = [UIImage imageWithContentsOfFile:FileFullPath];
                UIImageView *iv = [[UIImageView alloc] initWithImage:imageData];
                [photo setSrcImageView:iv];
            }
            else{
                // go to download
                DBTopicAnnexDataItem *DBTopicAnnexData = [[[DataMan TopicsAnnexDic] objectForKey:_TopicId] objectAtIndex:indexPath.row];
                
                [self downLoadImage:[DBTopicAnnexData Id] :DBTopicAnnexData :indexPath.row];
            }
            [photos addObject:photo];
            [photo release];
        }
        */
        for (int i = 0; i<count; i++) {
//            if (i == indexPath.row) {
//                continue;
//            }
            MJPhoto *photo = [[MJPhoto alloc] init];
            NSString *FileFullPath = [self getImageLocalFullPath:i];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            BOOL bRet = [fileMgr fileExistsAtPath:FileFullPath];
            if (bRet)
            {
                UIImage *imageData = [UIImage imageWithContentsOfFile:FileFullPath];
                UIImageView *iv = [[UIImageView alloc] initWithImage:imageData];
                [photo setSrcImageView:iv];
            }
            else{
                // go to download
                DBTopicAnnexDataItem *DBTopicAnnexData = [[[DataMan TopicsAnnexDic] objectForKey:_TopicId] objectAtIndex:i];
                
                [self downLoadImage:[DBTopicAnnexData Id] :DBTopicAnnexData :i];
            }
            [photos addObject:photo];
            [photo release];
        }
        
        // 2.显示相册
        _photoBrowser = [[MJPhotoBrowser alloc] init];
        [_photoBrowser setDelegate:self];
        _photoBrowser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
        _photoBrowser.photos = photos; // 设置所有的图片
//        browser.bShowProgress = NO;
        [_photoBrowser show];
//        [self presentViewController:_photoBrowser animated:YES completion:nil];
        
    }
}

static BOOL bIsFirst = YES;
- (void)photoBrowser2:(MJPhotoBrowser *)photoBrowser didChangedToPageAtIndex:(NSUInteger)index
{
    // 检查当前页是否有图片
    NSMutableArray *photos = [NSMutableArray arrayWithArray:[photoBrowser photos]];
    if ([photos count] > index) {
        MJPhoto *photo = [[MJPhoto alloc] init];
        NSString *FileFullPath = [self getImageLocalFullPath:index];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:FileFullPath];
        if (bRet)
        {
            
            UIImage *image = [UIImage imageWithContentsOfFile:FileFullPath];
            [photo setImage:image];
            UIImageView *iv = [[UIImageView alloc] initWithImage:image];
            [photo setSrcImageView:iv];
            [photos replaceObjectAtIndex:index withObject:photo];
            photoBrowser.photos = photos;
            if (bIsFirst) {
                bIsFirst = NO;
                photoBrowser.currentPhotoIndex = index;
            }
            
            [photoBrowser showPhotoViewAtIndex:index];
        }
    }
    return;
}

-(NSString*)getImageLocalFullPath:(NSInteger)nIndex
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    DBTopicAnnexDataItem *DBTopicAnnexData = [[[DataMan TopicsAnnexDic] objectForKey:_TopicId] objectAtIndex:nIndex];
    NSString *FileFullPath = [self GetAnnexFileFullPath:[DBTopicAnnexData Name]];
    return FileFullPath;
}
#pragma mark -UIButtonMehods
#pragma mark 获取当前议题的所有附件的URL
-(NSArray*)getAllAnnexFullUrl
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSString *AnnexDownloadUrl = [DataMan AnnexDownloadServiceUrl];
    NSURL *newURL = [[NSURL alloc] initWithString:[AnnexDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *UrlPath = [newURL path];
    UrlPath = AnnexDownloadUrl;
    if ([AnnexDownloadUrl length] <= 0)
    {
        return nil;
    }
    
    NSArray *allAnnexData = [[DataMan TopicsAnnexDic] objectForKey:_TopicId];
    NSMutableArray *AnnexFullUrlList = [NSMutableArray arrayWithCapacity:2];
    for (DBTopicAnnexDataItem *DBTopicAnnexData in allAnnexData) {
        if ([UrlPath hasSuffix:@"?"]) {
            // 已经有后缀?
            AnnexDownloadUrl = [NSString stringWithFormat:@"%@id=%@", UrlPath, DBTopicAnnexData.Id];
            [AnnexFullUrlList addObject:AnnexDownloadUrl];
        }
        else{
            AnnexDownloadUrl = [NSString stringWithFormat:@"%@?id=%@", UrlPath, DBTopicAnnexData.Id];
            [AnnexFullUrlList addObject:AnnexDownloadUrl];
        }
    }
    
    return AnnexFullUrlList;
}
//{
//    NSArray * _urls = @[@"http://ww4.sinaimg.cn/thumbnail/7f8c1087gw1e9g06pc68ug20ag05y4qq.gif", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr0nly5j20pf0gygo6.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1d0vyj20pf0gytcj.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr1xydcj20gy0o9q6s.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr2n1jjj20gy0o9tcc.jpg", @"http://ww2.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr39ht9j20gy0o6q74.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr3xvtlj20gy0obadv.jpg", @"http://ww4.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr4nndfj20gy0o9q6i.jpg", @"http://ww3.sinaimg.cn/thumbnail/8e88b0c1gw1e9lpr57tn9j20gy0obn0f.jpg"];
//    
//    return _urls;
//}

-(void)downLoadImage:(NSString*)imageId :(DBTopicAnnexDataItem *)DBTopicAnnexData :(NSInteger)row
{
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    NSString *AnnexDownloadUrl = [DataMan AnnexDownloadServiceUrl];
    NSURL *newURL = [[NSURL alloc] initWithString:[AnnexDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSString *UrlPath = [newURL path];
    if ([AnnexDownloadUrl length] <= 0)
    {
        // 下载服务地址不对，请重新配置。
//        [DataMan CreateFailedAlertViewWithFailedInfo:@"下载错误" andWithMessage:@"下载服务地址不正确，请重新配置"];
        return;
    }
    else
    {
        AnnexDownloadUrl = [NSString stringWithFormat:@"%@?id=%@", UrlPath, imageId];
        // AnnexDownloadUrl = [NSString stringWithFormat:@"%@id=%@", AnnexDownloadUrl, DBTopicAnnexData.Id];
    }
    
    AuthHttpEngine *AuthEngine = [DataMan GetNetEngineForAnn];
    MKNetworkOperation *downloadOperation = [AuthEngine DownloadAnnexFile:AnnexDownloadUrl onCompletion:^(NSString *RetMsg, MKNetworkOperation*Operation)
   {
       DBTopicAnnexDataItem *DBTopicAnnexData = (DBTopicAnnexDataItem*)Operation.userData;
       NSString *FileName = [DBTopicAnnexData Name];
       @try {
           if (FileName != nil)//zhenglei 2014.12.29 修改下载附件保存为目录名的bug
           {
               NSData *FileData = [Operation responseData];
               
               // 文件存放目录
               NSString *FileFullPath = [self GetAnnexFileFullPath:FileName];
               // 已经存在此文件则删除
               NSFileManager *fileMgr = [NSFileManager defaultManager];
               BOOL bRet = [fileMgr fileExistsAtPath:FileFullPath];
               if (bRet) {
                   NSError *err;
                   [fileMgr removeItemAtPath:FileFullPath error:&err];
               }
               
               [FileData writeToFile:FileFullPath atomically:YES];
//               [_AnnexDownloadCompleteFlgDic setValue:@"1" forKey:[DBTopicAnnexData Id]];
               NSIndexPath *ip = [Operation UserIndexPath];
               NSInteger nRow = ip.row;
               [self photoBrowser2:_photoBrowser didChangedToPageAtIndex:nRow];
               
           }
       }
       @catch (NSException *exception) {
           [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
       }
       @finally {
//           NSString *Msg = [NSString stringWithFormat:@"附件[%@]下载完成",FileName];
//           [delegate HidDownLoadWaittingView:Msg];
       }
       DLog(@"download finish");
       
   }onError:^(NSError* error, MKNetworkOperation* Operation) {

   }];
    [downloadOperation setUserData:DBTopicAnnexData];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:row inSection:0];
    [downloadOperation setUserIndexPath:ip];
//    [downloadOperation onUploadProgressChanged:^(double progress, MKNetworkOperation *Operation) {
//         NSLog(@"--progres:%ff", progress);
//    }];
    [downloadOperation onDownloadProgressChanged:^(double progress, MKNetworkOperation *Operation)
     {
         NSIndexPath *ip = [Operation UserIndexPath];
         NSInteger nRow = ip.row;
        NSLog(@"\-----n%d--progres:%ff", nRow, progress);
     }];
    
    return;
}

/* del by niurg 2015.9
// 下载附件
- (void)DownloadBtnTouched:(id)sender
{
    return;
    @try {
        UIButton *button = (UIButton *)sender;
        UITableViewCell *curCell = (UITableViewCell *)button.superview.superview;
        NSInteger nRow = [_AccessoryTabView indexPathForCell:curCell].row;
        //DBTopicAnnexDataItem *DBTopicAnnexData = [[SubjectDataItem TopicAnnexArr] objectAtIndex:nRow];
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        DBTopicAnnexDataItem *DBTopicAnnexData = [[[DataMan TopicsAnnexDic] objectForKey:_TopicId] objectAtIndex:nRow];
        // 附件是否存在
        NSString * Val = [_AnnexDownloadCompleteFlgDic objectForKey:[DBTopicAnnexData Id]];
        if ([Val isEqualToString:@"1"]) {
            // 文件已经存在，则进行预览操作
             NSString *FileFullPath = [self GetAnnexFileFullPath:[DBTopicAnnexData Name]];
            [delegate PreviewAnnex:FileFullPath];
            return;
        }
        [_AnnexNameQueue enqueue:DBTopicAnnexData];
        NSString *AnnexDownloadUrl = [DataMan AnnexDownloadServiceUrl];
        NSURL *newURL = [[NSURL alloc] initWithString:[AnnexDownloadUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        
        NSString *UrlPath = [newURL path];
        if ([AnnexDownloadUrl length] <= 0)
        {
            // 下载服务地址不对，请重新配置。
            [DataMan CreateFailedAlertViewWithFailedInfo:@"下载错误" andWithMessage:@"下载服务地址不正确，请重新配置"];
            return;
        }
        else 
        {
                       AnnexDownloadUrl = [NSString stringWithFormat:@"%@?id=%@", UrlPath, DBTopicAnnexData.Id];
           // AnnexDownloadUrl = [NSString stringWithFormat:@"%@id=%@", AnnexDownloadUrl, DBTopicAnnexData.Id];
        }
        
        __block BOOL  bFlg = NO;
        AuthHttpEngine *AuthEngine = [DataMan GetNetEngineForAnn];
        MKNetworkOperation *uploadOperation = [AuthEngine DownloadAnnexFile:AnnexDownloadUrl onCompletion:^(NSString *RetMsg, MKNetworkOperation*Operation)
        {
                                                                     // 首先将任务弹出队列
            DBTopicAnnexDataItem *DBTopicAnnexData = [_AnnexNameQueue dequeue];
            NSString *FileName = [DBTopicAnnexData Name];
            @try {
                if (FileName != nil)//zhenglei 2014.12.29 修改下载附件保存为目录名的bug
                {
                NSData *FileData = [Operation responseData];
                
                // 文件存放目录
                NSString *FileFullPath = [self GetAnnexFileFullPath:FileName];
                // 已经存在此文件则删除
                NSFileManager *fileMgr = [NSFileManager defaultManager];
                BOOL bRet = [fileMgr fileExistsAtPath:FileFullPath];
                if (bRet) {
                    NSError *err;
                    [fileMgr removeItemAtPath:FileFullPath error:&err];
                }
                
                [FileData writeToFile:FileFullPath atomically:YES];
                [_AnnexDownloadCompleteFlgDic setValue:@"1" forKey:[DBTopicAnnexData Id]];
                // 更改下载图标为预览图标
                NSInteger nRow = [DBTopicAnnexData Index];
                NSIndexPath *IndexPath = [NSIndexPath indexPathForRow:nRow inSection:0];
                UITableViewCell *AnnexCell = [_AccessoryTabView cellForRowAtIndexPath:IndexPath];
                UIButton *DownloadBtn = (UIButton *)[AnnexCell.contentView viewWithTag:104];
                [DownloadBtn setImage:[UIImage imageNamed:@"Preview.png"] forState:UIControlStateNormal];
            }
            }
            @catch (NSException *exception) {
                [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
            }
            @finally {
                NSString *Msg = [NSString stringWithFormat:@"附件[%@]下载完成",FileName];
                [delegate HidDownLoadWaittingView:Msg];
            }
            DLog(@"download finish");
            
        }onError:^(NSError* error, MKNetworkOperation* Operation) {
            // 首先将任务弹出队列
            [delegate HidDownLoadWaittingView:nil];
            DBTopicAnnexDataItem *DBTopicAnnexData = [_AnnexNameQueue dequeue];
            //NSString *FileName = [DBTopicAnnexData Name];
            [_AnnexDownloadCompleteFlgDic setValue:@"0" forKey:[DBTopicAnnexData Id]];
            //NSString *Msg = [NSString stringWithFormat:@"附件[%@]下载失败",FileName];
            DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
            [DataMan CreateFailedAlertViewWithFailedInfo:@"请检查下载地址是否正确" andWithMessage:nil];
        }];

        [uploadOperation onUploadProgressChanged:^(double progress, MKNetworkOperation *Operation) {
            if (!bFlg) {
                bFlg = YES;
                [delegate DisplayDownLoadWaittingView:@"正在下载附件,请稍后..."];
            }
        }];
        
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    } 
     
}
*/

-(NSString*)GetAnnexFileFullPath:(NSString*)FileName
{
    @try {
        // 文件存放目录
        NSString *pngDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        
        NSString *FileDir = [NSString stringWithFormat:@"%@/AnnexFiles/%@", pngDir, _TopicId];
        NSError *err;
        [fileMgr createDirectoryAtPath:FileDir withIntermediateDirectories:YES attributes:nil error:&err];
        NSString *FileFullPath = [FileDir stringByAppendingPathComponent:FileName];
        
        return FileFullPath;
    }
    @catch (NSException *exception) {
        return nil;
    }
    @finally {
        
    }

}


/*
// ASI 请求完成
-(void)ASIRequestDone:(ASIHTTPRequest*)request
{
    // 首先将任务弹出队列
    DBTopicAnnexDataItem *DBTopicAnnexData = [_AnnexNameQueue dequeue];
    NSString *FileName = [DBTopicAnnexData Name];
    @try {
        //NSString * apiResponse = [request responseString];
        //NSLog(@"%@", apiResponse);
        NSData *FileData = [request responseData];
        //int nLen = [FileData length];
        //NSLog(@"%d", nLen);

        // 文件存放目录
        NSString *FileFullPath = [self GetAnnexFileFullPath:FileName];
        // 已经存在此文件则删除
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        BOOL bRet = [fileMgr fileExistsAtPath:FileFullPath];
        if (bRet) {
            NSError *err;
            [fileMgr removeItemAtPath:FileFullPath error:&err];
        }

        [FileData writeToFile:FileFullPath atomically:YES];
        [_AnnexDownloadCompleteFlgDic setValue:@"1" forKey:[DBTopicAnnexData Id]];
        // 更改下载图标为预览图标
        NSInteger nRow = [DBTopicAnnexData Index];
        NSIndexPath *IndexPath = [NSIndexPath indexPathForRow:nRow inSection:0];
        UITableViewCell *AnnexCell = [AccessoryDataTabView cellForRowAtIndexPath:IndexPath];
        UIButton *DownloadBtn = (UIButton *)[AnnexCell.contentView viewWithTag:104];
        [DownloadBtn setImage:[UIImage imageNamed:@"Preview.png"] forState:UIControlStateNormal];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        NSString *Msg = [NSString stringWithFormat:@"附件[%@]下载完成",FileName];
        [delegate HidDownLoadWaittingView:Msg];
    } 
    
}
// ASI 请求失败
-(void)ASIRequestFailure:(ASIHTTPRequest*)request
{
    // 首先将任务弹出队列
    [delegate HidDownLoadWaittingView:nil];
    DBTopicAnnexDataItem *DBTopicAnnexData = [_AnnexNameQueue dequeue];
    //NSString *FileName = [DBTopicAnnexData Name];
    [_AnnexDownloadCompleteFlgDic setValue:@"0" forKey:[DBTopicAnnexData Id]];
    //NSString *Msg = [NSString stringWithFormat:@"附件[%@]下载失败",FileName];
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    [DataMan CreateFailedAlertViewWithFailedInfo:@"请检查下载地址是否正确" andWithMessage:nil];
    
    return;
}
*/

- (IBAction)GPRSBtnTouched:(id)sender
{
    @try {
        // 计算出多个地块的中心点
        // 取得地块
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        NSArray * DKDatas = [[[DataMan TopicIDToFeatureDic] objectForKey:_TopicId] allValues];
        AGSPoint *CentrPoint = nil;
        // 可显示全部整体地块的最小外围区域
        AGSMutableEnvelope *DKsMinEnv = nil;
        if (([DKDatas count] <= 0) || (DKDatas == nil)) {
            // 没有地块
        }
        else if([DKDatas count] == 1){
            // 只有一个地块
            DBTopicDKDataItem *DBTopicDKData = [DKDatas objectAtIndex:0];
            if ([DBTopicDKData.DKGeometry isKindOfClass:[AGSPolygon class]]) 
            {
                AGSPolygon *Poly = (AGSPolygon*)DBTopicDKData.DKGeometry;
                AGSGeometryEngine *geoEng = [AGSGeometryEngine defaultGeometryEngine];
                CentrPoint = [geoEng labelPointForPolygon:Poly];
                AGSEnvelope *env = [Poly envelope];
                DKsMinEnv = [AGSMutableEnvelope envelopeWithXmin:env.xmin ymin:env.ymin xmax:env.xmax ymax:env.ymax spatialReference:env.spatialReference];
            }
        }
        else if([DKDatas count] == 2)
        {
            // 有2个地块
            // 取得第1个地块
            DBTopicDKDataItem *DBTopicDKData = [DKDatas objectAtIndex:0];
            if ([DBTopicDKData.DKGeometry isKindOfClass:[AGSPolygon class]]) 
            {
                AGSPolygon *Poly = (AGSPolygon*)DBTopicDKData.DKGeometry;
                AGSGeometryEngine *geoEng = [AGSGeometryEngine defaultGeometryEngine];
                CentrPoint = [geoEng labelPointForPolygon:Poly];
                AGSEnvelope *env = [Poly envelope];
                DKsMinEnv = [AGSMutableEnvelope envelopeWithXmin:env.xmin ymin:env.ymin xmax:env.xmax ymax:env.ymax spatialReference:env.spatialReference];
            }
            // 取得第2个地块
            DBTopicDKData = [DKDatas objectAtIndex:1];
            AGSMutableEnvelope *envTmp2 = nil;
            if ([DBTopicDKData.DKGeometry isKindOfClass:[AGSPolygon class]]) 
            {
                AGSPolygon *Poly = (AGSPolygon*)DBTopicDKData.DKGeometry;
                envTmp2 = [[Poly envelope] copy];
                
                AGSGeometryEngine *geoEng = [AGSGeometryEngine defaultGeometryEngine];
                AGSPoint *CentrPoint2 = [geoEng labelPointForPolygon:Poly];
                if (CentrPoint2 != nil) 
                {
                    if (CentrPoint != nil) {
                        // 取得两点的中点
                        double dMidPosX = fabs(CentrPoint2.x - CentrPoint.x) / 2;
                        if (CentrPoint2.x < CentrPoint.x) {
                            dMidPosX = CentrPoint2.x + dMidPosX;
                        }
                        else {
                            dMidPosX = CentrPoint.x + dMidPosX;
                        }
                        double dMidPosY = fabs(CentrPoint2.y - CentrPoint.y) / 2;
                        if (CentrPoint2.y < CentrPoint.y) {
                            dMidPosY = CentrPoint2.y + dMidPosY;
                        }
                        else {
                            dMidPosY = CentrPoint.y + dMidPosY;
                        }
                        AGSSpatialReference *sRef = DBTopicDKData.DKGeometry.spatialReference;
                        CentrPoint = [AGSPoint pointWithX:dMidPosX y:dMidPosY spatialReference:sRef];
                    }
                    else {
                        CentrPoint = CentrPoint2;
                    }
                }
            }
            if (DKsMinEnv && envTmp2) {
                [DKsMinEnv unionWithEnvelope:DKsMinEnv];
            }
            else if (!DKsMinEnv && envTmp2)
            {
                DKsMinEnv = [AGSMutableEnvelope envelopeWithXmin:envTmp2.xmin ymin:envTmp2.ymin xmax:envTmp2.xmax ymax:envTmp2.ymax spatialReference:envTmp2.spatialReference];
            }
            else if (!envTmp2 && DKsMinEnv)
            {
                // aready get
            }
            else{
                // both is null
            }
        }
        else if ([DKDatas count] >= 3) {
            // 多个地块,分别取得每个地块的点，构建一个poly，再取得label point
            AGSGeometryEngine *geoEng = [AGSGeometryEngine defaultGeometryEngine];
            DBTopicDKDataItem *DBTopicDKData = [DKDatas objectAtIndex:0];
            AGSSpatialReference *sRef = DBTopicDKData.DKGeometry.spatialReference;
            AGSMutablePolygon *poly = [[AGSMutablePolygon alloc] initWithSpatialReference:sRef];
            [poly addRingToPolygon];
            for (DBTopicDKDataItem *DKData in DKDatas) 
            {
                // 取得每个地块的label point 
                if ([DBTopicDKData.DKGeometry isKindOfClass:[AGSPolygon class]]) 
                {
                    AGSPolygon *Poly = (AGSPolygon*)DKData.DKGeometry;
                    // add by niurg
                    AGSEnvelope *envTmp2 = [Poly envelope];
                    if (!DKsMinEnv) {
                        DKsMinEnv = [AGSMutableEnvelope envelopeWithXmin:envTmp2.xmin ymin:envTmp2.ymin xmax:envTmp2.xmax ymax:envTmp2.ymax spatialReference:envTmp2.spatialReference];

                    }
                    else{
                        [DKsMinEnv unionWithEnvelope:envTmp2];
                    }
                    // end
                    AGSMutablePoint *Point = [geoEng labelPointForPolygon:Poly];
                    if (Point != nil) 
                    {
                        [poly addPointToRing:[AGSPoint pointWithX:Point.x y:Point.y spatialReference:sRef]];
                    }
                }
                // 
            }
            NSUInteger PtNum = [poly numPointsInRing:0];
            if ((PtNum >= 3) && (PtNum < 100000)) {
                // 取得新的label point
                CentrPoint = [geoEng labelPointForPolygon:poly];
            }
            else if(PtNum > 0){
                // 取得第一个点
                CentrPoint = [poly pointOnRing:0 atIndex:0];
            }
            [poly release];
        }
        else {
            //
            return;
        }
        
        NSString *logMsg = [NSString stringWithFormat:@"\n议题ID:%@ \n地块BSM:多地块定位 \n 定位中心点:%@",_TopicId, CentrPoint];
        const char *cMsg = [logMsg cStringUsingEncoding:NSUTF8StringEncoding];
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:nil textInf:cMsg];
        
        [delegate LandDataViewAppear:_TopicId DKBsm:@"All" newCenterPoint:CentrPoint :DKsMinEnv];
        //[delegate LandsLocation:CentrPoint];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
    }

}

#pragma mark 关闭议题窗口
- (IBAction)ClosedBtnTouched:(id)sender
{
    UIButton *button = (UIButton *)sender;
    if (bCloseBtnFlg) {
        [button setImage:[UIImage imageNamed:@"OpenViewBtn.png"] forState:UIControlStateNormal]; 
        bCloseBtnFlg = NO;
    }else{
        [button setImage:[UIImage imageNamed:@"CloseViewBtn.png"] forState:UIControlStateNormal];
        bCloseBtnFlg = YES;
    }
    [delegate ClosedBtnTouchedWithFlag:bCloseBtnFlg];
}

// 重新加载议题数据
- (IBAction)UpdateBtnTouched:(id)sender
{
    bDownloadFlg = NO;   
    
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    if (![DataMan InternetConnectionTest]) {
        [DataMan CreateFailedAlertViewWithFailedInfo:@"网络未连接状态" andWithMessage:nil];
        return;
    }
    [DataMan setTopicDKDataQueryDelegate:self];
    NSString *GISUrlString = DataMan.GISWebServiceUrl;
    //NSURL *GISUrl = [NSURL URLWithString:GISUrlString];
    NSURL *GISUrl = [NSURL URLWithString:[GISUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSString *hostName = [GISUrl host];
    BOOL bMapServerIsReachable = [DataMan GetHostNetStatus:hostName];
    if(!bMapServerIsReachable)
    {
        //WebService服务不可用。
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"领导决策系统" message:@"不能连接到指定的WebSrevice服务，请稍后再试" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        [alert release];
        return;
    }else
    {
        // 重新获取地块数据
        NSString *MeetingID = [SubjectDataItem.OwnerMeetringID copy];
        // 刷新议题数据
        [[DataMan TopicIDToFeatureDic] removeAllObjects];
        [self CleanTopicDetailData:_TopicId];
        // 清除本地与议题相关附件信息
        NSArray * TopicsAnnexs = [[DataMan TopicsAnnexDic] objectForKey:_TopicId];
        for (DBTopicAnnexDataItem *DBTopicAnnexData in TopicsAnnexs ) {
            // 文件存放目录
            NSString *pngDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            NSString *FileDir = [NSString stringWithFormat:@"%@/AnnexFiles", pngDir];
            NSError *err;
            [fileMgr createDirectoryAtPath:FileDir withIntermediateDirectories:YES attributes:nil error:&err];
            NSString *FileFullPath = [FileDir stringByAppendingPathComponent:[DBTopicAnnexData Name]];
            BOOL bRet = [fileMgr fileExistsAtPath:FileFullPath];
            if (bRet) {
                // 
                NSError *err;
                [fileMgr removeItemAtPath:FileFullPath error:&err];
            }
        }
        
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        [delegate DisplayDownLoadWaittingView:@"开始更新地块数据..."];
        [DataMan setTopicDKReloadDelegate:self];
        [DataMan DownLoadTopicLandData:_TopicId MeetingId:MeetingID];
        
        [delegate DisplayDownLoadWaittingView:@"正在刷新议题详细数据,请稍后..."];
        [DataMan DownLoadTopicReasonData:_TopicId];
        
    }
}

// 指定议题的地块数据下载完成
- (void)TopicDKDownloadCompleted:(NSString*)Msg
{
//    [LandDataTabView reloadData];
    [SubDataTableView reloadData];
    return;
}

- (IBAction)SegmentedContlTouched:(id)sender
{
    if (0 == segmentedContl.selectedSegmentIndex)
    {
        [SubView bringSubviewToFront:BaseDataWebView];
    }
    else if(1 == segmentedContl.selectedSegmentIndex)
    {
        [SubView bringSubviewToFront:_AccessoryTabView];
    }
}

#pragma mark - DBDataManagerTopicDKDataQueryDelegate Method
// 议题基本情况数据查询结束
- (void)TopicReasonDidQuery:(NSString*)TopicID
{
    @synchronized(self)
    {
        if (bDownloadFlg) {
            [delegate DisplayDownLoadWaittingView:@"地块数据刷新完成"];
        }
        else {
            [delegate HidDownLoadWaittingView:@"正在刷新地块数据,请稍后..."];
        }
        bDownloadFlg = YES;
    }
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    self.SubjectDataItem = [[DataMan.TopicsOfMeeting objectForKey:_TopicOwnerId] objectForKey:TopicID];
    // 刷新议题信息界面
    [self ReloadReasonData:TopicID];
    
    return;
}

// 议题地块数据查询结束
- (void)TopicDKDidQuery:(NSString*)TopicID
{
    @synchronized(self) 
    {
        if (bDownloadFlg) {
            [delegate DisplayDownLoadWaittingView:@"基本情况刷新完成"];
        }
        else {
            [delegate HidDownLoadWaittingView:@"正在刷新基本情况数据,请稍后..."];
        }
        bDownloadFlg = YES;
    }
    
    // 重新加载地块数据
    [self ReloadLandData:TopicID];

    // 定位地块
    [self GPRSBtnTouched:nil];
    return;
}

// add by niurg 2015.9
#pragma mark 全屏开关按钮事件
- (IBAction)fullScreenSegClick:(id)sender {
    DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
    UISegmentedControl *segBtn = (UISegmentedControl*)sender;
    NSInteger nIndex = [segBtn selectedSegmentIndex];
    if (nIndex == 0) {
        // 设置为半屏模式
        [DataMan setCurrSubjectViewAreaConf:1];
        
        // 隐藏全屏基本情况VIEW
        [_BaseDataFullScreenView setHidden:YES];
    }
    else
    {
        // 设置为全屏模式
        [DataMan setCurrSubjectViewAreaConf:2];
        
        // 显示全屏基本情况VIEW
        [_BaseDataFullScreenView setHidden:NO];
        [RootView bringSubviewToFront:_BaseDataFullScreenView];
    }
    [delegate ClosedBtnTouchedWithFlag:bCloseBtnFlg];
    
    return;
}

// nFlg- 1:调整所有控件为半屏    2:调整所有控件为全屏
-(void)adjustSubjectView:(NSInteger)nFlg
{
    // 容器VIEW
    CGRect frame0 = self.view.frame;
    if (nFlg == 1) {
        //
        frame0.size.width = Half_Subject_Width_Big;
    }
    else{
        frame0.size.width = Full_Subject_Width_Big;
    }
    
//    [UIView beginAnimations:nil context:nil];
//    [UIView setAnimationDuration:0.4];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];

    [self.view setFrame:frame0];
    
    CGRect frame1 = self.RootView.frame;
    frame1.size.width = frame0.size.width - 28;
    [self.RootView setFrame:frame1];
    
    // add by niurg 2015.12.20
    CGRect rectTmp = SubDataView.frame;
    CGFloat fwidth = SCREEN_HEIGHT;
    CGFloat fheigth = SCREEN_WIDTH;
    CGFloat fwidth2 = SCREEN_HEIGHT2;
    CGFloat fheigth2 = SCREEN_WIDTH2;
    
    rectTmp.size.height = fwidth - 50 - 44;
    rectTmp.origin.y = 50;
    _BaseDataFullScreenView.frame = rectTmp;
    rectTmp.origin.y = 0;
    _BaseDataFullScreenWebView.frame = rectTmp;
    // end
    
    // 上半部分VIEW
    CGRect frame2 = self.SubDataView.frame;
    frame2.size.width = frame1.size.width - 5;
    [self.SubDataView setFrame:frame2];
    
    // 下半部分VIEW
    CGRect frame3 = self.SubView.frame;
    frame3.size.width = frame1.size.width - 5;
    [self.SubView setFrame:frame3];
    
    // 开关按钮调整
    CGRect frame4 = self.ClosedBtn.frame;
    frame4.origin.x = frame1.size.width - 8;
    [self.ClosedBtn setFrame:frame4];
    
    // 
    CGRect frame5 = self.SubDataTableView.frame;
    frame5.size.width = frame2.size.width;
    [self.SubDataTableView setFrame:frame5];
    
    CGRect frame6 = self.segmentedContl.frame;
    frame6.size.width = frame2.size.width;
    [self.segmentedContl setFrame:frame6];
    
    // 调整基本情况WebView
    CGRect frame7 = self.BaseDataWebView.frame;
    // chg 2015.11.22
    //frame7.size.width = frame3.size.width - 3;
    frame7.size.width = frame3.size.width - 3;
    // end
    
    [self.BaseDataWebView setFrame:frame7];
    
//    // 调整附件tableView
//    CGRect frame8 = self.AccessoryDataTabView.frame;
//    frame8.size.width = frame3.size.width - 3;
//    [self.AccessoryDataTabView setFrame:frame8];
//    [AccessoryDataTabView reloadData];
    
//    [UIView commitAnimations];
    return;
}

@end
