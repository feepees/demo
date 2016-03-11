//
//  DBAttributeViewController.h
//  HZDuban
//
//  Created by  on 12-7-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBPOIData.h"

@protocol DBAttributeViewDelegate <NSObject>

- (void)ScrollViewAppearWithPictureArray:(NSArray *)pictureArray;

@end

//显示POI的详细信息
@interface DBAttributeViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    id <DBAttributeViewDelegate> _delegate;
}

@property (nonatomic, retain) DBPOIData *DBPOIDataItem;
@property (weak, nonatomic) id <DBAttributeViewDelegate> delegate;

- (void)SetAttributeData:(NSMutableDictionary*)attributes;
- (void)POIInfoViewWillAppearByPOIData:(DBPOIData *)DBPOIData;

@end

