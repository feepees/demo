//
//  DBChoosePicViewController.h
//  HZDuban
//
//  Created by mac  on 13-6-21.
//
//

#import <UIKit/UIKit.h>

@protocol DBChoosePicViewControllerDelegate <NSObject>

- (void)chooseBtnTouched:(NSInteger)index;
- (void)chooseBtn2Touched:(NSInteger)index;

@end

@interface DBChoosePicViewController : UIViewController


@property (nonatomic, assign) id<DBChoosePicViewControllerDelegate> delegate;
@property (nonatomic, assign) NSInteger nFlg;

@end
