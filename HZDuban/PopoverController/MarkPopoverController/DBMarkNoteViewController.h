//
//  DBMarkNoteViewController.h
//  HZDuban
//
//  Created by mac on 12-8-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "DBAGSGraphic.h"


@protocol DBMarkNoteViewDelegate <NSObject>

- (void)SaveMark;
- (void)DeleteMark:(NSString *)MarkID;
- (void)CancelMarkWithFlag:(NSInteger)CancelFlag andWithMarkID:(NSString *)MarkID;

@end

@interface DBMarkNoteViewController : UIViewController
    <UITableViewDelegate, UITableViewDataSource>
{
    NSInteger flag;
}

@property (nonatomic, assign) id<DBMarkNoteViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)MarkNoteViewWillAppearByGraphicID:(NSString *)GraphicID andWithCancelFalg:(NSInteger)CancelFalg;

@end
