//
//  DBQueryMenuViewController.h
//  HZDuban
//
//  Created by sunz on 13-7-26.
//
//

#import <UIKit/UIKit.h>
@protocol DBMapLayerQueryDelegate <NSObject>
@required
- (void)MapLayerQuery:(NSString*)Layer;
@end

@interface DBQueryMenuViewController : UITableViewController

@property (weak, nonatomic) id <DBMapLayerQueryDelegate> MapLayerQueryDeg;
@end
