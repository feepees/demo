//
//  ModelTableViewController.h
//  DocumentManager
//
//  Created by mac  on 12-12-19.
//  Copyright (c) 2012年 mac . All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ModelTableViewControllerDelegate <NSObject>

- (void)CancelBtnTouched;
- (void)OkeyBtnTouched;
- (void)ModelCellDidSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface ModelTableViewController : UITableViewController
{
    BOOL bIsSelectedModel;
}
@property (nonatomic, assign) id<ModelTableViewControllerDelegate> ModelTableViewDelegate;
//1为处理意见 4为传阅意见
@property (nonatomic, assign) NSInteger type;

@end
