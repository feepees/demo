//
//  DBMapToolsView.m
//  HZDuban
//
//  Created by navinfoaec on 15/9/20.
//
//

#import "DBMapToolsView.h"

@implementation DBMapToolsView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //
        [self initUI];
    }
    return self;
}

// 初始化控件
-(void)initUI
{
    // all with is :(5+58) * 按钮个数
    _lengthMesureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_lengthMesureBtn addTarget:self action:@selector(lengthBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_lengthMesureBtn setBackgroundImage:[UIImage imageNamed:@"MeasureLength.png"] forState:UIControlStateNormal];
    [_lengthMesureBtn setBackgroundImage:[UIImage imageNamed:@"MeasureLength2.png"] forState:UIControlStateSelected];
    [_lengthMesureBtn setTag:100];
    CGRect frame = CGRectMake(5, 3, 58, 40);
    [_lengthMesureBtn setFrame:frame];
    
    _areaMesureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_areaMesureBtn addTarget:self action:@selector(areaBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_areaMesureBtn setBackgroundImage:[UIImage imageNamed:@"measureArea.png"] forState:UIControlStateNormal];
    [_areaMesureBtn setBackgroundImage:[UIImage imageNamed:@"measureArea2.png"] forState:UIControlStateSelected];
    [_areaMesureBtn setTag:101];
    frame.origin.x = frame.origin.x + frame.size.width + 5;
    [_areaMesureBtn setFrame:frame];
    
    // 添加标注按钮
    _addMarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_addMarkBtn addTarget:self action:@selector(addMarkBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_addMarkBtn setImage:[UIImage imageNamed:@"MarkBlackPin.png"] forState:UIControlStateNormal];
//    [_addMarkBtn setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    [_addMarkBtn setImage:[UIImage imageNamed:@"MarkPin.png"] forState:UIControlStateSelected];
//    [_addMarkBtn setImageEdgeInsets:UIEdgeInsetsMake(2, 2, 2, 2)];
    [_addMarkBtn setTag:102];
    frame.origin.x = frame.origin.x + frame.size.width + 5;
    [_addMarkBtn setFrame:frame];
    
    // 清除按钮
    _cleanBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cleanBtn addTarget:self action:@selector(cleanBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_cleanBtn setBackgroundImage:[UIImage imageNamed:@"MapErase.png"] forState:UIControlStateNormal];
    [_cleanBtn setTag:103];
    frame.origin.x = frame.origin.x + frame.size.width + 5;
    [_cleanBtn setFrame:frame];
    
    [self addSubview:_lengthMesureBtn];
//    [_lengthMesureBtn release];
    
    [self addSubview:_areaMesureBtn];
//    [_areaMesureBtn release];
    
    [self addSubview:_addMarkBtn];
//    [_addMarkBtn release];
    
    [self addSubview:_cleanBtn];
//    [_cleanBtn release];
    
    return;
}

-(void)selectSet:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    if (btn.isSelected) {
        [btn setSelected:NO];
    }
    else{
        [btn setSelected:YES];
    }
    return;
}
-(void)lengthBtnClick:(id)sender
{
    [self selectSet:sender];
    [_areaMesureBtn setSelected:NO];
    
    if ([_delegate respondsToSelector:@selector(btnClickedAtIndex:)]) {
        [self.delegate btnClickedAtIndex:sender];
    }
    
    return;
}

-(void)areaBtnClick:(id)sender
{
    [self selectSet:sender];
    [_lengthMesureBtn setSelected:NO];
    if ([_delegate respondsToSelector:@selector(btnClickedAtIndex:)]) {
        [self.delegate btnClickedAtIndex:sender];
    }
    
    return;
}

-(void)addMarkBtnClick:(id)sender
{
    [self selectSet:sender];
    if ([_delegate respondsToSelector:@selector(btnClickedAtIndex:)]) {
        [self.delegate btnClickedAtIndex:sender];
    }
    
    return;
}
-(BOOL)bIsAddMarkEditing
{
    return  _addMarkBtn.isSelected;
}

-(void)cleanBtnClick:(id)sender
{
    [self selectSet:sender];
    [_areaMesureBtn setSelected:NO];
    [_lengthMesureBtn setSelected:NO];
    if ([_delegate respondsToSelector:@selector(btnClickedAtIndex:)]) {
        [self.delegate btnClickedAtIndex:sender];
    }
    
    return;
}



-(void)layoutSubviews
{
    
    return;
}

@end
