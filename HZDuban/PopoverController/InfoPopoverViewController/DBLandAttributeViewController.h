//
//  DBLandAttributeViewController.h
//  HZDuban
//
//  Created by mac on 12-8-1.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataGridComponent.h"


@protocol DBLandAttributeViewDelegate <NSObject>
- (void)LandAttributeViewPopoverDone;
@end

@interface DBLandAttributeViewController : UIViewController<DataGridComponentDelegate> //<UITableViewDelegate, UITableViewDataSource>
{
    UITableView *LandDataTabView;
    id<DBLandAttributeViewDelegate> delegate;
    
    //NSArray *_LandPriceInfoArr;
    //DBLandPriceInfo *_LandPriceInfo;
    //NSArray *_PriceResults;
}

//@property (nonatomic, retain) AGSFeatureSet *allFeatureSet;
@property (nonatomic, assign) id<DBLandAttributeViewDelegate> delegate;
//@property (nonatomic, retain) NSArray *graphicArray;
//@property (nonatomic, retain) NSArray *TitleArray;
//@property (nonatomic, retain) NSMutableArray *BSMArray;
//@property (nonatomic, retain) NSMutableArray *OBJECTIDArray;
//@property (nonatomic, retain) NSMutableArray *AreaArray;
//@property (nonatomic, retain) NSMutableArray *LengthArray;
//@property (nonatomic, retain) NSMutableArray *YSDMArray;

@property (nonatomic, retain) NSArray *PriceResults;

@end
