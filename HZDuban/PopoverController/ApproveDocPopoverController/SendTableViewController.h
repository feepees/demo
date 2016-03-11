//
//  SendTableViewController.h
//  DocumentManager
//
//  Created by mac  on 12-12-20.
//  Copyright (c) 2012年 mac . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SendTableViewControllerDelegate <NSObject>

- (void)SendViewCancelBtnTouched;
- (void)OkeyBtnTouchedWithArray:(NSArray *)array;

@end

@interface SendTableViewController : UITableViewController

@property (nonatomic, assign) id<SendTableViewControllerDelegate> SendTableViewDelegate;
@property (nonatomic, retain) NSMutableArray *NameArr;

@end
