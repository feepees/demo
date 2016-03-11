//
//  DBStatisticViewController.h
//  HZDuban
//
//  Created by sunz on 13-1-6.
//
//

#import <UIKit/UIKit.h>

@interface DBStatisticViewController : UIViewController<UITableViewDelegate,UITableViewDataSource> {
    
    //IBOutlet UINavigationBar *MyNavigationBar;
    UITableView *MyTableView;
    NSArray * strTitleArr;
}
- (void)BackBtnClick:(id)sender;

@end
