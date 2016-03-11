//
//  DBLoginViewController.m
//  HZDuban
//
//  Created by  on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "DBLoginViewController.h"
#import "DBViewController.h"
#import "Logger.h"

@interface DBLoginViewController ()
@property (retain, nonatomic) IBOutlet UITextField *userNameTextField;
@property (retain, nonatomic) IBOutlet UITextField *pswTextField;
- (IBAction)LoginBtnTouched:(id)sender;

@end

@implementation DBLoginViewController
@synthesize userNameTextField;
@synthesize pswTextField;

#ifdef _FOR_DEBUG_  
-(BOOL) respondsToSelector:(SEL)aSelector {  
    printf("SELECTOR: %s  FileName: %s\n", [NSStringFromSelector(aSelector) UTF8String], __FILE__);
    return [super respondsToSelector:aSelector];  
}  
#endif

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)keyboardShown:(NSNotification *)aNotification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.1];
    self.view.center = CGPointMake(300, 512);
    [UIView commitAnimations];
}

- (void)keyboardHidden:(NSNotification *)aNotification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:1.0/30];
    self.view.center = CGPointMake(420, 512);
    [UIView commitAnimations];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    userNameTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UserNameTextFieldLeftImage.png"]];
    [imgView setFrame:CGRectMake(4, 0, 20, 20)];
    userNameTextField.leftView = imgView;
    [imgView release];
    userNameTextField.leftViewMode = UITextFieldViewModeAlways;
    
    [userNameTextField setText:@"hzgt"];
    
    pswTextField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    UIImageView *imgView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"PswTextFieldLeftImage.png"]];
    [imgView2 setFrame:CGRectMake(4, 0, 20, 20)];
    pswTextField.leftView = imgView2;
    [imgView2 release];
    pswTextField.leftViewMode = UITextFieldViewModeAlways;
    [pswTextField setText:@"hzgt"];
    pswTextField.secureTextEntry = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHidden:) name:UIKeyboardDidHideNotification object:nil];
    
}

- (void)viewDidUnload
{
    [self setUserNameTextField:nil];
    [self setPswTextField:nil];
    [UserNameTextField release];
    UserNameTextField = nil;
    [PswTextField release];
    PswTextField = nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
     if((UIInterfaceOrientationLandscapeLeft == interfaceOrientation) || (UIInterfaceOrientationLandscapeRight == interfaceOrientation))
     {
         return YES;
     }
    return NO;
}

- (void)dealloc {
    [userNameTextField release];
    [pswTextField release];
    [UserNameTextField release];
    [PswTextField release];
    [super dealloc];
}
- (IBAction)LoginBtnTouched:(id)sender 
{
    [NSThread detachNewThreadSelector:@selector(performSegueFunc) toTarget:self withObject:nil];
    
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	HUD.delegate = self;
	HUD.labelText = @"正在加载...";
	[HUD showWhileExecuting:@selector(myTask) onTarget:self withObject:nil animated:YES];
    
    //[self performSegueWithIdentifier:@"Login_MainMenu" sender:self];
    return;
}
-(void)performSegueFunc
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    @try {
        [NSThread sleepForTimeInterval:0.05];
        [self performSelectorOnMainThread:@selector(performSegueFunc2) withObject:nil  waitUntilDone:NO];
    }
    @catch (NSException *exception) {
        [Logger WriteLog:__FILE__ funcName:__func__ lineNum:__LINE__ exceptionObj:exception textInf:NULL];
    }
    @finally {
        [pool release];
    }
    
    return;
}

-(void)performSegueFunc2
{
    if (![[userNameTextField text] isEqualToString:@"hzgt"]) {
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        [DataMan CreateFailedAlertViewWithFailedInfo:@"用户名错误" andWithMessage:nil];
        return;
    }
    
    if ([[pswTextField text] isEqualToString:@"hzgt"]) {
        [self performSegueWithIdentifier:@"Login_MainMenu" sender:self];
    }
    else{
        DBLocalTileDataManager *DataMan = [DBLocalTileDataManager instance];
        [DataMan CreateFailedAlertViewWithFailedInfo:@"密码错误" andWithMessage:nil];
        return;
    }
    
    return;
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"Login_MainMenu"]) {
        // transfer data handle
    }


    //[segue destinationViewController];
    return;
}

#pragma mark -
#pragma mark Execution code

- (void)myTask {
	// Do something usefull in here instead of sleeping ...
	sleep(3);
}

- (void)myProgressTask {
	// This just increases the progress indicator in a loop
	float progress = 0.0f;
	while (progress < 1.0f) {
		progress += 0.01f;
		HUD.progress = progress;
		usleep(50000);
	}
}

- (void)myMixedTask {
	// Indeterminate mode
	sleep(2);
	// Switch to determinate mode
	HUD.mode = MBProgressHUDModeDeterminate;
	HUD.labelText = @"Progress";
	float progress = 0.0f;
	while (progress < 1.0f)
	{
		progress += 0.01f;
		HUD.progress = progress;
		usleep(50000);
	}
	// Back to indeterminate mode
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = @"Cleaning up";
	sleep(2);
	// The sample image is based on the work by www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
	// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators)
	HUD.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Completed";
	sleep(2);
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	// Remove HUD from screen when the HUD was hidded
	[HUD removeFromSuperview];
	[HUD release];
	HUD = nil;
}
@end
