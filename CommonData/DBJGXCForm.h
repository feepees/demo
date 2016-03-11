//
//  DBJGXCForm.h
//  HZDuban
//
//  Created by sunz on 13-7-4.
//
//

#import <Foundation/Foundation.h>

// 监管巡察表
@interface DBJGXCForm : NSObject

@property (nonatomic, retain) NSString *FormId;                 // 监管巡察表ID
@property (nonatomic, retain) NSString *DKId;                   // 监管巡察地块ID
@property (nonatomic, retain) NSString *QLR;                    // 权力人
@property (nonatomic, retain) NSString *Area;                   // 面积

@property (nonatomic, assign) BOOL BJQK;                        // 报建情况
@property (nonatomic, retain) NSString *GCGHXKZBH;              // 报建后的建设工程规划许可证编号
@property (nonatomic, retain) NSString *BJQK_Reason;            // 没有报建的原因

@property (nonatomic, assign) BOOL DGQK;                        // 动工情况
@property (nonatomic, retain) NSString *DGQK_Reason;            // 没有动工的原因

@property (nonatomic, assign) BOOL KFQK;                        // 开发情况
@property (nonatomic, retain) NSString *KFQK_Reason;            // 没有开发的原因

@property (nonatomic, assign) BOOL JGQK;                        // 竣工情况
@property (nonatomic, retain) NSString *JGYSHGZBH;              // 竣工验收合格证编号
@property (nonatomic, retain) NSString *JGQK_Reason;            // 没有竣工的原因

//  XCR
//  XC_Date 

@end
