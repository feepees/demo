//
//  DBScheduleViewController.m
//  HZDuban
//
//  Created by sunz on 12-12-21.
//
//

#import "DBScheduleViewController.h"
#import "NSDate+TKCategory.h"
//#import "LocalNotificationsManager.h"
//#import "DBLocalTileDataManager.h"

@interface DBScheduleViewController ()

@end

@implementation DBScheduleViewController
@synthesize calendar;
@synthesize EventArr;
@synthesize EventIndexPath;

#pragma mark - ViewLifeCycle
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

    self.EventArr = [NSMutableArray arrayWithCapacity:0];
    [self.EventArr addObject:@"nil"];
    NSDate * date = [NSDate localeDate];
    TKDateInformation dateInfo = [date dateInformation];
    
    UIImageView *BgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768 - 20)];
    BgImageView.image = [UIImage imageNamed:@"ScheduleBgImage.jpg"];
    [self.view addSubview:BgImageView];
    [BgImageView release];
    
    UIButton *BackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    BackBtn.frame = CGRectMake(30, 18, 50, 22);
    [BackBtn setImage:[UIImage imageNamed:@"AD_Back.png"] forState:UIControlStateNormal];
    [BackBtn addTarget:self action:@selector(BackBtnTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:BackBtn];
    
    UILabel *leftTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 460, 35)];
    leftTitleLabel.tag = 600;
    leftTitleLabel.font = [UIFont boldSystemFontOfSize:17];
    leftTitleLabel.backgroundColor = [UIColor clearColor];
    leftTitleLabel.text = @"日程管理";
    leftTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:leftTitleLabel];
    [leftTitleLabel release];
    
    dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(60, 175, 120, 120)];
    dayLabel.backgroundColor = [UIColor clearColor];
    dayLabel.font = [UIFont systemFontOfSize:90];
    dayLabel.textAlignment = NSTextAlignmentCenter;
    dayLabel.text = dateInfo.day < 10 ? [NSString stringWithFormat:@"0%d", dateInfo.day] : [NSString stringWithFormat:@"%d", dateInfo.day];
    [self.view addSubview:dayLabel];
    [dayLabel release];
    
    UILabel *calendarLabel = [[UILabel alloc]initWithFrame:CGRectMake(220, 53, 240, 25)];
    calendarLabel.backgroundColor = [UIColor clearColor];
    calendarLabel.textColor = [UIColor whiteColor];
    calendarLabel.font = [UIFont systemFontOfSize:16];
    calendarLabel.textAlignment = NSTextAlignmentCenter;
    calendarLabel.text = @"日期选择";
    [self.view addSubview:calendarLabel];
    [calendarLabel release];
    
    //init calendar
    self.calendar = [[TKCalendarMonthView alloc] init];
    calendar.delegate = self;
    calendar.dataSource = self;
    // Add Calendar to just off the top of the screen so it can later slide down
    calendar.frame = CGRectMake(229, 82, calendar.frame.size.width, calendar.frame.size.height);
	// Ensure this is the last "addSubview" because the calendar must be the top most view layer
	[self.view addSubview:calendar];
	[calendar reload];
    [calendar release];
    
    //tableView
    EventListTableView = [[UITableView alloc] initWithFrame:CGRectMake(21, 362, 1024 / 2 - 40 - 20 - 5, 768 - 20 - 360 - 20 - 20) style:UITableViewStylePlain];
    EventListTableView.delegate = self;
    EventListTableView.dataSource = self;
    EventListTableView.backgroundColor = [UIColor clearColor];
    EventListTableView.backgroundView = nil;
    UIButton *Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    EventListTableView.tableFooterView = Btn;
    EventListTableView.tableFooterView.hidden = YES;
    [self.view addSubview:EventListTableView];
    [EventListTableView release];
    
    EventDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(550, 20, 1024 - 550 - 20 - 40, 768 - 20 - 100) style:UITableViewStylePlain];
    EventDetailTableView.backgroundColor = [UIColor clearColor];
    EventDetailTableView.backgroundView = nil;
    EventDetailTableView.delegate = self;
    EventDetailTableView.dataSource = self;
    EventDetailTableView.tableFooterView = Btn;
    EventDetailTableView.tableFooterView.hidden = YES;
    [self.view addSubview:EventDetailTableView];
    [EventDetailTableView release];
    //测试
