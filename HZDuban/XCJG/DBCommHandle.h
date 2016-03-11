//
//  DBCommHandle.h
//  HZDuban
//
//  Created by sunz on 13-7-3.
//
//

#import <Foundation/Foundation.h>
#import <ArcGIS/ArcGIS.h>

@interface DBCommHandle : NSObject

// 获取单例
+ (DBCommHandle *)instance;
// 释放实例内存
+(void)releaseInstance;

- (AGSCompositeSymbol*)GetSymbolWithNumber:(NSInteger)stopNumber UnitText:(NSString*)UnitTextVal TypeFlg:(NSInteger)Flg;
@end
