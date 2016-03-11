//
//  DBMarkListViewController.h
//  HZDuban
//
//  Created by mac on 12-9-16.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBLocalTileDataManager.h"
#import "DBMarkData.h"

@protocol DBMarkListViewDelegate <NSObject>

- (void)MarkAppearWithDBMarkDataID:(NSString *)markID;

@end

@interface DBMarkListViewController : UITableViewController

@property (nonatomic, assign) id<DBMarkListViewDelegate> delegate;
@property (nonatomic, retain) DBLocalTileDataManager *DataMan;

@end
