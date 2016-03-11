//
//  DBChoosePicViewController.m
//  HZDuban
//
//  Created by mac  on 13-6-21.
//
//

#import "DBChoosePicViewController.h"

@interface DBChoosePicViewController ()

@end

@implementation DBChoosePicViewController
@synthesize delegate;
@synthesize nFlg = _nFlg;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        _nFlg = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // add image view
    CGRect rec = [self.view frame];
    UIImageView * BGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(-20, 0, rec.size.width, rec.size.height)];
    BGImageView.tag = 100;
    BGImageView.image = [UIImage imageNamed:@"AD_SearchCellBgImage2.png"];
    
    [self.view addSubview:BGImageView];

    UIButton *choosePicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    choosePicBtn.tag = 100;
    choosePicBtn.frame = CGRectMake(40, 10, 100, 40);
    [choosePicBtn setTitle:@"拍照/摄像" forState:UIControlStateNormal];
    
    [choosePicBtn setBackgroundImage:[UIImage imageNamed:@"BlackButton.png"] forState:UIControlStateNormal];
    
    [choosePicBtn addTarget:self action:@selector(choosePicBtnTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:choosePicBtn];
    
    UIButton *choosePicBtn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    choosePicBtn2.tag = 101;
    choosePicBtn2.frame = CGRectMake(180, 10, 100, 40);
    [choosePicBtn2 setTitle:@"本地数据" forState:UIControlStateNormal];
    [choosePicBtn2 setBackgroundImage:[UIImage imageNamed:@"BlackButton.png"] forState:UIControlStateNormal];
    [choosePicBtn2 addTarget:self action:@selector(choosePicBtn2Touched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:choosePicBtn2];
}

- (void)choosePicBtnTouched:(id)sender
{
    [delegate chooseBtnTouched:_nFlg];
}

- (void)choosePicBtn2Touched:(id)sender
{
    [delegate chooseBtn2Touched:_nFlg];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
