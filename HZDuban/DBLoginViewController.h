//
//  DBLoginViewController.h
//  HZDuban
//
//  Created by  on 12-7-5.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface DBLoginViewController : UIViewController<MBProgressHUDDelegate>
{
    MBProgressHUD *HUD;

    IBOutlet UITextField *UserNameTextField;
    IBOutlet UITextField *PswTextField;
}

- (void)myTask;
- (void)myProgressTask;
- (void)myMixedTask;
@end
