//
//  StatisticTableViewContorller.h
//  guotuDB
//
//  Created by sunz on 12-3-7.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StatisticTableViewContorller : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    
    //IBOutlet UINavigationBar *MyNavigationBar;
    UITableView *MyTableView;
    NSArray * strTitleArr;
}
- (void)BackBtnClick:(id)sender;

@end
