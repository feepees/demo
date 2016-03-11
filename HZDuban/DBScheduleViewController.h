//
//  DBScheduleViewController.h
//  HZDuban
//
//  Created by sunz on 12-12-21.
//
//

#import <UIKit/UIKit.h>
#import "TKCalendarMonthView.h"

@interface DBScheduleViewController : UIViewController
    <TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource, UITableViewDelegate, UITableViewDataSource>
{
    UITableView *EventListTableView;
    UITableView *EventDetailTableView;
    UILabel *dayLabel;
}

@property (nonatomic, retain) TKCalendarMonthView *calendar;
@property (nonatomic, retain) NSMutableArray *EventArr;
@property (nonatomic, retain) NSIndexPath *EventIndexPath;

- (IBAction)BackBtnTouch:(id)sender;

@end