//    DBLocalTileDataManager *dataMan = [DBLocalTileDataManager instance];
//    dataMan.version++;
    int count = [[[UIApplication sharedApplication] scheduledLocalNotifications] count];
    if (count == 0) {
        //无本地通知
        for (int i = 0; i < 5; i++) {
            [self createLocalNotificationWithBadgeNumber:i + 1];
        }
    }
//    if (dataMan.version < 2) {
//        //测试无新会议
//        if (count == 0) {
//            //无本地通知
//            for (int i = 0; i < 5; i++) {
//                [self createLocalNotificationWithBadgeNumber:i + 1];
//            }
//        }
//    }else{
//        //测试有新会议
//        if (count > 0) {
//            //还有本地通知
//            UILocalNotification *notif = [[[UIApplication sharedApplication] scheduledLocalNotifications] objectAtIndex:count - 1];
//            if (fabs([notif.fireDate timeIntervalSince1970] - 1) > 0.000001 ) {
//                //有新的会议, 但时间是在最后一个
//                [self createLocalNotificationWithBadgeNumber:count];
//            }else{
//                //全部取消, 重新创建
//                [[UIApplication sharedApplication] cancelAllLocalNotifications];
//                for (int i = 0; i < 5; i++) {
//                    [self createLocalNotificationWithBadgeNumber:i + 1];
//                }
//            }
//        }else{
//            //无本地通知
//            [self createLocalNotificationWithBadgeNumber:1];
//        }
//    }
}

//创建本地通知
- (void)createLocalNotificationWithBadgeNumber:(NSInteger)num
{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification != nil) {
        NSDate *now=[NSDate new];
        notification.fireDate = [now dateByAddingTimeInterval:20 * num];
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody= [NSString stringWithFormat:@"再有%d分钟会议开始", 20 * num];
        notification.applicationIconBadgeNumber = num;
        notification.soundName = UILocalNotificationDefaultSoundName;
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
        [notification release];
    }
}

- (void)dealloc
{
    self.calendar = nil;
    self.EventArr = nil;
    self.EventIndexPath = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)viewWillDisappear:(BOOL)animated
