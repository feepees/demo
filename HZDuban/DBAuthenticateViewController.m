//
//  DBAuthenticateViewController.m
//  HZDuban
//
//  Created by mac  on 13-7-30.
//
//

#import "DBAuthenticateViewController.h"

@interface DBAuthenticateViewController ()

@end

@implementation DBAuthenticateViewController

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
    DBLocalTileDataManager *dataManager = [DBLocalTileDataManager instance];
    dataManager.authDelegate = self;
#if TARGET_IPHONE_SIMULATOR
    NSString *uuid = @"467506CA-5D43-4BD1-B832-40DC72387D11";
#elif TARGET_OS_IPHONE
    NSString *uuid = @"";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }else {
        uuid = [[UIDevice currentDevice] uniqueIdentifier];
    }

#endif
    [dataManager authentcate:uuid];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - check device
- (void)authenticateDidFinish:(NSDictionary *)result{
//    [self performSegueWithIdentifier:@"mainMenu" sender:nil];
    [self performSegueWithIdentifier:@"DBViewSegueID" sender:nil];
    
}

- (void)authenticateDidError:(NSDictionary *)result{
#if TARGET_IPHONE_SIMULATOR
    NSString *uuid = @"467506CA-5D43-4BD1-B832-40DC72387D51";
#elif TARGET_OS_IPHONE
    NSString *uuid = @"";
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    }else {
        uuid = [[UIDevice currentDevice] uniqueIdentifier];
    }
#endif
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[result objectForKey:@"Memo"]
                                                    message:@"\n\n\n"
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles: nil];
    UITextView *uuidView = [[UITextView alloc] initWithFrame:CGRectMake(7, 44, 270, 25)];
    uuidView.text = uuid;
    uuidView.tag = 100;
    uuidView.userInteractionEnabled = NO;
    uuidView.editable = NO;
    
    UIButton *copyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [copyButton addTarget:self action:@selector(copyUUID:) forControlEvents:UIControlEventTouchUpInside];
    copyButton.frame = CGRectMake(12, 75, 260, 40);
    [copyButton setTitle:@"复制" forState:UIControlStateNormal];
    [copyButton setBackgroundImage:[UIImage imageNamed:@"copyBtn.png"] forState:UIControlStateNormal];
    [alert addSubview:copyButton];
    
    [alert addSubview:uuidView];
    
    [alert show];
}

- (void)copyUUID:(id)sender{
    UIAlertView *alertView = (UIAlertView *)((UIButton *)sender).superview;
    UIView *sub = [alertView viewWithTag:100];
    if ([sub isMemberOfClass:[UITextView class]]) {
        UITextView *textView = (UITextView *)sub;
        NSString *uuid = textView.text;
        [[UIPasteboard generalPasteboard] setPersistent:YES];
        [[UIPasteboard generalPasteboard] setString:uuid];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
        exit(0);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}
@end
