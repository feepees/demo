//
//  DBLandDataViewController.h
//  HZDuban
//
//  Created by mac on 12-7-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//取点查询后得到的数据的Controller。
#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

@protocol DBSingleLandInfoViewControllerDelegate <NSObject>
- (void)singleLandInfoViewPopoverDone;
@end

@interface DBSingleLandInfoViewController : UIViewController
<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *LandDataTabView;
}

@property (nonatomic, assign) id<DBSingleLandInfoViewControllerDelegate> delegate;

@property (nonatomic, retain) NSDictionary *result;
@property (nonatomic, retain) AGSGeometry *geometry;

- (id)initWithResult:(NSDictionary *)info;
- (id)initWithResult:(AGSIdentifyResult *)result andENNAME:(NSString *)ENNAME;

@end
