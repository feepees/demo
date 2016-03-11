//
//  DBXCDKListViewController.h
//  HZDuban
//
//  Created by sunz on 13-7-4.
//
//

#import <UIKit/UIKit.h>
#import "DBLocalTileDataManager.h"
#import "EGORefreshTableHeaderView.h"

@protocol DBJGDKDataViewAppearProtocol <NSObject>

@required
- (void)ViewAppearWithJGDKDataItem:(NSDictionary *)DBJGDKDataDic;
@end

@interface DBXCDKListViewController : UITableViewController<DBXCDKViewReloadDelegate, EGORefreshTableHeaderDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) id <DBJGDKDataViewAppearProtocol> delegate;

-(void)SetSubPopoverHiden;
- (void)DownLoadXCDK;
@end
