//
//  DBXCGeometryNameViewController.h
//  HZDuban
//
//  Created by sunz on 13-7-9.
//
//

#import <UIKit/UIKit.h>

@protocol DBXCGeometryNameViewDelegate <NSObject>

- (void)AddGeometry:(NSString*)Name Memo:(NSString*)Memo;
-(void)AddGeometryCancel;
- (void)CancelWithFlag:(NSInteger)CancelFlag andWithMarkID:(NSString *)MarkID;

@end


@interface DBXCGeometryNameViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
{
    NSInteger flag;
}

@property (nonatomic, assign) id<DBXCGeometryNameViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame;
- (void)DBXCGeometryNameViewAppear:(NSString *)GeometryName GeometryMemo:(NSString*)GeometryMemo;

@end
