//
//  DBChooseDateViewController.m
//  HZDuban
//
//  Created by mac  on 13-6-21.
//
//

#import "DBChooseDateViewController.h"
#import "NSDate+TKCategory.h"

@interface DBChooseDateViewController ()

@end

@implementation DBChooseDateViewController
@synthesize delegate;
@synthesize calendar;

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
    self.title = @"选择日期";
    //init calendar
    self.calendar = [[TKCalendarMonthView alloc] init];
    calendar.delegate = self;
    calendar.dataSource = self;
    calendar.frame = CGRectMake(0, 20, calendar.frame.size.width, calendar.frame.size.height);
	[self.view addSubview:calendar];
    [calendar release];
	[calendar reload];
}

- (void)dealloc
{
    self.calendar = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark TKCalendarMonthViewDelegate methods

- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d
{
    [self DateChanged:d];
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)d
{
    if (monthView.tag == 100) {
        //点击日历
        [self DateChanged:d];
    }else if (monthView.tag == 101) {
        //点击button
    }
    //	NSLog(@"calendarMonthView monthDidChange");
}
//custom method to changeDate
- (void)DateChanged:(NSDate *)d
{
    NSDate *today = [NSDate date];
    NSInteger flag = [today differenceInDaysTo:d];
    if (flag < 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"不能选择今天之前的日期" message:nil delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
    }else {
        [delegate chooseDateWith:[d dateDescription]];
    }
    
//    NSDate *today = [NSDate date];
//    NSInteger flag = [today differenceInDaysTo:d];
//    if (flag < 0) {
//        [_SDHud setFixedSize:CGSizeMake(180, 100)];
//        [_SDHud setCaption:@"不能选择今天之前的日期"];
//        [self.view bringSubviewToFront:_SDHud.view];
//        [_SDHud show];
//        [_SDHud hideAfter:1];
//    }else {
//        calendar.hidden = YES;
//        self.LastDate = d;
//        date = [d dateDescription];
//        
//        [self.TableView beginUpdates];
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//        NSArray *array = [NSArray arrayWithObject: indexPath];
//        [self.TableView reloadRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationNone];
//        [self.TableView endUpdates];
//    }
}
#pragma mark -
#pragma mark TKCalendarMonthViewDataSource methods

- (NSArray*)calendarMonthView:(TKCalendarMonthView *)monthView marksFromDate:(NSDate *)startDate toDate:(NSDate *)lastDate
{
    //	NSLog(@"calendarMonthView marksFromDate toDate");
    //	NSLog(@"Make sure to update 'data' variable to pull from CoreData, website, User Defaults, or some other source.");
	// When testing initially you will have to update the dates in this array so they are visible at the
	// time frame you are testing the code.
	NSArray *data = [NSArray arrayWithObjects:
					 @"2011-01-01 00:00:00 +0000", @"2011-01-09 00:00:00 +0000", @"2011-01-22 00:00:00 +0000",
					 @"2011-01-10 00:00:00 +0000", @"2011-01-11 00:00:00 +0000", @"2011-01-12 00:00:00 +0000",
					 @"2011-01-15 00:00:00 +0000", @"2011-01-28 00:00:00 +0000", @"2011-01-04 00:00:00 +0000",
					 @"2011-01-16 00:00:00 +0000", @"2011-01-18 00:00:00 +0000", @"2011-01-19 00:00:00 +0000",
					 @"2011-01-23 00:00:00 +0000", @"2011-01-24 00:00:00 +0000", @"2011-01-25 00:00:00 +0000",
					 @"2011-02-01 00:00:00 +0000", @"2011-03-01 00:00:00 +0000", @"2011-04-01 00:00:00 +0000",
					 @"2011-05-01 00:00:00 +0000", @"2011-06-01 00:00:00 +0000", @"2011-07-01 00:00:00 +0000",
					 @"2011-08-01 00:00:00 +0000", @"2011-09-01 00:00:00 +0000", @"2011-10-01 00:00:00 +0000",
					 @"2011-11-01 00:00:00 +0000", @"2011-12-01 00:00:00 +0000", nil];
	
    
	// Initialise empty marks array, this will be populated with TRUE/FALSE in order for each day a marker should be placed on.
	NSMutableArray *marks = [NSMutableArray array];
	
	// Initialise calendar to current type and set the timezone to never have daylight saving
	NSCalendar *cal = [NSCalendar currentCalendar];
	[cal setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
	
	// Construct DateComponents based on startDate so the iterating date can be created.
	// Its massively important to do this assigning via the NSCalendar and NSDateComponents because of daylight saving has been removed
	// with the timezone that was set above. If you just used "startDate" directly (ie, NSDate *date = startDate;) as the first
	// iterating date then times would go up and down based on daylight savings.
	NSDateComponents *comp = [cal components:(NSMonthCalendarUnit | NSMinuteCalendarUnit | NSYearCalendarUnit |
                                              NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSSecondCalendarUnit)
                                    fromDate:startDate];
	NSDate *d = [cal dateFromComponents:comp];
	
	// Init offset components to increment days in the loop by one each time
	NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
	[offsetComponents setDay:1];
	
    
	// for each date between start date and end date check if they exist in the data array
	while (YES) {
		// Is the date beyond the last date? If so, exit the loop.
		// NSOrderedDescending = the left value is greater than the right
		if ([d compare:lastDate] == NSOrderedDescending) {
			break;
		}
		
		// If the date is in the data array, add it to the marks array, else don't
		if ([data containsObject:[d description]]) {
			[marks addObject:[NSNumber numberWithBool:YES]];
		} else {
			[marks addObject:[NSNumber numberWithBool:NO]];
		}
		
		// Increment day using offset components (ie, 1 day in this instance)
		d = [cal dateByAddingComponents:offsetComponents toDate:d options:0];
	}
	
	return [NSArray arrayWithArray:marks];
}

@end
