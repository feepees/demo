//
//  DBBaseMapConfViewController.h
//  HZDuban
//
//  Created by  on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DBBaseMapLayerConfViewDelegate <NSObject>
- (void)ConfMapViewWithNameArray:(NSArray *)layerName andWithIndexArray:(NSArray *)index andWithType:(NSInteger)type;
@end

@interface DBBaseMapConfViewController : UITableViewController<UITableViewDataSource,UITableViewDelegate, UITextViewDelegate>
{
    id <DBBaseMapLayerConfViewDelegate>Delegate;
}
@property (nonatomic, assign) id <DBBaseMapLayerConfViewDelegate>Delegate;
@property (nonatomic, assign) NSInteger nBaseMapType;
@property (nonatomic, retain) NSMutableDictionary *BaseMapLayersDic;
@property (nonatomic, retain) NSMutableDictionary *OrgBaseMapLayersDic;

@end
