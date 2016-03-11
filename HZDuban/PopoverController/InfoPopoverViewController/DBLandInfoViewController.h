//
//  DBLandInfoViewController.h
//  HZDuban
//
//  Created by mac on 12-8-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBAGSGraphic.h"

@interface DBLandInfoViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource>

- (id)initWithFrame:(CGRect)frame;
- (void)LandInfoViewWillAppearByGraphic:(DBAGSGraphic *)LandInfoGraphic;

@end
