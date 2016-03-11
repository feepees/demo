//
//  DBMainMenuViewController.m
//  HZDuban
//
//  Created by sunz on 12-12-21.
//
//

#import "DBMainMenuViewController.h"
#import "Logger.h"
#import "DBViewController.h"

@interface DBMainMenuViewController ()

@end

@implementation DBMainMenuViewController

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
}

-(void)viewWillDisappear:(BOOL)animated
{

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"DBViewSegueID"])
    {
        // 领导决策模块
        DBViewController *DBViewCtrl = (DBViewController*)[segue destinationViewController];
        [DBViewCtrl setNModelFlg:1];
    }
    else if ([[segue identifier] isEqualToString:@"XCJGViewSegueID"])
    {
        // 巡察监管模块
        DBViewController *DBViewCtrl = (DBViewController*)[segue destinationViewController];
        [DBViewCtrl setNModelFlg:2];
        
    }
    
    //[segue destinationViewController];
    return;
}

- (IBAction)MeetingBtnTouch:(id)sender {
    return;
}


- (IBAction)ApproveDocBtnTouch:(id)sender {
    
}

- (IBAction)ScheduleBtnTouch:(id)sender {
    
}

- (IBAction)StatisticsBtnTouch:(id)sender {
}

- (IBAction)ConfBtnTouch:(id)sender {
}

- (IBAction)HelpBtnTouch:(id)sender {
}

@end
