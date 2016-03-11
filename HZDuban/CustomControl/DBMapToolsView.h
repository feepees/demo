//
//  DBMapToolsView.h
//  HZDuban
//
//  Created by navinfoaec on 15/9/20.
//
//

#import <UIKit/UIKit.h>

@protocol DBMapToolsViewDelegate <NSObject>
@optional
// 第N个按钮被按下
// 0:长度计算       1：面积计算      2:添加标注    3:清除
- (void)btnClickedAtIndex:(UIButton*)sender;
@end

// 显示工具类
@interface DBMapToolsView : UIView
{
    UIButton *_lengthMesureBtn;
    UIButton *_areaMesureBtn;
    UIButton *_cleanBtn;
    
    UIButton *_addMarkBtn;
}
@property(nonatomic, assign)id<DBMapToolsViewDelegate> delegate;

// 是否正在编辑标注状态
@property(nonatomic, assign) BOOL bIsAddMarkEditing;

@end