//{
//    [LocalNotificationsManager removeLocalNotificationWithActivityId:100];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if((UIInterfaceOrientationLandscapeLeft == interfaceOrientation) || (UIInterfaceOrientationLandscapeRight == interfaceOrientation))
    {
        return YES;
    }
    return NO;
}
#pragma mark UITableViewDelegate Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == EventListTableView) {
        return 1;
    }else{
        return 1;
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == EventListTableView) {
//        if(self.EventArr.count == 0){
//            return 1;
//        }else{
//            return self.EventArr.count;
//        }
        return 5;
    }else{
        return 7;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == EventListTableView) {
        if (self.EventArr.count == 0) {
            return 40;
        }else{
            return 40;
        }
    }else{
        return 50;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == EventListTableView) {
        if (self.EventArr.count == 0) {
            static NSString *cellID = @"cellID0";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
            }
            cell.textLabel.text = @"今天无事件";
            cell.userInteractionEnabled = NO;
            
            return cell;
        }else{
            static NSString *CellID = @"CellId";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:cell.frame];
                backgroundView.image = [UIImage imageNamed:@"AD_SearchCellBgImage.png"];
                cell.backgroundView = backgroundView;
                [backgroundView release];
                
                UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 2.0, 420.0, 15.0)];
                nameLabel.tag = 101;
                nameLabel.font = [UIFont boldSystemFontOfSize:14.0];
                nameLabel.backgroundColor = [UIColor clearColor];
                nameLabel.numberOfLines = 0;
                nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
                [cell.contentView addSubview:nameLabel];
                [nameLabel release];
                
                UILabel *addrLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 18.0, 180.0, 20.0)];
                addrLabel.tag = 102;
                addrLabel.font = [UIFont systemFontOfSize:13.0];
                addrLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:addrLabel];
                [addrLabel release];
                
                UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(300.0 - 20, 18.0, 75.0, 20.0)];
                timeLabel.tag = 103;
                timeLabel.font = [UIFont systemFontOfSize:13.0];
                timeLabel.backgroundColor = [UIColor clearColor];
                [cell.contentView addSubview:timeLabel];
                [timeLabel release];
                
                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                button.frame = CGRectMake(400, 10, 20, 20);
                button.tag = 104;
                [button setImage:[UIImage imageNamed:@"AD_BtnImage.png"] forState:UIControlStateNormal];
                [cell.contentView addSubview:button];
                
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(2, 36, 440, 4)];
                imageView.tag = 105;
                [cell.contentView addSubview:imageView];
                [imageView release];
            }
            UILabel *nameLabel = (UILabel *)[cell viewWithTag:101];
            nameLabel.text = @"廉政风险点";
            UILabel *addrLabel = (UILabel *)[cell viewWithTag:102];
            addrLabel.text = @"北京";
            UILabel *timeLabel = (UILabel *)[cell viewWithTag:103];
            timeLabel.text = @"2012.11.14";
            UIButton *button = (UIButton *)[cell viewWithTag:104];
            button.userInteractionEnabled = NO;
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:105];
            imageView.image = [UIImage imageNamed:@"AD_SeparateLine.jpg"];
            
            return cell;
        }
    }else{
        static NSString *CellID = @"Cell2";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellID];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UIImageView *backgroundView = [[UIImageView alloc] initWithFrame:cell.frame];
            backgroundView.image = [UIImage imageNamed:@"AD_SearchCellBgImage.png"];
            cell.backgroundView = backgroundView;
            [backgroundView release];
            
            UILabel *Label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 10.0, 90.0, 32.0)];
            Label.tag = 101;
            Label.textAlignment = NSTextAlignmentRight;
            Label.font = [UIFont boldSystemFontOfSize:14.0];
            Label.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:Label];
            [Label release];
            
            UILabel *ContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(110.0, 10.0, 320.0, 32.0)];
            ContentLabel.tag = 102;
            ContentLabel.font = [UIFont systemFontOfSize:14.0];
            ContentLabel.numberOfLines = 0;
            ContentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
            ContentLabel.backgroundColor = [UIColor clearColor];
            [cell.contentView addSubview:ContentLabel];
            [ContentLabel release];
        }
        UILabel *Label = (UILabel *)[cell viewWithTag:101];
        
        UILabel *ContentLabel = (UILabel *)[cell viewWithTag:102];
        if (indexPath.row == 0) {
            Label.text = @"主题:";
            ContentLabel.text = @"廉政风险点";
        }else if(indexPath.row == 1){
            Label.text = @"地点:";
            ContentLabel.text = @"主任办公室";
        }else if(indexPath.row == 2){
            Label.text = @"开始时间:";
            ContentLabel.text = @"2012-12-14 09:14";
        }else if(indexPath.row == 3){
            Label.text = @"结束时间:";
            ContentLabel.text = @"2012-12-14 10:14";
        }else if(indexPath.row == 4){
            Label.text = @"提醒时间:";
            ContentLabel.text = @"2012-12-14 09:00";
        }else if(indexPath.row == 5){
            Label.text = @"是否全天事件:";
            ContentLabel.text = @"是";
        }else if(indexPath.row == 6){
            Label.text = @"任务说明:";
            ContentLabel.text = @"把服务大厅的廉政风险点的内容发电子版给主任，并交一份纸质的内容。";
        }        
        
        return cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == EventListTableView) {
        self.EventIndexPath = indexPath;
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
        [EventDetailTableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == EventListTableView) {
        self.EventIndexPath = nil;
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

#pragma mark TKCalendarMonthViewDelegate methods
- (void)calendarMonthView:(TKCalendarMonthView *)monthView didSelectDate:(NSDate *)d
{
    [self DateChanged:d];
}

- (void)calendarMonthView:(TKCalendarMonthView *)monthView monthDidChange:(NSDate *)d
{
    if (monthView.tag == 100) {
        [self DateChanged:d];
    }else if (monthView.tag == 101) {
        //点击button
    }
}

//custom method to changeDate
- (void)DateChanged:(NSDate *)d
{
    if (self.EventIndexPath != nil) {
        UITableViewCell *cell = [EventListTableView cellForRowAtIndexPath:self.EventIndexPath];
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

    TKDateInformation dateInfo = [d dateInformation];
    dayLabel.text = dateInfo.day < 10 ? [NSString stringWithFormat:@"0%d", dateInfo.day] : [NSString stringWithFormat:@"%d", dateInfo.day];
    [EventListTableView reloadData];
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

- (IBAction)BackBtnTouch:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
