//
//  DBXCDKDataItem.h
//  HZDuban
//
//  Created by sunz on 13-7-4.
//
//

#import <Foundation/Foundation.h>

// 监管地块数据

@interface DBXCDKDataItem : NSObject

@property (nonatomic, retain) NSString *Id;                 // 监管地块ID
@property (nonatomic, retain) NSString *ProjectName;        // 项目名称
@property (nonatomic, retain) NSString *QLR;                // 权力人
@property (nonatomic, retain) NSString *ZDH;                // 宗地号

@property (nonatomic, retain) NSString *Area;               // 面积

@property (nonatomic, retain) NSString *Address;            // 坐落
@property (nonatomic, retain) NSString *UsePurpose;         // 用途
@property (nonatomic, retain) NSString *ProjectStartDate;   // 开工日期
@property (nonatomic, retain) NSString *ProjectEndDate;     // 竣工日期
@property (nonatomic, retain) NSString *ProjectStatus;      // 工程状态
@end
