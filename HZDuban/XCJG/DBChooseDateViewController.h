//
//  DBChooseDateViewController.h
//  HZDuban
//
//  Created by mac  on 13-6-21.
//
//

#import <UIKit/UIKit.h>
#import "TKCalendarMonthView.h"

@protocol DBChooseDateViewControllerDelegate <NSObject>

- (void)chooseDateWith:(NSString *)DateStr;

@end

@interface DBChooseDateViewController : UIViewController
    <TKCalendarMonthViewDelegate, TKCalendarMonthViewDataSource>

@property (nonatomic, assign) id<DBChooseDateViewControllerDelegate> delegate;
@property (nonatomic, retain) TKCalendarMonthView *calendar;

@end
