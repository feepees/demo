//
//  CommHeader.h
//  HZDuban
//
//  Created by sunz on 13-3-15.
//
//

#ifndef HZDuban_CommHeader_h
#define HZDuban_CommHeader_h

#define BASEMAPLAYER_NAME       @"BaseMapLayer"
#define ROAD_MAPLAYER_NAME      @"道路"
#define DEFAULT_MAPLAYER_NAME   @"地图"
#define SATELLITE_MAPLAYER_NAME @"影像"
#define MIX_MAPLAYER_NAME       @"混合"

#define DocumentDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]

#define AppBundleDir [NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSUserDomainMask, YES)lastObject]

#define SYSYTEM_VERSION     [[[UIDevice currentDevice] systemVersion] floatValue]

#define SCREEN_WIDTH ((SYSYTEM_VERSION > 7.9) ? [[UIScreen mainScreen] applicationFrame].size.width : [[UIScreen mainScreen] applicationFrame].size.height)

#define SCREEN_HEIGHT ((SYSYTEM_VERSION > 7.9) ? [[UIScreen mainScreen] applicationFrame].size.height : [[UIScreen mainScreen] applicationFrame].size.width)

#define SCREEN_WIDTH2     [[UIScreen mainScreen] applicationFrame].size.width
#define SCREEN_HEIGHT2   [[UIScreen mainScreen] applicationFrame].size.height

// add by niurg 2015.9
// 半屏不包含右侧箭头按钮的宽度
#define Half_Subject_Width_Small    (SCREEN_WIDTH * 0.6)
// 半屏包含右侧箭头按钮的宽度
#define Half_Subject_Width_Big      (Half_Subject_Width_Small + 28)

// 全屏不包含右侧箭头按钮的宽度
#define Full_Subject_Width_Small    (SCREEN_WIDTH - 30)
// 全屏包含右侧箭头按钮的宽度
#define Full_Subject_Width_Big      (Full_Subject_Width_Small + 28)

#define top_Bar_Btn_tuGui   @"tuGui"
#define top_Bar_Btn_chengGui   @"chengGui"
#define top_Bar_Btn_luWang   @"luWang"
#define top_Bar_Btn_faZheng   @"faZheng"

#define top_Bar_Btn_menuBtnName     @"menuBtnName"
#define top_Bar_Btn_mapLayerName     @"mapLayerName"
#define top_Bar_Btn_mapLayerUrl     @"mapLayerUrl"
// 是否是切换地图图层
#define top_Bar_Btn_mapLayerIsTile  @"isTileLayer"

#define top_bar_heigth ([[[UIDevice currentDevice] systemVersion] floatValue] < 7.9 ? 0.f : 44.f)
    
#endif
