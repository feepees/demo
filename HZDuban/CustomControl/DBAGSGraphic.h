//
//  DBAGSGraphic.h
//  HZDuban
//
//  Created by  on 12-8-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <ArcGIS/ArcGIS.h>

@interface DBAGSGraphic : AGSGraphic
//Graphic类型:0为标注，1为POI，2为地块。
@property (nonatomic, assign) int TypeFlg;
//标注ID
@property (nonatomic, retain) NSString *MarkID;

//POI相关详细信息
@property (nonatomic, assign) int POIIndex;
@property (nonatomic, retain) NSString *ObjectID;
@property (nonatomic, assign) BOOL bIsHighlighted;
//地块相关详细信息
@property (nonatomic, retain) NSString *Id;
@property (nonatomic, retain) NSString *BH;         // 编号
@property (nonatomic, retain) NSString *DKBH;       // 地块编号
@property (nonatomic, retain) NSString *DisscuseAffair;           // 讨论事项
@property (nonatomic, retain) NSString *DKName;      // 名称
@property (nonatomic, retain) NSString *DKBsm;
@property (nonatomic, retain) NSString *TopicID;      // 
@property (nonatomic, retain) NSString *Notes;        // 备注
@property (nonatomic, retain) NSString *DKApplicant; // 申请单位
@property (nonatomic, retain) AGSGeometry * DKGeometry;     // 地块位置坐标
@property (nonatomic, retain) NSString * DKBZXX;
@property (nonatomic, retain) NSString * DKLX;

// add by niurg 2016.02.16
// 选中的边框颜色
@property (nonatomic, retain)AGSSimpleFillSymbol *outerSelectedSymbol;
// 非选中状态的边框颜色
@property (nonatomic, retain)AGSSimpleFillSymbol *outerNoSelectedSymbol;
// end

@end
